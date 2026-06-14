import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

class DashboardFormPage extends StatelessWidget {
  const DashboardFormPage({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: ThemeColors.primary,
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: DashboardAdaptiveScroll(
          padding: EdgeInsets.fromLTRB(14, 14, 14, 18 + keyboardInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class DashboardAdaptiveScroll extends StatefulWidget {
  const DashboardAdaptiveScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.overflowTolerance = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double overflowTolerance;

  @override
  State<DashboardAdaptiveScroll> createState() =>
      _DashboardAdaptiveScrollState();
}

class _DashboardAdaptiveScrollState extends State<DashboardAdaptiveScroll> {
  final _contentKey = GlobalKey();
  bool _canScroll = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedPadding = widget.padding.resolve(
          Directionality.of(context),
        );
        final availableHeight =
            constraints.maxHeight - resolvedPadding.vertical;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final renderBox =
              _contentKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox == null) return;
          final shouldScroll =
              renderBox.size.height >
              availableHeight + widget.overflowTolerance;
          if (shouldScroll == _canScroll) return;
          setState(() => _canScroll = shouldScroll);
        });

        return SingleChildScrollView(
          physics: _canScroll
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: widget.padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: KeyedSubtree(key: _contentKey, child: widget.child),
          ),
        );
      },
    );
  }
}

class DashboardFormIntroCard extends StatelessWidget {
  const DashboardFormIntroCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: ThemeColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ThemeColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardFormCard extends StatelessWidget {
  const DashboardFormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class DashboardDatePickerTile extends StatelessWidget {
  const DashboardDatePickerTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.84),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: scheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Clear date',
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: scheme.outline,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
