import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/dashboard_view.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/event_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/events_tab.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_list_tab.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_reports.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/reminders_tab.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

const _guestsTabLabels = ['Overview', 'Guests', 'Events', 'Reminders'];

class GuestsPanel extends GetView<GuestsController> {
  const GuestsPanel({super.key, this.showHero = false});

  /// Shown when this panel is rendered as its own bottom-nav tab, which has
  /// no app bar above it (unlike the "Guests & RSVP" sub-page reached from
  /// Profile, which already gets a [CustomAppBar]).
  final bool showHero;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
        ),
      ),
      child: Column(
        children: [
          if (showHero && !desktop) const _RsvpHero(),
          _GuestsTabBar(),
          Expanded(
            child: Obx(() {
              if (controller.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return switch (controller.tabIndex.value) {
                1 => const GuestsListTab(),
                2 => const EventsTab(),
                3 => const RemindersTab(),
                _ => const GuestsOverviewTab(),
              };
            }),
          ),
        ],
      ),
    );
  }
}

class _RsvpHero extends StatelessWidget {
  const _RsvpHero();

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
            child: _RsvpGlow(size: 138, color: const Color(0xFFE01968)),
          ),
          Positioned(
            top: -76,
            right: -44,
            child: _RsvpGlow(size: 154, color: const Color(0xFFC11A4D)),
          ),
          Positioned(
            top: 16,
            right: -16,
            child: Icon(
              CupertinoIcons.person_crop_circle_fill_badge_checkmark,
              size: 92,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RSVP',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track guests, events and confirmations',
                    style: TextStyle(
                      color: Color(0xFFF7C859),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const ProfilePill(),
            ],
          ),
        ],
      ),
    );
  }
}

class _RsvpGlow extends StatelessWidget {
  const _RsvpGlow({required this.size, required this.color});

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

class _GuestsTabBar extends GetView<GuestsController> {
  const _GuestsTabBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Obx(
        () => Row(
          children: _guestsTabLabels.asMap().entries.map((entry) {
            final selected = controller.tabIndex.value == entry.key;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.tabIndex.value = entry.key,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? ThemeColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: ThemeColors.primary.withValues(alpha: 0.16),
                    ),
                  ),
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : ThemeColors.logoDeep,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class GuestsOverviewTab extends GetView<GuestsController> {
  const GuestsOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = [
        _StatCardData(
          icon: CupertinoIcons.person_3_fill,
          label: 'Total Guests',
          value: '${controller.totalGuests}',
          color: ThemeColors.primary,
        ),
        _StatCardData(
          icon: CupertinoIcons.mail_solid,
          label: 'Invitations',
          value: '${controller.totalInvitations}',
          color: ThemeColors.logoGold,
        ),
        _StatCardData(
          icon: CupertinoIcons.check_mark_circled_solid,
          label: 'Confirmed',
          value: '${controller.confirmedCount}',
          color: const Color(0xFF0D7A3A),
        ),
        _StatCardData(
          icon: CupertinoIcons.xmark_circle_fill,
          label: 'Declined',
          value: '${controller.declinedCount}',
          color: const Color(0xFFA90B3D),
        ),
        _StatCardData(
          icon: CupertinoIcons.question_circle_fill,
          label: 'Pending',
          value: '${controller.pendingCount}',
          color: const Color(0xFFF28B18),
        ),
        _StatCardData(
          icon: CupertinoIcons.group_solid,
          label: 'Expected Attendance',
          value: '${controller.expectedAttendance}',
          color: ThemeColors.weddingTeal,
        ),
      ];

      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 72),
        child: ResponsivePageContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatGrid(stats: stats),
              const SizedBox(height: 10),
              _SurfaceCard(
                title: 'Confirmation Rate',
                icon: Icons.donut_large_rounded,
                child: _ConfirmationRateRow(rate: controller.confirmationRate),
              ),
              const SizedBox(height: 14),
              _SurfaceCard(
                title: 'Event-wise Attendance',
                icon: Icons.event_available_rounded,
                child: controller.eventWiseSummary.isEmpty
                    ? const PremiumEmptyState(
                        icon: Icons.event_busy_rounded,
                        title: 'No events yet',
                        subtitle: 'Create a wedding event to see attendance.',
                      )
                    : Column(
                        children: controller.eventWiseSummary
                            .map(
                              (summary) =>
                                  _EventAttendanceRow(summary: summary),
                            )
                            .toList(),
                      ),
              ),
              const SizedBox(height: 14),
              _SurfaceCard(
                title: 'Reports',
                icon: Icons.picture_as_pdf_rounded,
                child: const GuestReportActions(),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatCardData {
  _StatCardData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.stats});

  final List<_StatCardData> stats;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final responsiveColumns = responsiveGridCount(context, desktopCount: 3);
    final columns = responsiveColumns == 1 ? 2 : responsiveColumns;
    final aspectRatio = screenWidth < mobileBreakpoint
        ? 1.95
        : columns == 2
        ? 2.8
        : 3.0;
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) => _StatCard(data: stats[index]),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});

  final _StatCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 16),
          ),
          const Spacer(),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: ThemeColors.logoDeep,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: ThemeColors.logoDeep.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeColors.logoGold, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.logoDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ConfirmationRateRow extends StatelessWidget {
  const _ConfirmationRateRow({required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).round();
    return Row(
      children: [
        SizedBox(
          width: 86,
          height: 86,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(86, 86),
                painter: _RatePainter(rate),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.logoDeep,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Share of all guest-event RSVP slots that have been confirmed so far.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0x993A1117),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatePainter extends CustomPainter {
  _RatePainter(this.rate);

  final double rate;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.16;
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = ThemeColors.logoGold.withValues(alpha: 0.18);
    canvas.drawArc(
      rect.deflate(stroke / 2),
      0,
      math.pi * 2,
      false,
      backgroundPaint,
    );

    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = ThemeColors.primary;
    canvas.drawArc(
      rect.deflate(stroke / 2),
      -math.pi / 2,
      math.pi * 2 * rate,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RatePainter oldDelegate) =>
      oldDelegate.rate != rate;
}

class _EventAttendanceRow extends StatelessWidget {
  const _EventAttendanceRow({required this.summary});

  final EventAttendance summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalGuests <= 0 ? 1 : summary.totalGuests;
    final confirmedRatio = summary.confirmed / total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  summary.event.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.logoDeep,
                  ),
                ),
              ),
              Text(
                '${summary.expectedAttendees} attending',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.logoDeep.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: confirmedRatio.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: ThemeColors.logoGold.withValues(alpha: 0.15),
              color: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

void openGuestAdd(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const GuestAddPage()));
}

void openEventAdd(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const EventAddPage()));
}
