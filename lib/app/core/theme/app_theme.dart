import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Unified centralized theme colors system
/// Combines ThemeColors with legacy ThemeColors for complete app color palette
/// Supports both light and dark themes
class ThemeColors {
  // ============================================================================
  // LIGHT THEME COLORS (Constants)
  // ============================================================================
  static const Color _lightPrimary = Color(0xFF186063);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightOnSurface = Color(0xFF0F3F41);
  static const Color _lightOnSurfaceSecondary = Color(0xFF5E637B);
  static const Color _lightInputBackground = Color(0xFFF4F7FF);
  static const Color _lightBorder = Color(
    0xFF186063,
  ); // with 0.08 alpha in getter
  static const Color _lightScaffold = Color(0xFFFFFFFF);
  static const Color _lightScaffoldGradientStart = Color(0xFFe0f7f7);
  static const Color _lightScaffoldGradientEnd = Color(0xFFFFFFFF);

  // ============================================================================
  // DARK THEME COLORS (Constants)
  // ============================================================================
  static const Color _darkPrimary = Color(0xFF0FA394);
  static const Color _darkSurface = Color(0xFF1A2332);
  static const Color _darkOnSurface = Color(0xFFE5E7EB);
  static const Color _darkOnSurfaceSecondary = Color(0xFF9CA3AF);
  static const Color _darkInputBackground = Color(0xFF2D3E50);
  static const Color _darkBorder = Color(
    0xFF2D3E50,
  ); // with 0.5 alpha in getter
  static const Color _darkScaffold = Color(0xFF131A37);
  static const Color _darkScaffoldGradientStart = Color(0xFF0F1720);
  static const Color _darkScaffoldGradientEnd = Color(0xFF131A37);
  static const Color _darkSurfaceOverlay = Color(0xFF1A2332);

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
  static const Color secondaryColor = Color(0xffbaad8c);

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
      ThemeService.isDark() ? null : const Color(0xFF0C8C80);
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_lightSurface, _lightInputBackground],
        );

  static LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[
      primary,
      primary.withValues(alpha: ThemeService.isDark() ? 0.7 : 0.6),
    ],
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
            const Color(0xFF102739),
            const Color(0xFF15293C),
            const Color(0xFF0F1720),
          ]
        : const <Color>[
            Color(0xFF06373B),
            Color(0xFF075B5F),
            Color(0xFF0EA493),
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

  static bool get _isArabic => Get.locale?.languageCode == 'ar';
  static String get _fontFamily => _isArabic ? 'NotoSansArabic' : 'Outfit';
  static const List<String> _fontFamilyFallback = <String>[
    'Poppins',
    'SF UI Display',
  ];

  static ThemeData lightTheme(BuildContext context) => ThemeData(
    fontFamily: _fontFamily,
    fontFamilyFallback: _fontFamilyFallback,
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimary,
    scaffoldBackgroundColor: _lightScaffold,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: _lightPrimary,
      onPrimary: whiteColor,
      primaryContainer: Color(0xFFD0ECEB),
      onPrimaryContainer: Color(0xFF0D2B2C),
      secondary: Color(0xFF186063),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFF0FA394),
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
        fontFamily: 'Outfit',
        fontSize: 24,
        fontWeight: FontWeight.w700,
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
        borderSide: const BorderSide(color: Color(0xFF0CA394), width: 1.4),
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
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: whiteColor,
        elevation: 0,
        minimumSize: const Size(64, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        minimumSize: const Size(64, 52),
        side: BorderSide(color: _lightPrimary.withValues(alpha: 0.18)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
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
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
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
    fontFamilyFallback: _fontFamilyFallback,
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimary,
    scaffoldBackgroundColor: _darkScaffoldGradientStart,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: _darkPrimary,
      onPrimary: whiteColor,
      primaryContainer: Color(0xFF0B5751),
      onPrimaryContainer: Color(0xFF7FF7F0),
      secondary: Color(0xFF80CCBB),
      onSecondary: Color(0xFF004138),
      tertiary: Color(0xFF0FA394),
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
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
