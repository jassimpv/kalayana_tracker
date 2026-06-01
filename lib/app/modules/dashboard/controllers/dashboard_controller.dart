import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/data/repositories/wedding_repository.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';

const expenseStatuses = [
  expenseStatusPending,
  expenseStatusPartiallyPaid,
  expenseStatusCompleted,
  expenseStatusPaidByOther,
  expenseStatusNeedToRepay,
  expenseStatusOverdue,
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

class DashboardController extends GetxController {
  DashboardController(this.repository);

  final WeddingRepository repository;
  final selectedIndex = 0.obs;
  final data = WeddingData.empty().obs;
  final loading = true.obs;
  final error = RxnString();
  final profile = <String, dynamic>{}.obs;
  final collaborators = <DashboardCollaborator>[].obs;
  final workspaceId = RxnString();
  final joinCode = RxnString();
  final collaborationLoading = false.obs;
  StreamSubscription<WeddingData>? _dataSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _workspaceSub;

  @override
  void onInit() {
    super.onInit();
    repository.seedIfEmpty();
    _bindStreams();
  }

  @override
  void onClose() {
    _dataSub?.cancel();
    _profileSub?.cancel();
    _workspaceSub?.cancel();
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

  Future<void> addExpensePayment(
    ExpenseItem item, {
    required double amount,
    required String paidBy,
    required DateTime date,
    String notes = '',
  }) async {
    if (amount <= 0) return;
    final normalizedAmount = amount.clamp(0, item.pendingForSummary).toDouble();
    if (normalizedAmount <= 0) return;
    final payment = PaymentSplit(
      amount: normalizedAmount,
      paidBy: paidBy.trim(),
      date: date,
      notes: notes.trim(),
    );
    await saveExpense(
      item.copyWith(
        paidAmount: (item.paidAmount + normalizedAmount)
            .clamp(0, item.totalAmount)
            .toDouble(),
        paymentSplit: [...item.paymentSplit, payment],
        updatedDate: DateTime.now(),
      ),
    );
  }

  Future<void> markExpenseCompleted(ExpenseItem item) async {
    final remaining = item.pendingForSummary;
    final payments = remaining > 0
        ? [
            ...item.paymentSplit,
            PaymentSplit(
              amount: remaining,
              date: DateTime.now(),
              paidBy: item.paidBy.trim().isEmpty ? 'Self' : item.paidBy.trim(),
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
    await saveExpense(
      item.copyWith(isRepaymentCompleted: true, updatedDate: DateTime.now()),
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

  Future<void> saveProfile({
    required String groom,
    required String bride,
    required DateTime? weddingDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final groomValue = groom.trim();
    final brideValue = bride.trim();
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'groomName': groomValue,
      'brideName': brideValue,
      'marriageDate': weddingDate?.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
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

    _dataSub = repository.watch().listen(
      (value) {
        data.value = value;
        loading.value = false;
      },
      onError: (Object exception) {
        error.value = exception.toString();
        loading.value = false;
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
          final nextWorkspaceId = profile['workspaceId']?.toString();
          if (nextWorkspaceId != null &&
              nextWorkspaceId.isNotEmpty &&
              nextWorkspaceId != workspaceId.value) {
            _bindWorkspace(nextWorkspaceId);
          }
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
  required String repayPerson,
  required bool needsRepayment,
  required String repayAmount,
  required DateTime? dueDate,
  required String notes,
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
  final paymentSplit = existing?.paymentSplit.isNotEmpty == true
      ? existing!.paymentSplit
      : paidAmount > 0
      ? [
          PaymentSplit(
            amount: paidAmount,
            date: now,
            paidBy: paidBy.trim().isEmpty ? 'Self' : paidBy.trim(),
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
    paidBy: paidBy.trim(),
    repayPerson: repayPerson.trim(),
    needsRepayment: needsRepayment,
    repayAmount: parsedRepayAmount ?? (needsRepayment ? paidAmount : 0),
    isRepaymentCompleted: existing?.isRepaymentCompleted ?? false,
    dueDate: dueDate,
    notes: notes.trim(),
    createdDate: existing?.createdDate ?? now,
    updatedDate: now,
    paymentSplit: paymentSplit,
  );
}

EventReminder buildReminder({
  EventReminder? existing,
  required String title,
  required String category,
  required DateTime dueDate,
}) {
  return EventReminder(
    id: existing?.id ?? newId(),
    title: title.trim(),
    category: category,
    dueDate: dueDate,
    isDone: existing?.isDone ?? false,
  );
}

PurchaseItem buildPurchase({
  PurchaseItem? existing,
  required String name,
  required String category,
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
    amount: existing?.amount ?? 0,
    status: status,
    note: note.trim(),
  );
}
