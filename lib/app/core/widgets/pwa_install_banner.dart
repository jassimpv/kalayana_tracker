import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/services/pwa_install_service.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

/// Wraps the app and shows a dismissible install banner on Flutter web when
/// the browser reports the PWA is installable (beforeinstallprompt fired).
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key, required this.child});

  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return widget.child;

    return Stack(
      children: [
        widget.child,
        ValueListenableBuilder<bool>(
          valueListenable: PwaInstallService.instance.canInstall,
          builder: (context, canInstall, _) {
            if (!canInstall || _dismissed) return const SizedBox.shrink();
            return Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: _InstallCard(
                  onInstall: PwaInstallService.instance.promptInstall,
                  onDismiss: () => setState(() => _dismissed = true),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _InstallCard extends StatelessWidget {
  const _InstallCard({required this.onInstall, required this.onDismiss});

  final VoidCallback onInstall;
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
              const Icon(Icons.install_mobile_rounded, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Install Kalyana for quick, offline-ready access.',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onInstall,
                child: const Text(
                  'Install',
                  style: TextStyle(
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
