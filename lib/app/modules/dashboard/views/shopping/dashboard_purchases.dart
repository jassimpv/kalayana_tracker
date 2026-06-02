part of '../dashboard_view.dart';

class PurchasesPanel extends StatefulWidget {
  const PurchasesPanel({super.key, required this.purchases});

  final List<PurchaseItem> purchases;

  @override
  State<PurchasesPanel> createState() => _PurchasesPanelState();
}

class _PurchasesPanelState extends State<PurchasesPanel> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PurchaseItem> get _filteredPurchases {
    final query = _searchQuery.trim().toLowerCase();
    return widget.purchases.where((item) {
      final purchased = item.status == 'Purchased';
      if (_selectedFilter == 'Pending' && purchased) {
        return false;
      }
      if (_selectedFilter == 'Purchased' && !purchased) {
        return false;
      }
      if (query.isEmpty) return true;
      final searchable = '${item.name} ${item.category} ${item.note}'
          .toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _filteredPurchases
      ..sort((a, b) {
        final aDone = a.status == 'Purchased';
        final bDone = b.status == 'Purchased';
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.name.compareTo(b.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PurchaseSearchField(
          controller: _searchController,
          onChanged: (value) => setState(() {
            _searchQuery = value;
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: ['All', 'Pending', 'Purchased']
              .map(
                (filter) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _PurchaseFilterChip(
                    label: filter,
                    selected: _selectedFilter == filter,
                    onTap: () => setState(() {
                      _selectedFilter = filter;
                    }),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 18),
        visible.isEmpty
            ? PremiumEmptyState(
                icon: Icons.filter_alt_off_rounded,
                title: _selectedFilter == 'All'
                    ? 'No wishlist items yet'
                    : 'No $_selectedFilter items',
                subtitle: _selectedFilter == 'All'
                    ? 'Add outfits, gifts, jewelry, decor, and booking purchases.'
                    : 'Try another filter or search term to find more items.',
              )
            : Column(
                children: visible
                    .map((item) => _PurchaseListCard(item: item))
                    .toList(),
              ),
      ],
    );
  }
}

class _PurchaseSearchField extends StatelessWidget {
  const _PurchaseSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: ThemeColors.primary,
      decoration: InputDecoration(
        hintText: 'Search items...',
        hintStyle: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.38),
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: ThemeColors.logoDeep.withValues(alpha: 0.45),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.66),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.18),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.18),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: ThemeColors.primary.withValues(alpha: 0.32),
          ),
        ),
      ),
    );
  }
}

class _PurchaseFilterChip extends StatelessWidget {
  const _PurchaseFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? ThemeColors.primary : const Color(0xFFFFF0DB),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? ThemeColors.primary
                  : ThemeColors.logoGold.withValues(alpha: 0.08),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.22),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseListCard extends GetView<DashboardController> {
  const _PurchaseListCard({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    final purchased = item.status == 'Purchased';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.74),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showPurchaseDialog(context, purchase: item),
          child: Container(
            constraints: const BoxConstraints(minHeight: 102),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE5D9)),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.logoDeep.withValues(alpha: 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: ThemeColors.logoDeep.withValues(alpha: 0.86),
                    size: 38,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty ? 'Untitled item' : item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        '₹${formatMoney(item.amount)}',
                        style: TextStyle(
                          color: ThemeColors.logoDeep.withValues(alpha: 0.82),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ShoppingStatusPill(
                  label: purchased ? 'Purchased' : 'Pending',
                  purchased: purchased,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShoppingStatusPill extends StatelessWidget {
  const _ShoppingStatusPill({required this.label, required this.purchased});

  final String label;
  final bool purchased;

  @override
  Widget build(BuildContext context) {
    final color = purchased ? const Color(0xFF258F48) : const Color(0xFFE95C24);
    final background = purchased
        ? const Color(0xFFDDF2D5)
        : const Color(0xFFFFF0D0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
