import '../../../../tinda_tracker/features/inventory/data/models/custom_category.dart';
import '../../../../tinda_tracker/features/inventory/data/models/custom_shelf_location.dart';
import '../../../../tinda_tracker/features/inventory/data/models/inventory_product.dart';
import '../../../../tinda_tracker/features/inventory/data/models/product_unit_conversion.dart';
import '../../../../tinda_tracker/features/inventory/data/models/stock_movement.dart';
import '../../../../tinda_tracker/features/inventory/data/local_inventory_repository.dart' show InventorySummary;

const Object updateSentinel = Object();

abstract class InventoryRepository {
  // Products
  Future<List<InventoryProduct>> listProducts({
    String? search,
    bool includeDeleted = false,
  });
  Future<InventoryProduct?> getById(String id);
  Future<InventoryProduct> createProduct({
    required String name,
    required String sku,
    String description = '',
    String category = 'General',
    String unit = 'pcs',
    String? baseUnit,
    double costPrice = 0,
    required double sellingPrice,
    int stockQuantity = 0,
    double? stockInBaseUnit,
    int reorderPoint = 0,
    bool isActive = true,
    String shelfLocation = 'Counter',
    String? imagePath,
    DateTime? expirationDate,
    List<ProductUnitConversion> unitConversions = const [],
  });
  Future<InventoryProduct> updateProduct(
    String id, {
    Object? name = updateSentinel,
    Object? sku = updateSentinel,
    Object? description = updateSentinel,
    Object? category = updateSentinel,
    Object? unit = updateSentinel,
    Object? baseUnit = updateSentinel,
    Object? costPrice = updateSentinel,
    Object? sellingPrice = updateSentinel,
    Object? stockInBaseUnit = updateSentinel,
    Object? reorderPoint = updateSentinel,
    Object? isActive = updateSentinel,
    Object? shelfLocation = updateSentinel,
    Object? imagePath = updateSentinel,
    Object? expirationDate = updateSentinel,
    Object? unitConversions = updateSentinel,
  });
  Future<void> deleteProduct(String id);
  Future<void> adjustStock({
    required String productId,
    required int quantityDelta,
    double? quantityDeltaBase,
    required String movementType,
    String note = '',
    DateTime? expirationDate,
  });
  Future<List<StockMovement>> getMovementsForProduct(String productId);
  Future<InventorySummary> getSummary();

  // Categories
  Future<List<CustomCategory>> listCategories({bool includeDeleted = false});
  Future<int> countQuickAccessCategories();
  Future<CustomCategory> createCategory(
    String name, {
    String description = '',
    String examples = '',
    bool isQuickAccess = false,
  });
  Future<CustomCategory> updateCategory(
    String id, {
    Object? name = updateSentinel,
    Object? description = updateSentinel,
    Object? examples = updateSentinel,
    Object? isQuickAccess = updateSentinel,
  });
  Future<void> deleteCategory(String id);

  // Shelf Locations
  Future<List<CustomShelfLocation>> listShelfLocations({bool includeDeleted = false});
  Future<CustomShelfLocation> createShelfLocation(
    String name, {
    String description = '',
    String examples = '',
    String? imagePath,
  });
  Future<CustomShelfLocation> updateShelfLocation(
    String id, {
    Object? name = updateSentinel,
    Object? description = updateSentinel,
    Object? examples = updateSentinel,
    Object? imagePath = updateSentinel,
  });
  Future<void> deleteShelfLocation(String id);
}
