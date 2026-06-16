import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';

/// `true` when the Google Mobile Ads SDK is usable on this platform.
///
/// The plugin only ships native implementations for Android and iOS, so any
/// other target (web, desktop) must skip ad loading entirely.
bool get isMobileAdsSupported =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// A banner ad anchored above the bottom navigation bar.
///
/// Reserves [AdsConfig.bannerHeight] of layout space wherever it's placed so
/// surrounding UI (FAB offsets, scroll padding) never has to react to the ad
/// loading. While the ad is loading — or if it fails to load/is unsupported
/// on this platform — the widget simply renders nothing instead of a broken
/// placeholder, so the reserved space just looks like a bit of breathing
/// room rather than a visible gap or error.
class DashboardBannerAd extends StatefulWidget {
  const DashboardBannerAd({super.key});

  @override
  State<DashboardBannerAd> createState() => _DashboardBannerAdState();
}

class _DashboardBannerAdState extends State<DashboardBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (isMobileAdsSupported) _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdsConfig.dashboardBannerUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
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
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}

/// Centers [DashboardBannerAd] and keeps a consistent height for the slot
/// it sits in, regardless of whether an ad is currently showing.
class DashboardBannerAdSlot extends StatelessWidget {
  const DashboardBannerAdSlot({super.key});

  @override
  Widget build(BuildContext context) {
    if (!isMobileAdsSupported) return const SizedBox.shrink();
    return SizedBox(
      height: AdsConfig.bannerHeight,
      width: double.infinity,
      child: const Center(child: DashboardBannerAd()),
    );
  }
}
