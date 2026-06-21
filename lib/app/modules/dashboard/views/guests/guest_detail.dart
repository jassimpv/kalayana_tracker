import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/rsvp_response.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class GuestDetailPage extends StatelessWidget {
  const GuestDetailPage({super.key, required this.guestId});

  final String guestId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestsController>();
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Guest Details'),
      ),
      body: Obx(() {
        final guest = controller.guests.firstWhereOrNull(
          (g) => g.id == guestId,
        );
        if (guest == null) {
          return const Center(
            child: PremiumEmptyState(
              icon: Icons.person_off_rounded,
              title: 'Guest not found',
              subtitle: 'This guest may have been deleted.',
            ),
          );
        }
        return DashboardFormPage(
          children: [
            DashboardFormIntroCard(
              icon: Icons.person_rounded,
              title: guest.name,
              subtitle: '${guest.side} • ${guest.category}',
            ),
            const SizedBox(height: 12),
            DashboardFormCard(
              children: [
                if (guest.phone.isNotEmpty) Text('Phone: ${guest.phone}'),
                if (guest.whatsapp.isNotEmpty)
                  Text('WhatsApp: ${guest.whatsapp}'),
                Text('Invited: ${guest.numberInvited}'),
                if (guest.address.isNotEmpty) Text('Address: ${guest.address}'),
                if (guest.notes.isNotEmpty) Text('Notes: ${guest.notes}'),
                if (guest.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      children: guest.tags
                          .map((tag) => Chip(label: Text(tag)))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GuestAddPage(existing: guest),
                          ),
                        ),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, controller, guestId),
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'RSVP by Event',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (controller.events.isEmpty)
              const PremiumEmptyState(
                icon: Icons.event_busy_rounded,
                title: 'No events yet',
                subtitle: 'Create a wedding event first.',
              )
            else
              ...controller.events.map(
                (event) => _EventRsvpEditor(guestId: guestId, event: event),
              ),
          ],
        );
      }),
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  GuestsController controller,
  String guestId,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete guest'),
      content: const Text('This will remove the guest and their RSVP history.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await controller.deleteGuest(guestId);
  if (context.mounted) Navigator.of(context).pop();
}

class _EventRsvpEditor extends StatefulWidget {
  const _EventRsvpEditor({required this.guestId, required this.event});

  final String guestId;
  final WeddingEvent event;

  @override
  State<_EventRsvpEditor> createState() => _EventRsvpEditorState();
}

class _EventRsvpEditorState extends State<_EventRsvpEditor> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestsController>();
    return Obx(() {
      final response = controller.responseFor(widget.guestId, widget.event.id);
      final status = response?.status ?? rsvpStatusPending;
      final attendeeCount = response?.attendeeCount ?? 0;
      final special = response?.specialRequirements ?? '';
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DashboardFormCard(
          children: [
            Text(
              widget.event.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: rsvpStatuses
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s, style: const TextStyle(fontSize: 11.5)),
                      selected: status == s,
                      selectedColor: ThemeColors.primary,
                      labelStyle: TextStyle(
                        color: status == s
                            ? Colors.white
                            : ThemeColors.logoDeep,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => controller.setRsvp(
                        guestId: widget.guestId,
                        eventId: widget.event.id,
                        status: s,
                        attendeeCount: attendeeCount,
                        specialRequirements: special,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey(
                      'attendees-${widget.event.id}-$attendeeCount',
                    ),
                    initialValue: attendeeCount == 0 ? '' : '$attendeeCount',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Attendee Count',
                      isDense: true,
                    ),
                    onFieldSubmitted: (value) => controller.setRsvp(
                      guestId: widget.guestId,
                      eventId: widget.event.id,
                      status: status,
                      attendeeCount: int.tryParse(value) ?? 0,
                      specialRequirements: special,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: ValueKey('special-${widget.event.id}-$special'),
              initialValue: special,
              decoration: const InputDecoration(
                labelText: 'Special Requirements',
                isDense: true,
              ),
              onFieldSubmitted: (value) => controller.setRsvp(
                guestId: widget.guestId,
                eventId: widget.event.id,
                status: status,
                attendeeCount: attendeeCount,
                specialRequirements: value,
              ),
            ),
          ],
        ),
      );
    });
  }
}
