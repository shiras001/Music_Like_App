// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonDetails => 'Detalles';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get commonPlay => 'Reproducir';

  @override
  String get commonShuffle => 'Aleatorio';

  @override
  String get commonSearch => 'Buscar';

  @override
  String get commonSort => 'Ordenar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonSaveChanges => 'Guardar';

  @override
  String get tabSongs => 'Canciones';

  @override
  String get tabArtists => 'Artistas';

  @override
  String get tabAlbums => 'Álbumes';

  @override
  String get tabPlaylists => 'Listas';

  @override
  String get drawerSettings => 'Configuración';

  @override
  String get drawerEditCategories => 'Editar categorías';

  @override
  String get drawerSort => 'Ordenar';

  @override
  String get libraryLoadFailed => 'No se pudo cargar la biblioteca';

  @override
  String get libraryReload => 'Recargar';

  @override
  String get errorDetailsTitle => 'Detalles del error';

  @override
  String get errorClose => 'Cerrar';

  @override
  String get searchHint => 'Canción, artista o álbum';

  @override
  String get categoryEditTitle => 'Editar categorías';

  @override
  String get categorySongs => 'Canciones';

  @override
  String get categoryArtists => 'Artistas';

  @override
  String get categoryAlbums => 'Álbumes';

  @override
  String get categoryPlaylists => 'Listas';

  @override
  String get sortTitleAsc => 'Título (A-Z)';

  @override
  String get sortTitleDesc => 'Título (Z-A)';

  @override
  String get sortArtistAsc => 'Artista (A-Z)';

  @override
  String get sortArtistDesc => 'Artista (Z-A)';

  @override
  String get sortDurationAsc => 'Duración (más corta)';

  @override
  String get sortDurationDesc => 'Duración (más larga)';

  @override
  String get noSongs => 'No hay canciones';

  @override
  String get noArtists => 'No hay artistas';

  @override
  String get noAlbums => 'No hay álbumes';

  @override
  String get noPlaylists => 'No hay listas';

  @override
  String get noResults => 'Sin resultados';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
      zero: '0 canciones',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count canciones',
      one: '1 canción',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => 'Búsqueda';

  @override
  String get searchPrompt => 'Buscar por canción, artista o álbum';

  @override
  String get sectionSongs => 'Canciones';

  @override
  String get sectionArtists => 'Artistas';

  @override
  String get sectionAlbums => 'Álbumes';

  @override
  String get sectionPlaylists => 'Listas';

  @override
  String get queueUpNext => 'Siguiente';

  @override
  String get queueEmpty => 'La cola está vacía';

  @override
  String removedFromQueue(String songName) {
    return 'Eliminado \"$songName\" de la cola';
  }

  @override
  String get playNext => 'Reproducir después';

  @override
  String addedPlayNext(String songName) {
    return 'Añadido \"$songName\" a Reproducir después';
  }

  @override
  String get addedToQueue => 'Añadido a la cola';

  @override
  String get addToPlaylist => 'Agregar a la lista';

  @override
  String get addToPlaylistTitle => 'Agregar a la lista';

  @override
  String get createNewPlaylist => 'Crear nueva lista';

  @override
  String get existingPlaylists => 'Listas existentes';

  @override
  String get createPlaylist => 'Crear lista';

  @override
  String get playlistNameHint => 'Ingrese el nombre de la lista';

  @override
  String get playlistCreated => 'Lista creada';

  @override
  String get addedToPlaylist => 'Añadido a la lista';

  @override
  String get editLyrics => 'Editar letra';

  @override
  String get editLyricsLrc => 'Editar letra (LRC)';

  @override
  String get editManually => 'Editar manualmente';

  @override
  String get adjustTiming => 'Ajustar sincronización';

  @override
  String get lyricsFileNotFound => 'Archivo de letra no encontrado';

  @override
  String get lyricsNoDestination => 'No hay destino para el archivo de letras';

  @override
  String get lyricsSaved => 'Letra guardada';

  @override
  String lyricsSaveFailed(String error) {
    return 'Error al guardar la letra: $error';
  }

  @override
  String get lrcHint => '[00:12.34]Texto de la letra';

  @override
  String get editSongInfo => 'Editar información de la canción';

  @override
  String get artworkLabel => 'Carátula';

  @override
  String get selectImage => 'Seleccionar imagen';

  @override
  String get changeImage => 'Cambiar imagen';

  @override
  String get titleLabel => 'Título';

  @override
  String get artistLabel => 'Artista';

  @override
  String get albumLabel => 'Álbum';

  @override
  String get songUpdated => 'Canción actualizada';

  @override
  String artworkSaveFailed(String error) {
    return 'Error al guardar la carátula: $error';
  }

  @override
  String get metadataSaved => 'Metadatos guardados';

  @override
  String get categoryDetailPlay => 'Reproducir';

  @override
  String get categoryDetailShuffle => 'Aleatorio';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get themeTitle => 'Tema';

  @override
  String get textColor => 'Color del texto';

  @override
  String get backgroundColor => 'Color de fondo';

  @override
  String get selectTextColor => 'Seleccionar color de texto';

  @override
  String get selectBackgroundColor => 'Seleccionar color de fondo';

  @override
  String get backgroundImage => 'Imagen de fondo';

  @override
  String get notSet => 'No establecido';

  @override
  String get removeBackgroundImage => 'Eliminar imagen de fondo';

  @override
  String get adjustBackgroundImage => 'Ajustar imagen de fondo';

  @override
  String get adjustBackgroundImageDesc => ' pellizcar para acercar y mover';

  @override
  String get cropThumbnail => 'Recortar miniatura';

  @override
  String get adjustThumbnail => 'Ajustar miniatura';

  @override
  String get backgroundOpacity => 'Opacidad';

  @override
  String get backgroundBlur => 'Desenfoque';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Seleccionar idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageJapanese => 'Japonés';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languageChineseSimplified => 'Chino (simplificado)';

  @override
  String get languageChineseTraditional => 'Chino (tradicional)';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languagePortugueseBrazil => 'Portugués (Brasil)';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get lyricsDisplayTitle => 'Mostrar letra';

  @override
  String lyricsFontSize(String size) {
    return 'Tamaño de fuente: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Líneas a mostrar (incluida la actual): $count';
  }

  @override
  String get showArtworkBackground => 'Mostrar carátula de fondo';

  @override
  String get showArtworkBackgroundDesc =>
      'Mostrar la carátula detrás de la letra';

  @override
  String get playbackTitle => 'Reproducción';

  @override
  String get skipSilence => 'Saltar silencio';

  @override
  String get skipSilenceDesc => 'Saltar partes silenciosas al inicio/final';

  @override
  String silenceThreshold(int ms) {
    return 'Umbral: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Archivos locales';

  @override
  String get importFiles => 'Importar archivos';

  @override
  String get importFolder => 'Importar carpeta';

  @override
  String get importing => 'Importando...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Limpiar biblioteca';

  @override
  String get clearLibraryConfirm =>
      'Se eliminarán todos los archivos locales.\nEsta acción no se puede deshacer.\n¿Estás seguro?';

  @override
  String get libraryCleared => 'Biblioteca limpiada';

  @override
  String get duplicateDetection => 'Detección de duplicados';

  @override
  String get duplicateDetectionDesc => 'Eliminar archivos más antiguos';

  @override
  String get supportedFormatsTitle => 'Formatos compatibles';

  @override
  String get audioFormatsTitle => 'Formatos de audio';

  @override
  String get lyricsFormatsTitle => 'Formatos de letra';

  @override
  String get lyricsFormatsDesc => 'LRC (letras sincronizadas)';

  @override
  String get supportedQualityTitle => 'Calidad compatible';

  @override
  String get supportedQualityDesc => 'Lossless, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'Ajuste LRC';

  @override
  String get selectSong => 'Seleccionar una canción';

  @override
  String offsetLabel(String value) {
    return 'Desplazamiento: $value';
  }

  @override
  String get applyChanges => 'Aplicar cambios';

  @override
  String get restore => 'Restaurar';

  @override
  String get previewTitle => 'Vista previa (primeras 30 líneas)';

  @override
  String get lrcFileNotFound => 'Archivo LRC no encontrado';

  @override
  String loadError(String error) {
    return 'Error de carga: $error';
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
  String get followSystemSetting => 'Idioma del sistema';

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
}
