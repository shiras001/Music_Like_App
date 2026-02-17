part of '../app_ui.dart';

extension _SettingsHelpers on _SettingsTab {
  /// クリップボードから文字列を取得
  Future<String?> _getClipboardText() async {
    try {
      final data = await Clipboard.getData('text/plain');
      return data?.text;
    } catch (e) {
      debugPrint('Clipboard error: $e');
      return null;
    }
  }

  /// YouTubeのURLであるか検証
  bool _isYouTubeUrl(String url) {
    final youtubePatterns = [
      RegExp(r'(?:https?:\/\/)?(?:www\.)?youtube\.com'),
      RegExp(r'(?:https?:\/\/)?(?:www\.)?youtu\.be'),
    ];
    return youtubePatterns.any((pattern) => pattern.hasMatch(url));
  }

  String _colorToHex(int color) {
    final value = color & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  String _localeLabel(BuildContext context, String code) {
    // If code is empty, treat as "follow system" and show the localized
    // label for that choice so the top item reads e.g. "システム言語".
    final trimmed = code.trim();
      if (trimmed.isEmpty) {
        return AppLocalizations.of(context)!.followSystemSetting;
    }
    // Return the language name as it is called in the language itself
    // e.g. for 'en' -> 'English', for 'ja' -> '日本語'
    String targetCode = trimmed;

    // Create a Locale instance for the target code and lookup its AppLocalizations
    Locale _localeForCode(String code) {
      switch (code) {
        case 'pt_BR':
          return const Locale('pt', 'BR');
        case 'zh_TW':
          return const Locale('zh', 'TW');
        case 'zh_Hans':
          return const Locale('zh');
        default:
          return Locale(code);
      }
    }

    final l = lookupAppLocalizations(_localeForCode(targetCode));
    switch (targetCode) {
      case 'ja':
        return l.languageJapanese;
      case 'en':
        return l.languageEnglish;
      case 'ko':
        return l.languageKorean;
      case 'de':
        return l.languageGerman;
      case 'fr':
        return l.languageFrench;
      case 'zh_Hans':
      case 'zh':
        return l.languageChineseSimplified;
      case 'zh_TW':
        return l.languageChineseTraditional;
      case 'es':
        return l.languageSpanish;
      case 'pt_BR':
      case 'pt':
        return l.languagePortugueseBrazil;
      case 'ru':
        return l.languageRussian;
      default:
        return targetCode;
    }
  }

  void _showThemeColorDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int currentColor,
    required bool isBackground,
  }) {
    int selectedColor = currentColor;
    final presetColors = <int>[
      0xFF000000,
      0xFF2C2C2E,
      0xFFFFFFFF,
      0xFFFF2D55,
      0xFF0A84FF,
      0xFF30D158,
      0xFFFF9F0A,
      0xFFBF5AF2,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          bool _shouldShowColorWarning() {
            if (!isBackground) return false;
            final bgColor = Color(selectedColor);
            final textColor = Color(ref.read(settingsViewModelProvider).themeTextColor);
            final bgR = bgColor.red.clamp(0, 255);
            final bgG = bgColor.green.clamp(0, 255);
            final bgB = bgColor.blue.clamp(0, 255);
            final textR = textColor.red.clamp(0, 255);
            final textG = textColor.green.clamp(0, 255);
            final textB = textColor.blue.clamp(0, 255);
            final distance = ((bgR - textR).abs() + (bgG - textG).abs() + (bgB - textB).abs()) / 3;
            return distance < 60;
          }

          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_shouldShowColorWarning())
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade900.withAlpha((0.3 * 255).round()),
                        border: Border.all(color: Colors.orange.shade700),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange[300], size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _t(
                                context,
                                ja: '背景と文字の色が近いため、テキストが見難くなる可能性があります',
                                en: 'Background and text colors are too similar and may reduce readability.',
                                zh: '背景色与文字颜色过于接近，可能影响可读性。',
                              ),
                              style: TextStyle(color: Colors.orange[300], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  // Use Wrap instead of GridView to avoid viewport intrinsic-measure
                  // calculations inside AlertDialog which can trigger render exceptions
                  // on some devices. Give each color a fixed size so layout is stable.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).dividerColor.withAlpha((0.24 * 255).round()),
                              width: selectedColor == color ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await _showCustomColorPicker(context, selectedColor);
                      if (result != null) {
                        if (isBackground) {
                          ref.read(settingsViewModelProvider.notifier).updateThemeColors(backgroundColor: result);
                        } else {
                          ref.read(settingsViewModelProvider.notifier).updateThemeColors(textColor: result);
                        }
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.palette_outlined),
                    label: Text(AppLocalizations.of(context)!.customColor),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.commonCancel),
              ),
              ElevatedButton(
                onPressed: () {
                  if (isBackground) {
                    ref.read(settingsViewModelProvider.notifier).updateThemeColors(backgroundColor: selectedColor);
                  } else {
                    ref.read(settingsViewModelProvider.notifier).updateThemeColors(textColor: selectedColor);
                  }
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.commonSave),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<int?> _showCustomColorPicker(BuildContext context, int currentColor) async {
    int selectedColor = currentColor;
    final controller = TextEditingController(text: _colorToHex(selectedColor));
    bool isEditingHex = false;

    int? _parseHexColor(String input) {
      var text = input.trim();
      if (text.startsWith('#')) {
        text = text.substring(1);
      }
      if (text.length == 6) {
        text = 'FF$text';
      }
      if (text.length != 8) return null;
      final value = int.tryParse(text, radix: 16);
      if (value == null) return null;
      return value;
    }

    return showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.customColor),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: Color(selectedColor),
                    onColorChanged: (color) {
                      setState(() {
                        selectedColor = color.value;
                        if (!isEditingHex) {
                          controller.text = _colorToHex(selectedColor);
                        }
                      });
                    },
                    enableAlpha: true,
                    pickerAreaHeightPercent: 0.4,
                    displayThumbColor: true,
                    showLabel: false,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: _t(context, ja: 'カラーコード', en: 'Color code', zh: '颜色代码'),
                      hintText: _t(context, ja: '#RRGGBB または #AARRGGBB', en: '#RRGGBB or #AARRGGBB', zh: '#RRGGBB 或 #AARRGGBB'),
                    ),
                    onChanged: (value) {
                      isEditingHex = true;
                      final parsed = _parseHexColor(value);
                      if (parsed != null) {
                        setState(() {
                          selectedColor = parsed;
                        });
                      }
                      isEditingHex = false;
                    },
                    onSubmitted: (value) {
                      final parsed = _parseHexColor(value);
                      if (parsed != null) {
                        setState(() {
                          selectedColor = parsed;
                          controller.text = _colorToHex(selectedColor);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.commonCancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedColor),
                child: Text(AppLocalizations.of(context)!.commonSave),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openBackgroundImageEditor(
    BuildContext context,
    WidgetRef ref,
    AppSettings settings,
  ) async {
    final path = settings.backgroundImagePath;
    if (path == null || path.isEmpty) return;
    final result = await Navigator.push<BackgroundTransformResult>(
      context,
      MaterialPageRoute(
        builder: (_) => BackgroundImageEditor(
          imagePath: path,
          initialScale: settings.backgroundImageScale.clamp(0.5, 4.0),
          initialOffsetX: settings.backgroundImageOffsetX.clamp(-1.0, 1.0),
          initialOffsetY: settings.backgroundImageOffsetY.clamp(-1.0, 1.0),
          themeBackgroundColor: Color(settings.themeBackgroundColor),
          themeTextColor: Color(settings.themeTextColor),
        ),
      ),
    );
    if (result == null) return;
    ref.read(settingsViewModelProvider.notifier).updateSettings(
          settings.copyWith(
            backgroundImageScale: result.scale,
            backgroundImageOffsetX: result.offsetX,
            backgroundImageOffsetY: result.offsetY,
          ),
        );
  }
}
