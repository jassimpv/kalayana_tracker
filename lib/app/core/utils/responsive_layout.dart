import 'package:flutter/material.dart';

const double mobileBreakpoint = 600;
const double desktopBreakpoint = 1024;

bool isMobile(BuildContext context) =>
    MediaQuery.sizeOf(context).width < mobileBreakpoint;

bool isTablet(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  return width >= mobileBreakpoint && width <= desktopBreakpoint;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.sizeOf(context).width > desktopBreakpoint;

double responsiveMaxWidth(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < mobileBreakpoint) return double.infinity;
  if (width <= desktopBreakpoint) return 960;
  return 1240;
}

double responsiveHorizontalPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < mobileBreakpoint) return 16;
  if (width <= desktopBreakpoint) return 28;
  return 36;
}

int responsiveGridCount(BuildContext context, {int desktopCount = 3}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < mobileBreakpoint) return 1;
  if (width <= desktopBreakpoint) return 2;
  return desktopCount;
}

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    if (isMobile(context)) return child;

    return Align(
      alignment: alignment,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(
              horizontal: responsiveHorizontalPadding(context),
            ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? responsiveMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class ResponsiveCardGrid extends StatelessWidget {
  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.desktopCount = 3,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio,
  });

  final List<Widget> children;
  final int desktopCount;
  final double spacing;
  final double runSpacing;
  final double? childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final count = responsiveGridCount(context, desktopCount: desktopCount);
    if (count == 1) {
      return Column(children: children);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - (spacing * (count - 1))) / count;
        final itemHeight = childAspectRatio == null
            ? null
            : itemWidth / childAspectRatio!;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth,
                  height: itemHeight,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}
