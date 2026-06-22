import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/event_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_detail.dart';

class RemindersTab extends GetView<GuestsController> {
  const RemindersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.events.isEmpty) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
          child: Align(
            alignment: Alignment.topCenter,
            child: _ReminderEmptyState(
              icon: CupertinoIcons.calendar_badge_plus,
              title: 'No wedding events yet',
              subtitle: 'Add an event first to send RSVP reminders.',
              actionLabel: 'Add Event',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EventAddPage())),
            ),
          ),
        );
      }
      final eventId =
          controller.selectedEventId.value ?? controller.events.first.id;
      final event = controller.events.firstWhereOrNull((e) => e.id == eventId);
      final pending = controller.pendingFor(eventId);
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: _ReminderHeaderPanel(
              eventId: eventId,
              pendingCount: pending.length,
              onBulkSend: pending.isEmpty || event == null
                  ? null
                  : () => _confirmBulkSend(context, pending, event),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: pending.isEmpty
                ? SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _ReminderEmptyState(
                        icon: CupertinoIcons.checkmark_circle,
                        title: 'No pending reminders',
                        subtitle: 'Everyone has responded for this event.',
                        actionLabel: 'View Guests',
                        onTap: () => controller.tabIndex.value = 1,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                    itemCount: pending.length,
                    itemBuilder: (context, index) =>
                        _ReminderRow(guest: pending[index], event: event!),
                  ),
          ),
        ],
      );
    });
  }

  Future<void> _confirmBulkSend(
    BuildContext context,
    List<Guest> guests,
    WeddingEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send bulk reminders'),
        content: Text(
          'This will open WhatsApp for each of the ${guests.length} pending guest(s) one by one. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await Get.find<GuestsController>().sendBulkReminders(guests, event);
    }
  }
}

class _ReminderEmptyState extends StatelessWidget {
  const _ReminderEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
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
          Icon(icon, color: ThemeColors.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF78656A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _ReminderSurfaceCard extends StatelessWidget {
  const _ReminderSurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReminderHeaderPanel extends GetView<GuestsController> {
  const _ReminderHeaderPanel({
    required this.eventId,
    required this.pendingCount,
    required this.onBulkSend,
  });

  final String eventId;
  final int pendingCount;
  final VoidCallback? onBulkSend;

  @override
  Widget build(BuildContext context) {
    return _ReminderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            initialValue: eventId,
            icon: Icon(
              CupertinoIcons.chevron_down,
              color: ThemeColors.primary.withValues(alpha: 0.72),
              size: 18,
            ),
            decoration: InputDecoration(
              labelText: 'Event',
              labelStyle: TextStyle(
                color: ThemeColors.logoDeep.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: Icon(
                CupertinoIcons.calendar,
                color: ThemeColors.primary.withValues(alpha: 0.72),
                size: 20,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: ThemeColors.primary.withValues(alpha: 0.42),
                ),
              ),
            ),
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            items: controller.events
                .map((e) => DropdownMenuItem(value: e.id, child: Text(e.name)))
                .toList(),
            onChanged: (value) {
              if (value != null) controller.selectedEventId.value = value;
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ThemeColors.primary.withValues(alpha: 0.10),
                ),
                alignment: Alignment.center,
                child: Icon(
                  CupertinoIcons.bell_fill,
                  color: ThemeColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount pending',
                      style: const TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      pendingCount == 0
                          ? 'No reminders to send'
                          : 'Guest(s) yet to RSVP for this event',
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.56),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onBulkSend,
              style: FilledButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                disabledBackgroundColor: ThemeColors.primary.withValues(
                  alpha: 0.3,
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text(
                'Send Bulk Reminders',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.guest, required this.event});

  final Guest guest;
  final WeddingEvent event;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GuestsController>();
    final hasPhone = guest.effectiveWhatsapp.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GuestDetailPage(guestId: guest.id)),
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
                child: Text(
                  guest.name.isEmpty ? '?' : guest.name[0].toUpperCase(),
                  style: TextStyle(
                    color: ThemeColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
                      guest.name.isEmpty ? 'Unnamed guest' : guest.name,
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
                        _ReminderTag(
                          text: hasPhone
                              ? guest.effectiveWhatsapp
                              : 'No phone number',
                          warning: !hasPhone,
                        ),
                        const _ReminderTag(text: 'Pending', highlighted: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _RoundIconButton(
                tooltip: 'Copy message',
                icon: FontAwesomeIcons.copy,
                background: ThemeColors.logoGold.withValues(alpha: 0.12),
                iconColor: ThemeColors.logoDeep,
                onPressed: () => controller.copyReminderMessage(guest, event),
              ),
              const SizedBox(width: 8),
              if (hasPhone)
                _RoundIconButton(
                  tooltip: 'Send via WhatsApp',
                  icon: FontAwesomeIcons.whatsapp,
                  background: hasPhone
                      ? const Color(0xFF25D366).withValues(alpha: 0.14)
                      : Colors.grey.withValues(alpha: 0.1),
                  iconColor: hasPhone ? const Color(0xFF128C3F) : Colors.grey,
                  onPressed: hasPhone
                      ? () => controller.sendWhatsAppReminder(guest, event)
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTag extends StatelessWidget {
  const _ReminderTag({
    required this.text,
    this.highlighted = false,
    this.warning = false,
  });

  final String text;
  final bool highlighted;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final color = warning
        ? const Color(0xFFA90B3D)
        : highlighted
        ? ThemeColors.primary
        : ThemeColors.logoDeep;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: warning
            ? const Color(0xFFFFE5EC)
            : highlighted
            ? ThemeColors.primary.withValues(alpha: 0.1)
            : ThemeColors.logoGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.onPressed,
  });

  final String tooltip;
  final FaIconData icon;
  final Color background;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: FaIcon(icon, size: 17, color: iconColor),
          ),
        ),
      ),
    );
  }
}
