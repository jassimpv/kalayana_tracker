part of '../dashboard_view.dart';

class ProfilePanel extends GetView<DashboardController> {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = controller.profile;
    final name = _profileDisplayName(user, profile);
    final email = user?.email ?? 'Shared planning space';
    final currency = profileCurrency(profile);
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF7), Color(0xFFFFF3EA)],
        ),
      ),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 108),
        child: ResponsivePageContainer(
          maxWidth: 900,
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  final topInset = MediaQuery.paddingOf(context).top;
                  return SizedBox(
                    height: topInset + 170,
                    child: _ProfileHeader(
                      name: name,
                      email: email,
                      photoUrl: user?.photoURL,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _ProfileMenuCard(
                children: [
                  _ProfileMenuRow(
                    icon: Icons.account_box_outlined,
                    label: 'Profile Details',
                    subtitle: 'View and edit your profile',
                    onTap: () => showProfileDialog(context),
                  ),
                  _ProfileMenuRow(
                    icon: AppConfig.appCurrencyIcon,
                    label: 'Currency',
                    value: '${currency.code} ${currency.symbol}',
                    trailingIcon: Icons.keyboard_arrow_down_rounded,
                    onTap: () => _showCurrencyPicker(context, controller),
                  ),
                  // ValueListenableBuilder<ThemeMode>(
                  //   valueListenable: ThemeService.themeModeNotifier,
                  //   builder: (context, mode, child) {
                  //     final label = mode == ThemeMode.dark ? 'Dark' : 'Light';
                  //     return _ProfileMenuRow(
                  //       icon: Icons.light_mode_outlined,
                  //       label: 'Theme',
                  //       value: label,
                  //       trailingIcon: Icons.keyboard_arrow_down_rounded,
                  //       // onTap: () => ThemeService.toggleTheme(),
                  //     );
                  //   },
                  // ),
                  _ProfileMenuRow(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notification Settings',
                    subtitle: 'Manage your alerts',
                    onTap: () =>
                        _showProfileSnack('Notification settings soon.'),
                  ),
                  _ProfileMenuRow(
                    icon: Icons.bar_chart_rounded,
                    label: 'Reports',
                    subtitle: 'View insights and analytics',
                    onTap: controller.openReports,
                  ),

                  _ProfileMenuRow(
                    icon: Icons.group_add_outlined,
                    label: 'Collaborators',
                    subtitle: 'Invite and manage members',
                    onTap: controller.openCollaborators,
                  ),
                  _ProfileMenuRow(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    subtitle: 'FAQs and contact support',
                    onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _ProfileMenuCard(
                children: [
                  _ProfileMenuRow(
                    icon: Icons.logout_rounded,
                    label: 'Logout',
                    subtitle: 'Sign out from your account',
                    destructive: true,
                    showDivider: false,
                    onTap: () => _confirmLogout(context, controller),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmLogout(
  BuildContext context,
  DashboardController controller,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  await controller.logout();
}

class ReportsPanel extends GetView<DashboardController> {
  const ReportsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.data.value;
      final total = data.effectiveBudget;
      final paid = data.paid;
      final pending = data.pending;
      final repaymentPending = data.repaymentPending;
      final paidRatio = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
      final pendingRatio = total <= 0 ? 0.0 : 1 - paidRatio;
      final categoryEntries = _topCategoryEntries(data.categoryTotals);
      final repaymentExpenses = data.expenses
          .where((item) => item.needsRepayment || item.repaymentAmount > 0)
          .toList();
      final paymentPeople = _personPaymentReports(data.expenses);
      final repaymentPeople = _personRepaymentReports(repaymentExpenses);
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ThemeColors.scaffoldColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: ThemeColors.logoGold.withValues(alpha: 0.12),
          ),
        ),
        child: DashboardAdaptiveScroll(
          overflowTolerance: 8,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: ResponsivePageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReportHeroCard(
                  total: total,
                  paid: paid,
                  pending: pending,
                  repayment: repaymentPending,
                  paidRatio: paidRatio,
                ),
                const SizedBox(height: 14),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReportTitle(
                        'Expense by Category',
                        icon: Icons.pie_chart_rounded,
                        color: ThemeColors.logoGold,
                      ),
                      const SizedBox(height: 12),
                      if (categoryEntries.isEmpty)
                        const PremiumEmptyState(
                          icon: Icons.pie_chart_outline_rounded,
                          title: 'No expenses yet',
                          subtitle: 'Add expenses to see category insights.',
                        )
                      else
                        Row(
                          children: [
                            SizedBox(
                              width: 124,
                              height: 124,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: const Size(124, 124),
                                    painter: _CategoryDonutPainter(
                                      categoryEntries,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 68,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            moneyOrDash(total),
                                            maxLines: 1,
                                            style: const TextStyle(
                                              color: ThemeColors.logoDeep,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            color: ThemeColors.logoDeep
                                                .withValues(alpha: 0.56),
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _CategoryLegend(entries: categoryEntries),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReportTitle(
                        'Total Expense Report',
                        icon: Icons.summarize_rounded,
                        color: ThemeColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _ReportInfoGrid(
                        items: [
                          _ReportInfoSpec(
                            'Total expense',
                            moneyOrDash(total),
                            Icons.receipt_long_rounded,
                            ThemeColors.logoGold,
                          ),
                          _ReportInfoSpec(
                            'Total paid',
                            moneyOrDash(paid),
                            Icons.check_circle_outline_rounded,
                            const Color(0xFF209B4B),
                          ),
                          _ReportInfoSpec(
                            'Pending amount',
                            moneyOrDash(pending),
                            Icons.schedule_rounded,
                            const Color(0xFFFF6824),
                          ),
                          _ReportInfoSpec(
                            'Repayment pending',
                            moneyOrDash(repaymentPending),
                            Icons.assignment_return_rounded,
                            ThemeColors.primary,
                          ),
                          _ReportInfoSpec(
                            'Completed bills',
                            '${data.completedExpenses}',
                            Icons.task_alt_rounded,
                            const Color(0xFF209B4B),
                          ),
                          _ReportInfoSpec(
                            'Pending bills',
                            '${data.pendingExpenses}',
                            Icons.pending_actions_rounded,
                            const Color(0xFFFF6824),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReportTitle(
                        'Detailed Expense Report',
                        icon: Icons.receipt_long_rounded,
                        color: ThemeColors.logoGold,
                      ),
                      const SizedBox(height: 12),
                      if (data.expenses.isEmpty)
                        const PremiumEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'No expense details yet',
                          subtitle: 'Add expenses to build a detailed report.',
                        )
                      else
                        _DetailedExpenseReport(expenses: data.expenses),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReportTitle(
                        'Repayment Report',
                        icon: Icons.assignment_return_rounded,
                        color: ThemeColors.primary,
                      ),
                      const SizedBox(height: 12),
                      _ReportInfoGrid(
                        items: [
                          _ReportInfoSpec(
                            'Total repayment',
                            moneyOrDash(
                              repaymentExpenses.fold<double>(
                                0,
                                (sum, item) => sum + item.repaymentAmount,
                              ),
                            ),
                            AppConfig.appCurrencyIcon,
                            ThemeColors.primary,
                          ),
                          _ReportInfoSpec(
                            'Pending to repay',
                            moneyOrDash(repaymentPending),
                            Icons.assignment_return_rounded,
                            const Color(0xFFFF6824),
                          ),
                          _ReportInfoSpec(
                            'Active repayments',
                            '${repaymentExpenses.where((item) => item.repaymentPending > 0).length}',
                            Icons.pending_actions_rounded,
                            ThemeColors.primary,
                          ),
                          _ReportInfoSpec(
                            'Completed repayments',
                            '${repaymentExpenses.where((item) => item.repaymentPending == 0).length}',
                            Icons.task_alt_rounded,
                            const Color(0xFF209B4B),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (repaymentPeople.isNotEmpty) ...[
                        _PersonRepaymentReportList(entries: repaymentPeople),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ReportTitle(
                        'Paid By Report',
                        icon: Icons.group_rounded,
                        color: ThemeColors.primary,
                      ),
                      const SizedBox(height: 12),
                      if (paymentPeople.isEmpty)
                        const PremiumEmptyState(
                          icon: Icons.group_outlined,
                          title: 'No payment people yet',
                          subtitle: 'Payment payer totals will appear here.',
                        )
                      else
                        _PersonPaymentReportList(entries: paymentPeople),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReportTitle(
                        'Paid vs Pending',
                        icon: Icons.insights_rounded,
                        color: Color(0xFF209B4B),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          height: 14,
                          child: Row(
                            children: [
                              Expanded(
                                flex: total <= 0
                                    ? 1
                                    : (paidRatio * 1000).round().clamp(1, 999),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF2DA052),
                                        Color(0xFF4FC97A),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: total <= 0
                                    ? 1
                                    : (pendingRatio * 1000).round().clamp(
                                        1,
                                        999,
                                      ),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFFF6824),
                                        Color(0xFFFFA15C),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _ReportPercentLabel(
                            label: 'Paid',
                            value: formatPercent(paidRatio),
                            color: const Color(0xFF209B4B),
                          ),
                          const SizedBox(width: 10),
                          _ReportPercentLabel(
                            label: 'Pending',
                            value: formatPercent(pendingRatio),
                            color: const Color(0xFFFF6824),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _printExpensePdf(context, data.expenses),
                        style: FilledButton.styleFrom(
                          backgroundColor: ThemeColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text(
                          'Expenses',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () =>
                            _printExpensePaymentsPdf(context, data.expenses),
                        style: FilledButton.styleFrom(
                          backgroundColor: ThemeColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.payments_rounded, size: 18),
                        label: const Text(
                          'Payment Expenses',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CollaboratorsPanel extends GetView<DashboardController> {
  const CollaboratorsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Obx(() {
      final joinKey = controller.joinCode.value ?? 'Preparing...';
      final collaborators = controller.collaborators.isEmpty
          ? [
              DashboardCollaborator(
                uid: user?.uid ?? '',
                name: _profileDisplayName(user, controller.profile),
                email: user?.email ?? '',
                role: 'Admin',
                photoUrl: user?.photoURL,
              ),
            ]
          : controller.collaborators.toList();
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: ThemeColors.scaffoldColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: ThemeColors.logoGold.withValues(alpha: 0.12),
          ),
        ),
        child: DashboardAdaptiveScroll(
          padding: const EdgeInsets.all(20),
          child: ResponsivePageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ReportSurface(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _ReportTitle(
                        'Your Join Key',
                        icon: Icons.vpn_key_rounded,
                        color: ThemeColors.logoGold,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.66),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEDE2D5)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                joinKey,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: controller.joinCode.value == null
                                  ? null
                                  : () => _copyJoinKey(joinKey),
                              icon: const Icon(Icons.copy_rounded),
                              color: ThemeColors.logoDeep,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share this key with family or friends to sync one wedding plan.',
                        style: TextStyle(
                          color: ThemeColors.logoDeep.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: controller.joinCode.value == null
                                  ? null
                                  : () => _copyJoinKey(joinKey),
                              icon: const Icon(Icons.ios_share_rounded),
                              label: const Text('Share'),
                              style: FilledButton.styleFrom(
                                backgroundColor: ThemeColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(46),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: controller.collaborationLoading.value
                                  ? null
                                  : () => _showJoinWorkspaceDialog(context),
                              icon: const Icon(Icons.group_add_outlined),
                              label: const Text('Join'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ThemeColors.primary,
                                minimumSize: const Size.fromHeight(46),
                                side: BorderSide(color: ThemeColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _ReportTitle(
                  'Collaborators',
                  icon: Icons.group_rounded,
                  color: ThemeColors.primary,
                ),
                const SizedBox(height: 12),
                _CollaboratorList(collaborators: collaborators),
                const SizedBox(height: 40),
                FilledButton(
                  onPressed: () =>
                      _showProfileSnack('Activity logs coming soon.'),
                  style: FilledButton.styleFrom(
                    backgroundColor: ThemeColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Activity Logs',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    // On mobile this banner bleeds edge-to-edge under the status bar, so
    // only the bottom corners are rounded. On tablet/desktop it's rendered
    // as a centered, margined card (see ResponsivePageContainer), so it
    // needs all four corners rounded or the flat top reads as clipped.
    final radius = const Radius.circular(24);
    final borderRadius = isMobile(context)
        ? BorderRadius.vertical(bottom: radius)
        : BorderRadius.all(radius);
    return Container(
      height: topInset + 238,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.18,
          colors: [Color(0xFFC50B50), Color(0xFF9D073E), Color(0xFF75062E)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: -84,
            top: -152,
            child: _ProfileHalo(size: 260, alpha: 0.16),
          ),
          const Positioned(
            left: -48,
            bottom: -38,
            child: _ProfileHalo(size: 150, alpha: 0.12),
          ),
          Positioned(
            right: -84,
            bottom: -26,
            child: Container(
              width: 232,
              height: 232,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ThemeColors.logoGold.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Positioned(
            right: 10,
            top: topInset + 70,
            child: const _ProfileLeafArt(),
          ),
          Positioned(left: 64, top: topInset + 172, child: const _ProfileDot()),
          Padding(
            padding: EdgeInsets.fromLTRB(18, topInset + 22, 18, 0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  _EditableProfileAvatar(
                    name: name,
                    photoUrl: photoUrl,
                    onTap: () => showProfileDialog(context),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF3C873),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

class _ProfileHalo extends StatelessWidget {
  const _ProfileHalo({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE54F7B).withValues(alpha: alpha),
        border: Border.all(
          color: ThemeColors.logoGold.withValues(alpha: alpha * 1.2),
        ),
      ),
    );
  }
}

class _ProfileLeafArt extends StatelessWidget {
  const _ProfileLeafArt();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(98, 122),
      painter: _ProfileLeafPainter(),
    );
  }
}

class _ProfileLeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeColors.logoGold.withValues(alpha: 0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    final stem = Path()
      ..moveTo(size.width * 0.22, size.height)
      ..cubicTo(
        size.width * 0.54,
        size.height * 0.72,
        size.width * 0.48,
        size.height * 0.34,
        size.width * 0.86,
        0,
      );
    canvas.drawPath(stem, paint);
    for (var i = 0; i < 8; i++) {
      final t = i / 8;
      final x = size.width * (0.25 + 0.52 * t);
      final y = size.height * (0.88 - 0.78 * t);
      final side = i.isEven ? 1.0 : -1.0;
      final leaf = Path()
        ..moveTo(x, y)
        ..cubicTo(
          x + side * 18,
          y - 18,
          x + side * 34,
          y - 8,
          x + side * 28,
          y + 18,
        )
        ..cubicTo(x + side * 13, y + 18, x + side * 5, y + 8, x, y);
      canvas.drawPath(leaf, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProfileDot extends StatelessWidget {
  const _ProfileDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFE8B75C), Color(0xFFC94F3D)],
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoGold.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileAvatar extends StatelessWidget {
  const _EditableProfileAvatar({
    required this.name,
    required this.photoUrl,
    required this.onTap,
  });

  final String name;
  final String? photoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.88),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.logoGold.withValues(alpha: 0.28),
                  blurRadius: 0,
                  spreadRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _ProfileAvatar(name: name, photoUrl: photoUrl, radius: 40),
          ),
          Positioned(
            right: 8,
            bottom: 2,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFF3D2DD),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: ThemeColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF5DED4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.label,
    this.subtitle,
    this.value,
    this.trailingIcon = Icons.chevron_right_rounded,
    this.destructive = false,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final String? value;
  final IconData trailingIcon;
  final bool destructive;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? const Color(0xFFE34944)
        : _profileIconColor(icon);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            SizedBox(
              height: subtitle == null ? 60 : 68,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: color.withValues(alpha: 0.10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color.withValues(alpha: 0.10),
                          ThemeColors.logoGold.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeColors.logoDeep.withValues(
                                alpha: 0.62,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (value != null) ...[
                    Text(
                      value!,
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.68),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    trailingIcon,
                    color: ThemeColors.logoDeep.withValues(alpha: 0.58),
                    size: 22,
                  ),
                ],
              ),
            ),
            if (showDivider)
              Divider(
                height: 1,
                thickness: 1,
                color: ThemeColors.logoGold.withValues(alpha: 0.12),
              ),
          ],
        ),
      ),
    );
  }
}

Color _profileIconColor(IconData icon) {
  if (icon == AppConfig.appCurrencyIcon || icon == Icons.light_mode_outlined) {
    return ThemeColors.logoGold;
  }
  if (icon == Icons.bar_chart_rounded || icon == Icons.group_add_outlined) {
    return const Color(0xFFE46D3D);
  }
  if (icon == Icons.help_outline_rounded) return const Color(0xFFD95245);
  return ThemeColors.primary;
}

class _ReportSurface extends StatelessWidget {
  const _ReportSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReportHeroCard extends StatelessWidget {
  const _ReportHeroCard({
    required this.total,
    required this.paid,
    required this.pending,
    required this.repayment,
    required this.paidRatio,
  });

  final double total;
  final double paid;
  final double pending;
  final double repayment;
  final double paidRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.3,
          colors: [Color(0xFFC71053), Color(0xFF8F1438), Color(0xFF5A0820)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Total Budget',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${AppConfig.appCurrency}${formatMoney(total)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  Container(color: Colors.white.withValues(alpha: 0.18)),
                  FractionallySizedBox(
                    widthFactor: paidRatio.clamp(0.0, 1.0),
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF7C859), Color(0xFFE8A64E)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  icon: Icons.task_alt_rounded,
                  label: 'Paid',
                  value: '${AppConfig.appCurrency}${formatMoney(paid)}',
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _HeroStat(
                  icon: Icons.schedule_rounded,
                  label: 'Pending',
                  value: '${AppConfig.appCurrency}${formatMoney(pending)}',
                ),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _HeroStat(
                  icon: Icons.assignment_return_rounded,
                  label: 'Repay',
                  value: '${AppConfig.appCurrency}${formatMoney(repayment)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.78),
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ReportTitle extends StatelessWidget {
  const _ReportTitle(this.text, {this.icon, this.color});

  final String text;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? ThemeColors.primary;
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 16),
          ),
          const SizedBox(width: 10),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: ThemeColors.logoDeep,
          ),
        ),
      ],
    );
  }
}

class _ReportPercentLabel extends StatelessWidget {
  const _ReportPercentLabel({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            '$label  $value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportInfoGrid extends StatelessWidget {
  const _ReportInfoGrid({required this.items});

  final List<_ReportInfoSpec> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 560;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (item) => SizedBox(
                  width: isWide
                      ? (constraints.maxWidth - 10) / 2
                      : constraints.maxWidth,
                  child: _ReportInfoTile(item: item),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ReportInfoTile extends StatelessWidget {
  const _ReportInfoTile({required this.item});

  final _ReportInfoSpec item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: item.color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep.withValues(alpha: 0.70),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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

class _DetailedExpenseReport extends StatelessWidget {
  const _DetailedExpenseReport({required this.expenses});

  final List<ExpenseItem> expenses;

  @override
  Widget build(BuildContext context) {
    final sorted = expenses.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return Column(
      children: sorted
          .map(
            (item) => _ReportListRow(
              icon: Icons.receipt_long_rounded,
              iconColor: ThemeColors.logoGold,
              title: item.name.isEmpty ? 'Untitled expense' : item.name,
              subtitle:
                  '${item.category} | ${item.status} | Paid by ${item.displayPaidBy}',
              trailingTitle: moneyOrDash(item.totalAmount),
              trailingSubtitle:
                  '${moneyOrDash(item.paidForSummary)} paid | ${moneyOrDash(item.pendingForSummary)} pending',
            ),
          )
          .toList(),
    );
  }
}

class _PersonPaymentReportList extends StatelessWidget {
  const _PersonPaymentReportList({required this.entries});

  final List<_PersonPaymentReport> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map(
            (entry) => _ReportListRow(
              icon: Icons.person_rounded,
              iconColor: ThemeColors.primary,
              title: entry.name,
              subtitle:
                  '${entry.paymentCount} payment${entry.paymentCount == 1 ? '' : 's'}',
              trailingTitle: moneyOrDash(entry.amount),
              trailingSubtitle: 'Total paid',
            ),
          )
          .toList(),
    );
  }
}

class _PersonRepaymentReportList extends StatelessWidget {
  const _PersonRepaymentReportList({required this.entries});

  final List<_PersonRepaymentReport> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: entries
          .map(
            (entry) => _ReportListRow(
              icon: Icons.assignment_return_rounded,
              iconColor: entry.pending > 0
                  ? ThemeColors.primary
                  : const Color(0xFF209B4B),
              title: entry.name,
              subtitle:
                  '${entry.itemCount} repayment item${entry.itemCount == 1 ? '' : 's'}',
              trailingTitle: moneyOrDash(entry.total),
              trailingSubtitle: '${moneyOrDash(entry.pending)} pending',
            ),
          )
          .toList(),
    );
  }
}

class _ReportListRow extends StatelessWidget {
  const _ReportListRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingTitle,
    required this.trailingSubtitle,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String trailingTitle;
  final String trailingSubtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep.withValues(alpha: 0.62),
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
                trailingTitle,
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
                trailingSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ThemeColors.logoDeep.withValues(alpha: 0.60),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryLegend extends StatelessWidget {
  const _CategoryLegend({required this.entries});

  final List<_CategoryReportEntry> entries;

  @override
  Widget build(BuildContext context) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.amount);
    return Column(
      children: entries.map((entry) {
        final percent = total <= 0 ? 0 : (entry.amount / total * 100).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  entry.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryDonutPainter extends CustomPainter {
  const _CategoryDonutPainter(this.entries);

  final List<_CategoryReportEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<double>(0, (sum, entry) => sum + entry.amount);
    final rect = Offset.zero & size;
    final stroke = size.shortestSide * 0.32;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    var start = -math.pi / 2;
    for (final entry in entries) {
      final sweep = total <= 0 ? 0.0 : (entry.amount / total) * math.pi * 2;
      paint.color = entry.color;
      canvas.drawArc(rect.deflate(stroke / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryDonutPainter oldDelegate) {
    return oldDelegate.entries != entries;
  }
}

class _CollaboratorList extends StatelessWidget {
  const _CollaboratorList({required this.collaborators});

  final List<DashboardCollaborator> collaborators;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.13)),
      ),
      child: Column(
        children: collaborators.asMap().entries.map((entry) {
          final collaborator = entry.value;
          final isLast = entry.key == collaborators.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    _ProfileAvatar(
                      name: collaborator.name,
                      photoUrl: collaborator.photoUrl,
                      radius: 20,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        collaborator.uid ==
                                FirebaseAuth.instance.currentUser?.uid
                            ? '${collaborator.name} (You)'
                            : collaborator.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      collaborator.role,
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: ThemeColors.logoGold.withValues(alpha: 0.12),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.photoUrl,
    required this.radius,
  });

  final String name;
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();
    return CircleAvatar(
      radius: radius,
      backgroundColor: ThemeColors.logoGold.withValues(alpha: 0.28),
      backgroundImage: imageUrl == null || imageUrl.isEmpty
          ? null
          : NetworkImage(imageUrl),
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              _profileInitials(name),
              style: TextStyle(
                color: ThemeColors.primary,
                fontSize: radius * 0.58,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

class _CategoryReportEntry {
  const _CategoryReportEntry(this.label, this.amount, this.color);

  final String label;
  final double amount;
  final Color color;
}

class _ReportInfoSpec {
  const _ReportInfoSpec(this.label, this.value, this.icon, this.color);

  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _PersonPaymentReport {
  const _PersonPaymentReport(this.name, this.amount, this.paymentCount);

  final String name;
  final double amount;
  final int paymentCount;
}

class _PersonRepaymentReport {
  const _PersonRepaymentReport(
    this.name,
    this.total,
    this.pending,
    this.itemCount,
  );

  final String name;
  final double total;
  final double pending;
  final int itemCount;
}

List<_CategoryReportEntry> _topCategoryEntries(Map<String, double> totals) {
  const colors = [
    Color(0xFF2E79A8),
    Color(0xFF2E964B),
    Color(0xFFFF8D1E),
    Color(0xFFFFB12A),
    Color(0xFFFF4F35),
    Color(0xFFB04BC4),
  ];
  final sorted = totals.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  if (sorted.length <= 6) {
    return [
      for (var index = 0; index < sorted.length; index++)
        _CategoryReportEntry(
          sorted[index].key,
          sorted[index].value,
          colors[index],
        ),
    ];
  }
  final top = sorted.take(5).toList();
  final others = sorted
      .skip(5)
      .fold<double>(0, (sum, item) => sum + item.value);
  return [
    for (var index = 0; index < top.length; index++)
      _CategoryReportEntry(top[index].key, top[index].value, colors[index]),
    _CategoryReportEntry('Others', others, colors.last),
  ];
}

List<_PersonPaymentReport> _personPaymentReports(List<ExpenseItem> expenses) {
  final totals = <String, double>{};
  final counts = <String, int>{};
  for (final expense in expenses) {
    if (expense.paymentSplit.isEmpty && expense.paidForSummary > 0) {
      final name = expense.displayPaidBy.trim().isEmpty
          ? 'Self'
          : expense.displayPaidBy.trim();
      totals[name] = (totals[name] ?? 0) + expense.paidForSummary;
      counts[name] = (counts[name] ?? 0) + 1;
      continue;
    }

    for (final payment in expense.paymentSplit) {
      if (payment.amount <= 0) continue;
      final name = payment.displayPaidBy.trim().isEmpty
          ? 'Self'
          : payment.displayPaidBy.trim();
      totals[name] = (totals[name] ?? 0) + payment.amount;
      counts[name] = (counts[name] ?? 0) + 1;
    }
  }

  final entries =
      totals.entries
          .map(
            (entry) => _PersonPaymentReport(
              entry.key,
              entry.value,
              counts[entry.key] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) => b.amount.compareTo(a.amount));
  return entries;
}

List<_PersonRepaymentReport> _personRepaymentReports(
  List<ExpenseItem> expenses,
) {
  final totals = <String, double>{};
  final pending = <String, double>{};
  final counts = <String, int>{};
  for (final expense in expenses) {
    final name = expense.repayPerson.trim().isEmpty
        ? expense.displayPaidBy
        : expense.repayPerson.trim();
    final normalizedName = name.trim().isEmpty ? 'Self' : name.trim();
    totals[normalizedName] =
        (totals[normalizedName] ?? 0) + expense.repaymentAmount;
    pending[normalizedName] =
        (pending[normalizedName] ?? 0) + expense.repaymentPending;
    counts[normalizedName] = (counts[normalizedName] ?? 0) + 1;
  }

  final entries =
      totals.entries
          .map(
            (entry) => _PersonRepaymentReport(
              entry.key,
              entry.value,
              pending[entry.key] ?? 0,
              counts[entry.key] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) => b.pending.compareTo(a.pending));
  return entries;
}

String _profileDisplayName(User? user, Map<String, dynamic> profile) {
  final displayName = user?.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) return displayName;
  final groom = profileGroom(profile);
  if (groom.isNotEmpty) return groom;
  final bride = profileBride(profile);
  if (bride.isNotEmpty) return bride;
  final email = user?.email;
  if (email != null && email.contains('@')) return email.split('@').first;
  return '-';
}

String _profileInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'K';
  return parts.take(2).map((part) => part[0].toUpperCase()).join();
}

void _copyJoinKey(String key) {
  Clipboard.setData(ClipboardData(text: key));
  _showProfileSnack('Join key copied.');
}

Future<void> _showJoinWorkspaceDialog(BuildContext context) async {
  final controller = Get.find<DashboardController>();
  final codeController = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Join Workspace'),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Join code',
            hintText: 'KALY-XXXX-XXXX',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final code = codeController.text.trim();
              Navigator.of(context).pop();
              controller.joinWorkspace(code);
            },
            child: const Text('Join'),
          ),
        ],
      );
    },
  );
  codeController.dispose();
}

Future<void> _showCurrencyPicker(
  BuildContext context,
  DashboardController controller,
) async {
  if (isDesktop(context)) {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.46),
      builder: (context) {
        final height = math.min(MediaQuery.sizeOf(context).height - 96, 720.0);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 40,
            vertical: 32,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 620, maxHeight: height),
            child: _CurrencyPickerPanel(
              controller: controller,
              borderRadius: BorderRadius.circular(26),
              showHandle: false,
            ),
          ),
        );
      },
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _CurrencyPickerSheet(controller: controller),
  );
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({required this.controller});
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.56,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return _CurrencyPickerPanel(
          controller: controller,
          scrollController: scrollController,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          showHandle: true,
        );
      },
    );
  }
}

class _CurrencyPickerPanel extends StatefulWidget {
  const _CurrencyPickerPanel({
    required this.controller,
    required this.borderRadius,
    required this.showHandle,
    this.scrollController,
  });

  final DashboardController controller;
  final BorderRadiusGeometry borderRadius;
  final bool showHandle;
  final ScrollController? scrollController;

  @override
  State<_CurrencyPickerPanel> createState() => _CurrencyPickerPanelState();
}

class _CurrencyPickerPanelState extends State<_CurrencyPickerPanel> {
  late final TextEditingController _search;
  late List<CurrencyOption> _results;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _results = CurrencySymbolApi.options;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = profileCurrency(widget.controller.profile);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Material(
      color: const Color(0xFFFFFBF7),
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHandle) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ThemeColors.primary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: _CurrencyPickerHeader(current: current),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
            child: _CurrencySearchField(
              controller: _search,
              onChanged: (value) {
                setState(() => _results = CurrencySymbolApi.search(value));
              },
            ),
          ),
          Expanded(
            child: _results.isEmpty
                ? const _CurrencyEmptyState()
                : ListView.separated(
                    controller: widget.scrollController,
                    padding: EdgeInsets.fromLTRB(18, 0, 18, 18 + bottomPadding),
                    itemBuilder: (context, index) {
                      final option = _results[index];
                      return _CurrencyOptionTile(
                        currency: option,
                        selected: option.code == current.code,
                        onTap: () async {
                          await widget.controller.saveProfile(
                            groom: profileGroom(widget.controller.profile),
                            bride: profileBride(widget.controller.profile),
                            weddingDate: profileMarriageDate(
                              widget.controller.profile,
                            ),
                            currency: option,
                          );
                          if (context.mounted) Navigator.pop(context);
                        },
                      );
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemCount: _results.length,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPickerHeader extends StatelessWidget {
  const _CurrencyPickerHeader({required this.current});

  final CurrencyOption current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 1.28,
          colors: [Color(0xFFC71053), Color(0xFF9D1740), Color(0xFF751030)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Text(
              current.symbol,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose currency',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${current.code}  ${current.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Currently active across your budget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFFF7C859).withValues(alpha: 0.92),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
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

class _CurrencySearchField extends StatelessWidget {
  const _CurrencySearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: true,
      onChanged: onChanged,
      cursorColor: ThemeColors.primary,
      style: const TextStyle(
        color: ThemeColors.logoDeep,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search code, name, or symbol',
        hintStyle: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.42),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: ThemeColors.primary.withValues(alpha: 0.72),
        ),
        suffixIcon: Icon(
          Icons.tune_rounded,
          color: ThemeColors.logoGold.withValues(alpha: 0.92),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.92),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0D7D2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFF0D7D2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: ThemeColors.primary.withValues(alpha: 0.42),
          ),
        ),
      ),
    );
  }
}

class _CurrencyOptionTile extends StatelessWidget {
  const _CurrencyOptionTile({
    required this.currency,
    required this.selected,
    required this.onTap,
  });

  final CurrencyOption currency;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? ThemeColors.primary.withValues(alpha: 0.38)
        : const Color(0xFFF0D7D2);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: selected
                ? ThemeColors.primary.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? ThemeColors.primary
                      : ThemeColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  currency.symbol,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : ThemeColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          currency.code,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currency.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeColors.logoDeep.withValues(
                                alpha: 0.78,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Symbol ${currency.symbol}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.52),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected
                    ? ThemeColors.primary
                    : ThemeColors.logoDeep.withValues(alpha: 0.38),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrencyEmptyState extends StatelessWidget {
  const _CurrencyEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: ThemeColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: ThemeColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No currency found',
              style: TextStyle(
                color: ThemeColors.logoDeep,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Try searching by code, country currency name, or symbol.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ThemeColors.logoDeep.withValues(alpha: 0.62),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showProfileSnack(String message) {
  Get.snackbar(
    'Profile',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );
}
