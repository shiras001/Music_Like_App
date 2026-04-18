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
  String get commonDetails => 'Подробности';

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
  String get tabPlaylists => 'Плейлисты';

  @override
  String get drawerSettings => 'Настройки';

  @override
  String get drawerEditCategories => 'Редактировать категории';

  @override
  String get drawerSort => 'Сортировка';

  @override
  String get libraryLoadFailed => 'Failed to load library';

  @override
  String get libraryReload => 'Reload';

  @override
  String get errorDetailsTitle => 'Подробности ошибки';

  @override
  String get errorClose => 'Close';

  @override
  String get searchHint => 'Song, artist, or album';

  @override
  String get categoryEditTitle => 'Редактировать категории';

  @override
  String get categorySongs => 'Songs';

  @override
  String get categoryArtists => 'Artists';

  @override
  String get categoryAlbums => 'Albums';

  @override
  String get categoryPlaylists => 'Playlists';

  @override
  String get sortTitleAsc => 'Название (А-Я)';

  @override
  String get sortTitleDesc => 'Название (Я-А)';

  @override
  String get sortArtistAsc => 'Исполнитель (А-Я)';

  @override
  String get sortArtistDesc => 'Исполнитель (Я-А)';

  @override
  String get sortDurationAsc => 'Длительность (короче)';

  @override
  String get sortDurationDesc => 'Длительность (длиннее)';

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
    return '\"$songName\" удалено из очереди';
  }

  @override
  String get playNext => 'Играть следующим';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\" добавлено в «Играть следующим»';
  }

  @override
  String get addedToQueue => 'Добавлено в очередь';

  @override
  String get addToPlaylist => 'Добавить в плейлист';

  @override
  String get addToPlaylistTitle => 'Добавить в плейлист';

  @override
  String get createNewPlaylist => 'Создать новый плейлист';

  @override
  String get existingPlaylists => 'Существующие плейлисты';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get playlistNameHint => 'Enter playlist name';

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get editLyrics => 'Редактировать текст';

  @override
  String get editLyricsLrc => 'Редактировать текст (LRC)';

  @override
  String get editManually => 'Редактировать вручную';

  @override
  String get adjustTiming => 'Настроить синхронизацию';

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
  String get editSongInfo => 'Редактировать данные трека';

  @override
  String get artworkLabel => 'Обложка';

  @override
  String get selectImage => 'Выбрать изображение';

  @override
  String get changeImage => 'Изменить изображение';

  @override
  String get titleLabel => 'Название';

  @override
  String get artistLabel => 'Исполнитель';

  @override
  String get albumLabel => 'Альбом';

  @override
  String get songUpdated => 'Данные трека обновлены';

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
    return 'Обработано: $processed/$total';
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
  String get supportedQualityDesc => 'Без потерь, Dolby Atmos';

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
  String get offset => 'Смещение';

  @override
  String get apply => 'Применить';

  @override
  String get reset => 'Сброс';

  @override
  String get noLrcFileFound => 'Файл LRC не найден';

  @override
  String get upNext => 'Далее';

  @override
  String get close => 'Закрыть';

  @override
  String get queueIsEmpty => 'Очередь пуста';

  @override
  String get selectASong => 'Выбрать песню';

  @override
  String get play => 'Воспроизвести';

  @override
  String get applyChanges2 => 'Применить изменения';

  @override
  String get restore2 => 'Восстановить';

  @override
  String get previewFirst30Lines => 'Предпросмотр (первые 30 строк)';

  @override
  String get customColor => 'Пользовательский цвет';

  @override
  String get darkMode => 'Тёмный режим';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystemSetting => 'Язык системы';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get change => 'Изменить';

  @override
  String get selectLanguage2 => 'Select language';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get execute => 'Выполнить';

  @override
  String get noData => 'Нет данных';

  @override
  String get error => 'Ошибка';

  @override
  String get delete => 'Удалить';

  @override
  String get search => 'Поиск';

  @override
  String get artist => 'Исполнитель';

  @override
  String get tracks => 'Треки';

  @override
  String get albums => 'Альбомы';

  @override
  String get createPlaylist2 => 'Создать плейлист';

  @override
  String get playpause => 'Воспроизведение/Пауза';

  @override
  String get next => 'Следующий';

  @override
  String get previous => 'Предыдущий';

  @override
  String get collection => 'Коллекция';

  @override
  String get artistTrackAlbum => 'Исполнитель, трек, альбом';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get getStarted => 'Начать';

  @override
  String get showDebugInfo => 'Показать отладочную информацию';

  @override
  String get clear => 'Очистить';

  @override
  String get clearCache => 'Очистить кэш';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get switchTheme => 'Сменить тему';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Тёмная';

  @override
  String get system => 'Система';

  @override
  String get play2 => 'Воспроизвести';

  @override
  String get playQueue => 'Воспроизвести очередь';

  @override
  String get remove => 'Удалить';

  @override
  String get migrateSettingsFromOlderVersions =>
      'Миграция настроек из старых версий';

  @override
  String get tracks2 => 'Треки';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get loading => 'Загрузка...';

  @override
  String get offlineMode => 'Офлайн-режим';

  @override
  String get downloaded => 'Загружено';

  @override
  String get youtube => 'Извлечение аудио с YouTube';

  @override
  String get youtubeurl => 'URL YouTube в буфере обмена не найден';

  @override
  String get youtube2 => 'Конвертировать YouTube в аудиофайл';

  @override
  String get k320Kbps => '320 кбит/с';

  @override
  String get k441Khz => '44,1 кГц';

  @override
  String get mp3M4aFlacWavAiff => 'MP3 / M4A / FLAC / WAV / AIFF';

  @override
  String get noLyrics => 'Нет текста песни';

  @override
  String get playbackSpeed => 'Скорость воспроизведения';

  @override
  String get loadingLyrics => 'Загрузка текста песни...';

  @override
  String get backgroundCustomize => 'Настройка фона';

  @override
  String get selectImageFirst => 'Сначала выберите изображение';

  @override
  String get backgroundSet => 'Фон установлен';

  @override
  String get backgroundSetFailed => 'Не удалось установить фон';

  @override
  String get thumbnailPreview => 'Предпросмотр миниатюры';

  @override
  String get lossless => 'Без потерь';

  @override
  String get audioConversionConfirm => 'Подтвердите преобразование аудио';

  @override
  String get confirmDownloadAudioFromVideo => 'Скачать аудио из этого видео?';

  @override
  String get download => 'Скачать';

  @override
  String get videotitle => 'Начата загрузка \"\$videoTitle\"...';

  @override
  String get videotitle2 => 'Загрузка \"\$videoTitle\" завершена!';

  @override
  String get videotitle3 => 'Не удалось загрузить \"\$videoTitle\"';

  @override
  String get downloadCompletedFileNotFound =>
      'Загрузка завершена, но файл не найден';

  @override
  String get downloadCompletedPathUnknown =>
      'Загрузка завершена, но путь к файлу неизвестен';

  @override
  String get clipboardEmpty => 'Буфер обмена пуст';

  @override
  String get outputformat => 'Формат вывода: \$outputFormat';

  @override
  String get selectOutputFormat => 'Выберите формат вывода';

  @override
  String get bitrate => 'Битрейт';

  @override
  String get samplingRate => 'Частота дискретизации';

  @override
  String e(String e) {
    return 'Ошибка: \$e';
  }

  @override
  String m123(String e) {
    return 'Ошибка обрезки: \$e';
  }

  @override
  String channelname(String channelName) {
    return 'Канал: \$channelName';
  }

  @override
  String error4(String error) {
    return 'Ошибка загрузки: \$error';
  }

  @override
  String get import => 'Импорт';

  @override
  String get export => 'Экспорт';

  @override
  String get nowPlaying => 'Сейчас играет';

  @override
  String param(Object processed, Object total) {
    return 'Обработано: $processed/$total';
  }

  @override
  String get nowPlaying2 => 'Сейчас играет';

  @override
  String get noSongPlaying => 'Нет воспроизводимой композиции';

  @override
  String get dolbyAtmos => 'Dolby Atmos (пространственный звук)';

  @override
  String get k075 => '0,75×';

  @override
  String get k09 => '0,9×';

  @override
  String get k10 => '1,0×';

  @override
  String get k11 => '1,1×';

  @override
  String get k125 => '1,25×';

  @override
  String get k15 => '1,5×';

  @override
  String get k20 => '2,0×';

  @override
  String get exportToDownloadsDesc =>
      'Сохранить в папку загрузок под другим именем.';

  @override
  String get exportLrcButton => 'Скачать LRC';

  @override
  String get exportAudioButton => 'Скачать аудио';

  @override
  String exportLrcSuccess(String fileName) {
    return '$fileName загружено';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '$fileName загружено';
  }

  @override
  String get exportLrcFailed => 'Не удалось загрузить LRC';

  @override
  String get exportAudioFailed => 'Не удалось загрузить аудио';

  @override
  String get exportNoFile => 'Нет файла';
}
