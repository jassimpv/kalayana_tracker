import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class PurchaseItem {
  const PurchaseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.status,
    required this.note,
    this.linkedExpenseId = '',
    this.dueDate,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'] as String? ?? newId(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      amount: numberFromJson(json['amount']) ?? 0,
      status: json['status'] as String? ?? 'Planned',
      note: json['note'] as String? ?? '',
      linkedExpenseId: json['linkedExpenseId'] as String? ?? '',
      dueDate: dateFromJson(json['dueDate']),
    );
  }

  final String id;
  final String name;
  final String category;
  final double amount;
  final String status;
  final String note;
  final String linkedExpenseId;
  final DateTime? dueDate;

  PurchaseItem copyWith({
    String? name,
    String? category,
    double? amount,
    String? status,
    String? note,
    String? linkedExpenseId,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) => PurchaseItem(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    status: status ?? this.status,
    note: note ?? this.note,
    linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
    dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'amount': amount,
    'status': status,
    'note': note,
    'linkedExpenseId': linkedExpenseId,
    'dueDate': dueDate?.toIso8601String(),
  };
}
