import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/app_theme.dart';
import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/sync/sync_orchestrator.dart';
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
      await ref
          .read(localInventoryRepositoryProvider)
          .deleteProduct(product.id);
      ref.invalidate(allProductsProvider);
      unawaited(ref.read(syncOrchestratorProvider).runOnce());
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
        await ref.read(localInventoryRepositoryProvider).deleteProduct(id);
      }
      ref.invalidate(allProductsProvider);
      ref.read(inventoryFilterProvider.notifier).toggleBulkSelectMode();
      unawaited(ref.read(syncOrchestratorProvider).runOnce());
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

          // Summary header — Dashboard tiles (2x2) with tappable filter
          // shortcuts. Each tile maps to a specific filter so the most
          // urgent stats double as one-tap navigation.
          summaryAsync.when(
            data: (summary) => _DashboardTiles(
              summary: summary,
              activeLowOnly: filter.lowStockOnly,
              activeOutOnly: filter.outOfStockOnly,
              onTapProducts: () => notifier.clearFilters(),
              onTapLow: notifier.toggleLowStockOnly,
              onTapOut: notifier.toggleOutOfStockOnly,
            ),
            loading: () => const SizedBox(height: 132),
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
      return _ContextualEmptyState(
        filter: filter,
        onAddProduct: _openAddProduct,
        onClearFilters: () =>
            ref.read(inventoryFilterProvider.notifier).clearFilters(),
        onClearSearch: () {
          _searchCtrl.clear();
          ref.read(inventoryFilterProvider.notifier).setSearch('');
          setState(() {});
        },
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

// ─────────────────────────────────────────────────────────────────────────────
// Dashboard tiles  (Concept 2 — monitoring hero, 2x2 grid)
// ─────────────────────────────────────────────────────────────────────────────

/// 2x2 grid of monitoring tiles. Each tile is tappable to drill into the
/// matching filter, turning the summary into a one-tap shortcut bar.
class _DashboardTiles extends StatelessWidget {
  final InventorySummary summary;
  final bool activeLowOnly;
  final bool activeOutOnly;
  final VoidCallback onTapProducts;
  final VoidCallback onTapLow;
  final VoidCallback onTapOut;

  const _DashboardTiles({
    required this.summary,
    required this.activeLowOnly,
    required this.activeOutOnly,
    required this.onTapProducts,
    required this.onTapLow,
    required this.onTapOut,
  });

  static final _compact = NumberFormat.compact();
  static final _peso = NumberFormat.compactCurrency(
    symbol: '₱',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    // The tiles sit on a light gray strip that visually separates the green
    // AppBar from the rest of the body — breaks up the green dominance and
    // gives the monitoring stats their own breathing room.
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _DashTile(
                  label: context.l10n.products,
                  value: _compact.format(summary.totalProducts),
                  icon: Icons.inventory_2_rounded,
                  accent: AppColors.primary,
                  onTap: onTapProducts,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashTile(
                  label: 'Stock Value',
                  value: _peso.format(summary.totalStockValue),
                  icon: Icons.payments_rounded,
                  accent: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DashTile(
                  label: context.l10n.lowStock,
                  value: '${summary.lowStockCount}',
                  icon: Icons.warning_amber_rounded,
                  accent: const Color(0xFFE65100),
                  active: activeLowOnly,
                  muted: summary.lowStockCount == 0,
                  onTap: summary.lowStockCount == 0 ? null : onTapLow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashTile(
                  label: context.l10n.outOfStock,
                  value: '${summary.outOfStockCount}',
                  icon: Icons.block_rounded,
                  accent: AppColors.error,
                  active: activeOutOnly,
                  muted: summary.outOfStockCount == 0,
                  onTap: summary.outOfStockCount == 0 ? null : onTapOut,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool active;
  final bool muted;
  final VoidCallback? onTap;

  const _DashTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.active = false,
    this.muted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccent = muted ? AppColors.onSurfaceVariant : accent;
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active
                  ? effectiveAccent
                  : AppColors.outlineVariant.withValues(alpha: 0.5),
              width: active ? 2 : 1,
            ),
            // Colored left-edge wash — the only color cue on an otherwise
            // white tile, so the eye can sort tiles by urgency at a glance.
            gradient: LinearGradient(
              colors: [
                effectiveAccent.withValues(alpha: active ? 0.18 : 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.06],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: effectiveAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveAccent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: muted
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      child: Center(
        // Center vertically inside the 44px row so the chip doesn't stretch
        // to fill height; keeps the pill compact and visually balanced.
        child: Material(
          color: isSelected
              ? AppColors.secondary
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 130),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.secondary
                      : AppColors.outlineVariant,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.1,
                  letterSpacing: 0.2,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.onSurface,
                ),
              ),
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

class _GroupedShelfView extends StatefulWidget {
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
  State<_GroupedShelfView> createState() => _GroupedShelfViewState();
}

class _GroupedShelfViewState extends State<_GroupedShelfView> {
  /// Per-shelf collapse state, keyed by shelf name. Defaults to expanded.
  final Map<String, bool> _collapsed = {};

  /// Natural / numeric-aware shelf comparator.
  ///
  /// String sorting puts "Aisle 10" before "Aisle 2" which is confusing for
  /// shop owners labelling shelves numerically. This walks both strings and
  /// compares contiguous digit runs as integers, falling back to a
  /// case-insensitive lexicographic comparison for non-numeric segments.
  static int _compareShelfNames(String a, String b) {
    int i = 0, j = 0;
    while (i < a.length && j < b.length) {
      final ca = a.codeUnitAt(i);
      final cb = b.codeUnitAt(j);
      final aIsDigit = ca >= 0x30 && ca <= 0x39;
      final bIsDigit = cb >= 0x30 && cb <= 0x39;

      if (aIsDigit && bIsDigit) {
        int ni = i;
        while (ni < a.length &&
            a.codeUnitAt(ni) >= 0x30 &&
            a.codeUnitAt(ni) <= 0x39) {
          ni++;
        }
        int nj = j;
        while (nj < b.length &&
            b.codeUnitAt(nj) >= 0x30 &&
            b.codeUnitAt(nj) <= 0x39) {
          nj++;
        }
        final na = int.parse(a.substring(i, ni));
        final nb = int.parse(b.substring(j, nj));
        if (na != nb) return na.compareTo(nb);
        i = ni;
        j = nj;
      } else {
        final cmp = a[i].toLowerCase().compareTo(b[j].toLowerCase());
        if (cmp != 0) return cmp;
        i++;
        j++;
      }
    }
    return a.length.compareTo(b.length);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<InventoryProduct>> grouped = {};
    for (final p in widget.products) {
      grouped.putIfAbsent(p.shelfLocation, () => []).add(p);
    }
    final shelves = grouped.keys.toList()..sort(_compareShelfNames);

    return CustomScrollView(
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 12)),
        for (final shelf in shelves) ...[
          // Sticky header — uses SliverPersistentHeader so it pins to the
          // top of the viewport while the shelf's products scroll past.
          SliverPersistentHeader(
            pinned: true,
            delegate: _ShelfHeaderDelegate(
              shelf: shelf,
              productCount: grouped[shelf]!.length,
              collapsed: _collapsed[shelf] == true,
              onToggle: () => setState(() {
                _collapsed[shelf] = !(_collapsed[shelf] ?? false);
              }),
            ),
          ),
          if (_collapsed[shelf] != true)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              sliver: SliverList.separated(
                itemCount: grouped[shelf]!.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final p = grouped[shelf]![i];
                  return ProductListTile(
                    product: p,
                    isSelected: widget.filter.selectedIds.contains(p.id),
                    bulkSelectMode: widget.filter.bulkSelectMode,
                    onTap: () => widget.onTap(p),
                    onEdit: () => widget.onEdit(p),
                    onAdjustStock: () => widget.onAdjustStock(p),
                  );
                },
              ),
            ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
      ],
    );
  }
}

/// Pinned header shown above each shelf section. Tapping anywhere on the
/// header collapses or expands the section so a long inventory can be
/// "table of contents"-navigated without endless scrolling.
class _ShelfHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String shelf;
  final int productCount;
  final bool collapsed;
  final VoidCallback onToggle;

  _ShelfHeaderDelegate({
    required this.shelf,
    required this.productCount,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Material(
        color: AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    shelf,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  context.l10n.nProducts(productCount),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  collapsed
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: AppColors.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _ShelfHeaderDelegate oldDelegate) {
    return oldDelegate.shelf != shelf ||
        oldDelegate.productCount != productCount ||
        oldDelegate.collapsed != collapsed;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contextual empty state
// ─────────────────────────────────────────────────────────────────────────────

/// Empty state that adapts its message and CTAs to *why* the list is empty:
/// active filters, a search miss, or genuinely no products yet.
class _ContextualEmptyState extends StatelessWidget {
  final InventoryFilterState filter;
  final VoidCallback onAddProduct;
  final VoidCallback onClearFilters;
  final VoidCallback onClearSearch;

  const _ContextualEmptyState({
    required this.filter,
    required this.onAddProduct,
    required this.onClearFilters,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final hasSearch = filter.search.isNotEmpty;
    final hasFilters =
        filter.category != null ||
        filter.shelfLocation != null ||
        filter.lowStockOnly ||
        filter.outOfStockOnly;

    final IconData icon;
    final String title;
    final String subtitle;
    if (hasSearch) {
      icon = Icons.search_off_rounded;
      title = 'Walang nahanap';
      subtitle =
          'No products match "${filter.search}". Try a different keyword.';
    } else if (hasFilters) {
      icon = Icons.filter_alt_off_rounded;
      final parts = <String>[
        if (filter.category != null) filter.category!,
        if (filter.shelfLocation != null) filter.shelfLocation!,
        if (filter.lowStockOnly) 'Low stock',
        if (filter.outOfStockOnly) 'Out of stock',
      ];
      title = 'No products match these filters';
      subtitle = parts.join(' · ');
    } else {
      icon = Icons.inventory_2_outlined;
      title = context.l10n.noProducts;
      subtitle = 'Add your first product to start tracking stock.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (hasSearch)
                  OutlinedButton.icon(
                    onPressed: onClearSearch,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Clear search'),
                  ),
                if (hasFilters)
                  OutlinedButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                    label: const Text('Clear filters'),
                  ),
                FilledButton.icon(
                  onPressed: onAddProduct,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.addProduct),
                ),
              ],
            ),
          ],
        ),
      ),
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
    symbol: '\u20B1',
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
