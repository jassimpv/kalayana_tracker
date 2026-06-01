import 'package:flutter/material.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/data/models/expense_item.dart';

class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          SoftIcon(icon: icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 12,
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

class SoftIcon extends StatelessWidget {
  const SoftIcon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: color, size: 21),
    );
  }
}

String expenseShortStatus(ExpenseItem item) {
  if (item.isCompleted) return 'Paid';
  if (item.hasPartialPayment) return 'Partial';
  return 'Pending';
}

Color expenseStatusColor(ExpenseItem item) {
  if (item.isCompleted) return const Color(0xFF2E9B67);
  if (item.hasPartialPayment) return const Color(0xFFFF9D2E);
  return ThemeColors.logoGold;
}

class ExpenseDetailSurface extends StatelessWidget {
  const ExpenseDetailSurface({
    super.key,
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.logoGold.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.logoDeep.withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ExpenseStatusBadge extends StatelessWidget {
  const ExpenseStatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
