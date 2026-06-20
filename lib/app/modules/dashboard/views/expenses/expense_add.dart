import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/repay_person_picker.dart';

class ExpenseAddPage extends StatefulWidget {
  const ExpenseAddPage({super.key, this.sourceArgument});

  /// Encodes the record this expense should be created from, in the form
  /// `purchase:<id>` or `reminder:<id>`. Null for a plain, blank expense.
  final String? sourceArgument;

  @override
  State<ExpenseAddPage> createState() => _ExpenseAddPageState();
}

class _ExpenseAddPageState extends State<ExpenseAddPage> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _totalController = TextEditingController();
  final _paidController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = expenseCategories.first;
  DateTime? _dueDate;
  RepayPerson? _paidByPerson;
  bool _needsRepayment = false;
  bool _isSaving = false;
  String _sourceShoppingItemId = '';
  String _sourceReminderId = '';

  @override
  void initState() {
    super.initState();
    _applySourcePrefill();
  }

  void _applySourcePrefill() {
    final argument = widget.sourceArgument;
    if (argument == null) return;
    final separatorIndex = argument.indexOf(':');
    if (separatorIndex == -1) return;
    final sourceType = argument.substring(0, separatorIndex);
    final sourceId = argument.substring(separatorIndex + 1);

    if (sourceType == 'purchase') {
      final purchase = controller.data.value.purchases.firstWhereOrNull(
        (entry) => entry.id == sourceId,
      );
      if (purchase == null) return;
      _nameController.text = purchase.name;
      if (purchase.amount > 0) {
        _totalController.text = moneyText(purchase.amount);
      }
      _category = expenseCategories.contains(purchase.category)
          ? purchase.category
          : 'Shopping';
      _dueDate = DateTime.now();
      _notesController.text = 'Created from shopping list item';
      _sourceShoppingItemId = purchase.id;
    } else if (sourceType == 'reminder') {
      final reminder = controller.data.value.reminders.firstWhereOrNull(
        (entry) => entry.id == sourceId,
      );
      if (reminder == null) return;
      _nameController.text = reminder.title;
      if (reminder.amount > 0) {
        _totalController.text = moneyText(reminder.amount);
      }
      _dueDate = reminder.dueDate;
      _notesController.text = 'Created from reminder';
      _sourceReminderId = reminder.id;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalController.dispose();
    _paidController.dispose();
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
    final repaymentPerson = _needsRepayment ? _paidByPerson?.name ?? '' : '';

    final expense = buildExpense(
      name: _nameController.text,
      category: _category,
      total: _totalController.text,
      paid: _paidController.text,
      paidBy: _paidByPerson?.name ?? '',
      paidByPersonId: _paidByPerson?.id ?? '',
      paidByPersonName: _paidByPerson?.name ?? '',
      repayPerson: repaymentPerson,
      needsRepayment: _needsRepayment,
      repayAmount: '',
      dueDate: _dueDate,
      notes: _notesController.text,
      sourceShoppingItemId: _sourceShoppingItemId,
      sourceReminderId: _sourceReminderId,
    );

    await controller.saveExpense(expense);
    if (_sourceShoppingItemId.isNotEmpty) {
      await controller.linkPurchaseToExpense(
        _sourceShoppingItemId,
        expense.id,
      );
    } else if (_sourceReminderId.isNotEmpty) {
      await controller.linkReminderToExpense(_sourceReminderId, expense.id);
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    controller.closeDashboardSubPage();
  }

  String get _repaymentToText => _paidByPerson?.name ?? 'Self';

  String get _repaymentAmountText {
    final paidAmount = moneyFromText(_paidController.text);
    if (paidAmount == null || paidAmount <= 0) {
      return 'Enter the amount';
    }

    return moneyOrDash(paidAmount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: DashboardFormPage(
        footer: SizedBox(
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
        children: [
          DashboardFormIntroCard(
            icon: Icons.payments_rounded,
            title: 'Add Expense',
            subtitle: _sourceShoppingItemId.isNotEmpty
                ? 'Review the prefilled details, then save to log this purchase as an expense.'
                : _sourceReminderId.isNotEmpty
                ? 'Review the prefilled details, then save to log this reminder as an expense.'
                : 'Track totals, paid amount, due date, and money owed.',
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
                      decoration: InputDecoration(
                        labelText: 'Total amount',
                        prefixIcon: Icon(AppConfig.appCurrencyIcon),
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
                      onChanged: (_) {
                        if (_needsRepayment) setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    RepayPersonPicker(
                      selectedPersonId: _paidByPerson?.id,
                      helperText: 'Choose Self or the person who paid',
                      onChanged: (person) {
                        setState(() {
                          _paidByPerson = person;
                          if (person == null) _needsRepayment = false;
                        });
                      },
                    ),
                    if (_paidByPerson != null) ...[
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('I owe this person'),
                          value: _needsRepayment,
                          onChanged: (value) =>
                              setState(() => _needsRepayment = value),
                        ),
                      ),
                      if (_needsRepayment) ...[
                        const SizedBox(height: 8),
                        _RepaymentAutoSummary(
                          repayTo: _repaymentToText,
                          amount: _repaymentAmountText,
                        ),
                      ],
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
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepaymentAutoSummary extends StatelessWidget {
  const _RepaymentAutoSummary({required this.repayTo, required this.amount});

  final String repayTo;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RepaymentAutoRow(
            icon: Icons.assignment_return_rounded,
            label: 'I owe',
            value: repayTo,
          ),
          const SizedBox(height: 10),
          _RepaymentAutoRow(
            icon: Icons.monetization_on_rounded,
            label: 'Amount owed',
            value: amount,
          ),
        ],
      ),
    );
  }
}

class _RepaymentAutoRow extends StatelessWidget {
  const _RepaymentAutoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: scheme.primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: scheme.outline,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
