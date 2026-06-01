import 'package:flutter/material.dart';

Route<dynamic> buildNestedDashboardRoute({
  required RouteSettings settings,
  required Widget child,
  Duration transitionDuration = Duration.zero,
  Offset startOffset = Offset.zero,
}) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) =>
        SizedBox.expand(child: child),
    transitionDuration: transitionDuration,
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (transitionDuration == Duration.zero) return child;
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(curve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}
