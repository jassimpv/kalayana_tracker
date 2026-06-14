import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/services/android_in_app_update_service.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/app_logo.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    unawaited(AndroidInAppUpdateService.checkForUpdate());
    unawaited(_openNextScreen());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openNextScreen() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final route = FirebaseAuth.instance.currentUser == null
        ? AppRoutes.auth
        : AppRoutes.dashboard;

    Get.offAllNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF7A1230),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: ThemeColors.appBarGradient.colors,
          ),
        ),
        child: Stack(
          children: [
            // Decorative glass orbs
            Positioned(
              right: -20,
              top: 80,
              child: _GlassOrb(size: 100, alpha: 0.05),
            ),
            Positioned(
              left: -24,
              bottom: 180,
              child: _GlassOrb(size: 80, alpha: 0.04),
            ),

            // Centered branding
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AppLogo(
                        size: 150,
                        padding: 14,
                        showBackground: false,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Kalyana',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EXPENSE TRACKER',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.70),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 3.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spinner pinned to bottom
            Positioned(
              bottom: bottomInset + 52,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white.withValues(alpha: 0.80),
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassOrb extends StatelessWidget {
  const _GlassOrb({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
        border: Border.all(color: Colors.white.withValues(alpha: alpha * 1.4)),
      ),
    );
  }
}
