part of '../app_ui.dart';

extension _SettingsActions on _SettingsTab {
  /// YouTube動画情報を取得して確認ダイアログを表示
  void _showYouTubeConfirmDialog(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    // YouTube ダウンロード機能はリリース版で削除されています。
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('お知らせ'),
        content: const Text('この機能は削除されました。歌詞はローカルなLRCファイルのみサポートします。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  Future<String?> _materializePickedFile(
    PlatformFile file, {
    required String subDir,
    String? preferredName,
  }) async {
    try {
      final srcPath = file.path;
      if (srcPath != null && srcPath.isNotEmpty) {
        final srcFile = File(srcPath);
        if (await srcFile.exists()) {
          final normalized = srcPath.replaceAll('\\', '/').toLowerCase();
          final isCachePath = normalized.contains('/cache/file_picker/');
          if (!isCachePath) {
            return srcPath;
          }
        }
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final targetDir = Directory(p.join(docsDir.path, subDir));
      if (!targetDir.existsSync()) {
        await targetDir.create(recursive: true);
      }

      final fileName = preferredName ?? file.name;
      final safeName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final destPath = p.join(targetDir.path, safeName);
      final destFile = File(destPath);

      if (srcPath != null && srcPath.isNotEmpty) {
        final srcFile = File(srcPath);
        if (await srcFile.exists()) {
          await srcFile.copy(destPath);
          return destPath;
        }
      }

      final stream = file.readStream;
      if (stream != null) {
        final sink = destFile.openWrite();
        await stream.pipe(sink);
        return destPath;
      }

      return null;
    } catch (e) {
      debugPrint('[LocalFile] ファイル実体化失敗 (${file.name}): $e');
      return null;
    }
  }

  /// YouTube音声ダウンロード処理を開始
  void _startYouTubeDownload(BuildContext context, WidgetRef ref, String url, String videoTitle) {
    // この機能は削除されています。ユーザーに通知のみ行います。
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('YouTubeダウンロード機能は削除されました。'),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// ローカルファイル選択と読込（複数ファイル対応）
  void _importLocalAudioFiles(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await RewardUnlockService.ensureUnlocked(
      context,
      l10n.importFiles,
    );
    if (!ok) return;

    final importer = ref.read(localImportViewModelProvider.notifier);
    final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
    final settings = ref.read(settingsViewModelProvider);
    const supportedAudioExtensions = ['mp3', 'm4a'];
    debugPrint('[LocalFile] ファイル選択開始');

    try {
      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'lrc'],
        allowMultiple: true,
        withReadStream: false,
      );

      if (pickResult == null || pickResult.files.isEmpty) {
        return;
      }

      final audioFiles = <PlatformFile>[];
      final lrcFiles = <PlatformFile>[];
      for (final file in pickResult.files) {
        final extension = file.extension?.toLowerCase();
        if (extension == 'lrc') {
          lrcFiles.add(file);
        } else if (supportedAudioExtensions.contains(extension)) {
          audioFiles.add(file);
        }
      }

      if (audioFiles.isEmpty && lrcFiles.isEmpty) {
        _pushAppMessage(context, '対応するファイルが選択されていません');
        return;
      }

      _pushAppMessage(context, '${audioFiles.length + lrcFiles.length}件のファイルを読込中...');

      final audioPaths = <String>[];
      final audioBaseByPath = <String, String>{};
      for (final audioFile in audioFiles) {
        final materialized = await _materializePickedFile(
          audioFile,
          subDir: 'imported_audio',
          preferredName: audioFile.name,
        );
        if (materialized != null) {
          audioPaths.add(materialized);
          audioBaseByPath[materialized] = p.basenameWithoutExtension(audioFile.name);
          final normalized = materialized.replaceAll('\\', '/').toLowerCase();
          if (normalized.contains('/app_flutter/imported_audio/')) {
            debugPrint('[LocalFile] 注意: 元ファイルパスを取得できず管理領域へコピーしました: ${audioFile.name}');
          }
        }
      }

      final lrcByBase = <String, String?>{};
      for (final lrcFile in lrcFiles) {
        final baseName = p.basenameWithoutExtension(lrcFile.name);
        final lrcPath = await _materializePickedFile(
          lrcFile,
          subDir: 'imported_lyrics',
          preferredName: '${baseName}.lrc',
        );
        lrcByBase[baseName] = lrcPath;
      }

      final lyricsByPath = <String, String?>{};
      for (final audioPath in audioPaths) {
        final base = audioBaseByPath[audioPath] ?? p.basenameWithoutExtension(audioPath);
        lyricsByPath[audioPath] = lrcByBase[base];
      }

      final importResult = await importer.importFilesBatched(
        audioPaths,
        lyricsByPath: lyricsByPath,
        batchSize: 30,
        duplicateDetection: settings.localFileSettings.duplicateDetection,
      );

      await libraryNotifier.refreshLibrary();
      if (!context.mounted) return;
      _pushAppMessage(context, 'インポート完了: ${importResult.imported}件 (スキップ ${importResult.skipped}件 / 失敗 ${importResult.failed}件)');
    } catch (e) {
      if (!context.mounted) return;
      _pushAppMessage(context, 'ファイル選択エラー: $e');
    }
  }

  /// フォルダ読み込み機能
  void _importFolderFiles(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await RewardUnlockService.ensureUnlocked(
      context,
      l10n.importFolder,
    );
    if (!ok) return;
    final importer = ref.read(localImportViewModelProvider.notifier);
    final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
    final settings = ref.read(settingsViewModelProvider);
    debugPrint('[Folder] フォルダ選択開始');

    try {
      // フォルダ選択のみで取り込みを行う。権限ダイアログはここでは表示しない。
      final folderPath = await FilePicker.platform.getDirectoryPath();
      if (!context.mounted) return;

      if (folderPath == null || folderPath.isEmpty) {
        _pushAppMessage(context, 'フォルダが選択されませんでした');
        return;
      }

      _pushAppMessage(context, 'フォルダをスキャン中...');
      final importResult = await importer.importFolderBatched(
        folderPath,
        batchSize: 30,
        duplicateDetection: settings.localFileSettings.duplicateDetection,
      );

      await libraryNotifier.refreshLibrary();
      debugPrint('[Folder] ライブラリ更新完了');

      if (!context.mounted) return;
      _pushAppMessage(context, 'インポート完了: ${importResult.imported}件 (スキップ ${importResult.skipped}件 / 失敗 ${importResult.failed}件)');
    } catch (e) {
      debugPrint('[Folder] エラー: $e');
      if (!context.mounted) return;
      _pushAppMessage(context, 'フォルダ読み込みエラー: $e');
    }
  }

  /// Android実機でのストレージ権限とディレクトリ確認
  void _checkStoragePermissions() {
    debugPrint('[Storage] 権限とディレクトリの確認を開始');

    try {
      // 外部ストレージの状態確認
      if (Platform.isAndroid) {
        debugPrint('[Storage] Android端末での実行を確認');

        // アプリのドキュメントディレクトリ確認
        final appDir = Directory('/data/data/com.likelife.musiclike');
        if (appDir.existsSync()) {
          debugPrint('[Storage] アプリディレクトリ存在確認: OK');
        } else {
          debugPrint('[Storage] 警告: アプリディレクトリが見つかりません');
        }

        // 外部ストレージ（Music/Downloads）の確認
        final musicDir = Directory('/storage/emulated/0/Music');
        final downloadsDir = Directory('/storage/emulated/0/Download');

        debugPrint('[Storage] Music ディレクトリ存在: ${musicDir.existsSync()}');
        debugPrint('[Storage] Downloads ディレクトリ存在: ${downloadsDir.existsSync()}');

        // 推奨保存先の確認
        if (musicDir.existsSync()) {
          debugPrint('[Storage] 推奨保存先: ${musicDir.path}');
        } else if (downloadsDir.existsSync()) {
          debugPrint('[Storage] 代替保存先: ${downloadsDir.path}');
        } else {
          debugPrint('[Storage] 警告: 外部ストレージディレクトリが見つかりません');
        }
      }
    } catch (e) {
      debugPrint('[Storage] 権限確認エラー: $e');
    }
  }
}
