import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_event.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';

class EventAddPage extends StatefulWidget {
  const EventAddPage({super.key, this.existing});

  final WeddingEvent? existing;

  @override
  State<EventAddPage> createState() => _EventAddPageState();
}

class _EventAddPageState extends State<EventAddPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late final TextEditingController _notesController;
  late String _type;
  DateTime? _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final event = widget.existing;
    _type = event?.type ?? weddingEventTypes.first;
    _nameController = TextEditingController(text: event?.name ?? _type);
    _venueController = TextEditingController(text: event?.venue ?? '');
    _notesController = TextEditingController(text: event?.notes ?? '');
    _date = event?.date;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Name required', 'Please enter an event name.');
      return;
    }
    setState(() => _saving = true);
    final controller = Get.find<GuestsController>();
    final event = (widget.existing ?? WeddingEvent(id: newEventId())).copyWith(
      name: name,
      type: _type,
      date: _date,
      venue: _venueController.text.trim(),
      notes: _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );
    try {
      if (_isEditing) {
        await controller.updateEvent(event);
      } else {
        await controller.addEvent(event);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      Get.snackbar('Could not save event', error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Edit Event' : 'Add Event'),
      ),
      body: DashboardFormPage(
        footer: FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: ThemeColors.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          child: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(_isEditing ? 'Save Changes' : 'Add Event'),
        ),
        children: [
          DashboardFormCard(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Event Type'),
                items: weddingEventTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _type = value;
                    if (weddingEventTypes
                        .where((t) => t != 'Custom')
                        .contains(_nameController.text.trim())) {
                      _nameController.text = value;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              const SizedBox(height: 12),
              DashboardDatePickerTile(
                icon: Icons.calendar_today_rounded,
                title: 'Event Date',
                value: _date == null
                    ? 'Not set'
                    : '${_date!.day}/${_date!.month}/${_date!.year}',
                onTap: _pickDate,
                onClear: _date == null ? null : () => setState(() => _date = null),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashboardFormCard(
            children: [
              TextField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
