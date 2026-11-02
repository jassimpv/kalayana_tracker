import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';

/// A solid branded header for standalone pages with light content backgrounds.
class AppPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageAppBar({
    super.key,
    required this.title,
    this.actions,
    this.automaticallyImplyLeading = true,
  });

  final Widget title;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
    title: title,
    actions: actions,
    automaticallyImplyLeading: automaticallyImplyLeading,
    backgroundColor: ThemeColors.themeColor,
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: Theme.of(
      context,
    ).appBarTheme.titleTextStyle?.copyWith(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
      statusBarColor: ThemeColors.themeColor,
    ),
  );
}
