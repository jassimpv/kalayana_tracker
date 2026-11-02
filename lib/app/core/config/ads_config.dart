/// AdMob identifiers and shared ad layout constants.
///
/// Keeping these in one place makes it easy to swap in platform-specific
/// ad unit IDs later without touching the widgets that use them.
class AdsConfig {
  AdsConfig._();

  static const bool _debugAdsEnabled = !bool.fromEnvironment('dart.vm.product');

  /// AdMob App ID (also declared natively in AndroidManifest.xml and
  /// ios/Runner/Info.plist — update both places together if this changes).
  static const String appId = 'ca-app-pub-1869067456074705~1827059897';

  /// Banner ad unit shown above the bottom navigation bar.
  static const String dashboardBannerUnitId =
      'ca-app-pub-1869067456074705/3471314056';

  /// Native advanced ad unit for in-feed placements ("inline").
  static const String nativeInlineUnitId =
      'ca-app-pub-1869067456074705/6093607968';

  /// App open ad unit shown when the app returns to the foreground.
  static const String appOpenUnitId = 'ca-app-pub-1869067456074705/7218987371';

  /// Rewarded ad unit shown before generating a PDF report.
  static const String rewardedReportUnitId =
      'ca-app-pub-1869067456074705/7157812588';

  /// Google sample ad unit IDs used in debug/profile sessions so development
  /// requests never generate traffic against the production placements.
  static String get dashboardBannerUnitIdForBuild => _debugAdsEnabled
      ? 'ca-app-pub-3940256099942544/6300978111'
      : dashboardBannerUnitId;
  static String get nativeInlineUnitIdForBuild => _debugAdsEnabled
      ? 'ca-app-pub-3940256099942544/1044960115'
      : nativeInlineUnitId;
  static String get appOpenUnitIdForBuild => _debugAdsEnabled
      ? 'ca-app-pub-3940256099942544/5575463023'
      : appOpenUnitId;
  static String get rewardedReportUnitIdForBuild => _debugAdsEnabled
      ? 'ca-app-pub-3940256099942544/5224354917'
      : rewardedReportUnitId;

  /// Height reserved for [DashboardBannerAd] (matches AdSize.banner).
  static const double bannerHeight = 50;

  /// Minimum time between two App Open ad impressions.
  static const Duration appOpenMinInterval = Duration(hours: 2);

  /// Maximum age for a loaded App Open ad before it is discarded and reloaded.
  static const Duration appOpenMaxCacheDuration = Duration(hours: 4);

  /// Minimum delay before retrying an App Open ad load after a failed request.
  static const Duration appOpenRetryDelay = Duration(seconds: 30);
}
