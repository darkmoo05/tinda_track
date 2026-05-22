import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/top_alert.dart';
import '../data/local_inventory_repository.dart';
import '../data/models/custom_shelf_location.dart';
import '../data/models/inventory_product.dart';
import '../data/shelf_code.dart';
import '../providers/inventory_providers.dart';
import '../widgets/inventory_filter_sheet.dart';
import '../widgets/manage_lookup_sheet.dart';
import '../widgets/product_cards.dart';
import '../widgets/quick_stock_sheet.dart';
import 'add_edit_product_screen.dart';
import 'shelf_detail_screen.dart';
import 'stock_history_screen.dart';

/// Main Inventory screen â€” backed by NestJS API, powered by Riverpod.
class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchVisible = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchCtrl.clear();
        ref.read(inventoryFilterProvider.notifier).setSearch('');
      }
    });
  }

  Future<void> _openAddProduct() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
    );
  }

  /// Opens the camera scanner. When a `TT-SHELF-<syncId>` QR is detected
  /// we look it up against the local shelf-location table and push the
  /// shelf detail screen. Anything else triggers a brief error toast so
  /// the operator knows their barcode wasn't a shelf tag.
  Future<void> _scanShelfCode() async {
    final raw = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => const _ShelfScannerScreen(),
        fullscreenDialog: true,
      ),
    );
    if (raw == null || !mounted) return;

    final syncId = tryParseShelfCodePayload(raw);
    if (syncId == null) {
      showTopAlert(context, 'That QR is not a Tinda Track shelf code.');
      return;
    }

    // Look up the shelf locally. Awaiting the future keeps the snapshot
    // consistent with whatever the user just scanned.
    final shelves = await ref.read(allShelfLocationsProvider.future);
    final CustomShelfLocation? match = shelves
        .where((s) => s.syncId == syncId)
        .cast<CustomShelfLocation?>()
        .firstWhere((s) => s != null, orElse: () => null);
    if (!mounted) return;
    if (match == null) {
      showTopAlert(
        context,
        'Shelf not found on this device. Pull-to-sync and try again.',
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShelfDetailScreen(shelf: match)),
    );
  }

  Future<void> _openEditProduct(InventoryProduct product) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(existing: product),
      ),
    );
  }

  Future<void> _openStockHistory(InventoryProduct product) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StockHistoryScreen(product: product)),
    );
  }

  Future<void> _openQuickStock(InventoryProduct product) async {
    await showQuickStockSheet(context, ref, product);
  }

  void _onProductTap(InventoryProduct product) {
    final filter = ref.read(inventoryFilterProvider);
    if (filter.bulkSelectMode) {
      ref.read(inventoryFilterProvider.notifier).toggleSelect(product.id);
    } else {
      _showProductActionSheet(product);
    }
  }

  void _showProductActionSheet(InventoryProduct product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductActionSheet(
        product: product,
        onAdjustStock: () => _openQuickStock(product),
        onEdit: () => _openEditProduct(product),
        onHistory: () => _openStockHistory(product),
        onDelete: () => _confirmDelete(product),
      ),
    );
  }

  Future<void> _confirmDelete(InventoryProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.archiveProductTitle),
        content: Text(context.l10n.archiveProductMessage(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.archive,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalInventoryRepository.instance.deleteProduct(product.id);
      ref.invalidate(allProductsProvider);
    }
  }

  Future<void> _bulkDelete() async {
    final filter = ref.read(inventoryFilterProvider);
    if (filter.selectedIds.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.archiveBulkTitle(filter.selectedIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.archive,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      for (final id in filter.selectedIds) {
        await LocalInventoryRepository.instance.deleteProduct(id);
      }
      ref.invalidate(allProductsProvider);
      ref.read(inventoryFilterProvider.notifier).toggleBulkSelectMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(inventoryFilterProvider);
    final notifier = ref.read(inventoryFilterProvider.notifier);
    final filteredAsync = ref.watch(filteredProductsProvider);
    final summaryAsync = ref.watch(inventorySummaryProvider);
    final hasFilter = notifier.hasActiveFilters;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(filter, hasFilter),
      floatingActionButton: filter.bulkSelectMode
          ? null
          : FloatingActionButton.extended(
              heroTag: 'inventory_fab',
              onPressed: _openAddProduct,
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                context.l10n.addProduct,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
      body: Column(
        children: [
          // Search bar (slides in/out)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _searchVisible
                ? _buildSearchBar(notifier)
                : const SizedBox.shrink(),
          ),

          // Summary header
          summaryAsync.when(
            data: (summary) => _SummaryHeader(summary: summary),
            loading: () => const SizedBox(height: 64),
            error: (_, _) => const SizedBox.shrink(),
          ),

          // Category chips â€” sourced from the QuickAccess pin list so users
          // can curate which categories belong on their main dashboard,
          // independent of which categories happen to have stock today.
          Builder(
            builder: (_) {
              final quickAsync = ref.watch(quickAccessCategoriesProvider);
              return quickAsync.when(
                data: (pinned) {
                  final names = pinned.map((c) => c.name).toList();
                  return _CategoryChips(
                    categories: names,
                    selected: filter.category,
                    onSelect: notifier.setCategory,
                    onManage: () =>
                        showManageLookupSheet(context, isCategory: true),
                  );
                },
                loading: () => const SizedBox(height: 44),
                error: (_, _) => const SizedBox.shrink(),
              );
            },
          ),

          // Product list / grid
          Expanded(
            child: filteredAsync.when(
              data: (products) => _buildProductContent(products, filter),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.secondary),
              ),
              error: (e, _) => Center(
                child: Text(
                  '$e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ),

          // Bulk action bar
          if (filter.bulkSelectMode) _buildBulkBar(filter),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    InventoryFilterState filter,
    bool hasFilter,
  ) {
    final notifier = ref.read(inventoryFilterProvider.notifier);
    return AppBar(
      backgroundColor: AppColors.secondary,
      foregroundColor: Colors.white,
      title: filter.bulkSelectMode
          ? Text(
              context.l10n.nSelected(filter.selectedIds.length),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : Text(
              context.l10n.inventory,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
      actions: [
        if (filter.bulkSelectMode) ...[
          TextButton(
            onPressed: () {
              final products = ref.read(filteredProductsProvider).value ?? [];
              notifier.selectAll(products);
            },
            child: Text(
              context.l10n.all,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: notifier.toggleBulkSelectMode,
          ),
        ] else ...[
          IconButton(
            tooltip: 'Scan shelf code',
            icon: const Icon(
              Icons.qr_code_scanner_rounded,
              color: Colors.white,
            ),
            onPressed: _scanShelfCode,
          ),
          IconButton(
            icon: Icon(
              _searchVisible ? Icons.search_off_rounded : Icons.search_rounded,
              color: Colors.white,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list_rounded, color: Colors.white),
                if (hasFilter)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD600),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => showInventoryFilterSheet(context),
          ),
          IconButton(
            icon: Icon(
              filter.isGridView
                  ? Icons.view_list_rounded
                  : Icons.grid_view_rounded,
              color: Colors.white,
            ),
            onPressed: notifier.toggleGridView,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (v) {
              if (v == 'bulk') notifier.toggleBulkSelectMode();
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'bulk',
                child: ListTile(
                  leading: const Icon(Icons.checklist_rounded),
                  title: Text(ctx.l10n.selectMultiple),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSearchBar(InventoryFilterNotifier notifier) {
    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: context.l10n.searchProductHint,
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white70),
                  onPressed: () {
                    _searchCtrl.clear();
                    notifier.setSearch('');
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
        ),
        onChanged: (v) {
          notifier.setSearch(v);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildProductContent(
    List<InventoryProduct> products,
    InventoryFilterState filter,
  ) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.noProducts,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: Text(context.l10n.addProduct),
            ),
          ],
        ),
      );
    }

    if (filter.isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.72,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) {
          final p = products[i];
          return ProductGridCard(
            product: p,
            isSelected: filter.selectedIds.contains(p.id),
            bulkSelectMode: filter.bulkSelectMode,
            onTap: () => _onProductTap(p),
          );
        },
      );
    }

    return _GroupedShelfView(
      products: products,
      filter: filter,
      onTap: _onProductTap,
      onEdit: _openEditProduct,
      onAdjustStock: _openQuickStock,
    );
  }

  Widget _buildBulkBar(InventoryFilterState filter) {
    return Container(
      color: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Row(
        children: [
          Text(
            context.l10n.nSelected(filter.selectedIds.length),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: filter.selectedIds.isEmpty ? null : _bulkDelete,
            icon: const Icon(Icons.archive_rounded, color: AppColors.error),
            label: Text(
              context.l10n.archive,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Summary header
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SummaryHeader extends StatelessWidget {
  final InventorySummary summary;

  const _SummaryHeader({required this.summary});

  static final _compact = NumberFormat.compact();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondary,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Row(
        children: [
          _StatChip(
            label: context.l10n.products,
            value: '${summary.totalProducts}',
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: context.l10n.totalStock,
            value: _compact.format(summary.totalStock),
            icon: Icons.layers_rounded,
          ),
          const SizedBox(width: 8),
          _StatChip(
            label: context.l10n.lowStock,
            value: '${summary.lowStockCount}',
            icon: Icons.warning_amber_rounded,
            urgent: summary.lowStockCount > 0,
          ),
          if (summary.outOfStockCount > 0) ...[
            const SizedBox(width: 8),
            _StatChip(
              label: context.l10n.outOfStock,
              value: '${summary.outOfStockCount}',
              icon: Icons.block_rounded,
              urgent: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool urgent;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    this.urgent = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = urgent
        ? AppColors.error.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.18);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Category chips
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;
  final VoidCallback? onManage;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    // Even when no pinned categories exist, render the chip row so users
    // can discover the gear button and curate their dashboard.
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildChip(
                  context.l10n.all,
                  selected == null,
                  () => onSelect(null),
                ),
                ...categories.map(
                  (cat) => _buildChip(
                    cat,
                    selected == cat,
                    () => onSelect(selected == cat ? null : cat),
                  ),
                ),
              ],
            ),
          ),
          if (onManage != null)
            IconButton(
              tooltip: 'Manage categories',
              icon: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: AppColors.onSurfaceVariant,
              ),
              onPressed: onManage,
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.secondary
                  : AppColors.outlineVariant,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Grouped by shelf view
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _GroupedShelfView extends StatelessWidget {
  final List<InventoryProduct> products;
  final InventoryFilterState filter;
  final ValueChanged<InventoryProduct> onTap;
  final ValueChanged<InventoryProduct> onEdit;
  final ValueChanged<InventoryProduct> onAdjustStock;

  const _GroupedShelfView({
    required this.products,
    required this.filter,
    required this.onTap,
    required this.onEdit,
    required this.onAdjustStock,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, List<InventoryProduct>> grouped = {};
    for (final p in products) {
      grouped.putIfAbsent(p.shelfLocation, () => []).add(p);
    }
    final shelves = grouped.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      children: shelves.map((shelf) {
        final shelfProducts = grouped[shelf]!;
        return _ShelfSection(
          shelf: shelf,
          products: shelfProducts,
          filter: filter,
          onTap: onTap,
          onEdit: onEdit,
          onAdjustStock: onAdjustStock,
        );
      }).toList(),
    );
  }
}

class _ShelfSection extends StatefulWidget {
  final String shelf;
  final List<InventoryProduct> products;
  final InventoryFilterState filter;
  final ValueChanged<InventoryProduct> onTap;
  final ValueChanged<InventoryProduct> onEdit;
  final ValueChanged<InventoryProduct> onAdjustStock;

  const _ShelfSection({
    required this.shelf,
    required this.products,
    required this.filter,
    required this.onTap,
    required this.onEdit,
    required this.onAdjustStock,
  });

  @override
  State<_ShelfSection> createState() => _ShelfSectionState();
}

class _ShelfSectionState extends State<_ShelfSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.shelf,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.nProducts(widget.products.length),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          ...widget.products.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ProductListTile(
                product: p,
                isSelected: widget.filter.selectedIds.contains(p.id),
                bulkSelectMode: widget.filter.bulkSelectMode,
                onTap: () => widget.onTap(p),
                onEdit: () => widget.onEdit(p),
                onAdjustStock: () => widget.onAdjustStock(p),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Product action sheet (on tap)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ProductActionSheet extends StatelessWidget {
  final InventoryProduct product;
  final VoidCallback onAdjustStock;
  final VoidCallback onEdit;
  final VoidCallback onHistory;
  final VoidCallback onDelete;

  static final _currency = NumberFormat.currency(
    symbol: 'â‚±',
    decimalDigits: 2,
  );

  const _ProductActionSheet({
    required this.product,
    required this.onAdjustStock,
    required this.onEdit,
    required this.onHistory,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = product.isLowStock;
    final isOut = product.isOutOfStock;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      _currency.format(product.sellingPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.stockQuantity}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: isOut
                          ? AppColors.error
                          : isLow
                          ? const Color(0xFFE65100)
                          : AppColors.secondary,
                    ),
                  ),
                  Text(
                    product.unit,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.add_circle_rounded, color: AppColors.secondary),
            ),
            title: Text(
              context.l10n.adjustStock,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onAdjustStock();
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(Icons.edit_rounded, color: Color(0xFF1565C0)),
            ),
            title: Text(
              context.l10n.editProduct,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onEdit();
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFF3E5F5),
              child: Icon(Icons.history_rounded, color: Color(0xFF6A1B9A)),
            ),
            title: Text(
              context.l10n.stockHistory,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context);
              onHistory();
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.archive_rounded, color: AppColors.error),
            ),
            title: Text(
              context.l10n.archiveProduct,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Phase 3 — minimal full-screen QR scanner used by the "Scan shelf" action.
// Returns the raw scanned string via Navigator.pop on the first detection.
// -----------------------------------------------------------------------------

class _ShelfScannerScreen extends StatefulWidget {
  const _ShelfScannerScreen();

  @override
  State<_ShelfScannerScreen> createState() => _ShelfScannerScreenState();
}

class _ShelfScannerScreenState extends State<_ShelfScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;
    _handled = true;
    Navigator.pop(context, raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan shelf code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (_, state, _) {
                final on = state.torchState == TorchState.on;
                return Icon(on ? Icons.flash_on : Icons.flash_off);
              },
            ),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Viewfinder cut-out
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aim at a TT-SHELF-… code',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
