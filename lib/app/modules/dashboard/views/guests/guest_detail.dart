import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final TextEditingController _attendeeController;
  late final TextEditingController _specialController;
  late final FocusNode _attendeeFocus;
  late final FocusNode _specialFocus;

  GuestsController get _ctrl => Get.find<GuestsController>();

  @override
  void initState() {
    super.initState();
    final response = _ctrl.responseFor(widget.guestId, widget.event.id);
    final count = response?.attendeeCount ?? 0;
    _attendeeController = TextEditingController(
      text: count == 0 ? '' : '$count',
    );
    _specialController = TextEditingController(
      text: response?.specialRequirements ?? '',
    );
    _attendeeFocus = FocusNode()..addListener(_onAttendeeFocusChanged);
    _specialFocus = FocusNode()..addListener(_onSpecialFocusChanged);
  }

  @override
  void dispose() {
    _attendeeController.dispose();
    _specialController.dispose();
    _attendeeFocus
      ..removeListener(_onAttendeeFocusChanged)
      ..dispose();
    _specialFocus
      ..removeListener(_onSpecialFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onAttendeeFocusChanged() {
    if (!_attendeeFocus.hasFocus) _saveAttendee();
  }

  void _onSpecialFocusChanged() {
    if (!_specialFocus.hasFocus) _saveSpecial();
  }

  void _saveAttendee() {
    final response = _ctrl.responseFor(widget.guestId, widget.event.id);
    _ctrl.setRsvp(
      guestId: widget.guestId,
      eventId: widget.event.id,
      status: response?.status ?? rsvpStatusPending,
      attendeeCount: int.tryParse(_attendeeController.text.trim()) ?? 0,
      specialRequirements: response?.specialRequirements ?? '',
    );
  }

  void _saveSpecial() {
    final response = _ctrl.responseFor(widget.guestId, widget.event.id);
    _ctrl.setRsvp(
      guestId: widget.guestId,
      eventId: widget.event.id,
      status: response?.status ?? rsvpStatusPending,
      attendeeCount: response?.attendeeCount ?? 0,
      specialRequirements: _specialController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final response = _ctrl.responseFor(widget.guestId, widget.event.id);
      final status = response?.status ?? rsvpStatusPending;
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
                      onSelected: (_) => _ctrl.setRsvp(
                        guestId: widget.guestId,
                        eventId: widget.event.id,
                        status: s,
                        attendeeCount:
                            int.tryParse(_attendeeController.text.trim()) ?? 0,
                        specialRequirements: _specialController.text.trim(),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _attendeeController,
              focusNode: _attendeeFocus,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Attendee Count',
                isDense: true,
              ),
              onSubmitted: (_) => _saveAttendee(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _specialController,
              focusNode: _specialFocus,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Special Requirements',
                isDense: true,
              ),
              onSubmitted: (_) => _saveSpecial(),
            ),
          ],
        ),
      );
    });
  }
}
