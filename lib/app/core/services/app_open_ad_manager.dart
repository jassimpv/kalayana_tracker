import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';

/// Loads App Open ads and shows one whenever the app opens or returns to the
/// foreground.
///
/// If an ad is not ready yet, the manager keeps the show request pending and
/// presents it as soon as loading succeeds.
class AppOpenAdManager with WidgetsBindingObserver {
  AppOpenAdManager._();

  static final AppOpenAdManager instance = AppOpenAdManager._();

  AppOpenAd? _ad;
  DateTime? _loadedAt;
  DateTime? _lastLoadAttemptAt;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  bool _isStarted = false;
  bool _isForeground = true;
  bool _hasMovedToBackground = false;
  bool _showWhenLoaded = false;
  DateTime? _lastShownAt;

  void start() {
    if (_isStarted || !shouldLoadMobileAds) return;
    _isStarted = true;
    WidgetsBinding.instance.addObserver(this);
    showAdIfAvailable();
    _loadAd();
  }

  void _loadAd() {
    if (_isLoadingAd || _ad != null || !_canAttemptLoad()) return;

    _isLoadingAd = true;
    _lastLoadAttemptAt = DateTime.now();
    AppOpenAd.load(
      adUnitId: AdsConfig.appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoadingAd = false;
          _lastLoadAttemptAt = null;
          if (!_isStarted || !shouldLoadMobileAds) {
            ad.dispose();
            return;
          }
          _ad = ad;
          _loadedAt = DateTime.now();
          if (_showWhenLoaded && _isForeground) {
            showAdIfAvailable();
          }
        },
        onAdFailedToLoad: (_) {
          _isLoadingAd = false;
          _ad = null;
          _loadedAt = null;
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _isForeground = false;
      _hasMovedToBackground = true;
      return;
    }
    if (state != AppLifecycleState.resumed || !_hasMovedToBackground) return;

    _isForeground = true;
    _hasMovedToBackground = false;
    showAdIfAvailable();
  }

  void showAdIfAvailable() {
    if (_isShowingAd) return;
    if (!_canShowByInterval()) {
      _showWhenLoaded = false;
      _loadAd();
      return;
    }

    final ad = _ad;
    if (ad == null) {
      _showWhenLoaded = true;
      _loadAd();
      return;
    }

    if (_isAdExpired) {
      _disposeLoadedAd();
      _showWhenLoaded = true;
      _loadAd();
      return;
    }

    _showWhenLoaded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _isShowingAd = true,
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _lastShownAt = DateTime.now();
        _clearShownAd(ad);
        _loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        _clearShownAd(ad);
        _loadAd();
      },
    );
    ad.show();
  }

  bool _canAttemptLoad() {
    final lastAttempt = _lastLoadAttemptAt;
    return lastAttempt == null ||
        DateTime.now().difference(lastAttempt) >= AdsConfig.appOpenRetryDelay;
  }

  bool _canShowByInterval() {
    final lastShown = _lastShownAt;
    return lastShown == null ||
        DateTime.now().difference(lastShown) >= AdsConfig.appOpenMinInterval;
  }

  bool get _isAdExpired {
    final loadedAt = _loadedAt;
    return loadedAt == null ||
        DateTime.now().difference(loadedAt) >=
            AdsConfig.appOpenMaxCacheDuration;
  }

  void _clearShownAd(AppOpenAd ad) {
    ad.dispose();
    if (identical(_ad, ad)) {
      _ad = null;
      _loadedAt = null;
    }
  }

  void _disposeLoadedAd() {
    _ad?.dispose();
    _ad = null;
    _loadedAt = null;
  }

  void dispose() {
    if (!_isStarted) return;
    _isStarted = false;
    WidgetsBinding.instance.removeObserver(this);
    _disposeLoadedAd();
    _isLoadingAd = false;
    _isShowingAd = false;
    _isForeground = false;
    _hasMovedToBackground = false;
    _showWhenLoaded = false;
  }
}
