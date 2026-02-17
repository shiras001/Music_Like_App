// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDetails => 'Details';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonApply => 'Применить';

  @override
  String get commonReset => 'Сброс';

  @override
  String get commonPlay => 'Воспроизвести';

  @override
  String get commonShuffle => 'Перемешать';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get commonSort => 'Сортировать';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonSaveChanges => 'Сохранить';

  @override
  String get tabSongs => 'Песни';

  @override
  String get tabArtists => 'Исполнители';

  @override
  String get tabAlbums => 'Альбомы';

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
  String get backgroundColor => 'Цвет фона';

  @override
  String get selectTextColor => 'Выбрать цвет текста';

  @override
  String get selectBackgroundColor => 'Выбрать цвет фона';

  @override
  String get backgroundImage => 'Фоновое изображение';

  @override
  String get notSet => 'Не задано';

  @override
  String get removeBackgroundImage => 'Удалить фоновое изображение';

  @override
  String get adjustBackgroundImage => 'Настроить фоновое изображение';

  @override
  String get adjustBackgroundImageDesc => 'Щипок для увеличения и перемещения';

  @override
  String get cropThumbnail => 'Crop Thumbnail';

  @override
  String get adjustThumbnail => 'Adjust Thumbnail';

  @override
  String get backgroundOpacity => 'Непрозрачность';

  @override
  String get backgroundBlur => 'Размытие';

  @override
  String get language => 'Язык';

  @override
  String get selectLanguage => 'Выбрать язык';

  @override
  String get languageSystem => 'Язык системы';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageKorean => 'Корейский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageChineseSimplified => 'Китайский (упрощенный)';

  @override
  String get languageChineseTraditional => 'Китайский (традиционный)';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languagePortugueseBrazil => 'Португальский (Бразилия)';

  @override
  String get languageRussian => 'Русский';

  @override
  String get lyricsDisplayTitle => 'Отображение текста';

  @override
  String lyricsFontSize(String size) {
    return 'Размер шрифта: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Строк для показа (включая текущую): $count';
  }

  @override
  String get showArtworkBackground => 'Показывать обложку на фоне';

  @override
  String get showArtworkBackgroundDesc =>
      'Показывать обложку альбома за текстом';

  @override
  String get playbackTitle => 'Воспроизведение';

  @override
  String get skipSilence => 'Пропускать тишину';

  @override
  String get skipSilenceDesc => 'Пропускать тихие части в начале/конце';

  @override
  String silenceThreshold(int ms) {
    return 'Порог: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Локальные файлы';

  @override
  String get importFiles => 'Импортировать файлы';

  @override
  String get importFolder => 'Импортировать папку';

  @override
  String get importing => 'Импорт...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Очистить библиотеку';

  @override
  String get clearLibraryConfirm =>
      'Все локальные файлы будут удалены.\nЭто действие нельзя отменить.\nВы уверены?';

  @override
  String get libraryCleared => 'Библиотека очищена';

  @override
  String get duplicateDetection => 'Поиск дубликатов';

  @override
  String get duplicateDetectionDesc => 'Удалить старые файлы';

  @override
  String get supportedFormatsTitle => 'Поддерживаемые форматы';

  @override
  String get audioFormatsTitle => 'Аудиоформаты';

  @override
  String get lyricsFormatsTitle => 'Формат текста';

  @override
  String get lyricsFormatsDesc => 'LRC (синхронизированный текст)';

  @override
  String get supportedQualityTitle => 'Поддерживаемое качество';

  @override
  String get supportedQualityDesc => 'Lossless, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'Настройка LRC';

  @override
  String get selectSong => 'Выбрать песню';

  @override
  String offsetLabel(String value) {
    return 'Смещение: $value';
  }

  @override
  String get applyChanges => 'Применить изменения';

  @override
  String get restore => 'Восстановить';

  @override
  String get previewTitle => 'Предпросмотр (первые 30 строк)';

  @override
  String get lrcFileNotFound => 'Файл LRC не найден';

  @override
  String loadError(String error) {
    return 'Ошибка загрузки: $error';
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
  String get followSystemSetting => 'Язык системы';

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
  String get outputformat => 'Output format: \$outputFormat';

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
}
