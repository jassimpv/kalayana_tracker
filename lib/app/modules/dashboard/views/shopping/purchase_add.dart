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
    await controller.savePurchase(
      buildPurchase(
        name: _nameController.text,
        category: _category,
        amount: _amountController.text,
        status: _status,
        note: _noteController.text,
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
          label: Text(_isSaving ? 'Saving' : 'Save Shopping'),
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
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      prefixIcon: Icon(Icons.shopping_basket_rounded),
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
                    items: purchaseCategories
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
                      labelText: 'Amount',
                      prefixIcon: Icon(AppConfig.appCurrencyIcon),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                    items: purchaseStatuses
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
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
                    decoration: const InputDecoration(
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
  if (value == null || value.trim().isEmpty) return 'This field is required';
  return null;
}
