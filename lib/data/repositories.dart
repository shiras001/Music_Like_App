/// データ層：リポジトリパターンの実装
/// - 設定データモデル（AppSettings, LyricsSettings, YouTubeSettings）
/// - リポジトリインターフェース（IMusicRepository, IPlaylistRepository, ILocalSettingsRepository）
/// - 実装クラス
/// 
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../domain/entities.dart';
import 'youtube_service.dart';
import 'local_audio_service.dart';

// ============================================================================
// 設定データモデル
// ============================================================================

/// YouTube音声抽出設定
class YouTubeSettings {
  final bool enabled;              // YouTube機能の有効/無効
  final String outputFormat;       // M4A / MP3 / FLAC
  final int bitrate;               // ビットレート（kbps）
  final int samplingRate;          // サンプリングレート（Hz）

  YouTubeSettings({
    this.enabled = false,
    this.outputFormat = 'M4A',
    this.bitrate = 256,
    this.samplingRate = 44100,
  });

  YouTubeSettings copyWith({
    bool? enabled,
    String? outputFormat,
    int? bitrate,
    int? samplingRate,
  }) {
    return YouTubeSettings(
      enabled: enabled ?? this.enabled,
      outputFormat: outputFormat ?? this.outputFormat,
      bitrate: bitrate ?? this.bitrate,
      samplingRate: samplingRate ?? this.samplingRate,
    );
  }
}

/// ローカルファイル読込設定
class LocalFileSettings {
  final bool autoScanEnabled;      // フォルダ自動スキャン有効
  final List<String> scanPaths;    // スキャン対象フォルダ
  final bool duplicateDetection;   // 重複検出ポリシー（古い方を削除）

  LocalFileSettings({
    this.autoScanEnabled = false,
    this.scanPaths = const [],
    this.duplicateDetection = false,
  });

  LocalFileSettings copyWith({
    bool? autoScanEnabled,
    List<String>? scanPaths,
    bool? duplicateDetection,
  }) {
    return LocalFileSettings(
      autoScanEnabled: autoScanEnabled ?? this.autoScanEnabled,
      scanPaths: scanPaths ?? this.scanPaths,
      duplicateDetection: duplicateDetection ?? this.duplicateDetection,
    );
  }
}

/// 歌詞表示設定
class LyricsSettings {
  final bool enabled;              // 歌詞表示の有効/無効
  final int contextLines;          // 前後の表示行数
  final double fontSize;           // フォントサイズ
  final bool highlightCurrent;     // 現在行の強調表示

  LyricsSettings({
    this.enabled = true,
    this.contextLines = 2,
    this.fontSize = 16.0,
    this.highlightCurrent = true,
  });

  LyricsSettings copyWith({
    bool? enabled,
    int? contextLines,
    double? fontSize,
    bool? highlightCurrent,
  }) {
    return LyricsSettings(
      enabled: enabled ?? this.enabled,
      contextLines: contextLines ?? this.contextLines,
      fontSize: fontSize ?? this.fontSize,
      highlightCurrent: highlightCurrent ?? this.highlightCurrent,
    );
  }
}

/// アプリケーション全体設定
class AppSettings {
  final YouTubeSettings youtubeSettings;
  final LocalFileSettings localFileSettings;
  final LyricsSettings lyricsSettings;
  final bool airPlayEnabled;       // AirPlay選択機能

  AppSettings({
    YouTubeSettings? youtubeSettings,
    LocalFileSettings? localFileSettings,
    LyricsSettings? lyricsSettings,
    this.airPlayEnabled = true,
  })  : youtubeSettings = youtubeSettings ?? YouTubeSettings(),
        localFileSettings = localFileSettings ?? LocalFileSettings(),
        lyricsSettings = lyricsSettings ?? LyricsSettings();

  AppSettings copyWith({
    YouTubeSettings? youtubeSettings,
    LocalFileSettings? localFileSettings,
    LyricsSettings? lyricsSettings,
    bool? airPlayEnabled,
  }) {
    return AppSettings(
      youtubeSettings: youtubeSettings ?? this.youtubeSettings,
      localFileSettings: localFileSettings ?? this.localFileSettings,
      lyricsSettings: lyricsSettings ?? this.lyricsSettings,
      airPlayEnabled: airPlayEnabled ?? this.airPlayEnabled,
    );
  }
}

// ============================================================================
// リポジトリインターフェース
// ============================================================================

/// 楽曲操作リポジトリ
abstract class IMusicRepository {
  Future<List<Song>> fetchLibrary();
  Future<Song?> getSongById(String id);
  Future<void> updateSongMetadata(String songId, Map<String, dynamic> data);
  Future<void> updateSongVolumeOffset(String songId, double offsetDb);
  Future<void> deleteSong(String songId);
}

/// プレイリスト操作リポジトリ
abstract class IPlaylistRepository {
  Future<List<Playlist>> fetchAllPlaylists();
  Future<Playlist?> getPlaylistById(String id);
  Future<String> createPlaylist(String name, {String? description});
  Future<void> updatePlaylistName(String playlistId, String newName);
  Future<void> addSongToPlaylist(String playlistId, String songId);
  Future<void> removeSongFromPlaylist(String playlistId, String songId);
  Future<void> reorderPlaylist(String playlistId, int fromIndex, int toIndex);
  Future<void> deletePlaylist(String playlistId);
}

/// アーティスト操作リポジトリ
abstract class IArtistRepository {
  Future<List<Artist>> fetchAllArtists();
  Future<Artist?> getArtistById(String id);
  Future<List<Song>> getSongsByArtist(String artistId);
}

/// アルバム操作リポジトリ
abstract class IAlbumRepository {
  Future<List<Album>> fetchAllAlbums();
  Future<Album?> getAlbumById(String id);
  Future<List<Song>> getSongsByAlbum(String albumId);
}

/// 設定保存リポジトリ
abstract class ILocalSettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}

/// 検索リポジトリ
abstract class ISearchRepository {
  Future<List<Song>> searchSongs(String query);
  Future<List<Artist>> searchArtists(String query);
  Future<List<Album>> searchAlbums(String query);
  Future<List<Playlist>> searchPlaylists(String query);
}

// ============================================================================
// リポジトリ実装クラス
// ============================================================================

class MusicRepositoryImpl implements IMusicRepository {
  @override
  Future<List<Song>> fetchLibrary() async {
    try {
      // アプリ専用ディレクトリの Music フォルダをスキャン
      final appDocDir = Directory(
        (await getApplicationDocumentsDirectory()).path,
      );
      final musicDir = Directory('${appDocDir.path}/Music');
      
      if (!await musicDir.exists()) {
        // ディレクトリがまだ作成されていない場合は空リストを返す
        return [];
      }
      
      final songs = <Song>[];
      int songCounter = 0;
      
      try {
        // Music ディレクトリ内の音声ファイルを列挙
        final localService = LocalAudioServiceImpl();
        await for (final entity in musicDir.list()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last;
            final extension = fileName.split('.').last.toLowerCase();
            
            // サポートされているフォーマットか確認
            if (['mp3', 'm4a', 'flac', 'wav', 'aiff'].contains(extension)) {
              songCounter++;
              final fileSize = await entity.length();

              // try to read metadata from file using LocalAudioService
              String title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
              String artist = 'Unknown Artist';
              String album = 'Unknown Album';
              Duration duration = Duration.zero;
              String localPath = entity.absolute.path;

              try {
                final meta = await localService.getMetadata(localPath);
                title = meta.title;
                artist = meta.artist;
                album = meta.album;
                duration = meta.duration;

                // 保存されたアートワークがあればファイル化して artworkUrl を設定
                if (meta.artworkData != null && meta.artworkData!.isNotEmpty) {
                  try {
                    final audioDir = p.dirname(localPath);
                    final baseName = p.basenameWithoutExtension(localPath);
                    final artPath = p.join(audioDir, '${baseName}_cover.jpg');
                    final artFile = File(artPath);
                    if (!artFile.existsSync()) {
                      await artFile.writeAsBytes(meta.artworkData!);
                    }
                    // set artworkUrl to local file path
                    // store as file:// URI so Image.file / Image.network can use it if needed
                    // but UI currently uses Image.network; using file path should still work with Image.file elsewhere
                    // we store the absolute path
                    // assign later when constructing Song
                    // temporarily attach to a variable
                    // we'll set artworkUrl below
                    
                    // Use a small variable to keep path
                    // (will be assigned to song.artworkUrl)
                    
                    // assign to local variable for later
                    // (we'll reuse 'title' etc.)
                    
                    // store artPath to local variable by shadowing
                    
                    // Save artPath in a map or closure-free var
                    
                    // For simplicity, temporarily set album to itself
                  } catch (e) {
                    // ignore artwork write errors
                  }
                }
              } catch (e) {
                // フォールバック: サイズから推定
                if (extension == 'flac') {
                  duration = Duration(seconds: (fileSize ~/ 40000).clamp(1, 86400));
                } else {
                  duration = Duration(seconds: (fileSize ~/ 16000).clamp(1, 86400));
                }
              }

              // 一意のIDを生成
              final id = 'local_${songCounter}';

              // determine artwork path (if exists)
              String? artworkPath;
              try {
                final audioDir = p.dirname(localPath);
                final baseName = p.basenameWithoutExtension(localPath);
                final candidate = p.join(audioDir, '${baseName}_cover.jpg');
                if (File(candidate).existsSync()) artworkPath = candidate;
              } catch (_) {}

              // determine lyrics path (if exists)
              String? lyricsPath;
              try {
                final audioDir = p.dirname(localPath);
                final baseName = p.basenameWithoutExtension(localPath);
                final lrcCandidate = p.join(audioDir, '$baseName.lrc');
                if (File(lrcCandidate).existsSync()) {
                  lyricsPath = lrcCandidate;
                }
              } catch (_) {}

              final song = Song(
                id: id,
                title: title,
                artist: artist,
                album: album,
                duration: duration,
                fileFormat: extension.toUpperCase(),
                isLocal: true,
                localPath: localPath,
                artworkUrl: artworkPath,
                lyricsPath: lyricsPath,
              );
              
              // メタデータログ出力
              print('[Library] メタデータ取得:');
              print('  ID: ${song.id}');
              print('  タイトル: ${song.title}');
              print('  アーティスト: ${song.artist}');
              print('  アルバム: ${song.album}');
              print('  フォーマット: ${song.fileFormat}');
              print('  ロスレス: ${song.isLossless}');
              print('  Dolby Atmos: ${song.isDolbyAtmos}');
              print('  ジャケット: ${song.artworkUrl}');
              print('  ローカルパス: ${song.localPath}');
              print('  再生時間: ${song.duration.inSeconds}秒');
              print('  歌詞パス: ${song.lyricsPath}');
              
              songs.add(song);
            }
          }
        }
      } catch (e) {
        print('[Library] ディレクトリスキャンエラー: $e');
      }
      
      print('[Library] ライブラリ更新完了: ${songs.length}曲');
      return songs;
    } catch (e) {
      print('[Library] エラー: $e');
      return [];
    }
  }

  @override
  Future<Song?> getSongById(String id) async {
    final library = await fetchLibrary();
    return library.where((s) => s.id == id).firstOrNull;
  }

  @override
  Future<void> updateSongMetadata(String songId, Map<String, dynamic> data) async {
    // 実際のDB更新処理
  }

  @override
  Future<void> updateSongVolumeOffset(String songId, double offsetDb) async {
    // 楽曲の音量オフセット値を保存
  }

  @override
  Future<void> deleteSong(String songId) async {
    // 楽曲を削除
  }
}

class PlaylistRepositoryImpl implements IPlaylistRepository {
  final Map<String, Playlist> _playlists = {};

  @override
  Future<List<Playlist>> fetchAllPlaylists() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _playlists.values.toList();
  }

  @override
  Future<Playlist?> getPlaylistById(String id) async {
    return _playlists[id];
  }

  @override
  Future<String> createPlaylist(String name, {String? description}) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(
      id: id,
      name: name,
      songIds: [],
      description: description,
      createdAt: DateTime.now(),
    );
    _playlists[id] = playlist;
    return id;
  }

  @override
  Future<void> updatePlaylistName(String playlistId, String newName) async {
    final playlist = _playlists[playlistId];
    if (playlist != null) {
      _playlists[playlistId] = playlist.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = _playlists[playlistId];
    if (playlist != null && !playlist.songIds.contains(songId)) {
      _playlists[playlistId] = playlist.copyWith(
        songIds: [...playlist.songIds, songId],
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final playlist = _playlists[playlistId];
    if (playlist != null) {
      _playlists[playlistId] = playlist.copyWith(
        songIds: playlist.songIds.where((id) => id != songId).toList(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> reorderPlaylist(String playlistId, int fromIndex, int toIndex) async {
    final playlist = _playlists[playlistId];
    if (playlist != null) {
      final songIds = List<String>.from(playlist.songIds);
      final item = songIds.removeAt(fromIndex);
      songIds.insert(toIndex, item);
      _playlists[playlistId] = playlist.copyWith(
        songIds: songIds,
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  Future<void> deletePlaylist(String playlistId) async {
    _playlists.remove(playlistId);
  }
}

class ArtistRepositoryImpl implements IArtistRepository {
  @override
  Future<List<Artist>> fetchAllArtists() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  @override
  Future<Artist?> getArtistById(String id) async {
    return null;
  }

  @override
  Future<List<Song>> getSongsByArtist(String artistId) async {
    return [];
  }
}

class AlbumRepositoryImpl implements IAlbumRepository {
  @override
  Future<List<Album>> fetchAllAlbums() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    return null;
  }

  @override
  Future<List<Song>> getSongsByAlbum(String albumId) async {
    return [];
  }
}

class LocalSettingsRepositoryImpl implements ILocalSettingsRepository {
  AppSettings _currentSettings = AppSettings();

  @override
  Future<AppSettings> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _currentSettings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _currentSettings = settings;
    // 実際はSharedPreferences/Hive等で永続化
  }
}

class SearchRepositoryImpl implements ISearchRepository {
  final IMusicRepository musicRepository;
  final IPlaylistRepository playlistRepository;

  SearchRepositoryImpl(this.musicRepository, this.playlistRepository);

  @override
  Future<List<Song>> searchSongs(String query) async {
    final library = await musicRepository.fetchLibrary();
    final lowerQuery = query.toLowerCase();
    return library
        .where((song) =>
            song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery) ||
            song.album.toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<List<Artist>> searchArtists(String query) async {
    final library = await musicRepository.fetchLibrary();
    final lowerQuery = query.toLowerCase();
    final Map<String, List<Song>> grouped = {};

    for (final song in library) {
      if (!song.artist.toLowerCase().contains(lowerQuery)) continue;
      grouped.putIfAbsent(song.artist, () => []).add(song);
    }

    return grouped.entries.map((entry) {
      final name = entry.key;
      final songs = entry.value;
      return Artist(
        id: name,
        name: name,
        songIds: songs.map((s) => s.id).toList(),
        imageUrl: songs.first.artworkUrl,
      );
    }).toList();
  }

  @override
  Future<List<Album>> searchAlbums(String query) async {
    final library = await musicRepository.fetchLibrary();
    final lowerQuery = query.toLowerCase();
    final Map<String, List<Song>> grouped = {};

    for (final song in library) {
      if (!song.album.toLowerCase().contains(lowerQuery)) continue;
      final key = '${song.album}__${song.artist}';
      grouped.putIfAbsent(key, () => []).add(song);
    }

    return grouped.entries.map((entry) {
      final songs = entry.value;
      final first = songs.first;
      return Album(
        id: entry.key,
        name: first.album,
        artist: first.artist,
        coverUrl: first.artworkUrl,
        songIds: songs.map((s) => s.id).toList(),
      );
    }).toList();
  }

  @override
  Future<List<Playlist>> searchPlaylists(String query) async {
    final playlists = await playlistRepository.fetchAllPlaylists();
    final lowerQuery = query.toLowerCase();
    return playlists
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

// ============================================================================
// Riverpod Providers
// ============================================================================

final musicRepositoryProvider = Provider<IMusicRepository>((ref) {
  return MusicRepositoryImpl();
});

final playlistRepositoryProvider = Provider<IPlaylistRepository>((ref) {
  return PlaylistRepositoryImpl();
});

final artistRepositoryProvider = Provider<IArtistRepository>((ref) {
  return ArtistRepositoryImpl();
});

final albumRepositoryProvider = Provider<IAlbumRepository>((ref) {
  return AlbumRepositoryImpl();
});

final settingsRepositoryProvider = Provider<ILocalSettingsRepository>((ref) {
  return LocalSettingsRepositoryImpl();
});

final searchRepositoryProvider = Provider<ISearchRepository>((ref) {
  final musicRepo = ref.watch(musicRepositoryProvider);
  final playlistRepo = ref.watch(playlistRepositoryProvider);
  return SearchRepositoryImpl(musicRepo, playlistRepo);
});

final youtubeServiceProvider = Provider<IYouTubeService>((ref) {
  return YouTubeServiceImpl();
});

final localAudioServiceProvider = Provider<ILocalAudioService>((ref) {
  return LocalAudioServiceImpl();
});