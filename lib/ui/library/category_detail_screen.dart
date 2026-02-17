part of '../app_ui.dart';

// ==============================================================================
// カテゴリ詳細画面（アーティスト/アルバム/プレイリスト → 曲一覧）
// ==============================================================================

enum CategoryDetailType { artist, album, playlist }

// ===== カテゴリ詳細画面について =====
// - ここはアーティスト／アルバム／プレイリストの詳細で曲一覧を表示する箇所です。
// - サムネイルを小さくする変更は本ファイル内でこの画面にのみ適用されています。
//   確認ポイント：オーバービュー（アーティスト一覧等）は影響を受けていないか。
class _CategoryDetailScreen extends ConsumerWidget {
  final CategoryDetailType type;
  final String title;
  final List<Song> songs;
  final String? subtitle;
  final String? artworkUrl;
  final String? heroTag;

  const _CategoryDetailScreen({
    required this.type,
    required this.title,
    required this.songs,
    this.subtitle,
    this.artworkUrl,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: const MiniPlayer(),
      body: CustomScrollView(
        slivers: [
          // ヘッダー部分（アートワークとタイトル）
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                _tapFeedback(context);
                Navigator.pop(context);
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // アートワーク
                    (heroTag != null
                        ? Hero(
                            tag: heroTag!,
                            child: _buildArtworkContainer(context),
                          )
                        : _buildArtworkContainer(context)),
                    const SizedBox(height: 12),
                    // アートワーク直下にタイトル、その下に曲数を改行で表示
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.songCount(songs.length),
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // アクションボタン
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 全曲再生ボタン
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _tapFeedback(context);
                        if (songs.isNotEmpty) {
                          ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: 0);
                        }
                      },
                      icon: Icon(Icons.play_arrow, color: Theme.of(context).iconTheme.color),
                      label: Text(
                        l10n.commonPlay,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // シャッフル再生ボタン
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _tapFeedback(context);
                        if (songs.isNotEmpty) {
                          ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: 0);
                          ref.read(playerViewModelProvider.notifier).toggleShuffle();
                        }
                      },
                      icon: Icon(Icons.shuffle, color: Theme.of(context).iconTheme.color),
                      label: Text(
                        l10n.commonShuffle,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 77, 77, 77),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 曲一覧
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return ListTile(
                  leading: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: song.artworkUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: song.artworkUrl!.startsWith('http')
                                ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                                : Image.file(File(song.artworkUrl!), fit: BoxFit.cover),
                          )
                        : Icon(Icons.music_note, color: Theme.of(context).iconTheme.color, size: 16),
                  ),
                  title: Text(
                    song.title,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    type == CategoryDetailType.album ? song.artist : song.album,
                    style: const TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    _formatDuration(song.duration),
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  onTap: () {
                    _tapFeedback(context);
                    ref.read(playerViewModelProvider.notifier).setQueue(songs, startIndex: index, autoPlay: true);
                  },
                  onLongPress: () {
                    _tapFeedback(context);
                    _showSongContextMenu(context, ref, song, songs);
                  },
                );
              },
              childCount: songs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkContainer(BuildContext context) {
    return Container(
      // アートワークサイズを半分に変更（以前は180）
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: type == CategoryDetailType.artist ? BorderRadius.circular(45) : BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.3 * 255).round()),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: artworkUrl != null
          ? ClipRRect(
              borderRadius: type == CategoryDetailType.artist ? BorderRadius.circular(90) : BorderRadius.circular(8),
              child: artworkUrl!.startsWith('http')
                  ? Image.network(artworkUrl!, fit: BoxFit.cover)
                  : Image.file(File(artworkUrl!), fit: BoxFit.cover),
            )
          : Icon(
              type == CategoryDetailType.artist
                  ? Icons.person
                  : type == CategoryDetailType.album
                      ? Icons.album
                      : Icons.queue_music,
              // アイコンサイズも半分に調整（以前は80）
              size: 40,
              color: Theme.of(context).iconTheme.color,
            ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString()}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${minutes.toString()}:${twoDigits(seconds)}';
  }

  void _showSongContextMenu(BuildContext context, WidgetRef ref, Song song, List<Song> allSongs) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.playlist_play, color: Theme.of(context).iconTheme.color),
              title: Text(l10n.playNext, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                ref.read(playerViewModelProvider.notifier).addToQueue(song);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.addedPlayNext(song.title),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: Theme.of(context).iconTheme.color),
              title: Text(l10n.addToPlaylist, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showAddToPlaylistDialog(context, ref, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.lyrics, color: Theme.of(context).iconTheme.color),
              title: Text(l10n.editLyrics, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showLyricsEditOptions(context, ref, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
              title: Text(l10n.editSongInfo, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                _showEditMetadataDialog(context, ref, song);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                _tapFeedback(context);
                Navigator.pop(context);
                // 削除確認ダイアログを表示
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: Text(
                      '削除確認',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    content: Text(
                      '「${song.title}」を削除してもよろしいですか？',
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.commonCancel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ref.read(libraryViewModelProvider.notifier).deleteSong(song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('「${song.title}」を削除しました')),
                          );
                        },
                        child: const Text('削除', style: TextStyle(color: Colors.red)),
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

  void _showLyricsEditOptions(BuildContext context, WidgetRef ref, Song song) {
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
              _showEditLyricsDialog(context, ref, song);
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
                  SnackBar(content: Text(l10n.lrcFileNotFound)),
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

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.read(playlistViewModelProvider).playlists;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(l10n.addToPlaylistTitle, style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              // 新規作成オプション
              ListTile(
                leading: Icon(Icons.add_circle, color: Theme.of(context).scaffoldBackgroundColor),
                title: Text(
                  l10n.createNewPlaylist,
                  style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showCreatePlaylistDialog(context, ref, song);
                },
              ),
              if (playlists.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.existingPlaylists,
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ),
              ...playlists.map((playlist) {
                return ListTile(
                  title: Text(playlist.name, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlist.id, song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.addedToPlaylist,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref, Song song) {
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
            child: Text(l10n.commonCancel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                // プレイリスト作成と曲追加
                ref.read(playlistViewModelProvider.notifier).createPlaylist(nameController.text).then((playlistId) {
                  if (playlistId != null) {
                    ref.read(playlistViewModelProvider.notifier).addSongToPlaylist(playlistId, song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.playlistCreated,
                        ),
                      ),
                    );
                  }
                });
              }
            },
            child: Text(l10n.commonSave, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditMetadataDialog(BuildContext context, WidgetRef ref, Song song) async {
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
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedArtworkPath != null
                          ? GestureDetector(
                              onTap: () async {
                                _tapFeedback(dialogContext);
                                if (!dialogContext.mounted) return;
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
                                if (!dialogContext.mounted) return;
                                if (cropped != null) setState(() { selectedArtworkPath = cropped; });
                              },
                              onLongPress: () async {
                                _tapFeedback(dialogContext);
                                if (!dialogContext.mounted) return;
                                final path = selectedArtworkPath;
                                if (path == null || path.isEmpty) return;
                                if (path.startsWith('http')) return;
                                final file = File(path);
                                if (!file.existsSync()) {
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(AppLocalizations.of(dialogContext)!.selectImageFirst)));
                                  return;
                                }
                                final cropped = await _showImageCropperDialog(dialogContext, selectedArtworkPath!);
                                if (!dialogContext.mounted) return;
                                if (cropped != null) setState(() { selectedArtworkPath = cropped; });
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: selectedArtworkPath!.startsWith('http')
                                    ? Image.network(selectedArtworkPath!, fit: BoxFit.cover)
                                    : Image.file(File(selectedArtworkPath!), fit: BoxFit.cover),
                              ),
                            )
                          : const Icon(Icons.music_note, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          _tapFeedback(dialogContext);
                          final result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                          );
                          if (!dialogContext.mounted) return;
                          final path = result?.files.single.path;
                          if (path != null) {
                            setState(() {
                              selectedArtworkPath = path;
                            });
                          }
                        },
                        icon: Icon(Icons.image, color: Theme.of(context).colorScheme.primary),
                        label: Text(l10n.changeImage, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                        ),
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
                    labelStyle: const TextStyle(color: Colors.grey),
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
                    labelStyle: const TextStyle(color: Colors.grey),
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
                    labelStyle: const TextStyle(color: Colors.grey),
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
              child: Text(l10n.commonCancel, style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                String? finalArtworkPath = selectedArtworkPath;
                if (selectedArtworkPath != null && song.localPath != null) {
                  try {
                    final dir = p.dirname(song.localPath!);
                    final base = p.basenameWithoutExtension(song.localPath!);
                    final ext = p.extension(selectedArtworkPath!).isEmpty ? '.jpg' : p.extension(selectedArtworkPath!);
                    final destPath = p.join(dir, '${base}_cover$ext');
                    if (selectedArtworkPath! != destPath) {
                      await File(selectedArtworkPath!).copy(destPath);
                    }
                    finalArtworkPath = destPath;
                  } catch (e) {
                    _warningFeedback();
                    if (context.mounted) {
                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        SnackBar(content: Text(l10n.artworkSaveFailed(e.toString()))),
                      );
                    }
                  }
                }

                await ref.read(libraryViewModelProvider.notifier).updateSongMetadata(
                  song.id,
                  {
                    'title': titleController.text.trim(),
                    'artist': artistController.text.trim(),
                    'album': albumController.text.trim(),
                    'artworkUrl': finalArtworkPath,
                    'localPath': song.localPath,
                  },
                );
                _successFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                    SnackBar(content: Text(l10n.metadataSaved)),
                  );
                }
              },
              child: Text(l10n.commonSave, style: TextStyle(color: Theme.of(dialogContext).colorScheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditLyricsDialog(BuildContext context, WidgetRef ref, Song song) async {
    final l10n = AppLocalizations.of(context)!;
    final ok = await RewardUnlockService.ensureUnlocked(
      context,
      l10n.editLyrics,
    );
    if (!ok) return;
    final defaultLyricsPath = song.lyricsPath ??
        (song.localPath != null
            ? p.join(
                p.dirname(song.localPath!),
                '${p.basenameWithoutExtension(song.localPath!)}.lrc',
              )
            : null);

    String initialText = '';
    if (defaultLyricsPath != null && File(defaultLyricsPath).existsSync()) {
      try {
        initialText = await File(defaultLyricsPath).readAsString();
      } catch (_) {}
    }

    final controller = TextEditingController(text: initialText);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        title: Text(l10n.editLyricsLrc, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 12,
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, height: 1.4),
            decoration: InputDecoration(
              hintText: l10n.lrcHint,
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
              // Ensure storage permission before attempting to write
              final ok = await ensureStorageAndAudioPermissions(dialogContext);
              if (!ok) {
                _warningFeedback();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_t(context, ja: 'ストレージ権限が必要です', en: 'Storage permission required', zh: '需要存储权限'))),
                );
                return;
              }
              try {
                await File(defaultLyricsPath).writeAsString(controller.text);
                await ref.read(libraryViewModelProvider.notifier).updateSongMetadata(
                  song.id,
                  {
                    'localPath': song.localPath,
                    'lyricsPath': defaultLyricsPath,
                  },
                );
                await ref.read(playerViewModelProvider.notifier).loadLyricsFromPath(defaultLyricsPath);
                _successFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.lyricsSaved)),
                  );
                }
              } catch (e) {
                _warningFeedback();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.lyricsSaveFailed(e.toString())),
                    ),
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
