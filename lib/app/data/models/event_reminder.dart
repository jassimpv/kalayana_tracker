import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class EventReminder {
  const EventReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.isDone,
    this.amount = 0,
    this.linkedExpenseId = '',
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'] as String? ?? newId(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Date',
      dueDate: dateFromJson(json['dueDate']) ?? DateTime.now(),
      isDone: json['isDone'] as bool? ?? false,
      amount: numberFromJson(json['amount']) ?? 0,
      linkedExpenseId: json['linkedExpenseId'] as String? ?? '',
    );
  }

  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final bool isDone;
  final double amount;
  final String linkedExpenseId;

  bool isOverdue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !isDone && due.isBefore(today);
  }

  EventReminder copyWith({
    String? title,
    String? category,
    DateTime? dueDate,
    bool? isDone,
    double? amount,
    String? linkedExpenseId,
  }) => EventReminder(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    dueDate: dueDate ?? this.dueDate,
    isDone: isDone ?? this.isDone,
    amount: amount ?? this.amount,
    linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'isDone': isDone,
    'amount': amount,
    'linkedExpenseId': linkedExpenseId,
  };
}
