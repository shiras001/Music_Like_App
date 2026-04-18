part of '../app_ui.dart';

extension _LibraryTabViews on _LibraryTabState {
  Widget _buildSongsList(List<Song> songs) {
    final l10n = AppLocalizations.of(context)!;
    if (songs.isEmpty) {
      return Center(
        child: Text(l10n.noSongs),
      );
    }

    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
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
                : const Icon(Icons.music_note),
          ),
          title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            _tapFeedback(context);
            ref
                .read(playerViewModelProvider.notifier)
                .setQueue(songs, startIndex: index, autoPlay: true);
          },
          onLongPress: () {
            _tapFeedback(context);
            _showSongContextMenu(context, song, songs, index);
          },
        );
      },
    );
  }

  Widget _buildArtistsList(List<Song> songs) {
    final l10n = AppLocalizations.of(context)!;
    // アーティストでグループ化
    final Map<String, List<Song>> artistMap = {};
    for (final song in songs) {
      artistMap.putIfAbsent(song.artist, () => []).add(song);
    }

    final artists = artistMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (artists.isEmpty) {
      return Center(
        child: Text(l10n.noArtists),
      );
    }

    return ListView.builder(
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          dense: false,
          visualDensity: VisualDensity.compact,
          minLeadingWidth: 48,
          horizontalTitleGap: 12,
          leading: Hero(
            tag: 'artist_${artist.key}',
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.person, size: 28),
            ),
          ),
          title: Text(artist.key, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            l10n.songCount(artist.value.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _tapFeedback(context);
            Navigator.push(
              context,
              _buildSmoothRoute(
                _CategoryDetailScreen(
                  type: CategoryDetailType.artist,
                  title: artist.key,
                  subtitle: l10n.songCount(artist.value.length),
                  songs: artist.value,
                  heroTag: 'artist_${artist.key}',
                ),
              ),
            );
          },
          onLongPress: () {
            _tapFeedback(context);
            _showArtistContextMenu(context, artist.key, artist.value);
          },
        );
      },
    );
  }

  Widget _buildAlbumsList(List<Song> songs) {
    final l10n = AppLocalizations.of(context)!;
    // アルバムでグループ化（アーティストも考慮）
    final Map<String, List<Song>> albumMap = {};
    for (final song in songs) {
      final key = '${song.album}_${song.artist}';
      albumMap.putIfAbsent(key, () => []).add(song);
    }

    final albums = albumMap.entries.toList()
      ..sort((a, b) => a.value.first.album.compareTo(b.value.first.album));

    if (albums.isEmpty) {
      return Center(
        child: Text(l10n.noAlbums),
      );
    }

    return ListView.builder(
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        final firstSong = album.value.first;
        final heroTag = 'album_${album.key}';
        return ListTile(
          minLeadingWidth: 56,
          horizontalTitleGap: 12,
          leading: Hero(
            tag: heroTag,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: firstSong.artworkUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: firstSong.artworkUrl!.startsWith('http')
                          ? Image.network(firstSong.artworkUrl!, fit: BoxFit.cover)
                          : Image.file(File(firstSong.artworkUrl!), fit: BoxFit.cover),
                    )
                  : Icon(Icons.album, color: Theme.of(context).iconTheme.color),
            ),
          ),
          title: Text(firstSong.album, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            l10n.songCount(album.value.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _tapFeedback(context);
            Navigator.push(
              context,
              _buildSmoothRoute(
                _CategoryDetailScreen(
                  type: CategoryDetailType.album,
                  title: firstSong.album,
                  subtitle: firstSong.artist,
                  artworkUrl: firstSong.artworkUrl,
                  songs: album.value,
                  heroTag: heroTag,
                ),
              ),
            );
          },
          onLongPress: () {
            _tapFeedback(context);
            _showAlbumContextMenu(context, firstSong.album, album.value);
          },
        );
      },
    );
  }

  Widget _buildPlaylistsList() {
    final l10n = AppLocalizations.of(context)!;
    final playlists = ref.watch(playlistViewModelProvider).playlists;

    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.noPlaylists),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _tapFeedback(context);
                _showCreatePlaylistOnlyDialog(context);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createPlaylist),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: playlists.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: ElevatedButton.icon(
              onPressed: () {
                _tapFeedback(context);
                _showCreatePlaylistOnlyDialog(context);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createPlaylist),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          );
        }

        final playlist = playlists[index - 1];
        final heroTag = 'playlist_${playlist.id}';
        return ListTile(
          minLeadingWidth: 56,
          horizontalTitleGap: 12,
          leading: Hero(
            tag: heroTag,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.queue_music, color: Theme.of(context).iconTheme.color),
            ),
          ),
          title: Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            l10n.songCount(playlist.songIds.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            _tapFeedback(context);
            // プレイリストの曲を取得
            final allSongs = ref.read(libraryViewModelProvider).songs;
            final playlistSongs = playlist.songIds
                .map((id) => allSongs.firstWhere(
                      (song) => song.id == id,
                      orElse: () => allSongs.first,
                    ))
                .toList();

            Navigator.push(
              context,
              _buildSmoothRoute(
                _CategoryDetailScreen(
                  type: CategoryDetailType.playlist,
                  title: playlist.name,
                  songs: playlistSongs,
                  heroTag: heroTag,
                ),
              ),
            );
          },
          onLongPress: () {
            _tapFeedback(context);
            // プレイリストメニューを表示
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).colorScheme.surface,
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.play_arrow, color: Theme.of(context).iconTheme.color),
                      title: Text(l10n.commonPlay, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      onTap: () {
                        Navigator.pop(context);
                        final allSongs = ref.read(libraryViewModelProvider).songs;
                        final playlistSongs = playlist.songIds
                            .map((id) => allSongs.firstWhere(
                                  (song) => song.id == id,
                                  orElse: () => allSongs.first,
                                ))
                            .toList();
                        ref.read(playerViewModelProvider.notifier).setQueue(playlistSongs, startIndex: 0, autoPlay: true);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.shuffle, color: Theme.of(context).iconTheme.color),
                      title: Text(l10n.commonShuffle, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
                      onTap: () {
                        Navigator.pop(context);
                        final allSongs = ref.read(libraryViewModelProvider).songs;
                        final playlistSongs = playlist.songIds
                            .map((id) => allSongs.firstWhere(
                                  (song) => song.id == id,
                                  orElse: () => allSongs.first,
                                ))
                            .toList();
                        playlistSongs.shuffle();
                        ref.read(playerViewModelProvider.notifier).setQueue(playlistSongs, startIndex: 0, autoPlay: true);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(l10n.commonDelete, style: const TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            title: Text(
                              '削除確認',
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                            content: Text(
                              '「${playlist.name}」を削除してもよろしいですか？',
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
                                  ref.read(playlistViewModelProvider.notifier).deletePlaylist(playlist.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('「${playlist.name}」を削除しました')),
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
          },
        );
      },
    );
  }

  Widget _buildSearchResults(SearchState searchState) {
    final l10n = AppLocalizations.of(context)!;
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.query.isEmpty) {
      return Center(
        child: Text(
          l10n.searchPrompt,
          style: TextStyle(color: Colors.grey[400]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.searchTitle),
      ),
      body: ListView(
        children: [
        // 曲の検索結果
        if (searchState.songResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.sectionSongs,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.songResults.map((song) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: song.artworkUrl != null
                      ? (song.artworkUrl!.startsWith('http')
                          ? Image.network(song.artworkUrl!, fit: BoxFit.cover)
                          : Image.file(File(song.artworkUrl!), fit: BoxFit.cover))
                      : const Icon(Icons.music_note, size: 20),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () {
                  ref
                      .read(playerViewModelProvider.notifier)
                      .setQueue([song], startIndex: 0);
                },
                onLongPress: () {
                  _showSongContextMenu(context, song, searchState.songResults, searchState.songResults.indexOf(song));
                },
              )),
        ],
        // アーティストの検索結果
        if (searchState.artistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.sectionArtists,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.artistResults.map((artist) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.person, color: Theme.of(context).iconTheme.color),
                ),
                title: Text(artist.name),
                subtitle: Text(l10n.songCount(artist.songIds.length)),
                onTap: () {
                  // アーティスト詳細画面へ遷移（未実装）
                },
              )),
        ],
        // アルバムの検索結果
        if (searchState.albumResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.sectionAlbums,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.albumResults.map((album) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.album, size: 20),
                ),
                title: Text(album.name),
                subtitle: Text(album.artist),
                onTap: () {
                  // アルバム詳細画面へ遷移（未実装）
                },
              )),
        ],
        // プレイリストの検索結果
        if (searchState.playlistResults.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.sectionPlaylists,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...searchState.playlistResults.map((playlist) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.queue_music, size: 20),
                ),
                title: Text(playlist.name),
                subtitle: Text(l10n.songCount(playlist.songIds.length)),
                onTap: () {
                  // プレイリスト詳細画面へ遷移（未実装）
                },
              )),
        ],
        if (searchState.songResults.isEmpty &&
            searchState.artistResults.isEmpty &&
            searchState.albumResults.isEmpty &&
            searchState.playlistResults.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(l10n.noResults),
            ),
          ),
        ],
      ),
    );
  }
}
