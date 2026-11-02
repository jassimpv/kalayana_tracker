import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({super.key});
  @override
  State<LanguageWidget> createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  bool busy = false;
  @override
  Widget build(BuildContext context) {
    final arabic = Localizations.localeOf(context).languageCode == 'ar';
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
        foregroundColor: Theme.of(context).colorScheme.primary,
        shape: const StadiumBorder(),
      ),
      onPressed: busy
          ? null
          : () async {
              setState(() => busy = true);
              try {
                await TranslationService.updateLocale(
                  arabic
                      ? TranslationService.locale
                      : TranslationService.supportedLocales[1],
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        TranslationService.translate(
                          'Unable to change language. Please try again.',
                        ),
                      ),
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => busy = false);
              }
            },
      icon: const Icon(Icons.language, size: 18),
      label: Text(arabic ? 'English' : 'العربية'),
    );
  }
}
