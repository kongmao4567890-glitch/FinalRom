import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'patcher.dart';
import 'checksums.dart';

/// BPS (Binary Patch System) patcher. Ported from UniPatcher's `BPS.kt`.
///
/// BPS records are tiny and numerous, so per-record async file I/O is far too
/// slow — but loading a multi-hundred-MB ROM, patch and output into memory
/// stalls (or kills) the app on large patches. This implementation therefore
/// streams everything through fixed-size buffers using synchronous file I/O
/// (patching runs in a background isolate): the patch is read sequentially, the
/// ROM through a sliding block cache, and the output through a write buffer
/// that can also serve `TARGET_COPY` back-references. Memory use is a few MiB
/// regardless of file size. The three embedded CRC32 values (source, target,
/// patch) are verified unless [apply] is called with `ignoreChecksum: true`.
class BpsPatcher extends RomPatcher {
  BpsPatcher({
    required super.patchFile,
    required super.romFile,
    required super.outputFile,
  });

  static const int _allChecksumsSize = 12;

  @override
  Future<PatchReport> apply({bool ignoreChecksum = false}) async {
    final patchLen = await patchFile.length();
    if (patchLen < 19) {
      throw PatchException("Patch file is too small or corrupted.");
    }

    RandomAccessFile? patchRaf;
    RandomAccessFile? romRaf;
    RandomAccessFile? outRaf;
    try {
      patchRaf = await patchFile.open(mode: FileMode.read);

      final footer = Uint8List(_allChecksumsSize);
      await patchRaf.setPosition(patchLen - _allChecksumsSize);
      if (await patchRaf.readInto(footer) != _allChecksumsSize) {
        throw PatchException("Patch file is too small or corrupted.");
      }
      final footerView = ByteData.sublistView(footer);
      final int sourceCrc = footerView.getUint32(0, Endian.little);
      final int targetCrc = footerView.getUint32(4, Endian.little);
      final int patchCrc = footerView.getUint32(8, Endian.little);

      await patchRaf.setPosition(0);
      final magic = await patchRaf.read(4);
      if (magic.length < 4 ||
          magic[0] != 0x42 ||
          magic[1] != 0x50 ||
          magic[2] != 0x53 ||
          magic[3] != 0x31) {
        // "BPS1"
        throw PatchException("Not a valid BPS patch.");
      }

      if (!ignoreChecksum) {
        final actualPatchCrc =
            await crc32OfFile(patchFile, length: patchLen - 4);
        if (actualPatchCrc != patchCrc) {
          throw PatchException("Patch file is corrupted (CRC mismatch).");
        }
        final actualSourceCrc = await crc32OfFile(romFile);
        if (actualSourceCrc != sourceCrc) {
          throw PatchException("ROM is not compatible with this patch.");
        }
      }

      romRaf = await romFile.open(mode: FileMode.read);
      outRaf = await outputFile.open(mode: FileMode.write);

      final patch = _PatchReader(patchRaf, patchLen);
      patch.seek(4); // skip magic
      final rom = _RomReader(romRaf, await romFile.length());

      patch.decodeVarint(); // source size (the ROM is read directly)
      final targetSize = patch.decodeVarint();
      final metadataSize = patch.decodeVarint();
      patch.skip(metadataSize);

      final out = _OutputWriter(outRaf);
      int romRelOffset = 0;
      int outRelOffset = 0;
      final int dataEnd = patchLen - _allChecksumsSize;

      try {
        while (patch.position < dataEnd) {
          int length = patch.decodeVarint();
          final mode = length & 3;
          length = (length >> 2) + 1;
          if (out.position + length > targetSize) {
            throw PatchException("Patch file is corrupted.");
          }

          switch (mode) {
            case 0: // SOURCE_READ — copy from ROM at the current output position
              out.writeFromRom(rom, out.position, length);
              break;
            case 1: // TARGET_READ — copy literal bytes from the patch
              out.writeFromPatch(patch, length);
              break;
            case 2: // SOURCE_COPY — copy from ROM at a relative offset
              int offset = patch.decodeVarint();
              offset = ((offset & 1) != 0 ? -1 : 1) * (offset >> 1);
              romRelOffset += offset;
              out.writeFromRom(rom, romRelOffset, length);
              romRelOffset += length;
              break;
            case 3: // TARGET_COPY — copy from already-written output (may overlap)
              int offset = patch.decodeVarint();
              offset = ((offset & 1) != 0 ? -1 : 1) * (offset >> 1);
              outRelOffset += offset;
              out.copyWithin(outRelOffset, length);
              outRelOffset += length;
              break;
          }
        }
        if (out.position < targetSize) {
          out.writeZeros(targetSize - out.position);
        }
        out.flush();
      } on RangeError {
        throw PatchException("Patch file is corrupted.");
      }

      if (!ignoreChecksum && out.crc != targetCrc) {
        throw PatchException("Wrong checksum after patching.");
      }
    } finally {
      await patchRaf?.close();
      await romRaf?.close();
      await outRaf?.close();
    }

    final outcome =
        ignoreChecksum ? CheckOutcome.skipped : CheckOutcome.passed;
    return PatchReport(format: "BPS", checks: [
      PatchCheck("Patch (CRC32)", outcome),
      PatchCheck("Source ROM (CRC32)", outcome),
      PatchCheck("Output (CRC32)", outcome),
    ]);
  }
}

/// Buffered sequential reader over the patch file.
class _PatchReader {
  static const int _bufSize = 1 << 20;

  final RandomAccessFile _raf;
  final int _length;
  final Uint8List _buf = Uint8List(_bufSize);
  int _bufStart = 0; // file offset of _buf[0]
  int _bufLen = 0;
  int position = 0; // logical file position

  _PatchReader(this._raf, this._length);

  void seek(int pos) => position = pos;

  void skip(int n) {
    if (n < 0 || position + n > _length) {
      throw PatchException("Patch file is corrupted.");
    }
    position += n;
  }

  void _fill() {
    _raf.setPositionSync(position);
    _bufStart = position;
    _bufLen = _raf.readIntoSync(_buf);
    if (_bufLen == 0) throw PatchException("Patch file is corrupted.");
  }

  int readByte() {
    if (position < _bufStart || position >= _bufStart + _bufLen) _fill();
    return _buf[position++ - _bufStart];
  }

  /// Reads [n] bytes into [dst] at [dstOffset].
  void readInto(Uint8List dst, int dstOffset, int n) {
    while (n > 0) {
      if (position < _bufStart || position >= _bufStart + _bufLen) _fill();
      final int idx = position - _bufStart;
      final int take = math.min(n, _bufLen - idx);
      dst.setRange(dstOffset, dstOffset + take, _buf, idx);
      position += take;
      dstOffset += take;
      n -= take;
    }
  }

  int decodeVarint() {
    int offset = 0;
    int shift = 1;
    while (true) {
      final x = readByte();
      offset += (x & 0x7f) * shift;
      if ((x & 0x80) != 0) break;
      shift <<= 7;
      offset += shift;
    }
    return offset;
  }
}

/// Random-access reader over the source ROM with a sliding block cache, so the
/// mostly-sequential access pattern of BPS costs one syscall per few MiB rather
/// than one per record.
class _RomReader {
  static const int _cacheSize = 4 << 20;

  final RandomAccessFile _raf;
  final int length;
  final Uint8List _cache = Uint8List(_cacheSize);
  int _cacheStart = 0;
  int _cacheLen = 0;

  _RomReader(this._raf, this.length);

  /// Reads [n] bytes starting at ROM offset [pos] into [dst] at [dstOffset].
  void read(int pos, Uint8List dst, int dstOffset, int n) {
    if (pos < 0 || pos + n > length) {
      throw PatchException("ROM is not compatible with this patch.");
    }
    while (n > 0) {
      if (pos < _cacheStart || pos >= _cacheStart + _cacheLen) {
        _raf.setPositionSync(pos);
        _cacheStart = pos;
        _cacheLen = _raf.readIntoSync(_cache);
        if (_cacheLen == 0) {
          throw PatchException("ROM is not compatible with this patch.");
        }
      }
      final int idx = pos - _cacheStart;
      final int take = math.min(n, _cacheLen - idx);
      dst.setRange(dstOffset, dstOffset + take, _cache, idx);
      pos += take;
      dstOffset += take;
      n -= take;
    }
  }
}

/// Buffered output writer that also serves reads of its own output (for BPS
/// `TARGET_COPY`) and maintains a running CRC32 of everything written.
class _OutputWriter {
  static const int _bufSize = 4 << 20;

  final RandomAccessFile _raf;
  final Uint8List _buf = Uint8List(_bufSize);
  final Uint8List _tmp = Uint8List(_bufSize);
  final Crc32 _crc = Crc32();
  int _bufLen = 0;
  int _flushed = 0; // bytes already written to the file

  _OutputWriter(this._raf);

  /// Total bytes produced so far.
  int get position => _flushed + _bufLen;

  /// CRC32 of all bytes written; valid after [flush].
  int get crc => _crc.value;

  void flush() {
    if (_bufLen == 0) return;
    _crc.update(_buf, 0, _bufLen);
    _raf.writeFromSync(_buf, 0, _bufLen);
    _flushed += _bufLen;
    _bufLen = 0;
  }

  void _write(Uint8List src, int srcOffset, int n) {
    while (n > 0) {
      if (_bufLen == _bufSize) flush();
      final int take = math.min(n, _bufSize - _bufLen);
      _buf.setRange(_bufLen, _bufLen + take, src, srcOffset);
      _bufLen += take;
      srcOffset += take;
      n -= take;
    }
  }

  void writeFromRom(_RomReader rom, int romPos, int n) {
    while (n > 0) {
      final int take = math.min(n, _bufSize);
      rom.read(romPos, _tmp, 0, take);
      _write(_tmp, 0, take);
      romPos += take;
      n -= take;
    }
  }

  void writeFromPatch(_PatchReader patch, int n) {
    while (n > 0) {
      final int take = math.min(n, _bufSize);
      patch.readInto(_tmp, 0, take);
      _write(_tmp, 0, take);
      n -= take;
    }
  }

  void writeZeros(int n) {
    _tmp.fillRange(0, math.min(n, _bufSize), 0);
    while (n > 0) {
      final int take = math.min(n, _bufSize);
      _write(_tmp, 0, take);
      n -= take;
    }
  }

  /// Appends [n] bytes copied from this output's own earlier bytes starting at
  /// [src]. The source range may overlap the bytes being written (the classic
  /// LZ77 run-length idiom); the copy is done in doubling chunks.
  void copyWithin(int src, int n) {
    if (src < 0 || src >= position) {
      throw PatchException("Patch file is corrupted.");
    }
    while (n > 0) {
      final int avail = position - src;
      int take = math.min(math.min(n, avail), _bufSize);
      if (src < _flushed) {
        // Source lies (at least partly) in the already-flushed region.
        take = math.min(take, _flushed - src);
        _raf.setPositionSync(src);
        final int got = _raf.readIntoSync(_tmp, 0, take);
        _raf.setPositionSync(_flushed);
        if (got != take) throw PatchException("Patch file is corrupted.");
      } else {
        final int idx = src - _flushed;
        _tmp.setRange(0, take, _buf, idx);
      }
      _write(_tmp, 0, take);
      src += take;
      n -= take;
    }
  }
}
