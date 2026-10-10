import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Key files shipped inside the app bundle (`assets/keys/`).
///
/// Background isolates cannot read Flutter assets and the key parsers work on
/// file paths, so the bundled files are extracted once into the app support
/// directory and handed out as ordinary paths. Anything missing from the bundle
/// simply yields null, in which case the UI falls back to asking the user for
/// a key file as before. A path the user picked explicitly always wins over
/// the bundled one.
class BundledKeys {
  static const String _assetDir = 'assets/keys';
  static const List<String> _files = ['aes_keys.txt', 'prod.keys', 'title.keys'];

  static Future<Map<String, String>>? _extracted;

  static Future<Map<String, String>> _extract() async {
    final result = <String, String>{};
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory(p.join(base.path, 'keys'));
      await dir.create(recursive: true);
      for (final name in _files) {
        try {
          final data = await rootBundle.load('$_assetDir/$name');
          final bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          final file = File(p.join(dir.path, name));
          if (!await file.exists() || await file.length() != bytes.length) {
            await file.writeAsBytes(bytes, flush: true);
          }
          result[name] = file.path;
        } catch (_) {
          // Not bundled: leave it out.
        }
      }
    } catch (_) {
      // No writable support directory: behave as if nothing is bundled.
    }
    return result;
  }

  static Future<Map<String, String>> _ensure() => _extracted ??= _extract();

  /// Path to the bundled 3DS `aes_keys.txt`, or null if not bundled.
  static Future<String?> threeDsKeysPath() async =>
      (await _ensure())['aes_keys.txt'];

  /// Path to the bundled Switch `prod.keys` (its sibling `title.keys` is merged
  /// in automatically by `SwitchKeys.loadFromFile`), or null if not bundled.
  static Future<String?> switchKeysPath() async =>
      (await _ensure())['prod.keys'];
}
