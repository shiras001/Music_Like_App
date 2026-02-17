import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:music_like/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdConfig {
  // 本番用のID
  static const String androidAppId = 'ca-app-pub-2949534183263780~4641527820';
  static const String androidNativeId = 'ca-app-pub-2949534183263780/8801089097';
  static const String androidInterstitialId = 'ca-app-pub-2949534183263780/5801624301';
  static const String androidRewardedId = 'ca-app-pub-2949534183263780/7156010521';

  // Google公式のテスト用ID
  static const String testNativeId = 'ca-app-pub-3940256099942544/2247696110';
  static const String testInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testRewardedId = 'ca-app-pub-3940256099942544/5224354917';

  // true の場合、実運用IDの代わりにテストIDを返す
  static bool useTestAds = false;

  // SDKに登録する任意のテストデバイスID
  static List<String> testDeviceIds = <String>[];

  static const Duration rewardDuration = Duration(minutes: 10);

  static String? nativeAdUnitId() {
    if (Platform.isAndroid) return useTestAds ? testNativeId : androidNativeId;
    return null;
  }

  static String? interstitialAdUnitId() {
    if (Platform.isAndroid) return useTestAds ? testInterstitialId : androidInterstitialId;
    return null;
  }

  static String? rewardedAdUnitId() {
    if (Platform.isAndroid) return useTestAds ? testRewardedId : androidRewardedId;
    return null;
  }

  static void setTestMode(bool enabled, {List<String>? deviceIds}) {
    useTestAds = enabled;
    if (deviceIds != null) {
      testDeviceIds = List<String>.from(deviceIds);
    }
  }
}

class RewardUnlockService {
  static const String _rewardUntilKey = 'reward_unlock_until_ms';

  static Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_rewardUntilKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return now < untilMs;
  }

  static Future<Duration> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final untilMs = prefs.getInt(_rewardUntilKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= untilMs) return Duration.zero;
    return Duration(milliseconds: untilMs - now);
  }

  static Future<void> grant(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt(_rewardUntilKey, now + duration.inMilliseconds);
  }

  static Future<bool> ensureUnlocked(BuildContext context, String actionLabel) async {
    if (await isUnlocked()) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _RewardDialog(actionLabel: actionLabel),
    );
    return result == true;
  }
}

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // 広告表示を再開するため false（本番配信向け）
  static const bool kDisableAds = true;

  static const String _lastInterstitialDateKey = 'last_interstitial_date';

  bool _initialized = false;
  bool _canRequestAds = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kDisableAds) {
      _initialized = true;
      return;
    }

    await _requestConsentIfNeeded();
    if (!_canRequestAds) {
      debugPrint('[Ads] consent not granted or unavailable; skip ad initialization');
      _initialized = true;
      return;
    }

    // テストデバイスIDが指定されている場合、SDKに登録します。
    // 登録すると該当端末は Google Mobile Ads によってテストデバイスとして扱われます。
    try {
      if (AdConfig.testDeviceIds.isNotEmpty) {
        await MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(testDeviceIds: AdConfig.testDeviceIds),
        );
        debugPrint('[Ads] registered test device ids: ${AdConfig.testDeviceIds}');
      }
    } catch (e) {
      debugPrint('[Ads] updateRequestConfiguration failed: $e');
    }

    await MobileAds.instance.initialize();
    _initialized = true;
    _loadInterstitial();
    _loadRewarded();
  }

  /// 実行時にテスト広告モードを有効/無効にし、必要に応じてテストデバイスを登録します。
  void setTestMode(bool enabled, {List<String>? deviceIds}) {
    AdConfig.setTestMode(enabled, deviceIds: deviceIds);
  }

  Future<void> _requestConsentIfNeeded() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(tagForUnderAgeOfConsent: false),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            debugPrint('[Ads] consent form dismissed with error: $formError');
          }
        });
        if (!completer.isCompleted) completer.complete();
      },
      (error) {
        debugPrint('[Ads] consent info update failed: $error');
        if (!completer.isCompleted) completer.complete();
      },
    );

    try {
      await completer.future.timeout(const Duration(seconds: 8));
    } catch (_) {
      debugPrint('[Ads] consent flow timeout; continue with canRequestAds check');
    }

    try {
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (error) {
      debugPrint('[Ads] canRequestAds failed: $error');
      _canRequestAds = false;
    }
  }

  void _loadInterstitial() {
    if (kDisableAds) return;
    if (_loadingInterstitial || _interstitialAd != null) return;
    final unitId = AdConfig.interstitialAdUnitId();
    if (unitId == null || unitId.isEmpty) return;
    _loadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _loadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _loadingInterstitial = false;
          debugPrint('[Ads] interstitial load failed: $error');
        },
      ),
    );
  }

  void _loadRewarded() {
    if (kDisableAds) return;
    if (_loadingRewarded || _rewardedAd != null) return;
    final unitId = AdConfig.rewardedAdUnitId();
    if (unitId == null || unitId.isEmpty) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _loadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _loadingRewarded = false;
          debugPrint('[Ads] rewarded load failed: $error');
        },
      ),
    );
  }

  Future<void> showSettingsInterstitialIfEligible() async {
    if (kDisableAds) return;
    final unitId = AdConfig.interstitialAdUnitId();
    if (unitId == null || unitId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _todayKey();
    final last = prefs.getString(_lastInterstitialDateKey);
    if (last == todayKey) return;

    if (_interstitialAd == null) {
      _loadInterstitial();
      return;
    }

    final ad = _interstitialAd;
    _interstitialAd = null;
    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        await prefs.setString(_lastInterstitialDateKey, todayKey);
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        await prefs.setString(_lastInterstitialDateKey, todayKey);
        ad.dispose();
        _loadInterstitial();
      },
    );
    await ad?.show();
  }

  Future<bool> showRewardedAndGrant() async {
    if (kDisableAds) {
      // 広告が無効化されている場合、ネットワークや広告無しで報酬を自動付与します。
      await RewardUnlockService.grant(AdConfig.rewardDuration);
      return true;
    }
    if (_rewardedAd == null) {
      _loadRewarded();
      return false;
    }
    final ad = _rewardedAd;
    _rewardedAd = null;
    bool rewarded = false;
    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadRewarded();
      },
    );
    await ad?.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
      },
    );
    if (rewarded) {
      await RewardUnlockService.grant(AdConfig.rewardDuration);
    }
    return rewarded;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }
}

class _RewardDialog extends StatefulWidget {
  final String actionLabel;

  const _RewardDialog({required this.actionLabel});

  @override
  State<_RewardDialog> createState() => _RewardDialogState();
}

class _RewardDialogState extends State<_RewardDialog> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(l10n.confirm),
      content: Text(
        widget.actionLabel,
        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.commonCancel),
        ),
        TextButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);
                  final ok = await AdService.instance.showRewardedAndGrant();
                  if (!mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.error)),
                    );
                  }
                  Navigator.pop(context, ok);
                },
          child: _loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.execute),
        ),
      ],
    );
  }
}
