import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';

/// Loads App Open ads ahead of time and shows one when the app returns to
/// the foreground — never on cold start, so it never competes with the
/// splash screen or the login flow.
///
/// Kept deliberately conservative to avoid feeling like an interstitial
/// spam: only shows on resume (not first launch), respects
/// [AdsConfig.appOpenMinInterval] between impressions, skips entirely while
/// another ad is already showing, and is a no-op on unsupported platforms.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();

  static final AppOpenAdManager instance = AppOpenAdManager._();

  AppOpenAd? _ad;
  bool _isShowingAd = false;
  bool _isFirstResume = true;
  DateTime? _lastShownAt;

  void start() {
    if (!isMobileAdsSupported) return;
    WidgetsBinding.instance.addObserver(this);
    _loadAd();
  }

  void _loadAd() {
    AppOpenAd.load(
      adUnitId: AdsConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) => _ad = ad,
        onAdFailedToLoad: (_) => _ad = null,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    // Skip the very first resume callback after launch — that's the cold
    // start the user just initiated, not a "return to the app".
    if (_isFirstResume) {
      _isFirstResume = false;
      return;
    }
    _maybeShowAd();
  }

  void _maybeShowAd() {
    if (_isShowingAd) return;
    final ad = _ad;
    if (ad == null) {
      _loadAd();
      return;
    }
    final lastShown = _lastShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < AdsConfig.appOpenMinInterval) {
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _lastShownAt = DateTime.now();
        ad.dispose();
        _ad = null;
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _ad = null;
        _loadAd();
      },
    );
    ad.show();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ad?.dispose();
    _ad = null;
  }
}
