import 'dart:math' as math;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_widgets.dart';
import 'package:kalayanaexpresstracker/app/routes/app_pages.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
part 'dashboard_overview.dart';
part 'dashboard_shared.dart';
part 'dashboard_expenses.dart';
part 'dashboard_reminders.dart';
part 'dashboard_purchases.dart';
part 'dashboard_profile.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.loading.value) {
        return const _DashboardLoadingScaffold();
      }
      if (controller.error.value != null) {
        return _StatusScaffold(
          icon: Icons.error_outline,
          title: 'Could not load data',
          message: controller.error.value!,
        );
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 1000;
          return Scaffold(
            extendBody: true,
            backgroundColor: ThemeColors.scaffoldColor,
            drawer: wide ? null : _MobileDrawer(controller: controller),
            appBar: _DashboardAppBar(wide: wide),
            body: DecoratedBox(
              decoration: BoxDecoration(gradient: ThemeColors.surfaceGradient),
              child: Row(
                children: [
                  if (wide) _SideRail(controller: controller),
                  Expanded(child: _DashboardFrame(wide: wide)),
                ],
              ),
            ),
            bottomNavigationBar: wide
                ? null
                : _BottomNav(controller: controller),
            floatingActionButton: Obx(
              () => controller.selectedIndex.value == 4
                  ? const SizedBox.shrink()
                  : FloatingActionButton.extended(
                      onPressed: () => _handlePrimaryAction(
                        context,
                        controller.selectedIndex.value,
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(
                        _primaryActionLabel(controller.selectedIndex.value),
                      ),
                    ),
            ),
          );
        },
      );
    });
  }

  void _handlePrimaryAction(BuildContext context, int index) {
    switch (index) {
      case 2:
        showReminderDialog(context);
      case 3:
        showPurchaseDialog(context);
      default:
        showExpenseDialog(context);
    }
  }

  String _primaryActionLabel(int index) {
    return switch (index) {
      2 => 'Reminder',
      3 => 'Purchase',
      _ => 'Expense',
    };
  }
}

class _DashboardFrame extends GetView<DashboardController> {
  const _DashboardFrame({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                wide ? 28 : 16,
                18,
                wide ? 28 : 16,
                104,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1260),
                  child: Obx(
                    () => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final offset = Tween<Offset>(
                          begin: const Offset(0, 0.03),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: offset,
                            child: child,
                          ),
                        );
                      },
                      child: _page(
                        controller.selectedIndex.value,
                        controller.data.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _page(int index, WeddingData data) {
    return switch (index) {
      1 => ExpensesPanel(
        key: const ValueKey('expenses'),
        expenses: data.expenses,
      ),
      2 => RemindersPanel(
        key: const ValueKey('reminders'),
        reminders: data.reminders,
      ),
      3 => PurchasesPanel(
        key: const ValueKey('purchases'),
        purchases: data.purchases,
      ),
      4 => const ProfilePanel(key: ValueKey('profile')),
      _ => OverviewPanel(key: const ValueKey('overview'), data: data),
    };
  }
}

class _DashboardAppBar extends GetView<DashboardController>
    implements PreferredSizeWidget {
  _DashboardAppBar({required this.wide});

  final bool wide;
  bool imageError = false;

  @override
  Size get preferredSize =>
      Size.fromHeight(MediaQuery.paddingOf(Get.context!).top + 20);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeColors.primary,
            ThemeColors.primary.withValues(alpha: 0.82),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 60, 16, 10),
        child: Row(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Obx(() {
                final profile = controller.profile;
                final couple = _coupleName(profile);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      couple ?? 'Kalyana Planner',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Colors.white.withValues(alpha: 0.78),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Today, ${formatDate(DateTime.now())}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(width: 12),

            CircleAvatar(
              radius: 23,
              backgroundColor: Colors.white.withValues(alpha: 0.20),

              backgroundImage:
                  (user?.photoURL != null &&
                      user!.photoURL!.isNotEmpty &&
                      !imageError)
                  ? NetworkImage(user.photoURL!)
                  : null,

              onBackgroundImageError:
                  user?.photoURL == null || user!.photoURL!.isEmpty
                  ? null
                  : (_, _) {
                      imageError = true;
                    },

              child:
                  (user?.photoURL == null ||
                      user!.photoURL!.isEmpty ||
                      imageError)
                  ? Text(
                      "${user?.displayName?[0] ?? ''}${user?.displayName?.split(' ').last[0] ?? ''}"
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 96,
      decoration: BoxDecoration(
        color: ThemeColors.whiteColor.withValues(alpha: 0.92),
        border: Border(
          right: BorderSide(color: scheme.primary.withValues(alpha: 0.08)),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(10, 0),
          ),
        ],
      ),
      child: Obx(
        () => NavigationRail(
          minWidth: 96,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          labelType: NavigationRailLabelType.all,
          backgroundColor: Colors.transparent,
          leading: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 26),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: ThemeColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white),
            ),
          ),
          destinations: navDestinations
              .map(
                (item) => NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: Text(item.label),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: 74,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: ThemeColors.primary.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.primary.withValues(alpha: 0.16),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Obx(
              () => Row(
                children: navDestinations.asMap().entries.map((entry) {
                  final selected = controller.selectedIndex.value == entry.key;
                  final item = entry.value;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => controller.selectedIndex.value = entry.key,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1A8E88),
                                    Color(0xFF256B72),
                                  ],
                                )
                              : null,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selected ? item.selectedIcon : item.icon,
                              size: 22,
                              color: selected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 3),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.outline,
                                fontSize: 11,
                                fontWeight: selected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                              ),
                              child: Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  const _MobileDrawer({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundImage: user?.photoURL == null
                        ? null
                        : NetworkImage(user!.photoURL!),
                    child: user?.photoURL == null
                        ? const Icon(Icons.person_outline)
                        : null,
                  ),
                  title: Text(
                    user?.displayName ?? 'Wedding planner',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    user?.email ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            ...navDestinations.asMap().entries.map(
              (entry) => Obx(
                () => ListTile(
                  leading: Icon(entry.value.icon),
                  title: Text(entry.value.label),
                  selected: controller.selectedIndex.value == entry.key,
                  onTap: () {
                    controller.selectedIndex.value = entry.key;
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Logout'),
              onTap: controller.logout,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 46,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
