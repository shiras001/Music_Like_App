// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonDetails => 'Einzelheiten';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonApply => 'Anwenden';

  @override
  String get commonReset => 'Zurücksetzen';

  @override
  String get commonPlay => 'Abspielen';

  @override
  String get commonShuffle => 'Zufällig';

  @override
  String get commonSearch => 'Suchen';

  @override
  String get commonSort => 'Sortieren';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonSaveChanges => 'Änderungen speichern';

  @override
  String get tabSongs => 'Titel';

  @override
  String get tabArtists => 'Interpreten';

  @override
  String get tabAlbums => 'Alben';

  @override
  String get tabPlaylists => 'Wiedergabelisten';

  @override
  String get drawerSettings => 'Einstellungen';

  @override
  String get drawerEditCategories => 'Kategorien bearbeiten';

  @override
  String get drawerSort => 'Sortieren';

  @override
  String get libraryLoadFailed => 'Bibliothek konnte nicht geladen werden';

  @override
  String get libraryReload => 'Neu laden';

  @override
  String get errorDetailsTitle => 'Fehlerdetails';

  @override
  String get errorClose => 'Schließen';

  @override
  String get searchHint => 'Titel, Interpret oder Album';

  @override
  String get categoryEditTitle => 'Kategorien bearbeiten';

  @override
  String get categorySongs => 'Titel';

  @override
  String get categoryArtists => 'Interpreten';

  @override
  String get categoryAlbums => 'Alben';

  @override
  String get categoryPlaylists => 'Playlisten';

  @override
  String get sortTitleAsc => 'Titel (A-Z)';

  @override
  String get sortTitleDesc => 'Titel (Z-A)';

  @override
  String get sortArtistAsc => 'Interpret (A-Z)';

  @override
  String get sortArtistDesc => 'Interpret (Z-A)';

  @override
  String get sortDurationAsc => 'Dauer (kurzer)';

  @override
  String get sortDurationDesc => 'Dauer (länger)';

  @override
  String get noSongs => 'Keine Songs';

  @override
  String get noArtists => 'Keine Interpreten';

  @override
  String get noAlbums => 'Keine Alben';

  @override
  String get noPlaylists => 'Keine Playlists';

  @override
  String get noResults => 'Keine Ergebnisse';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
      zero: '0 Titel',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Titel',
      one: '1 Titel',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => 'Suchen';

  @override
  String get searchPrompt => 'Nach Titel, Interpret oder Album suchen';

  @override
  String get sectionSongs => 'Titel';

  @override
  String get sectionArtists => 'Interpreten';

  @override
  String get sectionAlbums => 'Alben';

  @override
  String get sectionPlaylists => 'Playlisten';

  @override
  String get queueUpNext => 'Als Nächstes';

  @override
  String get queueEmpty => 'Warteschlange ist leer';

  @override
  String removedFromQueue(String songName) {
    return '\"$songName\" aus der Warteschlange entfernt';
  }

  @override
  String get playNext => 'Als Nächstes abspielen';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\" zu Als Nächstes hinzugefügt';
  }

  @override
  String get addedToQueue => 'Zur Warteschlange hinzugefügt';

  @override
  String get addToPlaylist => 'Zur Playlist hinzufügen';

  @override
  String get addToPlaylistTitle => 'Zur Playlist hinzufügen';

  @override
  String get createNewPlaylist => 'Neue Playlist erstellen';

  @override
  String get existingPlaylists => 'Vorhandene Playlists';

  @override
  String get createPlaylist => 'Playlist erstellen';

  @override
  String get playlistNameHint => 'Playlist-Namen eingeben';

  @override
  String get playlistCreated => 'Playlist erstellt';

  @override
  String get addedToPlaylist => 'Zur Playlist hinzugefügt';

  @override
  String get editLyrics => 'Text bearbeiten';

  @override
  String get editLyricsLrc => 'Text bearbeiten (LRC)';

  @override
  String get editManually => 'Manuell bearbeiten';

  @override
  String get adjustTiming => 'Timing anpassen';

  @override
  String get lyricsFileNotFound => 'Textdatei nicht gefunden';

  @override
  String get lyricsNoDestination => 'Kein Speicherort für Textdatei';

  @override
  String get lyricsSaved => 'Text gespeichert';

  @override
  String lyricsSaveFailed(String error) {
    return 'Text konnte nicht gespeichert werden: $error';
  }

  @override
  String get lrcHint => '[00:12.34]Textzeile';

  @override
  String get editSongInfo => 'Titel-Info bearbeiten';

  @override
  String get artworkLabel => 'Cover';

  @override
  String get selectImage => 'Bild wählen';

  @override
  String get changeImage => 'Bild ändern';

  @override
  String get titleLabel => 'Titel';

  @override
  String get artistLabel => 'Interpret';

  @override
  String get albumLabel => 'Albumtitel (Name)';

  @override
  String get songUpdated => 'Titel aktualisiert';

  @override
  String artworkSaveFailed(String error) {
    return 'Cover konnte nicht gespeichert werden: $error';
  }

  @override
  String get metadataSaved => 'Metadaten gespeichert';

  @override
  String get categoryDetailPlay => 'Abspielen';

  @override
  String get categoryDetailShuffle => 'Zufällig';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeTitle => 'Design';

  @override
  String get textColor => 'Textfarbe';

  @override
  String get backgroundColor => 'Hintergrundfarbe';

  @override
  String get selectTextColor => 'Textfarbe auswählen';

  @override
  String get selectBackgroundColor => 'Hintergrundfarbe auswählen';

  @override
  String get backgroundImage => 'Hintergrundbild';

  @override
  String get notSet => 'Nicht gesetzt';

  @override
  String get removeBackgroundImage => 'Hintergrundbild entfernen';

  @override
  String get adjustBackgroundImage => 'Hintergrundbild anpassen';

  @override
  String get adjustBackgroundImageDesc => 'Zweifinger-Zoom und Verschieben';

  @override
  String get cropThumbnail => 'Thumbnail zuschneiden';

  @override
  String get adjustThumbnail => 'Thumbnail anpassen';

  @override
  String get backgroundOpacity => 'Deckkraft';

  @override
  String get backgroundBlur => 'Weichzeichnen';

  @override
  String get language => 'Sprache';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get languageSystem => 'Systemsprache';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageFrench => 'Französisch';

  @override
  String get languageChineseSimplified => 'Chinesisch (vereinfacht)';

  @override
  String get languageChineseTraditional => 'Chinesisch (traditionell)';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languagePortugueseBrazil => 'Portugiesisch (Brasilien)';

  @override
  String get languageRussian => 'Russisch';

  @override
  String get lyricsDisplayTitle => 'Textanzeige';

  @override
  String lyricsFontSize(String size) {
    return 'Schriftgröße: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Anzuzeigende Zeilen (inkl. aktueller): $count';
  }

  @override
  String get showArtworkBackground => 'Cover im Hintergrund anzeigen';

  @override
  String get showArtworkBackgroundDesc => 'Albumcover hinter dem Text anzeigen';

  @override
  String get playbackTitle => 'Wiedergabe';

  @override
  String get skipSilence => 'Stille überspringen';

  @override
  String get skipSilenceDesc => 'Stille am Anfang/Ende überspringen';

  @override
  String silenceThreshold(int ms) {
    return 'Schwelle: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Lokale Dateien';

  @override
  String get importFiles => 'Dateien importieren';

  @override
  String get importFolder => 'Ordner importieren';

  @override
  String get importing => 'Importiere...';

  @override
  String importCount(int processed, int total) {
    return 'Verarbeitet: $processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Bibliothek leeren';

  @override
  String get clearLibraryConfirm =>
      'Alle lokalen Dateien werden entfernt.\nDiese Aktion kann nicht rückgängig gemacht werden.\nFortfahren?';

  @override
  String get libraryCleared => 'Bibliothek geleert';

  @override
  String get duplicateDetection => 'Duplikaterkennung';

  @override
  String get duplicateDetectionDesc => 'Ältere Dateien entfernen';

  @override
  String get supportedFormatsTitle => 'Unterstützte Formate';

  @override
  String get audioFormatsTitle => 'Audioformate';

  @override
  String get lyricsFormatsTitle => 'Textformate';

  @override
  String get lyricsFormatsDesc => 'LRC (zeitlich synchronisierte Texte)';

  @override
  String get supportedQualityTitle => 'Unterstützte Qualität';

  @override
  String get supportedQualityDesc => 'Verlustfrei, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'LRC anpassen';

  @override
  String get selectSong => 'Titel auswählen';

  @override
  String offsetLabel(String value) {
    return 'Versatz: $value';
  }

  @override
  String get applyChanges => 'Änderungen anwenden';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get previewTitle => 'Vorschau (erste 30 Zeilen)';

  @override
  String get lrcFileNotFound => 'LRC-Datei nicht gefunden';

  @override
  String loadError(String error) {
    return 'Ladefehler: $error';
  }

  @override
  String get offset => 'Versatz';

  @override
  String get apply => 'Anwenden';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get noLrcFileFound => 'Keine LRC-Datei gefunden';

  @override
  String get upNext => 'Als Nächstes';

  @override
  String get close => 'Schließen';

  @override
  String get queueIsEmpty => 'Warteschlange ist leer';

  @override
  String get selectASong => 'Einen Titel auswählen';

  @override
  String get play => 'Abspielen';

  @override
  String get applyChanges2 => 'Änderungen anwenden';

  @override
  String get restore2 => 'Wiederherstellen';

  @override
  String get previewFirst30Lines => 'Vorschau (erste 30 Zeilen)';

  @override
  String get customColor => 'Benutzerdefinierte Farbe';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystemSetting => 'Systemsprache';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get change => 'Ändern';

  @override
  String get selectLanguage2 => 'Select language';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get execute => 'Ausführen';

  @override
  String get noData => 'Keine Daten';

  @override
  String get error => 'Fehler';

  @override
  String get delete => 'Löschen';

  @override
  String get search => 'Suchen';

  @override
  String get artist => 'Künstler';

  @override
  String get tracks => 'Titel';

  @override
  String get albums => 'Alben';

  @override
  String get createPlaylist2 => 'Playlist erstellen';

  @override
  String get playpause => 'Abspielen/Pause';

  @override
  String get next => 'Nächster';

  @override
  String get previous => 'Vorheriger';

  @override
  String get collection => 'Sammlung';

  @override
  String get artistTrackAlbum => 'Künstler, Titel, Album';

  @override
  String get welcome => 'Willkommen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get showDebugInfo => 'Debug-Informationen anzeigen';

  @override
  String get clear => 'Löschen';

  @override
  String get clearCache => 'Cache löschen';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get switchTheme => 'Design wechseln';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'Systemmodus';

  @override
  String get play2 => 'Abspielen';

  @override
  String get playQueue => 'Warteschlange abspielen';

  @override
  String get remove => 'Entfernen';

  @override
  String get migrateSettingsFromOlderVersions =>
      'Einstellungen aus älteren Versionen migrieren';

  @override
  String get tracks2 => 'Titel';

  @override
  String get anErrorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get loading => 'Wird geladen...';

  @override
  String get offlineMode => 'Offline-Modus';

  @override
  String get downloaded => 'Heruntergeladen';

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
  String get import => 'Importieren';

  @override
  String get export => 'Exportieren';

  @override
  String get nowPlaying => 'Wird abgespielt';

  @override
  String param(Object processed, Object total) {
    return 'Verarbeitet: $processed/$total';
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
      'Im Download-Ordner unter neuem Namen speichern.';

  @override
  String get exportLrcButton => 'LRC herunterladen';

  @override
  String get exportAudioButton => 'Audio herunterladen';

  @override
  String exportLrcSuccess(String fileName) {
    return '$fileName heruntergeladen';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '$fileName heruntergeladen';
  }

  @override
  String get exportLrcFailed => 'LRC-Download fehlgeschlagen';

  @override
  String get exportAudioFailed => 'Audio-Download fehlgeschlagen';

  @override
  String get exportNoFile => 'Keine Datei';
}
