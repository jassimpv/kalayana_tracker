import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/dashboard_guests.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/event_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/event_rsvp_page.dart';

class EventsTab extends GetView<GuestsController> {
  const EventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 84 + (isMobileAdsSupported ? AdsConfig.bannerHeight : 0),
        ),
        child: FloatingActionButton(
          backgroundColor: ThemeColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => openEventAdd(context),
          child: const Icon(Icons.add_rounded),
        ),
      ),
      body: Obx(() {
        final events = controller.events;
        if (events.isEmpty) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
            child: Align(
              alignment: Alignment.topCenter,
              child: _EventsEmptyState(onTap: () => openEventAdd(context)),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
          itemCount: events.length,
          itemBuilder: (context, index) => _EventCard(event: events[index]),
        );
      }),
    );
  }
}

class _EventCard extends GetView<GuestsController> {
  const _EventCard({required this.event});

  final WeddingEvent event;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = controller.eventWiseSummary.firstWhereOrNull(
        (s) => s.event.id == event.id,
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          background: const _SwipeDeleteBackground(),
          confirmDismiss: (_) => _confirmDeleteEvent(context, event),
          onDismissed: (_) => controller.deleteEvent(event.id),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EventRsvpPage(eventId: event.id),
              ),
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 78),
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeColors.primary.withValues(alpha: 0.10),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.calendar,
                      color: ThemeColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          event.name.isEmpty ? 'Unnamed event' : event.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _EventTag(
                              text: event.date == null
                                  ? 'Date not set'
                                  : '${event.date!.day}/${event.date!.month}/${event.date!.year}',
                            ),
                            if (event.venue.isNotEmpty)
                              _EventTag(text: event.venue),
                            if (summary != null) ...[
                              _EventTag(
                                text: 'Confirmed ${summary.confirmed}',
                                highlighted: true,
                              ),
                              _EventTag(text: 'Pending ${summary.pending}'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Edit event',
                    icon: const Icon(Icons.edit_outlined),
                    color: const Color(0xFF9C8389),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EventAddPage(existing: event),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete event',
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: const Color(0xFFC30B4A),
                    onPressed: () async {
                      final confirmed = await _confirmDeleteEvent(
                        context,
                        event,
                      );
                      if (confirmed) {
                        await Get.find<GuestsController>().deleteEvent(
                          event.id,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _EventsEmptyState extends StatelessWidget {
  const _EventsEmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 320),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.calendar_badge_plus,
            color: ThemeColors.primary,
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'No wedding events yet',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add Engagement, Mehndi, Nikah, Reception and more.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF78656A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('Add Event')),
        ],
      ),
    );
  }
}

class _EventTag extends StatelessWidget {
  const _EventTag({required this.text, this.highlighted = false});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted
            ? ThemeColors.primary.withValues(alpha: 0.1)
            : ThemeColors.logoGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: highlighted ? ThemeColors.primary : ThemeColors.logoDeep,
        ),
      ),
    );
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFC30B4A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.delete, color: Colors.white, size: 22),
          const SizedBox(height: 3),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmDeleteEvent(
  BuildContext context,
  WeddingEvent event,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete event'),
      content: Text(
        'Delete ${event.name.isEmpty ? 'this event' : event.name}? '
        'This removes its RSVP responses too.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC30B4A),
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
