import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';

import '../../widgets/expense_widgets.dart';

class ExpenseDetailTimeline extends StatelessWidget {
  const ExpenseDetailTimeline({super.key, required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final payments = [...item.paymentSplit]
      ..sort((a, b) => a.date.compareTo(b.date));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpenseDetailSurface(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Timeline',
                style: TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              if (payments.isEmpty)
                _ExpenseTimelineRow(
                  markerColor: ThemeColors.logoGold,
                  date: 'Upcoming',
                  title: moneyOrDash(item.pendingForSummary),
                  subtitle: item.dueDate == null
                      ? 'No due date'
                      : 'Due on ${formatDate(item.dueDate!)}',
                  isLast: true,
                )
              else ...[
                ...payments.asMap().entries.map((entry) {
                  final payment = entry.value;
                  return _ExpenseTimelineRow(
                    markerColor: ThemeColors.logoGold,
                    date: formatDate(payment.date),
                    title: 'Paid ${moneyOrDash(payment.amount)}',
                    subtitle: 'Paid By: ${payment.displayPaidBy}',
                    isLast: false,
                  );
                }),
                if (item.pendingForSummary > 0)
                  _ExpenseTimelineRow(
                    markerColor: ThemeColors.logoGold,
                    date: 'Upcoming',
                    title: moneyOrDash(item.pendingForSummary),
                    subtitle: item.dueDate == null
                        ? 'Pending balance'
                        : 'Due on ${formatDate(item.dueDate!)}',
                    isLast: true,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpenseTimelineRow extends StatelessWidget {
  const _ExpenseTimelineRow({
    required this.markerColor,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  final Color markerColor;
  final String date;
  final String title;
  final String subtitle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: markerColor, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: markerColor.withValues(alpha: 0.32),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 92,
            child: Text(
              date,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ThemeColors.logoDeep,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
