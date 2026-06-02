part of '../dashboard_view.dart';

class OverviewPanel extends GetView<DashboardController> {
  const OverviewPanel({super.key, required this.data});

  final WeddingData data;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final profile = controller.profile;
      final date = profileMarriageDate(profile);
      final paymentProgress = data.totalBudget == 0
          ? 0.0
          : (data.paid / data.totalBudget).clamp(0.0, 1.0);
      return _DashboardOverviewScreen(
        data: data,
        profile: profile,
        weddingDate: date,
        progress: paymentProgress,
        onExpense: () => Navigator.of(context).push(
          buildNestedDashboardRoute(
            settings: const RouteSettings(name: AppRoutes.dashboardExpenseAdd),
            child: const ExpenseAddPage(),
            transitionDuration: const Duration(milliseconds: 280),
            startOffset: const Offset(0.12, 0),
          ),
        ),
        onReminder: () => showReminderDialog(context),
        onPurchase: () => showPurchaseDialog(context),
      );
    });
  }
}

class _DashboardOverviewScreen extends StatelessWidget {
  const _DashboardOverviewScreen({
    required this.data,
    required this.profile,
    required this.weddingDate,
    required this.progress,
    required this.onExpense,
    required this.onReminder,
    required this.onPurchase,
  });

  final WeddingData data;
  final Map<String, dynamic> profile;
  final DateTime? weddingDate;
  final double progress;
  final VoidCallback onExpense;
  final VoidCallback onReminder;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = _profileDisplayName(user, profile);
    final firstName = displayName.split(RegExp(r'\s+')).first;
    final groom = profileGroom(profile);
    final bride = profileBride(profile);
    final couple = groom.isNotEmpty && bride.isNotEmpty
        ? '$groom & $bride'
        : displayName == '-'
        ? 'Your Wedding'
        : displayName;
    final daysLeft = daysUntilDate(weddingDate);
    final paid = data.paid;
    final pending = data.pending;
    final remaining = math.max(data.totalBudget - paid - pending, 0.0);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF3E4), Color(0xFFFFFCF7)],
        ),
      ),
      child: Column(
        children: [
          _DashboardHeroHeader(
            firstName: firstName == '-' ? 'Jassim' : firstName,
            user: user,
            coupleName: couple,
            weddingDate: weddingDate,
            daysLeft: daysLeft,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: Column(
              children: [
                _BudgetHeroCard(
                  total: data.totalBudget,
                  paid: paid,
                  pending: pending,
                  remaining: remaining,
                  progress: progress,
                ),
                const SizedBox(height: 14),
                _BudgetMetricStrip(
                  paid: paid,
                  pending: pending,
                  remaining: remaining,
                  progress: progress,
                ),
                const SizedBox(height: 18),
                _PaymentPulseCard(daysLeft: daysLeft, onTap: onReminder),
                const SizedBox(height: 20),
                _OverviewQuickActions(
                  onExpense: onExpense,
                  onReminder: onReminder,
                  onPurchase: onPurchase,
                ),
                const SizedBox(height: 18),
                _OverviewBudgetAnalytics(
                  progress: progress,
                  categoryTotals: data.categoryTotals,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeroHeader extends StatelessWidget {
  const _DashboardHeroHeader({
    required this.firstName,
    required this.user,
    required this.coupleName,
    required this.weddingDate,
    required this.daysLeft,
  });

  final String firstName;
  final User? user;
  final String coupleName;
  final DateTime? weddingDate;
  final int? daysLeft;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final heroHeight = topInset + 296;
    return SizedBox(
      height: heroHeight + 96,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipPath(
            clipper: _OverviewHeaderClipper(),
            child: Container(
              height: heroHeight,
              decoration: const BoxDecoration(color: Color(0xFF8F1438)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/auth_wedding_hero.png',
                      fit: BoxFit.cover,
                      alignment: const Alignment(0.72, -0.02),
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xF28F1438),
                            Color(0xD09D1740),
                            Color(0x709D1740),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: topInset + 22,
                    left: 22,
                    right: 22,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi $firstName 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                  fontWeight: FontWeight.w900,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Let's plan your perfect day",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        _HeaderCircleButton(
                          icon: Icons.notifications_none_rounded,
                        ),
                        const SizedBox(width: 10),
                        _ProfilePill(user: user),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 10,
            child: _WeddingIdentityCard(
              coupleName: coupleName,
              weddingDate: weddingDate,
              daysLeft: daysLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Icon(icon, color: Colors.white.withValues(alpha: 0.88), size: 26),
    );
  }
}

class _ProfilePill extends StatelessWidget {
  const _ProfilePill({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(6, 5, 10, 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _ResilientAvatar(
            initials: _profileInitials(user?.displayName ?? user?.email ?? 'J'),
            imageUrl: user?.photoURL,
            size: 40,
          ),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _WeddingIdentityCard extends StatelessWidget {
  const _WeddingIdentityCard({
    required this.coupleName,
    required this.weddingDate,
    required this.daysLeft,
  });

  final String coupleName;
  final DateTime? weddingDate;
  final int? daysLeft;

  @override
  Widget build(BuildContext context) {
    final daysText = daysLeft == null
        ? 'Date pending'
        : daysLeft! <= 0
        ? 'Today'
        : '$daysLeft days to go';
    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFF1D9),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  Icons.celebration_rounded,
                  color: Color(0xFFB87A25),
                  size: 34,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: ThemeColors.logoGold, width: 2),
                  ),
                  child: const AppLogo(
                    size: 22,
                    padding: 1,
                    showBackground: false,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Wedding',
                  style: TextStyle(
                    color: Color(0xFFB87A25),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coupleName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF421018),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFFB87A25),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 10,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _WeddingMetaChip(
                      icon: Icons.calendar_month_rounded,
                      text: weddingDate == null
                          ? 'Set date'
                          : formatDate(weddingDate!),
                    ),
                    _WeddingMetaChip(
                      icon: Icons.favorite_border_rounded,
                      text: daysText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeddingMetaChip extends StatelessWidget {
  const _WeddingMetaChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF9D1740)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF9D1740),
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _BudgetHeroCard extends StatelessWidget {
  const _BudgetHeroCard({
    required this.total,
    required this.paid,
    required this.pending,
    required this.remaining,
    required this.progress,
  });

  final double total;
  final double paid;
  final double pending;
  final double remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(compact ? 16 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B0E33), Color(0xFF6C0928)],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B0E33).withValues(alpha: 0.24),
                blurRadius: 26,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: compact ? 6 : 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total Wedding Budget',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '₹${formatMoney(total)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 34 : 36,
                          fontWeight: FontWeight.w900,
                          height: 0.95,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Overall allocation across all\nexpenses and vendors',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: compact ? 10 : 16),
              SizedBox(
                width: compact ? 116 : 170,
                child: Column(
                  children: [
                    _ProgressRing(
                      progress: progress,
                      color: ThemeColors.logoGold,
                      size: compact ? 92 : 96,
                      stroke: 13,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                            ),
                          ),
                          const Text(
                            'paid',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _BudgetLegendGrid(
                      paid: paid,
                      pending: pending,
                      remaining: remaining,
                      compact: compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BudgetLegendGrid extends StatelessWidget {
  const _BudgetLegendGrid({
    required this.paid,
    required this.pending,
    required this.remaining,
    required this.compact,
  });

  final double paid;
  final double pending;
  final double remaining;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final items = [
      _LegendItem('Paid', paid, const Color(0xFFD59A42)),
      _LegendItem('Pending', pending, const Color(0xFFF0C7AE)),
      _LegendItem('Remaining', remaining, const Color(0xFFF4E4D8)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: _BudgetLegendDot(
                label: item.label,
                value: item.value,
                color: item.color,
                compact: compact,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _LegendItem {
  const _LegendItem(this.label, this.value, this.color);
  final String label;
  final double value;
  final Color color;
}

class _BudgetLegendDot extends StatelessWidget {
  const _BudgetLegendDot({
    required this.label,
    required this.value,
    required this.color,
    required this.compact,
  });

  final String label;
  final double value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!compact)
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (!compact) const SizedBox(height: 3),
                Text(
                  '₹${formatMoney(value)}',
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(fontSize: compact ? 12 : 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetMetricStrip extends StatelessWidget {
  const _BudgetMetricStrip({
    required this.paid,
    required this.pending,
    required this.remaining,
    required this.progress,
  });

  final double paid;
  final double pending;
  final double remaining;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricSpec(
        Icons.account_balance_wallet_rounded,
        'Paid',
        '₹${formatMoney(paid)}',
        const Color(0xFF13A05F),
      ),
      _MetricSpec(
        Icons.pending_actions_rounded,
        'Pending',
        '₹${formatMoney(pending)}',
        const Color(0xFFE49B22),
      ),
      _MetricSpec(
        Icons.currency_rupee_rounded,
        'Remaining',
        '₹${formatMoney(remaining)}',
        ThemeColors.primary,
      ),
      _MetricSpec(
        Icons.pie_chart_rounded,
        'Budget Used',
        '${(progress * 100).round()}%',
        ThemeColors.primary,
      ),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < metrics.length; i++) ...[
            Expanded(child: _MetricTile(spec: metrics[i])),
            if (i != metrics.length - 1)
              Container(
                width: 1,
                height: 58,
                color: ThemeColors.primary.withValues(alpha: 0.12),
              ),
          ],
        ],
      ),
    );
  }
}

class _MetricSpec {
  const _MetricSpec(this.icon, this.label, this.value, this.color);
  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.spec});

  final _MetricSpec spec;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0E7),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(spec.icon, color: ThemeColors.primary, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          spec.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            spec.value,
            style: TextStyle(
              color: spec.color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentPulseCard extends StatelessWidget {
  const _PaymentPulseCard({required this.daysLeft, required this.onTap});

  final int? daysLeft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final days = daysLeft == null
        ? '--'
        : daysLeft! <= 0
        ? '0'
        : daysLeft.toString();
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF6E9), Color(0xFFFFEBD4)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ThemeColors.logoGold.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: narrow ? 64 : 74,
                    height: narrow ? 64 : 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ThemeColors.primaryGradient,
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: narrow ? 36 : 42,
                    ),
                  ),
                  Positioned(
                    right: -3,
                    bottom: -3,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: ThemeColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Pulse',
                      style: TextStyle(
                        color: Color(0xFFB87A25),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$days days left',
                      maxLines: narrow ? 2 : 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF421018),
                        fontSize: narrow ? 22 : 24,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stay on track and make\nyour day perfect ✨',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF421018),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.22,
                      ),
                    ),
                  ],
                ),
              ),
              if (!narrow) ...[
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(112, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Schedule'),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                ),
              ] else
                IconButton.filled(
                  onPressed: onTap,
                  style: IconButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _OverviewQuickActions extends StatelessWidget {
  const _OverviewQuickActions({
    required this.onExpense,
    required this.onReminder,
    required this.onPurchase,
  });

  final VoidCallback onExpense;
  final VoidCallback onReminder;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionSpec(
        Icons.post_add_rounded,
        'Add Expense',
        'Track spending',
        onExpense,
      ),
      _ActionSpec(
        Icons.event_note_rounded,
        'Add Date',
        'Important events',
        onReminder,
      ),
      _ActionSpec(
        Icons.shopping_bag_rounded,
        'Shopping',
        'Manage items',
        onPurchase,
      ),
      _ActionSpec(Icons.groups_rounded, 'Vendors', 'Manage vendors', () {
        Get.snackbar(
          'Vendors',
          'Vendor management is coming soon.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }),
    ];
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Quick Actions',
                style: TextStyle(
                  color: Color(0xFF421018),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: ThemeColors.primary),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all'),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              Expanded(child: _ActionCard(spec: actions[i])),
              if (i != actions.length - 1) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

class _ActionSpec {
  const _ActionSpec(this.icon, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.spec});

  final _ActionSpec spec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.74),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: spec.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ThemeColors.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(spec.icon, color: ThemeColors.primary, size: 27),
              const SizedBox(height: 6),
              Text(
                spec.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                spec.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewBudgetAnalytics extends StatelessWidget {
  const _OverviewBudgetAnalytics({
    required this.progress,
    required this.categoryTotals,
  });

  final double progress;
  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.isEmpty
        ? const [
            MapEntry('Venue', 220000.0),
            MapEntry('Catering', 180400.0),
            MapEntry('Decoration', 120000.0),
          ]
        : entries.take(3).toList();
    final total = top.fold<double>(0, (sum, item) => sum + item.value);
    final colors = [
      ThemeColors.primary,
      const Color(0xFFC88932),
      const Color(0xFFE36C76),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Budget Analytics',
                  style: TextStyle(
                    color: Color(0xFF421018),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF421018),
                  minimumSize: const Size(98, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(
                    color: ThemeColors.primary.withValues(alpha: 0.12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('This Month'),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ProgressRing(
                progress: progress,
                color: ThemeColors.primary,
                size: 112,
                stroke: 14,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Color(0xFF421018),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Text(
                      'paid',
                      style: TextStyle(
                        color: Color(0xFF421018),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Top Spending Categories',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          'View Report ›',
                          style: TextStyle(
                            color: ThemeColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    for (var i = 0; i < top.length; i++)
                      _CategorySpendRow(
                        name: top[i].key,
                        value: top[i].value,
                        percent: total == 0 ? 0 : top[i].value / total,
                        color: colors[i % colors.length],
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

class _CategorySpendRow extends StatelessWidget {
  const _CategorySpendRow({
    required this.name,
    required this.value,
    required this.percent,
    required this.color,
  });

  final String name;
  final double value;
  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_categoryIcon(name), color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '₹${formatMoney(value)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(percent * 100).round()}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0.0, 1.0),
                    minHeight: 5,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.08),
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

IconData _categoryIcon(String category) {
  final normalized = category.toLowerCase();
  if (normalized.contains('venue')) return Icons.account_balance_rounded;
  if (normalized.contains('food') || normalized.contains('cater')) {
    return Icons.room_service_rounded;
  }
  if (normalized.contains('decor')) return Icons.local_florist_rounded;
  if (normalized.contains('photo')) return Icons.photo_camera_rounded;
  if (normalized.contains('travel')) return Icons.flight_takeoff_rounded;
  return Icons.category_rounded;
}

class _OverviewHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height - 48)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height + 12,
        size.width * 0.64,
        size.height - 16,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height - 36,
        size.width,
        size.height - 52,
      )
      ..lineTo(size.width, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ignore: unused_element
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

// ignore: unused_element
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

// ignore: unused_element
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

// ignore: unused_element
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

// ignore: unused_element
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

// ignore: unused_element
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
