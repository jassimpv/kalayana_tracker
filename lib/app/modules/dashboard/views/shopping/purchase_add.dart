import 'package:kalayanaexpresstracker/app/core/localization/translation_service.dart';
import 'package:kalayanaexpresstracker/app/core/localization/localized_widgets.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';

class PurchaseAddPage extends StatefulWidget {
  const PurchaseAddPage({super.key});

  @override
  State<PurchaseAddPage> createState() => _PurchaseAddPageState();
}

class _PurchaseAddPageState extends State<PurchaseAddPage> {
  final controller = Get.find<DashboardController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _category = purchaseCategories.first;
  String _status = purchaseStatuses.first;
  bool _isSaving = false;
  DateTime? _dueDate;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _savePurchase() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await controller.savePurchase(
        buildPurchase(
          name: _nameController.text,
          category: _category,
          amount: _amountController.text,
          status: _status,
          note: _noteController.text,
        ).copyWith(dueDate: _dueDate),
      );
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

  @override
  Widget build(BuildContext context) {
    return DashboardFormPage(
      footer: SizedBox(
        height: 50,
        child: FilledButton.icon(
          onPressed: _isSaving ? null : _savePurchase,
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
          label: LocalizedText(_isSaving ? 'Saving' : 'Save Shopping'),
        ),
      ),
      children: [
        const DashboardFormIntroCard(
          icon: Icons.shopping_bag_rounded,
          title: 'Add Shopping',
          subtitle: 'Track wedding purchases with category and status.',
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
                      labelText: 'Item name',
                      prefixIcon: Icon(Icons.shopping_basket_rounded),
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
                    items: purchaseCategories
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
                  DashboardDatePickerTile(
                    icon: Icons.event,
                    title: 'Shopping due date',
                    value: _dueDate == null
                        ? 'Choose date'
                        : formatDisplayDate(_dueDate!),
                    onClear: _dueDate == null
                        ? null
                        : () => setState(() => _dueDate = null),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() => _dueDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    decoration: LocalizedInputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(AppConfig.appCurrencyIcon),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const LocalizedInputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                    items: purchaseStatuses
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: LocalizedText(value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _status = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    minLines: 3,
                    maxLines: 5,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const LocalizedInputDecoration(
                      labelText: 'Note',
                      alignLabelWithHint: true,
                    ),
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
  if (value == null || value.trim().isEmpty) {
    return TranslationService.translate('This field is required');
  }
  return null;
}
