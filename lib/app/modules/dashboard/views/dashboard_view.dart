import 'dart:math' as math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/currency_symbols.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/utils/responsive_layout.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/app_logo.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/inline_native_ad.dart';
import 'package:kalayanaexpresstracker/app/core/services/rewarded_ad_manager.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_details.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_history.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_payment_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/dashboard_guests.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/reminders/reminder_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/profile/activity_log_page.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/repay/repay_persons_page.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/shopping/purchase_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/app_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/navigation_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';
import 'package:kalayanaexpresstracker/app/routes/app_routes.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/config.dart';
part 'profile/dashboard_profile.dart';
part 'expenses/dashboard_overview.dart';
part '../widgets/dashboard_shared.dart';
part 'expenses/dashboard_expenses.dart';
part 'reminders/dashboard_reminders.dart';
part 'shopping/dashboard_purchases.dart';

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
          icon: CupertinoIcons.exclamationmark_triangle,
          title: 'Could not load data',
          message: controller.error.value!,
        );
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.handleDashboardBack()) {
            Navigator.of(context).pop();
          }
        },
        child: isDesktop(context)
            ? _DesktopDashboardScaffold(
                controller: controller,
                onPrimaryAction: _handlePrimaryAction,
              )
            : Scaffold(
                extendBody: true,
                body: AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle.light,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          children: [
                            if (controller.isDashboardSubPage)
                              CustomAppBar(
                                title: _dashboardPageTitle(
                                  controller.dashboardPage.value,
                                ),
                                showGreeting: false,
                                onBack: controller.closeDashboardSubPage,
                              ),
                            Expanded(
                              child: _DashboardBody(controller: controller),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: IgnorePointer(
                          ignoring: controller.isDashboardSubPage,
                          child: AnimatedSlide(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            offset: controller.isDashboardSubPage
                                ? const Offset(0, 1.25)
                                : Offset.zero,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 180),
                              opacity: controller.isDashboardSubPage ? 0 : 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Obx(
                                    () => DashboardBannerAdSlot(
                                      key: ValueKey(
                                        'dashboard_banner_${controller.selectedIndex.value}',
                                      ),
                                    ),
                                  ),
                                  BottomNav(
                                    controller: controller,
                                    onItemClick: controller.openDashboardTab,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                floatingActionButton: Obx(
                  () =>
                      controller.isDashboardSubPage ||
                          controller.selectedIndex.value == 0 ||
                          controller.selectedIndex.value == 4 ||
                          controller.selectedIndex.value == 5
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                84 +
                                (isMobileAdsSupported
                                    ? AdsConfig.bannerHeight
                                    : 0),
                          ),
                          child: FloatingActionButton(
                            onPressed: () => _handlePrimaryAction(
                              controller.selectedIndex.value,
                            ),
                            backgroundColor: ThemeColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 12,
                            shape: const CircleBorder(),
                            child: const Icon(CupertinoIcons.plus, size: 34),
                          ),
                        ),
                ),
              ),
      );
    });
  }

  void _handlePrimaryAction(int index) {
    switch (index) {
      case 2:
        controller.openReminderAdd();
        return;
      case 3:
        controller.openPurchaseAdd();
        return;
      default:
        controller.openExpenseAdd();
    }
  }
}

class _DesktopDashboardScaffold extends StatelessWidget {
  const _DesktopDashboardScaffold({
    required this.controller,
    required this.onPrimaryAction,
  });

  final DashboardController controller;
  final ValueChanged<int> onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.scaffoldColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Row(
          children: [
            DashboardSideMenu(
              controller: controller,
              onItemClick: controller.openDashboardTab,
            ),
            Expanded(
              child: Column(
                children: [
                  _DesktopDashboardAppBar(controller: controller),
                  Expanded(child: _DashboardBody(controller: controller)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Obx(
        () =>
            controller.isDashboardSubPage ||
                controller.selectedIndex.value == 0 ||
                controller.selectedIndex.value == 4 ||
                controller.selectedIndex.value == 5
            ? const SizedBox.shrink()
            : FloatingActionButton.extended(
                onPressed: () =>
                    onPrimaryAction(controller.selectedIndex.value),
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.white,
                elevation: 10,
                icon: const Icon(CupertinoIcons.plus),
                label: const Text('Add'),
              ),
      ),
    );
  }
}

class _DesktopDashboardAppBar extends StatelessWidget {
  const _DesktopDashboardAppBar({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSubPage = controller.isDashboardSubPage;
      final title = isSubPage
          ? _dashboardPageTitle(controller.dashboardPage.value)
          : _dashboardTabTitle(controller.selectedIndex.value);
      final subtitle = isSubPage
          ? 'Manage ${title.toLowerCase()}'
          : 'Wedding Budget Overview';
      if (!isSubPage && controller.selectedIndex.value == 0) {
        return _DesktopOverviewAppHeader(controller: controller);
      }

      final user = FirebaseAuth.instance.currentUser;

      return Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          border: Border(
            bottom: BorderSide(
              color: ThemeColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              if (isSubPage) ...[
                IconButton(
                  onPressed: controller.closeDashboardSubPage,
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: 'Back',
                  color: ThemeColors.primary,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: controller.openProfile,
                borderRadius: BorderRadius.circular(999),
                // user?.photoURL is intentionally not passed here; the
                // avatar always shows themed initials, not a provider photo.
                child: _ResilientAvatar(
                  initials: _profileInitials(
                    user?.displayName ?? user?.email ?? 'J',
                  ),
                  size: 40,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _confirmLogout(context, controller),
                icon: const Icon(Icons.logout_rounded),
                color: ThemeColors.primary,
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _DesktopOverviewAppHeader extends StatelessWidget {
  const _DesktopOverviewAppHeader({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = FirebaseAuth.instance.currentUser;
      final profile = controller.profile;
      final identityProfile = controller.weddingIdentityProfile;
      final displayName = _profileDisplayName(user, profile);
      final firstName = displayName.split(RegExp(r'\s+')).first;
      final groom = profileGroom(identityProfile);
      final bride = profileBride(identityProfile);
      final isWorkspaceAdmin = controller.isWorkspaceAdmin;
      final couple = groom.isNotEmpty && bride.isNotEmpty
          ? '$groom & $bride'
          : isWorkspaceAdmin
          ? (displayName == '-' ? 'Your Wedding' : displayName)
          : 'Connected to ${controller.workspaceAdminCollaborator?.name ?? 'Admin'}';
      final weddingDate = profileMarriageDate(identityProfile);
      final daysLeft = daysUntilDate(weddingDate);

      return _buildHeader(
        context,
        user: user,
        firstName: firstName,
        couple: couple,
        weddingDate: weddingDate,
        daysLeft: daysLeft,
        isWorkspaceAdmin: isWorkspaceAdmin,
      );
    });
  }

  Widget _buildHeader(
    BuildContext context, {
    required User? user,
    required String firstName,
    required String couple,
    required DateTime? weddingDate,
    required int? daysLeft,
    required bool isWorkspaceAdmin,
  }) {
    return Container(
      height: 210,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: Color(0xFF8F1438),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/dashboard_figma_wedding_header.png',
              fit: BoxFit.cover,
              alignment: const Alignment(0.88, 0),
              filterQuality: FilterQuality.high,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF5A0820).withValues(alpha: 0.88),
                    const Color(0xFF8F1438).withValues(alpha: 0.48),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi ${firstName == '-' ? 'Jassim' : firstName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let's plan your perfect day",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _HeaderCircleButton(
                        icon: CupertinoIcons.bell,
                        onTap: () => controller.openDashboardTab(2),
                      ),
                      const SizedBox(width: 10),
                      const ProfilePill(),
                      const SizedBox(width: 10),
                      _HeaderCircleButton(
                        icon: Icons.logout_rounded,
                        onTap: () => _confirmLogout(context, controller),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _WeddingIdentityCard(
                        coupleName: couple,
                        weddingDate: weddingDate,
                        daysLeft: daysLeft,
                        onEdit: isWorkspaceAdmin
                            ? () => showProfileDialog(context)
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final argument = controller.dashboardPageArgument.value;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: switch (controller.dashboardPage.value) {
          DashboardPageKind.expenseAdd => ExpenseAddPage(
            key: ValueKey('expense-add-$argument'),
            sourceArgument: argument,
          ),
          DashboardPageKind.reminderAdd => const ReminderAddPage(
            key: ValueKey('reminder-add'),
          ),
          DashboardPageKind.purchaseAdd => const PurchaseAddPage(
            key: ValueKey('purchase-add'),
          ),
          DashboardPageKind.expenseDetail => ExpenseDetailPage(
            key: ValueKey('expense-detail-$argument'),
            expenseId: argument,
          ),
          DashboardPageKind.expensePaymentAdd => ExpensePaymentAddPage(
            key: ValueKey('expense-payment-add-$argument'),
            expenseId: argument,
          ),
          DashboardPageKind.expensePaymentHistory => ExpensePaymentHistoryPage(
            key: ValueKey('expense-payment-history-$argument'),
            expenseId: argument,
          ),
          DashboardPageKind.repayPersons => const RepayPersonsPage(
            key: ValueKey('repay-persons'),
          ),
          DashboardPageKind.reports => const ReportsPanel(
            key: ValueKey('reports'),
          ),
          DashboardPageKind.collaborators => const CollaboratorsPanel(
            key: ValueKey('collaborators'),
          ),
          DashboardPageKind.activityLog => const ActivityLogPage(
            key: ValueKey('activity-log'),
          ),
          DashboardPageKind.guests => const GuestsPanel(
            key: ValueKey('guests'),
          ),
          DashboardPageKind.tab => _DashboardTabPage(
            key: ValueKey('tab-${controller.selectedIndex.value}'),
            index: controller.selectedIndex.value,
          ),
        },
      );
    });
  }
}

String _dashboardPageTitle(DashboardPageKind page) => switch (page) {
  DashboardPageKind.expenseAdd => 'Add Expense',
  DashboardPageKind.reminderAdd => 'Add Reminder',
  DashboardPageKind.purchaseAdd => 'Add Shopping',
  DashboardPageKind.expenseDetail => 'Expense Detail',
  DashboardPageKind.expensePaymentAdd => 'Add Payment',
  DashboardPageKind.expensePaymentHistory => 'Payment History',
  DashboardPageKind.repayPersons => 'Pay Back',
  DashboardPageKind.reports => 'Reports',
  DashboardPageKind.collaborators => 'Collaborators',
  DashboardPageKind.activityLog => 'Activity Log',
  DashboardPageKind.guests => 'Guests & RSVP',
  DashboardPageKind.tab => 'Dashboard',
};

String _dashboardTabTitle(int index) => switch (index) {
  1 => 'Expenses',
  2 => 'Reminders',
  3 => 'Shopping',
  4 => 'Guests & RSVP',
  5 => 'Profile',
  _ => 'Overview',
};

class _DashboardTabPage extends GetView<DashboardController> {
  const _DashboardTabPage({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius:
                      index == 0 ||
                          index == 1 ||
                          index == 2 ||
                          index == 3 ||
                          index == 4 ||
                          index == 5
                      ? BorderRadius.zero
                      : const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                ),
                child: ResponsivePageContainer(
                  padding: EdgeInsets.zero,
                  child: _page(index, controller.data.value),
                ),
              ),
            ),
          ],
        ),
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
      4 => const GuestsPanel(key: ValueKey('rsvp'), showHero: true),
      5 => const ProfilePanel(key: ValueKey('profile')),
      _ => OverviewPanel(key: const ValueKey('overview'), data: data),
    };
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
                      fontWeight: FontWeight.w600,
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
