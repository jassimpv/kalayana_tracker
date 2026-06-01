part of 'dashboard_view.dart';

class RemindersPanel extends GetView<DashboardController> {
  const RemindersPanel({super.key, required this.reminders});

  final List<EventReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final sorted = [...reminders]
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
    final paymentReminders = sorted
        .where((item) => item.category == 'Payment')
        .toList();
    final taskReminders = sorted
        .where((item) => item.category != 'Payment')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Upcoming Due Payments',
          action: 'Add',
          onTap: () => showReminderDialog(context),
        ),
        const SizedBox(height: 12),
        if (paymentReminders.isEmpty)
          const PremiumEmptyState(
            icon: Icons.payments_rounded,
            title: 'No due payments yet',
            subtitle: 'Create a payment reminder to track upcoming bills.',
          )
        else
          ...paymentReminders.map((item) => _PaymentReminderCard(item: item)),
        const SizedBox(height: 22),
        _SectionHeader(
          title: 'Wedding Tasks',
          action: 'Add',
          onTap: () => showReminderDialog(context),
        ),
        const SizedBox(height: 12),
        if (taskReminders.isEmpty)
          const PremiumEmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No wedding tasks yet',
            subtitle:
                'Add reminders for tasks, invites, and vendor follow-ups.',
          )
        else
          ...taskReminders.map((item) => _WeddingTaskCard(item: item)),
      ],
    );
  }
}

class _PaymentReminderCard extends GetView<DashboardController> {
  const _PaymentReminderCard({required this.item});

  final EventReminder item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PremiumSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: ThemeColors.logoGold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.currency_rupee_rounded,
                color: ThemeColors.logoGold,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.isEmpty ? 'Untitled payment' : item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Due on ${formatDate(item.dueDate)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w700,
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

class _WeddingTaskCard extends GetView<DashboardController> {
  const _WeddingTaskCard({required this.item});

  final EventReminder item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PremiumSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            InkWell(
              onTap: () => controller.toggleReminder(item),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: item.isDone
                        ? ThemeColors.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  color: item.isDone ? ThemeColors.primary : Colors.transparent,
                ),
                child: item.isDone
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () => showReminderDialog(context, reminder: item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? 'Untitled task' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isDone
                            ? Theme.of(context).colorScheme.outline
                            : ThemeColors.logoDeep,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${item.category} • ${_dateStatus(daysUntilDate(item.dueDate))}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateStatus(int? days) {
  if (days == null) return 'Scheduled';
  if (days < 0) return 'Overdue';
  if (days == 0) return 'Today';
  if (days == 1) return 'Tomorrow';
  return '$days days left';
}
