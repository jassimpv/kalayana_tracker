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
          _DashboardWelcomeHeader(
            coupleName: _coupleName(profile),
            weddingDate: date,
          ),
          const SizedBox(height: 20),
          _OverviewHero(
            data: data,
            weddingDate: date,
            coupleName: _coupleName(profile),
          ),
          const SizedBox(height: 20),
          _PremiumQuickActions(
            onExpense: () => showExpenseDialog(context),
            onReminder: () => showReminderDialog(context),
            onPurchase: () => showPurchaseDialog(context),
          ),
          const SizedBox(height: 20),
          _BudgetAnalyticsCard(
            total: data.totalBudget,
            paid: data.paid,
            pending: data.pending,
            progress: paymentProgress,
          ),
          const SizedBox(height: 20),
          _TodayFocusCard(
            pendingExpenses: pendingExpenses,
            reminders: upcoming,
            repayment: data.repaymentPending,
          ),
          const SizedBox(height: 20),
          _UpcomingEventsCarousel(
            reminders: upcoming.take(5).toList(),
            onAdd: () => showReminderDialog(context),
            onEdit: (item) => showReminderDialog(context, reminder: item),
            onToggle: controller.toggleReminder,
          ),
          const SizedBox(height: 20),
          _PaymentTimeline(expenses: pendingExpenses.take(4).toList()),
        ],
      );
    });
  }
}

class _DashboardWelcomeHeader extends StatelessWidget {
  const _DashboardWelcomeHeader({
    required this.coupleName,
    required this.weddingDate,
  });

  final String? coupleName;
  final DateTime? weddingDate;

  @override
  Widget build(BuildContext context) {
    final days = daysUntilDate(weddingDate);
    final dateText = weddingDate == null
        ? 'Add your wedding date to unlock the countdown.'
        : '${formatDate(weddingDate!)}${days == null ? '' : ' • ${_momentDayLabel(days)} ${_momentDaySuffix(days)}'}';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wedding Budget Dashboard',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: ThemeColors.logoDeep,
                      fontSize: compact ? 30 : 40,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    coupleName == null ? dateText : '$coupleName • $dateText',
                    maxLines: compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: ThemeColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: ThemeColors.logoGold.withValues(alpha: 0.32),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: ThemeColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Premium planner',
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final greeting = _OverviewGreetingCard(
            coupleName: coupleName,
            weddingDate: weddingDate,
            daysLeft: daysLeft,
          );
          final budget = _OverviewBudgetCard(total: data.totalBudget);
          final pulse = _OverviewPulseCard(
            weddingDate: weddingDate,
            progress: budgetProgress,
          );
          return _ResponsiveCardGrid(
            spacing: 16,
            children: [greeting, budget, pulse],
          );
        },
      ),
    );
  }
}

class _ResponsiveCardGrid extends StatelessWidget {
  const _ResponsiveCardGrid({required this.children, this.spacing = 16});

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 960
            ? 3
            : width >= 640
            ? 2
            : 1;
        final itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth.isFinite ? itemWidth : width,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _OverviewGreetingCard extends StatelessWidget {
  const _OverviewGreetingCard({
    required this.coupleName,
    required this.weddingDate,
    required this.daysLeft,
  });

  final String? coupleName;
  final DateTime? weddingDate;
  final int? daysLeft;

  @override
  Widget build(BuildContext context) {
    final title = coupleName ?? 'Kalyana command suite';
    final countdownText = daysLeft == null
        ? 'Date locked'
        : daysLeft! <= 0
        ? 'Today is the day'
        : '$daysLeft days to forever';
    final dateText = weddingDate == null
        ? 'Set the wedding date for your countdown'
        : '${formatDate(weddingDate!)}  |  $countdownText';
    return _PremiumSurface(
      padding: const EdgeInsets.all(18),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCF6), Color(0xFFFFF0D8)],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -56,
            top: -58,
            child: _BlurCircle(
              color: Color(0xFFE7AD4F),
              size: 150,
              alpha: 0.12,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _CoupleAvatar(name: coupleName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good evening',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1.02,
                            letterSpacing: 0,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dateText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
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

class _OverviewBudgetCard extends StatelessWidget {
  const _OverviewBudgetCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF7A1230), Color(0xFF9D1740)],
      ),
      borderColor: Colors.white24,
      child: Stack(
        children: [
          const Positioned(
            right: -38,
            bottom: -62,
            child: _BlurCircle(
              color: Color(0xFFE8B75C),
              size: 170,
              alpha: 0.18,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wedding budget',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: total),
                duration: const Duration(milliseconds: 820),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '₹${formatMoney(value)}',
                    maxLines: 1,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 0.95,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total allocation across expenses, dates, and shopping.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewPulseCard extends StatelessWidget {
  const _OverviewPulseCard({required this.weddingDate, required this.progress});

  final DateTime? weddingDate;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final days = daysUntilDate(weddingDate);
    final displayDays = days == null
        ? '--'
        : days <= 0
        ? '0'
        : days.toString();
    return _PremiumSurface(
      padding: const EdgeInsets.all(18),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFBF4), Color(0xFFFFE4B8)],
      ),
      child: Row(
        children: [
          _ProgressRing(
            progress: progress,
            color: ThemeColors.primary,
            size: 82,
            stroke: 9,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  'paid',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayDays,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900, height: 0.95),
                    ),
                    const SizedBox(width: 5),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(
                        weddingDate == null ? 'days' : 'days left',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Payment pulse',
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Countdown and budget analytics',
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.88),
            const Color(0xFFFFF7F1).withValues(alpha: 0.72),
            const Color(0xFFFFEFD8).withValues(alpha: 0.72),
          ],
        ),
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 130),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeColors.primary.withValues(alpha: 0.10),
                      ThemeColors.logoGold.withValues(alpha: 0.14),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(widget.icon, color: ThemeColors.primary),
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 680;
          final statCards = [
            _AnalyticsStatCard(
              label: 'Paid amount',
              value: '₹${formatMoney(paid)}',
              icon: Icons.verified_rounded,
              color: ThemeColors.primary,
            ),
            _AnalyticsStatCard(
              label: 'Pending',
              value: '₹${formatMoney(pending)}',
              icon: Icons.hourglass_top_rounded,
              color: ThemeColors.logoGold,
            ),
            _AnalyticsStatCard(
              label: 'Remaining share',
              value: '${(100 - (progress * 100).round()).clamp(0, 100)}%',
              icon: Icons.pie_chart_rounded,
              color: ThemeColors.terracotta,
            ),
          ];
          final summary = Row(
            children: [
              _ProgressRing(
                progress: progress,
                color: scheme.primary,
                size: compact ? 100 : 116,
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
                      'paid',
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
                          ?.copyWith(
                            color: ThemeColors.logoDeep,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Wedding allocation across vendors, dates, and shopping.',
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.outline,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: 'Budget analytics',
                action: '${(progress * 100).round()}% paid',
              ),
              const SizedBox(height: 18),
              if (compact)
                Column(
                  children: [
                    summary,
                    const SizedBox(height: 16),
                    ...statCards.map(
                      (card) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: card,
                      ),
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: summary),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 6,
                      child: _ResponsiveCardGrid(
                        spacing: 10,
                        children: statCards,
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  const _AnalyticsStatCard({
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
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          SoftIcon(icon: icon, color: color),
          const SizedBox(width: 12),
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
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ThemeColors.logoDeep,
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
            color: ThemeColors.logoGold,
            title: nextBill?.name ?? 'No bill due next',
            subtitle: nextBill == null
                ? 'Pending bills will appear here.'
                : '${moneyOrDash(nextBill.pendingForSummary)} pending${nextBill.dueDate == null ? '' : ' | Due ${formatDate(nextBill.dueDate!)}'}',
          ),
          const SizedBox(height: 10),
          _FocusRow(
            icon: Icons.event_available_rounded,
            color: ThemeColors.primary,
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
          SoftIcon(icon: icon, color: color),
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
                const PremiumEmptyState(
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
              SoftIcon(icon: _eventIcon(item.category), color: doneColor),
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
            const PremiumEmptyState(
              icon: Icons.payments_rounded,
              title: 'All payments feel clear',
              subtitle: 'Pending balances will appear here.',
            )
          else
            ...items.asMap().entries.map((entry) {
              final item = entry.value;
              final color = entry.key.isEven
                  ? ThemeColors.primary
                  : ThemeColors.logoGold;
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

class CoupleCollaborationCard extends StatelessWidget {
  const CoupleCollaborationCard({
    super.key,
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
                  0xFFE8B75C,
                ).withValues(alpha: 0.16),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF9D1740),
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
    return const Color(0xFF2E9B67);
  }
  if (normalized.contains('advance') || normalized == 'ordered') {
    return const Color(0xFFC06A2A);
  }
  if (normalized.contains('pending') ||
      normalized.contains('planning') ||
      normalized == 'planned') {
    return ThemeColors.logoGold;
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
