// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDetails => 'Detalhes';

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
  String get errorDetailsTitle => 'Detalhes do erro';

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
  String get selectImage => 'Selecionar imagem';

  @override
  String get changeImage => 'Alterar imagem';

  @override
  String get titleLabel => 'Title';

  @override
  String get artistLabel => 'Artista';

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
  String get adjustBackgroundImage => 'Ajustar imagem de fundo';

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
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageChineseSimplified => 'Chinês (simplificado)';

  @override
  String get languageChineseTraditional => 'Chinês (tradicional)';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageRussian => 'Russo';

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
  String get offset => 'Deslocamento';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Redefinir';

  @override
  String get noLrcFileFound => 'Nenhum arquivo LRC encontrado';

  @override
  String get upNext => 'A seguir';

  @override
  String get close => 'Fechar';

  @override
  String get queueIsEmpty => 'A fila está vazia';

  @override
  String get selectASong => 'Selecione uma música';

  @override
  String get play => 'Reproduzir';

  @override
  String get applyChanges2 => 'Aplicar alterações';

  @override
  String get restore2 => 'Restaurar';

  @override
  String get previewFirst30Lines => 'Prévia (primeiras 30 linhas)';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystemSetting => 'Idioma do sistema';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get change => 'Alterar';

  @override
  String get selectLanguage2 => 'Select language';

  @override
  String get confirm => 'Confirmar';

  @override
  String get execute => 'Executar';

  @override
  String get noData => 'Sem dados';

  @override
  String get error => 'Erro';

  @override
  String get delete => 'Excluir';

  @override
  String get search => 'Pesquisar';

  @override
  String get artist => 'Artista';

  @override
  String get tracks => 'Faixas';

  @override
  String get albums => 'Álbuns';

  @override
  String get createPlaylist2 => 'Criar playlist';

  @override
  String get playpause => 'Reproduzir/Pausar';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get collection => 'Coleção';

  @override
  String get artistTrackAlbum => 'Artista, faixa, álbum';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get getStarted => 'Começar';

  @override
  String get showDebugInfo => 'Mostrar informações de depuração';

  @override
  String get clear => 'Limpar';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get switchTheme => 'Alternar tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get system => 'Sistema';

  @override
  String get play2 => 'Reproduzir';

  @override
  String get playQueue => 'Reproduzir fila';

  @override
  String get remove => 'Remover';

  @override
  String get migrateSettingsFromOlderVersions =>
      'Migrar configurações de versões antigas';

  @override
  String get tracks2 => 'Faixas';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String get loading => 'Carregando...';

  @override
  String get offlineMode => 'Modo offline';

  @override
  String get downloaded => 'Baixado';

  @override
  String get youtube => 'Extração de áudio do YouTube';

  @override
  String get youtubeurl =>
      'Nenhuma URL do YouTube encontrada na área de transferência';

  @override
  String get youtube2 => 'Converter YouTube para arquivo de áudio';

  @override
  String get k320Kbps => '320 kb/s';

  @override
  String get k441Khz => '44,1 kHz';

  @override
  String get mp3M4aFlacWavAiff => 'MP3 / M4A / FLAC / WAV / AIFF';

  @override
  String get noLyrics => 'Sem letras';

  @override
  String get playbackSpeed => 'Velocidade de reprodução';

  @override
  String get loadingLyrics => 'Carregando letras...';

  @override
  String get backgroundCustomize => 'Personalizar plano de fundo';

  @override
  String get selectImageFirst => 'Selecione uma imagem primeiro';

  @override
  String get backgroundSet => 'Plano de fundo definido';

  @override
  String get backgroundSetFailed => 'Falha ao definir plano de fundo';

  @override
  String get thumbnailPreview => 'Prévia da miniatura';

  @override
  String get lossless => 'Sem perdas';

  @override
  String get audioConversionConfirm => 'Confirmar conversão de áudio';

  @override
  String get confirmDownloadAudioFromVideo => 'Baixar o áudio deste vídeo?';

  @override
  String get download => 'Baixar';

  @override
  String get videotitle => 'Iniciando download de \"\$videoTitle\"...';

  @override
  String get videotitle2 => 'Download de \"\$videoTitle\" concluído!';

  @override
  String get videotitle3 => 'Falha ao baixar \"\$videoTitle\"';

  @override
  String get downloadCompletedFileNotFound =>
      'Download concluído, mas arquivo não encontrado';

  @override
  String get downloadCompletedPathUnknown =>
      'Download concluído, mas caminho do arquivo desconhecido';

  @override
  String get clipboardEmpty => 'A área de transferência está vazia';

  @override
  String get outputformat => 'Formato de saída: \$outputFormat';

  @override
  String get selectOutputFormat => 'Selecionar formato de saída';

  @override
  String get bitrate => 'Taxa de bits';

  @override
  String get samplingRate => 'Taxa de amostragem';

  @override
  String e(String e) {
    return 'Erro: \$e';
  }

  @override
  String m123(String e) {
    return 'Falha no corte: \$e';
  }

  @override
  String channelname(String channelName) {
    return 'Canal: \$channelName';
  }

  @override
  String error4(String error) {
    return 'Erro de download: \$error';
  }

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get nowPlaying => 'Tocando agora';

  @override
  String param(Object processed, Object total) {
    return 'Processado: $processed/$total';
  }

  @override
  String get nowPlaying2 => 'Tocando agora';

  @override
  String get noSongPlaying => 'Nenhuma música tocando';

  @override
  String get dolbyAtmos => 'Dolby Atmos (áudio espacial)';

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
      'Guardar na pasta de transferências com outro nome.';

  @override
  String get exportLrcButton => 'Transferir LRC';

  @override
  String get exportAudioButton => 'Transferir áudio';

  @override
  String exportLrcSuccess(String fileName) {
    return '$fileName transferido';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '$fileName transferido';
  }

  @override
  String get exportLrcFailed => 'Falha ao transferir LRC';

  @override
  String get exportAudioFailed => 'Falha ao transferir áudio';

  @override
  String get exportNoFile => 'Sem ficheiro';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Music Like';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Salvar';

  @override
  String get commonClose => 'Fechar';

  @override
  String get commonDetails => 'Detalhes';

  @override
  String get commonDelete => 'Excluir';

  @override
  String get commonApply => 'Aplicar';

  @override
  String get commonReset => 'Redefinir';

  @override
  String get commonPlay => 'Reproduzir';

  @override
  String get commonShuffle => 'Aleatório';

  @override
  String get commonSearch => 'Pesquisar';

  @override
  String get commonSort => 'Ordenar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonRetry => 'Tentar novamente';

  @override
  String get commonSaveChanges => 'Salvar';

  @override
  String get tabSongs => 'Músicas';

  @override
  String get tabArtists => 'Artistas';

  @override
  String get tabAlbums => 'Álbuns';

  @override
  String get tabPlaylists => 'Listas';

  @override
  String get drawerSettings => 'Configurações';

  @override
  String get drawerEditCategories => 'Editar categorias';

  @override
  String get drawerSort => 'Ordenar';

  @override
  String get libraryLoadFailed => 'Falha ao carregar a biblioteca';

  @override
  String get libraryReload => 'Recarregar';

  @override
  String get errorDetailsTitle => 'Detalhes do erro';

  @override
  String get errorClose => 'Fechar';

  @override
  String get searchHint => 'Música, artista ou álbum';

  @override
  String get categoryEditTitle => 'Editar categorias';

  @override
  String get categorySongs => 'Músicas';

  @override
  String get categoryArtists => 'Artistas';

  @override
  String get categoryAlbums => 'Álbuns';

  @override
  String get categoryPlaylists => 'Listas de reprodução';

  @override
  String get sortTitleAsc => 'Título (A-Z)';

  @override
  String get sortTitleDesc => 'Título (Z-A)';

  @override
  String get sortArtistAsc => 'Artista (A-Z)';

  @override
  String get sortArtistDesc => 'Artista (Z-A)';

  @override
  String get sortDurationAsc => 'Duração (mais curta)';

  @override
  String get sortDurationDesc => 'Duração (mais longa)';

  @override
  String get noSongs => 'Sem músicas';

  @override
  String get noArtists => 'Sem artistas';

  @override
  String get noAlbums => 'Sem álbuns';

  @override
  String get noPlaylists => 'Sem playlists';

  @override
  String get noResults => 'Sem resultados';

  @override
  String songCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '1 música',
      zero: '0 músicas',
    );
    return '$_temp0';
  }

  @override
  String artistSongCount(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count músicas',
      one: '1 música',
    );
    return '$artist • $_temp0';
  }

  @override
  String get searchTitle => 'Pesquisar';

  @override
  String get searchPrompt => 'Pesquisar por música, artista ou álbum';

  @override
  String get sectionSongs => 'Músicas';

  @override
  String get sectionArtists => 'Artistas';

  @override
  String get sectionAlbums => 'Álbuns';

  @override
  String get selectImage => 'Selecionar imagem';

  @override
  String get changeImage => 'Alterar imagem';

  @override
  String get artistLabel => 'Artista';

  @override
  String get metadataSaved => 'Metadados salvos';

  @override
  String get categoryDetailPlay => 'Reproduzir';

  @override
  String get categoryDetailShuffle => 'Aleatório';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get themeTitle => 'Tema';

  @override
  String get textColor => 'Cor do texto';

  @override
  String get backgroundColor => 'Cor de fundo';

  @override
  String get selectTextColor => 'Selecionar cor do texto';

  @override
  String get selectBackgroundColor => 'Selecionar cor de fundo';

  @override
  String get backgroundImage => 'Imagem de fundo';

  @override
  String get notSet => 'Não definido';

  @override
  String get removeBackgroundImage => 'Remover imagem de fundo';

  @override
  String get adjustBackgroundImage => 'Ajustar imagem de fundo';

  @override
  String get adjustBackgroundImageDesc => 'Pinçar para aumentar e mover';

  @override
  String get backgroundOpacity => 'Opacidade';

  @override
  String get backgroundBlur => 'Desfoque';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get languageSystem => 'Idioma do sistema';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageChineseSimplified => 'Chinês (simplificado)';

  @override
  String get languageChineseTraditional => 'Chinês (tradicional)';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languagePortugueseBrazil => 'Português (Brasil)';

  @override
  String get languageRussian => 'Russo';

  @override
  String get lyricsDisplayTitle => 'Exibição de letras';

  @override
  String lyricsFontSize(String size) {
    return 'Tamanho da fonte: $size';
  }

  @override
  String lyricsContextLines(String count) {
    return 'Linhas a mostrar (incluindo a atual): $count';
  }

  @override
  String get showArtworkBackground => 'Mostrar capa no fundo';

  @override
  String get showArtworkBackgroundDesc =>
      'Mostrar a capa do álbum atrás das letras';

  @override
  String get playbackTitle => 'Reprodução';

  @override
  String get skipSilence => 'Pular silêncio';

  @override
  String get skipSilenceDesc => 'Pular partes silenciosas no início/fim';

  @override
  String silenceThreshold(int ms) {
    return 'Limite: ${ms}ms';
  }

  @override
  String get localFilesTitle => 'Arquivos locais';

  @override
  String get importFiles => 'Importar arquivos';

  @override
  String get importFolder => 'Importar pasta';

  @override
  String get importing => 'Importando...';

  @override
  String importCount(int processed, int total) {
    return 'Processado: $processed/$total';
  }

  @override
  String get clearLibraryTitle => 'Limpar biblioteca';

  @override
  String get clearLibraryConfirm =>
      'Todos os arquivos locais serão removidos.\nEsta ação não pode ser desfeita.\nTem certeza?';

  @override
  String get libraryCleared => 'Biblioteca limpa';

  @override
  String get duplicateDetection => 'Detecção de duplicatas';

  @override
  String get duplicateDetectionDesc => 'Remover arquivos mais antigos';

  @override
  String get supportedFormatsTitle => 'Formatos suportados';

  @override
  String get audioFormatsTitle => 'Formatos de áudio';

  @override
  String get lyricsFormatsTitle => 'Formatos de letras';

  @override
  String get lyricsFormatsDesc => 'LRC (letras sincronizadas)';

  @override
  String get supportedQualityTitle => 'Qualidade suportada';

  @override
  String get supportedQualityDesc => 'Sem perdas, Dolby Atmos';

  @override
  String get lrcAdjustTitle => 'Ajuste LRC';

  @override
  String get selectSong => 'Selecionar uma música';

  @override
  String offsetLabel(String value) {
    return 'Deslocamento: $value';
  }

  @override
  String get applyChanges => 'Aplicar alterações';

  @override
  String get restore => 'Restaurar';

  @override
  String get previewTitle => 'Visualização (primeiras 30 linhas)';

  @override
  String get lrcFileNotFound => 'Arquivo LRC não encontrado';

  @override
  String loadError(String error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String get offset => 'Deslocamento';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Redefinir';

  @override
  String get noLrcFileFound => 'Nenhum arquivo LRC encontrado';

  @override
  String get upNext => 'A seguir';

  @override
  String get close => 'Fechar';

  @override
  String get queueIsEmpty => 'A fila está vazia';

  @override
  String get selectASong => 'Selecione uma música';

  @override
  String get play => 'Reproduzir';

  @override
  String get applyChanges2 => 'Aplicar alterações';

  @override
  String get restore2 => 'Restaurar';

  @override
  String get previewFirst30Lines => 'Prévia (primeiras 30 linhas)';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get appLanguage => 'App language';

  @override
  String get followSystemSetting => 'Idioma do sistema';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get change => 'Alterar';

  @override
  String get selectLanguage2 => 'Select language';

  @override
  String get confirm => 'Confirmar';

  @override
  String get execute => 'Executar';

  @override
  String get noData => 'Sem dados';

  @override
  String get error => 'Erro';

  @override
  String get delete => 'Excluir';

  @override
  String get search => 'Pesquisar';

  @override
  String get artist => 'Artista';

  @override
  String get tracks => 'Faixas';

  @override
  String get albums => 'Álbuns';

  @override
  String get createPlaylist2 => 'Criar playlist';

  @override
  String get playpause => 'Reproduzir/Pausar';

  @override
  String get next => 'Próximo';

  @override
  String get previous => 'Anterior';

  @override
  String get collection => 'Coleção';

  @override
  String get artistTrackAlbum => 'Artista, faixa, álbum';

  @override
  String get welcome => 'Bem-vindo';

  @override
  String get getStarted => 'Começar';

  @override
  String get showDebugInfo => 'Mostrar informações de depuração';

  @override
  String get clear => 'Limpar';

  @override
  String get clearCache => 'Limpar cache';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get switchTheme => 'Alternar tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get system => 'Sistema';

  @override
  String get play2 => 'Reproduzir';

  @override
  String get playQueue => 'Reproduzir fila';

  @override
  String get remove => 'Remover';

  @override
  String get migrateSettingsFromOlderVersions =>
      'Migrar configurações de versões antigas';

  @override
  String get tracks2 => 'Faixas';

  @override
  String get anErrorOccurred => 'Ocorreu um erro';

  @override
  String get loading => 'Carregando...';

  @override
  String get offlineMode => 'Modo offline';

  @override
  String get downloaded => 'Baixado';

  @override
  String get youtube => 'Extração de áudio do YouTube';

  @override
  String get youtubeurl =>
      'Nenhuma URL do YouTube encontrada na área de transferência';

  @override
  String get youtube2 => 'Converter YouTube para arquivo de áudio';

  @override
  String get k320Kbps => '320 kb/s';

  @override
  String get k441Khz => '44,1 kHz';

  @override
  String get mp3M4aFlacWavAiff => 'MP3 / M4A / FLAC / WAV / AIFF';

  @override
  String get noLyrics => 'Sem letras';

  @override
  String get playbackSpeed => 'Velocidade de reprodução';

  @override
  String get loadingLyrics => 'Carregando letras...';

  @override
  String get backgroundCustomize => 'Personalizar plano de fundo';

  @override
  String get selectImageFirst => 'Selecione uma imagem primeiro';

  @override
  String get backgroundSet => 'Plano de fundo definido';

  @override
  String get backgroundSetFailed => 'Falha ao definir plano de fundo';

  @override
  String get thumbnailPreview => 'Prévia da miniatura';

  @override
  String get lossless => 'Sem perdas';

  @override
  String get audioConversionConfirm => 'Confirmar conversão de áudio';

  @override
  String get confirmDownloadAudioFromVideo => 'Baixar o áudio deste vídeo?';

  @override
  String get download => 'Baixar';

  @override
  String get videotitle => 'Iniciando download de \"\$videoTitle\"...';

  @override
  String get videotitle2 => 'Download de \"\$videoTitle\" concluído!';

  @override
  String get videotitle3 => 'Falha ao baixar \"\$videoTitle\"';

  @override
  String get downloadCompletedFileNotFound =>
      'Download concluído, mas arquivo não encontrado';

  @override
  String get downloadCompletedPathUnknown =>
      'Download concluído, mas caminho do arquivo desconhecido';

  @override
  String get clipboardEmpty => 'A área de transferência está vazia';

  @override
  String get outputformat => 'Formato de saída: \$outputFormat';

  @override
  String get selectOutputFormat => 'Selecionar formato de saída';

  @override
  String get bitrate => 'Taxa de bits';

  @override
  String get samplingRate => 'Taxa de amostragem';

  @override
  String e(String e) {
    return 'Erro: \$e';
  }

  @override
  String m123(String e) {
    return 'Falha no corte: \$e';
  }

  @override
  String channelname(String channelName) {
    return 'Canal: \$channelName';
  }

  @override
  String error4(String error) {
    return 'Erro de download: \$error';
  }

  @override
  String get import => 'Importar';

  @override
  String get export => 'Exportar';

  @override
  String get nowPlaying => 'Tocando agora';

  @override
  String param(Object processed, Object total) {
    return 'Processado: $processed/$total';
  }

  @override
  String get nowPlaying2 => 'Tocando agora';

  @override
  String get noSongPlaying => 'Nenhuma música tocando';

  @override
  String get dolbyAtmos => 'Dolby Atmos (áudio espacial)';

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
      'Salvar na pasta de downloads com outro nome.';

  @override
  String get exportLrcButton => 'Baixar LRC';

  @override
  String get exportAudioButton => 'Baixar áudio';

  @override
  String exportLrcSuccess(String fileName) {
    return '$fileName baixado';
  }

  @override
  String exportAudioSuccess(String fileName) {
    return '$fileName baixado';
  }

  @override
  String get exportLrcFailed => 'Falha ao baixar LRC';

  @override
  String get exportAudioFailed => 'Falha ao baixar áudio';

  @override
  String get exportNoFile => 'Sem arquivo';
}
