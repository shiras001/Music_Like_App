part of '../app_ui.dart';

extension _LibraryTabDialogs on _LibraryTabState {
  void _showSongContextMenu(BuildContext context, Song song, List<Song> allSongs, int index) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            ListTile(
              leading: Icon(Icons.play_arrow, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(l10n.commonPlay, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).setQueue(allSongs, startIndex: index);
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_play, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(l10n.playNext, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.addedToQueue),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(l10n.addToPlaylist, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.lyrics, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(l10n.editLyrics, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showLyricsEditOptions(context, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(
                l10n.editSongInfo,
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showEditMetadataDialog(context, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: Theme.of(context).textTheme.bodyMedium?.color),
              title: Text(l10n.download, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showExportDialog(context, song);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                    title: Text(
                      '削除確認',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    content: Text(
                      '「${song.title}」を削除してもよろしいですか？',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          ref.read(libraryViewModelProvider.notifier).deleteSong(song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('「${song.title}」を削除しました')),
                          );
                        },
                        child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  void _showArtistContextMenu(BuildContext context, String artistName, List<Song> artistSongs) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                _tapFeedback(sheetContext);
                Navigator.pop(sheetContext);
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                    title: Text(
                      '削除確認',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    content: Text(
                      'アーティスト「$artistName」の曲を削除してもよろしいですか？',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          for (final song in artistSongs) {
                            await ref.read(libraryViewModelProvider.notifier).deleteSong(song.id);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('アーティスト「$artistName」の曲を削除しました')),
                            );
                          }
                        },
                        child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAlbumContextMenu(BuildContext context, String albumName, List<Song> albumSongs) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                _tapFeedback(sheetContext);
                Navigator.pop(sheetContext);
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                    title: Text(
                      '削除確認',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    content: Text(
                      'アルバム「$albumName」の曲を削除してもよろしいですか？',
                      style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext);
                          for (final song in albumSongs) {
                            await ref.read(libraryViewModelProvider.notifier).deleteSong(song.id);
                          }
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('アルバム「$albumName」の曲を削除しました')),
                            );
                          }
                        },
                        child: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, Song song) {
    final hasAudio = song.localPath != null && song.localPath!.isNotEmpty && File(song.localPath!).existsSync();
    final hasLrc   = song.lyricsPath != null && song.lyricsPath!.isNotEmpty && File(song.lyricsPath!).existsSync();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).colorScheme.surface,
        title: Text(AppLocalizations.of(ctx)!.download, style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color)),
        content: Text(
          AppLocalizations.of(ctx)!.exportToDownloadsDesc,
          style: TextStyle(color: Theme.of(ctx).textTheme.bodyMedium?.color),
        ),
        actions: [
          if (hasLrc)
            Builder(builder: (btnCtx) {
              final l10n = AppLocalizations.of(btnCtx)!;
              return TextButton(
                onPressed: () async {
                  final lrcBtn = l10n.exportLrcButton;
                  final successMsg = (String f) => l10n.exportLrcSuccess(f);
                  final failMsg = l10n.exportLrcFailed;
                  Navigator.pop(ctx);
                  final ok = await RewardUnlockService.ensureUnlocked(context, lrcBtn);
                  if (!ok) return;
                  final downloadedFileName = buildExportLrcFileName(song);
                  final dest = await exportLrcToDownloads(song);
                  _pushAppMessage(context, dest != null ? successMsg(downloadedFileName) : failMsg);
                },
                child: Text(l10n.exportLrcButton),
              );
            }),
          if (hasAudio)
            Builder(builder: (btnCtx) {
              final l10n = AppLocalizations.of(btnCtx)!;
              return TextButton(
                onPressed: () async {
                  final audioBtn = l10n.exportAudioButton;
                  final successMsg = (String f) => l10n.exportAudioSuccess(f);
                  final failMsg = l10n.exportAudioFailed;
                  Navigator.pop(ctx);
                  final ok = await RewardUnlockService.ensureUnlocked(context, audioBtn);
                  if (!ok) return;
                  final downloadedFileName = buildExportAudioFileName(song);
                  final dest = await exportAudioToDownloads(song);
                  _pushAppMessage(context, dest != null ? successMsg(downloadedFileName) : failMsg);
                },
                child: Text(l10n.exportAudioButton),
              );
            }),
          if (!hasAudio && !hasLrc)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx)!.exportNoFile),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.commonCancel),
          ),
        ],
      ),
    );
  }

  void _showLyricsEditOptions(BuildContext context, Song song) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.editLyrics, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await RewardUnlockService.ensureUnlocked(
                context,
                l10n.editLyrics,
              );
              if (!ok) return;
              _showEditLyricsDialog(context, song);
            },
            child: Text(l10n.editManually),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              final ok = await RewardUnlockService.ensureUnlocked(
                context,
                l10n.adjustTiming,
              );
              if (!ok) return;
              if (song.lyricsPath == null || song.lyricsPath!.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.lyricsFileNotFound)),
                );
                return;
              }
              ref.read(playerViewModelProvider.notifier).setQueue([song], startIndex: 0, autoPlay: true);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (_) => const FullPlayerScreen(adjustMode: true),
              );
            },
            child: Text(l10n.adjustTiming),
          ),
        ],
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, Song song) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.read(playlistViewModelProvider).playlists;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.addToPlaylistTitle,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 新規作成オプション
              ListTile(
                leading: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  l10n.createNewPlaylist,
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialogNoRef(context, song);
                },
              ),
              if (playlists.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(l10n.existingPlaylists),
                ),
              ...playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  subtitle: Text(
                    l10n.songCount(playlist.songIds.length),
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlist.id, song.id).then((_) {
                      _successFeedback();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.addedToPlaylist),
                        ),
                      );
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialogNoRef(BuildContext context, Song song) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.createPlaylist,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            hintText: l10n.playlistNameHint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // プレイリスト作成と曲追加
                ref.read(playlistViewModelProvider.notifier).createPlaylist(nameController.text).then((playlistId) {
                  if (playlistId == null) {
                    _warningFeedback();
                    return;
                  }
                  ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlistId, song.id);
                  _successFeedback();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.playlistCreated)),
                  );
                });
              } else {
                _warningFeedback();
              }
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistOnlyDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l10n.createPlaylist,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        content: TextField(
          controller: nameController,
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          decoration: InputDecoration(
            hintText: l10n.playlistNameHint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          cursorColor: Theme.of(context).colorScheme.primary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                _tapFeedback(context);
                ref.read(playlistViewModelProvider.notifier).createPlaylist(nameController.text);
              } else {
                _warningFeedback();
              }
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMetadataDialog(BuildContext context, Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await RewardUnlockService.ensureUnlocked(
      context,
      l10n.editSongInfo,
    );
    if (!ok) return;
    final titleController = TextEditingController(text: song.title);
    final artistController = TextEditingController(text: song.artist);
    final albumController = TextEditingController(text: song.album);
    String? selectedArtworkPath = song.artworkUrl;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          backgroundColor: Theme.of(dialogContext).colorScheme.surface,
          title: Text(l10n.editSongInfo, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _tapFeedback(dialogContext);
                        final path = selectedArtworkPath;
                        if (path == null || path.isEmpty) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(dialogContext)!.selectImageFirst)),
                          );
                          return;
                        }
                        if (path.startsWith('http')) return;
                        final file = File(path);
                        if (!file.existsSync()) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(dialogContext)!.selectImageFirst)),
                          );
                          return;
                        }
                        final cropped = await _showImageCropperDialog(dialogContext, path);
                        if (cropped != null) {
                          setState(() {
                            selectedArtworkPath = cropped;
                          });
                        }
                      },
                      onLongPress: () async {
                        _tapFeedback(dialogContext);
                        final path = selectedArtworkPath;
                        if (path == null || path.isEmpty) return;
                        // Ensure local file path is available before opening cropper
                        if (path.startsWith('http')) return;
                        final file = File(path);
                        if (!file.existsSync()) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(AppLocalizations.of(dialogContext)!.selectImageFirst)));
                          return;
                        }
                        final cropped = await _showImageCropperDialog(dialogContext, path);
                        if (cropped != null) {
                          setState(() {
                            selectedArtworkPath = cropped;
                          });
                        }
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Theme.of(dialogContext).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedArtworkPath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: selectedArtworkPath!.startsWith('http')
                                    ? Image.network(selectedArtworkPath!, fit: BoxFit.cover)
                                    : Image.file(File(selectedArtworkPath!), fit: BoxFit.cover),
                              )
                            : const Icon(Icons.music_note, size: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.artworkLabel, style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color)),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () async {
                              final result = await FilePicker.platform.pickFiles(type: FileType.image);
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  selectedArtworkPath = result.files.first.path;
                                });
                              }
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _breakByHalfWidthSpace(l10n.selectImage),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: false,
                                overflow: TextOverflow.visible,
                                style: _imageActionLabelStyle(dialogContext),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    labelText: l10n.titleLabel,
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(dialogContext).colorScheme.primary),
                    ),
                  ),
                  cursorColor: Theme.of(dialogContext).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: artistController,
                  style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    labelText: l10n.artistLabel,
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(dialogContext).colorScheme.primary),
                    ),
                  ),
                  cursorColor: Theme.of(dialogContext).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: albumController,
                  style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    labelText: l10n.albumLabel,
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[600]!),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(dialogContext).colorScheme.primary),
                    ),
                  ),
                  cursorColor: Theme.of(dialogContext).colorScheme.primary,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final resolvedAudioPath = await resolveEditableAudioPath(song.localPath);
                final writableAudioPath = (resolvedAudioPath == null || resolvedAudioPath.isEmpty)
                    ? song.localPath
                    : resolvedAudioPath;
                if (writableAudioPath == null || writableAudioPath.isEmpty) {
                  _warningFeedback();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_t(context, ja: '楽曲ファイルの保存先が見つかりません。', en: 'Unable to locate target audio file.', zh: '找不到目标音频文件。'))),
                    );
                  }
                  return;
                }
                final needsExternalPermission = !_isManagedInternalPath(writableAudioPath);
                if (needsExternalPermission) {
                  final canWrite = await ensureStorageAndAudioPermissions(
                    dialogContext,
                    forWrite: true,
                    targetPath: writableAudioPath,
                  );
                  if (!canWrite) {
                    _warningFeedback();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_t(context, ja: 'ファイルへの書き込み権限がありません。設定から「すべてのファイルへのアクセス」を許可してください。', en: 'No write permission for file. Please allow all-files access in settings.', zh: '没有文件写入权限。请在设置中允许所有文件访问。'))),
                      );
                    }
                    return;
                  }
                }
                String? finalArtworkPath = selectedArtworkPath;
                if (selectedArtworkPath != null && song.localPath != null) {
                  final rootDir = await getApplicationDocumentsDirectory();
                  final fileName = p.basename(selectedArtworkPath!);
                  final destPath = p.join(rootDir.path, 'artwork', fileName);
                  try {
                    final destDir = Directory(p.dirname(destPath));
                    if (!destDir.existsSync()) {
                      destDir.createSync(recursive: true);
                    }
                    await File(selectedArtworkPath!).copy(destPath);
                    finalArtworkPath = destPath;
                    debugPrint('[Save] Artwork copied to: $destPath');
                  } catch (e) {
                    debugPrint('[Save] Artwork copy failed: $e');
                  }
                }

                try {
                  final metadata = {
                    'title': titleController.text.trim(),
                    'artist': artistController.text.trim(),
                    'album': albumController.text.trim(),
                    'artworkUrl': finalArtworkPath,
                    'localPath': writableAudioPath,
                  };
                  debugPrint('[Save] Updating metadata: $metadata');
                  await ref.read(libraryViewModelProvider.notifier).updateSongMetadata(
                    song.id,
                    metadata,
                  );
                  debugPrint('[Save] Metadata saved successfully');
                  _successFeedback();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.songUpdated)),
                    );
                  }
                } catch (e, stackTrace) {
                  debugPrint('[Save] Metadata save ERROR: $e');
                  debugPrint('[Save] Stack: $stackTrace');
                  _warningFeedback();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_t(context, ja: 'メタデータの保存に失敗しました: $e', en: 'Failed to save metadata: $e', zh: '保存元数据失败: $e'))),
                    );
                  }
                }
              },
              child: Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditLyricsDialog(BuildContext context, Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await RewardUnlockService.ensureUnlocked(
      context,
      l10n.editLyrics,
    );
    if (!ok) return;
    final writableAudioPath = await resolveEditableAudioPath(song.localPath);
    final defaultLyricsPath =
        (song.lyricsPath != null && !_isManagedInternalPath(song.lyricsPath))
            ? song.lyricsPath
            : (writableAudioPath != null
                ? p.join(
                    p.dirname(writableAudioPath),
                    '${p.basenameWithoutExtension(writableAudioPath)}.lrc',
                  )
                : null);

    String initialText = '';
    if (defaultLyricsPath != null && File(defaultLyricsPath).existsSync()) {
      try {
        initialText = await File(defaultLyricsPath).readAsString();
      } catch (_) {}
    }
    if (initialText.isEmpty && song.lyricsPath != null && song.lyricsPath!.isNotEmpty) {
      try {
        final originalLyricsFile = File(song.lyricsPath!);
        if (await originalLyricsFile.exists()) {
          initialText = await originalLyricsFile.readAsString();
        }
      } catch (_) {}
    }

    final controller = TextEditingController(text: initialText);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(l10n.editLyricsLrc, style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            style: TextStyle(color: Theme.of(dialogContext).textTheme.bodyMedium?.color, height: 1.4),
            decoration: InputDecoration(
              hintText: '[00:12.34]歌詞テキスト',
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[700]!)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(dialogContext).colorScheme.primary)),
            ),
            cursorColor: Theme.of(dialogContext).colorScheme.primary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (defaultLyricsPath == null) {
                _warningFeedback();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.lyricsNoDestination)),
                );
                return;
              }
              if (_isManagedInternalPath(defaultLyricsPath)) {
                _warningFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_t(context, ja: '端末の実ファイルを特定できないため歌詞を直接上書きできません。フォルダ読み込みで再インポートしてください。', en: 'Cannot locate original local file for direct lyrics overwrite. Please re-import from folder scan.', zh: '无法定位原始本地文件，无法直接覆盖歌词。请从文件夹扫描重新导入。'))),
                  );
                }
                return;
              }
              try {
                debugPrint('[Save] Writing lyrics to: $defaultLyricsPath');
                final file = File(defaultLyricsPath);
                final parentDir = file.parent;
                if (!await parentDir.exists()) {
                  debugPrint('[Save] Creating parent directory: ${parentDir.path}');
                  await parentDir.create(recursive: true);
                }
                await file.writeAsString(controller.text);
                debugPrint('[Save] Lyrics file written successfully');
                await ref.read(libraryViewModelProvider.notifier).updateSongMetadata(
                  song.id,
                  {
                    'localPath': song.localPath,
                    'lyricsPath': defaultLyricsPath,
                  },
                );
                debugPrint('[Save] Metadata updated');
                await ref.read(playerViewModelProvider.notifier).loadLyricsFromPath(defaultLyricsPath);
                _successFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.lyricsSaved)),
                  );
                }
              } catch (e, stackTrace) {
                debugPrint('[Save] ERROR: $e');
                debugPrint('[Save] Stack: $stackTrace');
                _warningFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.lyricsSaveFailed(e.toString()))),
                  );
                }
              }
            },
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}
