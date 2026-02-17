// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonDetails => '詳細';

  @override
  String get commonDelete => '削除';

  @override
  String get commonApply => '変更';

  @override
  String get commonReset => 'リセット';

  @override
  String get commonPlay => '再生';

  @override
  String get commonShuffle => 'シャッフル';

  @override
  String get commonSearch => '検索';

  @override
  String get commonSort => '並び替え';

  @override
  String get commonEdit => '編集';

  @override
  String get commonRetry => '再試行';

  @override
  String get commonSaveChanges => '保存';

  @override
  String get tabSongs => '曲';

  @override
  String get tabArtists => 'アーティスト';

  @override
  String get tabAlbums => 'アルバム';

  @override
  String get tabPlaylists => 'プレイリスト';

  @override
  String get drawerSettings => '設定';

  @override
  String get drawerEditCategories => 'カテゴリを編集';

  @override
  String get drawerSort => '並び替え';

  @override
  String get libraryLoadFailed => 'ライブラリの読み込みに失敗しました';

  @override
  String get libraryReload => '再読み込み';

  @override
  String get errorDetailsTitle => 'エラー詳細';

  @override
  String get errorClose => '閉じる';

  @override
  String get searchHint => '曲名・アーティスト・アルバム';

  @override
  String get categoryEditTitle => 'カテゴリを編集';

  @override
  String get categorySongs => '曲';

  @override
  String get categoryArtists => 'アーティスト';

  @override
  String get categoryAlbums => 'アルバム';

  @override
  String get categoryPlaylists => 'プレイリスト';

  @override
  String get sortTitleAsc => 'タイトル (昇順)';

  @override
  String get sortTitleDesc => 'タイトル (降順)';

  @override
  String get sortArtistAsc => 'アーティスト (昇順)';

  @override
  String get sortArtistDesc => 'アーティスト (降順)';

  @override
  String get sortDurationAsc => '再生時間 (短い順)';

  @override
  String get sortDurationDesc => '再生時間 (長い順)';

  @override
  String get noSongs => '曲がありません';

  @override
  String get noArtists => 'アーティストがありません';

  @override
  String get noAlbums => 'アルバムがありません';

  @override
  String get noPlaylists => 'プレイリストがありません';

  @override
  String get noResults => '検索結果がありません';

  @override
  String songCount(int count) {
    return '$count曲';
  }

  @override
  String artistSongCount(String artist, int count) {
    return '$artist • $count曲';
  }

  @override
  String get searchTitle => '検索';

  @override
  String get searchPrompt => '曲名、アーティスト、アルバムで検索';

  @override
  String get sectionSongs => '曲';

  @override
  String get sectionArtists => 'アーティスト';

  @override
  String get sectionAlbums => 'アルバム';

  @override
  String get sectionPlaylists => 'プレイリスト';

  @override
  String get queueUpNext => '次に再生';

  @override
  String get queueEmpty => 'キューに曲がありません';

  @override
  String removedFromQueue(String songName) {
    return '「$songName」をキューから削除しました';
  }

  @override
  String get playNext => '次に再生';

  @override
  String addedPlayNext(String songName) {
    return '「$songName」を次に再生に追加しました';
  }

  @override
  String get addedToQueue => 'キューに追加しました';

  @override
  String get addToPlaylist => 'プレイリストに追加';

  @override
  String get addToPlaylistTitle => 'プレイリストに追加';

  @override
  String get createNewPlaylist => '新規プレイリストを作成';

  @override
  String get existingPlaylists => '既存のプレイリスト';

  @override
  String get createPlaylist => 'プレイリストを作成';

  @override
  String get playlistNameHint => 'プレイリスト名を入力';

  @override
  String get playlistCreated => 'プレイリストを作成しました';

  @override
  String get addedToPlaylist => 'プレイリストに追加しました';

  @override
  String get editLyrics => '歌詞を編集';

  @override
  String get editLyricsLrc => '歌詞を編集 (LRC)';

  @override
  String get editManually => '手動で編集';

  @override
  String get adjustTiming => 'タイミングの調整';

  @override
  String get lyricsFileNotFound => '歌詞ファイルが見つかりません';

  @override
  String get lyricsNoDestination => '歌詞ファイルの保存先がありません';

  @override
  String get lyricsSaved => '歌詞を保存しました';

  @override
  String lyricsSaveFailed(String error) {
    return '歌詞の保存に失敗しました: $error';
  }

  @override
  String get lrcHint => '[00:12.34]歌詞テキスト';

  @override
  String get editSongInfo => '曲データを編集';

  @override
  String get artworkLabel => 'アートワーク';

  @override
  String get selectImage => '画像選択';

  @override
  String get changeImage => '画像変更';

  @override
  String get titleLabel => 'タイトル';

  @override
  String get artistLabel => 'アーティスト名';

  @override
  String get albumLabel => 'アルバム';

  @override
  String get songUpdated => '曲情報を更新しました';

  @override
  String artworkSaveFailed(String error) {
    return 'サムネイル保存エラー: $error';
  }

  @override
  String get metadataSaved => 'メタデータを保存しました';

  @override
  String get categoryDetailPlay => '再生';

  @override
  String get categoryDetailShuffle => 'シャッフル';

  @override
  String get settingsTitle => '設定';

  @override
  String get themeTitle => 'テーマ設定';

  @override
  String get textColor => '文字色';

  @override
  String get backgroundColor => '背景色';

  @override
  String get selectTextColor => '文字色を選択';

  @override
  String get selectBackgroundColor => '背景色を選択';

  @override
  String get backgroundImage => '背景画像を設定';

  @override
  String get notSet => '未設定';

  @override
  String get removeBackgroundImage => '背景画像を削除';

  @override
  String get adjustBackgroundImage => '背景画像を調整';

  @override
  String get adjustBackgroundImageDesc => 'タッチ操作で拡大縮小と位置調整ができます';

  @override
  String get cropThumbnail => 'サムネイルをトリミング';

  @override
  String get adjustThumbnail => 'サムネイル調整';

  @override
  String get backgroundOpacity => '背景画像の透明率';

  @override
  String get backgroundBlur => '背景画像のぼかし';

  @override
  String get language => '表示言語';

  @override
  String get selectLanguage => '表示言語を選択';

  @override
  String get languageSystem => 'システム設定言語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageChineseSimplified => '中国語（簡体）';

  @override
  String get languageChineseTraditional => '中国語（繁体）';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languagePortugueseBrazil => 'ポルトガル語（ブラジル）';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get lyricsDisplayTitle => '歌詞表示';

  @override
  String lyricsFontSize(String size) {
    return 'フォントサイズ: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return '表示行数（現在行含む）: $count';
  }

  @override
  String get showArtworkBackground => '背景にサムネイルを表示';

  @override
  String get showArtworkBackgroundDesc => '歌詞表示時、背景にアルバムジャケットを表示';

  @override
  String get playbackTitle => '再生設定';

  @override
  String get skipSilence => '無音スキップ';

  @override
  String get skipSilenceDesc => '曲の始まりと終わりの無音部分をスキップします';

  @override
  String silenceThreshold(int ms) {
    return 'スキップ閾値: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'ローカルファイル';

  @override
  String get importFiles => 'ファイルのインポート';

  @override
  String get importFolder => 'フォルダのインポート';

  @override
  String get importing => 'インポート進行中...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total件';
  }

  @override
  String get clearLibraryTitle => 'ライブラリをクリア';

  @override
  String get clearLibraryConfirm =>
      'ローカルの全てのファイルを削除します。\nこの操作は元に戻せません。\n本当に削除しますか？';

  @override
  String get libraryCleared => 'ライブラリをクリアしました';

  @override
  String get duplicateDetection => '重複検出';

  @override
  String get duplicateDetectionDesc => '古い方を削除';

  @override
  String get supportedFormatsTitle => '対応フォーマット';

  @override
  String get audioFormatsTitle => '音声フォーマット';

  @override
  String get lyricsFormatsTitle => '歌詞フォーマット';

  @override
  String get lyricsFormatsDesc => 'LRC (時間同期型歌詞ファイル)';

  @override
  String get supportedQualityTitle => '対応音質';

  @override
  String get supportedQualityDesc => 'ロスレス音質、Dolby Atmos空間オーディオ';

  @override
  String get lrcAdjustTitle => 'LRC調整';

  @override
  String get selectSong => '曲を選択';

  @override
  String offsetLabel(String value) {
    return 'オフセット: $value';
  }

  @override
  String get applyChanges => '変更を適用';

  @override
  String get restore => '元に戻す';

  @override
  String get previewTitle => 'プレビュー（先頭30行）';

  @override
  String get lrcFileNotFound => 'LRCファイルが見つかりません';

  @override
  String loadError(String error) {
    return '読み込みエラー: $error';
  }

  @override
  String get offset => 'オフセット';

  @override
  String get apply => '適用';

  @override
  String get reset => 'リセット';

  @override
  String get noLrcFileFound => 'LRCファイルがありません';

  @override
  String get upNext => '次に再生';

  @override
  String get close => '閉じる';

  @override
  String get queueIsEmpty => 'キューに曲がありません';

  @override
  String get selectASong => '曲を選択';

  @override
  String get play => '再生';

  @override
  String get applyChanges2 => '変更を適用';

  @override
  String get restore2 => '元に戻す';

  @override
  String get previewFirst30Lines => 'プレビュー（先頭30行）';

  @override
  String get customColor => 'カスタムカラー';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get followSystemSetting => 'システム設定言語';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get change => '変更';

  @override
  String get selectLanguage2 => '言語を選択';

  @override
  String get confirm => '確認';

  @override
  String get execute => '実行';

  @override
  String get noData => 'データがありません';

  @override
  String get error => 'エラー';

  @override
  String get delete => '削除';

  @override
  String get search => '検索';

  @override
  String get artist => 'アーティスト';

  @override
  String get tracks => '曲';

  @override
  String get albums => 'アルバム';

  @override
  String get createPlaylist2 => 'プレイリストを作成';

  @override
  String get playpause => '再生/一時停止';

  @override
  String get next => '次へ';

  @override
  String get previous => '前へ';

  @override
  String get collection => 'コレクション';

  @override
  String get artistTrackAlbum => 'アーティスト、曲名、アルバム';

  @override
  String get welcome => 'ようこそ';

  @override
  String get getStarted => '始める';

  @override
  String get showDebugInfo => 'デバッグ情報を表示';

  @override
  String get clear => 'クリア';

  @override
  String get clearCache => 'キャッシュをクリア';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get switchTheme => 'テーマを切り替え';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get system => 'システム';

  @override
  String get play2 => 'プレイ';

  @override
  String get playQueue => '再生キュー';

  @override
  String get remove => '削除';

  @override
  String get migrateSettingsFromOlderVersions => '以前のバージョンからの設定を移行します';

  @override
  String get tracks2 => '曲数';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String get loading => '読み込み中...';

  @override
  String get offlineMode => 'オフラインモード';

  @override
  String get downloaded => 'ダウンロード済み';

  @override
  String get youtube => 'YouTube音声抽出';

  @override
  String get youtubeurl => 'クリップボードにYouTubeのURLが見つかりません';

  @override
  String get youtube2 => 'YouTubeから音声ファイル化';

  @override
  String get k320Kbps => '320 kbps';

  @override
  String get k441Khz => '44.1 kHz';

  @override
  String get mp3M4aFlacWavAiff => 'MP3, M4A, FLAC, WAV, AIFF';

  @override
  String get noLyrics => '歌詞はありません';

  @override
  String get playbackSpeed => '再生速度';

  @override
  String get loadingLyrics => '歌詞を読み込み中...';

  @override
  String get backgroundCustomize => '背景カスタマイズ';

  @override
  String get selectImageFirst => '先に画像を選択してください';

  @override
  String get backgroundSet => '壁紙を設定しました';

  @override
  String get backgroundSetFailed => '壁紙の設定に失敗しました';

  @override
  String get thumbnailPreview => 'サムネイルをプレビュー';

  @override
  String get lossless => 'ロスレス';

  @override
  String get audioConversionConfirm => '音声ファイル化の確認';

  @override
  String get confirmDownloadAudioFromVideo => 'この動画から音声をダウンロードしますか？';

  @override
  String get download => 'ダウンロード';

  @override
  String get videotitle => '「\$videoTitle」のダウンロードを開始しました...';

  @override
  String get videotitle2 => '「\$videoTitle」のダウンロードが完了しました！';

  @override
  String get videotitle3 => '「\$videoTitle」のダウンロードに失敗しました';

  @override
  String get downloadCompletedFileNotFound => 'ダウンロードは完了しましたが、ファイルが見つかりません';

  @override
  String get downloadCompletedPathUnknown => 'ダウンロードは完了しましたが、ファイルパスが不明です';

  @override
  String get clipboardEmpty => 'クリップボードが空です';

  @override
  String get outputformat => '出力形式: \$outputFormat';

  @override
  String get selectOutputFormat => '出力形式を選択';

  @override
  String get bitrate => 'ビットレート';

  @override
  String get samplingRate => 'サンプリングレート';

  @override
  String e(String e) {
    return 'エラー: \$e';
  }

  @override
  String m123(String e) {
    return 'クロップに失敗しました: \$e';
  }

  @override
  String channelname(String channelName) {
    return 'チャンネル: \$channelName';
  }

  @override
  String error4(String error) {
    return 'ダウンロードエラー: \$error';
  }

  @override
  String get import => 'インポート';

  @override
  String get export => 'エクスポート';

  @override
  String get nowPlaying => '現在再生中';

  @override
  String param(Object processed, Object total) {
    return '$processed/$total件';
  }

  @override
  String get nowPlaying2 => 'Now Playing';

  @override
  String get noSongPlaying => 'No song playing';

  @override
  String get dolbyAtmos => 'Dolby Atmos';

  @override
  String get k075 => '0.75×';

  @override
  String get k09 => '0.9×';

  @override
  String get k10 => '1.0×';

  @override
  String get k11 => '1.1×';

  @override
  String get k125 => '1.25×';

  @override
  String get k15 => '1.5×';

  @override
  String get k20 => '2.0×';
}
