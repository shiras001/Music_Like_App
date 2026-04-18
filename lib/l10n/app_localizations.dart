import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('de'),
    Locale('fr'),
    Locale('zh'),
    Locale('zh', 'TW'),
    Locale('es'),
    Locale('pt', 'BR'),
    Locale('ru'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Music Like'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get commonDetails;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get commonPlay;

  /// No description provided for @commonShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get commonShuffle;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @commonSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get commonSort;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSaveChanges;

  /// No description provided for @tabSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get tabSongs;

  /// No description provided for @tabArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get tabArtists;

  /// No description provided for @tabAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get tabAlbums;

  /// No description provided for @tabPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get tabPlaylists;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerEditCategories.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get drawerEditCategories;

  /// No description provided for @drawerSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get drawerSort;

  /// No description provided for @libraryLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load library'**
  String get libraryLoadFailed;

  /// No description provided for @libraryReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get libraryReload;

  /// No description provided for @errorDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Error details'**
  String get errorDetailsTitle;

  /// No description provided for @errorClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get errorClose;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Song, artist, or album'**
  String get searchHint;

  /// No description provided for @categoryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit categories'**
  String get categoryEditTitle;

  /// No description provided for @categorySongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get categorySongs;

  /// No description provided for @categoryArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get categoryArtists;

  /// No description provided for @categoryAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get categoryAlbums;

  /// No description provided for @categoryPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get categoryPlaylists;

  /// No description provided for @sortTitleAsc.
  ///
  /// In en, this message translates to:
  /// **'Title (A-Z)'**
  String get sortTitleAsc;

  /// No description provided for @sortTitleDesc.
  ///
  /// In en, this message translates to:
  /// **'Title (Z-A)'**
  String get sortTitleDesc;

  /// No description provided for @sortArtistAsc.
  ///
  /// In en, this message translates to:
  /// **'Artist (A-Z)'**
  String get sortArtistAsc;

  /// No description provided for @sortArtistDesc.
  ///
  /// In en, this message translates to:
  /// **'Artist (Z-A)'**
  String get sortArtistDesc;

  /// No description provided for @sortDurationAsc.
  ///
  /// In en, this message translates to:
  /// **'Duration (shorter)'**
  String get sortDurationAsc;

  /// No description provided for @sortDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'Duration (longer)'**
  String get sortDurationDesc;

  /// No description provided for @noSongs.
  ///
  /// In en, this message translates to:
  /// **'No songs'**
  String get noSongs;

  /// No description provided for @noArtists.
  ///
  /// In en, this message translates to:
  /// **'No artists'**
  String get noArtists;

  /// No description provided for @noAlbums.
  ///
  /// In en, this message translates to:
  /// **'No albums'**
  String get noAlbums;

  /// No description provided for @noPlaylists.
  ///
  /// In en, this message translates to:
  /// **'No playlists'**
  String get noPlaylists;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @songCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 songs} =1{1 song} other{{count} songs}}'**
  String songCount(int count);

  /// No description provided for @artistSongCount.
  ///
  /// In en, this message translates to:
  /// **'{artist} • {count, plural, =1{1 song} other{{count} songs}}'**
  String artistSongCount(String artist, int count);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search by song, artist, or album'**
  String get searchPrompt;

  /// No description provided for @sectionSongs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get sectionSongs;

  /// No description provided for @sectionArtists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get sectionArtists;

  /// No description provided for @sectionAlbums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get sectionAlbums;

  /// No description provided for @sectionPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get sectionPlaylists;

  /// No description provided for @queueUpNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get queueUpNext;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueEmpty;

  /// No description provided for @removedFromQueue.
  ///
  /// In en, this message translates to:
  /// **'Removed \"{songName}\" from queue'**
  String removedFromQueue(String songName);

  /// No description provided for @playNext.
  ///
  /// In en, this message translates to:
  /// **'Play Next'**
  String get playNext;

  /// No description provided for @addedPlayNext.
  ///
  /// In en, this message translates to:
  /// **'Added \"{songName}\" to Play Next'**
  String addedPlayNext(String songName);

  /// No description provided for @addedToQueue.
  ///
  /// In en, this message translates to:
  /// **'Added to queue'**
  String get addedToQueue;

  /// No description provided for @addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylist;

  /// No description provided for @addToPlaylistTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get addToPlaylistTitle;

  /// No description provided for @createNewPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create new playlist'**
  String get createNewPlaylist;

  /// No description provided for @existingPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Existing playlists'**
  String get existingPlaylists;

  /// No description provided for @createPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylist;

  /// No description provided for @playlistNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter playlist name'**
  String get playlistNameHint;

  /// No description provided for @playlistCreated.
  ///
  /// In en, this message translates to:
  /// **'Playlist created'**
  String get playlistCreated;

  /// No description provided for @addedToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Added to playlist'**
  String get addedToPlaylist;

  /// No description provided for @editLyrics.
  ///
  /// In en, this message translates to:
  /// **'Edit lyrics'**
  String get editLyrics;

  /// No description provided for @editLyricsLrc.
  ///
  /// In en, this message translates to:
  /// **'Edit lyrics (LRC)'**
  String get editLyricsLrc;

  /// No description provided for @editManually.
  ///
  /// In en, this message translates to:
  /// **'Edit manually'**
  String get editManually;

  /// No description provided for @adjustTiming.
  ///
  /// In en, this message translates to:
  /// **'Adjust timing'**
  String get adjustTiming;

  /// No description provided for @lyricsFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Lyrics file not found'**
  String get lyricsFileNotFound;

  /// No description provided for @lyricsNoDestination.
  ///
  /// In en, this message translates to:
  /// **'No destination for lyrics file'**
  String get lyricsNoDestination;

  /// No description provided for @lyricsSaved.
  ///
  /// In en, this message translates to:
  /// **'Lyrics saved'**
  String get lyricsSaved;

  /// No description provided for @lyricsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save lyrics: {error}'**
  String lyricsSaveFailed(String error);

  /// No description provided for @lrcHint.
  ///
  /// In en, this message translates to:
  /// **'[00:12.34]Lyrics text'**
  String get lrcHint;

  /// No description provided for @editSongInfo.
  ///
  /// In en, this message translates to:
  /// **'Edit song info'**
  String get editSongInfo;

  /// No description provided for @artworkLabel.
  ///
  /// In en, this message translates to:
  /// **'Artwork'**
  String get artworkLabel;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select image'**
  String get selectImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change image'**
  String get changeImage;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @artistLabel.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artistLabel;

  /// No description provided for @albumLabel.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get albumLabel;

  /// No description provided for @songUpdated.
  ///
  /// In en, this message translates to:
  /// **'Song updated'**
  String get songUpdated;

  /// No description provided for @artworkSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save artwork: {error}'**
  String artworkSaveFailed(String error);

  /// No description provided for @metadataSaved.
  ///
  /// In en, this message translates to:
  /// **'Metadata saved'**
  String get metadataSaved;

  /// No description provided for @categoryDetailPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get categoryDetailPlay;

  /// No description provided for @categoryDetailShuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get categoryDetailShuffle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get textColor;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColor;

  /// No description provided for @selectTextColor.
  ///
  /// In en, this message translates to:
  /// **'Select text color'**
  String get selectTextColor;

  /// No description provided for @selectBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Select background color'**
  String get selectBackgroundColor;

  /// No description provided for @backgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Background image'**
  String get backgroundImage;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @removeBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Remove background image'**
  String get removeBackgroundImage;

  /// No description provided for @adjustBackgroundImage.
  ///
  /// In en, this message translates to:
  /// **'Adjust background image'**
  String get adjustBackgroundImage;

  /// No description provided for @adjustBackgroundImageDesc.
  ///
  /// In en, this message translates to:
  /// **'Pinch to zoom and move'**
  String get adjustBackgroundImageDesc;

  /// No description provided for @cropThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Crop Thumbnail'**
  String get cropThumbnail;

  /// No description provided for @adjustThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Adjust Thumbnail'**
  String get adjustThumbnail;

  /// No description provided for @backgroundOpacity.
  ///
  /// In en, this message translates to:
  /// **'Opacity'**
  String get backgroundOpacity;

  /// No description provided for @backgroundBlur.
  ///
  /// In en, this message translates to:
  /// **'Blur'**
  String get backgroundBlur;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get languageSystem;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageKorean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// No description provided for @languageChineseSimplified.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Simplified)'**
  String get languageChineseSimplified;

  /// No description provided for @languageChineseTraditional.
  ///
  /// In en, this message translates to:
  /// **'Chinese (Traditional)'**
  String get languageChineseTraditional;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortugueseBrazil.
  ///
  /// In en, this message translates to:
  /// **'Portuguese (Brazil)'**
  String get languagePortugueseBrazil;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @lyricsDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics display'**
  String get lyricsDisplayTitle;

  /// No description provided for @lyricsFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size: {size}'**
  String lyricsFontSize(String size);

  /// No description provided for @lyricsContextLines.
  ///
  /// In en, this message translates to:
  /// **'Lines to show (including current): {count}'**
  String lyricsContextLines(String count);

  /// No description provided for @showArtworkBackground.
  ///
  /// In en, this message translates to:
  /// **'Show artwork in background'**
  String get showArtworkBackground;

  /// No description provided for @showArtworkBackgroundDesc.
  ///
  /// In en, this message translates to:
  /// **'Show album artwork behind lyrics'**
  String get showArtworkBackgroundDesc;

  /// No description provided for @playbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playbackTitle;

  /// No description provided for @skipSilence.
  ///
  /// In en, this message translates to:
  /// **'Skip silence'**
  String get skipSilence;

  /// No description provided for @skipSilenceDesc.
  ///
  /// In en, this message translates to:
  /// **'Skip silent parts at start/end'**
  String get skipSilenceDesc;

  /// No description provided for @silenceThreshold.
  ///
  /// In en, this message translates to:
  /// **'Threshold: {ms}ms'**
  String silenceThreshold(int ms);

  /// No description provided for @localFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Local files'**
  String get localFilesTitle;

  /// No description provided for @importFiles.
  ///
  /// In en, this message translates to:
  /// **'Import files'**
  String get importFiles;

  /// No description provided for @importFolder.
  ///
  /// In en, this message translates to:
  /// **'Import folder'**
  String get importFolder;

  /// No description provided for @importing.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importing;

  /// No description provided for @importCount.
  ///
  /// In en, this message translates to:
  /// **'{processed}/{total}'**
  String importCount(int processed, int total);

  /// No description provided for @clearLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear library'**
  String get clearLibraryTitle;

  /// No description provided for @clearLibraryConfirm.
  ///
  /// In en, this message translates to:
  /// **'All local files will be removed.\nThis action cannot be undone.\nAre you sure?'**
  String get clearLibraryConfirm;

  /// No description provided for @libraryCleared.
  ///
  /// In en, this message translates to:
  /// **'Library cleared'**
  String get libraryCleared;

  /// No description provided for @duplicateDetection.
  ///
  /// In en, this message translates to:
  /// **'Duplicate detection'**
  String get duplicateDetection;

  /// No description provided for @duplicateDetectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove older files'**
  String get duplicateDetectionDesc;

  /// No description provided for @supportedFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported formats'**
  String get supportedFormatsTitle;

  /// No description provided for @audioFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Audio formats'**
  String get audioFormatsTitle;

  /// No description provided for @lyricsFormatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Lyrics format'**
  String get lyricsFormatsTitle;

  /// No description provided for @lyricsFormatsDesc.
  ///
  /// In en, this message translates to:
  /// **'LRC (time-synced lyrics)'**
  String get lyricsFormatsDesc;

  /// No description provided for @supportedQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Supported quality'**
  String get supportedQualityTitle;

  /// No description provided for @supportedQualityDesc.
  ///
  /// In en, this message translates to:
  /// **'Lossless, Dolby Atmos'**
  String get supportedQualityDesc;

  /// No description provided for @lrcAdjustTitle.
  ///
  /// In en, this message translates to:
  /// **'LRC adjust'**
  String get lrcAdjustTitle;

  /// No description provided for @selectSong.
  ///
  /// In en, this message translates to:
  /// **'Select a song'**
  String get selectSong;

  /// No description provided for @offsetLabel.
  ///
  /// In en, this message translates to:
  /// **'Offset: {value}'**
  String offsetLabel(String value);

  /// No description provided for @applyChanges.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get applyChanges;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview (first 30 lines)'**
  String get previewTitle;

  /// No description provided for @lrcFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'LRC file not found'**
  String get lrcFileNotFound;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Load error: {error}'**
  String loadError(String error);

  /// No description provided for @offset.
  ///
  /// In en, this message translates to:
  /// **'Offset'**
  String get offset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @noLrcFileFound.
  ///
  /// In en, this message translates to:
  /// **'No LRC file found'**
  String get noLrcFileFound;

  /// No description provided for @upNext.
  ///
  /// In en, this message translates to:
  /// **'Up Next'**
  String get upNext;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @queueIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Queue is empty'**
  String get queueIsEmpty;

  /// No description provided for @selectASong.
  ///
  /// In en, this message translates to:
  /// **'Select a song'**
  String get selectASong;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @applyChanges2.
  ///
  /// In en, this message translates to:
  /// **'Apply changes'**
  String get applyChanges2;

  /// No description provided for @restore2.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore2;

  /// No description provided for @previewFirst30Lines.
  ///
  /// In en, this message translates to:
  /// **'Preview (first 30 lines)'**
  String get previewFirst30Lines;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @followSystemSetting.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get followSystemSetting;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @selectLanguage2.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage2;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @execute.
  ///
  /// In en, this message translates to:
  /// **'Execute'**
  String get execute;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get artist;

  /// No description provided for @tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// No description provided for @albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// No description provided for @createPlaylist2.
  ///
  /// In en, this message translates to:
  /// **'Create playlist'**
  String get createPlaylist2;

  /// No description provided for @playpause.
  ///
  /// In en, this message translates to:
  /// **'Play/Pause'**
  String get playpause;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @artistTrackAlbum.
  ///
  /// In en, this message translates to:
  /// **'Artist, track, album'**
  String get artistTrackAlbum;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @showDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'Show debug info'**
  String get showDebugInfo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @switchTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch theme'**
  String get switchTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @play2.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play2;

  /// No description provided for @playQueue.
  ///
  /// In en, this message translates to:
  /// **'Play queue'**
  String get playQueue;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @migrateSettingsFromOlderVersions.
  ///
  /// In en, this message translates to:
  /// **'Migrate settings from older versions'**
  String get migrateSettingsFromOlderVersions;

  /// No description provided for @tracks2.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks2;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline mode'**
  String get offlineMode;

  /// No description provided for @downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded'**
  String get downloaded;

  /// No description provided for @youtube.
  ///
  /// In en, this message translates to:
  /// **'YouTube audio extraction'**
  String get youtube;

  /// No description provided for @youtubeurl.
  ///
  /// In en, this message translates to:
  /// **'No YouTube URL found in clipboard'**
  String get youtubeurl;

  /// No description provided for @youtube2.
  ///
  /// In en, this message translates to:
  /// **'Convert from YouTube to audio file'**
  String get youtube2;

  /// No description provided for @k320Kbps.
  ///
  /// In en, this message translates to:
  /// **'320 kbps'**
  String get k320Kbps;

  /// No description provided for @k441Khz.
  ///
  /// In en, this message translates to:
  /// **'44.1 kHz'**
  String get k441Khz;

  /// No description provided for @mp3M4aFlacWavAiff.
  ///
  /// In en, this message translates to:
  /// **'MP3, M4A, FLAC, WAV, AIFF'**
  String get mp3M4aFlacWavAiff;

  /// No description provided for @noLyrics.
  ///
  /// In en, this message translates to:
  /// **'No lyrics'**
  String get noLyrics;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback speed'**
  String get playbackSpeed;

  /// No description provided for @loadingLyrics.
  ///
  /// In en, this message translates to:
  /// **'Loading lyrics...'**
  String get loadingLyrics;

  /// No description provided for @backgroundCustomize.
  ///
  /// In en, this message translates to:
  /// **'Background customize'**
  String get backgroundCustomize;

  /// No description provided for @selectImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select an image first'**
  String get selectImageFirst;

  /// No description provided for @backgroundSet.
  ///
  /// In en, this message translates to:
  /// **'Background set'**
  String get backgroundSet;

  /// No description provided for @backgroundSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set background'**
  String get backgroundSetFailed;

  /// No description provided for @thumbnailPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview thumbnail'**
  String get thumbnailPreview;

  /// No description provided for @lossless.
  ///
  /// In en, this message translates to:
  /// **'Lossless'**
  String get lossless;

  /// No description provided for @audioConversionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm audio conversion'**
  String get audioConversionConfirm;

  /// No description provided for @confirmDownloadAudioFromVideo.
  ///
  /// In en, this message translates to:
  /// **'Download audio from this video?'**
  String get confirmDownloadAudioFromVideo;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @videotitle.
  ///
  /// In en, this message translates to:
  /// **'Started downloading \"\$videoTitle\"...'**
  String get videotitle;

  /// No description provided for @videotitle2.
  ///
  /// In en, this message translates to:
  /// **'Finished downloading \"\$videoTitle\"!'**
  String get videotitle2;

  /// No description provided for @videotitle3.
  ///
  /// In en, this message translates to:
  /// **'Failed to download \"\$videoTitle\"'**
  String get videotitle3;

  /// No description provided for @downloadCompletedFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Download completed but file not found'**
  String get downloadCompletedFileNotFound;

  /// No description provided for @downloadCompletedPathUnknown.
  ///
  /// In en, this message translates to:
  /// **'Download completed but file path unknown'**
  String get downloadCompletedPathUnknown;

  /// No description provided for @clipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty'**
  String get clipboardEmpty;

  /// No description provided for @outputformat.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get outputformat;

  /// No description provided for @selectOutputFormat.
  ///
  /// In en, this message translates to:
  /// **'Select output format'**
  String get selectOutputFormat;

  /// No description provided for @bitrate.
  ///
  /// In en, this message translates to:
  /// **'Bitrate'**
  String get bitrate;

  /// No description provided for @samplingRate.
  ///
  /// In en, this message translates to:
  /// **'Sampling rate'**
  String get samplingRate;

  /// No description provided for @e.
  ///
  /// In en, this message translates to:
  /// **'Error: \$e'**
  String e(String e);

  /// No description provided for @m123.
  ///
  /// In en, this message translates to:
  /// **'Crop failed: \$e'**
  String m123(String e);

  /// No description provided for @channelname.
  ///
  /// In en, this message translates to:
  /// **'Channel: \$channelName'**
  String channelname(String channelName);

  /// No description provided for @error4.
  ///
  /// In en, this message translates to:
  /// **'Download error: \$error'**
  String error4(String error);

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @nowPlaying.
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get nowPlaying;

  /// No description provided for @param.
  ///
  /// In en, this message translates to:
  /// **'{processed}/{total}'**
  String param(Object processed, Object total);

  /// No description provided for @nowPlaying2.
  ///
  /// In en, this message translates to:
  /// **'Now Playing'**
  String get nowPlaying2;

  /// No description provided for @noSongPlaying.
  ///
  /// In en, this message translates to:
  /// **'No song playing'**
  String get noSongPlaying;

  /// No description provided for @dolbyAtmos.
  ///
  /// In en, this message translates to:
  /// **'Dolby Atmos'**
  String get dolbyAtmos;

  /// No description provided for @k075.
  ///
  /// In en, this message translates to:
  /// **'0.75×'**
  String get k075;

  /// No description provided for @k09.
  ///
  /// In en, this message translates to:
  /// **'0.9×'**
  String get k09;

  /// No description provided for @k10.
  ///
  /// In en, this message translates to:
  /// **'1.0×'**
  String get k10;

  /// No description provided for @k11.
  ///
  /// In en, this message translates to:
  /// **'1.1×'**
  String get k11;

  /// No description provided for @k125.
  ///
  /// In en, this message translates to:
  /// **'1.25×'**
  String get k125;

  /// No description provided for @k15.
  ///
  /// In en, this message translates to:
  /// **'1.5×'**
  String get k15;

  /// No description provided for @k20.
  ///
  /// In en, this message translates to:
  /// **'2.0×'**
  String get k20;

  /// No description provided for @exportToDownloadsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save to download folder with a new name.'**
  String get exportToDownloadsDesc;

  /// No description provided for @exportLrcButton.
  ///
  /// In en, this message translates to:
  /// **'Download LRC'**
  String get exportLrcButton;

  /// No description provided for @exportAudioButton.
  ///
  /// In en, this message translates to:
  /// **'Download audio'**
  String get exportAudioButton;

  /// No description provided for @exportLrcSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {fileName}'**
  String exportLrcSuccess(String fileName);

  /// No description provided for @exportAudioSuccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded {fileName}'**
  String exportAudioSuccess(String fileName);

  /// No description provided for @exportLrcFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download LRC'**
  String get exportLrcFailed;

  /// No description provided for @exportAudioFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to download audio'**
  String get exportAudioFailed;

  /// No description provided for @exportNoFile.
  ///
  /// In en, this message translates to:
  /// **'No file'**
  String get exportNoFile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'ja',
        'ko',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
