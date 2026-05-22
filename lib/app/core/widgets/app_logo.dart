import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 48,
    this.padding = 6,
    this.showBackground = true,
  });

  final double size;
  final double padding;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final logo = Padding(
      padding: EdgeInsets.all(padding),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );

    if (!showBackground) {
      return SizedBox(width: size, height: size, child: logo);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: ThemeColors.logoBackgroundGradient,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoCopper.withValues(alpha: 0.24),
            blurRadius: size * 0.34,
            offset: Offset(0, size * 0.14),
          ),
        ],
      ),
      child: logo,
    );
  }
}
