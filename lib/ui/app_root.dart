part of 'app_ui.dart';

bool _notificationRequestScheduled = false;
bool _audioServiceInitScheduled = false;
bool _adsInitScheduled = false;
bool _subscriptionInitScheduled = false;

/// アプリ全体のルートウィジェット
class MusicLikeApp extends ConsumerWidget {
  const MusicLikeApp({super.key});

  Locale _resolveLocale(String code) {
    if (code.contains('_')) {
      final parts = code.split('_');
      if (parts.length >= 2) {
        return Locale(parts[0], parts[1]);
      }
    }
    if (code == 'zh') {
      return const Locale('zh', 'Hans');
    }
    return Locale(code);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_notificationRequestScheduled) {
      _notificationRequestScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestNotificationPermission();
        _requestMediaPermissions();
      });
    }
    if (!_audioServiceInitScheduled) {
      _audioServiceInitScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(playerViewModelProvider.notifier).ensureAudioServiceInitialized();
      });
    }
    if (!_adsInitScheduled) {
      _adsInitScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AdService.instance.initialize();
      });
    }
    if (!_subscriptionInitScheduled) {
      _subscriptionInitScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PlaySubscriptionService.instance.initialize();
      });
    }
    // AudioService は PlayerViewModel 側の ensureAudioServiceInitialized()
    // で初期化されます。プラットフォーム固有のネイティブ初期化呼び出し
    // (nativeAudioServiceProvider) は廃止し、audio_service + just_audio
    // ベースの実装に統一します。Android/iOS のマニフェスト変更は
    // ロック画面参考資料.md に従ってください。
    final settings = ref.watch(settingsViewModelProvider);

    final themeBackground = Color(settings.themeBackgroundColor);
    // 背景画像使用時でもダイアログ/メニューは透過しないように常に不透明化
    final opaqueThemeBackground = themeBackground.withAlpha(255);
    final themeText = Color(settings.themeTextColor);
    final themeAccent = Color(settings.themeTextColor);
    final backgroundImagePath = settings.backgroundImagePath;
    final hasBackgroundImage = backgroundImagePath != null && backgroundImagePath.isNotEmpty && File(backgroundImagePath).existsSync();
    final brightness = ThemeData.estimateBrightnessForColor(themeBackground);
    final baseTheme = brightness == Brightness.dark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);
    final lineColor = brightness == Brightness.light
      ? Colors.black
      : Theme.of(context).colorScheme.onSurface;

    final localeCode = settings.locale.trim();
    final forcedLocale = localeCode.isEmpty ? null : _resolveLocale(localeCode);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: forcedLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        if (forcedLocale != null) return forcedLocale;
        if (deviceLocale == null) return const Locale('en');
        for (final locale in supportedLocales) {
          if (locale.languageCode == deviceLocale.languageCode) {
            return locale;
          }
        }
        return const Locale('en');
      },
      theme: baseTheme.copyWith(
        dividerColor: lineColor,
        brightness: brightness,
        primaryColor: themeAccent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeAccent,
          brightness: brightness,
          surface: opaqueThemeBackground,
        ),
        scaffoldBackgroundColor: hasBackgroundImage ? Colors.transparent : themeBackground,
        textTheme: baseTheme.textTheme.apply(
          bodyColor: themeText,
          displayColor: themeText,
        ),
        appBarTheme: AppBarTheme(
          // ヘッダーは背景画像表示時により半透明にする
          backgroundColor: hasBackgroundImage ? opaqueThemeBackground.withAlpha((0.65 * 255).round()) : opaqueThemeBackground,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: themeText,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          iconTheme: IconThemeData(color: themeText),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: themeAccent,
          inactiveTrackColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          thumbColor: themeAccent,
          overlayColor: themeAccent.withAlpha((0.3 * 255).round()),
          trackHeight: 3.0,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
        ),
        // ボタンテーマ
        filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
            backgroundColor: themeAccent,
            foregroundColor: themeText,
            textStyle: TextStyle(color: themeText, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: themeText,
            side: BorderSide(color: themeText.withAlpha((0.3 * 255).round())),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: themeAccent,
          ),
        ),
        // ダイアログテーマ
        dialogTheme: baseTheme.dialogTheme.copyWith(
          backgroundColor: opaqueThemeBackground,
          surfaceTintColor: Colors.transparent,
        ),
        // リストタイルテーマ
        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          textColor: themeText,
          iconColor: themeText.withAlpha((0.7 * 255).round()),
        ),
        // PopupMenuボタンテーマ
        popupMenuTheme: PopupMenuThemeData(
          color: opaqueThemeBackground,
        ),
        // ボトムシート（コンテキストメニュー含む）背景も不透明化
        bottomSheetTheme: baseTheme.bottomSheetTheme.copyWith(
          backgroundColor: opaqueThemeBackground,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      // ===== MaterialApp.builder: アプリ全体の背景画像描画 =====
      // ここで settings の backgroundImageScale / OffsetX / OffsetY を使って
      // Transform を作成し、全体背景として描画します。
      // - エディタ側（_BackgroundImageEditor）で設定した scale/offset が
      //   同じ意味（同じ正規化と行列適用順）で解釈されているかを確認してください。
      // - Zoom時にズレが発生する場合は、translate→scale と scale→translate の適用順や
      //   offset の正規化係数（ここでは *0.5 で幅/高さを割っています）を合わせる必要があります。
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (!hasBackgroundImage) {
          return Stack(
            children: [
              content,
              _TopMessageHost(notifier: _appMessageNotifier),
            ],
          );
        }
        final scale = settings.backgroundImageScale.clamp(0.5, 4.0);
        final offsetX = settings.backgroundImageOffsetX.clamp(-1.0, 1.0);
        final offsetY = settings.backgroundImageOffsetY.clamp(-1.0, 1.0);
        final opacity = settings.backgroundImageOpacity.clamp(0.0, 1.0);
        final blur = settings.backgroundImageBlurSigma.clamp(0.0, 30.0);
        final brightness = settings.backgroundImageBrightness.clamp(0.5, 1.5);
        return LayoutBuilder(
          builder: (context, constraints) {
            final dx = offsetX * constraints.maxWidth;
            final dy = offsetY * constraints.maxHeight;
            // デバッグ出力: ランタイム側で適用する変換値を表示
            debugPrint('[BG RUNTIME] settings scale=$scale offsetX=${offsetX.toStringAsFixed(4)} offsetY=${offsetY.toStringAsFixed(4)} dx=${dx.toStringAsFixed(2)} dy=${dy.toStringAsFixed(2)} viewport=${constraints.maxWidth.toStringAsFixed(0)}x${constraints.maxHeight.toStringAsFixed(0)} opacity=${opacity.toStringAsFixed(2)} blur=${blur.toStringAsFixed(1)}');
            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: opacity,
                    child: ImageFiltered(
                      imageFilter: blur > 0
                          ? ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur)
                          : ui.ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          brightness, 0, 0, 0, 0,
                          0, brightness, 0, 0, 0,
                          0, 0, brightness, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: BackgroundLayer(
                          imagePath: backgroundImagePath,
                          containerSize: Size(constraints.maxWidth, constraints.maxHeight),
                          scale: scale,
                          offsetX: offsetX,
                          offsetY: offsetY,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(color: Colors.transparent),
                ),
                Positioned.fill(child: content),
                _TopMessageHost(notifier: _appMessageNotifier),
              ],
            );
          },
        );
      },
      home: const MainScreen(),
    );
  }
}
