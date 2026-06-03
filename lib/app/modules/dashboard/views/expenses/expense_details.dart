import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_overview.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/expenses/expense_timeline.dart';

import '../../widgets/expense_widgets.dart';

class ExpenseDetailPage extends GetView<DashboardController> {
  const ExpenseDetailPage({super.key, required this.expenseId});

  final String? expenseId;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final item = controller.data.value.expenses.firstWhereOrNull(
        (entry) => entry.id == expenseId,
      );

      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TabBar(
                  labelPadding: EdgeInsets.zero,
                  indicatorPadding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                  dividerHeight: 0,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: ThemeColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ThemeColors.logoDeep.withValues(
                    alpha: 0.74,
                  ),
                  tabs: const [
                    SizedBox(
                      height: 40,
                      child: Center(child: Text('Overview')),
                    ),
                    SizedBox(
                      height: 40,
                      child: Center(child: Text('Timeline')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: item == null
                    ? const SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(12, 8, 12, 96),
                        child: PremiumEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Expense not found',
                          subtitle: 'This expense may have been deleted.',
                        ),
                      )
                    : TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 96),
                            child: ExpenseDetailOverview(item: item),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(12, 6, 12, 96),
                            child: ExpenseDetailTimeline(item: item),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
