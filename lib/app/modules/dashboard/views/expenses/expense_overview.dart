import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';

import '../../widgets/expense_widgets.dart';

class ExpenseDetailOverview extends GetView<DashboardController> {
  const ExpenseDetailOverview({super.key, required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final status = item.repaymentPending > 0
        ? expenseStatusNeedToRepay
        : expenseShortStatus(item);
    final statusColor = item.repaymentPending > 0
        ? const Color(0xFF4422D8)
        : expenseStatusColor(item);
    final paidBy = item.displayPaidBy;
    final notes = item.notes.trim().isEmpty
        ? 'No notes added'
        : item.notes.trim();
    final dueDate = item.dueDate == null
        ? 'No due date'
        : formatDate(item.dueDate!);
    final repayPerson = item.repayPerson.trim().isEmpty
        ? paidBy
        : item.repayPerson.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseDetailSurface(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _expenseDetailCategoryIcon(item.category),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
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
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item.category} | Created ${formatDate(item.createdDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ExpenseStatusBadge(label: status, color: statusColor),
                ],
              ),
              const SizedBox(height: 12),
              _ExpenseDetailAmountGrid(item: item),
              const SizedBox(height: 10),
              _ExpenseProgressSummary(item: item),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (item.needsRepayment || item.repayAmount > 0) ...[
          _ExpenseRepaymentPanel(item: item, repayPerson: repayPerson),
          const SizedBox(height: 8),
        ],
        _ExpenseDetailMetadataGrid(
          category: item.category,
          paidBy: paidBy,
          dueDate: dueDate,
          payments:
              '${item.paymentSplit.length} payment${item.paymentSplit.length == 1 ? '' : 's'}',
        ),
        const SizedBox(height: 8),
        _ExpenseDetailInfoCard(title: 'Notes', value: notes),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: item.pendingForSummary == 0
                      ? null
                      : () => controller.openExpensePaymentAdd(item.id),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.add_card_rounded, size: 20),
                  label: const Text('Add Payment'),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ExpenseDetailIconAction(
              icon: Icons.history_rounded,
              tooltip: 'Payment history',
              onPressed: () => controller.openExpensePaymentHistory(item.id),
            ),
            const SizedBox(width: 8),
            _ExpenseDetailIconAction(
              icon: Icons.edit_rounded,
              tooltip: 'Edit',
              onPressed: () => showExpenseDialog(context, item: item),
            ),
            const SizedBox(width: 8),
            _ExpenseDetailIconAction(
              icon: Icons.delete_outline_rounded,
              tooltip: 'Delete',
              onPressed: () async {
                await controller.deleteExpense(item);
                controller.closeDashboardSubPage();
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
      padding: const EdgeInsets.symmetric(vertical: 10),
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

class _ExpenseProgressSummary extends StatelessWidget {
  const _ExpenseProgressSummary({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final progress = item.totalAmount == 0
        ? 0.0
        : (item.paidForSummary / item.totalAmount).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: progress,
            backgroundColor: const Color(0xFFFFEFD7),
            color: ThemeColors.primary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                '${(progress * 100).round()}% paid',
                style: const TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${moneyOrDash(item.pendingForSummary)} remaining',
              style: const TextStyle(
                color: Color(0xFFD18A00),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
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
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 17,
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
      height: 38,
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
      width: 48,
      height: 48,
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
            child: Icon(icon, color: color, size: 21),
          ),
        ),
      ),
    );
  }
}

class _ExpenseRepaymentPanel extends GetView<DashboardController> {
  const _ExpenseRepaymentPanel({required this.item, required this.repayPerson});

  final ExpenseItem item;
  final String repayPerson;

  @override
  Widget build(BuildContext context) {
    final completed = item.isRepaymentCompleted || item.repaymentPending == 0;
    return ExpenseDetailSurface(
      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: completed
                  ? ThemeColors.completedColor
                  : const Color(0xFF4422D8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              completed ? Icons.check_rounded : Icons.assignment_return_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  completed ? 'Repayment completed' : 'Repayment needed',
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  completed
                      ? '${moneyOrDash(item.repayAmount)} settled'
                      : '${moneyOrDash(item.repayAmount)} to $repayPerson',
                  maxLines: 1,
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
          if (!completed)
            TextButton.icon(
              onPressed: () => controller.markRepaymentCompleted(item),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text('Done'),
            ),
        ],
      ),
    );
  }
}

class _ExpenseDetailMetadataGrid extends StatelessWidget {
  const _ExpenseDetailMetadataGrid({
    required this.category,
    required this.paidBy,
    required this.dueDate,
    required this.payments,
  });

  final String category;
  final String paidBy;
  final String dueDate;
  final String payments;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.1,
      children: [
        _ExpenseDetailMetaTile(
          icon: Icons.category_rounded,
          label: 'Category',
          value: category,
        ),
        _ExpenseDetailMetaTile(
          icon: Icons.account_circle_rounded,
          label: 'Paid by',
          value: paidBy,
        ),
        _ExpenseDetailMetaTile(
          icon: Icons.event_rounded,
          label: 'Due date',
          value: dueDate,
        ),
        _ExpenseDetailMetaTile(
          icon: Icons.credit_card_rounded,
          label: 'Payments',
          value: payments,
        ),
      ],
    );
  }
}

class _ExpenseDetailMetaTile extends StatelessWidget {
  const _ExpenseDetailMetaTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ExpenseDetailSurface(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.primary, size: 18),
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
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _ExpenseDetailInfoCard extends StatelessWidget {
  const _ExpenseDetailInfoCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_ExpenseDetailInfoText(label: title, value: value)],
      ),
    );
  }
}

IconData _expenseDetailCategoryIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('invite')) return Icons.mail_rounded;
  if (normalized.contains('photo')) return Icons.camera_alt_rounded;
  if (normalized.contains('food')) return Icons.restaurant_rounded;
  if (normalized.contains('decor')) return Icons.celebration_rounded;
  if (normalized.contains('jewel')) return Icons.diamond_rounded;
  if (normalized.contains('travel')) return Icons.flight_rounded;
  if (normalized.contains('venue')) return Icons.storefront_rounded;
  return Icons.receipt_long_rounded;
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
