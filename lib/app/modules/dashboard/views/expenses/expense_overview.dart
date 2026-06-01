import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_history.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/routes/app_routes.dart';
import 'package:kalayanaexpresstracker/app/routes/dashboard_route_helpers.dart';

import '../../widgets/expense_widgets.dart';

class ExpenseDetailOverview extends GetView<DashboardController> {
  const ExpenseDetailOverview({super.key, required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final status = expenseShortStatus(item);
    final statusColor = expenseStatusColor(item);
    final paidBy = item.paidBy.trim().isEmpty ? 'Self' : item.paidBy.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseDetailSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.isEmpty ? 'Untitled expense' : item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatDate(item.createdDate),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ExpenseStatusBadge(label: status, color: statusColor),
                      if (item.dueDate != null) ...[
                        const SizedBox(height: 18),
                        Text(
                          formatDate(item.dueDate!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _ExpenseDetailAmountGrid(item: item),
              const SizedBox(height: 14),
              _ExpenseDetailInfoCard(
                title: 'Paid By',
                value: paidBy,
                secondaryTitle: 'Notes',
                secondaryValue: item.notes.trim().isEmpty
                    ? 'No notes added'
                    : item.notes.trim(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 58,
                child: FilledButton.icon(
                  onPressed: item.pendingForSummary == 0
                      ? null
                      : () => _openExpensePaymentHistory(context, item.id),
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Add Payment'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ExpenseDetailIconAction(
              icon: Icons.edit_rounded,
              tooltip: 'Edit',
              onPressed: () => showExpenseDialog(context, item: item),
            ),
            const SizedBox(width: 10),
            _ExpenseDetailIconAction(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete',
              onPressed: () async {
                await controller.deleteExpense(item);
                if (context.mounted) Navigator.of(context).maybePop();
              },
              destructive: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _ExpenseDetailAmountGrid extends StatelessWidget {
  const _ExpenseDetailAmountGrid({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ExpenseDetailAmount(
              label: 'Total',
              value: moneyOrDash(item.totalAmount),
            ),
          ),
          _ExpenseDetailDivider(),
          Expanded(
            child: _ExpenseDetailAmount(
              label: 'Paid',
              value: moneyOrDash(item.paidForSummary),
            ),
          ),
          _ExpenseDetailDivider(),
          Expanded(
            child: _ExpenseDetailAmount(
              label: 'Pending',
              value: moneyOrDash(item.pendingForSummary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDetailAmount extends StatelessWidget {
  const _ExpenseDetailAmount({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDetailDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 46,
      color: ThemeColors.logoGold.withValues(alpha: 0.14),
    );
  }
}

class _ExpenseDetailIconAction extends StatelessWidget {
  const _ExpenseDetailIconAction({
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
      width: 56,
      height: 58,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: destructive
              ? const Color(0xFFFFE9DF)
              : const Color(0xFFFFEED7),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(18),
            child: Icon(icon, color: color),
          ),
        ),
      ),
    );
  }
}

class _ExpenseDetailInfoCard extends StatelessWidget {
  const _ExpenseDetailInfoCard({
    required this.title,
    required this.value,
    required this.secondaryTitle,
    required this.secondaryValue,
  });

  final String title;
  final String value;
  final String secondaryTitle;
  final String secondaryValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ExpenseDetailInfoText(label: title, value: value),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: ThemeColors.logoGold.withValues(alpha: 0.16),
            ),
          ),
          _ExpenseDetailInfoText(label: secondaryTitle, value: secondaryValue),
        ],
      ),
    );
  }
}

class _ExpenseDetailInfoText extends StatelessWidget {
  const _ExpenseDetailInfoText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          style: TextStyle(
            color: ThemeColors.logoDeep,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

void _openExpensePaymentHistory(BuildContext context, String expenseId) {
  Navigator.of(context).push(
    buildNestedDashboardRoute(
      settings: RouteSettings(
        name: AppRoutes.dashboardExpensePaymentHistory,
        arguments: expenseId,
      ),
      child: ExpensePaymentHistoryPage(expenseId: expenseId),
      transitionDuration: const Duration(milliseconds: 320),
      startOffset: const Offset(0.08, 0),
    ),
  );
}
