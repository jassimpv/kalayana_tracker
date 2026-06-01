import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

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

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ThemeColors.scaffoldColor,
          borderRadius: const BorderRadius.only(
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
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                      child: _ExpensePaymentHistoryContent(item: item),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _ExpensePaymentHistoryContent extends StatelessWidget {
  const _ExpensePaymentHistoryContent({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final splits = _expensePaymentSplits(item);
    final totalToRepay = splits.fold<double>(
      0,
      (total, split) => total + split.toRepay,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseDetailSurface(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: _ExpensePaymentSummaryMetric(
                  label: 'Total Expense',
                  value: moneyOrDash(item.totalAmount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExpensePaymentSummaryMetric(
                  label: 'Pending',
                  value: moneyOrDash(item.pendingForSummary),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Split Between',
          style: TextStyle(
            color: ThemeColors.logoDeep,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 14),
        ExpenseDetailSurface(
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
                    split: entry.value,
                    showDivider: entry.key != splits.length - 1,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: item.pendingForSummary == 0
                        ? null
                        : () =>
                              showAddExpensePaymentDialog(context, item: item),
                    child: const Text('Add Split'),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ExpenseDetailSurface(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: _ExpensePaymentSummaryMetric(
                  label: 'Total Paid',
                  value: moneyOrDash(item.paidForSummary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ExpensePaymentSummaryMetric(
                  label: 'Total To Repay',
                  value: moneyOrDash(totalToRepay),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ),
        if (item.paymentSplit.isNotEmpty) ...[
          const SizedBox(height: 18),
          ExpenseDetailSurface(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Splits',
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ...([...item.paymentSplit]
                      ..sort((a, b) => b.date.compareTo(a.date)))
                    .map((payment) => _ExpensePaymentHistoryRow(payment)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ExpensePaymentSummaryMetric extends StatelessWidget {
  const _ExpensePaymentSummaryMetric({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            color: ThemeColors.logoDeep,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
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
              fontSize: 16,
              fontWeight: FontWeight.w900,
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
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseSplitPersonTile extends StatelessWidget {
  const _ExpenseSplitPersonTile({
    required this.split,
    required this.showDivider,
  });

  final _ExpensePaymentSplit split;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEED7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ThemeColors.logoGold.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: ThemeColors.logoDeep,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  split.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _ExpenseSplitAmount(label: 'Paid', value: split.paid),
              const SizedBox(width: 16),
              _ExpenseSplitAmount(
                label: 'To Repay',
                value: split.toRepay,
                emphasize: split.toRepay > 0,
              ),
            ],
          ),
          if (split.toRepay > 0) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ExpenseStatusBadge(
                label: 'Pending',
                color: const Color(0xFFFF9D2E),
              ),
            ),
          ],
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 58),
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

class _ExpenseSplitAmount extends StatelessWidget {
  const _ExpenseSplitAmount({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final double value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            moneyOrDash(value),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasize ? ThemeColors.primary : ThemeColors.logoDeep,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpensePaymentHistoryRow extends StatelessWidget {
  const _ExpensePaymentHistoryRow(this.payment);

  final PaymentSplit payment;

  @override
  Widget build(BuildContext context) {
    final payer = payment.paidBy.trim().isEmpty
        ? 'Self'
        : payment.paidBy.trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SoftIcon(icon: Icons.payments_rounded, color: ThemeColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$payer paid ${moneyOrDash(payment.amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  payment.notes.trim().isEmpty
                      ? formatDate(payment.date)
                      : '${formatDate(payment.date)} • ${payment.notes.trim()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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

class _ExpensePaymentSplit {
  const _ExpensePaymentSplit({
    required this.name,
    required this.paid,
    required this.toRepay,
  });

  final String name;
  final double paid;
  final double toRepay;
}

List<_ExpensePaymentSplit> _expensePaymentSplits(ExpenseItem item) {
  final paidByPerson = <String, double>{};
  for (final payment in item.paymentSplit) {
    final name = payment.paidBy.trim().isEmpty ? 'Self' : payment.paidBy.trim();
    paidByPerson[name] = (paidByPerson[name] ?? 0) + payment.amount;
  }

  final names = paidByPerson.keys.toList();
  if (names.isEmpty) return const [];

  final share = item.totalAmount / names.length;
  final splits =
      names.map((name) {
        final paid = paidByPerson[name] ?? 0;
        return _ExpensePaymentSplit(
          name: name,
          paid: paid,
          toRepay: math.max(0, share - paid).toDouble(),
        );
      }).toList()..sort((a, b) {
        if (a.toRepay != b.toRepay) return b.toRepay.compareTo(a.toRepay);
        return b.paid.compareTo(a.paid);
      });

  return splits;
}
