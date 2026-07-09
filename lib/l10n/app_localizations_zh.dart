// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese Simplified (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Final ROM';

  @override
  String get tabSingleFile => '单文件';

  @override
  String get tabThreeDs => '3DS';

  @override
  String get tabBatchMode => '批量模式';

  @override
  String get tabPatcher => '补丁工具';

  @override
  String get tabHasher => '哈希校验';

  @override
  String get btnDecrypt => '解密';

  @override
  String get btnEncrypt => '加密';

  @override
  String get btnCancel => '取消';

  @override
  String get btnClearQueue => '清空';

  @override
  String get btnBrowse => '浏览';

  @override
  String get btnBrowseFolder => '文件夹';

  @override
  String get settingsTitle => '设置';

  @override
  String get trimPadding => '去除尾部填充（解密时）';

  @override
  String get trimPaddingDesc => '去除文件末尾无用的 0xFF 填充数据，节省空间。';

  @override
  String get outputHandling => '输出处理方式';

  @override
  String get outputHandlingNewFile => '创建新文件';

  @override
  String get outputHandlingOverwrite => '覆盖原文件（不可逆）';

  @override
  String get outputLocation => '输出位置';

  @override
  String get outputLocationNextToSource => '源文件旁边';

  @override
  String get outputLocationCustom => '自定义文件夹';

  @override
  String get outputLocationAppDocs => '设备文件夹（应用存储）';

  @override
  String get conflictBehavior => '输出已存在时';

  @override
  String get conflictAsk => '询问';

  @override
  String get conflictOverwrite => '覆盖';

  @override
  String get conflictRename => '自动重命名';

  @override
  String get parallelism => '并行数';

  @override
  String get parallelismDesc => '同时处理的文件数';

  @override
  String get themeMode => '外观';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get dynamicColor => '使用 Material You 动态取色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get statusIdle => '空闲';

  @override
  String get statusDone => '完成';

  @override
  String get statusError => '错误';

  @override
  String get statusSaving => '保存中...';

  @override
  String statusFileSelected(String size) {
    return '$size MiB';
  }

  @override
  String trimMessage(String saved) {
    return '已去除 $saved 字节的填充数据';
  }

  @override
  String batchSummary(int success, int failed, String time) {
    return '成功 $success 个，失败 $failed 个（用时 $time 秒）';
  }

  @override
  String batchProgress(int current, int total) {
    return '已处理 $current / $total';
  }

  @override
  String get errNoFileSelected => '未选择文件';

  @override
  String get errOutputFolderNotSelected => '未选择输出文件夹';

  @override
  String get confirmOverwriteTitle => '覆盖原文件？';

  @override
  String get confirmOverwriteContent => '此操作将不可逆地覆盖原始 ROM 文件。确定要继续吗？';

  @override
  String get btnYes => '是';

  @override
  String get btnNo => '否';

  @override
  String get errInvalidRom => '无效的 3DS ROM';

  @override
  String get fileConflictTitle => '文件已存在';

  @override
  String fileConflictContent(String filename) {
    return '文件 $filename 已存在。请选择操作：';
  }

  @override
  String get actionCancel => '取消';

  @override
  String get actionOverwrite => '覆盖';

  @override
  String get actionRename => '重命名';

  @override
  String queueFileProgress(int current, int total) {
    return '文件 $current / $total';
  }

  @override
  String queueDoneSummary(int ok, int total) {
    return '已完成 $ok / $total';
  }

  @override
  String queueFailuresSummary(int failed, int total) {
    return '失败 $failed / $total';
  }

  @override
  String get aboutTitle => '关于';

  @override
  String get aboutContent => '本应用完全离线运行，不收集任何个人数据。';

  @override
  String get dragDropHintSingle => '将 .3ds ROM 文件拖放到此处';

  @override
  String get dragDropHintBatch => '将 .3ds ROM 文件拖放到此处';

  @override
  String get dragDropHintPatch => '将 ROM 或补丁文件拖放到此处';

  @override
  String get dragDropHintHash => '将文件拖放到此处进行哈希校验';

  @override
  String get dragDropOnly3ds => '仅支持 .3ds 文件';

  @override
  String get dragDropSubtext => '释放鼠标以放置文件';

  @override
  String get romFile => '基础 ROM 文件';

  @override
  String get patchFile =>
      '补丁文件（.ips、.ups、.bps、.ppf、.aps、.ebp、.dps、.xdelta）';

  @override
  String get btnBrowseRom => '浏览 ROM';

  @override
  String get btnBrowsePatch => '浏览补丁';

  @override
  String get btnPatch => '应用补丁';

  @override
  String get errNoPatchSelected => '未选择补丁文件';

  @override
  String get statusPatching => '正在应用补丁...';

  @override
  String get fileToHash => '待哈希文件';

  @override
  String get statusHashing => '正在计算哈希值...';

  @override
  String get ignoreChecksum => '忽略校验和';

  @override
  String get ignoreChecksumSubtitle => '跳过 ROM 和补丁的校验验证';

  @override
  String get errUnsupportedPatch => '不支持的补丁格式';

  @override
  String patchReportFormat(String format) {
    return '格式：$format';
  }

  @override
  String get patchReportNoChecksums => '此格式没有可验证的内置校验和。';

  @override
  String get checkOutcomePassed => '通过';

  @override
  String get checkOutcomeSkipped => '已跳过';

  @override
  String get tabChd => 'CHD';

  @override
  String get tabSwitch => 'Switch';

  @override
  String get chdCreate => '创建 CHD';

  @override
  String get chdExtract => '提取 CHD';

  @override
  String get btnCreate => '创建';

  @override
  String get btnExtract => '提取';

  @override
  String get btnMerge => '合并';

  @override
  String get btnUnmerge => '拆分';

  @override
  String get btnCompress => '压缩';

  @override
  String get btnDecompress => '解压';

  @override
  String get chdCreateHint => '将 .cue 或 .bin 文件拖放到此处';

  @override
  String get chdExtractHint => '将 .chd 文件拖放到此处';

  @override
  String get switchMergeTab => '合并';

  @override
  String get switchSplitTab => '拆分';

  @override
  String get switchCompressTab => '压缩';

  @override
  String get switchDecompressTab => '解压';

  @override
  String get switchMergeHint => '将基础和更新 .nsp / .xci 文件拖放到此处';

  @override
  String get switchUnmergeHint => '将已合并的 .nsp 文件拖放到此处';

  @override
  String get switchCompressHint => '将 .nsp 文件拖放到此处';

  @override
  String get switchDecompressHint => '将 .nsz 文件拖放到此处';

  @override
  String get switchKeysRequired => '此操作需要 prod.keys 文件';

  @override
  String get keysFile => 'prod.keys 文件';

  @override
  String get btnBrowseKeys => '浏览密钥';

  @override
  String get compressionLevel => '压缩级别';

  @override
  String get statusCompressing => '正在压缩...';

  @override
  String get statusExtracting => '正在提取...';

  @override
  String get statusMerging => '正在合并...';

  @override
  String get statusUnmerging => '正在拆分...';

  @override
  String get statusDecompressing => '正在解压...';

  @override
  String unmergeSavedMessage(int count, String dir) {
    return '已写入 $count 个 NSP 文件到 $dir';
  }

  @override
  String unmergeMissingNcaWarning(int count) {
    return '$count 个标题引用了源 NSP 中缺失的 NCA';
  }

  @override
  String get patchCompatibilityChecking => '正在验证 ROM 兼容性...';

  @override
  String get patchCompatibilityCompatible => '补丁与所选 ROM 兼容';

  @override
  String get patchCompatibilityIncompatible =>
      '警告：ROM 校验和不匹配。此补丁可能不兼容。';

  @override
  String get patchCompatibilityUnverifiable => '此补丁格式不支持预先验证';

  @override
  String get btnShare => '分享';

  @override
  String savedToFile(String name) {
    return '已保存：$name';
  }

  @override
  String get alreadyDecryptedMessage => '已经解密 — 未创建新文件';

  @override
  String get clearCache => '清除缓存';

  @override
  String get clearCacheSubtitle => '删除临时和缓存文件';

  @override
  String get cacheCleared => '缓存已清除';

  @override
  String get btnSave => '保存';

  @override
  String get btnShowInFolder => '在文件夹中显示';

  @override
  String get statusCancelling => '正在取消…';

  @override
  String get errInvalidFileType => '所选操作不支持的文件类型';

  @override
  String get keysRequired3ds => '此操作需要 3dskeys.txt 文件';

  @override
  String copiedToClipboard(String label) {
    return '已将 $label 复制到剪贴板';
  }

  @override
  String get chdCodecsTitle => '压缩编解码器';

  @override
  String get chdCodecsHelper => '逗号分隔：cdlz、cdzl、cdfl、cdzs、none';

  @override
  String get chdHunkTitle => '数据块大小（字节）';

  @override
  String get chdHunkHelper => '留空使用默认值';
}
