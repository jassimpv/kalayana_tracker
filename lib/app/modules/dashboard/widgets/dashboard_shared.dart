part of '../views/dashboard_view.dart';

class _DashboardLoadingScaffold extends StatelessWidget {
  const _DashboardLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1000;
        return Scaffold(
          extendBody: true,
          backgroundColor: ThemeColors.scaffoldColor,
          appBar: wide ? null : _LoadingAppBar(wide: wide),
          body: DecoratedBox(
            decoration: BoxDecoration(gradient: ThemeColors.surfaceGradient),
            child: Row(
              children: [
                if (wide) const _LoadingSideRail(),
                Expanded(child: _DashboardSkeletonFrame(wide: wide)),
              ],
            ),
          ),
          bottomNavigationBar: wide ? null : const _LoadingBottomNav(),
        );
      },
    );
  }
}

class _DashboardSkeletonFrame extends StatelessWidget {
  const _DashboardSkeletonFrame({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          wide ? 28 : 16,
          wide ? 18 : 16,
          wide ? 28 : 16,
          wide ? 104 : 168,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: const _Shimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroSkeleton(),
                  SizedBox(height: 18),
                  _QuickActionsSkeleton(),
                  SizedBox(height: 18),
                  _AnalyticsSkeleton(),
                  SizedBox(height: 18),
                  _MetricStripSkeleton(),
                  SizedBox(height: 18),
                  _ListSkeleton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LoadingAppBar({required this.wide});

  final bool wide;

  @override
  Size get preferredSize =>
      Size.fromHeight(MediaQuery.paddingOf(Get.context!).top);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.primary,
            ThemeColors.primary.withValues(alpha: 0.82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
        child: _Shimmer(
          baseColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.38),
          child: Row(
            children: [
              const _SkeletonBox(width: 46, height: 46, radius: 23),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 190, height: 18, radius: 6),
                    SizedBox(height: 8),
                    _SkeletonBox(width: 135, height: 12, radius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _SkeletonBox(width: wide ? 46 : 42, height: 46, radius: 23),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingSideRail extends StatelessWidget {
  const _LoadingSideRail();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: ThemeColors.whiteColor.withValues(alpha: 0.92),
        border: Border(
          right: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: const _Shimmer(
        child: Column(
          children: [
            SizedBox(height: 16),
            _SkeletonBox(width: 48, height: 48, radius: 18),
            SizedBox(height: 30),
            _RailSkeletonItem(),
            _RailSkeletonItem(),
            _RailSkeletonItem(),
            _RailSkeletonItem(),
            _RailSkeletonItem(),
          ],
        ),
      ),
    );
  }
}

class _RailSkeletonItem extends StatelessWidget {
  const _RailSkeletonItem();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _SkeletonBox(width: 24, height: 24, radius: 12),
          SizedBox(height: 8),
          _SkeletonBox(width: 48, height: 9, radius: 5),
        ],
      ),
    );
  }
}

class _LoadingBottomNav extends StatelessWidget {
  const _LoadingBottomNav();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: ThemeColors.primary.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.primary.withValues(alpha: 0.16),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const _Shimmer(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SkeletonBox(width: 38, height: 38, radius: 14),
              _SkeletonBox(width: 38, height: 38, radius: 14),
              _SkeletonBox(width: 38, height: 38, radius: 14),
              _SkeletonBox(width: 38, height: 38, radius: 14),
              _SkeletonBox(width: 38, height: 38, radius: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      padding: const EdgeInsets.all(22),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A1230), Color(0xFF9D1740), Color(0xFF3A1117)],
      ),
      borderColor: Colors.white24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  _SkeletonBox(width: 58, height: 58, radius: 29),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(width: 110, height: 13, radius: 6),
                        SizedBox(height: 9),
                        _SkeletonBox(width: 230, height: 24, radius: 8),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const _SkeletonBox(width: 260, height: 13, radius: 6),
              const SizedBox(height: 14),
              _SkeletonBox(
                width: wide ? 280 : double.infinity,
                height: 42,
                radius: 10,
              ),
              const SizedBox(height: 10),
              const _SkeletonBox(width: 220, height: 13, radius: 6),
            ],
          );
          final counter = const _SkeletonBox(
            width: double.infinity,
            height: 156,
            radius: 24,
          );
          return wide
              ? Row(
                  children: [
                    Expanded(child: content),
                    const SizedBox(width: 24),
                    SizedBox(width: 250, child: counter),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [content, const SizedBox(height: 24), counter],
                );
        },
      ),
    );
  }
}

class _QuickActionsSkeleton extends StatelessWidget {
  const _QuickActionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: columns == 1 ? 4.4 : 2.7,
          ),
          itemBuilder: (context, index) => const _PremiumSurface(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                _SkeletonBox(width: 44, height: 44, radius: 14),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 120, height: 15, radius: 6),
                      SizedBox(height: 8),
                      _SkeletonBox(width: 90, height: 11, radius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnalyticsSkeleton extends StatelessWidget {
  const _AnalyticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final left = const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SkeletonBox(width: 180, height: 22, radius: 8),
              SizedBox(height: 10),
              _SkeletonBox(width: 260, height: 13, radius: 6),
              SizedBox(height: 20),
              _SkeletonBox(width: double.infinity, height: 12, radius: 6),
              SizedBox(height: 16),
              _SkeletonBox(width: 150, height: 12, radius: 6),
              SizedBox(height: 10),
              _SkeletonBox(width: 210, height: 12, radius: 6),
            ],
          );
          final right = const _SkeletonBox(
            width: double.infinity,
            height: 178,
            radius: 24,
          );
          return wide
              ? Row(
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 24),
                    SizedBox(width: 280, child: right),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 18), right],
                );
        },
      ),
    );
  }
}

class _MetricStripSkeleton extends StatelessWidget {
  const _MetricStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4
                ? 2.8
                : columns == 2
                ? 2.35
                : 3.6,
          ),
          itemBuilder: (context, index) => const _PremiumSurface(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                _SkeletonBox(width: 42, height: 42, radius: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 70, height: 16, radius: 6),
                      SizedBox(height: 7),
                      _SkeletonBox(width: 90, height: 11, radius: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SkeletonBox(width: 120, height: 19, radius: 7),
        SizedBox(height: 12),
        _ListSkeletonCard(),
        SizedBox(height: 12),
        _ListSkeletonCard(),
        SizedBox(height: 12),
        _ListSkeletonCard(),
      ],
    );
  }
}

class _ListSkeletonCard extends StatelessWidget {
  const _ListSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const _PremiumSurface(
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(width: 48, height: 48, radius: 16),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: double.infinity, height: 17, radius: 7),
                SizedBox(height: 10),
                _SkeletonBox(width: 210, height: 12, radius: 6),
                SizedBox(height: 14),
                Row(
                  children: [
                    _SkeletonBox(width: 72, height: 27, radius: 8),
                    SizedBox(width: 8),
                    _SkeletonBox(width: 88, height: 27, radius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.child, this.baseColor, this.highlightColor});

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base =
        widget.baseColor ??
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    final highlight =
        widget.highlightColor ?? Colors.white.withValues(alpha: 0.70);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final shimmerWidth = bounds.width <= 0 ? 1.0 : bounds.width;
            final slide = (shimmerWidth * 2) * _controller.value;
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.25, 0.50, 0.75],
              transform: _SlidingGradientTransform(slide - shimmerWidth),
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform(this.offset);

  final double offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(offset, 0, 0);
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _PremiumSurface extends StatelessWidget {
  const _PremiumSurface({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient:
                gradient ??
                LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.88),
                    ThemeColors.inputBackground.withValues(alpha: 0.74),
                  ],
                ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: borderColor ?? scheme.primary.withValues(alpha: 0.10),
            ),
            boxShadow: [
              BoxShadow(
                color: ThemeColors.logoDeep.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.62),
                blurRadius: 10,
                offset: const Offset(-6, -6),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class _AnimatedReveal extends StatelessWidget {
  const _AnimatedReveal({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 620 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _BlurCircle extends StatelessWidget {
  const _BlurCircle({
    required this.color,
    required this.size,
    this.alpha = 0.24,
  });

  final Color color;
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: alpha),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: alpha),
            blurRadius: 55,
            spreadRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _CoupleAvatar extends StatelessWidget {
  const _CoupleAvatar({required this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _ResilientAvatar(
          imageUrl: user?.photoURL,
          initials: _initials(name ?? user?.displayName ?? 'KW'),
          size: 58,
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: ThemeColors.logoGold),
            ),
            child: const AppLogo(size: 18, padding: 1, showBackground: false),
          ),
        ),
      ],
    );
  }
}

class _ResilientAvatar extends StatefulWidget {
  const _ResilientAvatar({
    required this.initials,
    required this.size,
    this.imageUrl,
  });

  final String initials;
  final double size;
  final String? imageUrl;

  @override
  State<_ResilientAvatar> createState() => _ResilientAvatarState();
}

class _ResilientAvatarState extends State<_ResilientAvatar> {
  bool _imageFailed = false;

  @override
  void didUpdateWidget(covariant _ResilientAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _imageFailed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.imageUrl;
    final showImage = imageUrl != null && imageUrl.isNotEmpty && !_imageFailed;
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3DC), Color(0xFFE8B75C)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: showImage
          ? Image.network(
              imageUrl,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                if (!_imageFailed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _imageFailed = true);
                  });
                }
                return _AvatarInitials(initials: widget.initials);
              },
            )
          : _AvatarInitials(initials: widget.initials),
    );
  }
}

class _AvatarInitials extends StatelessWidget {
  const _AvatarInitials({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: const TextStyle(
        color: ThemeColors.logoDeep,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.color,
    required this.center,
    this.size = 86,
    this.stroke = 9,
  });

  final double progress;
  final Color color;
  final Widget center;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => SizedBox.square(
        dimension: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(
                progress: value,
                color: color,
                stroke: stroke,
              ),
            ),
            center,
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = color.withValues(alpha: 0.13);
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [color, ThemeColors.logoGold, color],
      ).createShader(rect);
    canvas.drawArc(rect.deflate(stroke / 2), 0, math.pi * 2, false, base);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action, this.onTap});

  final String title;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              action,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}
