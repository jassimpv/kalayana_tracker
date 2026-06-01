import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.greeting = 'Hi Jassim 👋',
    this.subtitle = 'Wedding Budget Overview',
    this.showGreeting = false,
    this.onBack,
    this.onSearch,
    this.onNotification,
  });

  final String title;
  final String greeting;
  final String subtitle;
  final bool showGreeting;
  final VoidCallback? onBack;
  final VoidCallback? onSearch;
  final VoidCallback? onNotification;

  @override
  Size get preferredSize => Size.fromHeight(128);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final height = topInset + (showGreeting ? 60 : 48);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8F1438).withValues(alpha: 0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
            ),
          ),
          ClipPath(
            clipper: _LuxuryAppBarClipper(),
            child: Container(
              height: height,
              decoration: BoxDecoration(color: ThemeColors.primary),
              child: Stack(
                children: [
                  Positioned(
                    right: -46,
                    top: topInset + 4,
                    child: const _GlassOrb(size: 138, alpha: 0.13),
                  ),
                  Positioned(
                    left: -30,
                    bottom: 18,
                    child: const _GlassOrb(size: 118, alpha: 0.08),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.13),
                            Colors.white.withValues(alpha: 0.02),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        SizedBox(height: topInset),
                        if (showGreeting) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  greeting,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    height: 1.05,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.88),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          if (!showGreeting)
                            SizedBox(
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: onBack == null ? 0 : 56,
                                      ),
                                      child: Center(
                                        child: Text(
                                          title,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (onBack != null)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _HeaderIconButton(
                                        icon: Icons.arrow_back_rounded,
                                        tooltip: 'Overview',
                                        onPressed: onBack,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return const SizedBox(width: 48, height: 48);
    }
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        onPressed: onPressed,
        icon: Icon(icon),
        color: Colors.white,
        tooltip: tooltip,
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
        border: Border.all(color: Colors.white.withValues(alpha: alpha * 1.2)),
      ),
    );
  }
}

class _LuxuryAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const topRadius = 34.0;

    return Path()
      // top-left rounded corner
      ..moveTo(0, topRadius)
      ..quadraticBezierTo(0, 0, topRadius, 0)
      // top line
      ..lineTo(size.width - topRadius, 0)
      // top-right rounded corner
      ..quadraticBezierTo(size.width, 0, size.width, topRadius)
      // right side down
      ..lineTo(size.width, size.height)
      // bottom straight line
      ..lineTo(0, size.height)
      // left side up
      ..lineTo(0, topRadius)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
