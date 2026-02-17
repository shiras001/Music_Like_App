// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => '취소';

  @override
  String get commonSave => '저장';

  @override
  String get commonClose => '닫기';

  @override
  String get commonDetails => '세부정보';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonApply => '적용';

  @override
  String get commonReset => '재설정';

  @override
  String get commonPlay => '재생';

  @override
  String get commonShuffle => '셔플';

  @override
  String get commonSearch => '검색';

  @override
  String get commonSort => '정렬';

  @override
  String get commonEdit => '편집';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonSaveChanges => '저장';

  @override
  String get tabSongs => '곡';

  @override
  String get tabArtists => '아티스트';

  @override
  String get tabAlbums => '앨범';

  @override
  String get tabPlaylists => '재생목록';

  @override
  String get drawerSettings => '설정';

  @override
  String get drawerEditCategories => '카테고리 편집';

  @override
  String get drawerSort => '정렬';

  @override
  String get libraryLoadFailed => '라이브러리 로드에 실패했습니다';

  @override
  String get libraryReload => '다시 불러오기';

  @override
  String get errorDetailsTitle => '오류 상세';

  @override
  String get errorClose => '닫기';

  @override
  String get searchHint => '곡명, 아티스트, 앨범';

  @override
  String get categoryEditTitle => '카테고리 편집';

  @override
  String get categorySongs => '곡';

  @override
  String get categoryArtists => '아티스트';

  @override
  String get categoryAlbums => '앨범';

  @override
  String get categoryPlaylists => '재생목록';

  @override
  String get sortTitleAsc => '제목 (A-Z)';

  @override
  String get sortTitleDesc => '제목 (Z-A)';

  @override
  String get sortArtistAsc => '아티스트 (A-Z)';

  @override
  String get sortArtistDesc => '아티스트 (Z-A)';

  @override
  String get sortDurationAsc => '재생시간 (짧은 순)';

  @override
  String get sortDurationDesc => '재생시간 (긴 순)';

  @override
  String get noSongs => '곡 없음';

  @override
  String get noArtists => '아티스트 없음';

  @override
  String get noAlbums => '앨범 없음';

  @override
  String get noPlaylists => '재생목록 없음';

  @override
  String get noResults => '결과 없음';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count곡',
      one: '1곡',
      zero: '0곡',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count곡',
      one: '1곡',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => '검색';

  @override
  String get searchPrompt => '곡명, 아티스트, 앨범으로 검색';

  @override
  String get sectionSongs => '곡';

  @override
  String get sectionArtists => '아티스트';

  @override
  String get sectionAlbums => '앨범';

  @override
  String get sectionPlaylists => '재생목록';

  @override
  String get queueUpNext => '다음 재생';

  @override
  String get queueEmpty => '큐가 비어 있습니다';

  @override
  String removedFromQueue(String songName) {
    return '\"$songName\"을(를) 큐에서 제거했습니다';
  }

  @override
  String get playNext => '다음에 재생';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\"을(를) 다음에 재생으로 추가했습니다';
  }

  @override
  String get addedToQueue => '큐에 추가되었습니다';

  @override
  String get addToPlaylist => '재생목록에 추가';

  @override
  String get addToPlaylistTitle => '재생목록에 추가';

  @override
  String get createNewPlaylist => '새 재생목록 생성';

  @override
  String get existingPlaylists => '기존 재생목록';

  @override
  String get createPlaylist => '재생목록 생성';

  @override
  String get playlistNameHint => '재생목록 이름 입력';

  @override
  String get playlistCreated => '재생목록이 생성되었습니다';

  @override
  String get addedToPlaylist => '재생목록에 추가되었습니다';

  @override
  String get editLyrics => '가사 편집';

  @override
  String get editLyricsLrc => '가사 편집 (LRC)';

  @override
  String get editManually => '수동으로 편집';

  @override
  String get adjustTiming => '타이밍 조정';

  @override
  String get lyricsFileNotFound => '가사 파일을 찾을 수 없습니다';

  @override
  String get lyricsNoDestination => '가사 파일의 저장 위치가 없습니다';

  @override
  String get lyricsSaved => '가사를 저장했습니다';

  @override
  String lyricsSaveFailed(String error) {
    return '가사 저장에 실패했습니다: $error';
  }

  @override
  String get lrcHint => '[00:12.34]가사 텍스트';

  @override
  String get editSongInfo => '곡 정보 편집';

  @override
  String get artworkLabel => '아트워크';

  @override
  String get selectImage => '이미지 선택';

  @override
  String get changeImage => '이미지 변경';

  @override
  String get titleLabel => '제목';

  @override
  String get artistLabel => '아티스트';

  @override
  String get albumLabel => '앨범';

  @override
  String get songUpdated => '곡 정보가 업데이트되었습니다';

  @override
  String artworkSaveFailed(String error) {
    return '아트워크 저장 실패: $error';
  }

  @override
  String get metadataSaved => '메타데이터를 저장했습니다';

  @override
  String get categoryDetailPlay => '재생';

  @override
  String get categoryDetailShuffle => '셔플';

  @override
  String get settingsTitle => '설정';

  @override
  String get themeTitle => '테마';

  @override
  String get textColor => '텍스트 색상';

  @override
  String get backgroundColor => '배경 색상';

  @override
  String get selectTextColor => '텍스트 색상 선택';

  @override
  String get selectBackgroundColor => '배경 색상 선택';

  @override
  String get backgroundImage => '배경 이미지';

  @override
  String get notSet => '설정 안됨';

  @override
  String get removeBackgroundImage => '배경 이미지 제거';

  @override
  String get adjustBackgroundImage => '배경 이미지 조정';

  @override
  String get adjustBackgroundImageDesc => '핀치로 확대/축소하고 이동하세요';

  @override
  String get cropThumbnail => '썸네일 자르기';

  @override
  String get adjustThumbnail => '썸네일 조정';

  @override
  String get backgroundOpacity => '불투명도';

  @override
  String get backgroundBlur => '흐림';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get languageSystem => '시스템 언어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageGerman => '독일어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageChineseSimplified => '중국어(간체)';

  @override
  String get languageChineseTraditional => '중국어(번체)';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languagePortugueseBrazil => '포르투갈어(브라질)';

  @override
  String get languageRussian => '러시아어';

  @override
  String get lyricsDisplayTitle => '가사 표시';

  @override
  String lyricsFontSize(String size) {
    return '글꼴 크기: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return '표시할 줄 수 (현재 포함): $count';
  }

  @override
  String get showArtworkBackground => '배경에 아트워크 표시';

  @override
  String get showArtworkBackgroundDesc => '가사 뒤에 앨범 아트워크를 표시';

  @override
  String get playbackTitle => '재생';

  @override
  String get skipSilence => '무음 건너뛰기';

  @override
  String get skipSilenceDesc => '시작/끝의 무음 부분 건너뛰기';

  @override
  String silenceThreshold(int ms) {
    return '임계값: ${ms}ms';
  }

  @override
  String get localFilesTitle => '로컬 파일';

  @override
  String get importFiles => '파일 가져오기';

  @override
  String get importFolder => '폴더 가져오기';

  @override
  String get importing => '가져오는 중...';

  @override
  String importCount(int processed, int total) {
    return '$processed/$total';
  }

  @override
  String get clearLibraryTitle => '라이브러리 초기화';

  @override
  String get clearLibraryConfirm =>
      '모든 로컬 파일이 제거됩니다.\n이 작업은 되돌릴 수 없습니다.\n진행하시겠습니까?';

  @override
  String get libraryCleared => '라이브러리를 초기화했습니다';

  @override
  String get duplicateDetection => '중복 감지';

  @override
  String get duplicateDetectionDesc => '오래된 파일 제거';

  @override
  String get supportedFormatsTitle => '지원 형식';

  @override
  String get audioFormatsTitle => '오디오 형식';

  @override
  String get lyricsFormatsTitle => '가사 형식';

  @override
  String get lyricsFormatsDesc => 'LRC (타임 싱크 가사)';

  @override
  String get supportedQualityTitle => '지원 품질';

  @override
  String get supportedQualityDesc => '무손실, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'LRC 조정';

  @override
  String get selectSong => '곡 선택';

  @override
  String offsetLabel(String value) {
    return '오프셋: $value';
  }

  @override
  String get applyChanges => '변경 적용';

  @override
  String get restore => '복원';

  @override
  String get previewTitle => '미리보기 (첫 30줄)';

  @override
  String get lrcFileNotFound => 'LRC 파일을 찾을 수 없습니다';

  @override
  String loadError(String error) {
    return '로드 오류: $error';
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
  String get followSystemSetting => '시스템 언어';

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
