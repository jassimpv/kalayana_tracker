import "dart:math" as math;
import "dart:ui";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:kalayanaexpresstracker/app/core/theme/app_theme.dart";

class PremiumAuthScaffold extends StatelessWidget {
  const PremiumAuthScaffold({
    required this.childBuilder,
    super.key,
    this.showTopActions = true,
  });

  final Widget Function(BuildContext context, bool isDark) childBuilder;
  final bool showTopActions;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: ThemeService.themeModeNotifier,
    builder: (BuildContext context, ThemeMode _, Widget? child) {
      final bool isDark = ThemeService.isDark();

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: isDark
              ? const Color(0xFF061416)
              : const Color(0xFF073F43),
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Stack(
              children: <Widget>[
                Positioned.fill(child: PremiumAuthBackground(isDark: isDark)),
                SafeArea(
                  bottom: false,
                  child: Column(
                    children: <Widget>[
                      Expanded(child: childBuilder(context, isDark)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class PremiumAuthResponsiveContent extends StatelessWidget {
  const PremiumAuthResponsiveContent({
    required this.children,
    super.key,
    this.topFactor = 0.11,
    this.minTopGap = 54,
    this.maxTopGap = 112,
    this.maxWidth = 430,
    this.horizontalPadding = 20,
    this.bottomPadding = 24,
  });

  final List<Widget> children;
  final double topFactor;
  final double minTopGap;
  final double maxTopGap;
  final double maxWidth;
  final double horizontalPadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.viewInsetsOf(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double contentWidth = math.min(
          constraints.maxWidth - (horizontalPadding * 2),
          maxWidth,
        );
        final double contentTopGap = (constraints.maxHeight * topFactor).clamp(
          minTopGap,
          maxTopGap,
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            viewInsets.bottom + bottomPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: contentTopGap),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PremiumAuthBackground extends StatelessWidget {
  const PremiumAuthBackground({required this.isDark, super.key});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = isDark
        ? const <Color>[
            Color(0xFF041315),
            Color(0xFF062A2D),
            Color(0xFF074A4D),
            Color(0xFF0A7D72),
          ]
        : const <Color>[
            Color(0xFF06373B),
            Color(0xFF075B5F),
            Color(0xFF0EA493),
            Color(0xFF5EDFCB),
          ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
          stops: const <double>[0, 0.34, 0.74, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned.fill(child: _SubtleParticleField()),
          _GlowOrb(
            top: -120,
            left: -90,
            size: 310,
            color: const Color(0xFF8EF8EA),
            opacity: isDark ? 0.11 : 0.22,
          ),
          _GlowOrb(
            top: 92,
            right: -120,
            size: 280,
            color: const Color(0xFFB8FFF4),
            opacity: isDark ? 0.09 : 0.18,
          ),
          _GlowOrb(
            bottom: -96,
            left: 26,
            size: 360,
            color: const Color(0xFF24CBB7),
            opacity: isDark ? 0.12 : 0.18,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: isDark ? 0.04 : 0.08),
                    Colors.transparent,
                    const Color(
                      0xFF021B1D,
                    ).withValues(alpha: isDark ? 0.38 : 0.14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumAuthCard extends StatelessWidget {
  const PremiumAuthCard({
    required this.child,
    required this.isDark,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(24, 26, 24, 24),
    this.radius = 32,
  });

  final Widget child;
  final bool isDark;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0B2427).withValues(alpha: 0.86)
              : ThemeColors.whiteColor.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isDark
                ? ThemeColors.whiteColor.withValues(alpha: 0.12)
                : ThemeColors.whiteColor.withValues(alpha: 0.76),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(
                0xFF021618,
              ).withValues(alpha: isDark ? 0.46 : 0.24),
              blurRadius: 42,
              offset: const Offset(0, 24),
            ),
            BoxShadow(
              color: ThemeColors.whiteColor.withValues(
                alpha: isDark ? 0.06 : 0.95,
              ),
              blurRadius: 18,
              offset: const Offset(-8, -8),
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  final double size;
  final Color color;
  final double opacity;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  @override
  Widget build(BuildContext context) => Positioned(
    top: top,
    left: left,
    right: right,
    bottom: bottom,
    child: IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 42, sigmaY: 42),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    ),
  );
}

class _SubtleParticleField extends StatelessWidget {
  const _SubtleParticleField();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ParticlePainter(), child: const SizedBox.expand());
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint dotPaint = Paint()..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    const List<Offset> points = <Offset>[
      Offset(0.12, 0.18),
      Offset(0.28, 0.12),
      Offset(0.76, 0.19),
      Offset(0.88, 0.33),
      Offset(0.18, 0.58),
      Offset(0.42, 0.48),
      Offset(0.72, 0.62),
      Offset(0.32, 0.82),
      Offset(0.86, 0.84),
    ];

    for (int index = 0; index < points.length; index++) {
      final Offset point = Offset(
        points[index].dx * size.width,
        points[index].dy * size.height,
      );
      final double radius = index.isEven ? 1.9 : 1.25;
      dotPaint.color = Colors.white.withValues(
        alpha: index.isEven ? 0.16 : 0.1,
      );
      canvas.drawCircle(point, radius, dotPaint);
    }

    for (int index = 0; index < points.length - 1; index += 2) {
      final Offset start = Offset(
        points[index].dx * size.width,
        points[index].dy * size.height,
      );
      final Offset end = Offset(
        points[index + 1].dx * size.width,
        points[index + 1].dy * size.height,
      );
      linePaint.color = Colors.white.withValues(alpha: 0.04);
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
