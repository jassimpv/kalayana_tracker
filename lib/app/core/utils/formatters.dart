import 'package:cloud_firestore/cloud_firestore.dart';

double? numberFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString().replaceAll(',', '').trim());
}

DateTime? dateFromJson(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

String profileText(
  Map<String, dynamic> profile,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = profile[key]?.toString().trim();
    if (value != null && value.isNotEmpty) return value;
  }
  return fallback;
}

String profileGroom(Map<String, dynamic> profile) {
  return profileText(profile, const ['groomName']);
}

String profileBride(Map<String, dynamic> profile) {
  return profileText(profile, const ['brideName']);
}

DateTime? profileMarriageDate(Map<String, dynamic> profile) {
  return dateFromJson(profile['marriageDate']);
}

int? daysUntilDate(DateTime? date, {DateTime? from}) {
  if (date == null) return null;
  final todaySource = from ?? DateTime.now();
  final today = DateTime(todaySource.year, todaySource.month, todaySource.day);
  final target = DateTime(date.year, date.month, date.day);
  return target.difference(today).inDays;
}

double? moneyFromText(String text) {
  final cleaned = text.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  return double.tryParse(cleaned);
}

String moneyText(double? value) => value == null ? '' : formatMoney(value);

String moneyOrDash(double? value) =>
    value == null ? '-' : '₹${formatMoney(value)}';

String formatMoney(double value) {
  final rounded = value.round();
  final negative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    final remaining = digits.length - index;
    buffer.write(digits[index]);
    if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
  }
  return negative ? '-$buffer' : buffer.toString();
}

const months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDate(DateTime date) =>
    '${months[date.month - 1]} ${date.day}, ${date.year}';

String newId() => DateTime.now().microsecondsSinceEpoch.toString();
