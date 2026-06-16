import 'dart:math' as math;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/currency_symbols.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/app_logo.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_details.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_history.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_payment_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/reminders/reminder_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/repay/repay_persons_page.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/shopping/purchase_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/app_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_form_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/navigation_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';
import 'package:kalayanaexpresstracker/app/routes/app_routes.dart';
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
        child: Scaffold(
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
                      Expanded(child: _DashboardBody(controller: controller)),
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
                            const DashboardBannerAdSlot(),
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Obx(
            () =>
                controller.isDashboardSubPage ||
                    controller.selectedIndex.value == 0 ||
                    controller.selectedIndex.value == 4
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(
                      bottom:
                          84 +
                          (isMobileAdsSupported ? AdsConfig.bannerHeight : 0),
                    ),
                    child: FloatingActionButton(
                      onPressed: () =>
                          _handlePrimaryAction(controller.selectedIndex.value),
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

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.controller});

  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    final page = controller.dashboardPage.value;
    final argument = controller.dashboardPageArgument.value;

    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: switch (page) {
          DashboardPageKind.expenseAdd => const ExpenseAddPage(
            key: ValueKey('expense-add'),
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
          DashboardPageKind.tab => _DashboardTabPage(
            key: ValueKey('tab-${controller.selectedIndex.value}'),
            index: controller.selectedIndex.value,
          ),
        },
      ),
    );
  }
}

String _dashboardPageTitle(DashboardPageKind page) => switch (page) {
  DashboardPageKind.expenseAdd => 'Add Expense',
  DashboardPageKind.reminderAdd => 'Add Reminder',
  DashboardPageKind.purchaseAdd => 'Add Shopping',
  DashboardPageKind.expenseDetail => 'Expense Detail',
  DashboardPageKind.expensePaymentAdd => 'Add Payment',
  DashboardPageKind.expensePaymentHistory => 'Payment History',
  DashboardPageKind.repayPersons => 'Repay',
  DashboardPageKind.reports => 'Reports',
  DashboardPageKind.collaborators => 'Collaborators',
  DashboardPageKind.tab => 'Dashboard',
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
                  color: ThemeColors.scaffoldColor,
                  borderRadius:
                      index == 0 || index == 1 || index == 2 || index == 3
                      ? BorderRadius.zero
                      : const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                ),
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  primary: true,
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top:
                            index == 0 ||
                                index == 1 ||
                                index == 2 ||
                                index == 3 ||
                                index == 4
                            ? 0
                            : 8,
                        bottom:
                            MediaQuery.paddingOf(context).bottom +
                            (index == 0 ? 118 : 60) +
                            (isMobileAdsSupported ? AdsConfig.bannerHeight : 0),
                        left:
                            index == 0 ||
                                index == 1 ||
                                index == 2 ||
                                index == 3 ||
                                index == 4
                            ? 0
                            : 16,
                        right:
                            index == 0 ||
                                index == 1 ||
                                index == 2 ||
                                index == 3 ||
                                index == 4
                            ? 0
                            : 16,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: _page(index, controller.data.value),
                      ),
                    ),
                  ],
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
      4 => const ProfilePanel(key: ValueKey('profile')),
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
