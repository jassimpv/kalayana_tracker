import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class EventRsvpPage extends StatelessWidget {
  const EventRsvpPage({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestsController>();
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Obx(() {
          final event = controller.events.firstWhereOrNull(
            (e) => e.id == eventId,
          );
          return Text(event?.name ?? 'Event RSVP');
        }),
      ),
      body: Obx(() {
        final guests = controller.guests;
        if (guests.isEmpty) {
          return const Center(
            child: PremiumEmptyState(
              icon: Icons.person_off_rounded,
              title: 'No guests yet',
              subtitle: 'Add guests to record their RSVP for this event.',
            ),
          );
        }
        return DashboardFormPage(
          children: guests
              .map((guest) => _GuestRsvpRow(guest: guest, eventId: eventId))
              .toList(),
        );
      }),
    );
  }
}

class _GuestRsvpRow extends StatelessWidget {
  const _GuestRsvpRow({required this.guest, required this.eventId});

  final Guest guest;
  final String eventId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestsController>();
    return Obx(() {
      final response = controller.responseFor(guest.id, eventId);
      final status = response?.status ?? rsvpStatusPending;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DashboardFormCard(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    guest.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: status,
                  underline: const SizedBox.shrink(),
                  items: rsvpStatuses
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    controller.setRsvp(
                      guestId: guest.id,
                      eventId: eventId,
                      status: value,
                      attendeeCount: response?.attendeeCount ?? 0,
                      specialRequirements: response?.specialRequirements ?? '',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
