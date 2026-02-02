/// ドメイン層のユースケース
/// ビジネスロジックの定義
/// - 再生管理、プレイリスト管理、検索、YouTube変換、ローカルファイル読込
/// 
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'entities.dart';
import '../data/repositories.dart';
import '../data/youtube_service.dart';
import '../data/local_audio_service.dart';

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
  final IMusicRepository _musicRepo;

  PlaylistUseCase(this._playlistRepo, this._musicRepo);

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

// ============================================================================
// YouTube動画からの音声抽出、メタデータタグ付与
// ============================================================================
class YouTubeDownloadUseCase {
  final IYouTubeService _youtubeService;
  final IMusicRepository _musicRepo;

  YouTubeDownloadUseCase(this._youtubeService, this._musicRepo);

  /// YouTubeから動画メタデータを取得
  Future<YouTubeVideoInfo> getVideoInfo(String url) {
    return _youtubeService.getVideoInfo(url);
  }

  /// YouTube動画から音声をダウンロード・変換して保存
  Future<Song?> downloadAndConvert(
    String youtubeUrl,
    String outputFormat,
    String outputPath,
    int bitrate,
  ) async {
    try {
      final videoInfo = await _youtubeService.getVideoInfo(youtubeUrl);

      // ビデオダウンロード + FFmpeg変換
      final audioPath = await _youtubeService.downloadAndConvert(
        youtubeUrl,
        outputFormat: outputFormat,
        outputPath: outputPath,
        bitrate: bitrate,
      );

      // Songエンティティを作成してライブラリに追加
      final song = Song(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: videoInfo.title,
        artist: videoInfo.channelName,
        album: videoInfo.channelName,
        duration: videoInfo.duration,
        fileFormat: outputFormat,
        artworkUrl: videoInfo.thumbnailUrl,
        localPath: audioPath,
        isLocal: true,
      );

      return song;
    } catch (e) {
      debugPrint('YouTube download error: $e');
      return null;
    }
  }
}

// ============================================================================
// ローカルファイル読込ユースケース
// ============================================================================
/// ローカルファイル（音声・歌詞）の読込、重複検出
class LocalFileImportUseCase {
  final ILocalAudioService _localAudioService;
  final IMusicRepository _musicRepo;
  final ILocalSettingsRepository _settingsRepo;

  LocalFileImportUseCase(
    this._localAudioService,
    this._musicRepo,
    this._settingsRepo,
  );

  /// ファイル選択ダイアログから単一ファイルをインポート
  Future<Song?> importSingleAudioFile(String filePath) async {
    try {
      final metadata = await _localAudioService.getMetadata(filePath);

      final song = Song(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: metadata.title,
        artist: metadata.artist,
        album: metadata.album,
        duration: metadata.duration,
        fileFormat: _getFileFormat(filePath),
        localPath: filePath,
        isLocal: true,
        lyricsPath: metadata.lyrics.isNotEmpty ? filePath.replaceAll(RegExp(r'\.[^.]*$'), '.lrc') : null,
      );

      return song;
    } catch (e) {
      debugPrint('Local file import error: $e');
      return null;
    }
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

  /// サポートされているファイル形式かチェック
  bool isSupportedFormat(String filePath) {
    const supportedFormats = ['aac', 'mp3', 'flac', 'm4a', 'aiff', 'wav', 'lrc'];
    final ext = filePath.split('.').last.toLowerCase();
    return supportedFormats.contains(ext);
  }

  String _getFileFormat(String filePath) {
    return filePath.split('.').last.toUpperCase();
  }
}

