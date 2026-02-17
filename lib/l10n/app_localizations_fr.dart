// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonDetails => 'Détails';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonApply => 'Appliquer';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get commonPlay => 'Lire';

  @override
  String get commonShuffle => 'Aléatoire';

  @override
  String get commonSearch => 'Rechercher';

  @override
  String get commonSort => 'Trier';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonSaveChanges => 'Enregistrer';

  @override
  String get tabSongs => 'Titres';

  @override
  String get tabArtists => 'Artistes';

  @override
  String get tabAlbums => 'Albums';

  @override
  String get tabPlaylists => 'Playlists';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerEditCategories => 'Modifier les catégories';

  @override
  String get drawerSort => 'Trier';

  @override
  String get libraryLoadFailed => 'Échec du chargement de la bibliothèque';

  @override
  String get libraryReload => 'Recharger';

  @override
  String get errorDetailsTitle => 'Détails de l\'erreur';

  @override
  String get errorClose => 'Fermer';

  @override
  String get searchHint => 'Titre, artiste ou album';

  @override
  String get categoryEditTitle => 'Modifier les catégories';

  @override
  String get categorySongs => 'Titres';

  @override
  String get categoryArtists => 'Artistes';

  @override
  String get categoryAlbums => 'Albums';

  @override
  String get categoryPlaylists => 'Playlists';

  @override
  String get sortTitleAsc => 'Titre (A-Z)';

  @override
  String get sortTitleDesc => 'Titre (Z-A)';

  @override
  String get sortArtistAsc => 'Artiste (A-Z)';

  @override
  String get sortArtistDesc => 'Artiste (Z-A)';

  @override
  String get sortDurationAsc => 'Durée (plus court)';

  @override
  String get sortDurationDesc => 'Durée (plus long)';

  @override
  String get noSongs => 'Aucun titre';

  @override
  String get noArtists => 'Aucun artiste';

  @override
  String get noAlbums => 'Aucun album';

  @override
  String get noPlaylists => 'Aucune playlist';

  @override
  String get noResults => 'Aucun résultat';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '1 titre',
      zero: '0 titres',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count titres',
      one: '1 titre',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchPrompt => 'Rechercher par titre, artiste ou album';

  @override
  String get sectionSongs => 'Titres';

  @override
  String get sectionArtists => 'Artistes';

  @override
  String get sectionAlbums => 'Albums';

  @override
  String get sectionPlaylists => 'Playlists';

  @override
  String get queueUpNext => 'À suivre';

  @override
  String get queueEmpty => 'La file d\'attente est vide';

  @override
  String removedFromQueue(String songName) {
    return 'Suppression de \"$songName\" de la file';
  }

  @override
  String get playNext => 'Jouer ensuite';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\" ajouté à Jouer ensuite';
  }

  @override
  String get addedToQueue => 'Ajouté à la file';

  @override
  String get addToPlaylist => 'Ajouter à la playlist';

  @override
  String get addToPlaylistTitle => 'Ajouter à la playlist';

  @override
  String get createNewPlaylist => 'Créer une nouvelle playlist';

  @override
  String get existingPlaylists => 'Playlists existantes';

  @override
  String get createPlaylist => 'Créer une playlist';

  @override
  String get playlistNameHint => 'Entrez le nom de la playlist';

  @override
  String get playlistCreated => 'Playlist créée';

  @override
  String get addedToPlaylist => 'Ajouté à la playlist';

  @override
  String get editLyrics => 'Modifier les paroles';

  @override
  String get editLyricsLrc => 'Modifier les paroles (LRC)';

  @override
  String get editManually => 'Modifier manuellement';

  @override
  String get adjustTiming => 'Ajuster le timing';

  @override
  String get lyricsFileNotFound => 'Fichier de paroles introuvable';

  @override
  String get lyricsNoDestination =>
      'Aucun emplacement de destination pour le fichier de paroles';

  @override
  String get lyricsSaved => 'Paroles enregistrées';

  @override
  String lyricsSaveFailed(String error) {
    return 'Échec de l\'enregistrement des paroles : $error';
  }

  @override
  String get lrcHint => '[00:12.34]Texte des paroles';

  @override
  String get editSongInfo => 'Modifier les informations du titre';

  @override
  String get artworkLabel => 'Pochette';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get changeImage => 'Changer l\'image';

  @override
  String get titleLabel => 'Titre';

  @override
  String get artistLabel => 'Artiste';

  @override
  String get albumLabel => 'Album';

  @override
  String get songUpdated => 'Titre mis à jour';

  @override
  String artworkSaveFailed(String error) {
    return 'Échec de l\'enregistrement de la pochette : $error';
  }

  @override
  String get metadataSaved => 'Métadonnées enregistrées';

  @override
  String get categoryDetailPlay => 'Lire';

  @override
  String get categoryDetailShuffle => 'Aléatoire';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeTitle => 'Thème';

  @override
  String get textColor => 'Couleur du texte';

  @override
  String get backgroundColor => 'Couleur de fond';

  @override
  String get selectTextColor => 'Sélectionner la couleur du texte';

  @override
  String get selectBackgroundColor => 'Sélectionner la couleur de fond';

  @override
  String get backgroundImage => 'Image de fond';

  @override
  String get notSet => 'Non défini';

  @override
  String get removeBackgroundImage => 'Supprimer l\'image de fond';

  @override
  String get adjustBackgroundImage => 'Ajuster l\'image de fond';

  @override
  String get adjustBackgroundImageDesc => 'Pincer pour zoomer et déplacer';

  @override
  String get cropThumbnail => 'Recadrer la miniature';

  @override
  String get adjustThumbnail => 'Ajuster la miniature';

  @override
  String get backgroundOpacity => 'Opacité';

  @override
  String get backgroundBlur => 'Flou';

  @override
  String get language => 'Langue';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageKorean => 'Coréen';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageChineseSimplified => 'Chinois (simplifié)';

  @override
  String get languageChineseTraditional => 'Chinois (traditionnel)';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languagePortugueseBrazil => 'Portugais (Brésil)';

  @override
  String get languageRussian => 'Russe';

  @override
  String get lyricsDisplayTitle => 'Affichage des paroles';

  @override
  String lyricsFontSize(String size) {
    return 'Taille de la police : $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Lignes à afficher (y compris la ligne actuelle) : $count';
  }

  @override
  String get showArtworkBackground => 'Afficher la pochette en arrière-plan';

  @override
  String get showArtworkBackgroundDesc =>
      'Afficher la pochette derrière les paroles';

  @override
  String get playbackTitle => 'Lecture';

  @override
  String get skipSilence => 'Ignorer le silence';

  @override
  String get skipSilenceDesc =>
      'Ignorer les parties silencieuses au début/à la fin';

  @override
  String silenceThreshold(int ms) {
    return 'Seuil : ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Fichiers locaux';

  @override
  String get importFiles => 'Importer des fichiers';

  @override
  String get importFolder => 'Importer un dossier';

  @override
  String get importing => 'Importation...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Vider la bibliothèque';

  @override
  String get clearLibraryConfirm =>
      'Tous les fichiers locaux seront supprimés.\nCette action est irréversible.\nContinuer ?';

  @override
  String get libraryCleared => 'Bibliothèque vidée';

  @override
  String get duplicateDetection => 'Détection des doublons';

  @override
  String get duplicateDetectionDesc => 'Supprimer les fichiers plus anciens';

  @override
  String get supportedFormatsTitle => 'Formats pris en charge';

  @override
  String get audioFormatsTitle => 'Formats audio';

  @override
  String get lyricsFormatsTitle => 'Formats de paroles';

  @override
  String get lyricsFormatsDesc => 'LRC (paroles synchronisées)';

  @override
  String get supportedQualityTitle => 'Qualité prise en charge';

  @override
  String get supportedQualityDesc => 'Lossless, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'Ajuster LRC';

  @override
  String get selectSong => 'Sélectionner un titre';

  @override
  String offsetLabel(String value) {
    return 'Décalage : $value';
  }

  @override
  String get applyChanges => 'Appliquer les changements';

  @override
  String get restore => 'Restaurer';

  @override
  String get previewTitle => 'Aperçu (30 premières lignes)';

  @override
  String get lrcFileNotFound => 'Fichier LRC introuvable';

  @override
  String loadError(String error) {
    return 'Erreur de chargement : $error';
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
  String get followSystemSetting => 'Langue du système';

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
