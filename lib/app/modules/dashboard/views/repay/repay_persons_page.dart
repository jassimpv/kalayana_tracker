import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/repay_person.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class RepayPersonsPage extends StatefulWidget {
  const RepayPersonsPage({super.key});

  @override
  State<RepayPersonsPage> createState() => _RepayPersonsPageState();
}

class _RepayPersonsPageState extends State<RepayPersonsPage> {
  final controller = Get.find<DashboardController>();
  String? _selectedPersonId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      floatingActionButton: Obx(() {
        final showAddButton =
            _selectedPersonId == null &&
            controller.repayPersons.isNotEmpty &&
            !controller.repayPersonsLoading.value;
        if (!showAddButton) return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: () => _showRepayPersonDialog(context),
          backgroundColor: ThemeColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add Person'),
        );
      }),
      body: SizedBox.expand(
        child: Container(
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
                child: ResponsivePageContainer(
                  maxWidth: 900,
                  child: PremiumEmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load people',
                    subtitle: controller.repayPersonsError.value!,
                  ),
                ),
              );
            }

            final people = controller.repayPersons;
            final selectedPerson = people.firstWhereOrNull(
              (person) => person.id == _selectedPersonId,
            );
            if (_selectedPersonId != null && selectedPerson == null) {
              _selectedPersonId = null;
            }
            if (selectedPerson != null) {
              return _RepayPersonDetailView(
                person: selectedPerson,
                onBack: () => setState(() => _selectedPersonId = null),
              );
            }

            if (people.isEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                child: ResponsivePageContainer(
                  maxWidth: 900,
                  child: Column(
                    children: [
                      const PremiumEmptyState(
                        icon: Icons.people_alt_rounded,
                        title: 'No people added yet',
                        subtitle:
                            'Add people who paid expenses on your behalf.',
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
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              itemBuilder: (context, index) {
                final person = people[index];
                return ResponsivePageContainer(
                  maxWidth: 900,
                  child: _RepayPersonTile(
                    person: person,
                    onTap: () => setState(() => _selectedPersonId = person.id),
                  ),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: people.length,
            );
          }),
        ),
      ),
    );
  }
}

class _RepayPersonTile extends GetView<DashboardController> {
  const _RepayPersonTile({required this.person, required this.onTap});

  final RepayPerson person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pending = _repayPersonPendingAmount(controller, person);
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ThemeColors.primary.withValues(alpha: 0.08),
            ),
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
                      style: const TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created ${formatDate(person.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount owed: ${moneyOrDash(pending)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: pending > 0
                            ? ThemeColors.primary
                            : ThemeColors.completedColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _RepayPersonDetailView extends GetView<DashboardController> {
  const _RepayPersonDetailView({required this.person, required this.onBack});

  final RepayPerson person;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = _repayPersonHistory(controller, person);
      final pending = _repayPersonPendingAmount(controller, person);
      final totalPaid = _repayPersonPaidAmount(controller, person);

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
        child: ResponsivePageContainer(
          maxWidth: 900,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RepayPersonDetailHeader(
                person: person,
                pending: pending,
                totalPaid: totalPaid,
                onBack: onBack,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: controller.openExpenseAdd,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RepayPersonActionButton(
                    icon: Icons.edit_rounded,
                    tooltip: 'Edit person',
                    onPressed: () =>
                        _showRepayPersonDialog(context, person: person),
                  ),
                  const SizedBox(width: 8),
                  _RepayPersonActionButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete person',
                    destructive: true,
                    onPressed: () => _confirmDeleteRepayPerson(context, person),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Pay History',
                style: TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              if (history.isEmpty)
                const PremiumEmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No pay history yet',
                  subtitle: 'Expenses involving this person will appear here.',
                )
              else
                ...history.map((item) => _RepayPersonHistoryTile(item: item)),
            ],
          ),
        ),
      );
    });
  }
}

class _RepayPersonDetailHeader extends StatelessWidget {
  const _RepayPersonDetailHeader({
    required this.person,
    required this.pending,
    required this.totalPaid,
    required this.onBack,
  });

  final RepayPerson person;
  final double pending;
  final double totalPaid;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: const TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Created ${formatDate(person.createdAt)}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _RepayPersonMetric(
                  label: 'Amount owed',
                  value: moneyOrDash(pending),
                  color: pending > 0
                      ? ThemeColors.primary
                      : ThemeColors.completedColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _RepayPersonMetric(
                  label: 'Total paid',
                  value: moneyOrDash(totalPaid),
                  color: ThemeColors.completedColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RepayPersonMetric extends StatelessWidget {
  const _RepayPersonMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RepayPersonActionButton extends StatelessWidget {
  const _RepayPersonActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.destructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? const Color(0xFFB44A35) : ThemeColors.logoDeep;
    return SizedBox(
      width: 50,
      height: 50,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: destructive
              ? const Color(0xFFFFE9DF)
              : const Color(0xFFFFEED7),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Icon(icon, color: color),
          ),
        ),
      ),
    );
  }
}

class _RepayPersonHistoryTile extends GetView<DashboardController> {
  const _RepayPersonHistoryTile({required this.item});

  final ExpenseItem item;

  @override
  Widget build(BuildContext context) {
    final settled = item.isRepaymentCompleted || item.repaymentPending == 0;
    final color = settled ? ThemeColors.completedColor : ThemeColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          SoftIcon(
            icon: settled
                ? Icons.check_circle_outline_rounded
                : Icons.assignment_return_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name.isEmpty ? 'Untitled expense' : item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category} | ${formatDate(item.updatedDate)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                moneyOrDash(item.repaymentAmount),
                style: const TextStyle(
                  color: ThemeColors.logoDeep,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                settled ? 'Settled' : 'Pending',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              PopupMenuButton<bool>(
                tooltip: 'Update payment status',
                initialValue: settled,
                onSelected: (completed) => controller.updateRepaymentStatus(
                  item,
                  completed: completed,
                ),
                itemBuilder: (context) => const [
                  PopupMenuItem<bool>(value: false, child: Text('Pending')),
                  PopupMenuItem<bool>(value: true, child: Text('Settled')),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Update',
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.72),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ThemeColors.logoDeep.withValues(alpha: 0.72),
                      size: 14,
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

double _repayPersonPendingAmount(
  DashboardController controller,
  RepayPerson person,
) {
  return _repayPersonHistory(
    controller,
    person,
  ).fold<double>(0, (total, item) => total + item.repaymentPending);
}

double _repayPersonPaidAmount(
  DashboardController controller,
  RepayPerson person,
) {
  return _repayPersonHistory(
    controller,
    person,
  ).fold<double>(0, (total, item) => total + item.repaymentAmount);
}

List<ExpenseItem> _repayPersonHistory(
  DashboardController controller,
  RepayPerson person,
) {
  final expenses =
      controller.data.value.expenses
          .where((item) => _expenseMatchesRepayPerson(item, person))
          .toList()
        ..sort((a, b) => b.updatedDate.compareTo(a.updatedDate));
  return expenses;
}

bool _expenseMatchesRepayPerson(ExpenseItem item, RepayPerson person) {
  if (!item.needsRepayment && item.repaymentAmount <= 0) {
    return false;
  }

  final personId = person.id.trim().toLowerCase();
  final personName = person.name.trim().toLowerCase();
  if (personId.isNotEmpty &&
      item.paidByPersonId.trim().toLowerCase() == personId) {
    return true;
  }

  if (personName.isNotEmpty &&
      item.repayPerson.trim().toLowerCase() == personName) {
    return true;
  }

  if (personName.isNotEmpty &&
      item.paidByPersonName.trim().toLowerCase() == personName) {
    return true;
  }

  if (personName.isNotEmpty && item.paidBy.trim().toLowerCase() == personName) {
    return true;
  }

  return item.paymentSplit.any((payment) {
    if (personId.isNotEmpty &&
        payment.paidByPersonId.trim().toLowerCase() == personId) {
      return true;
    }

    return personName.isNotEmpty &&
        payment.displayPaidBy.trim().toLowerCase() == personName;
  });
}

Future<void> _showRepayPersonDialog(
  BuildContext context, {
  RepayPerson? person,
}) async {
  final controller = Get.find<DashboardController>();
  final nameController = TextEditingController(text: person?.name ?? '');
  final formKey = GlobalKey<FormState>();
  var saving = false;

  Future<void> submit(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (saving || !formKey.currentState!.validate()) return;
    FocusScope.of(dialogContext).unfocus();
    setDialogState(() => saving = true);
    final saved = person == null
        ? await controller.addRepayPerson(nameController.text)
        : await controller.updateRepayPerson(person, nameController.text);
    if (dialogContext.mounted && saved) {
      Navigator.pop(dialogContext);
      return;
    }
    if (dialogContext.mounted) setDialogState(() => saving = false);
  }

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final title = person == null ? 'Add Person' : 'Edit Person';
        final subtitle = person == null
            ? 'Add someone who can pay expenses on your behalf.'
            : 'Update this person for future payment selection.';

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: ThemeColors.scaffoldColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: ThemeColors.primary.withValues(alpha: 0.10),
                ),
                boxShadow: [
                  BoxShadow(
                    color: ThemeColors.primary.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SoftIcon(
                            icon: person == null
                                ? Icons.person_add_alt_1_rounded
                                : Icons.edit_rounded,
                            color: ThemeColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: ThemeColors.logoDeep,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: ThemeColors.logoDeep.withValues(
                                      alpha: 0.62,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: saving
                                ? null
                                : Navigator.of(context).pop,
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Close',
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Person name',
                          hintText: 'Enter name',
                          helperText: 'This name will appear in paid-by lists.',
                          prefixIcon: const Icon(Icons.person_rounded),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.86),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
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
                          if (duplicate) {
                            return 'A person with this name already exists';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => submit(context, setState),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: saving
                                  ? null
                                  : Navigator.of(context).pop,
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: saving
                                  ? null
                                  : () => submit(context, setState),
                              icon: saving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.check_rounded),
                              label: Text(saving ? 'Saving' : 'Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
  Future<void>.delayed(const Duration(milliseconds: 300), () {
    nameController.dispose();
  });
}

Future<void> _confirmDeleteRepayPerson(
  BuildContext context,
  RepayPerson person,
) async {
  final controller = Get.find<DashboardController>();
  if (controller.isRepayPersonUsed(person.id, personName: person.name)) {
    await controller.deleteRepayPerson(person);
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Person'),
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
