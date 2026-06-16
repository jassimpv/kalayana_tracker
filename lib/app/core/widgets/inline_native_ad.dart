import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';

/// Native id passed to the platform ad factories registered in
/// MainActivity.kt (Android) and AppDelegate.swift (iOS).
const String _inlineNativeAdFactoryId = 'inlineNativeAd';

/// Card height the platform-side templates are designed to fill. Kept here
/// so the Flutter-side reserved space always matches the native layout.
const double _inlineNativeAdHeight = 300;

/// A native ad styled like the app's own cards, meant to sit between
/// sections of a scrolling feed (currently the Overview tab).
///
/// Same "reserve space, render nothing on failure" pattern as
/// [DashboardBannerAd]: if the ad never loads — or the platform doesn't
/// support Mobile Ads at all — this collapses to nothing instead of leaving
/// a broken or empty-looking card in the feed.
class InlineNativeAdCard extends StatefulWidget {
  const InlineNativeAdCard({super.key});

  @override
  State<InlineNativeAdCard> createState() => _InlineNativeAdCardState();
}

class _InlineNativeAdCardState extends State<InlineNativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (shouldLoadMobileAds) _loadAd();
  }

  void _loadAd() {
    final ad = NativeAd(
      adUnitId: AdsConfig.nativeInlineUnitId,
      factoryId: _inlineNativeAdFactoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _ad = null;
            _loaded = false;
          });
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: _inlineNativeAdHeight,
        child: AdWidget(ad: ad),
      ),
    );
  }
}
