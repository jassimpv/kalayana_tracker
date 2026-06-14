part of '../dashboard_view.dart';

class RemindersPanel extends GetView<DashboardController> {
  const RemindersPanel({super.key, required this.reminders});

  final List<EventReminder> reminders;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final sorted = [...reminders]
      ..sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        return a.dueDate.compareTo(b.dueDate);
      });
    final paymentReminders = sorted
        .where((item) => item.category == 'Payment' && !item.isDone)
        .toList();
    final dueTodayPayments = paymentReminders
        .where((item) => daysUntilDate(item.dueDate, from: today) == 0)
        .toList();
    final upcomingPayments = paymentReminders
        .where((item) => (daysUntilDate(item.dueDate, from: today) ?? 0) > 0)
        .toList();
    final taskReminders = sorted
        .where((item) => item.category != 'Payment')
        .toList();
    final completedCount = reminders.where((item) => item.isDone).length;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReminderHero(),
          Transform.translate(
            offset: const Offset(0, -15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _ReminderStatsCard(
                stats: [
                  _ReminderStat(
                    icon: CupertinoIcons.creditcard_fill,
                    value: dueTodayPayments.length,
                    label: 'Due Today',
                    color: const Color(0xFFA90B3D),
                    tint: const Color(0xFFFBE8EA),
                  ),
                  _ReminderStat(
                    icon: CupertinoIcons.calendar_badge_plus,
                    value: upcomingPayments.length,
                    label: 'Upcoming',
                    color: const Color(0xFFF28B18),
                    tint: const Color(0xFFFFF0E0),
                  ),
                  _ReminderStat(
                    icon: CupertinoIcons.check_mark_circled_solid,
                    value: completedCount,
                    label: 'Completed',
                    color: const Color(0xFF0D7A3A),
                    tint: const Color(0xFFEAF3ED),
                  ),
                  _ReminderStat(
                    icon: CupertinoIcons.arrow_counterclockwise,
                    value: reminders.length,
                    label: 'All Reminders',
                    color: const Color(0xFF6A0C91),
                    tint: const Color(0xFFF0E7F7),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: _PaymentEmptyCallout(
              hasDuePayments: dueTodayPayments.isNotEmpty,
              payment: dueTodayPayments.firstOrNull,
              onTap: controller.openReminderAdd,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _ReminderTaskHeader(showingCompleted: false, onTap: () {}),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: taskReminders.isEmpty
                ? _ReminderEmptyTasks(onTap: controller.openReminderAdd)
                : Column(
                    children: taskReminders
                        .map((item) => _WeddingTaskCard(item: item))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ReminderHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      width: double.infinity,
      height: top + 110,
      padding: EdgeInsets.fromLTRB(22, top + 18, 22, 0),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.25,
          colors: [Color(0xFFC71053), Color(0xFF8F1438), Color(0xFF5A0820)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -76,
            left: -96,
            child: _ReminderGlow(size: 138, color: const Color(0xFFE01968)),
          ),
          Positioned(
            top: -76,
            right: -44,
            child: _ReminderGlow(size: 154, color: const Color(0xFFC11A4D)),
          ),
          const Positioned(top: 20, right: -28, child: _ReminderHeaderArt()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reminders',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Stay on track, never miss a payment',
                style: TextStyle(
                  color: Color(0xFFF7C859),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReminderGlow extends StatelessWidget {
  const _ReminderGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.34),
      ),
    );
  }
}

class _ReminderHeaderArt extends StatelessWidget {
  const _ReminderHeaderArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 78,
      child: FittedBox(
        child: SizedBox(
          width: 150,
          height: 102,
          child: CustomPaint(painter: _ReminderHeaderArtPainter()),
        ),
      ),
    );
  }
}

class _ReminderHeaderArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFE8A64E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final rose = Paint()
      ..color = const Color(0xFFB61B48).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final faint = Paint()
      ..color = const Color(0xFFEF6A71).withValues(alpha: 0.32)
      ..style = PaintingStyle.fill;

    final cal = Rect.fromLTWH(46, 20, 64, 54);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cal, const Radius.circular(5)),
      gold,
    );
    canvas.drawLine(
      Offset(cal.left, cal.top + 17),
      Offset(cal.right, cal.top + 17),
      gold,
    );
    for (final x in [56.0, 72.0, 88.0, 104.0]) {
      canvas.drawLine(Offset(x, 12), Offset(x, 30), gold);
    }
    for (final point in [
      const Offset(58, 42),
      const Offset(77, 42),
      const Offset(96, 42),
      const Offset(58, 60),
      const Offset(77, 60),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(point.dx, point.dy, 9, 9),
          const Radius.circular(2),
        ),
        rose,
      );
    }

    final bellPath = Path()
      ..moveTo(110, 72)
      ..quadraticBezierTo(102, 70, 101, 63)
      ..lineTo(101, 49)
      ..quadraticBezierTo(102, 30, 119, 28)
      ..quadraticBezierTo(137, 30, 138, 49)
      ..lineTo(138, 63)
      ..quadraticBezierTo(139, 70, 148, 72)
      ..close();
    canvas.drawPath(bellPath, gold);
    canvas.drawArc(Rect.fromLTWH(113, 72, 14, 12), 0, math.pi, false, gold);
    canvas.drawLine(const Offset(119, 20), const Offset(119, 28), gold);

    final leafPath = Path()
      ..moveTo(18, 78)
      ..quadraticBezierTo(32, 52, 55, 62)
      ..quadraticBezierTo(30, 57, 12, 46);
    canvas.drawPath(leafPath, rose);
    for (final offset in [
      const Offset(20, 72),
      const Offset(31, 64),
      const Offset(43, 61),
      const Offset(132, 18),
      const Offset(137, 11),
      const Offset(142, 26),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: offset, width: 13, height: 26),
        faint,
      );
    }

    final sparkle = Path()
      ..moveTo(25, 17)
      ..lineTo(31, 29)
      ..lineTo(43, 35)
      ..lineTo(31, 41)
      ..lineTo(25, 53)
      ..lineTo(19, 41)
      ..lineTo(7, 35)
      ..lineTo(19, 29)
      ..close();
    canvas.drawPath(sparkle, gold);
    canvas.drawCircle(const Offset(20, 7), 1.8, faint);
    canvas.drawCircle(const Offset(146, 48), 1.6, faint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ReminderStatsCard extends StatelessWidget {
  const _ReminderStatsCard({required this.stats});

  final List<_ReminderStat> stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          return Expanded(
            child: Row(
              children: [
                Expanded(child: _ReminderStatTile(stat: entry.value)),
                if (entry.key != stats.length - 1)
                  Container(
                    width: 1,
                    height: 48,
                    color: const Color(0xFFEACBC8).withValues(alpha: 0.72),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReminderStat {
  const _ReminderStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final Color tint;
}

class _ReminderStatTile extends StatelessWidget {
  const _ReminderStatTile({required this.stat});

  final _ReminderStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: stat.tint,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(stat.icon, color: stat.color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          stat.value.toString(),
          style: TextStyle(
            color: stat.color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          stat.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: stat.color,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentEmptyCallout extends StatelessWidget {
  const _PaymentEmptyCallout({
    required this.hasDuePayments,
    required this.payment,
    required this.onTap,
  });

  final bool hasDuePayments;
  final EventReminder? payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = hasDuePayments
        ? (payment?.title.isEmpty ?? true
              ? 'Payment due today'
              : payment!.title)
        : 'No due payments yet';
    final subtitle = hasDuePayments
        ? 'Due today. Tap to add another reminder.'
        : 'Create a payment reminder to track upcoming bills.';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0C9C6)),
      ),
      child: Row(
        children: [
          const _PaymentBadge(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF78656A),
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AddReminderButton(onTap: onTap),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.primary.withValues(alpha: 0.10),
            ),
          ),
          Container(
            width: 25,
            height: 18,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE62971), Color(0xFF9D1740)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.creditcard_fill,
              color: Colors.white,
              size: 15,
            ),
          ),
          Positioned(
            right: 2,
            bottom: 3,
            child: Container(
              width: 17,
              height: 17,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFF1EA),
              ),
              child: const Icon(
                CupertinoIcons.bell_fill,
                color: Color(0xFF8F1438),
                size: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddReminderButton extends StatelessWidget {
  const _AddReminderButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9A123A), Color(0xFFC30B4A)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9A123A).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.plus, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Add Reminder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTaskHeader extends StatelessWidget {
  const _ReminderTaskHeader({
    required this.showingCompleted,
    required this.onTap,
  });

  final bool showingCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Wedding Tasks',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Row(
              children: [
                Text(
                  showingCompleted ? 'Completed' : 'Upcoming',
                  style: const TextStyle(
                    color: Color(0xFFD17B14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 5),
                const Icon(
                  CupertinoIcons.chevron_down,
                  color: Color(0xFFD17B14),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReminderEmptyTasks extends StatelessWidget {
  const _ReminderEmptyTasks({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            color: ThemeColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'No wedding tasks yet',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('Add Reminder')),
        ],
      ),
    );
  }
}

class _WeddingTaskCard extends GetView<DashboardController> {
  const _WeddingTaskCard({required this.item});

  final EventReminder item;

  @override
  Widget build(BuildContext context) {
    final days = daysUntilDate(item.dueDate);
    final daysColor = item.isDone
        ? const Color(0xFF0D7A3A)
        : days != null && days < 0
        ? const Color(0xFFC30B4A)
        : const Color(0xFFB21546);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => showReminderDialog(context, reminder: item),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF1D9D5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              InkWell(
                onTap: () => controller.toggleReminder(item),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeColors.primary.withValues(alpha: 0.10),
                    border: Border.all(
                      color: item.isDone
                          ? const Color(0xFF0D7A3A)
                          : ThemeColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Icon(
                    item.isDone
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.calendar,
                    color: item.isDone
                        ? const Color(0xFF0D7A3A)
                        : ThemeColors.primary,
                    size: 21,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title.isEmpty ? 'Untitled task' : item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: item.isDone
                            ? const Color(0xFF78656A)
                            : ThemeColors.logoDeep,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          color: ThemeColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            formatDate(item.dueDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF726166),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _DaysLeftPill(days: days, color: daysColor, done: item.isDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _DaysLeftPill extends StatelessWidget {
  const _DaysLeftPill({
    required this.days,
    required this.color,
    required this.done,
  });

  final int? days;
  final Color color;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final label = done
        ? 'Done'
        : days == null
        ? '-'
        : days! < 0
        ? days!.abs().toString()
        : days.toString();
    final caption = done
        ? ''
        : days != null && days! < 0
        ? 'overdue'
        : 'days left';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0CCC8)),
      ),
      width: 50,
      height: 50,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: done ? 12 : 17,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          if (caption.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              caption.capitalizeFirst ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
