import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';

class ActivityLogPage extends GetView<DashboardController> {
  const ActivityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
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
            if (controller.activityLogLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = controller.activityLog;
            if (entries.isEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
                child: ResponsivePageContainer(
                  maxWidth: 900,
                  child: const PremiumEmptyState(
                    icon: Icons.history_rounded,
                    title: 'No activity yet',
                    subtitle:
                        'Joins, leaves, and changes made by you or your collaborators will show up here.',
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 120),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ResponsivePageContainer(
                  maxWidth: 900,
                  child: _ActivityLogTile(entry: entry),
                );
              },
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemCount: entries.length,
            );
          }),
        ),
      ),
    );
  }
}

class _ActivityLogTile extends StatelessWidget {
  const _ActivityLogTile({required this.entry});

  final ActivityLogEntry entry;

  @override
  Widget build(BuildContext context) {
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
          SoftIcon(icon: Icons.history_rounded, color: ThemeColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.actorName} ${entry.action}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatDate(entry.createdAt)} · ${_formatTime(entry.createdAt)}',
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
        ],
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour24 = dateTime.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour24 >= 12 ? 'PM' : 'AM';
  return '$hour12:$minute $period';
}
