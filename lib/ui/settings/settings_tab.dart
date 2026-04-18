part of '../app_ui.dart';

// ==============================================================================
// 設定タブ
// ==============================================================================

class _SettingsTab extends ConsumerWidget {
  const _SettingsTab();

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y/$m/$d';
  }

  Future<void> _openSubscriptionCenter(BuildContext context) async {
    final uri = Uri.parse(
      'https://play.google.com/store/account/subscriptions?sku=${PlaySubscriptionService.monthlyProductId}&package=com.likelife.musiclike',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('定期購読管理ページを開けませんでした')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsViewModelProvider);
    final importState = ref.watch(localImportViewModelProvider);
    // YouTubeダウンロード機能は削除済みのため、関連UIは表示しません。

    // Android実機でのストレージ権限確認
    _checkStoragePermissions();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          // YouTubeダウンロード機能は削除済み。UIは表示しません。

          // ============================================================================
          // 定期購読セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '定期購読',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          FutureBuilder<SubscriptionInfo>(
            future: PlaySubscriptionService.instance.getSubscriptionInfo(),
            builder: (context, snapshot) {
              final info = snapshot.data;
              final active = info?.isActive ?? false;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          active ? '広告なしプラン利用中' : '広告なしプラン未加入',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('プラン: 月額1ドル（日本円で150円）'),
                        Text('有効期限: ${_formatDate(info?.expiresAt)}'),
                        Text('次回更新日: ${_formatDate(info?.nextRenewalAt)}'),
                        const SizedBox(height: 8),
                        Text(
                          '※ 次回更新日は端末情報からの推定表示です。正確な請求日は Google Play を確認してください。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (!active)
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Color(settings.themeTextColor),
                                  foregroundColor: Color(settings.themeBackgroundColor),
                                ),
                                onPressed: () async {
                                  final started = await PlaySubscriptionService.instance.purchaseMonthlyPlan();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(started ? 'Google Play の購入画面を開きました' : '購入を開始できませんでした'),
                                    ),
                                  );
                                },
                                child: const Text('購入する'),
                              ),
                            OutlinedButton(
                              onPressed: () async {
                                await PlaySubscriptionService.instance.restorePurchases();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('購入情報の復元を実行しました')),
                                );
                              },
                              child: const Text('購入を復元'),
                            ),
                            TextButton(
                              onPressed: () => _openSubscriptionCenter(context),
                              child: const Text('Google Playで管理/解約'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ============================================================================
          // テーマ設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.themeTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          ListTile(
            title: Text(l10n.textColor),
            subtitle: Text(_colorToHex(settings.themeTextColor)),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(settings.themeTextColor),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.24 * 255).round())),
              ),
            ),
            onTap: () => _showThemeColorDialog(
              context,
              ref,
              title: l10n.selectTextColor,
              currentColor: settings.themeTextColor,
              isBackground: false,
            ),
          ),

          ListTile(
            title: Text(l10n.backgroundColor),
            subtitle: Text(_colorToHex(settings.themeBackgroundColor)),
            trailing: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color(settings.themeBackgroundColor),
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).dividerColor.withAlpha((0.24 * 255).round())),
              ),
            ),
            onTap: () => _showThemeColorDialog(
              context,
              ref,
              title: l10n.selectBackgroundColor,
              currentColor: settings.themeBackgroundColor,
              isBackground: true,
            ),
          ),

          ListTile(
            title: Text(l10n.backgroundImage),
            subtitle: Text(
              settings.backgroundImagePath == null || settings.backgroundImagePath!.isEmpty
                  ? l10n.notSet
                  : p.basename(settings.backgroundImagePath!),
            ),
            trailing: settings.backgroundImagePath == null || settings.backgroundImagePath!.isEmpty
                ? const Icon(Icons.image)
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.removeBackgroundImage,
                    onPressed: () {
                      ref.read(settingsViewModelProvider.notifier).updateSettings(
                            settings.copyWith(
                              backgroundImagePath: '',
                              backgroundImageScale: 1.0,
                              backgroundImageOffsetX: 0.0,
                              backgroundImageOffsetY: 0.0,
                              backgroundImageOpacity: 1.0,
                              backgroundImageBlurSigma: 0.0,
                              backgroundImageBrightness: 1.0,
                            ),
                          );
                    },
                  ),
            onTap: () async {
              final l10n = AppLocalizations.of(context)!;
              final ok = await RewardUnlockService.ensureUnlocked(
                context,
                l10n.adjustBackgroundImage,
              );
              if (!ok) return;
              final result = await FilePicker.platform.pickFiles(type: FileType.image);
              final originalPath = result?.files.single.path;
              if (originalPath != null && originalPath.isNotEmpty) {
                try {
                  final appDir = await getApplicationDocumentsDirectory();
                  final bgDir = Directory(p.join(appDir.path, 'backgrounds'));
                  if (!bgDir.existsSync()) await bgDir.create(recursive: true);
                  final dest = p.join(bgDir.path, p.basename(originalPath));
                  // If same file already exists, append timestamp
                  var destPath = dest;
                  if (File(destPath).existsSync()) {
                    destPath = p.join(
                      bgDir.path,
                      '${p.basenameWithoutExtension(dest)}_${DateTime.now().millisecondsSinceEpoch}${p.extension(dest)}',
                    );
                  }
                  await File(originalPath).copy(destPath);
                  debugPrint('[BG] Copied background image to $destPath');
                  ref.read(settingsViewModelProvider.notifier).updateSettings(
                        settings.copyWith(
                          backgroundImagePath: destPath,
                          backgroundImageScale: 1.0,
                          backgroundImageOffsetX: 0.0,
                          backgroundImageOffsetY: 0.0,
                          backgroundImageOpacity: 1.0,
                          backgroundImageBlurSigma: 0.0,
                          backgroundImageBrightness: 1.0,
                        ),
                      );
                } catch (e) {
                  debugPrint('[BG] 保存に失敗: $e');
                  // fallback: use original path if copy failed
                  ref.read(settingsViewModelProvider.notifier).updateSettings(
                        settings.copyWith(
                          backgroundImagePath: originalPath,
                          backgroundImageScale: 1.0,
                          backgroundImageOffsetX: 0.0,
                          backgroundImageOffsetY: 0.0,
                          backgroundImageOpacity: 1.0,
                          backgroundImageBlurSigma: 0.0,
                          backgroundImageBrightness: 1.0,
                        ),
                      );
                }
              }
            },
          ),

          if (settings.backgroundImagePath != null && settings.backgroundImagePath!.isNotEmpty) ...[
            ListTile(
              title: Text(l10n.adjustBackgroundImage),
              subtitle: Text(l10n.adjustBackgroundImageDesc),
              trailing: const Icon(Icons.tune),
              onTap: () async {
                final l10n = AppLocalizations.of(context)!;
                final ok = await RewardUnlockService.ensureUnlocked(
                  context,
                  l10n.adjustBackgroundImage,
                );
                if (!ok) return;
                _openBackgroundImageEditor(context, ref, settings);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.backgroundOpacity}: ${settings.backgroundImageOpacity.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: settings.backgroundImageOpacity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: (v) {
                      ref.read(settingsViewModelProvider.notifier).updateSettings(
                            settings.copyWith(backgroundImageOpacity: v),
                          );
                    },
                  ),
                  Text(
                    '${_t(context, ja: '背景画像の明度', en: 'Brightness', zh: '亮度', ko: '밝기', ru: 'Яркость')}: ${settings.backgroundImageBrightness.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: settings.backgroundImageBrightness,
                    min: 0.5,
                    max: 1.5,
                    divisions: 20,
                    onChanged: (v) {
                      ref.read(settingsViewModelProvider.notifier).updateSettings(
                            settings.copyWith(backgroundImageBrightness: v),
                          );
                    },
                  ),
                  Text(
                    '${l10n.backgroundBlur}: ${settings.backgroundImageBlurSigma.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Slider(
                    value: settings.backgroundImageBlurSigma,
                    min: 0.0,
                    max: 20.0,
                    divisions: 20,
                    onChanged: (v) {
                      ref.read(settingsViewModelProvider.notifier).updateSettings(
                            settings.copyWith(backgroundImageBlurSigma: v),
                          );
                    },
                  ),
                ],
              ),
            ),
          ],

          // 言語選択
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(_localeLabel(context, settings.locale)),
            onTap: () async {
              final localeOptions = <String>[
                '', // system default
                'ja',
                'en',
                'ko',
                'de',
                'fr',
                'zh_Hans',
                'zh_TW',
                'es',
                'pt_BR',
                'ru',
              ];

              final selected = await showDialog<String?>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: Text(AppLocalizations.of(context)!.selectLanguage),
                  children: localeOptions.map((code) {
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, code),
                      child: Text(_localeLabel(context, code)),
                    );
                  }).toList(),
                ),
              );
              if (selected != null) {
                ref.read(settingsViewModelProvider.notifier).updateSettings(
                      settings.copyWith(locale: selected),
                    );
              }
            },
          ),

          const Divider(),

          // ============================================================================
          // 歌詞表示設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.lyricsDisplayTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
              child: Column(
                children: [
                  // 歌詞のフォントサイズと表示行数の設定
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.lyricsFontSize(settings.lyricsSettings.fontSize.clamp(12.0, 25.0).toStringAsFixed(0)),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Slider(
                          value: settings.lyricsSettings.fontSize.clamp(12.0, 25.0),
                          min: 12.0,
                          max: 25.0,
                          divisions: 13,
                          label: settings.lyricsSettings.fontSize.clamp(12.0, 25.0).toStringAsFixed(0),
                          onChanged: (v) {
                            ref.read(settingsViewModelProvider.notifier).updateSettings(
                                  settings.copyWith(
                                    lyricsSettings: settings.lyricsSettings.copyWith(fontSize: v),
                                  ),
                                );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.lyricsContextLines('${settings.lyricsSettings.contextLines * 2 + 1}'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        // 表示行数スライダー
                        Slider(
                          value: settings.lyricsSettings.contextLines.toDouble(),
                          min: 0,
                          max: 4,
                          divisions: 4,
                          label: '${settings.lyricsSettings.contextLines * 2 + 1}',
                          onChanged: (v) {
                            ref.read(settingsViewModelProvider.notifier).updateSettings(
                                  settings.copyWith(
                                    lyricsSettings: settings.lyricsSettings.copyWith(contextLines: v.toInt()),
                                  ),
                                );
                          },
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: Text(l10n.showArtworkBackground),
                    subtitle: Text(l10n.showArtworkBackgroundDesc),
                    value: settings.lyricsSettings.showBackground,
                    onChanged: (value) {
                      ref.read(settingsViewModelProvider.notifier).updateSettings(
                            settings.copyWith(
                              lyricsSettings: settings.lyricsSettings.copyWith(showBackground: value),
                            ),
                          );
                    },
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // ============================================================================
          // 再生設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.playbackTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
              child: Column(
                children: [
                  // 無音スキップは現時点でバグ調査中のため非表示
                  // SwitchListTile(
                  //   title: Text(l10n.skipSilence),
                  //   subtitle: Text(l10n.skipSilenceDesc),
                  //   value: settings.silenceSkipEnabled,
                  //   onChanged: (value) {
                  //     ref.read(settingsViewModelProvider.notifier).updateSilenceSkip(
                  //           enabled: value,
                  //           threshold: settings.silenceSkipThreshold,
                  //         );
                  //   },
                  // ),
                  // if (settings.silenceSkipEnabled)
                  //   Padding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           l10n.silenceThreshold(settings.silenceSkipThreshold),
                  //           style: Theme.of(context).textTheme.bodySmall,
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Slider(
                  //           value: settings.silenceSkipThreshold.toDouble(),
                  //           min: 500,
                  //           max: 5000,
                  //           divisions: 9,
                  //           label: '${(settings.silenceSkipThreshold / 1000).toStringAsFixed(1)}s',
                  //           onChanged: (value) {
                  //             ref.read(settingsViewModelProvider.notifier).updateSilenceSkip(
                  //                   enabled: settings.silenceSkipEnabled,
                  //                   threshold: value.toInt(),
                  //                 );
                  //           },
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),

          const Divider(),

          // ============================================================================
          // ローカルファイル設定セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.localFilesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _importLocalAudioFiles(context, ref),
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.importFiles),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => _importFolderFiles(context, ref),
              icon: const Icon(Icons.folder),
              label: Text(l10n.importFolder),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          if (importState.isImporting || importState.total > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    importState.statusMessage ?? l10n.importing,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: importState.total > 0
                        ? importState.processed / importState.total
                        : null,
                    minHeight: 6,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppLocalizations.of(context)!.param(importState.processed, importState.total),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.clearLibraryTitle),
                    content: Text(l10n.clearLibraryConfirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.commonCancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await ref.read(musicRepositoryProvider).clearLibrary();
                          await deleteLegacyCopiedMusicDir();
                          debugPrint('[Settings] ライブラリDBクリア完了');

                          // ライブラリを更新
                          final libraryNotifier = ref.read(libraryViewModelProvider.notifier);
                          await libraryNotifier.refreshLibrary();

                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.libraryCleared),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.commonDelete,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.clearLibraryTitle),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          ListTile(
            title: Text(l10n.duplicateDetection),
            subtitle: Text(l10n.duplicateDetectionDesc),
            trailing: Switch(
              value: settings.localFileSettings.duplicateDetection,
              onChanged: (value) async {
                if (!value) {
                  ref.read(settingsViewModelProvider.notifier).updateLocalFileSettings(
                        settings.localFileSettings.copyWith(
                          duplicateDetection: false,
                        ),
                      );
                  return;
                }

                final applyToExisting = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.duplicateDetection),
                    content: Text(
                      _t(
                        context,
                        ja: '一覧にある曲にも適用しますか？新しい曲に更新されます。',
                        en: 'Apply to songs already in the list? They will be updated to newer files.',
                        zh: '也要应用到列表中的歌曲吗？将更新为较新的曲目。',
                        ko: '목록에 있는 곡에도 적용할까요? 더 최신 파일로 업데이트됩니다.',
                        ru: 'Применить и к песням в списке? Они будут обновлены до более новых файлов.',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.commonCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(_t(context, ja: '新しい曲のみ', en: 'New songs only', zh: '仅新曲', ko: '새 곡만', ru: 'Только новые песни')),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(_t(context, ja: '一覧にも適用', en: 'Apply to list', zh: '应用到列表', ko: '목록에도 적용', ru: 'Применить к списку')),
                      ),
                    ],
                  ),
                );

                if (applyToExisting == null) return;

                ref.read(settingsViewModelProvider.notifier).updateLocalFileSettings(
                      settings.localFileSettings.copyWith(
                        duplicateDetection: true,
                      ),
                    );

                if (applyToExisting) {
                  final removed = await ref.read(libraryViewModelProvider.notifier).applyDuplicateDetectionToLibrary();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _t(
                          context,
                          ja: '重複を整理しました: ${removed}件削除',
                          en: 'Duplicates cleaned: $removed removed',
                          zh: '已清理重复: 删除$removed项',
                          ko: '중복 정리 완료: ${removed}개 삭제',
                          ru: 'Дубликаты очищены: удалено $removed',
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),

          const Divider(),

          // ============================================================================
          // 対応フォーマット表示セクション
          // ============================================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.supportedFormatsTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          ListTile(
            title: Text(l10n.audioFormatsTitle),
            subtitle: const Text('MP3, M4A'),
            leading: Icon(Icons.audiotrack, color: Theme.of(context).colorScheme.primary),
          ),

          ListTile(
            title: Text(l10n.lyricsFormatsTitle),
            subtitle: Text(l10n.lyricsFormatsDesc),
            leading: Icon(Icons.lyrics, color: Theme.of(context).colorScheme.primary),
          ),

          ListTile(
            title: Text(l10n.supportedQualityTitle),
            subtitle: Text(l10n.supportedQualityDesc),
            leading: Icon(Icons.high_quality, color: Theme.of(context).colorScheme.primary),
          ),

          const Divider(),

          ListTile(
            title: Text(_t(context, ja: 'バージョン', en: 'Version', zh: '版本', ko: '버전', ru: 'Версия')),
            subtitle: const Text('Ver.1.0.0'),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
