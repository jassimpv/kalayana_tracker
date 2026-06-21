import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kalayanaexpresstracker/app/core/config/ads_config.dart';
import 'package:kalayanaexpresstracker/app/core/theme/app_theme.dart';
import 'package:kalayanaexpresstracker/app/core/widgets/dashboard_banner_ad.dart';
import 'package:kalayanaexpresstracker/app/data/models/guest.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/controllers/guests_controller.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/dashboard_guests.dart';
import 'package:kalayanaexpresstracker/app/modules/dashboard/views/guests/guest_detail.dart';

class GuestsListTab extends GetView<GuestsController> {
  const GuestsListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: 84 + (isMobileAdsSupported ? AdsConfig.bannerHeight : 0),
        ),
        child: FloatingActionButton(
          backgroundColor: ThemeColors.primary,
          foregroundColor: Colors.white,
          onPressed: () => openGuestAdd(context),
          child: const Icon(Icons.person_add_alt_1_rounded),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: _GuestSearchPanel(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              final guests = controller.filteredGuests;
              if (guests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  child: _GuestsEmptyState(
                    hasFilters:
                        controller.searchQuery.value.isNotEmpty ||
                        controller.categoryFilter.value != null ||
                        controller.sideFilter.value != null,
                    onTap: () => openGuestAdd(context),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                itemCount: guests.length,
                itemBuilder: (context, index) =>
                    _GuestCard(guest: guests[index]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _GuestSearchPanel extends GetView<GuestsController> {
  const _GuestSearchPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
          TextField(
            onChanged: (value) => controller.searchQuery.value = value,
            cursorColor: ThemeColors.primary,
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: 'Search guests by name or phone',
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
          ),
          const SizedBox(height: 12),
          Obx(
            () => SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                children: [
                  _GuestFilterChip(
                    label: 'All',
                    count: controller.guests.length,
                    selected: controller.categoryFilter.value == null,
                    onTap: () => controller.categoryFilter.value = null,
                  ),
                  const SizedBox(width: 8),
                  ...guestCategories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _GuestFilterChip(
                        label: category,
                        count: controller.guests
                            .where((g) => g.category == category)
                            .length,
                        selected: controller.categoryFilter.value == category,
                        onTap: () => controller.categoryFilter.value =
                            controller.categoryFilter.value == category
                            ? null
                            : category,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                children: [
                  _GuestFilterChip(
                    label: 'All Sides',
                    count: controller.guests.length,
                    selected: controller.sideFilter.value == null,
                    onTap: () => controller.sideFilter.value = null,
                  ),
                  const SizedBox(width: 8),
                  ...guestSides.map(
                    (side) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _GuestFilterChip(
                        label: side,
                        count: controller.guests
                            .where((g) => g.side == side)
                            .length,
                        selected: controller.sideFilter.value == side,
                        onTap: () => controller.sideFilter.value =
                            controller.sideFilter.value == side ? null : side,
                      ),
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

class _GuestFilterChip extends StatelessWidget {
  const _GuestFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

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

class _GuestsEmptyState extends StatelessWidget {
  const _GuestsEmptyState({required this.hasFilters, required this.onTap});

  final bool hasFilters;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0D7D2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.person_2, color: ThemeColors.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            hasFilters ? 'No guests match your filters' : 'No guests yet',
            style: const TextStyle(
              color: ThemeColors.logoDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasFilters
                ? 'Try clearing the search or filters above.'
                : 'Add guests to start tracking invitations and RSVPs.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF78656A),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: onTap, child: const Text('Add Guest')),
        ],
      ),
    );
  }
}

class _GuestCard extends GetView<GuestsController> {
  const _GuestCard({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final eventId = controller.selectedEventId.value;
      final status = eventId == null
          ? null
          : controller.responseFor(guest.id, eventId)?.status;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Dismissible(
          key: ValueKey(guest.id),
          direction: DismissDirection.endToStart,
          background: const _SwipeDeleteBackground(),
          confirmDismiss: (_) => _confirmDeleteGuest(context, guest),
          onDismissed: (_) => controller.deleteGuest(guest.id),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GuestDetailPage(guestId: guest.id),
              ),
            ),
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ThemeColors.primary.withValues(alpha: 0.10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      guest.name.isEmpty ? '?' : guest.name[0].toUpperCase(),
                      style: TextStyle(
                        color: ThemeColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          guest.name.isEmpty ? 'Unnamed guest' : guest.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ThemeColors.logoDeep,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Tag(text: guest.side),
                            _Tag(text: guest.category),
                            _Tag(text: 'Invited ${guest.numberInvited}'),
                            if (status != null)
                              _Tag(text: status, highlighted: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF9C8389),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _SwipeDeleteBackground extends StatelessWidget {
  const _SwipeDeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFC30B4A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.delete, color: Colors.white, size: 22),
          const SizedBox(height: 3),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool> _confirmDeleteGuest(BuildContext context, Guest guest) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete guest'),
      content: Text(
        'Delete ${guest.name.isEmpty ? 'this guest' : guest.name}? '
        'This removes their RSVP history too.',
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
  return confirmed ?? false;
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, this.highlighted = false});

  final String text;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted
            ? ThemeColors.primary.withValues(alpha: 0.1)
            : ThemeColors.logoGold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: highlighted ? ThemeColors.primary : ThemeColors.logoDeep,
        ),
      ),
    );
  }
}
