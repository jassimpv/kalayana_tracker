import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class EventReminder {
  const EventReminder({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.isDone,
  });

  factory EventReminder.fromJson(Map<String, dynamic> json) {
    return EventReminder(
      id: json['id'] as String? ?? newId(),
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Date',
      dueDate: dateFromJson(json['dueDate']) ?? DateTime.now(),
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String category;
  final DateTime dueDate;
  final bool isDone;

  bool isOverdue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return !isDone && due.isBefore(today);
  }

  EventReminder copyWith({bool? isDone}) => EventReminder(
    id: id,
    title: title,
    category: category,
    dueDate: dueDate,
    isDone: isDone ?? this.isDone,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'dueDate': dueDate.toIso8601String(),
    'isDone': isDone,
  };
}
