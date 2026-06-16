part of '../dashboard_view.dart';

class PurchasesPanel extends StatefulWidget {
  const PurchasesPanel({super.key, required this.purchases});

  final List<PurchaseItem> purchases;

  @override
  State<PurchasesPanel> createState() => _PurchasesPanelState();
}

class _PurchasesPanelState extends State<PurchasesPanel> {
  final controller = Get.find<DashboardController>();
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
      final purchased = _isPurchased(item);
      if (_selectedFilter == 'Pending' && purchased) return false;
      if (_selectedFilter == 'Purchased' && !purchased) return false;
      if (query.isEmpty) return true;
      final searchable = '${item.name} ${item.category} ${item.note}'
          .toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.purchases.length;
    final purchasedCount = widget.purchases.where(_isPurchased).length;
    final pendingCount = total - purchasedCount;
    final visible = _filteredPurchases
      ..sort((a, b) {
        final aDone = _isPurchased(a);
        final bDone = _isPurchased(b);
        if (aDone != bDone) return aDone ? 1 : -1;
        return a.name.compareTo(b.name);
      });

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFDF4EC), Color(0xFFFFF8F0)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShoppingHero(),
          Transform.translate(
            offset: const Offset(0, -20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _ShoppingSearchPanel(
                controller: _searchController,
                selectedFilter: _selectedFilter,
                total: total,
                pending: pendingCount,
                purchased: purchasedCount,
                onChanged: (value) => setState(() {
                  _searchQuery = value;
                }),
                onFilterChanged: (value) => setState(() {
                  _selectedFilter = value;
                }),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _WishlistCallout(onTap: controller.openPurchaseAdd),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _ShoppingListHeader(count: visible.length),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: visible.isEmpty
                ? _ShoppingEmptyState(
                    filter: _selectedFilter,
                    onTap: controller.openPurchaseAdd,
                  )
                : Column(
                    children: visible
                        .map((item) => _PurchaseListCard(item: item))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingHero extends StatelessWidget {
  const _ShoppingHero();

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      height: top + 110,
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, top + 18, 22, 0),
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.25,
          colors: [Color(0xFFC71053), Color(0xFF8F1438), Color(0xFF5A0820)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -76,
            right: -44,
            child: Container(
              width: 154,
              height: 154,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1.5,
                ),
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            left: -96,
            bottom: -44,
            child: Container(
              width: 138,
              height: 138,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE03A72).withValues(alpha: 0.42),
              ),
            ),
          ),
          Positioned(
            right: -30,
            top: 16,
            child: SizedBox(
              width: 124,
              height: 96,
              child: CustomPaint(painter: _ShoppingHeaderArtPainter()),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shopping',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              const SizedBox(
                width: 230,
                child: Text(
                  'Manage purchases, stay on budget',
                  style: TextStyle(
                    color: Color(0xFFF7C859),
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShoppingHeaderArtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()
      ..color = const Color(0xFFE8A64E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    final pink = Paint()
      ..color = const Color(0xFFE73A70).withValues(alpha: 0.74)
      ..style = PaintingStyle.fill;
    final deepPink = Paint()
      ..color = const Color(0xFFB21245).withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;
    final orange = Paint()
      ..color = const Color(0xFFE58E47).withValues(alpha: 0.78)
      ..style = PaintingStyle.fill;

    final bag = Path()
      ..moveTo(72, 48)
      ..lineTo(136, 48)
      ..lineTo(142, 124)
      ..lineTo(64, 124)
      ..close();
    canvas.drawPath(bag, pink);
    canvas.drawArc(Rect.fromLTWH(88, 4, 54, 64), math.pi, math.pi, false, gold);
    canvas.drawLine(const Offset(92, 50), const Offset(92, 78), gold);
    canvas.drawLine(const Offset(126, 50), const Offset(126, 78), gold);
    for (final point in [
      const Offset(92, 80),
      const Offset(126, 80),
      const Offset(88, 64),
      const Offset(130, 62),
    ]) {
      canvas.drawCircle(point, 3.2, orange);
    }

    final giftRect = Rect.fromLTWH(40, 86, 58, 42);
    canvas.drawRRect(
      RRect.fromRectAndRadius(giftRect, const Radius.circular(5)),
      orange,
    );
    canvas.drawRect(Rect.fromLTWH(64, 86, 10, 42), pink);
    canvas.drawRect(Rect.fromLTWH(40, 100, 58, 8), pink);
    canvas.drawArc(
      Rect.fromLTWH(47, 73, 22, 22),
      0.1,
      math.pi * 1.55,
      false,
      gold,
    );
    canvas.drawArc(
      Rect.fromLTWH(70, 73, 22, 22),
      math.pi * 1.35,
      math.pi * 1.55,
      false,
      gold,
    );

    final vase = Path()
      ..moveTo(152, 90)
      ..quadraticBezierTo(144, 104, 148, 126)
      ..lineTo(184, 126)
      ..quadraticBezierTo(188, 104, 180, 90)
      ..quadraticBezierTo(170, 96, 152, 90)
      ..close();
    canvas.drawPath(vase, Paint()..color = const Color(0xFFE7887E));
    canvas.drawLine(const Offset(166, 92), const Offset(170, 42), gold);
    canvas.drawLine(const Offset(166, 92), const Offset(186, 36), gold);
    canvas.drawLine(const Offset(166, 92), const Offset(156, 48), gold);
    for (final flower in [
      const Offset(170, 42),
      const Offset(186, 36),
      const Offset(156, 48),
      const Offset(181, 58),
      const Offset(160, 64),
    ]) {
      canvas.drawCircle(flower, 6, orange);
      canvas.drawCircle(flower.translate(3, -4), 4, pink);
    }

    for (final leaf in [
      const Offset(20, 92),
      const Offset(26, 74),
      const Offset(160, 32),
      const Offset(184, 74),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: leaf, width: 14, height: 28),
        deepPink,
      );
    }

    _drawSparkle(canvas, const Offset(10, 74), 8, gold);
    _drawSparkle(canvas, const Offset(22, 18), 5, gold);
    _drawSparkle(canvas, const Offset(174, 13), 9, gold);
    _drawSparkle(canvas, const Offset(4, 112), 4, gold);
  }

  void _drawSparkle(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r * 0.42, center.dy - r * 0.42)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx + r * 0.42, center.dy + r * 0.42)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r * 0.42, center.dy + r * 0.42)
      ..lineTo(center.dx - r, center.dy)
      ..lineTo(center.dx - r * 0.42, center.dy - r * 0.42)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShoppingSearchPanel extends StatelessWidget {
  const _ShoppingSearchPanel({
    required this.controller,
    required this.selectedFilter,
    required this.total,
    required this.pending,
    required this.purchased,
    required this.onChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String selectedFilter;
  final int total;
  final int pending;
  final int purchased;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          _PurchaseSearchField(controller: controller, onChanged: onChanged),
          const SizedBox(height: 12),
          Row(
            children: [
              _PurchaseFilterChip(
                icon: CupertinoIcons.bag,
                label: 'All',
                count: total,
                selected: selectedFilter == 'All',
                onTap: () => onFilterChanged('All'),
              ),
              const SizedBox(width: 10),
              _PurchaseFilterChip(
                icon: CupertinoIcons.hourglass,
                label: 'Pending',
                count: pending,
                selected: selectedFilter == 'Pending',
                onTap: () => onFilterChanged('Pending'),
              ),
              const SizedBox(width: 10),
              _PurchaseFilterChip(
                icon: CupertinoIcons.check_mark_circled,
                label: 'Purchased',
                count: purchased,
                selected: selectedFilter == 'Purchased',
                onTap: () => onFilterChanged('Purchased'),
              ),
            ],
          ),
        ],
      ),
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
      style: const TextStyle(
        color: ThemeColors.logoDeep,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: 'Search items, vendors, categories...',
        hintStyle: TextStyle(
          color: ThemeColors.logoDeep.withValues(alpha: 0.36),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(
          CupertinoIcons.search,
          color: ThemeColors.primary.withValues(alpha: 0.72),
          size: 23,
        ),
        suffixIcon: Container(
          width: 52,
          margin: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: const Color(0xFFE8CBC7).withValues(alpha: 0.80),
              ),
            ),
          ),
          child: Icon(
            CupertinoIcons.slider_horizontal_3,
            color: ThemeColors.primary.withValues(alpha: 0.92),
            size: 22,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFEFDCD7)),
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

class _PurchaseFilterChip extends StatelessWidget {
  const _PurchaseFilterChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
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
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF9A123A), Color(0xFFC30B4A)],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFEFDCD7),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ThemeColors.primary.withValues(alpha: 0.23),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : ThemeColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  count.toString(),
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : ThemeColors.logoDeep.withValues(alpha: 0.28),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistCallout extends StatelessWidget {
  const _WishlistCallout({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ThemeColors.primary.withValues(alpha: 0.10),
            ),
            child: Icon(
              CupertinoIcons.bookmark,
              color: ThemeColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No wishlist items yet',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add outfits, gifts, jewelry, decor, and booking purchases.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF78656A),
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AddWishlistButton(onTap: onTap),
        ],
      ),
    );
  }
}

class _AddWishlistButton extends StatelessWidget {
  const _AddWishlistButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9A123A), Color(0xFFC30B4A)],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9A123A).withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.plus, color: Colors.white, size: 16),
              SizedBox(width: 6),
              Text(
                'Add Wishlist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingListHeader extends StatelessWidget {
  const _ShoppingListHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Shopping List',
            style: TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShoppingEmptyState extends StatelessWidget {
  const _ShoppingEmptyState({required this.filter, required this.onTap});

  final String filter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = filter == 'All'
        ? 'No shopping items yet'
        : 'No $filter items';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
      ),
      child: Column(
        children: [
          Icon(CupertinoIcons.bag, color: ThemeColors.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('Add Wishlist')),
        ],
      ),
    );
  }
}

class _PurchaseListCard extends GetView<DashboardController> {
  const _PurchaseListCard({required this.item});

  final PurchaseItem item;

  @override
  Widget build(BuildContext context) {
    final purchased = _isPurchased(item);
    final spec = _ShoppingCategorySpec.fromCategory(item.category);
    final vendor = item.note.trim().isEmpty
        ? 'Vendor not set'
        : item.note.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(item.id),
        background: _SwipeActionBackground(
          alignment: Alignment.centerLeft,
          color: const Color(0xFF0D7A3A),
          icon: purchased
              ? CupertinoIcons.arrow_counterclockwise
              : CupertinoIcons.check_mark_circled_solid,
          label: purchased ? 'Mark pending' : 'Mark purchased',
        ),
        secondaryBackground: const _SwipeActionBackground(
          alignment: Alignment.centerRight,
          color: Color(0xFFC30B4A),
          icon: CupertinoIcons.delete,
          label: 'Delete',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _handleTogglePurchase(context, item);
            return false;
          }
          return _confirmDeletePurchase(context, item);
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            controller.deletePurchase(item);
          }
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showPurchaseDialog(context, purchase: item),
          onLongPress: () => _showPurchaseActions(context, item),
          child: Container(
            constraints: const BoxConstraints(minHeight: 78),
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF1D9D5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => _handleTogglePurchase(context, item),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeColors.primary.withValues(alpha: 0.10),
                    ),
                    child: Icon(
                      spec.icon,
                      color: ThemeColors.primary,
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name.isEmpty ? 'Untitled item' : item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ThemeColors.logoDeep,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _CategoryPill(spec: spec, label: item.category),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.storefront_outlined,
                            color: ThemeColors.primary,
                            size: 13,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              vendor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF60464C),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${AppConfig.appCurrency} ${formatMoney(item.amount)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _ShoppingStatusPill(
                      label: purchased ? 'Purchased' : 'Pending',
                      purchased: purchased,
                    ),
                  ],
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _showPurchaseActions(context, item),
                  borderRadius: BorderRadius.circular(999),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      CupertinoIcons.ellipsis_vertical,
                      color: Color(0xFF9C8389),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.spec, required this.label});

  final _ShoppingCategorySpec spec;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: ThemeColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ThemeColors.primary.withValues(alpha: 0.16)),
      ),
      child: Text(
        label.isEmpty ? 'General' : label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ThemeColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1,
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
    final color = purchased ? const Color(0xFF3FA463) : const Color(0xFFE39918);
    final background = purchased
        ? const Color(0xFFE5F4E9)
        : const Color(0xFFFFF1D7);
    return Container(
      constraints: const BoxConstraints(maxWidth: 104),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            purchased
                ? CupertinoIcons.check_mark_circled
                : CupertinoIcons.hourglass,
            color: color,
            size: 13,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingCategorySpec {
  const _ShoppingCategorySpec({
    required this.icon,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final Color color;
  final Color tint;

  static _ShoppingCategorySpec fromCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('outfit')) {
      return const _ShoppingCategorySpec(
        icon: Icons.checkroom_outlined,
        color: Color(0xFFB21546),
        tint: Color(0xFFFBE7E9),
      );
    }
    if (normalized.contains('gift')) {
      return const _ShoppingCategorySpec(
        icon: CupertinoIcons.gift,
        color: Color(0xFF6A38D6),
        tint: Color(0xFFF0E8FF),
      );
    }
    if (normalized.contains('decor') || normalized.contains('venue')) {
      return const _ShoppingCategorySpec(
        icon: Icons.celebration_outlined,
        color: Color(0xFFD39119),
        tint: Color(0xFFFFF3DA),
      );
    }
    if (normalized.contains('photo')) {
      return const _ShoppingCategorySpec(
        icon: CupertinoIcons.camera,
        color: Color(0xFF743CD6),
        tint: Color(0xFFF0E8FF),
      );
    }
    if (normalized.contains('jewel')) {
      return const _ShoppingCategorySpec(
        icon: Icons.diamond_outlined,
        color: Color(0xFFD39119),
        tint: Color(0xFFFFF5DD),
      );
    }
    if (normalized.contains('travel')) {
      return const _ShoppingCategorySpec(
        icon: CupertinoIcons.airplane,
        color: Color(0xFFB21546),
        tint: Color(0xFFFBE7E9),
      );
    }
    if (normalized.contains('beauty')) {
      return const _ShoppingCategorySpec(
        icon: Icons.spa_outlined,
        color: Color(0xFFB21546),
        tint: Color(0xFFFBE7E9),
      );
    }
    if (normalized.contains('food')) {
      return const _ShoppingCategorySpec(
        icon: Icons.restaurant_outlined,
        color: Color(0xFFE17812),
        tint: Color(0xFFFFEEE0),
      );
    }
    return _ShoppingCategorySpec(
      icon: CupertinoIcons.bag,
      color: ThemeColors.primary,
      tint: const Color(0xFFFBE7E9),
    );
  }
}

bool _isPurchased(PurchaseItem item) => item.status == 'Purchased';

void _handleTogglePurchase(BuildContext context, PurchaseItem item) {
  if (_isPurchased(item)) {
    Get.find<DashboardController>().togglePurchase(item);
  } else {
    showMarkPurchasedDialog(context, purchase: item);
  }
}

Future<void> _showPurchaseActions(BuildContext context, PurchaseItem item) {
  final controller = Get.find<DashboardController>();
  final purchased = _isPurchased(item);
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6D6D2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item.name.isEmpty ? 'Untitled item' : item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ThemeColors.logoDeep,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                purchased
                    ? CupertinoIcons.arrow_counterclockwise
                    : CupertinoIcons.check_mark_circled_solid,
                color: const Color(0xFF0D7A3A),
              ),
              title: Text(purchased ? 'Mark as pending' : 'Mark as purchased'),
              onTap: () {
                Navigator.pop(sheetContext);
                _handleTogglePurchase(context, item);
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.pencil, color: ThemeColors.primary),
              title: const Text('Edit item'),
              onTap: () {
                Navigator.pop(sheetContext);
                showPurchaseDialog(context, purchase: item);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.delete,
                color: Color(0xFFC30B4A),
              ),
              title: const Text('Delete item'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final confirmed = await _confirmDeletePurchase(context, item);
                if (confirmed == true) {
                  await controller.deletePurchase(item);
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

Future<bool?> _confirmDeletePurchase(BuildContext context, PurchaseItem item) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete item'),
      content: Text(
        'Delete ${item.name.isEmpty ? 'this item' : item.name}? '
        'This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFC30B4A),
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
