import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';

class ExpenseItem {
  final String id;
  final String name;
  final String category;
  final String notes;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final String paymentStatus;
  final String paidBy;
  final String paidByPersonId;
  final String paidByPersonName;
  final String repayPerson;
  final double repayAmount;
  final DateTime? dueDate;
  final DateTime createdDate;
  final DateTime updatedDate;
  final bool needsRepayment;
  final bool isRepaymentCompleted;
  final List<PaymentSplit> paymentSplit;
  final String sourceShoppingItemId;
  final String sourceReminderId;

  ExpenseItem({
    this.id = '',
    this.name = '',
    this.category = '',
    this.notes = '',
    this.totalAmount = 0,
    this.paidAmount = 0,
    this.pendingAmount = 0,
    this.paymentStatus = '',
    this.paidBy = '',
    this.paidByPersonId = '',
    this.paidByPersonName = '',
    this.repayPerson = '',
    this.repayAmount = 0,
    this.dueDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    this.needsRepayment = false,
    this.isRepaymentCompleted = false,
    this.paymentSplit = const [],
    this.sourceShoppingItemId = '',
    this.sourceReminderId = '',
  }) : createdDate = createdDate ?? DateTime.now(),
       updatedDate = updatedDate ?? createdDate ?? DateTime.now();

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    final paymentSplit =
        ((json['paymentSplit'] ?? json['payments']) as List<dynamic>?)
            ?.map((item) => PaymentSplit.fromJson(_toMap(item)))
            .toList() ??
        const <PaymentSplit>[];
    final totalAmount = _toDouble(json['totalAmount']);
    final splitPaidAmount = paymentSplit.fold<double>(
      0,
      (total, payment) => total + payment.amount,
    );
    final paidAmount = json.containsKey('paidAmount')
        ? _toDouble(json['paidAmount'])
        : json.containsKey('advancePaid')
        ? _toDouble(json['advancePaid'])
        : splitPaidAmount;
    final firstPayment = paymentSplit.isEmpty ? null : paymentSplit.first;
    final repaymentSplit = paymentSplit.firstWhere(
      (item) => item.repayAmount > 0 || item.repayPerson.trim().isNotEmpty,
      orElse: () => PaymentSplit(date: _emptyDate),
    );
    final needsRepayment =
        json['needsRepayment'] == true || json['needToRepay'] == true;
    final repayPerson =
        json['repayPerson']?.toString() ??
        json['needToRepayPerson']?.toString() ??
        repaymentSplit.repayPerson;
    final parsedRepayAmount = json.containsKey('repayAmount')
        ? _toDouble(json['repayAmount'])
        : repaymentSplit.repayAmount;

    return ExpenseItem(
      id: json['id']?.toString() ?? _newId(),
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      notes: json['notes']?.toString() ?? json['note']?.toString() ?? '',
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      pendingAmount: json.containsKey('pendingAmount')
          ? _toDouble(json['pendingAmount'])
          : json.containsKey('pendingPayment')
          ? _toDouble(json['pendingPayment'])
          : _calculatePendingAmount(totalAmount, paidAmount),
      paymentStatus:
          json['paymentStatus']?.toString() ??
          json['status']?.toString() ??
          _deriveExpenseStatus(totalAmount, paidAmount),
      paidBy: json['paidBy']?.toString() ?? firstPayment?.paidBy ?? '',
      paidByPersonId:
          json['paidByPersonId']?.toString() ??
          firstPayment?.paidByPersonId ??
          '',
      paidByPersonName:
          json['paidByPersonName']?.toString() ??
          firstPayment?.paidByPersonName ??
          '',
      repayPerson: repayPerson,
      repayAmount: parsedRepayAmount > 0 || !needsRepayment
          ? parsedRepayAmount
          : paidAmount,
      dueDate: _toDateTime(json['dueDate']),
      createdDate:
          _toDateTime(json['createdDate']) ?? _toDateTime(json['createdAt']),
      updatedDate:
          _toDateTime(json['updatedDate']) ?? _toDateTime(json['updatedAt']),
      needsRepayment: needsRepayment,
      isRepaymentCompleted: json['isRepaymentCompleted'] == true,
      paymentSplit: paymentSplit,
      sourceShoppingItemId: json['sourceShoppingItemId']?.toString() ?? '',
      sourceReminderId: json['sourceReminderId']?.toString() ?? '',
    );
  }

  factory ExpenseItem.fromMap(Map<String, dynamic> map) {
    return ExpenseItem.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'notes': notes,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'dueDate': dueDate?.toIso8601String(),
      'createdDate': createdDate.toIso8601String(),
      'updatedDate': updatedDate.toIso8601String(),
      'repayPerson': repayPerson,
      'repayAmount': repayAmount,
      'needsRepayment': needsRepayment,
      'isRepaymentCompleted': isRepaymentCompleted,
      'paymentSplit': paymentSplit.map((item) => item.toJson()).toList(),
      'sourceShoppingItemId': sourceShoppingItemId,
      'sourceReminderId': sourceReminderId,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  double get amount => totalAmount;

  double get advancePaid => paidAmount;

  double get pendingPayment => pendingForSummary;

  double get remainingAmount => pendingForSummary;

  double get knownTotal => totalAmount;

  double get paidForSummary => paidAmount;

  double get pendingForSummary =>
      _calculatePendingAmount(totalAmount, paidAmount);

  double get displayPending => pendingForSummary;

  double get splitPaidTotal =>
      paymentSplit.fold<double>(0, (total, payment) => total + payment.amount);

  bool get hasSplitPayments => paymentSplit.length > 1;

  double get repaymentPending {
    if (!needsRepayment || isRepaymentCompleted) {
      return 0;
    }

    return repaymentAmount;
  }

  double get repaymentAmount =>
      needsRepayment && repayAmount <= 0 ? paidAmount : repayAmount;

  String get displayPaidBy {
    final normalizedPersonName = paidByPersonName.trim();
    if (normalizedPersonName.isNotEmpty) {
      return normalizedPersonName;
    }

    final normalizedPaidBy = paidBy.trim();
    if (normalizedPaidBy.isNotEmpty) {
      return normalizedPaidBy;
    }

    final firstPayment = paymentSplit.isEmpty ? null : paymentSplit.first;
    return firstPayment?.displayPaidBy ?? 'Self';
  }

  double get paidPercentage {
    if (totalAmount <= 0) {
      return 0;
    }

    return (paidAmount / totalAmount).clamp(0, 1).toDouble();
  }

  bool get isPaid => pendingForSummary <= 0;

  bool get isPending => !isPaid;

  bool get isCompleted => pendingForSummary <= 0;

  bool get hasPartialPayment => paidForSummary > 0 && pendingForSummary > 0;

  bool get isPaidByOther => paidBy.trim().isNotEmpty && paidBy.trim() != 'Self';

  bool isOverdue(DateTime now) {
    if (dueDate == null || pendingForSummary <= 0) {
      return false;
    }

    return now.isAfter(
      DateTime(dueDate!.year, dueDate!.month, dueDate!.day, 23, 59, 59),
    );
  }

  String get status {
    if (isOverdue(DateTime.now())) {
      return _expenseStatusOverdue;
    }

    if (repaymentPending > 0) {
      return _expenseStatusNeedToRepay;
    }

    if (isPaidByOther) {
      return _expenseStatusPaidByOther;
    }

    return _deriveExpenseStatus(totalAmount, paidAmount);
  }

  ExpenseItem copyWith({
    String? id,
    String? name,
    String? category,
    String? notes,
    double? totalAmount,
    double? paidAmount,
    double? pendingAmount,
    String? paymentStatus,
    String? paidBy,
    String? paidByPersonId,
    String? paidByPersonName,
    String? repayPerson,
    double? repayAmount,
    DateTime? dueDate,
    bool clearDueDate = false,
    DateTime? createdDate,
    DateTime? updatedDate,
    bool? needsRepayment,
    bool? isRepaymentCompleted,
    List<PaymentSplit>? paymentSplit,
    String? sourceShoppingItemId,
    String? sourceReminderId,
  }) {
    return ExpenseItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paidBy: paidBy ?? this.paidBy,
      paidByPersonId: paidByPersonId ?? this.paidByPersonId,
      paidByPersonName: paidByPersonName ?? this.paidByPersonName,
      repayPerson: repayPerson ?? this.repayPerson,
      repayAmount: repayAmount ?? this.repayAmount,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      needsRepayment: needsRepayment ?? this.needsRepayment,
      isRepaymentCompleted: isRepaymentCompleted ?? this.isRepaymentCompleted,
      paymentSplit: paymentSplit ?? this.paymentSplit,
      sourceShoppingItemId: sourceShoppingItemId ?? this.sourceShoppingItemId,
      sourceReminderId: sourceReminderId ?? this.sourceReminderId,
    );
  }
}

class PaymentSplit {
  final double amount;
  final DateTime date;
  final String notes;
  final String paidBy;
  final String paidByPersonId;
  final String paidByPersonName;
  final String paymentStatus;
  final double pendingAmount;
  final double repayAmount;
  final String repayPerson;

  const PaymentSplit({
    this.amount = 0,
    required this.date,
    this.notes = '',
    this.paidBy = '',
    this.paidByPersonId = '',
    this.paidByPersonName = '',
    this.paymentStatus = '',
    this.pendingAmount = 0,
    this.repayAmount = 0,
    this.repayPerson = '',
  });

  factory PaymentSplit.fromJson(Map<String, dynamic> json) {
    return PaymentSplit(
      amount: _toDouble(json['amount']),
      date:
          _toDateTime(json['date']) ??
          _toDateTime(json['paidAt']) ??
          DateTime.now(),
      notes: json['notes']?.toString() ?? json['note']?.toString() ?? '',
      paidBy: json['paidBy']?.toString() ?? '',
      paidByPersonId: json['paidByPersonId']?.toString() ?? '',
      paidByPersonName:
          json['paidByPersonName']?.toString() ??
          json['paidByName']?.toString() ??
          json['paidBy']?.toString() ??
          '',
      paymentStatus:
          json['paymentStatus']?.toString() ?? _paymentSplitStatusPending,
      pendingAmount: _toDouble(json['pendingAmount']),
      repayAmount: _toDouble(json['repayAmount']),
      repayPerson: json['repayPerson']?.toString() ?? '',
    );
  }

  factory PaymentSplit.fromMap(Map<String, dynamic> map) {
    return PaymentSplit.fromJson(map);
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'date': date.toIso8601String(),
      'notes': notes,
      'paidBy': paidBy,
      'paidByPersonId': paidByPersonId,
      'paidByPersonName': paidByPersonName,
      'paymentStatus': paymentStatus,
      'pendingAmount': pendingAmount,
      'repayAmount': repayAmount,
      'repayPerson': repayPerson,
    };
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  String get displayPaidBy {
    final normalizedPersonName = paidByPersonName.trim();
    if (normalizedPersonName.isNotEmpty) {
      return normalizedPersonName;
    }

    final normalizedPaidBy = paidBy.trim();
    if (normalizedPaidBy.isNotEmpty) {
      return normalizedPaidBy;
    }

    return 'Self';
  }

  PaymentSplit copyWith({
    double? amount,
    DateTime? date,
    String? notes,
    String? paidBy,
    String? paidByPersonId,
    String? paidByPersonName,
    String? paymentStatus,
    double? pendingAmount,
    double? repayAmount,
    String? repayPerson,
  }) {
    return PaymentSplit(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      paidBy: paidBy ?? this.paidBy,
      paidByPersonId: paidByPersonId ?? this.paidByPersonId,
      paidByPersonName: paidByPersonName ?? this.paidByPersonName,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      pendingAmount: pendingAmount ?? this.pendingAmount,
      repayAmount: repayAmount ?? this.repayAmount,
      repayPerson: repayPerson ?? this.repayPerson,
    );
  }
}

const _expenseStatusPending = 'Pending';
const _expenseStatusPartiallyPaid = 'Partially Paid';
const _expenseStatusCompleted = 'Completed';
const _expenseStatusPaidByOther = 'Paid by Other';
const _expenseStatusNeedToRepay = 'Need to Repay';
const _expenseStatusOverdue = 'Overdue';
const _paymentSplitStatusPending = 'Pending';
final _emptyDate = DateTime.fromMillisecondsSinceEpoch(0);

double _toDouble(dynamic value) {
  return numberFromJson(value) ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  return dateFromJson(value);
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  return const {};
}

double _calculatePendingAmount(double totalAmount, double paidAmount) {
  final remaining = totalAmount - paidAmount;
  return remaining > 0 ? remaining : 0;
}

String _deriveExpenseStatus(double totalAmount, double paidAmount) {
  if (_calculatePendingAmount(totalAmount, paidAmount) <= 0) {
    return _expenseStatusCompleted;
  }

  if (paidAmount > 0) {
    return _expenseStatusPartiallyPaid;
  }

  return _expenseStatusPending;
}

String _newId() => newId();
