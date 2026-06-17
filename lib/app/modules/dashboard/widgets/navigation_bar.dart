import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/app_logo.dart';

import '../controllers/dashboard_controller.dart';
import 'dashboard_widgets.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.controller,
    required this.onItemClick,
  });

  final DashboardController controller;
  final ValueChanged<int> onItemClick;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: Container(
        height: MediaQuery.of(context).padding.bottom + 72,
        padding: EdgeInsets.only(
          top: 12,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.84),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(
            color: ThemeColors.primary.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: ThemeColors.logoDeep.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.85),
              blurRadius: 12,
              offset: const Offset(0, -4),
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
                  onTap: () => onItemClick(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7A1230), Color(0xFF9D1740)],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? item.selectedIcon : item.icon,
                          size: 21,
                          color: selected ? Colors.white : ThemeColors.primary,
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 220),
                          style: TextStyle(
                            color: selected
                                ? Colors.white
                                : ThemeColors.primary,
                            fontSize: 10.5,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
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
    );
  }
}

class DashboardSideMenu extends StatelessWidget {
  const DashboardSideMenu({
    super.key,
    required this.controller,
    required this.onItemClick,
  });

  final DashboardController controller;
  final ValueChanged<int> onItemClick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        border: Border(
          right: BorderSide(color: ThemeColors.primary.withValues(alpha: 0.10)),
        ),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.07),
            blurRadius: 28,
            offset: const Offset(12, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const AppLogo(size: 48, padding: 4),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Kalyana',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemeColors.logoDeep,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Obx(
                () => Column(
                  children: navDestinations.asMap().entries.map((entry) {
                    final selected =
                        controller.selectedIndex.value == entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _SideMenuItem(
                        label: item.label,
                        icon: selected ? item.selectedIcon : item.icon,
                        selected: selected,
                        onTap: () => onItemClick(entry.key),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideMenuItem extends StatelessWidget {
  const _SideMenuItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7A1230), Color(0xFF9D1740)],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : ThemeColors.primary,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : ThemeColors.logoDeep,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
