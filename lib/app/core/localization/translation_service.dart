import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ar_ae.dart';
import 'en_us.dart';

/// Matches nemaCollection's GetX maps, saved preference and device fallback.
class TranslationService extends Translations {
  static const locale = Locale('en', 'US');
  static const fallbackLocale = locale;
  static const supportedLocales = [locale, Locale('ar', 'AE')];
  static const _preferenceKey = 'languageCode';
  static Locale _currentLocale = locale;
  static bool _updating = false;
  static void Function()? onLocaleChanged;
  static Locale get currentLocale => _currentLocale;
  static bool get isArabic =>
      (Get.locale ?? _currentLocale).languageCode == 'ar';

  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'ar_AE': arAe};

  static Future<void> init() async {
    final deviceLanguage = PlatformDispatcher.instance.locale.languageCode;
    _currentLocale = deviceLanguage == 'ar' ? supportedLocales[1] : locale;
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = preferences.getString(_preferenceKey);
      if (saved != null) {
        _currentLocale = saved == 'ar' ? supportedLocales[1] : locale;
      } else {
        await preferences.setString(
          _preferenceKey,
          _currentLocale.languageCode,
        );
      }
    } catch (_) {
      // A preference-storage failure should not block app startup.
    }
  }

  static Future<void> updateLocale(Locale newLocale) async {
    if (_updating ||
        !supportedLocales.contains(newLocale) ||
        _currentLocale == newLocale) {
      return;
    }
    _updating = true;
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(
        _preferenceKey,
        newLocale.languageCode,
      );
      if (!saved) throw StateError('Unable to save the language preference.');
      _currentLocale = newLocale;
      await Get.updateLocale(newLocale);
      onLocaleChanged?.call();
    } finally {
      _updating = false;
    }
  }

  static final _templates = [
    for (final key
        in (enUs.keys.where((key) => key.contains(RegExp(r'@\w+'))).toList()
          ..sort(
            (a, b) => b
                .replaceAll(RegExp(r'@\w+'), '')
                .length
                .compareTo(a.replaceAll(RegExp(r'@\w+'), '').length),
          )))
      _TranslationTemplate(key),
  ];

  /// Localizes presentation only. Database values and exported records stay
  /// canonical. Template parameters are preserved, including names and money.
  static String translate(String text) {
    if (!isArabic || text.isEmpty) return text;
    if (arAe.containsKey(text)) return text.tr;
    for (final prefix in ['Bad state: ', 'FormatException: ']) {
      if (text.startsWith(prefix)) {
        return translate(text.substring(prefix.length));
      }
    }
    for (final template in _templates) {
      final match = template.pattern.firstMatch(text);
      if (match == null) continue;
      return template.key.trParams({
        for (var i = 0; i < template.parameters.length; i++)
          template.parameters[i]: '\u2068${match.group(i + 1)}\u2069',
      });
    }
    return text;
  }
}

class _TranslationTemplate {
  _TranslationTemplate(this.key) {
    final buffer = StringBuffer('^');
    var offset = 0;
    for (final match in RegExp(r'@(\w+)').allMatches(key)) {
      buffer.write(RegExp.escape(key.substring(offset, match.start)));
      buffer.write('([\\s\\S]+?)');
      parameters.add(match.group(1)!);
      offset = match.end;
    }
    buffer.write(RegExp.escape(key.substring(offset)));
    buffer.write(r'$');
    pattern = RegExp(buffer.toString());
  }
  final String key;
  final parameters = <String>[];
  late final RegExp pattern;
}
