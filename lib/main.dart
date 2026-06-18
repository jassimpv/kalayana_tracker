import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kalayanaexpresstracker/app/core/services/app_open_ad_manager.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppBootstrap.load();
    AppBootstrap.loadAds();
    runApp(const KalyanaApp());
  } catch (error, stackTrace) {
    debugPrint('Firebase startup failed: $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(FirebaseStartupErrorApp(error: error));
  }
}

class KalyanaApp extends StatelessWidget {
  const KalyanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalyana Expense Tracker',
      theme: ThemeColors.lightTheme(context),
      // darkTheme: ThemeColors.darkTheme(context),
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}

class AppBootstrap {
  static Future<void> load() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      throw StateError(
        'Firebase is not configured for this platform. Add real Firebase options in lib/firebase_options.dart.',
      );
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

  }

  static void loadAds() {
    if (!shouldLoadMobileAds) return;

    unawaited(
      MobileAds.instance.initialize().then(
        (_) => AppOpenAdManager.instance.start(),
      ),
    );
  }
}

class FirebaseStartupErrorApp extends StatelessWidget {
  const FirebaseStartupErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalyana Expense Tracker',
      theme: ThemeColors.lightTheme(context),
      // darkTheme: ThemeColors.darkTheme(context),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      size: 48,
                      color: Color(0xFFB45309),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Firebase setup needs attention',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF667085),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
