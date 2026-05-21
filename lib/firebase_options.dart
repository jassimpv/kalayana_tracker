import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static const _placeholderProjectId = 'replace-with-your-project-id';

  static bool get isConfigured {
    final options = currentPlatform;
    return options.projectId != _placeholderProjectId &&
        !options.apiKey.startsWith('replace-with');
  }

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD1b_IjjsBsH-MsHIdL_H51p3uPhEFcW8g',
    appId: '1:1097547412500:web:b27df58809557eabfca301',
    messagingSenderId: '1097547412500',
    projectId: 'expense-tracker-20653',
    authDomain: 'expense-tracker-20653.firebaseapp.com',
    storageBucket: 'expense-tracker-20653.firebasestorage.app',
    measurementId: 'G-278BE24QD3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjrO5hXX0ExVIQ9hQEOl3nhzAawCh7eUs',
    appId: '1:1097547412500:android:2fcd1bf3c30c1787fca301',
    messagingSenderId: '1097547412500',
    projectId: 'expense-tracker-20653',
    storageBucket: 'expense-tracker-20653.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjXP8_vOj3NIkSBO74Rp3npPs4JqeKngU',
    appId: '1:1097547412500:ios:b30cac04f6b7b591fca301',
    messagingSenderId: '1097547412500',
    projectId: 'expense-tracker-20653',
    storageBucket: 'expense-tracker-20653.firebasestorage.app',
    androidClientId: '1097547412500-dlttq0ck3gks6gklndimu5p09h9eebdt.apps.googleusercontent.com',
    iosClientId: '1097547412500-5r0mucmb4kb1qr1samnpinqjatghtk36.apps.googleusercontent.com',
    iosBundleId: 'com.fueltech.kalayanaexpresstracker',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'replace-with-api-key',
    appId: 'replace-with-macos-app-id',
    messagingSenderId: 'replace-with-sender-id',
    projectId: _placeholderProjectId,
    storageBucket: 'replace-with-your-project-id.appspot.com',
    iosBundleId: 'com.fueltech.kalayanaexpresstracker',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'replace-with-api-key',
    appId: 'replace-with-windows-app-id',
    messagingSenderId: 'replace-with-sender-id',
    projectId: _placeholderProjectId,
    authDomain: 'replace-with-your-project-id.firebaseapp.com',
    storageBucket: 'replace-with-your-project-id.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'replace-with-api-key',
    appId: 'replace-with-linux-app-id',
    messagingSenderId: 'replace-with-sender-id',
    projectId: _placeholderProjectId,
    authDomain: 'replace-with-your-project-id.firebaseapp.com',
    storageBucket: 'replace-with-your-project-id.appspot.com',
  );
}