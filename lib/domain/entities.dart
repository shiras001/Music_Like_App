/// ドメイン層のエンティティ（ビジネスロジック層）
/// 楽曲、プレイリスト、アーティスト、アルバム、ユーザー設定のモデル定義
/// 
// ============================================================================
// 楽曲エンティティ
// ============================================================================
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? artworkUrl;
  final Duration duration;
  final String fileFormat;        // 'AAC', 'MP3', 'FLAC', 'M4A', 'AIFF', 'WAV'
  final bool isLossless;          // ロスレス判定
  final bool isDolbyAtmos;        // Dolby Atmos（空間オーディオ）対応
  final double volumeOffsetDb;    // ±dB単位での楽曲単位音量オフセット
  final String? localPath;        // ローカルファイルパス（ローカル曲の場合）
  final bool isLocal;             // ローカルファイルか
  final String? lyricsPath;       // 歌詞ファイルパス（LRC形式）

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.artworkUrl,
    required this.duration,
    required this.fileFormat,
    this.isLossless = false,
    this.isDolbyAtmos = false,
    this.volumeOffsetDb = 0.0,
    this.localPath,
    this.isLocal = false,
    this.lyricsPath,
  });

  // イミュータブルな更新用メソッド
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? artworkUrl,
    Duration? duration,
    String? fileFormat,
    bool? isLossless,
    bool? isDolbyAtmos,
    double? volumeOffsetDb,
    String? localPath,
    bool? isLocal,
    String? lyricsPath,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      duration: duration ?? this.duration,
      fileFormat: fileFormat ?? this.fileFormat,
      isLossless: isLossless ?? this.isLossless,
      isDolbyAtmos: isDolbyAtmos ?? this.isDolbyAtmos,
      volumeOffsetDb: volumeOffsetDb ?? this.volumeOffsetDb,
      localPath: localPath ?? this.localPath,
      isLocal: isLocal ?? this.isLocal,
      lyricsPath: lyricsPath ?? this.lyricsPath,
    );
  }
}

// ============================================================================
// プレイリストエンティティ
// ============================================================================
class Playlist {
  final String id;
  final String name;
  final List<String> songIds;      // 楽曲IDのリスト
  final String? description;       // プレイリストの説明
  final String? coverUrl;          // プレイリストカバー画像
  final DateTime createdAt;        // 作成日時
  final DateTime? updatedAt;       // 更新日時

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    this.description,
    this.coverUrl,
    required this.createdAt,
    this.updatedAt,
  });

  // イミュータブルな更新用メソッド
  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    String? description,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// ============================================================================
// アーティストエンティティ
// ============================================================================
class Artist {
  final String id;
  final String name;
  final String? bio;               // アーティスト説明
  final String? imageUrl;          // アーティスト画像
  final List<String> songIds;      // アーティストの楽曲ID一覧

  Artist({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    required this.songIds,
  });

  Artist copyWith({
    String? id,
    String? name,
    String? bio,
    String? imageUrl,
    List<String>? songIds,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      imageUrl: imageUrl ?? this.imageUrl,
      songIds: songIds ?? this.songIds,
    );
  }
}

// ============================================================================
// アルバムエンティティ
// ============================================================================
class Album {
  final String id;
  final String name;
  final String artist;            // アーティスト名
  final String? releaseDate;      // リリース日
  final String? coverUrl;         // アルバムカバー画像
  final List<String> songIds;     // アルバムの楽曲ID一覧

  Album({
    required this.id,
    required this.name,
    required this.artist,
    this.releaseDate,
    this.coverUrl,
    required this.songIds,
  });

  Album copyWith({
    String? id,
    String? name,
    String? artist,
    String? releaseDate,
    String? coverUrl,
    List<String>? songIds,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      releaseDate: releaseDate ?? this.releaseDate,
      coverUrl: coverUrl ?? this.coverUrl,
      songIds: songIds ?? this.songIds,
    );
  }
}

// ============================================================================
// 再生状態エンティティ
// ============================================================================
enum ShuffleMode { off, on }
enum RepeatMode { off, all, one }

class PlaybackState {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration duration;
  final ShuffleMode shuffleMode;
  final RepeatMode repeatMode;
  final double playbackSpeed;      // 1.0x, 1.25x, 1.5x, 2.0x
  final String? currentSongId;

  PlaybackState({
    required this.isPlaying,
    required this.currentPosition,
    required this.duration,
    this.shuffleMode = ShuffleMode.off,
    this.repeatMode = RepeatMode.off,
    this.playbackSpeed = 1.0,
    this.currentSongId,
  });

  PlaybackState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? duration,
    ShuffleMode? shuffleMode,
    RepeatMode? repeatMode,
    double? playbackSpeed,
    String? currentSongId,
  }) {
    return PlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      duration: duration ?? this.duration,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      currentSongId: currentSongId ?? this.currentSongId,
    );
  }
}

// ============================================================================
// キュー（次に再生）エンティティ
// ============================================================================
class Queue {
  final List<String> songIds;      // 順序付きの楽曲ID
  final int currentIndex;          // 現在の再生位置

  Queue({
    required this.songIds,
    required this.currentIndex,
  });

  Queue copyWith({
    List<String>? songIds,
    int? currentIndex,
  }) {
    return Queue(
      songIds: songIds ?? this.songIds,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}