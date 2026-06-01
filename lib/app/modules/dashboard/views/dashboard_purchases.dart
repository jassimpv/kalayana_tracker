part of 'dashboard_view.dart';

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
      if (_selectedFilter == 'Pending' && item.status != 'Pending') {
        return false;
      }
      if (_selectedFilter == 'Purchased' && item.status != 'Purchased') {
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
    final sorted = [...widget.purchases]
      ..sort((a, b) {
        final aDone = a.status == 'Purchased';
        final bDone = b.status == 'Purchased';
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.name.compareTo(b.name);
      });
    final visible = _filteredPurchases
      ..sort((a, b) {
        final aDone = a.status == 'Purchased';
        final bDone = b.status == 'Purchased';
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.name.compareTo(b.name);
      });
    final done = sorted.where((item) => item.status == 'Purchased').length;
    final ordered = sorted.where((item) => item.status == 'Ordered').length;
    final planned = sorted.where((item) => item.status == 'Planned').length;
    final open = sorted.length - done;
    final progress = sorted.isEmpty ? 0.0 : done / sorted.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ScreenHero(
          eyebrow: 'Shopping atelier',
          title: 'Wedding wishlist',
          subtitle: '${sorted.length} curated items | $open still open',
          icon: Icons.shopping_bag_rounded,
          actionLabel: 'Add item',
          onAction: () => showPurchaseDialog(context),
        ),
        const SizedBox(height: 18),
        _PurchaseSummaryCard(
          itemCount: sorted.length,
          purchased: done,
          open: open,
          progress: progress,
        ),
        const SizedBox(height: 18),
        _PurchaseStatusStrip(
          itemCount: sorted.length,
          planned: planned,
          ordered: ordered,
          purchased: done,
        ),
        const SizedBox(height: 18),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Shopping list',
                    action: 'Review',
                  ),
                  const SizedBox(height: 12),
                  ...visible.map((item) => _PurchaseListCard(item: item)),
                ],
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
      decoration: InputDecoration(
        hintText: 'Search items...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.74),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.22),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: ThemeColors.logoGold.withValues(alpha: 0.22),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? ThemeColors.primary : const Color(0xFFFFEED7),
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.20),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : ThemeColors.logoDeep,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseSummaryCard extends StatelessWidget {
  const _PurchaseSummaryCard({
    required this.itemCount,
    required this.purchased,
    required this.open,
    required this.progress,
  });

  final int itemCount;
  final int purchased;
  final int open;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Row(
        children: [
          _ProgressRing(
            progress: progress,
            color: ThemeColors.weddingTeal,
            size: 104,
            stroke: 10,
            center: Text(
              '${(progress * 100).round()}%',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$itemCount items',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'shopping checklist',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                _LegendRow(
                  color: ThemeColors.weddingTeal,
                  label: 'Purchased',
                  value: '$purchased',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: ThemeColors.logoGold,
                  label: 'Still open',
                  value: '$open of $itemCount',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseStatusStrip extends StatelessWidget {
  const _PurchaseStatusStrip({
    required this.itemCount,
    required this.planned,
    required this.ordered,
    required this.purchased,
  });

  final int itemCount;
  final int planned;
  final int ordered;
  final int purchased;

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MiniExpenseMetric(
        icon: Icons.shopping_bag_rounded,
        label: 'Items',
        value: '$itemCount',
        color: ThemeColors.weddingTeal,
      ),
      _MiniExpenseMetric(
        icon: Icons.pending_actions_rounded,
        label: 'Planned',
        value: '$planned',
        color: ThemeColors.logoGold,
      ),
      _MiniExpenseMetric(
        icon: Icons.local_shipping_rounded,
        label: 'Ordered',
        value: '$ordered',
        color: const Color(0xFF1C7C8C),
      ),
      _MiniExpenseMetric(
        icon: Icons.task_alt_rounded,
        label: 'Bought',
        value: '$purchased',
        color: const Color(0xFF3A8F63),
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 820
            ? 4
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4
                ? 2.8
                : columns == 2
                ? 2.35
                : 3.6,
          ),
          itemBuilder: (context, index) => metrics[index],
        );
      },
    );
  }
}

class _PurchaseListCard extends GetView<DashboardController> {
  const _PurchaseListCard({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => showPurchaseDialog(context, purchase: item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE8E2D8)),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ThemeColors.logoGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.shopping_bag_rounded,
                    color: ThemeColors.logoGold,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name.isEmpty ? 'Untitled item' : item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${formatMoney(item.amount)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusPill(label: item.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
