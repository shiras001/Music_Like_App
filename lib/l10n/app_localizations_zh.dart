// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '保存';

  @override
  String get commonClose => '关闭';

  @override
  String get commonDetails => '详情';

  @override
  String get commonDelete => '删除';

  @override
  String get commonApply => '应用';

  @override
  String get commonReset => '重置';

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
  String get tabSongs => '歌曲';

  @override
  String get tabArtists => '艺术家';

  @override
  String get tabAlbums => '专辑';

  @override
  String get tabPlaylists => '播放列表';

  @override
  String get drawerSettings => '设置';

  @override
  String get drawerEditCategories => '编辑分类';

  @override
  String get drawerSort => '排序';

  @override
  String get libraryLoadFailed => 'Failed to load library';

  @override
  String get libraryReload => 'Reload';

  @override
  String get errorDetailsTitle => '错误详情';

  @override
  String get errorClose => 'Close';

  @override
  String get searchHint => 'Song, artist, or album';

  @override
  String get categoryEditTitle => '编辑分类';

  @override
  String get categorySongs => 'Songs';

  @override
  String get categoryArtists => 'Artists';

  @override
  String get categoryAlbums => 'Albums';

  @override
  String get categoryPlaylists => 'Playlists';

  @override
  String get sortTitleAsc => '标题 (A-Z)';

  @override
  String get sortTitleDesc => '标题 (Z-A)';

  @override
  String get sortArtistAsc => '艺术家 (A-Z)';

  @override
  String get sortArtistDesc => '艺术家 (Z-A)';

  @override
  String get sortDurationAsc => '时长（较短）';

  @override
  String get sortDurationDesc => '时长（较长）';

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
    return '已从队列移除“$songName”';
  }

  @override
  String get playNext => '接下来播放';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\" 已添加到“接下来播放”';
  }

  @override
  String get addedToQueue => '已加入队列';

  @override
  String get addToPlaylist => '添加到播放列表';

  @override
  String get addToPlaylistTitle => '添加到播放列表';

  @override
  String get createNewPlaylist => '新建播放列表';

  @override
  String get existingPlaylists => '现有播放列表';

  @override
  String get createPlaylist => 'Create playlist';

  @override
  String get playlistNameHint => 'Enter playlist name';

  @override
  String get playlistCreated => 'Playlist created';

  @override
  String get addedToPlaylist => 'Added to playlist';

  @override
  String get editLyrics => '编辑歌词';

  @override
  String get editLyricsLrc => '编辑歌词 (LRC)';

  @override
  String get editManually => '手动编辑';

  @override
  String get adjustTiming => '调整时间';

  @override
  String get lyricsFileNotFound => 'Lyrics file not found';

  @override
  String get lyricsNoDestination => 'No destination for lyrics file';

  @override
  String get lyricsSaved => 'Lyrics saved';

  @override
  String lyricsSaveFailed(String error) {
    return '保存歌词失败：$error';
  }

  @override
  String get lrcHint => '[00:12.34]歌词文本';

  @override
  String get editSongInfo => '编辑歌曲信息';

  @override
  String get artworkLabel => '封面';

  @override
  String get selectImage => '选择图片';

  @override
  String get changeImage => '更换图片';

  @override
  String get titleLabel => '标题';

  @override
  String get artistLabel => '艺术家';

  @override
  String get albumLabel => '专辑';

  @override
  String get songUpdated => '歌曲信息已更新';

  @override
  String artworkSaveFailed(String error) {
    return '保存封面失败：$error';
  }

  @override
  String get metadataSaved => '元数据已保存';

  @override
  String get categoryDetailPlay => '播放';

  @override
  String get categoryDetailShuffle => '随机播放';

  @override
  String get settingsTitle => '设置';

  @override
  String get themeTitle => '主题';

  @override
  String get textColor => '文字颜色';

  @override
  String get backgroundColor => '背景颜色';

  @override
  String get selectTextColor => '选择文字颜色';

  @override
  String get selectBackgroundColor => '选择背景颜色';

  @override
  String get backgroundImage => '背景图片';

  @override
  String get notSet => '未设置';

  @override
  String get removeBackgroundImage => '移除背景图片';

  @override
  String get adjustBackgroundImage => '调整背景图片';

  @override
  String get adjustBackgroundImageDesc => '捏合缩放并移动';

  @override
  String get cropThumbnail => 'Crop Thumbnail';

  @override
  String get adjustThumbnail => 'Adjust Thumbnail';

  @override
  String get backgroundOpacity => '不透明度';

  @override
  String get backgroundBlur => '模糊';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageSystem => '系统语言';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageChineseSimplified => '中文(简体)';

  @override
  String get languageChineseTraditional => '中文(繁體)';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languagePortugueseBrazil => '葡萄牙语（巴西）';

  @override
  String get languageRussian => '俄语';

  @override
  String get lyricsDisplayTitle => '歌词显示';

  @override
  String lyricsFontSize(String size) {
    return '字体大小：$size';
  }

  @override
  String lyricsContextLines(String count) {
    return '要显示的行数（包含当前行）：$count';
  }

  @override
  String get showArtworkBackground => '在背景中显示封面';

  @override
  String get showArtworkBackgroundDesc => '在歌词后显示专辑封面';

  @override
  String get playbackTitle => '播放设置';

  @override
  String get skipSilence => '跳过静音';

  @override
  String get skipSilenceDesc => '跳过开头/结尾的静音部分';

  @override
  String silenceThreshold(int ms) {
    return '阈值：${ms}ms';
  }

  @override
  String get localFilesTitle => '本地文件';

  @override
  String get importFiles => '导入文件';

  @override
  String get importFolder => '导入文件夹';

  @override
  String get importing => '导入中...';

  @override
  String importCount(int processed, int total) {
    return '已处理：$processed/$total';
  }

  @override
  String get clearLibraryTitle => '清空库';

  @override
  String get clearLibraryConfirm => '所有本地文件将被移除。\n此操作无法撤销。\n确定要继续吗？';

  @override
  String get libraryCleared => '库已清空';

  @override
  String get duplicateDetection => '重复检测';

  @override
  String get duplicateDetectionDesc => '移除较旧的文件';

  @override
  String get supportedFormatsTitle => '支持的格式';

  @override
  String get audioFormatsTitle => '音频格式';

  @override
  String get lyricsFormatsTitle => '歌词格式';

  @override
  String get lyricsFormatsDesc => 'LRC（时间同步歌词）';

  @override
  String get supportedQualityTitle => '支持的质量';

  @override
  String get supportedQualityDesc => '无损，Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'LRC 调整';

  @override
  String get selectSong => '选择一首歌曲';

  @override
  String offsetLabel(String value) {
    return '偏移：$value';
  }

  @override
  String get applyChanges => '应用更改';

  @override
  String get restore => '恢复';

  @override
  String get previewTitle => '预览（前 30 行）';

  @override
  String get lrcFileNotFound => '未找到 LRC 文件';

  @override
  String loadError(String error) {
    return '加载错误：$error';
  }

  @override
  String get offset => '偏移';

  @override
  String get apply => '应用';

  @override
  String get reset => '重置';

  @override
  String get noLrcFileFound => '未找到LRC文件';

  @override
  String get upNext => '接下来播放';

  @override
  String get close => '关闭';

  @override
  String get queueIsEmpty => '队列为空';

  @override
  String get selectASong => '选择歌曲';

  @override
  String get play => '播放';

  @override
  String get applyChanges2 => '应用更改';

  @override
  String get restore2 => '恢复';

  @override
  String get previewFirst30Lines => '预览（前30行）';

  @override
  String get customColor => '自定义颜色';

  @override
  String get darkMode => '深色模式';

  @override
  String get appLanguage => '应用语言';

  @override
  String get followSystemSetting => '系统语言';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get change => '更改';

  @override
  String get selectLanguage2 => '选择语言';

  @override
  String get confirm => '确认';

  @override
  String get execute => '执行';

  @override
  String get noData => '没有数据';

  @override
  String get error => '错误';

  @override
  String get delete => '删除';

  @override
  String get search => '搜索';

  @override
  String get artist => '艺术家';

  @override
  String get tracks => '曲目';

  @override
  String get albums => '专辑';

  @override
  String get createPlaylist2 => '创建播放列表';

  @override
  String get playpause => '播放/暂停';

  @override
  String get next => '下一首';

  @override
  String get previous => '上一首';

  @override
  String get collection => '收藏';

  @override
  String get artistTrackAlbum => '艺术家、曲目、专辑';

  @override
  String get welcome => '欢迎';

  @override
  String get getStarted => '开始';

  @override
  String get showDebugInfo => '显示调试信息';

  @override
  String get clear => '清除';

  @override
  String get clearCache => '清除缓存';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get switchTheme => '切换主题';

  @override
  String get light => '明亮';

  @override
  String get dark => '黑暗';

  @override
  String get system => '系统';

  @override
  String get play2 => '播放';

  @override
  String get playQueue => '播放队列';

  @override
  String get remove => '移除';

  @override
  String get migrateSettingsFromOlderVersions => '从旧版本迁移设置';

  @override
  String get tracks2 => '曲数';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get loading => '加载中...';

  @override
  String get offlineMode => '离线模式';

  @override
  String get downloaded => '已下载';

  @override
  String get youtube => 'YouTube 音频提取';

  @override
  String get youtubeurl => '剪贴板中未找到 YouTube URL';

  @override
  String get youtube2 => '将 YouTube 转换为音频文件';

  @override
  String get k320Kbps => '320 千比特每秒';

  @override
  String get k441Khz => '44.1 千赫兹';

  @override
  String get mp3M4aFlacWavAiff => 'MP3／M4A／FLAC／WAV／AIFF';

  @override
  String get noLyrics => '无歌词';

  @override
  String get playbackSpeed => '播放速度';

  @override
  String get loadingLyrics => '歌词加载中...';

  @override
  String get backgroundCustomize => '背景自定义';

  @override
  String get selectImageFirst => '请先选择图片';

  @override
  String get backgroundSet => '背景已设置';

  @override
  String get backgroundSetFailed => '设置背景失败';

  @override
  String get thumbnailPreview => '缩略图预览';

  @override
  String get lossless => '无损';

  @override
  String get audioConversionConfirm => '确认音频转换';

  @override
  String get confirmDownloadAudioFromVideo => '要下载此视频的音频吗？';

  @override
  String get download => '下载';

  @override
  String get videotitle => '已开始下载 \"\$videoTitle\"...';

  @override
  String get videotitle2 => '\"\$videoTitle\" 下载完成！';

  @override
  String get videotitle3 => '下载 \"\$videoTitle\" 失败';

  @override
  String get downloadCompletedFileNotFound => '下载完成，但未找到文件';

  @override
  String get downloadCompletedPathUnknown => '下载完成，但文件路径未知';

  @override
  String get clipboardEmpty => '剪贴板为空';

  @override
  String get outputformat => '输出格式：\$outputFormat';

  @override
  String get selectOutputFormat => '选择输出格式';

  @override
  String get bitrate => '比特率';

  @override
  String get samplingRate => '采样率';

  @override
  String e(String e) {
    return '错误：\$e';
  }

  @override
  String m123(String e) {
    return '裁剪失败：\$e';
  }

  @override
  String channelname(String channelName) {
    return '频道：\$channelName';
  }

  @override
  String error4(String error) {
    return '下载错误：\$error';
  }

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get nowPlaying => '正在播放';

  @override
  String param(Object processed, Object total) {
    return '已处理：$processed/$total';
  }

  @override
  String get nowPlaying2 => '正在播放';

  @override
  String get noSongPlaying => '当前没有播放歌曲';

  @override
  String get dolbyAtmos => '杜比全景声';

  @override
  String get k075 => '0.75倍';

  @override
  String get k09 => '0.9倍';

  @override
  String get k10 => '1.0倍';

  @override
  String get k11 => '1.1倍';

  @override
  String get k125 => '1.25倍';

  @override
  String get k15 => '1.5倍';

  @override
  String get k20 => '2.0倍';

  @override
  String get exportToDownloadsDesc => '以新文件名保存到下载文件夹。';

  @override
  String get exportLrcButton => '下载 LRC';

  @override
  String get exportAudioButton => '下载音频';

  @override
  String exportLrcSuccess(String fileName) {
    return '已下载 $fileName';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '已下载 $fileName';
  }

  @override
  String get exportLrcFailed => 'LRC 下载失败';

  @override
  String get exportAudioFailed => '音频文件下载失败';

  @override
  String get exportNoFile => '无文件';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => '取消';

  @override
  String get commonSave => '儲存';

  @override
  String get commonClose => '關閉';

  @override
  String get commonDetails => '詳情';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonApply => '套用';

  @override
  String get commonReset => '重設';

  @override
  String get tabSongs => '歌曲';

  @override
  String get tabArtists => '藝術家';

  @override
  String get tabAlbums => '專輯';

  @override
  String get tabPlaylists => '播放清單';

  @override
  String get drawerSettings => '設定';

  @override
  String get drawerEditCategories => '編輯分類';

  @override
  String get drawerSort => '排序';

  @override
  String get errorDetailsTitle => '錯誤詳情';

  @override
  String get categoryEditTitle => '編輯分類';

  @override
  String get sortTitleAsc => '標題 (A-Z)';

  @override
  String get sortTitleDesc => '標題 (Z-A)';

  @override
  String get sortArtistAsc => '藝術家 (A-Z)';

  @override
  String get sortArtistDesc => '藝術家 (Z-A)';

  @override
  String get sortDurationAsc => '時長（較短）';

  @override
  String get sortDurationDesc => '時長（較長）';

  @override
  String removedFromQueue(String songName) {
    return '已從佇列移除「$songName」';
  }

  @override
  String get playNext => '接下來播放';

  @override
  String addedPlayNext(String songName) {
    return '\"$songName\" 已加入「接下來播放」';
  }

  @override
  String get addedToQueue => '已加入佇列';

  @override
  String get addToPlaylist => '加入播放清單';

  @override
  String get addToPlaylistTitle => '加入播放清單';

  @override
  String get createNewPlaylist => '建立新播放清單';

  @override
  String get existingPlaylists => '現有播放清單';

  @override
  String get editLyrics => '編輯歌詞';

  @override
  String get editLyricsLrc => '編輯歌詞 (LRC)';

  @override
  String get editManually => '手動編輯';

  @override
  String get adjustTiming => '調整時間';

  @override
  String lyricsSaveFailed(String error) {
    return '儲存歌詞失敗：$error';
  }

  @override
  String get editSongInfo => '編輯歌曲資訊';

  @override
  String get artworkLabel => '封面';

  @override
  String get selectImage => '選擇圖片';

  @override
  String get changeImage => '更換圖片';

  @override
  String get titleLabel => '標題';

  @override
  String get artistLabel => '藝術家';

  @override
  String get albumLabel => '專輯';

  @override
  String get songUpdated => '歌曲資訊已更新';

  @override
  String get metadataSaved => '已儲存資料';

  @override
  String get categoryDetailPlay => '播放';

  @override
  String get categoryDetailShuffle => '隨機播放';

  @override
  String get settingsTitle => '設定';

  @override
  String get themeTitle => '主題';

  @override
  String get textColor => '文字顏色';

  @override
  String get backgroundColor => '背景顏色';

  @override
  String get selectTextColor => '選擇文字顏色';

  @override
  String get selectBackgroundColor => '選擇背景顏色';

  @override
  String get backgroundImage => '背景圖片';

  @override
  String get notSet => '未設定';

  @override
  String get removeBackgroundImage => '移除背景圖片';

  @override
  String get adjustBackgroundImage => '調整背景圖片';

  @override
  String get adjustBackgroundImageDesc => '以雙指捏合縮放並移動';

  @override
  String get backgroundOpacity => '不透明度';

  @override
  String get backgroundBlur => '模糊';

  @override
  String get language => '語言';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get languageSystem => '系統語言';

  @override
  String get languageJapanese => '日文';

  @override
  String get languageEnglish => '英文';

  @override
  String get languageKorean => '韓語';

  @override
  String get languageGerman => '德語';

  @override
  String get languageFrench => '法語';

  @override
  String get languageChineseSimplified => '中文(簡體)';

  @override
  String get languageChineseTraditional => '中文(繁體)';

  @override
  String get languageSpanish => '西班牙語';

  @override
  String get languagePortugueseBrazil => '葡萄牙語（巴西）';

  @override
  String get languageRussian => '俄語';

  @override
  String get lyricsDisplayTitle => '歌詞顯示';

  @override
  String lyricsFontSize(String size) {
    return '字體大小：$size';
  }

  @override
  String lyricsContextLines(String count) {
    return '顯示行數（包含目前行）：$count';
  }

  @override
  String get showArtworkBackground => '在背景顯示封面';

  @override
  String get showArtworkBackgroundDesc => '在歌詞後顯示專輯封面';

  @override
  String get playbackTitle => '播放';

  @override
  String get skipSilence => '跳過靜音';

  @override
  String get skipSilenceDesc => '跳過開頭/結尾的靜音部分';

  @override
  String silenceThreshold(int ms) {
    return '閾值：${ms}ms';
  }

  @override
  String get localFilesTitle => '本機檔案';

  @override
  String get importFiles => '匯入檔案';

  @override
  String get importFolder => '匯入資料夾';

  @override
  String get importing => '匯入中...';

  @override
  String importCount(int processed, int total) {
    return '已處理：$processed/$total';
  }

  @override
  String get clearLibraryTitle => '清空資料庫';

  @override
  String get clearLibraryConfirm => '所有本機檔案將被移除。\n此操作無法復原。\n確定要繼續？';

  @override
  String get libraryCleared => '資料庫已清空';

  @override
  String get duplicateDetection => '重複檢測';

  @override
  String get duplicateDetectionDesc => '移除較舊的檔案';

  @override
  String get supportedFormatsTitle => '支援的格式';

  @override
  String get audioFormatsTitle => '音訊格式';

  @override
  String get lyricsFormatsTitle => '歌詞格式';

  @override
  String get lyricsFormatsDesc => 'LRC（時間同步歌詞）';

  @override
  String get supportedQualityTitle => '支援的品質';

  @override
  String get supportedQualityDesc => '無損，Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'LRC 調整';

  @override
  String get selectSong => '選擇歌曲';

  @override
  String offsetLabel(String value) {
    return '位移：$value';
  }

  @override
  String get applyChanges => '套用變更';

  @override
  String get restore => '還原';

  @override
  String get previewTitle => '預覽（前 30 行）';

  @override
  String get lrcFileNotFound => '找不到 LRC 檔案';

  @override
  String loadError(String error) {
    return '載入錯誤：$error';
  }

  @override
  String get offset => '偏移';

  @override
  String get apply => '套用';

  @override
  String get reset => '重置';

  @override
  String get noLrcFileFound => '未找到LRC文件';

  @override
  String get upNext => '接下来播放';

  @override
  String get close => '關閉';

  @override
  String get queueIsEmpty => '队列为空';

  @override
  String get selectASong => '选择歌曲';

  @override
  String get play => '播放';

  @override
  String get applyChanges2 => '应用更改';

  @override
  String get restore2 => '恢复';

  @override
  String get previewFirst30Lines => '预览（前30行）';

  @override
  String get customColor => '自定义颜色';

  @override
  String get darkMode => '深色模式';

  @override
  String get appLanguage => '应用语言';

  @override
  String get followSystemSetting => '系統語言';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get change => '更改';

  @override
  String get selectLanguage2 => '选择语言';

  @override
  String get confirm => '确认';

  @override
  String get execute => '执行';

  @override
  String get noData => '没有数据';

  @override
  String get error => '錯誤';

  @override
  String get delete => '删除';

  @override
  String get search => '搜索';

  @override
  String get artist => '艺术家';

  @override
  String get tracks => '曲目';

  @override
  String get albums => '专辑';

  @override
  String get createPlaylist2 => '创建播放列表';

  @override
  String get playpause => '播放/暂停';

  @override
  String get next => '下一首';

  @override
  String get previous => '上一首';

  @override
  String get collection => '收藏';

  @override
  String get artistTrackAlbum => '艺术家、曲目、专辑';

  @override
  String get welcome => '欢迎';

  @override
  String get getStarted => '开始';

  @override
  String get showDebugInfo => '显示调试信息';

  @override
  String get clear => '清除';

  @override
  String get clearCache => '清除缓存';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get switchTheme => '切换主题';

  @override
  String get light => '明亮';

  @override
  String get dark => '黑暗';

  @override
  String get system => '系统';

  @override
  String get play2 => '播放';

  @override
  String get playQueue => '播放队列';

  @override
  String get remove => '移除';

  @override
  String get migrateSettingsFromOlderVersions => '从旧版本迁移设置';

  @override
  String get tracks2 => '曲数';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get loading => '加载中...';

  @override
  String get offlineMode => '离线模式';

  @override
  String get downloaded => '已下载';

  @override
  String get youtube => 'YouTube 音訊擷取';

  @override
  String get youtubeurl => '剪貼簿中找不到 YouTube URL';

  @override
  String get youtube2 => '將 YouTube 轉換為音訊檔';

  @override
  String get k320Kbps => '320 千位元每秒';

  @override
  String get k441Khz => '44.1 千赫茲';

  @override
  String get mp3M4aFlacWavAiff => 'MP3／M4A／FLAC／WAV／AIFF';

  @override
  String get noLyrics => '無歌詞';

  @override
  String get playbackSpeed => '播放速度';

  @override
  String get loadingLyrics => '歌詞載入中...';

  @override
  String get backgroundCustomize => '背景自訂';

  @override
  String get selectImageFirst => '請先選擇圖片';

  @override
  String get backgroundSet => '背景已設定';

  @override
  String get backgroundSetFailed => '設定背景失敗';

  @override
  String get thumbnailPreview => '縮圖預覽';

  @override
  String get lossless => '無損';

  @override
  String get audioConversionConfirm => '確認音訊轉換';

  @override
  String get confirmDownloadAudioFromVideo => '要下載此影片的音訊嗎？';

  @override
  String get download => '下載';

  @override
  String get videotitle => '已開始下載 \"\$videoTitle\"...';

  @override
  String get videotitle2 => '\"\$videoTitle\" 下載完成！';

  @override
  String get videotitle3 => '下載 \"\$videoTitle\" 失敗';

  @override
  String get downloadCompletedFileNotFound => '下載完成，但找不到檔案';

  @override
  String get downloadCompletedPathUnknown => '下載完成，但檔案路徑未知';

  @override
  String get clipboardEmpty => '剪貼簿是空的';

  @override
  String get outputformat => '輸出格式：\$outputFormat';

  @override
  String get selectOutputFormat => '選擇輸出格式';

  @override
  String get bitrate => '位元率';

  @override
  String get samplingRate => '取樣率';

  @override
  String e(String e) {
    return '錯誤：\$e';
  }

  @override
  String m123(String e) {
    return '裁切失敗：\$e';
  }

  @override
  String channelname(String channelName) {
    return '頻道：\$channelName';
  }

  @override
  String error4(String error) {
    return '下載錯誤：\$error';
  }

  @override
  String get import => '导入';

  @override
  String get export => '导出';

  @override
  String get nowPlaying => '正在播放';

  @override
  String param(Object processed, Object total) {
    return '已處理：$processed/$total';
  }

  @override
  String get nowPlaying2 => '正在播放';

  @override
  String get noSongPlaying => '目前沒有播放歌曲';

  @override
  String get dolbyAtmos => '杜比全景聲';

  @override
  String get k075 => '0.75倍';

  @override
  String get k09 => '0.9倍';

  @override
  String get k10 => '1.0倍';

  @override
  String get k11 => '1.1倍';

  @override
  String get k125 => '1.25倍';

  @override
  String get k15 => '1.5倍';

  @override
  String get k20 => '2.0倍';

  @override
  String get exportToDownloadsDesc => '以新名稱儲存到下載資料夾。';

  @override
  String get exportLrcButton => '下載 LRC';

  @override
  String get exportAudioButton => '下載音訊';

  @override
  String exportLrcSuccess(String fileName) {
    return '已下載 $fileName';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '已下載 $fileName';
  }

  @override
  String get exportLrcFailed => 'LRC 下載失敗';

  @override
  String get exportAudioFailed => '音訊檔案下載失敗';

  @override
  String get exportNoFile => '無檔案';
}
