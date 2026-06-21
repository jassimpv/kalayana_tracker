import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';

/// Loads a Rewarded ad on demand and shows it before letting the caller
/// run a gated action (e.g. generating a PDF report).
///
/// If the ad can't be loaded or shown — unsupported platform, no fill,
/// network error — [showForAction] still runs [onEarnedReward] so report
/// generation never gets permanently blocked by ad-serving problems. If the
/// ad loads but the user dismisses it before earning the reward, the action
/// is skipped and they need to try again.
class RewardedAdManager {
  RewardedAdManager._();

  static final RewardedAdManager instance = RewardedAdManager._();

  bool _isLoading = false;

  void showForAction(VoidCallback onEarnedReward) {
    if (!shouldLoadMobileAds) {
      onEarnedReward();
      return;
    }
    if (_isLoading) return;
    _isLoading = true;

    RewardedAd.load(
      adUnitId: AdsConfig.rewardedReportUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          var rewardEarned = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (rewardEarned) onEarnedReward();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              onEarnedReward();
            },
          );
          ad.show(
            onUserEarnedReward: (ad, reward) => rewardEarned = true,
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          onEarnedReward();
        },
      ),
    );
  }
}
