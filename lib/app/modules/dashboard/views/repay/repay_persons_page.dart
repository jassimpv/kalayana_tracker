import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class RepayPersonsPage extends GetView<DashboardController> {
  const RepayPersonsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.primary,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRepayPersonDialog(context),
        backgroundColor: ThemeColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Person'),
      ),
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Obx(() {
          if (controller.repayPersonsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.repayPersonsError.value != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: PremiumEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Could not load repay persons',
                subtitle: controller.repayPersonsError.value!,
              ),
            );
          }

          final people = controller.repayPersons;
          if (people.isEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              child: Column(
                children: [
                  const PremiumEmptyState(
                    icon: Icons.people_alt_rounded,
                    title: 'No repay persons added yet',
                    subtitle:
                        'Add people who can be selected as payment payers.',
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: () => _showRepayPersonDialog(context),
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      label: const Text('Add Person'),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
            itemBuilder: (context, index) {
              final person = people[index];
              return _RepayPersonTile(person: person);
            },
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemCount: people.length,
          );
        }),
      ),
    );
  }
}

class _RepayPersonTile extends GetView<DashboardController> {
  const _RepayPersonTile({required this.person});

  final RepayPerson person;

  @override
  Widget build(BuildContext context) {
    final isUsed = controller.isRepayPersonUsed(person.id);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          SoftIcon(icon: Icons.person_rounded, color: ThemeColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created ${formatDate(person.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showRepayPersonDialog(context, person: person),
            icon: const Icon(Icons.edit_rounded),
            tooltip: 'Edit person',
          ),
          IconButton(
            onPressed: () async {
              if (isUsed) {
                await controller.deleteRepayPerson(person);
                return;
              }
              await _confirmDeleteRepayPerson(context, person);
            },
            icon: Icon(
              isUsed ? Icons.lock_outline_rounded : Icons.delete_outline,
            ),
            tooltip: isUsed ? 'Used in payments' : 'Delete person',
          ),
        ],
      ),
    );
  }
}

Future<void> _showRepayPersonDialog(
  BuildContext context, {
  RepayPerson? person,
}) async {
  final controller = Get.find<DashboardController>();
  final nameController = TextEditingController(text: person?.name ?? '');
  final formKey = GlobalKey<FormState>();
  var saving = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(
            person == null ? 'Add Repay Person' : 'Edit Repay Person',
          ),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Person name cannot be empty';
                }
                final duplicate = controller.repayPersons.any(
                  (entry) =>
                      entry.id != person?.id &&
                      entry.name.trim().toLowerCase() ==
                          value.trim().toLowerCase(),
                );
                if (duplicate) return 'A person with this name already exists';
                return null;
              },
              onFieldSubmitted: (_) async {
                if (saving || !formKey.currentState!.validate()) return;
                setState(() => saving = true);
                final saved = person == null
                    ? await controller.addRepayPerson(nameController.text)
                    : await controller.updateRepayPerson(
                        person,
                        nameController.text,
                      );
                if (context.mounted && saved) Navigator.pop(context);
                if (context.mounted) setState(() => saving = false);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : Navigator.of(context).pop,
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setState(() => saving = true);
                      final saved = person == null
                          ? await controller.addRepayPerson(nameController.text)
                          : await controller.updateRepayPerson(
                              person,
                              nameController.text,
                            );
                      if (context.mounted && saved) Navigator.pop(context);
                      if (context.mounted) setState(() => saving = false);
                    },
              child: Text(saving ? 'Saving' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
  nameController.dispose();
}

Future<void> _confirmDeleteRepayPerson(
  BuildContext context,
  RepayPerson person,
) async {
  final controller = Get.find<DashboardController>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Repay Person'),
      content: Text('Delete ${person.name}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await controller.deleteRepayPerson(person);
}
