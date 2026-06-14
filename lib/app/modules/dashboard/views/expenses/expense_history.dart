import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/repay_person_picker.dart';

import '../../../../core/theme/app_theme.dart';
import '../../controllers/dashboard_controller.dart';

class ExpensePaymentHistoryPage extends GetView<DashboardController> {
  const ExpensePaymentHistoryPage({super.key, required this.expenseId});

  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.data.value.expenses.firstWhereOrNull(
        (entry) => entry.id == expenseId,
      );

      return Scaffold(
        backgroundColor: ThemeColors.primary,
        body: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF8ED), Color(0xFFFFFCF7)],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: item == null
                    ? const SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 120),
                        child: PremiumEmptyState(
                          icon: Icons.account_balance_wallet_rounded,
                          title: 'Payment not found',
                          subtitle: 'This expense may have been deleted.',
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
                        child: _ExpensePaymentHistoryContent(item: item),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ExpensePaymentHistoryContent extends StatefulWidget {
  const _ExpensePaymentHistoryContent({required this.item});

  final ExpenseItem item;

  @override
  State<_ExpensePaymentHistoryContent> createState() =>
      _ExpensePaymentHistoryContentState();
}

class _ExpensePaymentHistoryContentState
    extends State<_ExpensePaymentHistoryContent> {
  String _paidByFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final uniquePayments = _uniquePaymentEntries(item.paymentSplit);
    final splits = _expensePaymentSplits(item, uniquePayments);
    final sortedPayments = [...uniquePayments]
      ..sort((a, b) => b.value.date.compareTo(a.value.date));
    final paidByOptions = [
      'All',
      ...{for (final entry in sortedPayments) entry.value.displayPaidBy},
    ];
    if (!paidByOptions.contains(_paidByFilter)) {
      _paidByFilter = 'All';
    }
    final filteredPayments = _paidByFilter == 'All'
        ? sortedPayments
        : sortedPayments
              .where((entry) => entry.value.displayPaidBy == _paidByFilter)
              .toList();
    final totalToRepay = splits.fold<double>(
      0,
      (total, split) => total + split.toRepay,
    );
    final totalPaid = uniquePayments.fold<double>(
      0,
      (total, entry) => total + entry.value.amount,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PaymentHistoryTopCard(
          totalAmount: item.totalAmount,
          pendingAmount: math.max(0, item.totalAmount - totalPaid).toDouble(),
        ),
        const SizedBox(height: 24),
        const _ExpenseHistorySectionTitle(title: 'Split Between'),
        const SizedBox(height: 14),
        _PaymentHistoryCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (splits.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                  child: _ExpenseNoSplitState(item: item),
                )
              else
                ...splits.asMap().entries.map(
                  (entry) => _ExpenseSplitPersonTile(
                    item: item,
                    split: entry.value,
                    showDivider: entry.key != splits.length - 1,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: item.pendingForSummary == 0
                        ? null
                        : () => Get.find<DashboardController>()
                              .openExpensePaymentAdd(item.id),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFA0123F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text(
                      'Add Split',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _PaymentTotalsCard(totalPaid: totalPaid, totalToRepay: totalToRepay),
        if (item.paymentSplit.isNotEmpty) ...[
          const SizedBox(height: 18),
          _PaymentHistoryCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Recent Splits',
                      style: TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'View All',
                      style: TextStyle(
                        color: ThemeColors.secondaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: ThemeColors.secondaryColor,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (paidByOptions.length > 2) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF7),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: ThemeColors.logoGold.withValues(alpha: 0.16),
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: _paidByFilter,
                      decoration: const InputDecoration(
                        labelText: 'Filter by Paid By',
                        prefixIcon: Icon(Icons.filter_list_rounded),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      items: paidByOptions
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _paidByFilter = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (filteredPayments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'No payments match this person.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  ...filteredPayments.map(
                    (entry) => _ExpensePaymentHistoryRow(
                      item: item,
                      payment: entry.value,
                      paymentIndex: entry.key,
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        const _SecurePaymentNote(),
      ],
    );
  }
}

class _PaymentHistoryCard extends StatelessWidget {
  const _PaymentHistoryCard({required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentHistoryTopCard extends StatelessWidget {
  const _PaymentHistoryTopCard({
    required this.totalAmount,
    required this.pendingAmount,
  });

  final double totalAmount;
  final double pendingAmount;

  @override
  Widget build(BuildContext context) {
    return _PaymentHistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: _PaymentLargeMetric(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: ThemeColors.primary,
              iconBackground: const Color(0xFFFFEAF1),
              label: 'Total Expense',
              value: moneyOrDash(totalAmount),
            ),
          ),
          Container(
            width: 1,
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: ThemeColors.logoGold.withValues(alpha: 0.34),
          ),
          Expanded(
            child: _PaymentLargeMetric(
              icon: Icons.access_time_rounded,
              iconColor: const Color(0xFFC08021),
              iconBackground: const Color(0xFFFFF0DB),
              label: 'Pending Amount',
              value: moneyOrDash(pendingAmount),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentLargeMetric extends StatelessWidget {
  const _PaymentLargeMetric({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: iconBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 25),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeColors.logoDeep.withValues(alpha: 0.78),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseHistorySectionTitle extends StatelessWidget {
  const _ExpenseHistorySectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: ThemeColors.logoDeep,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          width: 88,
          height: 1,
          color: ThemeColors.logoGold.withValues(alpha: 0.54),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(
            Icons.auto_awesome,
            size: 16,
            color: ThemeColors.logoGold,
          ),
        ),
        Container(
          width: 38,
          height: 1,
          color: ThemeColors.logoGold.withValues(alpha: 0.54),
        ),
      ],
    );
  }
}

class _ExpenseNoSplitState extends StatelessWidget {
  const _ExpenseNoSplitState({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          SoftIcon(icon: Icons.group_add_rounded, color: ThemeColors.primary),
          const SizedBox(height: 10),
          Text(
            'No split added',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.pendingForSummary == 0
                ? 'This expense is fully paid.'
                : 'Add a split to track who paid and what is pending.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTotalsCard extends StatelessWidget {
  const _PaymentTotalsCard({
    required this.totalPaid,
    required this.totalToRepay,
  });

  final double totalPaid;
  final double totalToRepay;

  @override
  Widget build(BuildContext context) {
    return _PaymentHistoryCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: _PaymentLargeMetric(
              icon: Icons.check_circle_outline_rounded,
              iconColor: const Color(0xFF2F7A35),
              iconBackground: const Color(0xFFECFAE8),
              label: 'Total Paid',
              value: moneyOrDash(totalPaid),
            ),
          ),
          Container(
            width: 1,
            height: 58,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: ThemeColors.logoGold.withValues(alpha: 0.34),
          ),
          Expanded(
            child: _PaymentLargeMetric(
              icon: AppConfig.appCurrencyIcon,
              iconColor: ThemeColors.primary,
              iconBackground: const Color(0xFFFFEAF1),
              label: 'Total To Repay',
              value: moneyOrDash(totalToRepay),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurePaymentNote extends StatelessWidget {
  const _SecurePaymentNote();

  @override
  Widget build(BuildContext context) {
    return _PaymentHistoryCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0DB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: ThemeColors.secondaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'All your payments are secure and encrypted.\nWe keep your data safe.',
              style: TextStyle(
                color: ThemeColors.logoDeep.withValues(alpha: 0.82),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSplitPersonTile extends StatelessWidget {
  const _ExpenseSplitPersonTile({
    required this.item,
    required this.split,
    required this.showDivider,
  });

  final ExpenseItem item;
  final _ExpensePaymentSplit split;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final isCompleted = split.paymentStatus == paymentSplitStatusCompleted;
    final hasRepayment = split.toRepay > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? const Color(0xFFECFAE8)
                          : const Color(0xFFFFEAF1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ThemeColors.logoGold.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle_outline_rounded
                          : Icons.account_balance_wallet_rounded,
                      color: isCompleted
                          ? const Color(0xFF2F7A35)
                          : const Color(0xFFFF8A1F),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      split.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _ExpenseSplitIconAction(
                    icon: Icons.edit_rounded,
                    tooltip: 'Edit split',
                    onPressed: () => _showEditSplitGroupDialog(
                      context,
                      item: item,
                      split: split,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _ExpenseSplitIconAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete split',
                    destructive: true,
                    onPressed: () => _confirmDeleteSplitGroup(
                      context,
                      item: item,
                      split: split,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _ExpenseSplitAmountCard(
                      label: 'Amount paid',
                      value: moneyOrDash(split.paid),
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF2F7A35),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _ExpenseSplitAmountCard(
                      label: hasRepayment ? 'To repay' : 'Repayment',
                      value: hasRepayment
                          ? moneyOrDash(split.toRepay)
                          : 'Settled',
                      icon: hasRepayment
                          ? Icons.assignment_return_rounded
                          : Icons.verified_rounded,
                      color: hasRepayment
                          ? ThemeColors.primary
                          : const Color(0xFF2F7A35),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ExpenseSplitStatusPill(
            label: hasRepayment ? 'Repayment pending' : split.paymentStatus,
            completed: isCompleted,
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Divider(
                height: 1,
                color: ThemeColors.logoGold.withValues(alpha: 0.16),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _ExpenseSplitAmountCard extends StatelessWidget {
  const _ExpenseSplitAmountCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSplitIconAction extends StatelessWidget {
  const _ExpenseSplitIconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFB44A35) : ThemeColors.logoDeep;
    return SizedBox(
      width: 36,
      height: 36,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: destructive
              ? const Color(0xFFFFE9DF)
              : const Color(0xFFFFEED7),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _ExpenseSplitStatusPill extends StatelessWidget {
  const _ExpenseSplitStatusPill({required this.label, required this.completed});

  final String label;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final color = completed ? const Color(0xFF2F7A35) : const Color(0xFFFF8A1F);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ExpensePaymentHistoryRow extends StatelessWidget {
  const _ExpensePaymentHistoryRow({
    required this.item,
    required this.payment,
    required this.paymentIndex,
  });

  final ExpenseItem item;
  final PaymentSplit payment;
  final int paymentIndex;

  @override
  Widget build(BuildContext context) {
    final payer = payment.displayPaidBy;
    final paymentStatus = _paymentStatusForDisplay(item, payment);
    final isCompleted = paymentStatus == paymentSplitStatusCompleted;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEAF1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.account_balance_wallet_rounded,
              color: ThemeColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid By: $payer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  payment.notes.trim().isEmpty
                      ? 'Amount: ${moneyOrDash(payment.amount)} | Date: ${formatDate(payment.date)}'
                      : 'Amount: ${moneyOrDash(payment.amount)} | Date: ${formatDate(payment.date)} | ${payment.notes.trim()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.secondaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFECFAE8)
                      : const Color(0xFFFFF0DB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  paymentStatus,
                  style: TextStyle(
                    color: isCompleted
                        ? const Color(0xFF2F7A35)
                        : const Color(0xFFFF8A1F),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeletePaymentSplit(
                  context,
                  item: item,
                  paymentIndex: paymentIndex,
                  payment: payment,
                ),
                icon: Icon(
                  Icons.delete_outline_rounded,
                  color: ThemeColors.primary,
                ),
                tooltip: 'Delete split',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmDeletePaymentSplit(
  BuildContext context, {
  required ExpenseItem item,
  required int paymentIndex,
  required PaymentSplit payment,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Split'),
      content: Text(
        'Delete ${moneyOrDash(payment.amount)} paid by ${payment.displayPaidBy}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await Get.find<DashboardController>().deleteExpensePayment(
    item,
    paymentIndex,
  );
}

Future<void> _showEditSplitGroupDialog(
  BuildContext context, {
  required ExpenseItem item,
  required _ExpensePaymentSplit split,
}) async {
  final controller = Get.find<DashboardController>();
  final amountController = TextEditingController(text: moneyText(split.paid));
  final formKey = GlobalKey<FormState>();
  final initialPerson =
      controller.repayPersons.firstWhereOrNull(
        (person) => person.id == split.paidByPersonId,
      ) ??
      controller.repayPersons.firstWhereOrNull(
        (person) =>
            person.name.trim().toLowerCase() == split.name.toLowerCase(),
      );
  RepayPerson? selectedPerson = controller.repayPersons.firstWhereOrNull(
    (person) => person.id == split.paidByPersonId,
  );
  selectedPerson ??= initialPerson;
  var selectedStatus =
      _editablePaymentSplitStatuses.contains(split.paymentStatus)
      ? split.paymentStatus
      : paymentSplitStatusPending;
  var saving = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D8CC),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEAF1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          color: ThemeColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Split',
                              style: TextStyle(
                                color: ThemeColors.logoDeep,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              split.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: ThemeColors.logoDeep.withValues(
                                  alpha: 0.62,
                                ),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ThemeColors.logoGold.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Paid amount',
                            prefixIcon: Icon(AppConfig.appCurrencyIcon),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'This field is required';
                            }
                            final parsed = moneyFromText(value) ?? 0;
                            if (parsed <= 0) {
                              return 'Enter an amount above zero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        RepayPersonPicker(
                          selectedPersonId: selectedPerson?.id,
                          onChanged: (person) {
                            setState(() => selectedPerson = person);
                          },
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<String>(
                          initialValue: selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Payment status',
                            prefixIcon: Icon(Icons.fact_check_rounded),
                          ),
                          items: _editablePaymentSplitStatuses
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ),
                              )
                              .toList(),
                          onChanged: (status) {
                            if (status == null) return;
                            setState(() => selectedStatus = status);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: saving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setState(() => saving = true);
                                  final saved = await controller
                                      .updateExpensePaymentGroup(
                                        item,
                                        paymentIndices: split.paymentIndices,
                                        amount:
                                            moneyFromText(
                                              amountController.text,
                                            ) ??
                                            0,
                                        paidByPersonId:
                                            selectedPerson?.id ?? '',
                                        paidByPersonName:
                                            selectedPerson?.name ?? '',
                                        paymentStatus: selectedStatus,
                                      );
                                  if (context.mounted && saved) {
                                    Navigator.pop(context);
                                    return;
                                  }
                                  if (context.mounted) {
                                    setState(() => saving = false);
                                  }
                                },
                          icon: saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.done_rounded),
                          label: Text(saving ? 'Saving' : 'Done'),
                          style: FilledButton.styleFrom(
                            backgroundColor: ThemeColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  Future<void>.delayed(const Duration(milliseconds: 300), () {
    amountController.dispose();
  });
}

Future<void> _confirmDeleteSplitGroup(
  BuildContext context, {
  required ExpenseItem item,
  required _ExpensePaymentSplit split,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Split'),
      content: Text(
        'Delete all split payments by ${split.name} worth ${moneyOrDash(split.paid)}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await Get.find<DashboardController>().deleteExpensePaymentGroup(
    item,
    split.paymentIndices,
  );
}

class _ExpensePaymentSplit {
  const _ExpensePaymentSplit({
    required this.name,
    required this.paidByPersonId,
    required this.paymentStatus,
    required this.paid,
    required this.toRepay,
    required this.paymentIndices,
  });

  final String name;
  final String paidByPersonId;
  final String paymentStatus;
  final double paid;
  final double toRepay;
  final List<int> paymentIndices;
}

const _editablePaymentSplitStatuses = [
  paymentSplitStatusPending,
  paymentSplitStatusCompleted,
];

List<_ExpensePaymentSplit> _expensePaymentSplits(
  ExpenseItem item,
  List<MapEntry<int, PaymentSplit>> payments,
) {
  final paidByPerson = <String, double>{};
  final namesByKey = <String, String>{};
  final personIdsByKey = <String, String>{};
  final statusesByKey = <String, String>{};
  final indicesByKey = <String, List<int>>{};
  for (final entry in payments) {
    final payment = entry.value;
    final name = payment.displayPaidBy;
    final personId = payment.paidByPersonId.trim();
    final key = name.trim().toLowerCase();
    paidByPerson[key] = (paidByPerson[key] ?? 0) + payment.amount;
    namesByKey[key] = name;
    if (personId.isNotEmpty) {
      personIdsByKey[key] = personId;
    }
    final normalizedStatus =
        paymentSplitStatuses.contains(payment.paymentStatus)
        ? payment.paymentStatus
        : paymentSplitStatusPending;
    statusesByKey[key] = normalizedStatus == paymentSplitStatusCompleted
        ? paymentSplitStatusCompleted
        : statusesByKey[key] ?? normalizedStatus;
    indicesByKey.putIfAbsent(key, () => []).add(entry.key);
  }

  final names = paidByPerson.keys.toList();
  if (names.isEmpty) return const [];

  final share = item.totalAmount / names.length;
  final repaymentKey = _repaymentSplitKey(item);
  final splits =
      names.map((name) {
        final paid = paidByPerson[name] ?? 0;
        final isRepaymentPayer =
            repaymentKey.isNotEmpty && repaymentKey == name;
        final toRepay =
            item.needsRepayment &&
                !item.isRepaymentCompleted &&
                isRepaymentPayer
            ? item.repaymentAmount
            : math.max(0, share - paid).toDouble();
        final paymentStatus =
            isRepaymentPayer && item.needsRepayment && item.isRepaymentCompleted
            ? paymentSplitStatusCompleted
            : isRepaymentPayer && item.needsRepayment
            ? paymentSplitStatusPaidByOther
            : statusesByKey[name] ?? paymentSplitStatusPending;
        return _ExpensePaymentSplit(
          name: namesByKey[name] ?? name,
          paidByPersonId: personIdsByKey[name] ?? '',
          paymentStatus: paymentStatus,
          paid: paid,
          toRepay: toRepay,
          paymentIndices: indicesByKey[name] ?? const [],
        );
      }).toList()..sort((a, b) {
        if (a.toRepay != b.toRepay) return b.toRepay.compareTo(a.toRepay);
        return b.paid.compareTo(a.paid);
      });

  return splits;
}

String _repaymentSplitKey(ExpenseItem item) {
  final repayPerson = item.repayPerson.trim();
  if (repayPerson.isNotEmpty) {
    return repayPerson.toLowerCase();
  }

  final paidByPersonName = item.paidByPersonName.trim();
  if (paidByPersonName.isNotEmpty) {
    return paidByPersonName.toLowerCase();
  }

  final paidBy = item.paidBy.trim();
  if (paidBy.isNotEmpty) {
    return paidBy.toLowerCase();
  }

  return '';
}

String _paymentStatusForDisplay(ExpenseItem item, PaymentSplit payment) {
  final repaymentKey = _repaymentSplitKey(item);
  final paymentKey = payment.displayPaidBy.trim().toLowerCase();
  if (item.needsRepayment &&
      item.isRepaymentCompleted &&
      repaymentKey.isNotEmpty &&
      repaymentKey == paymentKey) {
    return paymentSplitStatusCompleted;
  }

  if (item.needsRepayment &&
      repaymentKey.isNotEmpty &&
      repaymentKey == paymentKey) {
    return paymentSplitStatusPaidByOther;
  }

  return paymentSplitStatuses.contains(payment.paymentStatus)
      ? payment.paymentStatus
      : paymentSplitStatusPending;
}

List<MapEntry<int, PaymentSplit>> _uniquePaymentEntries(
  List<PaymentSplit> payments,
) {
  final seen = <String>{};
  final entries = <MapEntry<int, PaymentSplit>>[];
  for (final entry in payments.asMap().entries) {
    final payment = entry.value;
    final key = _paymentEntryKey(payment);
    if (seen.add(key)) entries.add(entry);
  }
  return entries;
}

String _paymentEntryKey(PaymentSplit payment) {
  final date = DateTime(
    payment.date.year,
    payment.date.month,
    payment.date.day,
  );
  return [
    payment.amount.toStringAsFixed(2),
    date.toIso8601String(),
    payment.paidByPersonId.trim().toLowerCase(),
    payment.displayPaidBy.trim().toLowerCase(),
    payment.notes.trim().toLowerCase(),
  ].join('|');
}
