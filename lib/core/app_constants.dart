/// アプリケーション全体で使用する定数を管理
/// - 対応フォーマット
/// - 音量オフセット調整範囲
/// - 歌詞表示設定のデフォルト値
/// - カラー定義
/// - 再生速度設定
/// 
class AppConstants {
  // ============================================================================
  // 対応フォーマット（仕様セクション 7, 9.2）
  // ============================================================================
  static const List<String> supportedAudioFormats = [
    'AAC', 'MP3', 'FLAC', 'M4A', 'AIFF', 'WAV'
  ];

  static const List<String> supportedLyricsFormats = ['LRC'];

  // ============================================================================
  // YouTube出力形式（仕様セクション 9.1）
  // ============================================================================
  static const List<String> youtubeOutputFormats = ['M4A', 'MP3', 'FLAC'];
  static const int defaultYouTubeBitrate = 256;          // kbps
  static const int defaultYouTubeSamplingRate = 44100;   // Hz

  // ============================================================================
  // 音量オフセット調整範囲（仕様セクション 5 拡張UI）
  // ============================================================================
  static const double minVolumeOffsetDb = -12.0;
  static const double maxVolumeOffsetDb = 12.0;

  // ============================================================================
  // 歌詞表示設定のデフォルト値（仕様セクション 6, 9.3）
  // ============================================================================
  static const int defaultLyricsContextLines = 2;        // 前後表示行数
  static const double defaultLyricsFontSize = 16.0;

  // ============================================================================
  // 再生速度設定（仕様セクション 5 再生コントロール）
  // ============================================================================
  static const List<double> availablePlaybackSpeeds = [1.0, 1.25, 1.5, 2.0];
  static const double defaultPlaybackSpeed = 1.0;

  // ============================================================================
  // カラーデザイン（仕様セクション 10）
  // ============================================================================
  static const int primaryColor = 0xFFFF2D55;            // Apple Music Red
  static const int surfaceColor = 0xFF1C1C1E;            // Dark surface
  static const int backgroundColor = 0xFF000000;         // Black background

  // ============================================================================
  // ソートオプション
  // ============================================================================
  static const List<String> sortOptions = ['title', 'artist', 'album', 'duration'];
  static const String defaultSortOption = 'title';

  // ============================================================================
  // UIタイムアウト
  // ============================================================================
  static const Duration seekDebounceTime = Duration(milliseconds: 300);
  static const Duration networkTimeout = Duration(seconds: 30);
}