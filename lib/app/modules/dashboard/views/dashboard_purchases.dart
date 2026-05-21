part of 'dashboard_view.dart';

class PurchasesPanel extends GetView<DashboardController> {
  const PurchasesPanel({super.key, required this.purchases});

  final List<PurchaseItem> purchases;

  @override
  Widget build(BuildContext context) {
    final sorted = [...purchases]
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
        sorted.isEmpty
            ? const _PremiumEmptyState(
                icon: Icons.shopping_bag_rounded,
                title: 'No wishlist items yet',
                subtitle:
                    'Add outfits, gifts, jewelry, decor, and booking purchases.',
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(
                    title: 'Shopping list',
                    action: 'Review',
                  ),
                  const SizedBox(height: 12),
                  ...sorted.map((item) => _PurchaseListCard(item: item)),
                ],
              ),
      ],
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
            color: const Color(0xFF0F8B7D),
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
                  color: const Color(0xFF0F8B7D),
                  label: 'Purchased',
                  value: '$purchased',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFD4A373),
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
        color: const Color(0xFF0F8B7D),
      ),
      _MiniExpenseMetric(
        icon: Icons.pending_actions_rounded,
        label: 'Planned',
        value: '$planned',
        color: const Color(0xFFD4A373),
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
        final columns = constraints.maxWidth >= 680 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: columns == 4 ? 1.35 : 1.55,
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
    final color = _premiumStatusColor(item.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _PremiumSurface(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SoftIcon(icon: Icons.shopping_bag_rounded, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => showPurchaseDialog(context, purchase: item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name.isEmpty ? 'Untitled item' : item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        height: 1.08,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusPill(label: item.status),
                        LabelPill(label: item.category),
                      ],
                    ),
                    if (item.note.trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        item.note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded),
              onSelected: (value) {
                if (value == 'edit') {
                  showPurchaseDialog(context, purchase: item);
                } else if (value == 'convert') {
                  showConvertPurchaseToExpenseDialog(context, purchase: item);
                } else if (value == 'delete') {
                  controller.deletePurchase(item);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit item')),
                PopupMenuItem(
                  value: 'convert',
                  child: Text('Convert to expense'),
                ),
                PopupMenuItem(value: 'delete', child: Text('Delete item')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
