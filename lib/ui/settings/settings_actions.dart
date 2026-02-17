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
        withReadStream: true,
      );

      if (pickResult != null && pickResult.files.isNotEmpty) {
        debugPrint('[LocalFile] 選択されたファイル数: ${pickResult.files.length}');

        final audioFiles = <PlatformFile>[];
        final lrcFiles = <PlatformFile>[];

        // ファイルを音声ファイルと歌詞ファイルに分類
        for (final file in pickResult.files) {
          final extension = file.extension?.toLowerCase();
          debugPrint('[LocalFile] ファイル: ${file.name} (拡張子: $extension)');

          if (extension == 'lrc') {
            lrcFiles.add(file);
          } else if (supportedAudioExtensions.contains(extension)) {
            audioFiles.add(file);
          }
        }

        debugPrint('[LocalFile] 音声ファイル: ${audioFiles.length}件');
        debugPrint('[LocalFile] 歌詞ファイル: ${lrcFiles.length}件');

        if (audioFiles.isEmpty && lrcFiles.isEmpty) {
          _pushAppMessage(context, '対応するファイルが選択されていません');
          return;
        }

        _pushAppMessage(context, '${audioFiles.length + lrcFiles.length}件のファイルを読込中...');

        final audioPaths = <String>[];
        final audioBaseByPath = <String, String>{};
        for (final audioFile in audioFiles) {
          if (audioFile.path != null) {
            audioPaths.add(audioFile.path!);
            audioBaseByPath[audioFile.path!] = p.basenameWithoutExtension(audioFile.name);
          } else {
            debugPrint('[LocalFile] 音声パス取得不可: ${audioFile.name}');
          }
        }

        final lrcByBase = <String, String?>{};
        for (final lrcFile in lrcFiles) {
          final baseName = p.basenameWithoutExtension(lrcFile.name);
          String? lrcPath = lrcFile.path;
          final needsCopy = lrcPath == null || lrcPath.startsWith('content://');
          if (needsCopy) {
            final stream = lrcFile.readStream;
            if (stream != null) {
              try {
                final tempDir = await getTemporaryDirectory();
                final lrcDir = Directory(p.join(tempDir.path, 'lrc_import'));
                if (!lrcDir.existsSync()) {
                  await lrcDir.create(recursive: true);
                }
                final destPath = p.join(
                  lrcDir.path,
                  '${baseName}_${DateTime.now().millisecondsSinceEpoch}.lrc',
                );
                final outFile = File(destPath);
                final sink = outFile.openWrite();
                await stream.pipe(sink);
                lrcPath = destPath;
                debugPrint('[LocalFile] LRCを一時ファイルへコピー: $destPath');
              } catch (e) {
                debugPrint('[LocalFile] LRCコピー失敗: $e');
              }
            } else {
              debugPrint('[LocalFile] LRC読込不可: ${lrcFile.name}');
            }
          }
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

        // ライブラリを更新
        await libraryNotifier.refreshLibrary();
        debugPrint('[LocalFile] ライブラリ更新完了');

        if (!context.mounted) return;
        _pushAppMessage(context, 'インポート完了: ${importResult.imported}件 (スキップ ${importResult.skipped}件 / 失敗 ${importResult.failed}件)');
      }
    } catch (e) {
      debugPrint('[LocalFile] エラー: $e');
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
    const supportedAudioExtensions = ['mp3', 'm4a'];
    debugPrint('[Folder] フォルダ選択開始');

    try {
      // 必要な権限を一元的に確認・要求する
      final permsOk = await ensureStorageAndAudioPermissions(context);
      if (!permsOk) {
        if (!context.mounted) return;
        _pushAppMessage(context, 'ストレージ権限が必要です');
        return;
      }
      final folderPath = await FilePicker.platform.getDirectoryPath();
      if (!context.mounted) return;
      if (folderPath == null) return;

      debugPrint('[Folder] 選択されたフォルダ: $folderPath');

      // Directory に直接アクセスできる場合は従来処理
      final directory = Directory(folderPath);
      if (directory.existsSync()) {
        _pushAppMessage(context, 'フォルダをスキャン中...');
        final importResult = await importer.importFolderBatched(
          folderPath,
          batchSize: 30,
          duplicateDetection: settings.localFileSettings.duplicateDetection,
        );

        // ライブラリを更新
        await libraryNotifier.refreshLibrary();
        debugPrint('[Folder] ライブラリ更新完了');

        if (!context.mounted) return;
        _pushAppMessage(context, 'インポート完了: ${importResult.imported}件 (スキップ ${importResult.skipped}件 / 失敗 ${importResult.failed}件)');
        return;
      }

      // Android 14 などで content:// が返り Directory へアクセスできない場合は
      // ファイル選択ダイアログへフォールバックして個別ファイルをインポートする
      debugPrint('[Folder] Directory にアクセス不可、ファイル選択へフォールバック');
      _pushAppMessage(context, 'フォルダへアクセスできません。ファイルを個別選択します...');

      final pickResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'lrc'],
        allowMultiple: true,
        withReadStream: true,
      );
      if (!context.mounted) return;

      if (pickResult == null || pickResult.files.isEmpty) {
        _pushAppMessage(context, 'ファイルが選択されませんでした');
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
        if (audioFile.path != null) {
          audioPaths.add(audioFile.path!);
          audioBaseByPath[audioFile.path!] = p.basenameWithoutExtension(audioFile.name);
        } else {
          debugPrint('[Folder] 音声パス取得不可: ${audioFile.name}');
        }
      }

      final lrcByBase = <String, String?>{};
      for (final lrcFile in lrcFiles) {
        final baseName = p.basenameWithoutExtension(lrcFile.name);
        String? lrcPath = lrcFile.path;
        final needsCopy = lrcPath == null || lrcPath.startsWith('content://');
        if (needsCopy) {
          final stream = lrcFile.readStream;
          if (stream != null) {
            try {
              final tempDir = await getTemporaryDirectory();
              final lrcDir = Directory(p.join(tempDir.path, 'lrc_import'));
              if (!lrcDir.existsSync()) await lrcDir.create(recursive: true);
              final destPath = p.join(
                lrcDir.path,
                '${baseName}_${DateTime.now().millisecondsSinceEpoch}.lrc',
              );
              final outFile = File(destPath);
              final sink = outFile.openWrite();
              await stream.pipe(sink);
              lrcPath = destPath;
              debugPrint('[Folder] LRC を一時ファイルへコピー: $destPath');
            } catch (e) {
              debugPrint('[Folder] LRC コピー失敗: $e');
            }
          } else {
            debugPrint('[Folder] LRC 読込不可: ${lrcFile.name}');
          }
        }
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
