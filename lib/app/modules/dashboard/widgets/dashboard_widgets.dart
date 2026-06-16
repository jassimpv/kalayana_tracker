import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';

const navDestinations = [
  NavItem(
    'Overview',
    CupertinoIcons.square_grid_2x2,
    CupertinoIcons.square_grid_2x2_fill,
  ),
  NavItem(
    'Expenses',
    CupertinoIcons.creditcard,
    CupertinoIcons.creditcard_fill,
  ),
  NavItem('Reminders', CupertinoIcons.calendar, CupertinoIcons.calendar),
  NavItem('Shopping', CupertinoIcons.bag, CupertinoIcons.bag_fill),
  NavItem('Profile', CupertinoIcons.person, CupertinoIcons.person_fill),
];

class NavItem {
  const NavItem(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class PageTitle extends StatelessWidget {
  const PageTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final heading = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading,
              if (action != null) ...[const SizedBox(height: 12), action!],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: heading),
            if (action != null) ...[const SizedBox(width: 12), action!],
          ],
        );
      },
    );
  }
}

class MetricData {
  const MetricData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({super.key, required this.metrics});

  final List<MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    final columns = responsiveGridCount(context, desktopCount: 4);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: metrics.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: columns == 1 ? 3.2 : 2.1,
      ),
      itemBuilder: (context, index) => _MetricTile(data: metrics[index]),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});
  final MetricData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(data.icon, color: data.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedPanel extends StatelessWidget {
  const ExpandedPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class ExpenseList extends GetView<DashboardController> {
  const ExpenseList({super.key, required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 780) {
          return Card(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Total'), numeric: true),
                  DataColumn(label: Text('Paid'), numeric: true),
                  DataColumn(label: Text('Pending'), numeric: true),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Paid by')),
                  DataColumn(label: Text('')),
                ],
                rows: expenses
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Text(
                                item.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(item.category)),
                          DataCell(Text(moneyOrDash(item.totalAmount))),
                          DataCell(Text(moneyOrDash(item.paidAmount))),
                          DataCell(Text(moneyOrDash(item.displayPending))),
                          DataCell(StatusPill(label: item.status)),
                          DataCell(Text(item.displayPaidBy)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: item.pendingForSummary == 0
                                      ? null
                                      : () => showAddExpensePaymentDialog(
                                          context,
                                          item: item,
                                        ),
                                  icon: const Icon(Icons.add_card_outlined),
                                  tooltip: 'Add payment',
                                ),
                                IconButton(
                                  onPressed: () =>
                                      showExpenseDialog(context, item: item),
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _confirmDeleteExpense(context, item),
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }
        return Column(
          children: expenses.map((item) => _ExpenseCard(item: item)).toList(),
        );
      },
    );
  }
}

class _ExpenseCard extends GetView<DashboardController> {
  const _ExpenseCard({required this.item});
  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          LabelPill(label: item.category),
                          StatusPill(label: item.status),
                          LabelPill(label: 'Paid by ${item.displayPaidBy}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      moneyOrDash(item.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due ${moneyOrDash(item.displayPending)}',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ExpenseMetric(
                    label: 'Paid',
                    value: moneyOrDash(item.paidAmount),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ExpenseMetric(
                    label: 'Pending',
                    value: moneyOrDash(item.displayPending),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseMetric extends StatelessWidget {
  const _ExpenseMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withAlpha((0.7 * 255).round()),
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class ReminderList extends GetView<DashboardController> {
  const ReminderList({
    super.key,
    required this.reminders,
    this.compact = false,
  });

  final List<EventReminder> reminders;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (reminders.isEmpty) {
      return const EmptyState(
        label: 'No reminders yet',
        icon: Icons.event_note_outlined,
      );
    }
    return Column(
      children: reminders.map((item) {
        final overdue = item.isOverdue(DateTime.now());
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            leading: Checkbox(
              value: item.isDone,
              onChanged: (_) => controller.toggleReminder(item),
            ),
            title: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: item.isDone ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Wrap(
              spacing: 8,
              children: [
                Text(formatDate(item.dueDate)),
                Text(item.category),
                if (overdue)
                  Text(
                    'Overdue',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            trailing: compact
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () =>
                            showReminderDialog(context, reminder: item),
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        onPressed: () => _confirmDeleteReminder(context, item),
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }
}

class PurchaseList extends GetView<DashboardController> {
  const PurchaseList({super.key, required this.purchases});

  final List<PurchaseItem> purchases;

  @override
  Widget build(BuildContext context) {
    final columns = responsiveGridCount(context, desktopCount: 3);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchases.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.25,
      ),
      itemBuilder: (context, index) {
        final item = purchases[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          showPurchaseDialog(context, purchase: item),
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      onPressed: () => _confirmDeletePurchase(context, item),
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusPill(label: item.status),
                    LabelPill(label: item.category),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _confirmDeleteExpense(
  BuildContext context,
  ExpenseItem item,
) async {
  final confirmed = await _confirmDeleteAction(
    context,
    title: 'Delete Expense',
    message: 'Delete ${item.name.isEmpty ? 'this expense' : item.name}?',
  );
  if (confirmed != true) return;
  await Get.find<DashboardController>().deleteExpense(item);
}

Future<void> _confirmDeleteReminder(
  BuildContext context,
  EventReminder item,
) async {
  final confirmed = await _confirmDeleteAction(
    context,
    title: 'Delete Reminder',
    message: 'Delete ${item.title.isEmpty ? 'this reminder' : item.title}?',
  );
  if (confirmed != true) return;
  await Get.find<DashboardController>().deleteReminder(item);
}

Future<void> _confirmDeletePurchase(
  BuildContext context,
  PurchaseItem item,
) async {
  final confirmed = await _confirmDeleteAction(
    context,
    title: 'Delete Purchase',
    message: 'Delete ${item.name.isEmpty ? 'this purchase' : item.name}?',
  );
  if (confirmed != true) return;
  await Get.find<DashboardController>().deletePurchase(item);
}

Future<bool?> _confirmDeleteAction(
  BuildContext context, {
  required String title,
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
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
}

class PendingPayments extends StatelessWidget {
  const PendingPayments({super.key, required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) return const EmptyState(label: 'No pending payments');
    return Column(
      children: expenses
          .take(6)
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${AppConfig.appCurrency} ${formatMoney(item.pendingForSummary)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}

class LabelPill extends StatelessWidget {
  const LabelPill({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.label,
    this.icon = Icons.inbox_outlined,
  });
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ThemeColors.whiteColor.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: ThemeColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 30, color: ThemeColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('completed') || normalized == 'purchased') {
    return const Color(0xFF0E766F);
  }
  if (normalized.contains('advance') || normalized == 'ordered') {
    return const Color(0xFF2563EB);
  }
  if (normalized.contains('pending') ||
      normalized.contains('planning') ||
      normalized == 'planned') {
    return const Color(0xFFB45309);
  }
  if (normalized.contains('cancelled')) return const Color(0xFFBE3455);
  return const Color(0xFF4F46E5);
}
