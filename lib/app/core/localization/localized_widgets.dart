import 'package:flutter/material.dart';
import 'translation_service.dart';

/// Const-friendly translation at the presentation boundary. Raw user content
/// continues to use Flutter's Text, without translation.
class LocalizedText extends Text {
  const LocalizedText(
    super.data, {
    super.key,
    super.style,
    super.strutStyle,
    super.textAlign,
    super.textDirection,
    super.locale,
    super.softWrap,
    super.overflow,
    super.textScaler,
    super.maxLines,
    super.semanticsLabel,
    super.semanticsIdentifier,
    super.textWidthBasis,
    super.textHeightBehavior,
    super.selectionColor,
  });

  @override
  String? get data =>
      super.data == null ? null : TranslationService.translate(super.data!);
  @override
  String? get semanticsLabel => super.semanticsLabel == null
      ? null
      : TranslationService.translate(super.semanticsLabel!);
}

/// Keeps form labels const-compatible without translating stored field values.
class LocalizedInputDecoration extends InputDecoration {
  const LocalizedInputDecoration({
    super.icon,
    super.iconColor,
    super.label,
    super.labelText,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helper,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.hintText,
    super.hint,
    super.hintStyle,
    super.hintTextDirection,
    super.hintMaxLines,
    super.hintFadeDuration,
    super.maintainHintSize,
    super.maintainLabelSize,
    super.error,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed,
    super.isDense,
    super.contentPadding,
    super.prefixIcon,
    super.prefixIconConstraints,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixIcon,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconColor,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.filled,
    super.fillColor,
    super.focusColor,
    super.hoverColor,
    super.errorBorder,
    super.focusedBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.enabledBorder,
    super.border,
    super.enabled,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
    super.visualDensity,
  });

  @override
  String? get labelText => _translate(super.labelText);
  @override
  String? get hintText => _translate(super.hintText);
  @override
  String? get helperText => _translate(super.helperText);
  @override
  String? get errorText => _translate(super.errorText);
  @override
  String? get semanticCounterText => _translate(super.semanticCounterText);
  static String? _translate(String? text) =>
      text == null ? null : TranslationService.translate(text);
}
