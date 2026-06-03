import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class ExpensePaymentAddPage extends StatefulWidget {
  const ExpensePaymentAddPage({super.key, required this.expenseId});

  final String? expenseId;

  @override
  State<ExpensePaymentAddPage> createState() => _ExpensePaymentAddPageState();
}

class _ExpensePaymentAddPageState extends State<ExpensePaymentAddPage> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _paidByController = TextEditingController(text: 'Self');
  final _notesController = TextEditingController();

  DateTime _paymentDate = DateTime.now();
  String? _initializedExpenseId;
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _paidByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _ensureInitialAmount(ExpenseItem item) {
    if (_initializedExpenseId == item.id) return;
    _initializedExpenseId = item.id;
    _amountController.text = moneyText(item.pendingForSummary);
  }

  Future<void> _pickPaymentDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );
    if (result != null) {
      setState(() => _paymentDate = result);
    }
  }

  Future<void> _savePayment(ExpenseItem item) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await controller.addExpensePayment(
      item,
      amount: moneyFromText(_amountController.text) ?? 0,
      paidBy: _paidByController.text,
      date: _paymentDate,
      notes: _notesController.text,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    controller.closeDashboardSubPage();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.data.value.expenses.firstWhereOrNull(
        (entry) => entry.id == widget.expenseId,
      );

      if (item == null) {
        return const DashboardFormPage(
          children: [
            PremiumEmptyState(
              icon: Icons.account_balance_wallet_rounded,
              title: 'Expense not found',
              subtitle: 'This expense may have been deleted.',
            ),
          ],
        );
      }

      _ensureInitialAmount(item);

      return DashboardFormPage(
        children: [
          DashboardFormIntroCard(
            icon: Icons.add_card_rounded,
            title: 'Add Payment',
            subtitle:
                '${item.name.isEmpty ? 'Expense' : item.name} | ${moneyOrDash(item.pendingForSummary)} pending',
          ),
          const SizedBox(height: 12),
          DashboardFormCard(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Payment amount',
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                      ),
                      validator: (value) {
                        final requiredError = _required(value);
                        if (requiredError != null) return requiredError;
                        final parsed = moneyFromText(value ?? '') ?? 0;
                        if (parsed <= 0) return 'Enter an amount above zero';
                        if (parsed > item.pendingForSummary) {
                          return 'Cannot exceed pending balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _paidByController,
                      decoration: const InputDecoration(
                        labelText: 'Paid by',
                        prefixIcon: Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DashboardDatePickerTile(
                      icon: Icons.calendar_month_rounded,
                      title: 'Payment date',
                      value: formatDate(_paymentDate),
                      onTap: _pickPaymentDate,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Payment notes',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.notes_rounded),
                        hintText: 'Transfer ref, cash note...',
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
              onPressed: _isSaving ? null : () => _savePayment(item),
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
              label: Text(_isSaving ? 'Saving' : 'Save Payment'),
            ),
          ),
        ],
      );
    });
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}
