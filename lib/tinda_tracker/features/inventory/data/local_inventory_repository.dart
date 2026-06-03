import 'package:tinda_track/core/database/repositories/inventory_repository.dart';
import 'package:tinda_track/tinda_tracker/features/inventory/data/models/inventory_product.dart';

export 'package:tinda_track/core/database/repositories/inventory_repository.dart';
export 'package:tinda_track/core/database/providers/database_providers.dart' show localInventoryRepositoryProvider;

typedef LocalInventoryRepository = InventoryRepository;

/// Hard cap on the number of categories that can be pinned to the dashboard
/// chip row. Enforced by [LocalInventoryRepository] on every mutating call.
const int maxQuickAccessCategories = 10;

/// Thrown by [LocalInventoryRepository.createProduct] when an existing
/// product (including soft-deleted) already uses the same SKU. The
/// caller can offer a restock-the-existing-row flow with [existing].
class DuplicateSkuException implements Exception {
  final InventoryProduct existing;
  const DuplicateSkuException(this.existing);

  @override
  String toString() => 'DuplicateSkuException(existing=${existing.sku})';
}

/// Thrown when a category / shelf-location name collides with an
/// existing non-deleted row.
class DuplicateNameException implements Exception {
  /// Human-readable kind, e.g. 'category' or 'shelf location'.
  final String kind;
  final String name;
  const DuplicateNameException({required this.kind, required this.name});

  @override
  String toString() => 'DuplicateNameException($kind "$name")';
}

/// Thrown when pinning a category would exceed
/// [maxQuickAccessCategories].
class QuickAccessLimitException implements Exception {
  final int limit;
  const QuickAccessLimitException(this.limit);

  @override
  String toString() =>
      'QuickAccessLimitException(limit=$limit) — pin one fewer to add another.';
}

/// Aggregate counts/value for the inventory dashboard summary card.
class InventorySummary {
  final int totalProducts;
  final int totalStock;
  final int lowStockCount;
  final int outOfStockCount;
  final double totalStockValue;

  const InventorySummary({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
    required this.totalStockValue,
  });
}
