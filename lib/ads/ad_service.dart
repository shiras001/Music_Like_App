import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

  // 1回の機能解放に必要なリワード広告視聴回数（既定: 1）
  // 必要に応じて 2 以上に変更できます。
  static int rewardedAdsPerUnlock = 1;

  static const Duration rewardDuration = Duration(minutes: 3);

  static int effectiveRewardedAdsPerUnlock() {
    return rewardedAdsPerUnlock < 1 ? 1 : rewardedAdsPerUnlock;
  }

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
  static Future<bool>? _pendingUnlockFlow;

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
    // 複数箇所から同時に呼ばれてもダイアログ/広告フローを1つにまとめる
    final pending = _pendingUnlockFlow;
    if (pending != null) return pending;

    // 仕様変更: 機能解放確認ダイアログは非表示にする。
    // final future = showDialog<bool>(
    //   context: context,
    //   builder: (dialogContext) => _RewardDialog(actionLabel: actionLabel),
    // ).then((value) => value == true);
    final future = AdService.instance.showRewardedAndGrant();

    _pendingUnlockFlow = future;
    try {
      return await future;
    } finally {
      if (identical(_pendingUnlockFlow, future)) {
        _pendingUnlockFlow = null;
      }
    }
  }
}

class AdService {
  AdService._();
  static final AdService instance = AdService._();
  
  // ランタイムで広告の有効/無効を切り替えられるようにします。
  // 設定は SharedPreferences の 'ads_enabled' キーで保持します（デフォルト true）。
  bool _adsEnabled = true;
  static const String _adFreePlanUntilKey = 'ad_free_plan_until_ms';

  static const String _lastInterstitialDateKey = 'last_interstitial_date';

  bool _initialized = false;
  bool _canRequestAds = false;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  bool _showingRewarded = false;

  Future<void> initialize() async {
    if (_initialized) return;
    // SharedPreferences から広告設定を読み込む
    try {
      final prefs = await SharedPreferences.getInstance();
      _adsEnabled = prefs.getBool('ads_enabled') ?? true;
      final planUntilMs = prefs.getInt(_adFreePlanUntilKey) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (planUntilMs > nowMs) {
        _adsEnabled = false;
      }
    } catch (e) {
      debugPrint('[Ads] failed to read prefs for ads_enabled: $e');
      _adsEnabled = true;
    }

    if (!_adsEnabled) {
      _initialized = true;
      return;
    }

    try {
      await _requestConsentIfNeeded();
    } catch (e, st) {
      debugPrint('[Ads] _requestConsentIfNeeded threw: $e');
      debugPrintStack(stackTrace: st);
      _canRequestAds = false;
    }

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

    try {
      await MobileAds.instance.initialize();
    } catch (e, st) {
      debugPrint('[Ads] MobileAds.initialize failed: $e');
      debugPrintStack(stackTrace: st);
      _initialized = true;
      return;
    }
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
    if (!_adsEnabled) return;
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
    if (!_adsEnabled) return;
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
    if (!_adsEnabled) return;
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

  Future<bool> showRewardedAndGrant({int? requiredAds}) async {
    final targetAds = requiredAds ?? AdConfig.effectiveRewardedAdsPerUnlock();
    if (!_adsEnabled) {
      // 広告が無効化されている場合、ネットワークや広告無しで報酬を自動付与します。
      await RewardUnlockService.grant(AdConfig.rewardDuration);
      return true;
    }
    if (_showingRewarded) {
      // 同時多重表示を防止
      return false;
    }
    _showingRewarded = true;
    try {
      for (var i = 0; i < targetAds; i++) {
        final ok = await _showSingleRewarded();
        if (!ok) return false;
      }
      await RewardUnlockService.grant(AdConfig.rewardDuration);
      return true;
    } catch (e) {
      debugPrint('[Ads] rewarded show failed: $e');
      return false;
    } finally {
      _showingRewarded = false;
    }
  }

  Future<bool> _showSingleRewarded() async {
    if (_rewardedAd == null) {
      _loadRewarded();
      // 広告読み込み中・未取得時は広告なしで解放
      await RewardUnlockService.grant(AdConfig.rewardDuration);
      return true;
    }

    final ad = _rewardedAd;
    _rewardedAd = null;
    bool rewarded = false;
    bool shown = false;
    final completer = Completer<bool>();

    void completeOnce(bool value) {
      if (completer.isCompleted) return;
      completer.complete(value);
    }

    ad?.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        shown = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        final unlocked = rewarded || shown;
        completeOnce(unlocked);
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        completeOnce(false);
        ad.dispose();
        _loadRewarded();
      },
    );

    try {
      await ad?.show(
        onUserEarnedReward: (_, __) {
          rewarded = true;
        },
      );
      final result = await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => rewarded || shown,
      );
      return result;
    } catch (e) {
      debugPrint('[Ads] single rewarded show failed: $e');
      try {
        ad?.dispose();
      } catch (_) {}
      _loadRewarded();
      return false;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// ランタイムで広告を有効/無効にする。
  Future<void> setAdsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ads_enabled', enabled);
    } catch (e) {
      debugPrint('[Ads] failed to save ads_enabled: $e');
    }
    _adsEnabled = enabled;
    if (!enabled) {
      try {
        _interstitialAd?.dispose();
      } catch (_) {}
      _interstitialAd = null;
      try {
        _rewardedAd?.dispose();
      } catch (_) {}
      _rewardedAd = null;
      _loadingInterstitial = false;
      _loadingRewarded = false;
      _initialized = true;
    } else {
      // 有効化されたら初期化を再実行
      _initialized = false;
      await initialize();
    }
  }

  /// 設定ストアから現在の広告有効状態を取得するユーティリティ
  static Future<bool> areAdsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('ads_enabled') ?? true;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> isAdFreeMonthlyPlanActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final untilMs = prefs.getInt(_adFreePlanUntilKey) ?? 0;
      return DateTime.now().millisecondsSinceEpoch < untilMs;
    } catch (_) {
      return false;
    }
  }

  Future<void> activateAdFreeMonthlyPlan() async {
    final now = DateTime.now();
    final until = now.add(const Duration(days: 30));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_adFreePlanUntilKey, until.millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[Ads] failed to save ad free plan until: $e');
    }
    await setAdsEnabled(false);
  }
}

class SubscriptionInfo {
  final bool storeAvailable;
  final bool isActive;
  final DateTime? expiresAt;
  final DateTime? nextRenewalAt;

  const SubscriptionInfo({
    required this.storeAvailable,
    required this.isActive,
    this.expiresAt,
    this.nextRenewalAt,
  });
}

class PlaySubscriptionService {
  PlaySubscriptionService._();
  static final PlaySubscriptionService instance = PlaySubscriptionService._();

  static const String monthlyProductId = 'ad_free_monthly_1usd';
  static const String _subActiveKey = 'sub_active';
  static const String _subExpiresAtKey = 'sub_expires_at_ms';
  static const String _subNextRenewalAtKey = 'sub_next_renewal_at_ms';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _initialized = false;
  bool _storeAvailable = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _storeAvailable = await _iap.isAvailable();

    _purchaseSub = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object e) => debugPrint('[Sub] purchase stream error: $e'),
    );

    if (_storeAvailable) {
      await _iap.restorePurchases();
    }
  }

  Future<bool> purchaseMonthlyPlan() async {
    final available = await _iap.isAvailable();
    _storeAvailable = available;
    if (!available) return false;

    final resp = await _iap.queryProductDetails({monthlyProductId});
    if (resp.productDetails.isEmpty) {
      debugPrint('[Sub] product not found: $monthlyProductId');
      return false;
    }
    final param = PurchaseParam(productDetails: resp.productDetails.first);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    if (!_storeAvailable && !await _iap.isAvailable()) return;
    await _iap.restorePurchases();
  }

  Future<SubscriptionInfo> getSubscriptionInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final active = prefs.getBool(_subActiveKey) ?? false;
    final expiresAt = _readDateTime(prefs, _subExpiresAtKey);
    final nextRenewalAt = _readDateTime(prefs, _subNextRenewalAtKey);
    final now = DateTime.now();
    final currentlyActive = active && (expiresAt == null || now.isBefore(expiresAt));
    return SubscriptionInfo(
      storeAvailable: _storeAvailable,
      isActive: currentlyActive,
      expiresAt: expiresAt,
      nextRenewalAt: nextRenewalAt,
    );
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> updates) async {
    for (final purchase in updates) {
      if (purchase.productID != monthlyProductId) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        final transactionMs = int.tryParse(purchase.transactionDate ?? '') ?? DateTime.now().millisecondsSinceEpoch;
        final purchasedAt = DateTime.fromMillisecondsSinceEpoch(transactionMs);
        final renewAt = purchasedAt.add(const Duration(days: 30));
        await _saveStatus(active: true, expiresAt: renewAt, nextRenewalAt: renewAt);
        await AdService.instance.setAdsEnabled(false);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _saveStatus({
    required bool active,
    DateTime? expiresAt,
    DateTime? nextRenewalAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_subActiveKey, active);
    if (expiresAt != null) {
      await prefs.setInt(_subExpiresAtKey, expiresAt.millisecondsSinceEpoch);
      await prefs.setInt('ad_free_plan_until_ms', expiresAt.millisecondsSinceEpoch);
    }
    if (nextRenewalAt != null) {
      await prefs.setInt(_subNextRenewalAtKey, nextRenewalAt.millisecondsSinceEpoch);
    }
  }

  DateTime? _readDateTime(SharedPreferences prefs, String key) {
    final ms = prefs.getInt(key);
    if (ms == null || ms <= 0) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
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
        '広告を見てプレミアム機能を３分間開放しますか？',
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
                      const SnackBar(content: Text('広告を読み込み中です。少し待ってからもう一度お試しください。')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('プレミアム機能が利用できます')),
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
