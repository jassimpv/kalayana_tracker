import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';

class RepayPersonPicker extends GetView<DashboardController> {
  const RepayPersonPicker({
    super.key,
    required this.selectedPersonId,
    required this.onChanged,
    this.labelText = 'Paid By - Self',
    this.validator,
  });

  final String? selectedPersonId;
  final ValueChanged<RepayPerson?> onChanged;
  final String labelText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final people = controller.repayPersons;
      final selected = people.any((person) => person.id == selectedPersonId)
          ? selectedPersonId
          : null;

      if (controller.repayPersonsLoading.value) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.person_rounded),
          ),
          child: const Row(
            children: [
              SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading people...'),
            ],
          ),
        );
      }

      if (controller.repayPersonsError.value != null) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.error_outline_rounded),
          ),
          child: Text(controller.repayPersonsError.value!),
        );
      }

      return DropdownButtonFormField<String>(
        key: ValueKey(selected),
        initialValue: selected,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: const Icon(Icons.person_rounded),
          helperText: people.isEmpty ? 'Add a repay person first' : null,
        ),
        items: people
            .map(
              (person) =>
                  DropdownMenuItem(value: person.id, child: Text(person.name)),
            )
            .toList(),
        onChanged: people.isEmpty
            ? null
            : (id) {
                final person = people.firstWhereOrNull(
                  (entry) => entry.id == id,
                );
                onChanged(person);
              },
        validator:
            validator ??
            (value) {
              return null;
            },
      );
    });
  }
}
