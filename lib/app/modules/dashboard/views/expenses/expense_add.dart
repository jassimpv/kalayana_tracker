import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/repay_person_picker.dart';

class ExpenseAddPage extends StatefulWidget {
  const ExpenseAddPage({super.key});

  @override
  State<ExpenseAddPage> createState() => _ExpenseAddPageState();
}

class _ExpenseAddPageState extends State<ExpenseAddPage> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalController = TextEditingController();
  final _paidController = TextEditingController();
  final _repayPersonController = TextEditingController();
  final _repayAmountController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = expenseCategories.first;
  DateTime? _dueDate;
  RepayPerson? _paidByPerson;
  bool _needsRepayment = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _paidController.dispose();
    _repayPersonController.dispose();
    _repayAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (result != null) {
      setState(() {
        _dueDate = result;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final expense = buildExpense(
      name: _nameController.text,
      category: _category,
      total: _totalController.text,
      paid: _paidController.text,
      paidBy: _paidByPerson?.name ?? '',
      paidByPersonId: _paidByPerson?.id ?? '',
      paidByPersonName: _paidByPerson?.name ?? '',
      repayPerson: _repayPersonController.text,
      needsRepayment: _needsRepayment,
      repayAmount: _repayAmountController.text,
      dueDate: _dueDate,
      notes: _notesController.text,
    );

    await controller.saveExpense(expense);
    if (!mounted) return;
    setState(() => _isSaving = false);
    controller.closeDashboardSubPage();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardFormPage(
      children: [
        const DashboardFormIntroCard(
          icon: Icons.payments_rounded,
          title: 'Add Expense',
          subtitle: 'Track totals, paid amount, due date, and repayments.',
        ),
        const SizedBox(height: 12),
        DashboardFormCard(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Expense name',
                      prefixIcon: Icon(Icons.storefront_rounded),
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
                    items: expenseCategories
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
                    controller: _totalController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Total amount',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _paidController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Paid amount',
                      prefixIcon: Icon(Icons.payments_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RepayPersonPicker(
                    selectedPersonId: _paidByPerson?.id,
                    onChanged: (person) {
                      setState(() => _paidByPerson = person);
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Needs repayment'),
                    value: _needsRepayment,
                    onChanged: (value) {
                      setState(() => _needsRepayment = value);
                    },
                  ),
                  if (_needsRepayment) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _repayPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Repayment person',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _repayAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Repayment amount',
                        prefixIcon: Icon(Icons.monetization_on_rounded),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  DashboardDatePickerTile(
                    icon: Icons.calendar_today_rounded,
                    title: 'Due date',
                    value: _dueDate == null
                        ? 'Choose due date'
                        : formatDate(_dueDate!),
                    onTap: _pickDueDate,
                    onClear: _dueDate == null
                        ? null
                        : () => setState(() => _dueDate = null),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesController,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.note_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 50,
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _saveExpense,
            icon: _isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving' : 'Save Expense'),
          ),
        ),
      ],
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}
