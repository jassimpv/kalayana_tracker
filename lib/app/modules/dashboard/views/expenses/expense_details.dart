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
          color: ThemeColors.scaffoldColor,
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
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
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
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: ThemeColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: ThemeColors.logoDeep.withValues(
                    alpha: 0.74,
                  ),
                  tabs: const [
                    SizedBox(
                      height: 52,
                      child: Center(child: Text('Overview')),
                    ),
                    SizedBox(
                      height: 52,
                      child: Center(child: Text('Timeline')),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: item == null
                    ? const SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 120),
                        child: PremiumEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'Expense not found',
                          subtitle: 'This expense may have been deleted.',
                        ),
                      )
                    : TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                            child: ExpenseDetailOverview(item: item),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
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
