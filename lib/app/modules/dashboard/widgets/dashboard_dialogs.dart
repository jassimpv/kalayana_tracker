import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/currency_symbols.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/repay_person_picker.dart';
import 'package:kalayanaexpresstracker/gemini.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showExpenseDialog(
  BuildContext context, {
  ExpenseItem? item,
}) async {
  final controller = Get.find<DashboardController>();
  final name = TextEditingController(text: item?.name ?? '');
  final total = TextEditingController(text: moneyText(item?.totalAmount));
  final paid = TextEditingController(text: moneyText(item?.paidAmount));
  final repayPerson = TextEditingController(text: item?.repayPerson ?? '');
  final repayAmount = TextEditingController(text: moneyText(item?.repayAmount));
  final notes = TextEditingController(text: item?.notes ?? '');
  RepayPerson? paidByPerson = item == null
      ? null
      : controller.repayPersons.firstWhereOrNull(
          (person) => person.id == item.paidByPersonId,
        );
  var category = expenseCategories.contains(item?.category)
      ? item!.category
      : expenseCategories.first;
  var dueDate = item?.dueDate;
  var needsRepayment = item?.needsRepayment ?? false;
  var scanningInvoice = false;
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _PlannerDialog(
        icon: Icons.payments_rounded,
        title: item == null ? 'Add expense' : 'Edit expense',
        subtitle: 'Track totals, payments, due dates, and repayment.',
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await controller.saveExpense(
                buildExpense(
                  existing: item,
                  name: name.text,
                  category: category,
                  total: total.text,
                  paid: paid.text,
                  paidBy: paidByPerson?.name ?? item?.paidBy ?? '',
                  paidByPersonId:
                      paidByPerson?.id ?? item?.paidByPersonId ?? '',
                  paidByPersonName:
                      paidByPerson?.name ?? item?.paidByPersonName ?? '',
                  repayPerson: repayPerson.text,
                  needsRepayment: needsRepayment,
                  repayAmount: repayAmount.text,
                  dueDate: dueDate,
                  notes: notes.text,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item == null) ...[
                _InvoiceScanPanel(
                  loading: scanningInvoice,
                  onCamera: () => _scanInvoice(
                    context,
                    setState,
                    ImageSource.camera,
                    setLoading: (value) => scanningInvoice = value,
                    name: name,
                    total: total,
                    paid: paid,
                    notes: notes,
                    updateCategory: (value) => category = value,
                    updateDueDate: (value) => dueDate = value,
                  ),
                  onGallery: () => _scanInvoice(
                    context,
                    setState,
                    ImageSource.gallery,
                    setLoading: (value) => scanningInvoice = value,
                    name: name,
                    total: total,
                    paid: paid,
                    notes: notes,
                    updateCategory: (value) => category = value,
                    updateDueDate: (value) => dueDate = value,
                  ),
                ),
                const SizedBox(height: 14),
              ],
              TextFormField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Expense name',
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                validator: _required,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                key: ValueKey(category),
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: expenseCategories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => category = value ?? category,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: total,
                decoration: const InputDecoration(
                  labelText: 'Total amount',
                  prefixIcon: Icon(Icons.account_balance_wallet_rounded),
                ),
                keyboardType: TextInputType.number,
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: paid,
                decoration: const InputDecoration(
                  labelText: 'Paid amount',
                  prefixIcon: Icon(Icons.paid_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              RepayPersonPicker(
                selectedPersonId: paidByPerson?.id ?? item?.paidByPersonId,
                onChanged: (person) => setState(() => paidByPerson = person),
              ),
              const SizedBox(height: 14),
              Material(
                color: Colors.transparent,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Need to repay someone'),
                  value: needsRepayment,
                  onChanged: (value) => setState(() => needsRepayment = value),
                ),
              ),
              if (needsRepayment) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: repayPerson,
                  decoration: const InputDecoration(
                    labelText: 'Need to repay person',
                    prefixIcon: Icon(Icons.person_add_alt_1_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: repayAmount,
                  decoration: InputDecoration(
                    labelText: 'Repay amount',
                    prefixIcon: Icon(AppConfig.appCurrencyIcon),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
              const SizedBox(height: 14),
              _DatePickerTile(
                icon: Icons.event_rounded,
                title: 'Due date',
                value: dueDate == null ? 'Not set' : formatDate(dueDate!),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _scanInvoice(
  BuildContext context,
  void Function(void Function()) setState,
  ImageSource source, {
  required void Function(bool value) setLoading,
  required TextEditingController name,
  required TextEditingController total,
  required TextEditingController paid,
  required TextEditingController notes,
  required void Function(String value) updateCategory,
  required void Function(DateTime? value) updateDueDate,
}) async {
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: 82,
    maxWidth: 1600,
  );
  if (picked == null) return;

  setState(() => setLoading(true));
  try {
    final invoice = await GeminiInovieAppData().extractInvoice(
      await picked.readAsBytes(),
    );
    if (!invoice.isInvoice) {
      throw const FormatException(
        'The selected image does not look like a bill.',
      );
    }
    final category = expenseCategories.contains(invoice.category)
        ? invoice.category
        : expenseCategories.first;
    setState(() {
      name.text = invoice.expenseName;
      total.text = moneyText(invoice.totalAmount);
      paid.text = invoice.paidAmount <= invoice.totalAmount
          ? moneyText(invoice.paidAmount)
          : moneyText(invoice.totalAmount);
      notes.text = invoice.billNotes;
      updateCategory(category);
      updateDueDate(invoice.dueDate ?? invoice.invoiceDate);
    });
    if (!context.mounted) return;
    Get.snackbar(
      'Invoice scanned',
      'Review the bill details, then tap Save.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  } catch (error) {
    if (!context.mounted) return;
    Get.snackbar(
      'Invoice scan failed',
      error.toString(),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  } finally {
    setState(() => setLoading(false));
  }
}

class _InvoiceScanPanel extends StatelessWidget {
  const _InvoiceScanPanel({
    required this.loading,
    required this.onCamera,
    required this.onGallery,
  });

  final bool loading;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner_rounded, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loading ? 'Reading invoice...' : 'Scan invoice to fill bill',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (loading)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: loading ? null : onCamera,
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Camera'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: loading ? null : onGallery,
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> showAddExpensePaymentDialog(
  BuildContext context, {
  required ExpenseItem item,
}) async {
  final controller = Get.find<DashboardController>();
  final amount = TextEditingController(text: moneyText(item.pendingForSummary));
  final notes = TextEditingController();
  RepayPerson? paidByPerson;
  var date = DateTime.now();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _PlannerDialog(
        icon: Icons.add_card_rounded,
        title: 'Add payment',
        subtitle: item.name,
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final saved = await controller.addExpensePayment(
                item,
                amount: moneyFromText(amount.text) ?? 0,
                paidByPersonId: paidByPerson?.id ?? '',
                paidByPersonName: paidByPerson?.name ?? 'Self',
                date: date,
                notes: notes.text,
              );
              if (context.mounted && saved) Navigator.pop(context);
            },
            child: const Text('Save payment'),
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amount,
                decoration: InputDecoration(
                  labelText: 'Payment amount',
                  prefixIcon: Icon(AppConfig.appCurrencyIcon),
                ),
                keyboardType: TextInputType.number,
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
              const SizedBox(height: 14),
              RepayPersonPicker(
                selectedPersonId: paidByPerson?.id,
                onChanged: (person) => setState(() => paidByPerson = person),
              ),
              const SizedBox(height: 14),
              _DatePickerTile(
                icon: Icons.calendar_month_rounded,
                title: 'Payment date',
                value: formatDate(date),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) setState(() => date = picked);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Payment notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                  hintText: 'Transfer ref, cash note, installment detail...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showReminderDialog(
  BuildContext context, {
  EventReminder? reminder,
}) async {
  final controller = Get.find<DashboardController>();
  final title = TextEditingController(text: reminder?.title ?? '');
  var category = reminder?.category ?? reminderCategories.first;
  var dueDate = reminder?.dueDate ?? DateTime.now();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _PlannerDialog(
        icon: Icons.event_available_rounded,
        title: reminder == null ? 'Add reminder' : 'Edit reminder',
        subtitle: 'Keep important dates easy to follow.',
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await controller.saveReminder(
                buildReminder(
                  existing: reminder,
                  title: title.text,
                  category: category,
                  dueDate: dueDate,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _DialogIntroCard(
                icon: Icons.event_note_rounded,
                title: 'Reminder details',
                subtitle: 'Set the title, category, and due date.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: 'Reminder title',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: reminderCategories.contains(category)
                    ? category
                    : reminderCategories.first,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: reminderCategories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => category = value ?? category,
              ),
              const SizedBox(height: 12),
              _DatePickerTile(
                icon: Icons.calendar_month_rounded,
                title: 'Due date',
                value: formatDate(dueDate),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showPurchaseDialog(
  BuildContext context, {
  PurchaseItem? purchase,
}) async {
  final controller = Get.find<DashboardController>();
  final name = TextEditingController(text: purchase?.name ?? '');
  final savedCategory = purchase?.category;
  var category = purchaseCategories.contains(savedCategory)
      ? savedCategory!
      : purchaseCategories.first;
  final amount = TextEditingController(
    text: purchase != null && purchase.amount > 0
        ? moneyText(purchase.amount)
        : '',
  );
  final note = TextEditingController(text: purchase?.note ?? '');
  var status = purchase?.status ?? purchaseStatuses.first;
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => _PlannerDialog(
      icon: Icons.shopping_bag_rounded,
      title: purchase == null ? 'Add purchase' : 'Edit purchase',
      subtitle: 'Keep shopping items organized and clear.',
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            await controller.savePurchase(
              buildPurchase(
                existing: purchase,
                name: name.text,
                category: category,
                amount: amount.text,
                status: status,
                note: note.text,
              ),
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _DialogIntroCard(
              icon: Icons.shopping_bag_rounded,
              title: 'Shopping item',
              subtitle: 'Add the item, category, amount, status, and note.',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                labelText: 'Item name',
                prefixIcon: Icon(Icons.shopping_basket_rounded),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: purchaseCategories
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => category = value ?? category,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: amount,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(AppConfig.appCurrencyIcon),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: purchaseStatuses.contains(status)
                  ? status
                  : purchaseStatuses.first,
              decoration: const InputDecoration(
                labelText: 'Status',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              items: purchaseStatuses
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => status = value ?? status,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: note,
              decoration: const InputDecoration(
                labelText: 'Note',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showMarkPurchasedDialog(
  BuildContext context, {
  required PurchaseItem purchase,
}) async {
  final controller = Get.find<DashboardController>();
  final amount = TextEditingController(
    text: purchase.amount > 0 ? moneyText(purchase.amount) : '',
  );
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => _PlannerDialog(
      icon: Icons.check_circle_rounded,
      title: 'Mark as purchased',
      subtitle: purchase.name.isEmpty ? 'Shopping item' : purchase.name,
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            await controller.markPurchased(
              purchase,
              amount: moneyFromText(amount.text) ?? 0,
            );
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
      child: Form(
        key: formKey,
        child: TextFormField(
          controller: amount,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Amount paid',
            prefixIcon: Icon(AppConfig.appCurrencyIcon),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            final requiredError = _required(value);
            if (requiredError != null) return requiredError;
            final parsed = moneyFromText(value ?? '') ?? 0;
            if (parsed <= 0) return 'Enter an amount above zero';
            return null;
          },
        ),
      ),
    ),
  );
}

Future<void> showConvertPurchaseToExpenseDialog(
  BuildContext context, {
  required PurchaseItem purchase,
}) async {
  final controller = Get.find<DashboardController>();
  final total = TextEditingController();
  final paid = TextEditingController();
  final notes = TextEditingController(
    text: purchase.note.trim().isEmpty
        ? 'Converted from shopping list'
        : '${purchase.note.trim()}\nConverted from shopping list',
  );
  var category = expenseCategories.contains(purchase.category)
      ? purchase.category
      : expenseCategories.first;
  RepayPerson? paidByPerson;
  var dueDate = DateTime.now();
  final formKey = GlobalKey<FormState>();

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _PlannerDialog(
        icon: Icons.receipt_long_rounded,
        title: 'Convert to expense',
        subtitle: 'Add the bill amount and move this item into expenses.',
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await controller.convertPurchaseToExpense(
                purchase: purchase,
                expense: buildExpense(
                  name: purchase.name,
                  category: category,
                  total: total.text,
                  paid: paid.text,
                  paidBy: paidByPerson?.name ?? '',
                  paidByPersonId: paidByPerson?.id ?? '',
                  paidByPersonName: paidByPerson?.name ?? '',
                  repayPerson: '',
                  needsRepayment: false,
                  repayAmount: '',
                  dueDate: dueDate,
                  notes: notes.text,
                ),
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Convert'),
          ),
        ],
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: purchase.name,
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  prefixIcon: Icon(Icons.shopping_bag_rounded),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(
                  labelText: 'Expense category',
                  prefixIcon: Icon(Icons.category_rounded),
                ),
                items: expenseCategories
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) => category = value ?? category,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: total,
                decoration: InputDecoration(
                  labelText: 'Bill amount',
                  prefixIcon: Icon(AppConfig.appCurrencyIcon),
                ),
                keyboardType: TextInputType.number,
                validator: _required,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: paid,
                decoration: const InputDecoration(
                  labelText: 'Paid amount',
                  prefixIcon: Icon(Icons.paid_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              RepayPersonPicker(
                selectedPersonId: paidByPerson?.id,
                onChanged: (person) => setState(() => paidByPerson = person),
              ),
              const SizedBox(height: 14),
              _DatePickerTile(
                icon: Icons.event_rounded,
                title: 'Due date',
                value: formatDate(dueDate),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dueDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2040),
                  );
                  if (picked != null) setState(() => dueDate = picked);
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: notes,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showProfileDialog(BuildContext context) async {
  final controller = Get.find<DashboardController>();
  final groom = TextEditingController(text: profileGroom(controller.profile));
  final bride = TextEditingController(text: profileBride(controller.profile));
  var weddingDate = profileMarriageDate(controller.profile);
  var currency = profileCurrency(controller.profile);

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => _PlannerDialog(
        icon: Icons.favorite_rounded,
        title: 'Wedding details',
        subtitle: 'Keep names and the wedding date synced.',
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await controller.saveProfile(
                groom: groom.text,
                bride: bride.text,
                weddingDate: weddingDate,
                currency: currency,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dialogLabel('Couple names'),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: groom,
                    decoration: const InputDecoration(
                      hintText: 'Groom',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: bride,
                    decoration: const InputDecoration(
                      hintText: 'Bride',
                      prefixIcon: Icon(Icons.person_2_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _dialogLabel('Wedding date'),
            const SizedBox(height: 6),
            _DatePickerTile(
              icon: Icons.calendar_month_rounded,
              title: weddingDate == null
                  ? 'Select date'
                  : formatDate(weddingDate!),
              value: weddingDate == null
                  ? 'Tap to set your wedding date'
                  : 'Tap to change',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: weddingDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2040),
                );
                if (picked != null) setState(() => weddingDate = picked);
              },
            ),
            const SizedBox(height: 14),
            _dialogLabel('Currency'),
            const SizedBox(height: 6),
            _DatePickerTile(
              icon: AppConfig.appCurrencyIcon,
              title: '${currency.code}  ${currency.symbol}  ${currency.name}',
              value: 'Tap to change currency',
              onTap: () async {
                final selected = await showCurrencySelectionDialog(
                  context,
                  selectedCode: currency.code,
                );
                if (selected != null) setState(() => currency = selected);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Future<CurrencyOption?> showCurrencySelectionDialog(
  BuildContext context, {
  required String selectedCode,
}) async {
  final search = TextEditingController();
  var results = CurrencySymbolApi.options;

  final selected = await showDialog<CurrencyOption>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Select currency'),
        content: SizedBox(
          width: double.maxFinite,
          height: 420,
          child: Column(
            children: [
              TextField(
                controller: search,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Search currency',
                  hintText: 'USD, Euro, ₹',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
                onChanged: (value) {
                  setState(() => results = CurrencySymbolApi.search(value));
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final option = results[index];
                    final selected = option.code == selectedCode;
                    return ListTile(
                      dense: true,
                      leading: Text(
                        option.symbol,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      title: Text('${option.code}  ${option.name}'),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: ThemeColors.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, option),
                    );
                  },
                  separatorBuilder: (_, _) => const Divider(height: 1),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    ),
  );
  return selected;
}

Widget _dialogLabel(String text) {
  return Text(
    text,
    style: TextStyle(
      color: ThemeColors.onSurfaceSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _PlannerDialog extends StatelessWidget {
  const _PlannerDialog({
    required this.icon,
    required this.title,
    required this.actions,
    required this.child,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: ThemeColors.surfaceGradient is LinearGradient
                ? ThemeColors.surfaceGradient as LinearGradient
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.surface, ThemeColors.inputBackground],
                  ),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: ThemeColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.24),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.05,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.outline,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                  child: child,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var index = 0; index < actions.length; index++) ...[
                      if (index > 0) const SizedBox(width: 10),
                      actions[index],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogIntroCard extends StatelessWidget {
  const _DialogIntroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ThemeColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  const _DatePickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.84),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
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
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: scheme.outline, size: 20),
          ],
        ),
      ),
    );
  }
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Required' : null;
