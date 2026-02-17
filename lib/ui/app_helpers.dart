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

/// ストレージとオーディオ再生に必要な権限を確認・要求するヘルパー
/// - Android: 現行の `permission_handler` を用いて可能な権限を順に要求します。
/// - iOS: 特別なストレージ権限は不要なためここではオーディオ関連の権限のみ確認します。
Future<bool> ensureStorageAndAudioPermissions(BuildContext context) async {
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

    // 2) ストレージ / メディアオーディオ
    // Android のバージョン依存で要求する権限が変わるが
    // `permission_handler` は高レベルの Permission.storage / Permission.manageExternalStorage を提供するため
    // できる限り安全な順で要求する。

    // 説明ダイアログを表示
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ストレージ権限の許可'),
        content: const Text('音楽ファイルや歌詞ファイルの読み込みのためにストレージアクセスを許可してください。'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('キャンセル')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('OK')),
        ],
      ),
    );
    if (proceed != true) return false;

    // まず通常のストレージ権限
    try {
      final storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        final res = await Permission.storage.request();
        if (res.isGranted) return true;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('[Perm] storage request failed: $e');
    }

    // Android 11+ 等で MANAGE_EXTERNAL_STORAGE が必要な場合のフォールバック
    try {
      final manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        final res = await Permission.manageExternalStorage.request();
        if (res.isGranted) return true;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('[Perm] manageExternalStorage not available or failed: $e');
    }

    // 最後にメディアオーディオ（Android 13+）
    try {
      final audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        final res = await Permission.audio.request();
        if (res.isGranted) return true;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('[Perm] audio permission check failed: $e');
    }

    return false;
  } catch (e) {
    debugPrint('[Perm] ensureStorageAndAudioPermissions error: $e');
    return false;
  }
}
