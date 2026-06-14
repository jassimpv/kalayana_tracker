import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Unified centralized theme colors system
/// Combines ThemeColors with legacy ThemeColors for complete app color palette
/// Supports both light and dark themes
class ThemeColors {
  // ============================================================================
  // LIGHT THEME COLORS (Constants)
  // ============================================================================
  static const Color _lightPrimary = Color(0xFF8F1438);
  static const Color _lightSurface = Color(0xFFFFFCF6);
  static const Color _lightOnSurface = Color(0xFF331316);
  static const Color _lightOnSurfaceSecondary = Color(0xFF7A6255);
  static const Color _lightInputBackground = Color(0xFFFFF4E6);
  static const Color _lightBorder = Color(
    0xFFB7803B,
  ); // with 0.08 alpha in getter
  static const Color _lightScaffold = Color(0xFFFFF8ED);
  static const Color _lightScaffoldGradientStart = Color(0xFFFFF5E8);
  static const Color _lightScaffoldGradientEnd = Color(0xFFFFFBF4);

  // ============================================================================
  // DARK THEME COLORS (Constants)
  // ============================================================================
  static const Color _darkPrimary = Color(0xFF41C5B6);
  static const Color _darkSurface = Color(0xFF12231F);
  static const Color _darkOnSurface = Color(0xFFFFF4EA);
  static const Color _darkOnSurfaceSecondary = Color(0xFFD7C7BE);
  static const Color _darkInputBackground = Color(0xFF20332F);
  static const Color _darkBorder = Color(
    0xFF2F6F68,
  ); // with 0.5 alpha in getter
  static const Color _darkScaffold = Color(0xFF0C1715);
  static const Color _darkScaffoldGradientStart = Color(0xFF081311);
  static const Color _darkScaffoldGradientEnd = Color(0xFF1E2B25);
  static const Color _darkSurfaceOverlay = Color(0xFF12231F);

  // ============================================================================
  // SEMANTIC COLORS (Universal)
  // ============================================================================
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color error = Color(0xFFFF0000);
  static const Color completedColor = Color(0xFF12B76A);
  // DARK MODE SUCCESS - Light mode uses completedColor
  static const Color _darkSuccess = Color(0xFF10B981);

  // ============================================================================
  // STATUS & SEMANTIC COLORS
  // ============================================================================
  static const Color statusPurple = Color(0xffA88FF3);
  static const Color statusGreen = Color(0xff12B76A);

  // ============================================================================
  // CUSTOM PALETTE COLORS
  // ============================================================================
  static const Color darkGreen = Color(0xff12673F);
  static const Color secondaryColor = Color(0xFFD99A3F);
  static const Color logoCopper = Color(0xFFC46F53);
  static const Color logoRose = Color(0xFFF2A17D);
  static const Color logoGold = Color(0xFFE8B75C);
  static const Color logoDeep = Color(0xFF3A1117);
  static const Color weddingTeal = Color(0xFF9D1740);
  static const Color deepTeal = Color(0xFF4A101A);
  static const Color terracotta = Color(0xFFB04B2F);
  static const Color champagne = Color(0xFFFFE4B8);

  // ============================================================================
  // DEPRECATED LEGACY COLORS (Kept for backward compatibility)
  // ============================================================================
  static const Color themeColor = _lightPrimary;
  static const Color headingColor = _lightOnSurface;
  static const Color themeTextColor = Color(0xFF122044);
  static const Color greyTextColor = _lightOnSurfaceSecondary;

  // ============================================================================
  // THEME-AWARE DYNAMIC COLORS (Light/Dark Mode Support)
  // ============================================================================

  // CORE COLORS

  static Color get primary =>
      ThemeService.isDark() ? _darkPrimary : _lightPrimary;
  static const Color onPrimary = whiteColor;
  static Color get blackWhite =>
      ThemeService.isDark() ? whiteColor : blackColor;
  static Color get whitePrimary =>
      ThemeService.isDark() ? whiteColor : _lightPrimary;

  // SURFACE COLORS
  static Color get surface =>
      ThemeService.isDark() ? _darkSurface : _lightSurface;
  static Color get onSurface =>
      ThemeService.isDark() ? _darkOnSurface : _lightOnSurface;
  static Color get onSurfaceSecondary => ThemeService.isDark()
      ? _darkOnSurfaceSecondary
      : _lightOnSurfaceSecondary;
  static Color get scaffoldColor =>
      ThemeService.isDark() ? _darkScaffold : _lightScaffold;
  static Color get inputBackground =>
      ThemeService.isDark() ? _darkInputBackground : _lightInputBackground;

  // BORDERS & DIVIDERS
  static Color get border => ThemeService.isDark()
      ? _darkBorder.withValues(alpha: 0.5)
      : _lightBorder.withValues(alpha: 0.08);

  // STATUS COLORS
  static Color get success =>
      ThemeService.isDark() ? _darkSuccess : completedColor;

  // SHADOWS
  static Color get shadow => ThemeService.isDark()
      ? blackColor.withValues(alpha: 0.3)
      : blackColor.withValues(alpha: 0.08);

  // DIALOG & MODAL
  static Color get surfaceOverlay => ThemeService.isDark()
      ? _darkSurfaceOverlay.withValues(alpha: 0.95)
      : whiteColor.withValues(alpha: 0.95);

  static Color get surfaceOverlayBorder => ThemeService.isDark()
      ? whiteColor.withValues(alpha: 0.08)
      : primary.withValues(alpha: 0.2);

  static Color? get lightScaffoldAuthBg =>
      ThemeService.isDark() ? null : const Color(0xFF8F1438);
  // TEXT
  static Color get textPrimary => onSurface;
  static Color get textSecondary => onSurfaceSecondary;

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static Gradient get surfaceGradient => ThemeService.isDark()
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_darkSurface, _darkScaffold],
        )
      : const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomRight,
          colors: <Color>[
            _lightScaffoldGradientStart,
            _lightSurface,
            _lightScaffoldGradientEnd,
          ],
        );

  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      primary,
      ThemeService.isDark() ? const Color(0xFF8F1438) : weddingTeal,
    ],
  );

  static LinearGradient get logoBackgroundGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFFFFF5EA), Color(0xFFFFD2BA), Color(0xFFE7AD4F)],
  );

  static LinearGradient get scaffoldGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: ThemeService.isDark()
        ? const <Color>[_darkScaffoldGradientStart, _darkScaffoldGradientEnd]
        : const <Color>[_lightScaffoldGradientStart, _lightScaffoldGradientEnd],
  );

  static LinearGradient get appBarGradient => LinearGradient(
    colors: ThemeService.isDark()
        ? <Color>[
            const Color(0xFF0B2522),
            const Color(0xFF10433E),
            const Color(0xFF6C3A2D),
          ]
        : const <Color>[
            Color(0xFF7A1230),
            Color(0xFF9D1740),
            Color(0xFFB04B2F),
          ],
  );
  // ============================================================================
  // COMMON ALIASES
  // ============================================================================
  static Color get inputBorder => border;
  static Color get dialogBackground => surface;
  static Color get dialogBorder => surfaceOverlayBorder;
  static Color get modalBackground => surfaceOverlay;
  static Color get modalBorder => surfaceOverlayBorder;

  // ============================================================================
  // THEME DATA FACTORIES
  // ============================================================================

  static const String _fontFamily = 'Outfit';

  static ThemeData lightTheme(BuildContext context) => ThemeData(
    fontFamily: _fontFamily,
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimary,
    scaffoldBackgroundColor: _lightScaffold,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: whiteColor,
      primaryContainer: Color(0xFFFFD8E2),
      onPrimaryContainer: Color(0xFF4A101A),
      secondary: Color(0xFFD99A3F),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFB04B2F),
      onTertiary: Color(0xFFFFFFFF),
      error: error,
      onError: Color(0xFFFFFFFF),
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      onSurfaceVariant: _lightOnSurfaceSecondary,
      outline: _lightBorder,
    ),
    textTheme: Theme.of(context).textTheme.apply(
      bodyColor: _lightOnSurface,
      displayColor: _lightOnSurface,
      fontFamily: _fontFamily,
    ),
    cardColor: _lightSurface,
    dividerColor: _lightBorder,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: whiteColor,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: whiteColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: _lightPrimary.withValues(alpha: 0.10)),
      ),
      shadowColor: _lightPrimary.withValues(alpha: 0.10),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightInputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: const TextStyle(
        color: _lightOnSurfaceSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(
        color: _lightOnSurfaceSecondary.withValues(alpha: 0.72),
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: _lightPrimary,
      suffixIconColor: _lightPrimary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _lightPrimary.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: _lightPrimary.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: logoGold, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: error, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: whiteColor,
        minimumSize: const Size(64, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: whiteColor,
        elevation: 0,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        minimumSize: const Size(64, 52),
        side: BorderSide(color: _lightPrimary.withValues(alpha: 0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: whiteColor,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 74,
      elevation: 0,
      backgroundColor: whiteColor.withValues(alpha: 0.92),
      indicatorColor: _lightPrimary,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? whiteColor
              : _lightOnSurfaceSecondary,
          fontSize: 11,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w600,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? whiteColor
              : _lightOnSurfaceSecondary,
          size: 22,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: whiteColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
  );

  static ThemeData darkTheme(BuildContext context) => ThemeData(
    fontFamily: _fontFamily,
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimary,
    scaffoldBackgroundColor: _darkScaffoldGradientStart,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: whiteColor,
      primaryContainer: Color(0xFF0F4F49),
      onPrimaryContainer: Color(0xFFD8F1ED),
      secondary: Color(0xFFC46F53),
      onSecondary: Color(0xFF26100A),
      tertiary: Color(0xFFE7AD4F),
      onTertiary: Color(0xFFFFFFFF),
      error: error,
      onError: Color(0xFFFFFFFF),
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      onSurfaceVariant: _darkOnSurfaceSecondary,
      outline: _darkBorder,
    ),
    textTheme: Theme.of(context).textTheme.apply(
      bodyColor: _darkOnSurface,
      displayColor: _darkOnSurface,
      fontFamily: _fontFamily,
    ),
    cardColor: _darkSurface,
    dividerColor: _darkBorder,
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: whiteColor.withValues(alpha: 0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkInputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: const TextStyle(
        color: _darkOnSurfaceSecondary,
        fontWeight: FontWeight.w500,
      ),
      prefixIconColor: _darkPrimary,
      suffixIconColor: _darkPrimary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: whiteColor.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: whiteColor.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: _darkPrimary, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: whiteColor,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
  );
}

class ThemeController extends GetxController {
  late Rx<ThemeMode> selectedMode;

  @override
  void onInit() {
    super.onInit();
    selectedMode = ThemeService.themeMode.obs;
  }

  Future<void> updateTheme(ThemeMode mode) async {
    if (selectedMode.value == mode) return;
    selectedMode.value = mode;
    await ThemeService.setThemeMode(mode);
  }

  String getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark'.tr;
      case ThemeMode.light:
        return 'light'.tr;
      case ThemeMode.system:
        return 'system'.tr;
    }
  }

  IconData getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return CupertinoIcons.moon_fill;
      case ThemeMode.light:
        return CupertinoIcons.sun_max_fill;
      case ThemeMode.system:
        return CupertinoIcons.circle_lefthalf_fill;
    }
  }
}

class ThemeService {
  static ThemeMode themeMode = ThemeMode.light;
  static final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(
    ThemeMode.light,
  );

  static Future<void> init() async {
    const String stored = 'light';
    // await PreferenceUtils.getString(_key);

    if (stored == 'light') {
      themeMode = ThemeMode.light;
    } else if (stored == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (stored == 'system') {
      themeMode = ThemeMode.system;
    }
    themeModeNotifier.value = themeMode;
    Get.changeThemeMode(themeMode);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    themeModeNotifier.value = themeMode;

    // Apply immediately
    Get.changeThemeMode(themeMode);

    // Persist
    // await PreferenceUtils.saveString(_key, modeString);
  }

  static Future<void> toggleTheme() async {
    if (themeMode == ThemeMode.light) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.light;
    }

    themeModeNotifier.value = themeMode;

    // Apply immediately
    Get.changeThemeMode(themeMode);

    // Persist
    // await PreferenceUtils.saveString(
    //   _key,
    //   themeMode == ThemeMode.dark ? 'dark' : 'light',
    // );
  }

  static bool isDark() {
    if (themeMode == ThemeMode.dark) {
      return true;
    } else if (themeMode == ThemeMode.system) {
      return PlatformDispatcher.instance.platformBrightness == Brightness.dark;
    }
    return false;
  }
}
