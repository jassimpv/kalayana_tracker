import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InAppReviewService {
  const InAppReviewService._();

  static const _keyInstallDate = 'install_date';
  static const _keyReviewRequested = 'review_requested';
  static const _minDaysBeforeReview = 2;

  static Future<void> maybeRequestReview() async {
    if (kIsWeb) return;
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!prefs.containsKey(_keyInstallDate)) {
        await prefs.setString(
          _keyInstallDate,
          DateTime.now().toIso8601String(),
        );
        return;
      }

      if (prefs.getBool(_keyReviewRequested) == true) return;

      final installDate = DateTime.tryParse(
        prefs.getString(_keyInstallDate) ?? '',
      );
      if (installDate == null) return;

      final daysSinceInstall = DateTime.now().difference(installDate).inDays;
      if (daysSinceInstall < _minDaysBeforeReview) return;

      final inAppReview = InAppReview.instance;
      if (!await inAppReview.isAvailable()) return;

      await inAppReview.requestReview();
      await prefs.setBool(_keyReviewRequested, true);
    } catch (error) {
      debugPrint('In-app review request failed: $error');
    }
  }
}
