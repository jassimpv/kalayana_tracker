import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';

class ReminderAddPage extends StatefulWidget {
  const ReminderAddPage({super.key});

  @override
  State<ReminderAddPage> createState() => _ReminderAddPageState();
}

class _ReminderAddPageState extends State<ReminderAddPage> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String _category = reminderCategories.first;
  DateTime _dueDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (result != null) {
      setState(() => _dueDate = result);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await controller.saveReminder(
      buildReminder(
        title: _titleController.text,
        category: _category,
        dueDate: _dueDate,
        amount: _amountController.text,
      ),
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    controller.closeDashboardSubPage();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardFormPage(
      footer: SizedBox(
        height: 50,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _saveReminder,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_rounded),
          label: Text(_isSaving ? 'Saving' : 'Save Reminder'),
        ),
      ),
      children: [
        const DashboardFormIntroCard(
          icon: Icons.event_available_rounded,
          title: 'Add Reminder',
          subtitle: 'Keep important dates and payment follow-ups visible.',
        ),
        const SizedBox(height: 12),
        DashboardFormCard(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Reminder title',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_rounded),
                    ),
                    items: reminderCategories
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _category = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount (optional)',
                      prefixIcon: Icon(AppConfig.appCurrencyIcon),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DashboardDatePickerTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'Due date',
                    value: formatDate(_dueDate),
                    onTap: _pickDueDate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}
