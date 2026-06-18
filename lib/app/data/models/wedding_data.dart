import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';

class WeddingData {
  const WeddingData({
    required this.expenses,
    required this.reminders,
    required this.purchases,
    this.budgetGoal = 0,
  });

  factory WeddingData.empty() =>
      const WeddingData(expenses: [], reminders: [], purchases: []);

  factory WeddingData.withDefaultExpenses() =>
      WeddingData(expenses: [], reminders: [], purchases: const []);

  factory WeddingData.fromJson(Map<String, dynamic> json) {
    return WeddingData(
      expenses: (json['expenses'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ExpenseItem.fromJson)
          .toList(),
      reminders: (json['reminders'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(EventReminder.fromJson)
          .toList(),
      purchases: (json['purchases'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PurchaseItem.fromJson)
          .toList(),
      budgetGoal: numberFromJson(json['budgetGoal']) ?? 0,
    );
  }

  final List<ExpenseItem> expenses;
  final List<EventReminder> reminders;
  final List<PurchaseItem> purchases;
  final double budgetGoal;

  double get totalBudget =>
      expenses.fold(0, (total, item) => total + item.knownTotal);

  bool get hasBudgetGoal => budgetGoal > 0;

  double get effectiveBudget => hasBudgetGoal ? budgetGoal : totalBudget;

  bool get isOverBudget => hasBudgetGoal && totalBudget > budgetGoal;

  double get overBudgetAmount => isOverBudget ? totalBudget - budgetGoal : 0;
  double get paid =>
      expenses.fold(0, (total, item) => total + item.paidForSummary);
  double get pending =>
      expenses.fold(0, (total, item) => total + item.pendingForSummary);
  double get repaymentPending =>
      expenses.fold(0, (total, item) => total + item.repaymentPending);
  int get completedExpenses =>
      expenses.where((item) => item.pendingForSummary == 0).length;
  int get pendingExpenses =>
      expenses.where((item) => item.pendingForSummary > 0).length;
  int get partiallyPaidExpenses => expenses
      .where(
        (item) => item.paidAmount > 0 && item.paidAmount < item.totalAmount,
      )
      .length;
  Map<String, double> get categoryTotals {
    final totals = <String, double>{};
    for (final item in expenses) {
      totals[item.category] = (totals[item.category] ?? 0) + item.totalAmount;
    }
    return totals;
  }

  int get openReminders => reminders.where((item) => !item.isDone).length;
  int get purchasedItems =>
      purchases.where((item) => item.status == 'Purchased').length;

  Map<String, dynamic> toJson() => {
    'expenses': expenses.map((item) => item.toJson()).toList(),
    'reminders': reminders.map((item) => item.toJson()).toList(),
    'purchases': purchases.map((item) => item.toJson()).toList(),
    'budgetGoal': budgetGoal,
  };

  WeddingData copyWith({
    List<ExpenseItem>? expenses,
    List<EventReminder>? reminders,
    List<PurchaseItem>? purchases,
    double? budgetGoal,
  }) => WeddingData(
    expenses: expenses ?? this.expenses,
    reminders: reminders ?? this.reminders,
    purchases: purchases ?? this.purchases,
    budgetGoal: budgetGoal ?? this.budgetGoal,
  );
}

class JulyWeddingDates {
  static final arikuth = DateTime(2026, 7, 5);
  static final sangeeth = DateTime(2026, 7, 15);
  static final malaji = DateTime(2026, 7, 16);
  static final ponnaniKalayanaThalan = DateTime(2026, 7, 17);
  static final koottandBrideToBe = DateTime(2026, 7, 17, 12);
  static final koottandDolkiNight = DateTime(2026, 7, 17, 19);
  static final ponnaniKalyanam = DateTime(2026, 7, 18);
  static final koottandNikkah = DateTime(2026, 7, 18, 10);
  static final koottandNoProgram = DateTime(2026, 7, 19);
  static final koottandMehendiNight = DateTime(2026, 7, 19, 19);
  static final koottandGroomMainEvent = DateTime(2026, 7, 20);
}
