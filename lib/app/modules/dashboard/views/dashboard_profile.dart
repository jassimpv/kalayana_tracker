part of 'dashboard_view.dart';

class ProfilePanel extends GetView<DashboardController> {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Obx(() {
      final profile = controller.profile;
      final date = profileMarriageDate(profile);
      final couple = _coupleName(profile);
      final days = daysUntilDate(date);
      final data = controller.data.value;
      final done = data.completedExpenses + data.purchasedItems;
      final progress = done + data.openReminders == 0
          ? 0.0
          : done / (done + data.openReminders);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PremiumSurface(
            padding: EdgeInsets.zero,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [ThemeColors.weddingTeal, Color(0xFFF1E3D2)],
            ),
            child: Stack(
              children: [
                const Positioned(
                  right: -40,
                  top: -42,
                  child: _BlurCircle(
                    color: Colors.white,
                    size: 160,
                    alpha: 0.18,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _CoupleAvatar(name: couple),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  couple ?? 'Couple profile',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                Text(
                                  user?.email ?? 'Shared planning space',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.76),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton.filled(
                            onPressed: () => showProfileDialog(context),
                            icon: const Icon(Icons.edit_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: ThemeColors.weddingTeal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        date == null
                            ? 'Wedding date not set'
                            : '${formatDate(date)} | ${days == null
                                  ? 'Countdown ready'
                                  : days <= 0
                                  ? 'Today'
                                  : '$days days left'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // _CoupleCollaborationCard(
          //   coupleName: couple,
          //   done: done,
          //   open: data.openReminders,
          // ),
          // const SizedBox(height: 18),
          _PremiumSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Settings', action: 'Personalized'),
                const SizedBox(height: 14),
                // _SettingsRow(
                //   icon: Icons.family_restroom_rounded,
                //   label: 'Family collaboration',
                //   value: '4 invitees ready',
                // ),
                // _SettingsRow(
                //   icon: Icons.palette_rounded,
                //   label: 'Theme personalization',
                //   value: 'Emerald and gold',
                // ),
                // _SettingsRow(
                //   icon: Icons.workspace_premium_rounded,
                //   label: 'Premium subscription',
                //   value: 'Planner Pro preview',
                // ),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy policy',
                  value: 'Open legal page',
                  onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                ),
                _SettingsRow(
                  icon: Icons.delete_forever_rounded,
                  label: 'Delete account',
                  value: 'Verification required',
                  onTap: () => Get.toNamed(AppRoutes.deleteAccount),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _PremiumSurface(
            child: Row(
              children: [
                _ProgressRing(
                  progress: progress.clamp(0.0, 1.0),
                  color: ThemeColors.logoGold,
                  size: 86,
                  center: Text(
                    '${(progress * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Your shared planning workspace is calm, synced, and ready for the next family decision.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      );
    });
  }
}

class _ScreenHero extends StatelessWidget {
  const _ScreenHero({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PremiumSurface(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFCF8), Color(0xFFF1E3D2)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;
          final titleBlock = Row(
            children: [
              SoftIcon(icon: icon, color: scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: wide ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900, height: 1.02),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      maxLines: wide ? 1 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: scheme.outline,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
          final action = FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionLabel),
          );
          if (!wide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleBlock,
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: action),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 18),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Row(
          children: [
            SoftIcon(icon: icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              onTap == null
                  ? Icons.chevron_right_rounded
                  : Icons.open_in_new_rounded,
              color: ThemeColors.weddingTeal,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

String? _coupleName(Map<String, dynamic> profile) {
  final groom = profileGroom(profile);
  final bride = profileBride(profile);
  if (groom.isNotEmpty && bride.isNotEmpty) return '$groom & $bride';
  if (groom.isNotEmpty) return groom;
  if (bride.isNotEmpty) return bride;
  return null;
}
