import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AndroidInAppUpdateService {
  const AndroidInAppUpdateService._();

  static Future<void> checkForUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        return;
      }

      if (info.flexibleUpdateAllowed) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (error, stackTrace) {
      debugPrint('Android in-app update check failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
