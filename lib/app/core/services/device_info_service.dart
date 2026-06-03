import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfoService {
  DeviceInfoService._();

  static final DeviceInfoService instance = DeviceInfoService._();

  static const privacyText =
      'We collect basic app and device information to improve app stability and user experience. '
      'We do not collect personal files, contacts, messages, precise location, camera, or microphone data without permission.';

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<void> initDeviceInfo() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final info = await _buildDeviceInfo();
      final platform = info['platform'] as String? ?? 'unknown';
      final doc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('deviceInfo')
          .doc(platform);

      await doc.set({
        ...info,
        'privacyText': privacyText,
        'lastSeenAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error, stackTrace) {
      if (error is FirebaseException && error.code == 'permission-denied') {
        debugPrint('Device info capture skipped: Firestore permission denied.');
        return;
      }
      debugPrint('Device info capture failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<Map<String, dynamic>> _buildDeviceInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final baseInfo = <String, dynamic>{
      'appName': packageInfo.appName,
      'packageName': packageInfo.packageName,
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'screen': _screenInfo(),
      'locale': ui.PlatformDispatcher.instance.locale.toLanguageTag(),
      'themeMode': _themeMode(),
      'networkType': 'unknown',
    };

    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return {
        ...baseInfo,
        'platform': 'web',
        'browserName': webInfo.browserName.name,
        'browserUserAgent': webInfo.userAgent,
        'browserPlatform': webInfo.platform,
        'browserVendor': webInfo.vendor,
        'deviceModel': webInfo.browserName.name,
        'manufacturer': webInfo.vendor,
        'androidVersion': null,
      };
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        ...baseInfo,
        'platform': 'android',
        'deviceModel': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'androidVersion': androidInfo.version.release,
        'androidSdkInt': androidInfo.version.sdkInt,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'product': androidInfo.product,
      };
    }

    return {
      ...baseInfo,
      'platform': defaultTargetPlatform.name,
      'deviceModel': null,
      'manufacturer': null,
      'androidVersion': null,
    };
  }

  Map<String, dynamic> _screenInfo() {
    final dispatcher = ui.PlatformDispatcher.instance;
    final view = dispatcher.views.isEmpty ? null : dispatcher.views.first;
    final pixelRatio =
        view?.devicePixelRatio ??
        dispatcher.implicitView?.devicePixelRatio ??
        1;
    final physicalSize =
        view?.physicalSize ??
        dispatcher.implicitView?.physicalSize ??
        ui.Size.zero;
    final logicalSize = physicalSize / pixelRatio;

    return {
      'width': logicalSize.width.round(),
      'height': logicalSize.height.round(),
      'pixelRatio': pixelRatio,
    };
  }

  String _themeMode() {
    final brightness = ui.PlatformDispatcher.instance.platformBrightness;
    return brightness == ui.Brightness.dark ? 'dark' : 'light';
  }
}
