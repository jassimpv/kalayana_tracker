import 'dart:math' as math;

import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

const expenseStatusPending = 'Pending';
const expenseStatusPartiallyPaid = 'Partially Paid';
const expenseStatusCompleted = 'Completed';
const expenseStatusPaidByOther = 'Paid by Other';
const expenseStatusNeedToRepay = 'Need to Repay';
const expenseStatusOverdue = 'Overdue';

class PaymentSplit {
  const PaymentSplit({
    required this.amount,
    required this.date,
    this.paidBy = '',
    this.notes = '',
  });

  factory PaymentSplit.fromJson(Map<String, dynamic> json) {
    return PaymentSplit(
      amount: numberFromJson(json['amount']) ?? 0,
      date:
          dateFromJson(json['date']) ??
          dateFromJson(json['paidAt']) ??
          DateTime.now(),
      paidBy: json['paidBy'] as String? ?? '',
      notes: json['notes'] as String? ?? json['note'] as String? ?? '',
    );
  }

  final double amount;
  final DateTime date;
  final String paidBy;
  final String notes;

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'date': date.toIso8601String(),
    'paidBy': paidBy,
    'notes': notes,
  };
}

class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.name,
    required this.category,
    required this.totalAmount,
    required this.paidAmount,
    required this.paymentStatus,
    required this.createdDate,
    required this.updatedDate,
    this.pendingAmount,
    this.paidBy = '',
    this.repayPerson = '',
    this.needsRepayment = false,
    this.repayAmount = 0,
    this.isRepaymentCompleted = false,
    this.dueDate,
    this.notes = '',
    this.paymentSplit = const [],
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    final total = numberFromJson(json['totalAmount']) ?? 0;
    final paymentSplitSource =
        json['paymentSplit'] as List<dynamic>? ??
        json['payments'] as List<dynamic>? ??
        const [];
    final paymentSplit = paymentSplitSource
        .whereType<Map<String, dynamic>>()
        .map(PaymentSplit.fromJson)
        .toList();
    final paid =
        numberFromJson(json['paidAmount']) ??
        numberFromJson(json['advancePaid']) ??
        paymentSplit.fold<double>(0, (sum, payment) => sum + payment.amount);
    final pending =
        numberFromJson(json['pendingAmount']) ??
        numberFromJson(json['pendingPayment']) ??
        math.max(0, total - paid).toDouble();
    final created =
        dateFromJson(json['createdDate']) ??
        dateFromJson(json['createdAt']) ??
        DateTime.now();
    return ExpenseItem(
      id: json['id'] as String? ?? newId(),
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      totalAmount: total,
      paidAmount: paid,
      pendingAmount: pending,
      paymentStatus:
          json['paymentStatus'] as String? ??
          json['status'] as String? ??
          expenseStatusPending,
      paidBy: json['paidBy'] as String? ?? '',
      repayPerson:
          json['repayPerson'] as String? ??
          json['needToRepayPerson'] as String? ??
          '',
      needsRepayment:
          json['needsRepayment'] as bool? ??
          json['needToRepay'] as bool? ??
          false,
      repayAmount: numberFromJson(json['repayAmount']) ?? 0,
      isRepaymentCompleted: json['isRepaymentCompleted'] as bool? ?? false,
      dueDate: dateFromJson(json['dueDate']),
      notes: json['notes'] as String? ?? json['note'] as String? ?? '',
      createdDate: created,
      updatedDate: dateFromJson(json['updatedDate']) ?? created,
      paymentSplit: paymentSplit,
    );
  }

  final String id;
  final String name;
  final String category;
  final double totalAmount;
  final double paidAmount;
  final double? pendingAmount;
  final String paymentStatus;
  final String paidBy;
  final String repayPerson;
  final bool needsRepayment;
  final double repayAmount;
  final bool isRepaymentCompleted;
  final DateTime? dueDate;
  final String notes;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<PaymentSplit> paymentSplit;

  double get advancePaid => paidAmount;
  double get pendingPayment => pendingForSummary;
  double get knownTotal => totalAmount;
  double get paidForSummary => math.min(totalAmount, paidAmount).toDouble();
  double get pendingForSummary =>
      math.max(0, totalAmount - paidForSummary).toDouble();
  double get repaymentPending =>
      needsRepayment && !isRepaymentCompleted ? repayAmount : 0;
  double get displayPending => pendingForSummary;
  double get splitPaidTotal =>
      paymentSplit.fold(0, (sum, payment) => sum + payment.amount);
  bool get hasSplitPayments => paymentSplit.length > 1;
  bool get hasPartialPayment => paidForSummary > 0 && pendingForSummary > 0;
  bool get isPaidByOther => paidBy.trim().isNotEmpty && paidBy.trim() != 'Self';
  bool get isOverdue =>
      dueDate != null &&
      pendingForSummary > 0 &&
      DateTime.now().isAfter(
        DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 23, 59, 59),
      );
  bool get isCompleted => pendingForSummary == 0 && repaymentPending == 0;

  String get status {
    if (isOverdue) return expenseStatusOverdue;
    if (repaymentPending > 0) return expenseStatusNeedToRepay;
    if (isPaidByOther) return expenseStatusPaidByOther;
    if (paidAmount <= 0) return expenseStatusPending;
    if (paidAmount < totalAmount) return expenseStatusPartiallyPaid;
    return expenseStatusCompleted;
  }

  ExpenseItem copyWith({
    String? id,
    String? name,
    String? category,
    double? totalAmount,
    double? paidAmount,
    double? pendingAmount,
    String? paymentStatus,
    String? paidBy,
    String? repayPerson,
    bool? needsRepayment,
    double? repayAmount,
    bool? isRepaymentCompleted,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? notes,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<PaymentSplit>? paymentSplit,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidBy: paidBy ?? this.paidBy,
      repayPerson: repayPerson ?? this.repayPerson,
      needsRepayment: needsRepayment ?? this.needsRepayment,
      repayAmount: repayAmount ?? this.repayAmount,
      isRepaymentCompleted: isRepaymentCompleted ?? this.isRepaymentCompleted,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      paymentSplit: paymentSplit ?? this.paymentSplit,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'pendingAmount': pendingForSummary,
    'paymentStatus': status,
    'status': status,
    'paidBy': paidBy,
    'repayPerson': repayPerson,
    'needsRepayment': needsRepayment,
    'repayAmount': repayAmount,
    'isRepaymentCompleted': isRepaymentCompleted,
    'dueDate': dueDate?.toIso8601String(),
    'notes': notes,
    'createdDate': createdDate.toIso8601String(),
    'updatedDate': updatedDate.toIso8601String(),
    'paymentSplit': paymentSplit.map((payment) => payment.toJson()).toList(),
    'advancePaid': paidAmount,
    'pendingPayment': pendingForSummary,
  };
}
