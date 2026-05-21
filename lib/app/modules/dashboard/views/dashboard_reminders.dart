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
    final pendingItems = sorted.where((item) => !item.isDone).toList();
    final next = pendingItems.isEmpty ? null : pendingItems.first;
    final completed = sorted.where((item) => item.isDone).length;
    final upcoming = sorted.length - completed;
    final overdue = sorted
        .where((item) => item.isOverdue(DateTime.now()))
        .length;
    final progress = sorted.isEmpty ? 0.0 : completed / sorted.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHero(
          eyebrow: 'Reminder timeline',
          title: next == null ? 'Wedding roadmap' : next.title,
          subtitle: next == null
              ? 'Build your ceremony schedule and vendor milestone calendar.'
              : '${formatDate(next.dueDate)} | ${next.category}',
          icon: Icons.event_note_rounded,
          actionLabel: 'Add date',
          onAction: () => showReminderDialog(context),
        ),
        const SizedBox(height: 18),
        _ReminderSummaryCard(
          total: sorted.length,
          completed: completed,
          upcoming: upcoming,
          progress: progress,
        ),
        const SizedBox(height: 18),
        _ReminderStatusStrip(
          total: sorted.length,
          upcoming: upcoming,
          completed: completed,
          overdue: overdue,
        ),
        const SizedBox(height: 18),

        sorted.isEmpty
            ? const _PremiumEmptyState(
                icon: Icons.event_available_rounded,
                title: 'No timeline moments yet',
                subtitle:
                    'Add rituals, bookings, and reminder dates to build a roadmap.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'Dates', action: 'Review'),
                  const SizedBox(height: 12),
                  ...sorted.map((item) => _DateMomentCard(item: item)),
                ],
              ),
      ],
    );
  }
}

class _ReminderSummaryCard extends StatelessWidget {
  const _ReminderSummaryCard({
    required this.total,
    required this.completed,
    required this.upcoming,
    required this.progress,
  });

  final int total;
  final int completed;
  final int upcoming;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Row(
        children: [
          _ProgressRing(
            progress: progress,
            color: const Color(0xFF0F8B7D),
            size: 104,
            stroke: 10,
            center: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$total dates',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'wedding roadmap',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _LegendRow(
                  color: const Color(0xFF0F8B7D),
                  label: 'Upcoming',
                  value: '$upcoming',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFD4A373),
                  label: 'Completed',
                  value: '$completed',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderStatusStrip extends StatelessWidget {
  const _ReminderStatusStrip({
    required this.total,
    required this.upcoming,
    required this.completed,
    required this.overdue,
  });

  final int total;
  final int upcoming;
  final int completed;
  final int overdue;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MiniExpenseMetric(
        icon: Icons.event_note_rounded,
        label: 'Dates',
        value: '$total',
        color: const Color(0xFF0F8B7D),
      ),
      _MiniExpenseMetric(
        icon: Icons.schedule_rounded,
        label: 'Upcoming',
        value: '$upcoming',
        color: const Color(0xFFD4A373),
      ),
      _MiniExpenseMetric(
        icon: Icons.task_alt_rounded,
        label: 'Done',
        value: '$completed',
        color: const Color(0xFF3A8F63),
      ),
      _MiniExpenseMetric(
        icon: Icons.warning_rounded,
        label: 'Overdue',
        value: '$overdue',
        color: const Color(0xFFE45D52),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 680 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.35 : 1.55,
          ),
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }
}

class _DateMomentCard extends GetView<DashboardController> {
  const _DateMomentCard({required this.item});

  final EventReminder item;

  @override
  Widget build(BuildContext context) {
    final color = item.isDone
        ? Theme.of(context).colorScheme.outline
        : _premiumStatusColor(item.category);
    final days = daysUntilDate(item.dueDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PremiumSurface(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _SoftIcon(icon: _eventIcon(item.category), color: color),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => showReminderDialog(context, reminder: item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isEmpty ? 'Untitled date' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusPill(
                          label: item.isDone ? 'Done' : _dateStatus(days),
                        ),
                        LabelPill(label: item.category),
                        LabelPill(label: formatDate(item.dueDate)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Checkbox(
              value: item.isDone,
              onChanged: (_) => controller.toggleReminder(item),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (value) {
                if (value == 'edit') {
                  showReminderDialog(context, reminder: item);
                } else if (value == 'delete') {
                  controller.deleteReminder(item);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit date')),
                PopupMenuItem(value: 'delete', child: Text('Delete date')),
              ],
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
