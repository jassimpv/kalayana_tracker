import 'dart:math' as math;
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/utils/formatters.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/app_logo.dart';
import 'package:kalayanaexpresstracker/app/data/models/event_reminder.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/purchase_item.dart';
import 'package:kalayanaexpresstracker/app/data/models/wedding_data.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_add.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_details.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_history.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/app_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_dialogs.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/dashboard_widgets.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/navigation_bar.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/widgets/expense_widgets.dart';
import 'package:kalayanaexpresstracker/app/routes/app_routes.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
part 'dashboard_overview.dart';
part 'dashboard_shared.dart';
part 'dashboard_expenses.dart';
part 'dashboard_reminders.dart';
part 'dashboard_purchases.dart';
part 'dashboard_profile.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'dashboardNestedNavigator',
  );
  late final DashboardController controller = Get.find<DashboardController>();
  bool _showDashboardChrome = true;
  String _currentNestedRoute = AppRoutes.dashboardOverview;

  bool get _showDashboardGreeting {
    return !_isStandaloneDashboardRoute(_currentNestedRoute) &&
        controller.selectedIndex.value == 0;
  }

  String get _appBarTitle {
    if (_currentNestedRoute == AppRoutes.dashboardExpenseAdd) {
      return 'Add Expense';
    }
    if (_currentNestedRoute == AppRoutes.dashboardExpenseDetail) {
      return 'Expense Detail';
    }
    if (_currentNestedRoute == AppRoutes.dashboardExpensePaymentHistory) {
      return 'Payment History';
    }
    return _DashboardDestination.fromRoute(_currentNestedRoute).title;
  }

  bool _handleBackNavigation() {
    final navigatorState = _navigatorKey.currentState;
    if (navigatorState != null && navigatorState.canPop()) {
      navigatorState.pop();
      return false;
    }
    if (controller.selectedIndex.value != 0) {
      _handleNavigation(0);
      return false;
    }
    return true;
  }

  void _handleNavigation(int index) {
    final navigator = _navigatorKey.currentState;
    if (navigator == null || controller.selectedIndex.value == index) return;

    final previousIndex = controller.selectedIndex.value;
    navigator.pushReplacement(
      _buildDashboardTabRoute(index, previousIndex, index),
    );
    controller.selectedIndex.value = index;
  }

  void _handleNestedRouteChanged(String? routeName) {
    final nextRoute = routeName ?? AppRoutes.dashboardOverview;
    final shouldShowChrome = !_isStandaloneDashboardRoute(nextRoute);
    if (_showDashboardChrome == shouldShowChrome &&
        _currentNestedRoute == nextRoute) {
      return;
    }
    setState(() {
      _showDashboardChrome = shouldShowChrome;
      _currentNestedRoute = nextRoute;
    });
  }

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
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_handleBackNavigation()) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          extendBody: true,
          backgroundColor: ThemeColors.primary,
          body: Stack(
            children: [
              Positioned.fill(
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CustomAppBar(
                          title: _appBarTitle,
                          showGreeting: _showDashboardGreeting,
                          onBack:
                              _isStandaloneDashboardRoute(_currentNestedRoute)
                              ? () => Navigator.of(context).maybePop()
                              : null,
                        ),
                      ),
                    ),
                  ],
                  body: Navigator(
                    key: _navigatorKey,
                    initialRoute: _DashboardDestination.overview.route,
                    onGenerateRoute: _DashboardDestination.onGenerateRoute,
                    observers: [
                      DashboardTabNavigatorObserver(
                        onRouteChanged: _handleNestedRouteChanged,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  ignoring: !_showDashboardChrome,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    offset: _showDashboardChrome
                        ? Offset.zero
                        : const Offset(0, 1.25),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _showDashboardChrome ? 1 : 0,
                      child: BottomNav(
                        controller: controller,
                        onItemClick: _handleNavigation,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Obx(
            () => !_showDashboardChrome || controller.selectedIndex.value == 4
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 84),
                    child: FloatingActionButton.extended(
                      onPressed: () => _handlePrimaryAction(
                        context,
                        controller.selectedIndex.value,
                      ),
                      backgroundColor: ThemeColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 26),
                      label: Text(
                        _primaryActionLabel(controller.selectedIndex.value),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }

  void _handlePrimaryAction(BuildContext context, int index) {
    switch (index) {
      case 2:
        showReminderDialog(context);
        return;
      case 3:
        showPurchaseDialog(context);
        return;
      default:
        _pushExpenseAddPage();
    }
  }

  void _pushExpenseAddPage() {
    _navigatorKey.currentState?.push(
      buildNestedDashboardRoute(
        settings: const RouteSettings(name: AppRoutes.dashboardExpenseAdd),
        child: const ExpenseAddPage(),
        transitionDuration: const Duration(milliseconds: 280),
        startOffset: const Offset(0.12, 0),
      ),
    );
  }

  String _primaryActionLabel(int index) {
    return switch (index) {
      2 => 'Reminder',
      3 => 'Purchase',
      _ => 'Expense',
    };
  }
}

enum _DashboardDestination {
  overview(AppRoutes.dashboardOverview, 0),
  expenses(AppRoutes.dashboardExpenses, 1),
  dates(AppRoutes.dashboardDates, 2),
  shopping(AppRoutes.dashboardShopping, 3),
  profile(AppRoutes.dashboardProfile, 4);

  const _DashboardDestination(this.route, this.tabIndex);

  final String route;
  final int tabIndex;

  Widget get widget => _DashboardTabPage(index: tabIndex);

  static _DashboardDestination fromIndex(int index) =>
      _DashboardDestination.values.firstWhere(
        (destination) => destination.tabIndex == index,
        orElse: () => _DashboardDestination.overview,
      );

  static _DashboardDestination fromRoute(String? route) =>
      _DashboardDestination.values.firstWhere(
        (destination) => destination.route == route,
        orElse: () => _DashboardDestination.overview,
      );

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == AppRoutes.dashboardExpenseAdd) {
      return buildNestedDashboardRoute(
        settings: settings,
        child: const ExpenseAddPage(),
      );
    }
    if (routeName == AppRoutes.dashboardExpenseDetail) {
      final expenseId = settings.arguments as String?;
      return buildNestedDashboardRoute(
        settings: settings,
        child: ExpenseDetailPage(expenseId: expenseId),
      );
    }
    if (routeName == AppRoutes.dashboardExpensePaymentHistory) {
      final expenseId = settings.arguments as String?;
      return buildNestedDashboardRoute(
        settings: settings,
        child: ExpensePaymentHistoryPage(expenseId: expenseId),
      );
    }

    final destination = _DashboardDestination.fromRoute(routeName);
    return buildNestedDashboardRoute(
      settings: RouteSettings(name: destination.route),
      child: destination.widget,
    );
  }
}

Route<dynamic> buildNestedDashboardRoute({
  required RouteSettings settings,
  required Widget child,
  Duration transitionDuration = Duration.zero,
  Offset startOffset = Offset.zero,
}) {
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) =>
        SizedBox.expand(child: child),
    transitionDuration: transitionDuration,
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (transitionDuration == Duration.zero) return child;
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(curve),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

Route<dynamic> _buildDashboardTabRoute(int index, int fromIndex, int toIndex) {
  final destination = _DashboardDestination.fromIndex(index);
  final slideFromRight = toIndex > fromIndex;
  final startOffset = Offset(slideFromRight ? 0.12 : -0.12, 0);
  return buildNestedDashboardRoute(
    settings: RouteSettings(name: destination.route),
    child: destination.widget,
    transitionDuration: const Duration(milliseconds: 360),
    startOffset: startOffset,
  );
}

class DashboardTabNavigatorObserver extends NavigatorObserver {
  DashboardTabNavigatorObserver({required this.onRouteChanged});

  final ValueChanged<String?> onRouteChanged;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;
    if (routeName == null) return;
    onRouteChanged(routeName);
    _syncSelectedIndex(routeName);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final routeName = newRoute?.settings.name;
    if (routeName == null) return;
    onRouteChanged(routeName);
    _syncSelectedIndex(routeName);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = previousRoute?.settings.name;
    if (routeName == null) return;
    onRouteChanged(routeName);
    _syncSelectedIndex(routeName);
  }

  void _syncSelectedIndex(String? routeName) {
    final routeIndex = _matchedDashboardRouteNameToIndex(routeName);
    if (routeIndex == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<DashboardController>()) return;
      final controller = Get.find<DashboardController>();
      if (controller.selectedIndex.value != routeIndex) {
        controller.selectedIndex.value = routeIndex;
      }
    });
  }
}

bool _isStandaloneDashboardRoute(String? routeName) {
  return routeName == AppRoutes.dashboardExpenseAdd ||
      routeName == AppRoutes.dashboardExpenseDetail ||
      routeName == AppRoutes.dashboardExpensePaymentHistory;
}

int? _matchedDashboardRouteNameToIndex(String? routeName) {
  if (routeName == null) return null;
  final routeIndex = _DashboardDestination.values.indexWhere(
    (destination) => destination.route == routeName,
  );
  return routeIndex >= 0 ? routeIndex : null;
}

class _DashboardTabPage extends GetView<DashboardController> {
  const _DashboardTabPage({required this.index});

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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: CustomScrollView(
                  primary: true,
                  slivers: [
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(
                        top: 8.0,
                        bottom: MediaQuery.paddingOf(context).bottom + 60,
                        left: 16,
                        right: 16,
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

extension on _DashboardDestination {
  String get title => switch (this) {
    _DashboardDestination.overview => 'Dashboard',
    _DashboardDestination.expenses => 'Expenses',
    _DashboardDestination.dates => 'Dates',
    _DashboardDestination.shopping => 'Shopping',
    _DashboardDestination.profile => 'Profile',
  };
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
