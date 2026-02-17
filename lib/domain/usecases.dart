/// ドメイン層のユースケース
/// ビジネスロジックの定義
/// - 再生管理、プレイリスト管理、検索、YouTube変換、ローカルファイル読込
/// 
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'entities.dart';
import '../data/repositories.dart';
import '../data/local_audio_service.dart';
import '../data/thumbnail_store.dart';

// ============================================================================
// プレイヤー再生管理ユースケース
// ============================================================================
/// 再生状態管理、スキップ、速度制御など
class PlayerUseCase {
  final IMusicRepository _musicRepo;

  PlayerUseCase(this._musicRepo);

  /// 有効音量（dB）を計算
  /// ベース音量（0～100）を-12～+12dBに正規化
  double calculateEffectiveVolume(
    double baseVolumePercent,
    double volumeOffset,
  ) {
    const maxDbRange = 12.0;
    final normalizedBase = (baseVolumePercent / 100.0 * 2 - 1) * maxDbRange;
    return normalizedBase + volumeOffset;
  }

  /// 次の楽曲を取得（シャッフルまたはプレイリスト順）
  Future<Song?> getNextSong(
    Queue queue,
    int currentIndex,
    bool isShuffle,
  ) async {
    if (queue.songIds.isEmpty) return null;

    int nextIndex;
    if (isShuffle) {
      nextIndex = Random().nextInt(queue.songIds.length);
    } else {
      nextIndex = (currentIndex + 1) % queue.songIds.length;
    }

    try {
      final song = await _musicRepo.getSongById(queue.songIds[nextIndex]);
      return song;
    } catch (e) {
      debugPrint('Error getting next song: $e');
      return null;
    }
  }

  /// 前の楽曲を取得
  Future<Song?> getPreviousSong(
    Queue queue,
    int currentIndex,
  ) async {
    if (queue.songIds.isEmpty) return null;

    final previousIndex =
        currentIndex == 0 ? queue.songIds.length - 1 : currentIndex - 1;

    try {
      final song = await _musicRepo.getSongById(queue.songIds[previousIndex]);
      return song;
    } catch (e) {
      debugPrint('Error getting previous song: $e');
      return null;
    }
  }

  /// スキップして次の楽曲へ
  Future<void> skipToNext(Queue queue) async {
    // 実装予定
  }

  /// スキップして前の楽曲へ
  Future<void> skipToPrevious(Queue queue) async {
    // 実装予定
  }

  /// 指定位置にスキップ（秒）
  Future<void> seekTo(Duration position) async {
    // 実装予定
  }

  /// 再生速度を設定
  Future<void> setPlaybackSpeed(double speed) async {
    // 実装予定
  }

  /// シャッフル切り替え
  Future<void> toggleShuffle(bool enabled) async {
    // 実装予定
  }

  /// リピートモード変更
  Future<void> setRepeatMode(RepeatMode mode) async {
    // 実装予定
  }
}

// ============================================================================
// ライブラリ管理ユースケース
// ============================================================================
/// 楽曲ライブラリの検索、フィルタリング、ソート
class LibraryUseCase {
  final IMusicRepository _musicRepo;

  LibraryUseCase(this._musicRepo);

  /// ライブラリ全体を取得
  Future<List<Song>> getLibrary() {
    return _musicRepo.fetchLibrary();
  }

  /// ライブラリの楽曲を取得（別名）
  Future<List<Song>> getLibrarySongs() {
    return _musicRepo.fetchLibrary();
  }

  /// 楽曲を名前で検索
  Future<List<Song>> searchSongs(String query) async {
    final library = await _musicRepo.fetchLibrary();
    final lowerQuery = query.toLowerCase();

    return library
        .where((song) =>
            song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery) ||
            song.album.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 楽曲をアーティストでグループ化
  Future<Map<String, List<Song>>> getByArtist() async {
    final library = await _musicRepo.fetchLibrary();
    final grouped = <String, List<Song>>{};

    for (final song in library) {
      if (!grouped.containsKey(song.artist)) {
        grouped[song.artist] = [];
      }
      grouped[song.artist]!.add(song);
    }

    return grouped;
  }

  /// 楽曲をアルバムでグループ化
  Future<Map<String, List<Song>>> getByAlbum() async {
    final library = await _musicRepo.fetchLibrary();
    final grouped = <String, List<Song>>{};

    for (final song in library) {
      if (!grouped.containsKey(song.album)) {
        grouped[song.album] = [];
      }
      grouped[song.album]!.add(song);
    }

    return grouped;
  }

  /// 楽曲をソート（タイトル、アーティスト、追加日時）
  List<Song> sortSongs(
    List<Song> songs, {
    required String sortBy,
    bool ascending = true,
  }) {
    final sorted = [...songs];

    switch (sortBy) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'artist':
        sorted.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case 'date':
        sorted.sort((a, b) => 0);
        break;
    }

    if (!ascending) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  /// ライブラリ内の楽曲総数を取得
  Future<int> getLibrarySize() async {
    final library = await _musicRepo.fetchLibrary();
    return library.length;
  }

  /// 最近追加された楽曲を取得
  Future<List<Song>> getRecentlyAdded({int limit = 10}) async {
    final library = await _musicRepo.fetchLibrary();
    return library.take(limit).toList();
  }

  /// 楽曲メタデータを更新
  Future<void> updateSongMetadata(String songId, Map<String, dynamic> data) async {
    await _musicRepo.updateSongMetadata(songId, data);
  }

  /// 楽曲を削除
  Future<void> deleteSong(String songId) async {
    await _musicRepo.deleteSong(songId);
  }
}

// ============================================================================
// プレイリスト管理ユースケース
// ============================================================================
/// プレイリスト作成、編集、順序変更
class PlaylistUseCase {
  final IPlaylistRepository _playlistRepo;
  
  PlaylistUseCase(this._playlistRepo);

  /// すべてのプレイリストを取得
  Future<List<Playlist>> getPlaylists() {
    return _playlistRepo.fetchAllPlaylists();
  }

  /// プレイリストを作成
  Future<String> createPlaylist(String name, {String? description}) {
    return _playlistRepo.createPlaylist(name, description: description);
  }

  /// プレイリストに楽曲を追加
  Future<void> addSongToPlaylist(String playlistId, String songId) {
    return _playlistRepo.addSongToPlaylist(playlistId, songId);
  }

  /// プレイリストから楽曲を削除
  Future<void> removeSongFromPlaylist(String playlistId, String songId) {
    return _playlistRepo.removeSongFromPlaylist(playlistId, songId);
  }

  /// プレイリスト内の楽曲を並び替え
  Future<void> reorderSong(
    String playlistId,
    int fromIndex,
    int toIndex,
  ) {
    return _playlistRepo.reorderPlaylist(playlistId, fromIndex, toIndex);
  }

  /// プレイリスト名を変更
  Future<void> renamePlaylist(String playlistId, String newName) async {
    await _playlistRepo.updatePlaylistName(playlistId, newName);
  }

  /// プレイリストを削除
  Future<void> deletePlaylist(String playlistId) async {
    await _playlistRepo.deletePlaylist(playlistId);
  }
}

// ============================================================================
// 検索ユースケース
// ============================================================================
/// 複合検索（楽曲、アーティスト、アルバム、プレイリスト）
class SearchUseCase {
  final ISearchRepository _searchRepo;

  SearchUseCase(this._searchRepo);

  /// 楽曲のみを検索
  Future<List<Song>> searchSongs(String query) {
    return _searchRepo.searchSongs(query);
  }

  /// アーティストのみを検索
  Future<List<Artist>> searchArtists(String query) {
    return _searchRepo.searchArtists(query);
  }

  /// アルバムのみを検索
  Future<List<Album>> searchAlbums(String query) {
    return _searchRepo.searchAlbums(query);
  }

  /// プレイリストのみを検索
  Future<List<Playlist>> searchPlaylists(String query) {
    return _searchRepo.searchPlaylists(query);
  }
}

// YouTubeダウンロード機能は削除されました。関連ユースケースは廃止しています。

// ============================================================================
// ローカルファイル読込ユースケース
// ============================================================================
/// ローカルファイル（音声・歌詞）の読込、重複検出
class ImportProgress {
  final int total;
  final int processed;
  final String? message;

  const ImportProgress({
    required this.total,
    required this.processed,
    this.message,
  });

  double get ratio => total == 0 ? 0.0 : processed / total;
}

class ImportResult {
  final int total;
  final int imported;
  final int skipped;
  final int failed;
  final bool lazyParse;

  const ImportResult({
    required this.total,
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.lazyParse,
  });
}

class LocalFileImportUseCase {
  final ILocalAudioService _localAudioService;
  final IMusicRepository _musicRepo;
  
  LocalFileImportUseCase(
    this._localAudioService,
    this._musicRepo,
  );

  /// バッチインポート進捗
  static ImportProgress _progress(int processed, int total, {String? message}) {
    return ImportProgress(
      total: total,
      processed: processed,
      message: message,
    );
  }

  /// ファイル選択ダイアログから単一ファイルをインポート
  Future<Song?> importSingleAudioFile(String filePath) async {
    try {
      final metadata = await _localAudioService.getMetadata(filePath);

      final song = Song(
        id: filePath,
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        duration: metadata.duration,
        fileFormat: _getFileFormat(filePath),
        localPath: filePath,
        isLocal: true,
        lyricsPath: metadata.lyrics.isNotEmpty ? filePath.replaceAll(RegExp(r'\.[^.]*$'), '.lrc') : null,
      );
      await _musicRepo.upsertSong(song);
      return song;
    } catch (e) {
      debugPrint('Local file import error: $e');
      return null;
    }
  }

  /// 複数ファイルのバッチインポート
  Future<ImportResult> importAudioFilesBatched(
    List<String> filePaths, {
    Map<String, String?>? lyricsByPath,
    int batchSize = 30,
    bool lazyParse = false,
    bool duplicateDetection = false,
    void Function(ImportProgress progress)? onProgress,
  }) async {
    if (filePaths.isEmpty) {
      return const ImportResult(total: 0, imported: 0, skipped: 0, failed: 0, lazyParse: false);
    }

    final supported = filePaths.where(isSupportedFormat).toList();
    final existing = await _musicRepo.getExistingLocalPaths(supported);
    final pending = supported.where((p) => !existing.contains(p)).toList();

    final total = pending.length;
    int processed = 0;
    int imported = 0;
    int failed = 0;

    for (var i = 0; i < pending.length; i += batchSize) {
      final batch = pending.sublist(i, i + batchSize > pending.length ? pending.length : i + batchSize);

      try {
        if (lazyParse) {
          final songs = <Song>[];
          for (final path in batch) {
            final title = path.split(RegExp(r'[\\/]')).last.replaceAll(RegExp(r'\.[^.]+$'), '');
            songs.add(
              Song(
                id: path,
                title: title,
                artist: 'Unknown Artist',
                album: 'Unknown Album',
                duration: Duration.zero,
                fileFormat: _getFileFormat(path),
                localPath: path,
                isLocal: true,
                lyricsPath: lyricsByPath?[path],
              ),
            );
            imported++;
            processed++;
            onProgress?.call(_progress(processed, total, message: 'インポート中...'));
          }
          if (songs.isNotEmpty) {
            await _musicRepo.upsertSongs(songs, parseState: 0);
          }
        } else {
          final metadataList = await _localAudioService.parseMetadataBatch(
            batch,
            lyricsOverrides: lyricsByPath,
          );
          // Optional duplicate detection: compare by title/artist and remove older file
          Map<String, Song> existingByKey = {};
          if (duplicateDetection) {
            try {
              final library = await _musicRepo.fetchLibrary();
              for (final s in library) {
                final key = '${s.title}/${s.artist}';
                // keep the newest by file modified time (if available)
                if (!existingByKey.containsKey(key)) {
                  existingByKey[key] = s;
                } else {
                  final cur = existingByKey[key]!;
                  try {
                    final curPath = cur.localPath;
                    final sPath = s.localPath;
                    if (curPath != null && sPath != null) {
                      final curFile = File(curPath);
                      final sFile = File(sPath);
                      if (curFile.existsSync() && sFile.existsSync()) {
                        final curM = curFile.lastModifiedSync();
                        final sM = sFile.lastModifiedSync();
                        if (sM.isAfter(curM)) existingByKey[key] = s;
                      }
                    }
                  } catch (_) {}
                }
              }
            } catch (_) {}
          }

          final songs = <Song>[];
          for (final meta in metadataList) {
            try {
              var song = Song(
                id: meta.filePath,
                title: meta.title,
                artist: meta.artist,
                album: meta.album,
                duration: meta.duration,
                fileFormat: meta.fileFormat,
                localPath: meta.filePath,
                isLocal: true,
                lyricsPath: meta.lyricsPath,
                artworkUrl: meta.artworkThumbnail != null ? meta.filePath : null,
              );

              // If duplicate detection is enabled and an existing entry with same title/artist exists,
              // decide whether to replace the old one or skip the new one based on file modified time.
              if (duplicateDetection) {
                final key = '${song.title}/${song.artist}';
                final existing = existingByKey[key];
                if (existing != null) {
                  try {
                    final existingPath = existing.localPath;
                    if (existingPath != null) {
                      final existingFile = File(existingPath);
                      final newFile = File(song.localPath ?? song.id);
                      final existingExists = existingFile.existsSync();
                      final newExists = newFile.existsSync();
                      if (existingExists && newExists) {
                        final existingM = existingFile.lastModifiedSync();
                        final newM = newFile.lastModifiedSync();
                        if (newM.isAfter(existingM)) {
                          try {
                            await _musicRepo.deleteSong(existing.id);
                            if (existingFile.existsSync()) existingFile.deleteSync();
                          } catch (_) {}
                        } else {
                          processed++;
                          onProgress?.call(_progress(processed, total, message: 'インポート中...'));
                          continue;
                        }
                      }
                    }
                  } catch (_) {}
                }
              }

              if (meta.artworkThumbnail != null && meta.artworkThumbnail!.isNotEmpty) {
                final thumbPath = await ThumbnailStore.saveThumbnail(meta.filePath, meta.artworkThumbnail!);
                song = song.copyWith(artworkUrl: thumbPath);
              } else {
                song = song.copyWith(artworkUrl: null);
              }

              songs.add(song);
              imported++;
            } catch (_) {
              failed++;
            } finally {
              processed++;
              onProgress?.call(_progress(processed, total, message: 'インポート中...'));
            }
          }

          if (songs.isNotEmpty) {
            await _musicRepo.upsertSongs(songs, parseState: 1);
          }

          final missingCount = batch.length - metadataList.length;
          if (missingCount > 0) {
            failed += missingCount;
            for (var n = 0; n < missingCount; n++) {
              processed++;
              onProgress?.call(_progress(processed, total, message: 'インポート中...'));
            }
          }
        }
      } catch (e) {
        failed += batch.length;
        for (var n = 0; n < batch.length; n++) {
          processed++;
          onProgress?.call(_progress(processed, total, message: 'インポート中...'));
        }
      }
    }

    return ImportResult(
      total: total,
      imported: imported,
      skipped: supported.length - total,
      failed: failed,
      lazyParse: lazyParse,
    );
  }

  /// フォルダ内のすべての対応形式ファイルをインポート
  Future<List<Song>> importAudioFolder(String folderPath) async {
    try {
      final songList = await _localAudioService.scanDirectory(folderPath);
      return songList;
    } catch (e) {
      debugPrint('Folder import error: $e');
      return [];
    }
  }

  /// フォルダのバッチインポート（再帰スキャン）
  Future<ImportResult> importAudioFolderBatched(
    String folderPath, {
    int batchSize = 30,
    bool? lazyParse,
    bool duplicateDetection = false,
    void Function(ImportProgress progress)? onProgress,
  }) async {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      return const ImportResult(total: 0, imported: 0, skipped: 0, failed: 0, lazyParse: false);
    }

    final audioPaths = <String>[];
    final lrcMap = <String, String?>{};

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final ext = entity.path.split('.').last.toLowerCase();
        if (ext == 'lrc') {
          final base = entity.path.replaceAll(RegExp(r'\.[^.]+$'), '');
          lrcMap[base] = entity.path;
        } else if (isSupportedFormat(entity.path)) {
          audioPaths.add(entity.path);
        }
      }
    }

    final lyricsByPath = <String, String?>{};
    for (final audioPath in audioPaths) {
      final base = audioPath.replaceAll(RegExp(r'\.[^.]+$'), '');
      lyricsByPath[audioPath] = lrcMap[base];
    }

    final total = audioPaths.length;
    final useLazyParse = lazyParse ?? total >= 2000;

    // Wrap onProgress so callers see the scanner-detected total (audioPaths.length)
    void Function(ImportProgress progress)? wrappedOnProgress;
    if (onProgress != null) {
      wrappedOnProgress = (progress) {
        onProgress(ImportProgress(total: total, processed: progress.processed, message: progress.message));
      };
    }

    return importAudioFilesBatched(
      audioPaths,
      lyricsByPath: lyricsByPath,
      batchSize: batchSize,
      lazyParse: useLazyParse,
      duplicateDetection: duplicateDetection,
      onProgress: wrappedOnProgress,
    );
  }

  /// 未解析曲をバックグラウンドで補完
  Future<ImportResult> backfillUnparsed({
    int limit = 200,
    int batchSize = 30,
    void Function(ImportProgress progress)? onProgress,
  }) async {
    final targets = await _musicRepo.getUnparsedFilePaths(limit: limit);
    if (targets.isEmpty) {
      return const ImportResult(total: 0, imported: 0, skipped: 0, failed: 0, lazyParse: false);
    }

    return importAudioFilesBatched(
      targets,
      batchSize: batchSize,
      lazyParse: false,
      onProgress: onProgress,
    );
  }

  /// 歌詞ファイル（LRC）をインポート
  Future<bool> importLyricsFile(String songId, String lyricsPath) async {
    try {
      await _musicRepo.updateSongMetadata(
        songId,
        {'lyricsPath': lyricsPath},
      );
      return true;
    } catch (e) {
      debugPrint('Lyrics import error: $e');
      return false;
    }
  }

  /// 重複楽曲をチェック
  Future<List<Song>> checkDuplicates() async {
    try {
      final library = await _musicRepo.fetchLibrary();
      final duplicates = <Song>[];

      final seen = <String>{};
      for (final song in library) {
        final key = '${song.title}/${song.artist}';
        if (seen.contains(key)) {
          duplicates.add(song);
        }
        seen.add(key);
      }

      return duplicates;
    } catch (e) {
      debugPrint('Duplicate check error: $e');
      return [];
    }
  }

  /// 既存ライブラリに重複検出を適用して、古い曲を削除
  /// 返り値: 削除した件数
  Future<int> applyDuplicateDetectionToLibrary() async {
    try {
      final library = await _musicRepo.fetchLibrary();
      final keepByKey = <String, Song>{};
      final toDelete = <Song>[];

      for (final song in library) {
        final key = '${song.title}/${song.artist}';
        final existing = keepByKey[key];
        if (existing == null) {
          keepByKey[key] = song;
          continue;
        }

        final existingPath = existing.localPath;
        final newPath = song.localPath;
        if (existingPath != null && newPath != null) {
          try {
            final existingFile = File(existingPath);
            final newFile = File(newPath);
            if (existingFile.existsSync() && newFile.existsSync()) {
              final existingM = existingFile.lastModifiedSync();
              final newM = newFile.lastModifiedSync();
              if (newM.isAfter(existingM)) {
                toDelete.add(existing);
                keepByKey[key] = song;
              } else {
                toDelete.add(song);
              }
              continue;
            }
          } catch (_) {}
        }

        // fallback: keep first, delete the later one
        toDelete.add(song);
      }

      int removed = 0;
      for (final song in toDelete) {
        try {
          await _musicRepo.deleteSong(song.id);
          final path = song.localPath;
          if (path != null) {
            final file = File(path);
            if (file.existsSync()) file.deleteSync();
          }
          removed++;
        } catch (_) {}
      }
      return removed;
    } catch (e) {
      debugPrint('Duplicate apply error: $e');
      return 0;
    }
  }

  /// サポートされているファイル形式かチェック
  bool isSupportedFormat(String filePath) {
    const supportedFormats = ['aac', 'mp3', 'm4a', 'lrc'];
    final ext = filePath.split('.').last.toLowerCase();
    return supportedFormats.contains(ext);
  }

  String _getFileFormat(String filePath) {
    return filePath.split('.').last.toUpperCase();
  }
}

