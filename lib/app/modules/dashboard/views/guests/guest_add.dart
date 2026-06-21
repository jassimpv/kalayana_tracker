import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';

class GuestAddPage extends StatefulWidget {
  const GuestAddPage({super.key, this.existing});

  final Guest? existing;

  @override
  State<GuestAddPage> createState() => _GuestAddPageState();
}

class _GuestAddPageState extends State<GuestAddPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _whatsappController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagController;
  late String _side;
  late String _category;
  late int _numberInvited;
  late List<String> _tags;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final guest = widget.existing;
    _nameController = TextEditingController(text: guest?.name ?? '');
    _phoneController = TextEditingController(text: guest?.phone ?? '');
    _whatsappController = TextEditingController(text: guest?.whatsapp ?? '');
    _addressController = TextEditingController(text: guest?.address ?? '');
    _notesController = TextEditingController(text: guest?.notes ?? '');
    _tagController = TextEditingController();
    _side = guest?.side ?? guestSideBoth;
    _category = guest?.category ?? guestCategories.first;
    _numberInvited = guest?.numberInvited ?? 1;
    _tags = List.of(guest?.tags ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existing != null;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Name required', 'Please enter the guest\'s name.');
      return;
    }
    setState(() => _saving = true);
    final controller = Get.find<GuestsController>();
    final guest = (widget.existing ?? Guest(id: newGuestId())).copyWith(
      name: name,
      phone: _phoneController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      side: _side,
      category: _category,
      numberInvited: _numberInvited,
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      tags: _tags,
      updatedAt: DateTime.now(),
    );
    try {
      if (_isEditing) {
        await controller.updateGuest(guest);
      } else {
        await controller.addGuest(guest);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      Get.snackbar('Could not save guest', error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty || _tags.contains(tag)) return;
    setState(() {
      _tags.add(tag);
      _tagController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(_isEditing ? 'Edit Guest' : 'Add Guest'),
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
              : Text(_isEditing ? 'Save Changes' : 'Add Guest'),
        ),
        children: [
          DashboardFormCard(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Guest Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp Number (optional)',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashboardFormCard(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _side,
                decoration: const InputDecoration(labelText: 'Side'),
                items: guestSides
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (value) => setState(() => _side = value ?? _side),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: guestCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _category = value ?? _category),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Number Invited',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      if (_numberInvited > 1) _numberInvited--;
                    }),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    '$_numberInvited',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _numberInvited++),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          DashboardFormCard(
            children: [
              TextField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address (optional)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(labelText: 'Add tag'),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  IconButton(
                    onPressed: _addTag,
                    icon: Icon(Icons.add_circle, color: ThemeColors.primary),
                  ),
                ],
              ),
              if (_tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            onDeleted: () => setState(() => _tags.remove(tag)),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
