import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/services/external_link_service.dart';
import 'package:kalayanaexpresstracker/app/core/services/pwa_install_service.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

const String _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.fueltech.kalyana_tracker';

/// Wraps the app and shows a dismissible install banner on Flutter web.
/// Android browsers are pointed to the Play Store listing, iOS browsers see
/// an "app coming soon" note, and other browsers fall back to the PWA
/// install prompt when the browser reports it's installable.
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key, required this.child});

  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _dismissed = false;

  void _dismiss() => setState(() => _dismissed = true);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(child: _resolveBanner()),
        ),
      ],
    );
  }

  Widget _resolveBanner() {
    if (_dismissed) return const SizedBox.shrink();

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _InstallCard(
          icon: Icons.shop_rounded,
          message: 'Get the Kalyana app on Google Play for the full experience.',
          actionLabel: 'Play Store',
          onAction: () =>
              ExternalLinkService.instance.openInNewTab(_playStoreUrl),
          onDismiss: _dismiss,
        );
      case TargetPlatform.iOS:
        return _InstallCard(
          icon: Icons.apple_rounded,
          message: 'The iOS app is coming soon. Use the web app for now.',
          onDismiss: _dismiss,
        );
      default:
        return ValueListenableBuilder<bool>(
          valueListenable: PwaInstallService.instance.canInstall,
          builder: (context, canInstall, _) {
            if (!canInstall) return const SizedBox.shrink();
            return _InstallCard(
              icon: Icons.install_mobile_rounded,
              message: 'Install Kalyana for quick, offline-ready access.',
              actionLabel: 'Install',
              onAction: PwaInstallService.instance.promptInstall,
              onDismiss: _dismiss,
            );
          },
        );
    }
  }
}

class _InstallCard extends StatelessWidget {
  const _InstallCard({
    required this.icon,
    required this.message,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: ThemeColors.primary,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actionLabel != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
