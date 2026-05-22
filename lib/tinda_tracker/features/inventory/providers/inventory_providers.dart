import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_inventory_repository.dart';
import '../data/models/custom_category.dart';
import '../data/models/custom_shelf_location.dart';
import '../data/models/inventory_product.dart';
import '../data/models/stock_movement.dart';

// Refresh counter — increment to re-fetch products from API
final inventoryRefreshProvider = StateProvider<int>((ref) => 0);

class InventoryFilterState {
  final String search;
  final String? category;
  final String? shelfLocation;
  final bool lowStockOnly;
  final bool outOfStockOnly;
  final bool isGridView;
  final bool bulkSelectMode;
  final Set<String> selectedIds;

  const InventoryFilterState({
    this.search = '',
    this.category,
    this.shelfLocation,
    this.lowStockOnly = false,
    this.outOfStockOnly = false,
    this.isGridView = false,
    this.bulkSelectMode = false,
    this.selectedIds = const {},
  });

  InventoryFilterState copyWith({
    String? search,
    Object? category = _sentinel,
    Object? shelfLocation = _sentinel,
    bool? lowStockOnly,
    bool? outOfStockOnly,
    bool? isGridView,
    bool? bulkSelectMode,
    Set<String>? selectedIds,
  }) {
    return InventoryFilterState(
      search: search ?? this.search,
      category: category == _sentinel ? this.category : category as String?,
      shelfLocation: shelfLocation == _sentinel
          ? this.shelfLocation
          : shelfLocation as String?,
      lowStockOnly: lowStockOnly ?? this.lowStockOnly,
      outOfStockOnly: outOfStockOnly ?? this.outOfStockOnly,
      isGridView: isGridView ?? this.isGridView,
      bulkSelectMode: bulkSelectMode ?? this.bulkSelectMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  static const _sentinel = Object();
}

class InventoryFilterNotifier extends StateNotifier<InventoryFilterState> {
  InventoryFilterNotifier() : super(const InventoryFilterState());

  void setSearch(String q) => state = state.copyWith(search: q);

  void setCategory(String? cat) => state = state.copyWith(category: cat);

  void setShelfLocation(String? loc) =>
      state = state.copyWith(shelfLocation: loc);

  void toggleLowStockOnly() => state = state.copyWith(
    lowStockOnly: !state.lowStockOnly,
    outOfStockOnly: false,
  );

  void toggleOutOfStockOnly() => state = state.copyWith(
    outOfStockOnly: !state.outOfStockOnly,
    lowStockOnly: false,
  );

  void toggleGridView() =>
      state = state.copyWith(isGridView: !state.isGridView);

  void toggleBulkSelectMode() {
    final next = !state.bulkSelectMode;
    state = state.copyWith(bulkSelectMode: next, selectedIds: const {});
  }

  void toggleSelect(String id) {
    final set = Set<String>.from(state.selectedIds);
    if (set.contains(id)) {
      set.remove(id);
    } else {
      set.add(id);
    }
    state = state.copyWith(selectedIds: set);
  }

  void selectAll(List<InventoryProduct> products) {
    state = state.copyWith(selectedIds: products.map((p) => p.id).toSet());
  }

  void clearSelection() => state = state.copyWith(selectedIds: const {});

  void clearFilters() => state = state.copyWith(
    category: null,
    shelfLocation: null,
    lowStockOnly: false,
    outOfStockOnly: false,
  );

  bool get hasActiveFilters =>
      state.category != null ||
      state.shelfLocation != null ||
      state.lowStockOnly ||
      state.outOfStockOnly;
}

final inventoryFilterProvider =
    StateNotifierProvider<InventoryFilterNotifier, InventoryFilterState>(
      (ref) => InventoryFilterNotifier(),
    );

final allProductsProvider = FutureProvider.autoDispose<List<InventoryProduct>>((
  ref,
) {
  ref.watch(inventoryRefreshProvider);
  return LocalInventoryRepository.instance.listProducts();
});

final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<InventoryProduct>>>((ref) {
      final allAsync = ref.watch(allProductsProvider);
      final filter = ref.watch(inventoryFilterProvider);

      return allAsync.whenData((products) {
        var result = products;

        if (filter.search.isNotEmpty) {
          final q = filter.search.toLowerCase();
          result = result
              .where(
                (p) =>
                    p.name.toLowerCase().contains(q) ||
                    p.sku.toLowerCase().contains(q),
              )
              .toList();
        }

        if (filter.category != null) {
          result = result.where((p) => p.category == filter.category).toList();
        }

        if (filter.shelfLocation != null) {
          result = result
              .where((p) => p.shelfLocation == filter.shelfLocation)
              .toList();
        }

        if (filter.lowStockOnly) {
          result = result.where((p) => p.isLowStock).toList();
        }

        if (filter.outOfStockOnly) {
          result = result.where((p) => p.isOutOfStock).toList();
        }

        return result;
      });
    });

final inventorySummaryProvider =
    Provider.autoDispose<AsyncValue<InventorySummary>>((ref) {
      final allAsync = ref.watch(allProductsProvider);
      return allAsync.whenData((products) {
        return InventorySummary(
          totalProducts: products.length,
          totalStock: products.fold(0, (s, p) => s + p.stockQuantity),
          lowStockCount: products.where((p) => p.isLowStock).length,
          outOfStockCount: products.where((p) => p.isOutOfStock).length,
          totalStockValue: products.fold<double>(0, (s, p) {
            final unit = p.costPrice > 0 ? p.costPrice : p.sellingPrice;
            return s + unit * p.stockQuantity;
          }),
        );
      });
    });

final stockMovementsProvider = FutureProvider.autoDispose
    .family<List<StockMovement>, String>((ref, productId) {
      return LocalInventoryRepository.instance.getMovementsForProduct(
        productId,
      );
    });

/// Returns the products currently assigned to [shelfName] (matched by
/// product `shelfLocation` string). Used by the shelf-detail screen and
/// scan-to-locate flow so the operator can see exactly which SKUs should
/// live on the physical shelf they just scanned.
final productsByShelfNameProvider = Provider.autoDispose
    .family<AsyncValue<List<InventoryProduct>>, String>((ref, shelfName) {
      final allAsync = ref.watch(allProductsProvider);
      return allAsync.whenData(
        (products) =>
            products.where((p) => p.shelfLocation == shelfName).toList(),
      );
    });

// ─── Lookup table providers ───────────────────────────────────────────────

/// Increment to force re-fetch of categories.
final categoriesRefreshProvider = StateProvider<int>((ref) => 0);

/// Increment to force re-fetch of shelf locations.
final shelfLocationsRefreshProvider = StateProvider<int>((ref) => 0);

final allCategoriesProvider = FutureProvider.autoDispose<List<CustomCategory>>((
  ref,
) {
  ref.watch(categoriesRefreshProvider);
  return LocalInventoryRepository.instance.listCategories();
});

final allShelfLocationsProvider =
    FutureProvider.autoDispose<List<CustomShelfLocation>>((ref) {
      ref.watch(shelfLocationsRefreshProvider);
      return LocalInventoryRepository.instance.listShelfLocations();
    });

/// Categories pinned to the dashboard chip row. Hard-capped at
/// [maxQuickAccessCategories] by the repository on every mutating call, so
/// this provider simply filters whatever is in the table.
final quickAccessCategoriesProvider =
    Provider.autoDispose<AsyncValue<List<CustomCategory>>>((ref) {
      final all = ref.watch(allCategoriesProvider);
      return all.whenData(
        (cats) => cats.where((c) => c.isQuickAccess).toList(),
      );
    });
