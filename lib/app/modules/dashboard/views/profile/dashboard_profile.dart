part of '../dashboard_view.dart';

class ProfilePanel extends GetView<DashboardController> {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final profile = controller.profile;
    final name = _profileDisplayName(user, profile);
    final email = user?.email ?? 'Shared planning space';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFBF7), Color(0xFFFFF3EA)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 128),
        child: Column(
          children: [
            Builder(
              builder: (context) {
                final topInset = MediaQuery.paddingOf(context).top;
                return SizedBox(
                  height: topInset + 358,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _ProfileHeader(
                        name: name,
                        email: email,
                        photoUrl: user?.photoURL,
                      ),
                      const Positioned(
                        left: 22,
                        right: 22,
                        bottom: 0,
                        child: _PremiumPlanBanner(),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            _ProfileMenuCard(
              children: [
                _ProfileMenuRow(
                  icon: Icons.account_box_outlined,
                  label: 'Profile Details',
                  subtitle: 'View and edit your profile',
                  onTap: () => showProfileDialog(context),
                ),
                _ProfileMenuRow(
                  icon: Icons.currency_rupee_rounded,
                  label: 'Currency',
                  value: 'INR (₹)',
                  onTap: () => _showProfileSnack('Currency is set to INR.'),
                ),
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeService.themeModeNotifier,
                  builder: (context, mode, child) {
                    final label = mode == ThemeMode.dark ? 'Dark' : 'Light';
                    return _ProfileMenuRow(
                      icon: Icons.light_mode_outlined,
                      label: 'Theme',
                      value: label,
                      trailingIcon: Icons.keyboard_arrow_down_rounded,
                      onTap: () => ThemeService.toggleTheme(),
                    );
                  },
                ),
                _ProfileMenuRow(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notification Settings',
                  subtitle: 'Manage your alerts',
                  onTap: () => _showProfileSnack('Notification settings soon.'),
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
                  onTap: controller.logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReportsPanel extends GetView<DashboardController> {
  const ReportsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = controller.data.value;
      final total = data.totalBudget;
      final paid = data.paid;
      final paidRatio = total <= 0 ? 0.0 : (paid / total).clamp(0.0, 1.0);
      final categoryEntries = _topCategoryEntries(data.categoryTotals);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _ReportMetricCard(
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: ThemeColors.logoGold,
                      label: 'Total Expense',
                      value: '₹${formatMoney(total)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ReportMetricCard(
                      icon: Icons.task_alt_rounded,
                      iconColor: const Color(0xFF209B4B),
                      label: 'Total Paid',
                      value: '₹${formatMoney(paid)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ReportSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ReportTitle('Expense by Category'),
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
                            child: CustomPaint(
                              painter: _CategoryDonutPainter(categoryEntries),
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
                    const _ReportTitle('Paid vs Pending'),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            Expanded(
                              flex: (paidRatio * 1000).round().clamp(1, 999),
                              child: Container(color: const Color(0xFF2DA052)),
                            ),
                            Expanded(
                              flex: ((1 - paidRatio) * 1000).round().clamp(
                                1,
                                999,
                              ),
                              child: Container(color: const Color(0xFFFF6824)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ReportPercentLabel(
                          label: 'Paid',
                          value: '${(paidRatio * 100).round()}%',
                        ),
                        _ReportPercentLabel(
                          label: 'Pending',
                          value: '${((1 - paidRatio) * 100).round()}%',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _printExpensePdf(context, data.expenses),
                style: FilledButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'View Detailed Report',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ReportSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ReportTitle('Your Join Key'),
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
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
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
                        fontWeight: FontWeight.w700,
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
              const _ReportTitle('Collaborators'),
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
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
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
    return Container(
      height: topInset + 310,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
        gradient: RadialGradient(
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
            right: 18,
            top: topInset + 90,
            child: const _ProfileLeafArt(),
          ),
          Positioned(left: 74, top: topInset + 220, child: const _ProfileDot()),
          Padding(
            padding: EdgeInsets.fromLTRB(20, topInset + 32, 20, 0),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  _EditableProfileAvatar(
                    name: name,
                    photoUrl: photoUrl,
                    onTap: () => showProfileDialog(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFF3C873),
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
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
      width: 128,
      height: 116,
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
            child: _ProfileAvatar(name: name, photoUrl: photoUrl, radius: 52),
          ),
          Positioned(
            right: 10,
            bottom: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 50,
                  height: 50,
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
                    size: 26,
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

class _PremiumPlanBanner extends StatelessWidget {
  const _PremiumPlanBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.fromLTRB(28, 18, 22, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFB20B46), Color(0xFF97083A), Color(0xFF7D062F)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8F1438).withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF8F1438).withValues(alpha: 0.42),
              border: Border.all(color: const Color(0xFFF4C84E), width: 1.5),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: Color(0xFFF4C84E),
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Premium Account',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enjoy all premium features',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFF7DFE6),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: const Row(
              children: [
                Text(
                  'Manage Plan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
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
      margin: const EdgeInsets.symmetric(horizontal: 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFF5DED4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          children: [
            SizedBox(
              height: subtitle == null ? 82 : 92,
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
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
                    child: Icon(icon, color: color, size: 29),
                  ),
                  const SizedBox(width: 22),
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
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 5),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ThemeColors.logoDeep.withValues(
                                alpha: 0.62,
                              ),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Icon(
                    trailingIcon,
                    color: ThemeColors.logoDeep.withValues(alpha: 0.58),
                    size: 30,
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
  if (icon == Icons.currency_rupee_rounded ||
      icon == Icons.light_mode_outlined) {
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  const _ReportMetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _ReportSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep.withValues(alpha: 0.76),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _ReportTitle extends StatelessWidget {
  const _ReportTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
    );
  }
}

class _ReportPercentLabel extends StatelessWidget {
  const _ReportPercentLabel({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.76),
          fontWeight: FontWeight.w800,
          fontFamily: DefaultTextStyle.of(context).style.fontFamily,
        ),
        children: [
          TextSpan(text: label),
          const TextSpan(text: '   '),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
            ),
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
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(fontWeight: FontWeight.w900),
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
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      collaborator.role,
                      style: TextStyle(
                        color: ThemeColors.logoDeep.withValues(alpha: 0.72),
                        fontWeight: FontWeight.w800,
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
                fontWeight: FontWeight.w900,
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

void _showProfileSnack(String message) {
  Get.snackbar(
    'Profile',
    message,
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(16),
  );
}
