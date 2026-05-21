import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/app_theme.dart';
import '../../../../../core/l10n/l10n_extension.dart';
import '../providers/inventory_providers.dart';
import 'manage_lookup_sheet.dart';

/// Bottom sheet for applying filters to the inventory list.
Future<void> showInventoryFilterSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _InventoryFilterSheet(),
  );
}

class _InventoryFilterSheet extends ConsumerWidget {
  const _InventoryFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(inventoryFilterProvider);
    final notifier = ref.read(inventoryFilterProvider.notifier);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      context.l10n.filters,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        notifier.clearFilters();
                        Navigator.pop(context);
                      },
                      child: Text(
                        context.l10n.clearAll,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // -- Category --------------------------------------------
                Row(
                  children: [
                    _SectionLabel(context.l10n.category),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Manage categories',
                      onPressed: () =>
                          showManageLookupSheet(context, isCategory: true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ref
                    .watch(allCategoriesProvider)
                    .when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (cats) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: context.l10n.all,
                            selected: filter.category == null,
                            onTap: () => notifier.setCategory(null),
                          ),
                          ...cats.map(
                            (cat) => _FilterChip(
                              label: cat.name,
                              selected: filter.category == cat.name,
                              onTap: () => notifier.setCategory(
                                filter.category == cat.name ? null : cat.name,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 20),

                // -- Shelf Location -------------------------------------
                Row(
                  children: [
                    const _SectionLabel('Location'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Manage locations',
                      onPressed: () =>
                          showManageLookupSheet(context, isCategory: false),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ref
                    .watch(allShelfLocationsProvider)
                    .when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (locs) => Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChip(
                            label: 'All',
                            selected: filter.shelfLocation == null,
                            onTap: () => notifier.setShelfLocation(null),
                          ),
                          ...locs.map(
                            (loc) => _FilterChip(
                              label: loc.name,
                              selected: filter.shelfLocation == loc.name,
                              onTap: () => notifier.setShelfLocation(
                                filter.shelfLocation == loc.name
                                    ? null
                                    : loc.name,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                const SizedBox(height: 20),

                // -- Stock alerts ----------------------------------------
                _SectionLabel(context.l10n.stockAlerts),
                const SizedBox(height: 8),
                SwitchListTile.adaptive(
                  title: Text(context.l10n.lowStockOnly),
                  value: filter.lowStockOnly,
                  activeColor: AppColors.secondary,
                  onChanged: (_) => notifier.toggleLowStockOnly(),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile.adaptive(
                  title: Text(context.l10n.outOfStockOnly),
                  value: filter.outOfStockOnly,
                  activeColor: AppColors.secondary,
                  onChanged: (_) => notifier.toggleOutOfStockOnly(),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // -- Apply -----------------------------------------------
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      context.l10n.apply,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        color: AppColors.onSurface,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.secondary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}
