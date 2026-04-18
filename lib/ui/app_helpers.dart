part of 'app_ui.dart';

void _tapFeedback(BuildContext context) {
  Feedback.forTap(context);
  HapticFeedback.selectionClick();
}

void _successFeedback() {
  HapticFeedback.lightImpact();
}

void _warningFeedback() {
  HapticFeedback.mediumImpact();
}

String _breakByHalfWidthSpace(String text) {
  final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (!normalized.contains(' ')) return normalized;
  final words = normalized.split(' ');
  if (words.length == 2) {
    return '${words[0]}\n${words[1]}';
  }
  final firstLineCount = (words.length / 2).ceil();
  final firstLine = words.sublist(0, firstLineCount).join(' ');
  final secondLine = words.sublist(firstLineCount).join(' ');
  return '$firstLine\n$secondLine';
}

TextStyle _imageActionLabelStyle(BuildContext context, {Color? color}) {
  final languageCode = Localizations.localeOf(context).languageCode.toLowerCase();
  final compactLocales = {'en', 'fr', 'de'};
  return TextStyle(
    color: color,
    fontSize: compactLocales.contains(languageCode) ? 13.5 : 14,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );
}

String _t(
  BuildContext context, {
  required String ja,
  required String en,
  String? zh,
  String? ko,
  String? ru,
}) {
  final locale = Localizations.localeOf(context);
  final languageCode = locale.languageCode.toLowerCase();
  if (languageCode == 'ja') return ja;
  if (languageCode == 'zh') return zh ?? en;
  if (languageCode == 'ko') return ko ?? en;
  if (languageCode == 'ru') return ru ?? en;
  return en;
}

// サムネイルクロップ画面を表示
Future<String?> _showImageCropperDialog(BuildContext context, String imagePath) async {
  try {
    final themeBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final themeTextColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    final result = await Navigator.push<ThumbnailCropResult>(
      context,
      MaterialPageRoute(
        builder: (context) => ThumbnailCropScreen(
          imagePath: imagePath,
          themeBackgroundColor: themeBackgroundColor,
          themeTextColor: themeTextColor,
        ),
      ),
    );
    return result?.croppedImagePath;
  } catch (e) {
    debugPrint('[CROP DIALOG] error: $e');
    return null;
  }
}

Future<void> _requestNotificationPermission() async {
  if (!Platform.isAndroid) return;
  try {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  } catch (_) {
    // Ignore permission request errors
  }
}

/// 起動時にメディア権限（音声・画像）をリクエストする
/// - Android 13+: READ_MEDIA_AUDIO → 「音楽とオーディオ」permission group
///                READ_MEDIA_IMAGES → 「写真と動画」permission group（アルバムアート用）
/// - Android ≤ 12: READ_EXTERNAL_STORAGE でまとめてリクエスト
Future<void> _requestMediaPermissions() async {
  if (!Platform.isAndroid) return;
  try {
    final audioStatus = await Permission.audio.status;
    if (!audioStatus.isGranted) {
      await Permission.audio.request();
    }
  } catch (_) {}
  try {
    final photosStatus = await Permission.photos.status;
    if (!photosStatus.isGranted) {
      await Permission.photos.request();
    }
  } catch (_) {}
}

/// ストレージとオーディオ再生に必要な権限を確認・要求するヘルパー
/// - Android: SAF/Media 権限ベースで必要最小限の権限のみ要求します。
/// - iOS: 特別なストレージ権限は不要なためここではオーディオ関連の権限のみ確認します。
Future<bool> ensureStorageAndAudioPermissions(
  BuildContext context, {
  bool forWrite = false,
  String? targetPath,
}) async {
  try {
    if (!Platform.isAndroid) {
      // iOS: 通知などは別途要求するがストレージアクセスは不要
      return true;
    }

    // 1) 先に通知権限（広告/分析のために必要なケースがある）
    try {
      final noti = await Permission.notification.status;
      if (!noti.isGranted) {
        // 簡易説明ダイアログを表示してから通知権限を要求
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('通知権限の許可'),
            content: const Text('広告表示や再生通知のために通知権限が必要な場合があります。許可しますか？'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
            ],
          ),
        );
        if (ok == true) await Permission.notification.request();
      }
    } catch (e) {
      debugPrint('[Perm] notification check failed: $e');
    }

    // 2) SAF/Media ベースの最小権限だけを扱う（全ファイルアクセスは使用しない）

    // 説明ダイアログを表示
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ストレージ権限の許可'),
        content: const Text('音楽ファイルの読み込みのため、必要最小限のメディアアクセスを許可してください。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
        ],
      ),
    );
    if (proceed != true) return false;

    // 最後にメディアオーディオ（Android 13+）
    try {
      final audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        final res = await Permission.audio.request();
        if (res.isGranted && !forWrite) return true;
      } else {
        if (!forWrite) return true;
      }
    } catch (e) {
      debugPrint('[Perm] audio permission check failed: $e');
    }

    // Android 13+ で画像を扱う場合に備えて photos も確認（否認されても致命ではない）
    try {
      final photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted) {
        await Permission.photos.request();
      }
    } catch (e) {
      debugPrint('[Perm] photos permission check failed: $e');
    }

    if (!forWrite) return false;

    final checkPath = targetPath;
    if (checkPath == null || checkPath.isEmpty) return false;

    try {
      final dir = File(checkPath).parent;
      if (!await dir.exists()) return false;
      final probe = File('${dir.path}/.write_probe_${DateTime.now().millisecondsSinceEpoch}.tmp');
      await probe.writeAsString('ok', flush: true);
      if (await probe.exists()) {
        await probe.delete();
      }
      return true;
    } catch (e) {
      debugPrint('[Perm] write probe failed for $checkPath: $e');
      return false;
    }
  } catch (e) {
    debugPrint('[Perm] ensureStorageAndAudioPermissions error: $e');
    return false;
  }
}

bool _isManagedInternalPath(String? value) {
  if (value == null || value.isEmpty) return false;
  final normalized = value.replaceAll('\\', '/').toLowerCase();
  return normalized.contains('/app_flutter/imported_audio/') ||
      normalized.contains('/app_flutter/imported_lyrics/') ||
      normalized.contains('/cache/file_picker/');
}

Future<String?> resolveEditableAudioPath(String? currentPath) async {
  if (currentPath == null || currentPath.isEmpty) return null;
  if (!_isManagedInternalPath(currentPath)) return currentPath;

  try {
    final baseName = p.basename(currentPath);
    if (baseName.isEmpty) return currentPath;

    int? expectedSize;
    try {
      final f = File(currentPath);
      if (await f.exists()) expectedSize = await f.length();
    } catch (_) {}

    final roots = <String>[
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Download',
    ];

    for (final root in roots) {
      final dir = Directory(root);
      if (!await dir.exists()) continue;

      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is! File) continue;
        if (p.basename(entity.path) != baseName) continue;

        if (expectedSize != null) {
          try {
            final len = await entity.length();
            if (len != expectedSize) continue;
          } catch (_) {
            continue;
          }
        }
        return entity.path;
      }
    }
  } catch (e) {
    debugPrint('[PathResolve] 外部実ファイル探索エラー: $e');
  }

  return currentPath;
}

// ─────────────────────────────────────────────
// ダウンロードフォルダへの書き出し（MediaStore）
// ─────────────────────────────────────────────

const _kAppChannel = MethodChannel('appmaker/wallpaper');

/// 音声ファイルをダウンロードフォルダに別名コピーして書き出す。
/// [song] に localPath が無い場合は false を返す。
/// 戻り値: 成功なら保存先 URI/パスの文字列、失敗なら null
Future<String?> exportAudioToDownloads(Song song) async {
  final srcPath = song.localPath;
  if (srcPath == null || srcPath.isEmpty) return null;
  final srcFile = File(srcPath);
  if (!srcFile.existsSync()) return null;

  final ext = p.extension(srcPath).toLowerCase().replaceFirst('.', '');
  final mimeType = switch (ext) {
    'mp3'  => 'audio/mpeg',
    'm4a'  => 'audio/mp4',
    'mp4'  => 'audio/mp4',
    'flac' => 'audio/flac',
    'wav'  => 'audio/wav',
    _      => 'audio/mpeg',
  };

  final safeName = buildExportAudioFileName(song);

  try {
    final result = await _kAppChannel.invokeMethod<String>('exportToDownloads', {
      'sourcePath': srcPath,
      'fileName': safeName,
      'mimeType': mimeType,
    });
    debugPrint('[Export] 音声書き出し完了: $result');
    return result;
  } catch (e) {
    debugPrint('[Export] 音声書き出しエラー: $e');
    return null;
  }
}

String buildExportAudioFileName(Song song) {
  final srcPath = song.localPath ?? '';
  final ext = p.extension(srcPath).toLowerCase().replaceFirst('.', '');
  final baseName = song.title.trim().isEmpty
      ? p.basenameWithoutExtension(srcPath)
      : song.title.trim();
  return '${_sanitizeFileName(baseName)}.$ext';
}

/// LRC ファイルをダウンロードフォルダに別名コピーして書き出す。
/// [song] に lyricsPath が無い場合は false を返す。
/// 戻り値: 成功なら保存先 URI/パスの文字列、失敗なら null
Future<String?> exportLrcToDownloads(Song song) async {
  final srcPath = song.lyricsPath;
  if (srcPath == null || srcPath.isEmpty) return null;
  final srcFile = File(srcPath);
  if (!srcFile.existsSync()) return null;

  final safeName = buildExportLrcFileName(song);

  try {
    final result = await _kAppChannel.invokeMethod<String>('exportToDownloads', {
      'sourcePath': srcPath,
      'fileName': safeName,
      'mimeType': 'application/octet-stream',
    });
    debugPrint('[Export] LRC 書き出し完了: $result');
    return result;
  } catch (e) {
    debugPrint('[Export] LRC 書き出しエラー: $e');
    return null;
  }
}

String buildExportLrcFileName(Song song) {
  final srcPath = song.lyricsPath ?? '';
  final baseName = song.title.trim().isEmpty
      ? p.basenameWithoutExtension(srcPath)
      : song.title.trim();
  return '${_sanitizeFileName(baseName)}.lrc';
}

/// ファイル名に使えない文字を除去する
String _sanitizeFileName(String name) {
  return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
}
