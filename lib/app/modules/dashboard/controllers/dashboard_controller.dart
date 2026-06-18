import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/currency_symbols.dart';
import 'package:kalayanaexpresstracker/app/core/services/notification_service.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/data/repositories/wedding_repository.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

const expenseStatusPending = 'Pending';
const expenseStatusPartiallyPaid = 'Partially Paid';
const expenseStatusCompleted = 'Completed';
const expenseStatusPaidByOther = 'Paid by Other';
const expenseStatusNeedToRepay = 'Need to Repay';
const expenseStatusOverdue = 'Overdue';
const paymentSplitStatusPending = 'Pending';
const paymentSplitStatusCompleted = 'Completed';
const paymentSplitStatusPaidByOther = 'Paid by Other';

const expenseStatuses = [
  expenseStatusPending,
  expenseStatusPartiallyPaid,
  expenseStatusCompleted,
  expenseStatusPaidByOther,
  expenseStatusNeedToRepay,
  expenseStatusOverdue,
];
const paymentSplitStatuses = [
  paymentSplitStatusPending,
  paymentSplitStatusCompleted,
  paymentSplitStatusPaidByOther,
];
const expenseCategories = [
  'General',
  'Loan',
  'Venue',
  'Photography',
  'Makeup',
  'Home Work',
  'Dress',
  'Invitation',
  'Travel',
  'Food',
  'Jewelry',
  'Decor',
  'Shopping',
];
const reminderCategories = ['Date', 'Payment', 'Invite', 'Vendor'];
const purchaseCategories = [
  'General',
  'Outfit',
  'Jewelry',
  'Gifts',
  'Decor',
  'Beauty',
  'Venue',
  'Food',
  'Travel',
  'Photography',
];
const purchaseStatuses = ['Planned', 'Ordered', 'Purchased', 'Cancelled'];

enum DashboardPageKind {
  tab,
  expenseAdd,
  reminderAdd,
  purchaseAdd,
  expenseDetail,
  expensePaymentAdd,
  expensePaymentHistory,
  repayPersons,
  reports,
  collaborators,
}

class DashboardController extends GetxController {
  DashboardController(this.repository);

  final WeddingRepository repository;
  final selectedIndex = 0.obs;
  final dashboardPage = DashboardPageKind.tab.obs;
  final dashboardPageArgument = RxnString();
  DashboardPageKind? _previousDashboardPage;
  String? _previousDashboardPageArgument;
  final data = WeddingData.empty().obs;
  final loading = true.obs;
  final error = RxnString();
  final profile = <String, dynamic>{}.obs;
  final collaborators = <DashboardCollaborator>[].obs;
  final repayPersons = <RepayPerson>[].obs;
  final repayPersonsLoading = true.obs;
  final repayPersonsError = RxnString();
  final workspaceId = RxnString();
  final joinCode = RxnString();
  final collaborationLoading = false.obs;
  StreamSubscription<WeddingData>? _dataSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _workspaceSub;
  StreamSubscription<List<RepayPerson>>? _repayPersonsSub;

  bool get isDashboardSubPage => dashboardPage.value != DashboardPageKind.tab;

  void openDashboardTab(int index) {
    selectedIndex.value = index;
    dashboardPage.value = DashboardPageKind.tab;
    dashboardPageArgument.value = null;
    _previousDashboardPage = null;
    _previousDashboardPageArgument = null;
  }

  void openExpenseAdd() =>
      _openDashboardSubPage(DashboardPageKind.expenseAdd, selectedTab: 1);

  void openExpenseAddFromPurchase(String purchaseId) => _openDashboardSubPage(
    DashboardPageKind.expenseAdd,
    selectedTab: 1,
    argument: 'purchase:$purchaseId',
  );

  void openExpenseAddFromReminder(String reminderId) => _openDashboardSubPage(
    DashboardPageKind.expenseAdd,
    selectedTab: 1,
    argument: 'reminder:$reminderId',
  );

  void openReminderAdd() =>
      _openDashboardSubPage(DashboardPageKind.reminderAdd, selectedTab: 2);

  void openPurchaseAdd() =>
      _openDashboardSubPage(DashboardPageKind.purchaseAdd, selectedTab: 3);

  void openExpenseDetail(String expenseId) => _openDashboardSubPage(
    DashboardPageKind.expenseDetail,
    selectedTab: 1,
    argument: expenseId,
  );

  void openExpensePaymentAdd(String expenseId) => _openDashboardSubPage(
    DashboardPageKind.expensePaymentAdd,
    selectedTab: 1,
    argument: expenseId,
  );

  void openExpensePaymentHistory(String expenseId) => _openDashboardSubPage(
    DashboardPageKind.expensePaymentHistory,
    selectedTab: 1,
    argument: expenseId,
  );

  void openRepayPersons() =>
      _openDashboardSubPage(DashboardPageKind.repayPersons, selectedTab: 0);

  void openReports() =>
      _openDashboardSubPage(DashboardPageKind.reports, selectedTab: 4);

  void openCollaborators() =>
      _openDashboardSubPage(DashboardPageKind.collaborators, selectedTab: 4);

  void closeDashboardSubPage() {
    if (_previousDashboardPage != null) {
      dashboardPage.value = _previousDashboardPage!;
      dashboardPageArgument.value = _previousDashboardPageArgument;
      _previousDashboardPage = null;
      _previousDashboardPageArgument = null;
      return;
    }
    dashboardPage.value = DashboardPageKind.tab;
    dashboardPageArgument.value = null;
  }

  bool handleDashboardBack() {
    if (isDashboardSubPage) {
      closeDashboardSubPage();
      return false;
    }
    if (selectedIndex.value != 0) {
      openDashboardTab(0);
      return false;
    }
    return true;
  }

  void _openDashboardSubPage(
    DashboardPageKind page, {
    required int selectedTab,
    String? argument,
  }) {
    if (isDashboardSubPage) {
      _previousDashboardPage = dashboardPage.value;
      _previousDashboardPageArgument = dashboardPageArgument.value;
    } else {
      _previousDashboardPage = null;
      _previousDashboardPageArgument = null;
    }
    selectedIndex.value = selectedTab;
    dashboardPage.value = page;
    dashboardPageArgument.value = argument;
  }

  @override
  void onInit() {
    super.onInit();
    _initialize();
    NotificationService.instance.requestPermission();
  }

  Future<void> _initialize() async {
    final user = await _resolveCurrentUser();
    if (user == null) {
      Get.offAllNamed(AppRoutes.auth);
      return;
    }
    repository.seedIfEmpty();
    _bindStreams();
  }

  Future<User?> _resolveCurrentUser() async {
    final current = FirebaseAuth.instance.currentUser;
    if (current != null) return current;
    return FirebaseAuth.instance.authStateChanges().first;
  }

  bool get notificationsEnabled => profile['notificationsEnabled'] != false;

  Future<void> setNotificationsEnabled(bool enabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (enabled) await NotificationService.instance.requestPermission();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'notificationsEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await NotificationService.instance.syncSchedule(
      data.value,
      enabled: enabled,
    );
  }

  void _resyncNotifications() {
    NotificationService.instance.syncSchedule(
      data.value,
      enabled: notificationsEnabled,
    );
  }

  @override
  void onClose() {
    _dataSub?.cancel();
    _profileSub?.cancel();
    _workspaceSub?.cancel();
    _repayPersonsSub?.cancel();
    super.onClose();
  }

  Future<void> logout() => FirebaseAuth.instance.signOut().then(
    (_) => Get.offAllNamed(AppRoutes.auth),
  );

  Future<void> saveExpense(ExpenseItem item) async {
    final items = [...data.value.expenses];
    final index = items.indexWhere((entry) => entry.id == item.id);
    index == -1 ? items.add(item) : items[index] = item;
    await _save(data.value.copyWith(expenses: items));
  }

  Future<void> deleteExpense(ExpenseItem item) async {
    await _save(
      data.value.copyWith(
        expenses: data.value.expenses
            .where((entry) => entry.id != item.id)
            .toList(),
      ),
    );
  }

  Future<bool> addExpensePayment(
    ExpenseItem item, {
    required double amount,
    required String paidByPersonId,
    required String paidByPersonName,
    required DateTime date,
    String paymentStatus = paymentSplitStatusPending,
    String notes = '',
  }) async {
    if (amount <= 0) return false;
    final payerId = paidByPersonId.trim();
    final payerName = _paidByNameOrSelf(paidByPersonName);
    final normalizedAmount = amount.clamp(0, item.pendingForSummary).toDouble();
    if (normalizedAmount <= 0) return false;
    final payment = PaymentSplit(
      amount: normalizedAmount,
      paidBy: payerName,
      paidByPersonId: payerId,
      paidByPersonName: payerName,
      paymentStatus: _normalizePaymentSplitStatus(paymentStatus),
      date: date,
      notes: notes.trim(),
    );
    if (item.paymentSplit.any((entry) => _isSamePaymentSplit(entry, payment))) {
      _showDashboardSnack('Split', 'This payment split is already added.');
      return false;
    }
    await saveExpense(
      item.copyWith(
        paidAmount: (item.paidAmount + normalizedAmount)
            .clamp(0, item.totalAmount)
            .toDouble(),
        paymentSplit: [...item.paymentSplit, payment],
        updatedDate: DateTime.now(),
      ),
    );
    return true;
  }

  Future<void> deleteExpensePayment(ExpenseItem item, int paymentIndex) async {
    await deleteExpensePaymentGroup(item, [paymentIndex]);
  }

  Future<void> deleteExpensePaymentGroup(
    ExpenseItem item,
    List<int> paymentIndices,
  ) async {
    final indexSet = paymentIndices
        .where((index) => index >= 0 && index < item.paymentSplit.length)
        .toSet();
    if (indexSet.isEmpty) return;
    final payments = [...item.paymentSplit];
    final removedAmount = indexSet.fold<double>(
      0,
      (total, index) => total + item.paymentSplit[index].amount,
    );
    final sortedIndices = indexSet.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      payments.removeAt(index);
    }
    await saveExpense(
      item.copyWith(
        paidAmount: (item.paidAmount - removedAmount)
            .clamp(0, item.totalAmount)
            .toDouble(),
        paymentSplit: payments,
        updatedDate: DateTime.now(),
      ),
    );
  }

  Future<bool> updateExpensePaymentGroup(
    ExpenseItem item, {
    required List<int> paymentIndices,
    required double amount,
    required String paidByPersonId,
    required String paidByPersonName,
    required String paymentStatus,
    DateTime? date,
    String notes = '',
  }) async {
    final indexSet = paymentIndices
        .where((index) => index >= 0 && index < item.paymentSplit.length)
        .toSet();
    if (indexSet.isEmpty) return false;
    if (amount <= 0) {
      _showDashboardSnack('Split', 'Enter an amount above zero.');
      return false;
    }
    final payerId = paidByPersonId.trim();
    final payerName = _paidByNameOrSelf(paidByPersonName);
    final oldAmount = indexSet.fold<double>(
      0,
      (total, index) => total + item.paymentSplit[index].amount,
    );
    final nextPaidAmount = item.paidAmount - oldAmount + amount;
    if (nextPaidAmount > item.totalAmount) {
      _showDashboardSnack('Split', 'Paid amount cannot exceed total expense.');
      return false;
    }

    final payments = [...item.paymentSplit];
    final sortedIndices = indexSet.toList()..sort((a, b) => b.compareTo(a));
    for (final index in sortedIndices) {
      payments.removeAt(index);
    }
    final normalizedPaymentStatus = _normalizePaymentSplitStatus(paymentStatus);
    payments.add(
      PaymentSplit(
        amount: amount,
        date: date ?? DateTime.now(),
        paidBy: payerName,
        paidByPersonId: payerId,
        paidByPersonName: payerName,
        paymentStatus: normalizedPaymentStatus,
        notes: notes.trim().isEmpty ? 'Edited split' : notes.trim(),
      ),
    );
    final updatesRepaymentStatus =
        item.needsRepayment &&
        _isExpenseRepaymentPayer(item, payerId, payerName);
    await saveExpense(
      item.copyWith(
        paidAmount: nextPaidAmount.clamp(0, item.totalAmount).toDouble(),
        paymentSplit: payments,
        isRepaymentCompleted: updatesRepaymentStatus
            ? normalizedPaymentStatus == paymentSplitStatusCompleted
            : item.isRepaymentCompleted,
        updatedDate: DateTime.now(),
      ),
    );
    return true;
  }

  Future<void> markExpenseCompleted(ExpenseItem item) async {
    final remaining = item.pendingForSummary;
    final payments = remaining > 0
        ? [
            ...item.paymentSplit,
            PaymentSplit(
              amount: remaining,
              date: DateTime.now(),
              paidBy: item.displayPaidBy,
              paidByPersonId: item.paidByPersonId,
              paidByPersonName: item.paidByPersonName,
              paymentStatus: paymentSplitStatusCompleted,
              notes: 'Marked complete',
            ),
          ]
        : item.paymentSplit;
    await saveExpense(
      item.copyWith(
        paidAmount: item.totalAmount,
        paymentSplit: payments,
        updatedDate: DateTime.now(),
      ),
    );
  }

  Future<void> markExpensePaidByOther(
    ExpenseItem item, {
    required String paidBy,
    required bool needsRepayment,
    String repayPerson = '',
    double? repayAmount,
  }) async {
    await saveExpense(
      item.copyWith(
        paidBy: paidBy.trim(),
        needsRepayment: needsRepayment,
        repayPerson: repayPerson.trim().isEmpty
            ? paidBy.trim()
            : repayPerson.trim(),
        repayAmount: repayAmount ?? item.paidAmount,
        updatedDate: DateTime.now(),
      ),
    );
  }

  Future<void> markRepaymentCompleted(ExpenseItem item) async {
    final payments = item.paymentSplit
        .map(
          (payment) => _isExpenseRepaymentPayment(item, payment)
              ? payment.copyWith(paymentStatus: paymentSplitStatusCompleted)
              : payment,
        )
        .toList();
    await saveExpense(
      item.copyWith(
        isRepaymentCompleted: true,
        paymentSplit: payments,
        updatedDate: DateTime.now(),
      ),
    );
  }

  Future<bool> addRepayPerson(String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      _showDashboardSnack('Repay', 'Person name cannot be empty.');
      return false;
    }
    if (_hasDuplicateRepayPersonName(normalizedName)) {
      _showDashboardSnack('Repay', 'A person with this name already exists.');
      return false;
    }
    final now = DateTime.now();
    try {
      await repository.addRepayPerson(
        RepayPerson(
          id: newId(),
          name: normalizedName,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return true;
    } catch (exception) {
      _showDashboardSnack('Repay', exception.toString());
      return false;
    }
  }

  Future<bool> updateRepayPerson(RepayPerson person, String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      _showDashboardSnack('Repay', 'Person name cannot be empty.');
      return false;
    }
    if (_hasDuplicateRepayPersonName(normalizedName, exceptId: person.id)) {
      _showDashboardSnack('Repay', 'A person with this name already exists.');
      return false;
    }
    try {
      await repository.updateRepayPerson(
        person.copyWith(name: normalizedName, updatedAt: DateTime.now()),
      );
      return true;
    } catch (exception) {
      _showDashboardSnack('Repay', exception.toString());
      return false;
    }
  }

  Future<bool> deleteRepayPerson(RepayPerson person) async {
    if (isRepayPersonUsed(person.id, personName: person.name)) {
      _showDashboardSnack(
        'Repay',
        '${person.name} is already used in a payment or expense.',
      );
      return false;
    }
    try {
      await repository.deleteRepayPerson(person.id);
      return true;
    } catch (exception) {
      _showDashboardSnack('Repay', exception.toString());
      return false;
    }
  }

  bool isRepayPersonUsed(String personId, {String personName = ''}) {
    final normalizedId = personId.trim().toLowerCase();
    final normalizedName = personName.trim().toLowerCase();
    if (normalizedId.isEmpty && normalizedName.isEmpty) return false;

    bool matchesPerson({String id = '', String name = ''}) {
      final candidateId = id.trim().toLowerCase();
      if (normalizedId.isNotEmpty &&
          candidateId.isNotEmpty &&
          candidateId == normalizedId) {
        return true;
      }

      final candidateName = name.trim().toLowerCase();
      return normalizedName.isNotEmpty &&
          candidateName.isNotEmpty &&
          candidateName == normalizedName;
    }

    return data.value.expenses.any((expense) {
      if (matchesPerson(
        id: expense.paidByPersonId,
        name: expense.paidByPersonName,
      )) {
        return true;
      }
      if (matchesPerson(name: expense.paidBy)) return true;
      if (matchesPerson(name: expense.repayPerson)) return true;

      return expense.paymentSplit.any(
        (payment) =>
            matchesPerson(
              id: payment.paidByPersonId,
              name: payment.paidByPersonName,
            ) ||
            matchesPerson(name: payment.paidBy) ||
            matchesPerson(name: payment.repayPerson),
      );
    });
  }

  bool _hasDuplicateRepayPersonName(String name, {String? exceptId}) {
    final normalized = name.trim().toLowerCase();
    return repayPersons.any(
      (person) =>
          person.id != exceptId &&
          person.name.trim().toLowerCase() == normalized,
    );
  }

  List<ExpenseItem> filterExpenses({
    String? category,
    String? status,
    bool sortByPendingAmount = false,
    bool sortByDueDate = false,
  }) {
    final filtered = data.value.expenses.where((item) {
      final categoryMatches =
          category == null || category == 'All' || item.category == category;
      final statusMatches =
          status == null || status == 'All' || item.status == status;
      return categoryMatches && statusMatches;
    }).toList();
    if (sortByPendingAmount) {
      filtered.sort(
        (a, b) => b.pendingForSummary.compareTo(a.pendingForSummary),
      );
    } else if (sortByDueDate) {
      filtered.sort((a, b) {
        final aDate = a.dueDate ?? DateTime(9999);
        final bDate = b.dueDate ?? DateTime(9999);
        return aDate.compareTo(bDate);
      });
    }
    return filtered;
  }

  Future<void> saveReminder(EventReminder item) async {
    final items = [...data.value.reminders];
    final index = items.indexWhere((entry) => entry.id == item.id);
    index == -1 ? items.add(item) : items[index] = item;
    await _save(data.value.copyWith(reminders: items));
  }

  Future<void> linkReminderToExpense(
    String reminderId,
    String expenseId,
  ) async {
    final items = data.value.reminders
        .map(
          (entry) => entry.id == reminderId
              ? entry.copyWith(linkedExpenseId: expenseId)
              : entry,
        )
        .toList();
    await _save(data.value.copyWith(reminders: items));
  }

  Future<void> toggleReminder(EventReminder item) async {
    final items = data.value.reminders
        .map(
          (entry) => entry.id == item.id
              ? entry.copyWith(isDone: !entry.isDone)
              : entry,
        )
        .toList();
    await _save(data.value.copyWith(reminders: items));
  }

  Future<void> deleteReminder(EventReminder item) async {
    await _save(
      data.value.copyWith(
        reminders: data.value.reminders
            .where((entry) => entry.id != item.id)
            .toList(),
      ),
    );
  }

  Future<void> savePurchase(PurchaseItem item) async {
    final items = [...data.value.purchases];
    final index = items.indexWhere((entry) => entry.id == item.id);
    index == -1 ? items.add(item) : items[index] = item;
    await _save(data.value.copyWith(purchases: items));
  }

  Future<void> deletePurchase(PurchaseItem item) async {
    await _save(
      data.value.copyWith(
        purchases: data.value.purchases
            .where((entry) => entry.id != item.id)
            .toList(),
      ),
    );
  }

  Future<void> togglePurchase(PurchaseItem item) async {
    final purchased = item.status == 'Purchased';
    final items = data.value.purchases
        .map(
          (entry) => entry.id == item.id
              ? entry.copyWith(status: purchased ? 'Planned' : 'Purchased')
              : entry,
        )
        .toList();
    await _save(data.value.copyWith(purchases: items));
  }

  Future<void> linkPurchaseToExpense(
    String purchaseId,
    String expenseId,
  ) async {
    final items = data.value.purchases
        .map(
          (entry) => entry.id == purchaseId
              ? entry.copyWith(linkedExpenseId: expenseId)
              : entry,
        )
        .toList();
    await _save(data.value.copyWith(purchases: items));
  }

  Future<void> convertPurchaseToExpense({
    required PurchaseItem purchase,
    required ExpenseItem expense,
  }) async {
    await _save(
      data.value.copyWith(
        expenses: [...data.value.expenses, expense],
        purchases: data.value.purchases
            .where((entry) => entry.id != purchase.id)
            .toList(),
      ),
    );
  }

  Future<void> setBudgetGoal(double amount) async {
    await _save(data.value.copyWith(budgetGoal: amount));
  }

  Future<void> saveProfile({
    required String groom,
    required String bride,
    required DateTime? weddingDate,
    CurrencyOption? currency,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final groomValue = groom.trim();
    final brideValue = bride.trim();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'groomName': groomValue,
      'brideName': brideValue,
      'marriageDate': weddingDate?.toIso8601String(),
      if (currency != null) ...{
        'currencyCode': currency.code,
        'currencySymbol': currency.symbol,
      },
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (currency != null) CurrencySymbolApi.applyToAppConfig(currency);
    await _updateCurrentMember();
  }

  Future<void> joinWorkspace(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    final normalizedCode = _normalizeJoinCode(code);
    if (user == null || normalizedCode.isEmpty) return;

    collaborationLoading.value = true;
    try {
      final query = await FirebaseFirestore.instance
          .collection('weddingWorkspaces')
          .where('joinCode', isEqualTo: normalizedCode)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        _showDashboardSnack('Collaborators', 'Join code not found.');
        return;
      }
      final workspace = query.docs.first;
      await workspace.reference.set({
        'members': {user.uid: _currentMemberData(user, 'Member')},
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'workspaceId': workspace.id,
        'collaboratorRole': 'Member',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _showDashboardSnack('Collaborators', 'Workspace joined.');
      _bindStreams();
    } catch (exception) {
      _showDashboardSnack('Collaborators', exception.toString());
    } finally {
      collaborationLoading.value = false;
    }
  }

  Future<void> leaveWorkspace() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentWorkspaceId = workspaceId.value;
    if (user == null || currentWorkspaceId == null) return;

    collaborationLoading.value = true;
    try {
      await FirebaseFirestore.instance
          .collection('weddingWorkspaces')
          .doc(currentWorkspaceId)
          .set({
            'members': {user.uid: FieldValue.delete()},
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'workspaceId': user.uid,
        'collaboratorRole': 'Admin',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _showDashboardSnack('Collaborators', 'You left the shared workspace.');
      _bindStreams();
    } catch (exception) {
      _showDashboardSnack('Collaborators', exception.toString());
    } finally {
      collaborationLoading.value = false;
    }
  }

  Future<void> _save(WeddingData value) async {
    try {
      await repository.save(value);
    } catch (exception) {
      Get.snackbar(
        'Save failed',
        exception.toString(),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void _bindStreams() {
    _dataSub?.cancel();
    _profileSub?.cancel();
    _workspaceSub?.cancel();
    _repayPersonsSub?.cancel();

    _dataSub = repository.watch().listen(
      (value) {
        data.value = value;
        loading.value = false;
        _resyncNotifications();
      },
      onError: (Object exception) {
        error.value = exception.toString();
        loading.value = false;
      },
    );

    repayPersonsLoading.value = true;
    _repayPersonsSub = repository.getRepayPersons().listen(
      (value) {
        repayPersons.value = value;
        repayPersonsLoading.value = false;
        repayPersonsError.value = null;
      },
      onError: (Object exception) {
        repayPersonsError.value = exception.toString();
        repayPersonsLoading.value = false;
      },
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
          profile.value = snapshot.data() ?? {};
          CurrencySymbolApi.applyToAppConfig(profileCurrency(profile));
          final nextWorkspaceId = profile['workspaceId']?.toString();
          if (nextWorkspaceId != null &&
              nextWorkspaceId.isNotEmpty &&
              nextWorkspaceId != workspaceId.value) {
            _bindWorkspace(nextWorkspaceId);
          }
          _resyncNotifications();
        });
  }

  void _bindWorkspace(String nextWorkspaceId) {
    workspaceId.value = nextWorkspaceId;
    _workspaceSub?.cancel();
    _workspaceSub = FirebaseFirestore.instance
        .collection('weddingWorkspaces')
        .doc(nextWorkspaceId)
        .snapshots()
        .listen((snapshot) {
          final workspace = snapshot.data() ?? {};
          joinCode.value = workspace['joinCode']?.toString();
          final members = workspace['members'];
          if (members is Map<String, dynamic>) {
            collaborators.value =
                members.entries
                    .where((entry) => entry.value is Map<String, dynamic>)
                    .map((entry) {
                      final value = Map<String, dynamic>.from(
                        entry.value as Map<String, dynamic>,
                      );
                      return DashboardCollaborator.fromJson(entry.key, value);
                    })
                    .toList()
                  ..sort((a, b) {
                    if (a.uid == FirebaseAuth.instance.currentUser?.uid) {
                      return -1;
                    }
                    if (b.uid == FirebaseAuth.instance.currentUser?.uid) {
                      return 1;
                    }
                    return a.name.compareTo(b.name);
                  });
          } else {
            collaborators.clear();
          }
        });
  }

  Future<void> _updateCurrentMember() async {
    final user = FirebaseAuth.instance.currentUser;
    final currentWorkspaceId = workspaceId.value;
    if (user == null || currentWorkspaceId == null) return;
    final role = profile['collaboratorRole']?.toString() ?? 'Member';
    await FirebaseFirestore.instance
        .collection('weddingWorkspaces')
        .doc(currentWorkspaceId)
        .set({
          'members': {user.uid: _currentMemberData(user, role)},
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }
}

class DashboardCollaborator {
  const DashboardCollaborator({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.photoUrl,
  });

  factory DashboardCollaborator.fromJson(
    String uid,
    Map<String, dynamic> json,
  ) {
    return DashboardCollaborator(
      uid: uid,
      name: json['name']?.toString().trim().isNotEmpty == true
          ? json['name'].toString().trim()
          : 'Member',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'Member',
      photoUrl: json['photoUrl']?.toString(),
    );
  }

  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
}

Map<String, dynamic> _currentMemberData(User user, String role) {
  return {
    'uid': user.uid,
    'name': user.displayName ?? user.email?.split('@').first ?? 'Member',
    'email': user.email,
    'photoUrl': user.photoURL,
    'role': role,
    'joinedAt': FieldValue.serverTimestamp(),
  };
}

String _normalizeJoinCode(String code) {
  final compact = code.trim().toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
  if (compact.length < 8) return compact;
  return '${compact.substring(0, 4)}-${compact.substring(4, 8)}-${compact.substring(8).padRight(4, 'K').substring(0, 4)}';
}

bool _isSamePaymentSplit(PaymentSplit first, PaymentSplit second) {
  final firstDate = DateTime(first.date.year, first.date.month, first.date.day);
  final secondDate = DateTime(
    second.date.year,
    second.date.month,
    second.date.day,
  );
  return first.amount.toStringAsFixed(2) == second.amount.toStringAsFixed(2) &&
      firstDate == secondDate &&
      first.paidByPersonId.trim().toLowerCase() ==
          second.paidByPersonId.trim().toLowerCase() &&
      first.displayPaidBy.trim().toLowerCase() ==
          second.displayPaidBy.trim().toLowerCase() &&
      first.notes.trim().toLowerCase() == second.notes.trim().toLowerCase();
}

bool _isExpenseRepaymentPayment(ExpenseItem item, PaymentSplit payment) {
  return _isExpenseRepaymentPayer(
    item,
    payment.paidByPersonId,
    payment.displayPaidBy,
  );
}

bool _isExpenseRepaymentPayer(
  ExpenseItem item,
  String paidByPersonId,
  String paidByName,
) {
  final normalizedPaidByPersonId = paidByPersonId.trim().toLowerCase();
  final itemPaidByPersonId = item.paidByPersonId.trim().toLowerCase();
  if (normalizedPaidByPersonId.isNotEmpty &&
      itemPaidByPersonId.isNotEmpty &&
      normalizedPaidByPersonId == itemPaidByPersonId) {
    return true;
  }

  final normalizedPaidByName = paidByName.trim().toLowerCase();
  if (normalizedPaidByName.isEmpty) {
    return false;
  }

  final repayPerson = item.repayPerson.trim().toLowerCase();
  if (repayPerson.isNotEmpty && normalizedPaidByName == repayPerson) {
    return true;
  }

  final itemPaidByPersonName = item.paidByPersonName.trim().toLowerCase();
  if (itemPaidByPersonName.isNotEmpty &&
      normalizedPaidByName == itemPaidByPersonName) {
    return true;
  }

  final itemPaidBy = item.paidBy.trim().toLowerCase();
  return itemPaidBy.isNotEmpty && normalizedPaidByName == itemPaidBy;
}

String _normalizePaymentSplitStatus(String status) {
  final normalized = status.trim();
  return paymentSplitStatuses.contains(normalized)
      ? normalized
      : paymentSplitStatusPending;
}

String _paidByNameOrSelf(String name) {
  final normalized = name.trim();
  return normalized.isEmpty ? 'Self' : normalized;
}

void _showDashboardSnack(String title, String message) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );
}

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WeddingRepository>(
      () => FirestoreWeddingRepository(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      ),
    );
    Get.lazyPut(() => DashboardController(Get.find<WeddingRepository>()));
  }
}

ExpenseItem buildExpense({
  ExpenseItem? existing,
  required String name,
  required String category,
  required String total,
  required String paid,
  required String paidBy,
  required String paidByPersonId,
  required String paidByPersonName,
  required String repayPerson,
  required bool needsRepayment,
  required String repayAmount,
  required DateTime? dueDate,
  required String notes,
  String? sourceShoppingItemId,
  String? sourceReminderId,
}) {
  final now = DateTime.now();
  final totalAmount = moneyFromText(total) ?? 0;
  final paidAmount = (moneyFromText(paid) ?? 0)
      .clamp(0, totalAmount)
      .toDouble();
  final categoryValue = expenseCategories.contains(category.trim())
      ? category.trim()
      : expenseCategories.first;
  final parsedRepayAmount = moneyFromText(repayAmount);
  final payerName = _paidByNameOrSelf(
    paidByPersonName.trim().isEmpty ? paidBy : paidByPersonName,
  );
  final initialPaymentStatus =
      paidByPersonId.trim().isNotEmpty && needsRepayment
      ? paymentSplitStatusPaidByOther
      : paymentSplitStatusPending;
  final paymentSplit = existing?.paymentSplit.isNotEmpty == true
      ? existing!.paymentSplit
      : paidAmount > 0
      ? [
          PaymentSplit(
            amount: paidAmount,
            date: now,
            paidBy: payerName,
            paidByPersonId: paidByPersonId.trim(),
            paidByPersonName: payerName,
            paymentStatus: initialPaymentStatus,
            notes: 'Initial payment',
          ),
        ]
      : const <PaymentSplit>[];
  return ExpenseItem(
    id: existing?.id ?? newId(),
    name: name.trim(),
    category: categoryValue,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    pendingAmount: (totalAmount - paidAmount)
        .clamp(0, double.infinity)
        .toDouble(),
    paymentStatus: existing?.paymentStatus ?? expenseStatusPending,
    paidBy: '',
    paidByPersonId: '',
    paidByPersonName: '',
    repayPerson: repayPerson.trim(),
    needsRepayment: needsRepayment,
    repayAmount: parsedRepayAmount ?? (needsRepayment ? paidAmount : 0),
    isRepaymentCompleted: existing?.isRepaymentCompleted ?? false,
    dueDate: dueDate,
    notes: notes.trim(),
    createdDate: existing?.createdDate ?? now,
    updatedDate: now,
    paymentSplit: paymentSplit,
    sourceShoppingItemId:
        sourceShoppingItemId ?? existing?.sourceShoppingItemId ?? '',
    sourceReminderId: sourceReminderId ?? existing?.sourceReminderId ?? '',
  );
}

EventReminder buildReminder({
  EventReminder? existing,
  required String title,
  required String category,
  required DateTime dueDate,
  String? amount,
}) {
  return EventReminder(
    id: existing?.id ?? newId(),
    title: title.trim(),
    category: category,
    dueDate: dueDate,
    isDone: existing?.isDone ?? false,
    amount: amount == null
        ? existing?.amount ?? 0
        : moneyFromText(amount) ?? existing?.amount ?? 0,
    linkedExpenseId: existing?.linkedExpenseId ?? '',
  );
}

PurchaseItem buildPurchase({
  PurchaseItem? existing,
  required String name,
  required String category,
  String? amount,
  required String status,
  required String note,
}) {
  final categoryValue = purchaseCategories.contains(category.trim())
      ? category.trim()
      : purchaseCategories.first;
  return PurchaseItem(
    id: existing?.id ?? newId(),
    name: name.trim(),
    category: categoryValue,
    amount: amount == null
        ? existing?.amount ?? 0
        : moneyFromText(amount) ?? existing?.amount ?? 0,
    status: status,
    note: note.trim(),
  );
}
