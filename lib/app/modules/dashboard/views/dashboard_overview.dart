part of 'dashboard_view.dart';

class OverviewPanel extends GetView<DashboardController> {
  const OverviewPanel({super.key, required this.data});

  final WeddingData data;

  @override
  Widget build(BuildContext context) {
    final upcoming = [...data.reminders]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final pendingExpenses = data.expenses
        .where((item) => item.pendingForSummary > 0)
        .toList();
    pendingExpenses.sort((a, b) {
      final aDate = a.dueDate;
      final bDate = b.dueDate;
      if (aDate != null && bDate != null) return aDate.compareTo(bDate);
      if (aDate != null) return -1;
      if (bDate != null) return 1;
      return b.pendingForSummary.compareTo(a.pendingForSummary);
    });
    return Obx(() {
      final profile = controller.profile;
      final date = profileMarriageDate(profile);
      final paymentProgress = data.totalBudget == 0
          ? 0.0
          : (data.paid / data.totalBudget).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OverviewHero(
            data: data,
            weddingDate: date,
            coupleName: _coupleName(profile),
          ),
          const SizedBox(height: 18),
          _PremiumQuickActions(
            onExpense: () => showExpenseDialog(context),
            onReminder: () => showReminderDialog(context),
            onPurchase: () => showPurchaseDialog(context),
          ),
          const SizedBox(height: 18),
          _BudgetAnalyticsCard(
            total: data.totalBudget,
            paid: data.paid,
            pending: data.pending,
            progress: paymentProgress,
          ),
          const SizedBox(height: 18),
          _TodayFocusCard(
            pendingExpenses: pendingExpenses,
            reminders: upcoming,
            repayment: data.repaymentPending,
          ),
          const SizedBox(height: 18),
          _UpcomingEventsCarousel(
            reminders: upcoming.take(5).toList(),
            onAdd: () => showReminderDialog(context),
            onEdit: (item) => showReminderDialog(context, reminder: item),
            onToggle: controller.toggleReminder,
          ),
          const SizedBox(height: 18),
          _PaymentTimeline(expenses: pendingExpenses.take(4).toList()),
        ],
      );
    });
  }
}

class _OverviewHero extends StatelessWidget {
  const _OverviewHero({
    required this.data,
    required this.weddingDate,
    required this.coupleName,
  });

  final WeddingData data;
  final DateTime? weddingDate;
  final String? coupleName;

  @override
  Widget build(BuildContext context) {
    final budgetProgress = data.totalBudget == 0
        ? 0.0
        : (data.paid / data.totalBudget).clamp(0.0, 1.0);
    final daysLeft = daysUntilDate(weddingDate);
    return _AnimatedReveal(
      child: _PremiumSurface(
        padding: EdgeInsets.zero,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F8B7D), Color(0xFF155F58), Color(0xFF241D18)],
        ),
        borderColor: Colors.white24,
        child: Stack(
          children: [
            const Positioned(
              right: -48,
              top: -42,
              child: _BlurCircle(color: Color(0xFFD4A373), size: 170),
            ),
            const Positioned(
              left: -70,
              bottom: -80,
              child: _BlurCircle(color: Colors.white, size: 190, alpha: 0.10),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final left = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CoupleAvatar(name: coupleName),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good evening',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  coupleName ?? 'Kalyana command suite',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        height: 1.02,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        weddingDate == null
                            ? 'Set the wedding date to unlock your emotional countdown.'
                            : '${formatDate(weddingDate!)}  |  ${daysLeft == null
                                  ? 'Date locked'
                                  : daysLeft <= 0
                                  ? 'Today is the day'
                                  : '$daysLeft days to forever'}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.78),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: data.totalBudget),
                        duration: const Duration(milliseconds: 820),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Text(
                          '₹${formatMoney(value)}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0,
                                height: 1,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total wedding budget under orchestration',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.68),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  );
                  final right = _HeroCountdownCard(
                    weddingDate: weddingDate,
                    progress: budgetProgress,
                  );
                  return wide
                      ? Row(
                          children: [
                            Expanded(child: left),
                            const SizedBox(width: 24),
                            SizedBox(width: 250, child: right),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [left, const SizedBox(height: 24), right],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumQuickActions extends StatelessWidget {
  const _PremiumQuickActions({
    required this.onExpense,
    required this.onReminder,
    required this.onPurchase,
  });

  final VoidCallback onExpense;
  final VoidCallback onReminder;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return _AnimatedReveal(
      delay: const Duration(milliseconds: 80),
      child: _PremiumSurface(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_card_rounded,
                label: 'Expense',
                onTap: onExpense,
              ),
            ),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_available_rounded,
                label: 'Date',
                onTap: onReminder,
              ),
            ),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.shopping_bag_rounded,
                label: 'Shop',
                onTap: onPurchase,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatefulWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 130),
        child: Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(widget.icon, color: scheme.primary),
            ),
            const SizedBox(height: 7),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetAnalyticsCard extends StatelessWidget {
  const _BudgetAnalyticsCard({
    required this.total,
    required this.paid,
    required this.pending,
    required this.progress,
  });

  final double total;
  final double paid;
  final double pending;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Budget analytics',
            action: '${(progress * 100).round()}% paid',
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _ProgressRing(
                progress: progress,
                color: scheme.primary,
                size: 108,
                stroke: 10,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'complete',
                      style: TextStyle(
                        color: scheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${formatMoney(total)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'wedding allocation',
                      style: TextStyle(
                        color: scheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _LegendRow(
                      color: scheme.primary,
                      label: 'Paid',
                      value: '₹${formatMoney(paid)}',
                    ),
                    const SizedBox(height: 8),
                    _LegendRow(
                      color: const Color(0xFFD4A373),
                      label: 'Pending',
                      value: '₹${formatMoney(pending)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayFocusCard extends StatelessWidget {
  const _TodayFocusCard({
    required this.pendingExpenses,
    required this.reminders,
    required this.repayment,
  });

  final List<ExpenseItem> pendingExpenses;
  final List<EventReminder> reminders;
  final double repayment;

  @override
  Widget build(BuildContext context) {
    final nextBill = pendingExpenses.isEmpty ? null : pendingExpenses.first;
    final nextReminder = reminders.isEmpty ? null : reminders.first;
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Today focus', action: 'Priority'),
          const SizedBox(height: 14),
          _FocusRow(
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFFD4A373),
            title: nextBill?.name ?? 'No bill due next',
            subtitle: nextBill == null
                ? 'Pending bills will appear here.'
                : '${moneyOrDash(nextBill.pendingForSummary)} pending${nextBill.dueDate == null ? '' : ' | Due ${formatDate(nextBill.dueDate!)}'}',
          ),
          const SizedBox(height: 10),
          _FocusRow(
            icon: Icons.event_available_rounded,
            color: const Color(0xFF0F8B7D),
            title: nextReminder?.title ?? 'No upcoming date',
            subtitle: nextReminder == null
                ? 'Add reminders to track next actions.'
                : '${nextReminder.category} | ${formatDate(nextReminder.dueDate)}',
          ),
          if (repayment > 0) ...[
            const SizedBox(height: 10),
            _FocusRow(
              icon: Icons.assignment_return_rounded,
              color: const Color(0xFFB85D75),
              title: 'Repayment pending',
              subtitle: '₹${formatMoney(repayment)} needs settlement',
            ),
          ],
        ],
      ),
    );
  }
}

class _FocusRow extends StatelessWidget {
  const _FocusRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _SoftIcon(icon: icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
        ],
      ),
    );
  }
}

class _UpcomingEventsCarousel extends StatelessWidget {
  const _UpcomingEventsCarousel({
    required this.reminders,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
  });

  final List<EventReminder> reminders;
  final VoidCallback onAdd;
  final ValueChanged<EventReminder> onEdit;
  final ValueChanged<EventReminder> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = reminders.isEmpty ? null : reminders.first;
    final remaining = reminders.skip(1).take(4).toList();
    return _PremiumSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Upcoming moments',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (next == null)
            Column(
              children: [
                const _PremiumEmptyState(
                  icon: Icons.event_note_rounded,
                  title: 'No dates on the horizon',
                  subtitle: 'Add rituals, fittings, and payment deadlines.',
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add first moment'),
                  ),
                ),
              ],
            )
          else ...[
            _NextMomentCard(
              item: next,
              onTap: () => onEdit(next),
              onToggle: () => onToggle(next),
            ),
            if (remaining.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...remaining.map(
                (item) => _UpcomingMomentRow(
                  item: item,
                  onTap: () => onEdit(item),
                  onToggle: () => onToggle(item),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _NextMomentCard extends StatelessWidget {
  const _NextMomentCard({
    required this.item,
    required this.onTap,
    required this.onToggle,
  });

  final EventReminder item;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = _premiumStatusColor(item.category);
    final days = daysUntilDate(item.dueDate);
    final doneColor = item.isDone
        ? Theme.of(context).colorScheme.outline
        : color;
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _SoftIcon(icon: _eventIcon(item.category), color: doneColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusPill(label: item.category),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formatDate(item.dueDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.isDone ? 'Done' : _momentDayLabel(days),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: doneColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.isDone ? 'completed' : _momentDaySuffix(days),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MomentCheckButton(
                    isDone: item.isDone,
                    onTap: onToggle,
                    color: doneColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpcomingMomentRow extends StatelessWidget {
  const _UpcomingMomentRow({
    required this.item,
    required this.onTap,
    required this.onToggle,
  });

  final EventReminder item;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final color = _premiumStatusColor(item.category);
    final days = daysUntilDate(item.dueDate);
    final effectiveColor = item.isDone
        ? Theme.of(context).colorScheme.outline
        : color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _eventIcon(item.category),
                    color: effectiveColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          decoration: item.isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${item.category}  |  ${formatDate(item.dueDate)}',
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
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.isDone ? 'Done' : _momentDayLabel(days),
                      style: TextStyle(
                        color: effectiveColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      item.isDone ? 'set' : _momentDaySuffix(days),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                _MomentCheckButton(
                  isDone: item.isDone,
                  onTap: onToggle,
                  color: effectiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MomentCheckButton extends StatelessWidget {
  const _MomentCheckButton({
    required this.isDone,
    required this.onTap,
    required this.color,
  });

  final bool isDone;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isDone ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.42)),
        ),
        child: Icon(
          isDone ? Icons.check_rounded : Icons.circle_outlined,
          color: color,
          size: 18,
        ),
      ),
    );
  }
}

String _momentDayLabel(int? days) {
  if (days == null) return '--';
  if (days < 0) return 'Past';
  if (days == 0) return 'Today';
  if (days == 1) return '1';
  return '$days';
}

String _momentDaySuffix(int? days) {
  if (days == null) return 'date';
  if (days < 0) return 'overdue';
  if (days == 0) return 'now';
  if (days == 1) return 'day left';
  return 'days left';
}

class _PaymentTimeline extends StatelessWidget {
  const _PaymentTimeline({required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    final items = expenses.take(5).toList();
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Payment timeline', action: 'Due next'),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const _PremiumEmptyState(
              icon: Icons.payments_rounded,
              title: 'All payments feel clear',
              subtitle: 'Pending balances will appear here.',
            )
          else
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              final color = entry.key.isEven
                  ? const Color(0xFF0F8B7D)
                  : const Color(0xFFD4A373);
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.28),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        if (entry.key != items.length - 1)
                          Container(
                            width: 2,
                            height: 38,
                            color: color.withValues(alpha: 0.16),
                          ),
                      ],
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.status,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${formatMoney(item.pendingForSummary)}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _CoupleCollaborationCard extends StatelessWidget {
  const _CoupleCollaborationCard({
    required this.coupleName,
    required this.done,
    required this.open,
  });

  final String? coupleName;
  final int done;
  final int open;

  @override
  Widget build(BuildContext context) {
    final progress = (done + open) == 0 ? 0.0 : done / (done + open);
    return _PremiumSurface(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCF8), Color(0xFFF5EBDF)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Couple collaboration', action: 'Synced'),
          const SizedBox(height: 16),
          Row(
            children: [
              _CoupleAvatar(name: coupleName),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  coupleName == null
                      ? 'Invite your partner into the planning rhythm.'
                      : '$coupleName are planning with shared clarity.',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 720),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: const Color(
                  0xFFD4A373,
                ).withValues(alpha: 0.16),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF0F8B7D),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$done completed moments | $open open decisions',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

IconData _eventIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('payment')) return Icons.payments_rounded;
  if (normalized.contains('invite')) return Icons.mail_rounded;
  if (normalized.contains('vendor')) return Icons.storefront_rounded;
  return Icons.event_rounded;
}

Color _premiumStatusColor(String status) {
  final normalized = status.toLowerCase();
  if (normalized.contains('completed') || normalized == 'purchased') {
    return const Color(0xFF0F8B7D);
  }
  if (normalized.contains('advance') || normalized == 'ordered') {
    return const Color(0xFF4E7DD1);
  }
  if (normalized.contains('pending') ||
      normalized.contains('planning') ||
      normalized == 'planned') {
    return const Color(0xFFD4A373);
  }
  if (normalized.contains('cancelled')) return const Color(0xFFB85D75);
  return const Color(0xFF6D6A75);
}

String _initials(String value) {
  final parts = value
      .replaceAll('&', ' ')
      .split(RegExp(r'\s+'))
      .where((part) => part.trim().isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'KW';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}
