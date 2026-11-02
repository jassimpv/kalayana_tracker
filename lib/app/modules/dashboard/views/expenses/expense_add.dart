import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';
import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/invoice_scanner_card.dart';
import 'package:kalayanaexpresstracker/app/data/models/planning_entry.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
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
  final _otherPersonNameController = TextEditingController();

  String _category = expenseCategories.first;
  String _vendorId = '';
  DateTime? _dueDate;
  RepayPerson? _paidByPerson;
  bool _needsRepayment = false;
  bool _paidByOther = false;
  bool _isSaving = false;
  bool _isScanning = false;
  String _sourceShoppingItemId = '';
  String _sourceReminderId = '';
  ExpenseItem? _editingExpense;

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

    if (sourceType == 'edit') {
      final expense = controller.data.value.expenses.firstWhereOrNull(
        (entry) => entry.id == sourceId,
      );
      if (expense == null) return;
      _editingExpense = expense;
      _vendorId = expense.vendorId;
      _nameController.text = expense.name;
      _totalController.text = moneyText(expense.totalAmount);
      _paidController.text = moneyText(expense.paidAmount);
      _category = expenseCategories.contains(expense.category)
          ? expense.category
          : expenseCategories.first;
      _dueDate = expense.dueDate;
      _notesController.text = expense.notes;
      _sourceShoppingItemId = expense.sourceShoppingItemId;
      _sourceReminderId = expense.sourceReminderId;
      _paidByPerson = controller.repayPersons.firstWhereOrNull(
        (person) => person.id == expense.paidByPersonId,
      );
      _needsRepayment = expense.needsRepayment;
      final paidByPersonName = expense.paidByPersonName.trim();
      if (_paidByPerson == null &&
          paidByPersonName.isNotEmpty &&
          paidByPersonName.toLowerCase() != 'self') {
        _paidByOther = true;
        _otherPersonNameController.text = paidByPersonName;
      }
    } else if (sourceType == 'purchase') {
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
    _otherPersonNameController.dispose();
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
    try {
      var paidByPerson = _paidByPerson;
      var needsRepayment = _needsRepayment;
      if (_paidByOther) {
        paidByPerson = await controller.findOrCreateRepayPerson(
          _otherPersonNameController.text,
        );
        if (paidByPerson == null) {
          if (!mounted) return;
          setState(() => _isSaving = false);
          return;
        }
        needsRepayment = true;
      }

      final repaymentPerson = needsRepayment ? paidByPerson?.name ?? '' : '';

      final expense = buildExpense(
        existing: _editingExpense,
        name: _nameController.text,
        category: _category,
        total: _totalController.text,
        paid: _paidController.text,
        paidBy: paidByPerson?.name ?? '',
        paidByPersonId: paidByPerson?.id ?? '',
        paidByPersonName: paidByPerson?.name ?? '',
        repayPerson: repaymentPerson,
        needsRepayment: needsRepayment,
        repayAmount: '',
        dueDate: _dueDate,
        notes: _notesController.text,
        sourceShoppingItemId: _sourceShoppingItemId,
        sourceReminderId: _sourceReminderId,
      ).copyWith(vendorId: _vendorId);

      await controller.saveExpense(expense, expected: _editingExpense);
      if (_editingExpense == null && _sourceShoppingItemId.isNotEmpty) {
        await controller.linkPurchaseToExpense(
          _sourceShoppingItemId,
          expense.id,
        );
      } else if (_editingExpense == null && _sourceReminderId.isNotEmpty) {
        await controller.linkReminderToExpense(_sourceReminderId, expense.id);
      }
      if (!mounted) return;
      setState(() => _isSaving = false);
      controller.closeDashboardSubPage();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: LocalizedText('Unable to save: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get _repaymentToText {
    if (_paidByOther) {
      final name = _otherPersonNameController.text.trim();
      return name.isEmpty ? 'Enter person name' : name;
    }
    return _paidByPerson?.name ?? 'Self';
  }

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
            onPressed: _isSaving || _isScanning ? null : _saveExpense,
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
            label: LocalizedText(_isSaving ? 'Saving' : 'Save Expense'),
          ),
        ),
        children: [
          DashboardFormIntroCard(
            icon: Icons.payments_rounded,
            title: _editingExpense == null ? 'Add Expense' : 'Edit Expense',
            subtitle: _editingExpense != null
                ? 'Update this expense while keeping its payment history connected.'
                : _sourceShoppingItemId.isNotEmpty
                ? 'Review the prefilled details, then save to log this purchase as an expense.'
                : _sourceReminderId.isNotEmpty
                ? 'Review the prefilled details, then save to log this reminder as an expense.'
                : 'Track totals, paid amount, due date, and money owed.',
          ),
          const SizedBox(height: 12),
          InvoiceScannerCard(
            enabled: !_isSaving,
            onBusyChanged: (value) {
              if (mounted) setState(() => _isScanning = value);
            },
            onScanned: (invoice) => setState(() {
              _nameController.text = invoice.expenseName;
              _totalController.text = moneyText(invoice.totalAmount);
              _paidController.text = moneyText(
                invoice.paidAmount.clamp(0, invoice.totalAmount).toDouble(),
              );
              _notesController.text = invoice.billNotes;
              _category = expenseCategories.contains(invoice.category)
                  ? invoice.category
                  : expenseCategories.first;
              _dueDate = invoice.dueDate ?? invoice.invoiceDate;
            }),
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
                      decoration: const LocalizedInputDecoration(
                        labelText: 'Expense name',
                        prefixIcon: Icon(Icons.storefront_rounded),
                      ),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const LocalizedInputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                      items: expenseCategories
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: LocalizedText(value),
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
                      decoration: LocalizedInputDecoration(
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
                      decoration: const LocalizedInputDecoration(
                        labelText: 'Paid amount',
                        prefixIcon: Icon(Icons.payments_rounded),
                      ),
                      onChanged: (_) {
                        if (_needsRepayment || _paidByOther) setState(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    RepayPersonPicker(
                      selectedPersonId: _paidByPerson?.id,
                      helperText: 'Choose Self or the person who paid',
                      allowOther: true,
                      isOtherSelected: _paidByOther,
                      onChanged: (person) {
                        setState(() {
                          _paidByPerson = person;
                          _paidByOther = false;
                          if (person == null) _needsRepayment = false;
                        });
                      },
                      onOtherSelected: () {
                        setState(() {
                          _paidByPerson = null;
                          _paidByOther = true;
                          _needsRepayment = false;
                        });
                      },
                    ),
                    if (_paidByOther) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _otherPersonNameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const LocalizedInputDecoration(
                          labelText: 'Person name',
                          hintText: 'Enter person name',
                          prefixIcon: Icon(Icons.person_add_alt_1_rounded),
                        ),
                        validator: _required,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      _RepaymentAutoSummary(
                        repayTo: _repaymentToText,
                        amount: _repaymentAmountText,
                      ),
                    ],
                    if (_paidByPerson != null) ...[
                      const SizedBox(height: 8),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const LocalizedText('I owe this person'),
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
                          : formatDisplayDate(_dueDate!),
                      onTap: _pickDueDate,
                      onClear: _dueDate == null
                          ? null
                          : () => setState(() => _dueDate = null),
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final vendors = controller.data.value.entries(
                        PlanningKind.vendor,
                      );
                      return DropdownButtonFormField<String>(
                        initialValue:
                            vendors.any((entry) => entry.id == _vendorId)
                            ? _vendorId
                            : '',
                        decoration: const LocalizedInputDecoration(
                          labelText: 'Vendor',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: '',
                            child: LocalizedText('No vendor'),
                          ),
                          ...vendors.map(
                            (entry) => DropdownMenuItem(
                              value: entry.id,
                              child: Text(entry.name),
                            ),
                          ),
                        ],
                        onChanged: (value) => _vendorId = value ?? '',
                      );
                    }),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const LocalizedInputDecoration(
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
              LocalizedText(
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
    return TranslationService.translate('This field is required');
  }
  return null;
}
