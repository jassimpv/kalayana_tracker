import 'package:kalayanaexpresstracker/app/data/models/planning_entry.dart';
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
    this.planning = const [],
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
      planning: (json['planning'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PlanningEntry.fromJson)
          .toList(),
    );
  }

  final List<ExpenseItem> expenses;
  final List<EventReminder> reminders;
  final List<PurchaseItem> purchases;
  final double budgetGoal;
  final List<PlanningEntry> planning;

  List<PlanningEntry> entries(PlanningKind kind) =>
      planning.where((entry) => entry.kind == kind).toList();

  double get giftsReceived =>
      entries(PlanningKind.gift).fold(0, (sum, entry) => sum + entry.amount);
  double get contributionsReceived => entries(
    PlanningKind.contribution,
  ).fold(0, (sum, entry) => sum + entry.received);
  double get fundsReceived => giftsReceived + contributionsReceived;

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

  /// Validate shared planning invariants after transactional merges and restore.
  void validatePlanning() {
    final byId = <String, PlanningEntry>{};
    final categories = <String>{};
    final expenseIds = expenses.map((item) => item.id).toSet();
    for (final entry in planning) {
      if (entry.id.isEmpty ||
          byId.containsKey(entry.id) ||
          entry.name.trim().isEmpty ||
          entry.amountMinor < 0 ||
          entry.amountMinor > 999999999999 ||
          entry.receivedMinor < 0 ||
          entry.receivedMinor > entry.amountMinor) {
        throw const FormatException('Invalid or duplicate planning record.');
      }
      byId[entry.id] = entry;
      if ([
            PlanningKind.gift,
            PlanningKind.contribution,
            PlanningKind.repayment,
            PlanningKind.categoryBudget,
          ].contains(entry.kind) &&
          entry.amountMinor <= 0) {
        throw const FormatException(
          'Money records must have a positive amount.',
        );
      }
      if ([
            PlanningKind.gift,
            PlanningKind.contribution,
            PlanningKind.repayment,
          ].contains(entry.kind) &&
          entry.date == null) {
        throw const FormatException('Money records need a date.');
      }
      if (entry.kind == PlanningKind.categoryBudget &&
          !categories.add(entry.category)) {
        throw const FormatException('Each category can have only one budget.');
      }
    }
    for (final entry in planning) {
      if (entry.kind == PlanningKind.repayment &&
          !expenseIds.contains(entry.linkedId)) {
        throw const FormatException('Repayment expense no longer exists.');
      }
      if (entry.kind == PlanningKind.document) {
        final uri = Uri.tryParse(entry.url);
        if (uri == null ||
            uri.scheme != 'https' ||
            uri.host.isEmpty ||
            uri.userInfo.isNotEmpty ||
            (entry.linkedId.isNotEmpty &&
                !expenseIds.contains(entry.linkedId) &&
                byId[entry.linkedId]?.kind != PlanningKind.vendor)) {
          throw const FormatException('Invalid document or linked record.');
        }
      }
      if (entry.kind == PlanningKind.task) {
        bool cycle(String id, Set<String> path) {
          if (!path.add(id)) return true;
          final task = byId[id];
          if (task?.kind != PlanningKind.task) {
            throw const FormatException(
              'A prerequisite task no longer exists.',
            );
          }
          return task!.dependencies.any((next) => cycle(next, {...path}));
        }

        if (cycle(entry.id, {})) {
          throw const FormatException('Task dependencies cannot form a cycle.');
        }
        if (entry.status == 'Completed' &&
            entry.dependencies.any((id) => byId[id]?.status != 'Completed')) {
          throw const FormatException('Complete prerequisite tasks first.');
        }
      }
    }
    for (final expense in expenses) {
      if (expense.vendorId.isNotEmpty &&
          byId[expense.vendorId]?.kind != PlanningKind.vendor) {
        throw const FormatException('The linked vendor no longer exists.');
      }
      final repayments = planning
          .where(
            (entry) =>
                entry.kind == PlanningKind.repayment &&
                entry.linkedId == expense.id,
          )
          .toList();
      if (repayments.isNotEmpty) {
        final total =
            repayments.fold<int>(
              0,
              (value, entry) => value + entry.amountMinor,
            ) /
            100;
        if (!expense.needsRepayment ||
            total > expense.repaymentAmount + 0.001 ||
            (expense.repaymentPaidAmount - total).abs() > 0.001) {
          throw const FormatException(
            'Repayment history does not match the expense balance.',
          );
        }
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'expenses': expenses.map((item) => item.toJson()).toList(),
    'reminders': reminders.map((item) => item.toJson()).toList(),
    'purchases': purchases.map((item) => item.toJson()).toList(),
    'budgetGoal': budgetGoal,
    'planning': planning.map((entry) => entry.toJson()).toList(),
  };

  WeddingData copyWith({
    List<ExpenseItem>? expenses,
    List<EventReminder>? reminders,
    List<PurchaseItem>? purchases,
    double? budgetGoal,
    List<PlanningEntry>? planning,
  }) => WeddingData(
    expenses: expenses ?? this.expenses,
    reminders: reminders ?? this.reminders,
    purchases: purchases ?? this.purchases,
    budgetGoal: budgetGoal ?? this.budgetGoal,
    planning: planning ?? this.planning,
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
