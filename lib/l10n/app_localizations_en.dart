// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonPlay => 'Play';

  @override
  String get commonShuffle => 'Shuffle';

  @override
  String get commonSearch => 'Search';

  @override
  String get commonSort => 'Sort';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonSaveChanges => 'Save';

  @override
  String get tabSongs => 'Songs';

  @override
  String get tabArtists => 'Artists';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabPlaylists => 'Playlists';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerEditCategories => 'Edit categories';

  @override
  String get drawerSort => 'Sort';

  @override
  String get libraryLoadFailed => 'Failed to load library';

  @override
  String get libraryReload => 'Reload';

  @override
  String get errorDetailsTitle => 'Error details';

  @override
  String get errorClose => 'Close';

  @override
  String get searchHint => 'Song, artist, or album';

  @override
  String get categoryEditTitle => 'Edit categories';

  @override
  String get categorySongs => 'Songs';

  @override
  String get categoryArtists => 'Artists';

  @override
  String get categoryAlbums => 'Albums';

  @override
  String get categoryPlaylists => 'Playlists';

  @override
  String get sortTitleAsc => 'Title (A-Z)';

  @override
  String get sortTitleDesc => 'Title (Z-A)';

  @override
  String get sortArtistAsc => 'Artist (A-Z)';

  @override
  String get sortArtistDesc => 'Artist (Z-A)';

  @override
  String get sortDurationAsc => 'Duration (shorter)';

  @override
  String get sortDurationDesc => 'Duration (longer)';

  @override
  String get noSongs => 'No songs';

  @override
  String get noArtists => 'No artists';

  @override
  String get noAlbums => 'No albums';

  @override
  String get noPlaylists => 'No playlists';

  @override
  String get noResults => 'No results';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
      zero: '0 songs',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count songs',
      one: '1 song',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchPrompt => 'Search by song, artist, or album';

  @override
  String get sectionSongs => 'Songs';

  @override
  String get sectionArtists => 'Artists';

  @override
  String get sectionAlbums => 'Albums';

  @override
  String get sectionPlaylists => 'Playlists';

  @override
  String get queueUpNext => 'Up Next';

  @override
  String get queueEmpty => 'Queue is empty';

  @override
  String removedFromQueue(String songName) {
    return 'Removed \"$songName\" from queue';
  }

  @override
  String get playNext => 'Play Next';

  @override
  String addedPlayNext(String songName) {
    return 'Added \"$songName\" to Play Next';
  }

  @override
  String get addedToQueue => 'Added to queue';

  @override
  String get addToPlaylist => 'Add to playlist';

  @override
  String get addToPlaylistTitle => 'Add to playlist';

  @override
  String get createNewPlaylist => 'Create new playlist';

  @override
  String get existingPlaylists => 'Existing playlists';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get playlistNameHint => 'Enter playlist name';

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get editLyrics => 'Edit lyrics';

  @override
  String get editLyricsLrc => 'Edit lyrics (LRC)';

  @override
  String get editManually => 'Edit manually';

  @override
  String get adjustTiming => 'Adjust timing';

  @override
  String get lyricsFileNotFound => 'Lyrics file not found';

  @override
  String get lyricsNoDestination => 'No destination for lyrics file';

  @override
  String get lyricsSaved => 'Lyrics saved';

  @override
  String lyricsSaveFailed(String error) {
    return 'Failed to save lyrics: $error';
  }

  @override
  String get lrcHint => '[00:12.34]Lyrics text';

  @override
  String get editSongInfo => 'Edit song info';

  @override
  String get artworkLabel => 'Artwork';

  @override
  String get selectImage => 'Select image';

  @override
  String get changeImage => 'Change image';

  @override
  String get titleLabel => 'Title';

  @override
  String get artistLabel => 'Artist';

  @override
  String get albumLabel => 'Album';

  @override
  String get songUpdated => 'Song updated';

  @override
  String artworkSaveFailed(String error) {
    return 'Failed to save artwork: $error';
  }

  @override
  String get metadataSaved => 'Metadata saved';

  @override
  String get categoryDetailPlay => 'Play';

  @override
  String get categoryDetailShuffle => 'Shuffle';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeTitle => 'Theme';

  @override
  String get textColor => 'Text color';

  @override
  String get backgroundColor => 'Background color';

  @override
  String get selectTextColor => 'Select text color';

  @override
  String get selectBackgroundColor => 'Select background color';

  @override
  String get backgroundImage => 'Background image';

  @override
  String get notSet => 'Not set';

  @override
  String get removeBackgroundImage => 'Remove background image';

  @override
  String get adjustBackgroundImage => 'Adjust background image';

  @override
  String get adjustBackgroundImageDesc => 'Pinch to zoom and move';

  @override
  String get cropThumbnail => 'Crop Thumbnail';

  @override
  String get adjustThumbnail => 'Adjust Thumbnail';

  @override
  String get backgroundOpacity => 'Opacity';

  @override
  String get backgroundBlur => 'Blur';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get languageSystem => 'System language';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageGerman => 'German';

  @override
  String get languageFrench => 'French';

  @override
  String get languageChineseSimplified => 'Chinese (Simplified)';

  @override
  String get languageChineseTraditional => 'Chinese (Traditional)';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languagePortugueseBrazil => 'Portuguese (Brazil)';

  @override
  String get languageRussian => 'Russian';

  @override
  String get lyricsDisplayTitle => 'Lyrics display';

  @override
  String lyricsFontSize(String size) {
    return 'Font size: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Lines to show (including current): $count';
  }

  @override
  String get showArtworkBackground => 'Show artwork in background';

  @override
  String get showArtworkBackgroundDesc => 'Show album artwork behind lyrics';

  @override
  String get playbackTitle => 'Playback';

  @override
  String get skipSilence => 'Skip silence';

  @override
  String get skipSilenceDesc => 'Skip silent parts at start/end';

  @override
  String silenceThreshold(int ms) {
    return 'Threshold: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Local files';

  @override
  String get importFiles => 'Import files';

  @override
  String get importFolder => 'Import folder';

  @override
  String get importing => 'Importing...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Clear library';

  @override
  String get clearLibraryConfirm =>
      'All local files will be removed.\nThis action cannot be undone.\nAre you sure?';

  @override
  String get libraryCleared => 'Library cleared';

  @override
  String get duplicateDetection => 'Duplicate detection';

  @override
  String get duplicateDetectionDesc => 'Remove older files';

  @override
  String get supportedFormatsTitle => 'Supported formats';

  @override
  String get audioFormatsTitle => 'Audio formats';

  @override
  String get lyricsFormatsTitle => 'Lyrics format';

  @override
  String get lyricsFormatsDesc => 'LRC (time-synced lyrics)';

  @override
  String get supportedQualityTitle => 'Supported quality';

  @override
  String get supportedQualityDesc => 'Lossless, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'LRC adjust';

  @override
  String get selectSong => 'Select a song';

  @override
  String offsetLabel(String value) {
    return 'Offset: $value';
  }

  @override
  String get applyChanges => 'Apply changes';

  @override
  String get restore => 'Restore';

  @override
  String get previewTitle => 'Preview (first 30 lines)';

  @override
  String get lrcFileNotFound => 'LRC file not found';

  @override
  String loadError(String error) {
    return 'Load error: $error';
  }

  @override
  String get offset => 'Offset';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get noLrcFileFound => 'No LRC file found';

  @override
  String get upNext => 'Up Next';

  @override
  String get close => 'Close';

  @override
  String get queueIsEmpty => 'Queue is empty';

  @override
  String get selectASong => 'Select a song';

  @override
  String get play => 'Play';

  @override
  String get applyChanges2 => 'Apply changes';

  @override
  String get restore2 => 'Restore';

  @override
  String get previewFirst30Lines => 'Preview (first 30 lines)';

  @override
  String get customColor => 'Custom color';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystemSetting => 'System language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get change => 'Change';

  @override
  String get selectLanguage2 => 'Select language';

  @override
  String get confirm => 'Confirm';

  @override
  String get execute => 'Execute';

  @override
  String get noData => 'No data';

  @override
  String get error => 'Error';

  @override
  String get delete => 'Delete';

  @override
  String get search => 'Search';

  @override
  String get artist => 'Artist';

  @override
  String get tracks => 'Tracks';

  @override
  String get albums => 'Albums';

  @override
  String get createPlaylist2 => 'Create playlist';

  @override
  String get playpause => 'Play/Pause';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get collection => 'Collection';

  @override
  String get artistTrackAlbum => 'Artist, track, album';

  @override
  String get welcome => 'Welcome';

  @override
  String get getStarted => 'Get started';

  @override
  String get showDebugInfo => 'Show debug info';

  @override
  String get clear => 'Clear';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get switchTheme => 'Switch theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get play2 => 'Play';

  @override
  String get playQueue => 'Play queue';

  @override
  String get remove => 'Remove';

  @override
  String get migrateSettingsFromOlderVersions =>
      'Migrate settings from older versions';

  @override
  String get tracks2 => 'Tracks';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get loading => 'Loading...';

  @override
  String get offlineMode => 'Offline mode';

  @override
  String get downloaded => 'Downloaded';

  @override
  String get youtube => 'YouTube audio extraction';

  @override
  String get youtubeurl => 'No YouTube URL found in clipboard';

  @override
  String get youtube2 => 'Convert from YouTube to audio file';

  @override
  String get k320Kbps => '320 kbps';

  @override
  String get k441Khz => '44.1 kHz';

  @override
  String get mp3M4aFlacWavAiff => 'MP3, M4A, FLAC, WAV, AIFF';

  @override
  String get noLyrics => 'No lyrics';

  @override
  String get playbackSpeed => 'Playback speed';

  @override
  String get loadingLyrics => 'Loading lyrics...';

  @override
  String get backgroundCustomize => 'Background customize';

  @override
  String get selectImageFirst => 'Please select an image first';

  @override
  String get backgroundSet => 'Background set';

  @override
  String get backgroundSetFailed => 'Failed to set background';

  @override
  String get thumbnailPreview => 'Preview thumbnail';

  @override
  String get lossless => 'Lossless';

  @override
  String get audioConversionConfirm => 'Confirm audio conversion';

  @override
  String get confirmDownloadAudioFromVideo => 'Download audio from this video?';

  @override
  String get download => 'Download';

  @override
  String get videotitle => 'Started downloading \"\$videoTitle\"...';

  @override
  String get videotitle2 => 'Finished downloading \"\$videoTitle\"!';

  @override
  String get videotitle3 => 'Failed to download \"\$videoTitle\"';

  @override
  String get downloadCompletedFileNotFound =>
      'Download completed but file not found';

  @override
  String get downloadCompletedPathUnknown =>
      'Download completed but file path unknown';

  @override
  String get clipboardEmpty => 'Clipboard is empty';

  @override
  String get outputformat => 'Output format';

  @override
  String get selectOutputFormat => 'Select output format';

  @override
  String get bitrate => 'Bitrate';

  @override
  String get samplingRate => 'Sampling rate';

  @override
  String e(String e) {
    return 'Error: \$e';
  }

  @override
  String m123(String e) {
    return 'Crop failed: \$e';
  }

  @override
  String channelname(String channelName) {
    return 'Channel: \$channelName';
  }

  @override
  String error4(String error) {
    return 'Download error: \$error';
  }

  @override
  String get import => 'Import';

  @override
  String get export => 'Export';

  @override
  String get nowPlaying => 'Now playing';

  @override
  String param(Object processed, Object total) {
    return '$processed/$total';
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

  @override
  String get exportToDownloadsDesc =>
      'Save to download folder with a new name.';

  @override
  String get exportLrcButton => 'Download LRC';

  @override
  String get exportAudioButton => 'Download audio';

  @override
  String exportLrcSuccess(String fileName) {
    return 'Downloaded $fileName';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return 'Downloaded $fileName';
  }

  @override
  String get exportLrcFailed => 'Failed to download LRC';

  @override
  String get exportAudioFailed => 'Failed to download audio';

  @override
  String get exportNoFile => 'No file';
}
