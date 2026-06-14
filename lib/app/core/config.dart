import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = "Kalyana Expense Tracker";
  static const String appVersion = "1.0.0";
  static String appCurrency = "₹";
  static String appCurrencyCode = "INR";
  static IconData appCurrencyIcon = Icons.currency_rupee_rounded;

  static void setCurrency({
    required String code,
    required String symbol,
    IconData? icon,
  }) {
    appCurrencyCode = code;
    appCurrency = symbol;
    appCurrencyIcon = icon ?? _currencyIconFor(code);
  }

  static IconData _currencyIconFor(String code) {
    return switch (code.toUpperCase()) {
      'INR' => Icons.currency_rupee_rounded,
      'USD' => Icons.attach_money_rounded,
      'EUR' => Icons.euro_rounded,
      'GBP' => Icons.currency_pound_rounded,
      'JPY' || 'CNY' => Icons.currency_yen_rounded,
      _ => Icons.payments_rounded,
    };
  }
}
