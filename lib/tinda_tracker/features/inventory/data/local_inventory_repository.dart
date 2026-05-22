import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/sync_config.dart';
import 'models/custom_category.dart';
import 'models/custom_shelf_location.dart';
import 'models/inventory_product.dart';
import 'models/stock_movement.dart';

/// Thrown by [LocalInventoryRepository.createProduct] when a local product
/// with the same SKU already exists. The UI should offer a restock flow.
class DuplicateSkuException implements Exception {
  final InventoryProduct existing;
  const DuplicateSkuException(this.existing);
}

/// Local-first inventory repository.
///
/// All writes hit SQLite immediately (is_dirty = 1), then fire a background
/// API call. On success the server_id is stored and the row is marked clean.
/// Reads always come from local SQLite, keeping the UI fast and offline-safe.
class LocalInventoryRepository {
  static LocalInventoryRepository? _instance;
  static LocalInventoryRepository get instance =>
      _instance ??= LocalInventoryRepository._();
  LocalInventoryRepository._();

  static const _uuid = Uuid();
  static const _timeout = Duration(seconds: 12);
  final _db = AppDatabase.instance;

  // ─── helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, Object?>?> _rowById(String id) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.ttProductsTable,
      where: 'server_id = ? OR sync_id = ?',
      whereArgs: [id, id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  // ─── public API ───────────────────────────────────────────────────────────

  Future<List<InventoryProduct>> listProducts({
    String? search,
    bool includeDeleted = false,
  }) async {
    final db = await _db.database;
    var rows = await db.query(
      AppDatabase.ttProductsTable,
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'is_active DESC, name ASC',
    );
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      rows = rows.where((r) {
        final name = (r['name'] as String).toLowerCase();
        final sku = (r['sku'] as String).toLowerCase();
        return name.contains(q) || sku.contains(q);
      }).toList();
    }
    return rows.map(InventoryProduct.fromLocalDb).toList();
  }

  Future<InventoryProduct> getById(String id) async {
    final row = await _rowById(id);
    if (row == null) throw Exception('Product not found: $id');
    return InventoryProduct.fromLocalDb(row);
  }

  Future<InventoryProduct> createProduct({
    required String name,
    required String sku,
    String description = '',
    String category = 'General',
    String unit = 'pcs',
    double costPrice = 0,
    required double sellingPrice,
    int stockQuantity = 0,
    int reorderPoint = 0,
    bool isActive = true,
    String shelfLocation = 'Counter',
    String? imagePath,
    DateTime? expirationDate,
  }) async {
    // Block duplicate SKU locally — throw so the UI can offer a restock flow.
    final db = await _db.database;
    final existing = await db.query(
      AppDatabase.ttProductsTable,
      where: 'sku = ? AND is_deleted = 0',
      whereArgs: [sku],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw DuplicateSkuException(InventoryProduct.fromLocalDb(existing.first));
    }
    final syncId = _uuid.v4();
    final deviceId = await _db.getOrCreateDeviceId();
    final now = DateTime.now().toIso8601String();

    await db.insert(AppDatabase.ttProductsTable, {
      'sync_id': syncId,
      'server_id': null,
      'device_id': deviceId,
      'name': name,
      'sku': sku,
      'description': description,
      'category': category,
      'unit': unit,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'reorder_point': reorderPoint,
      'is_active': isActive ? 1 : 0,
      'is_deleted': 0,
      'is_dirty': 1,
      'image_path': imagePath,
      'image_url': null,
      'shelf_location': shelfLocation,
      'expiration_date': expirationDate?.toIso8601String(),
      'created_at': now,
      'updated_at': now,
    });

    final rows = await db.query(
      AppDatabase.ttProductsTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    final product = InventoryProduct.fromLocalDb(rows.first);
    return product;
  }

  Future<InventoryProduct> updateProduct(
    String id, {
    String? name,
    String? sku,
    String? description,
    String? category,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    int? reorderPoint,
    bool? isActive,
    String? shelfLocation,
    String? imagePath,
    Object? expirationDate = _updateSentinel,
  }) async {
    final row = await _rowById(id);
    if (row == null) throw Exception('Product not found: $id');
    final syncId = row['sync_id'] as String;

    final patch = <String, Object?>{
      'is_dirty': 1,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) {
      patch['name'] = name;
    }
    if (sku != null) {
      patch['sku'] = sku;
    }
    if (description != null) {
      patch['description'] = description;
    }
    if (category != null) {
      patch['category'] = category;
    }
    if (unit != null) {
      patch['unit'] = unit;
    }
    if (costPrice != null) {
      patch['cost_price'] = costPrice;
    }
    if (sellingPrice != null) {
      patch['selling_price'] = sellingPrice;
    }
    if (reorderPoint != null) {
      patch['reorder_point'] = reorderPoint;
    }
    if (isActive != null) {
      patch['is_active'] = isActive ? 1 : 0;
    }
    if (shelfLocation != null) {
      patch['shelf_location'] = shelfLocation;
    }
    if (imagePath != null) {
      patch['image_path'] = imagePath;
      // Clear the cached server URL so the sync service re-uploads the new file.
      patch['image_url'] = null;
    }
    if (expirationDate != _updateSentinel) {
      patch['expiration_date'] = (expirationDate as DateTime?)
          ?.toIso8601String();
    }

    final db = await _db.database;
    await db.update(
      AppDatabase.ttProductsTable,
      patch,
      where: 'sync_id = ?',
      whereArgs: [syncId],
    );
    final result = await db.query(
      AppDatabase.ttProductsTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    final product = InventoryProduct.fromLocalDb(result.first);
    return product;
  }

  Future<InventoryProduct> adjustStock({
    required String productId,
    required int quantityDelta,
    String movementType = 'ADJUSTMENT',
    String note = '',
    DateTime? expirationDate,
  }) async {
    final row = await _rowById(productId);
    if (row == null) throw Exception('Product not found: $productId');
    final syncId = row['sync_id'] as String;
    final serverId = row['server_id'] as String?;
    final newStock = (row['stock_quantity'] as int) + quantityDelta;

    final effectiveNote = expirationDate != null
        ? '$note${note.isNotEmpty ? ' ' : ''}(expires: ${expirationDate.toIso8601String().split('T').first})'
        : note;

    final db = await _db.database;
    await db.update(
      AppDatabase.ttProductsTable,
      {
        'stock_quantity': newStock,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'sync_id = ?',
      whereArgs: [syncId],
    );
    final result = await db.query(
      AppDatabase.ttProductsTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    final product = InventoryProduct.fromLocalDb(result.first);

    // If we have a server_id, fire-and-forget the adjust-stock endpoint so
    // a proper movement record (with expirationDate) is created server-side.
    if (serverId != null) {
      unawaited(
        _pushAdjustMovement(
          serverId: serverId,
          syncId: syncId,
          quantityDelta: quantityDelta,
          movementType: movementType,
          note: effectiveNote,
          expirationDate: expirationDate,
        ),
      );
    }

    return product;
  }

  Future<void> deleteProduct(String id) async {
    final row = await _rowById(id);
    if (row == null) return;
    final syncId = row['sync_id'] as String;

    final db = await _db.database;
    await db.update(
      AppDatabase.ttProductsTable,
      {
        'is_deleted': 1,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'sync_id = ?',
      whereArgs: [syncId],
    );
  }

  /// Stock movements are server-computed; always fetch from API (no local cache).
  Future<List<StockMovement>> getMovementsForProduct(String productId) async {
    try {
      final row = await _rowById(productId);
      final apiId = (row?['server_id'] as String?) ?? productId;
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final uri = Uri.parse('$baseUrl/inventory/products/$apiId/movements');
      final res = await http.get(uri).timeout(_timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      return list
          .map((e) => StockMovement.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<InventorySummary> getSummary() async {
    final products = await listProducts();
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
  }

  // Fire-and-forget: creates a proper server-side movement record so that
  // expiration date and movement history are preserved. Silently ignored
  // if the server is unreachable (the stock quantity is already updated locally).
  Future<void> _pushAdjustMovement({
    required String serverId,
    required String syncId,
    required int quantityDelta,
    required String movementType,
    required String note,
    DateTime? expirationDate,
  }) async {
    try {
      final baseUrl = await SyncConfig.getBaseApiUrl();
      final body = <String, dynamic>{
        'quantityDelta': quantityDelta,
        'movementType': movementType,
        if (note.isNotEmpty) 'note': note,
        if (expirationDate != null)
          'expirationDate': expirationDate.toIso8601String(),
      };
      final res = await http
          .post(
            Uri.parse('$baseUrl/inventory/products/$serverId/adjust-stock'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        // Server confirmed — mark row clean so syncAll() won't re-patch quantity.
        final db = await _db.database;
        await db.update(
          AppDatabase.ttProductsTable,
          {'is_dirty': 0},
          where: 'sync_id = ?',
          whereArgs: [syncId],
        );
      }
    } catch (_) {
      // Offline or server error — syncAll() will patch the quantity later.
    }
  }

  // ─── Category CRUD ────────────────────────────────────────────────────────

  Future<List<CustomCategory>> listCategories({
    bool includeDeleted = false,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.ttProductCategoriesTable,
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'name ASC',
    );
    return rows.map(CustomCategory.fromLocalDb).toList();
  }

  Future<CustomCategory> createCategory(
    String name, {
    String description = '',
    String examples = '',
    bool isQuickAccess = false,
  }) async {
    if (isQuickAccess) {
      await _assertCanPinAnotherQuickAccessCategory(localIdAlreadyPinned: -1);
    }
    await _assertCategoryNameAvailable(name, excludeLocalId: -1);
    final db = await _db.database;
    final syncId = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert(AppDatabase.ttProductCategoriesTable, {
      'sync_id': syncId,
      'server_id': null,
      'name': name.trim(),
      'description': description.trim(),
      'examples': examples.trim(),
      'is_quick_access': isQuickAccess ? 1 : 0,
      'is_deleted': 0,
      'is_dirty': 1,
      'created_at': now,
      'updated_at': now,
    });
    final rows = await db.query(
      AppDatabase.ttProductCategoriesTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    return CustomCategory.fromLocalDb(rows.first);
  }

  /// Updates the editable fields of a category.
  /// Any field left as [_updateSentinel] keeps its existing value.
  /// Flips `is_dirty` so the row is queued for the next push.
  Future<CustomCategory> updateCategory(
    int localId, {
    Object? name = _updateSentinel,
    Object? description = _updateSentinel,
    Object? examples = _updateSentinel,
    Object? isQuickAccess = _updateSentinel,
  }) async {
    if (isQuickAccess is bool && isQuickAccess == true) {
      await _assertCanPinAnotherQuickAccessCategory(
        localIdAlreadyPinned: localId,
      );
    }
    if (name is String) {
      await _assertCategoryNameAvailable(name, excludeLocalId: localId);
    }
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final patch = <String, Object?>{'is_dirty': 1, 'updated_at': now};
    if (name is String) patch['name'] = name.trim();
    if (description is String) patch['description'] = description.trim();
    if (examples is String) patch['examples'] = examples.trim();
    if (isQuickAccess is bool) patch['is_quick_access'] = isQuickAccess ? 1 : 0;
    await db.update(
      AppDatabase.ttProductCategoriesTable,
      patch,
      where: 'id = ?',
      whereArgs: [localId],
    );
    final rows = await db.query(
      AppDatabase.ttProductCategoriesTable,
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    return CustomCategory.fromLocalDb(rows.first);
  }

  /// Count of categories currently pinned to the dashboard chip row.
  Future<int> countQuickAccessCategories() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppDatabase.ttProductCategoriesTable} '
      'WHERE is_quick_access = 1 AND is_deleted = 0',
    );
    return (rows.first['c'] as int?) ?? 0;
  }

  /// Throws a [QuickAccessLimitException] if pinning another category would
  /// push the active count over [maxQuickAccessCategories].
  ///
  /// Pass the [localIdAlreadyPinned] of the row being edited (or `-1` when
  /// creating a new one) so toggling a row that's already pinned is a no-op.
  Future<void> _assertCanPinAnotherQuickAccessCategory({
    required int localIdAlreadyPinned,
  }) async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM ${AppDatabase.ttProductCategoriesTable} '
      'WHERE is_quick_access = 1 AND is_deleted = 0 AND id != ?',
      [localIdAlreadyPinned],
    );
    final otherPinned = (rows.first['c'] as int?) ?? 0;
    if (otherPinned + 1 > maxQuickAccessCategories) {
      throw QuickAccessLimitException(
        limit: maxQuickAccessCategories,
        attempted: otherPinned + 1,
      );
    }
  }

  /// Throws a [DuplicateNameException] if another (non-deleted) category
  /// already has the given [name] (case-insensitive). Pass the editing
  /// row's [excludeLocalId] (or `-1` when creating) so renaming a row to
  /// its current value is allowed.
  Future<void> _assertCategoryNameAvailable(
    String name, {
    required int excludeLocalId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT id FROM ${AppDatabase.ttProductCategoriesTable} '
      'WHERE is_deleted = 0 AND id != ? AND LOWER(name) = LOWER(?) LIMIT 1',
      [excludeLocalId, trimmed],
    );
    if (rows.isNotEmpty) {
      throw DuplicateNameException(name: trimmed, kind: 'category');
    }
  }

  /// Same idea as [_assertCategoryNameAvailable] but for shelf locations.
  Future<void> _assertShelfLocationNameAvailable(
    String name, {
    required int excludeLocalId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT id FROM ${AppDatabase.ttShelfLocationsTable} '
      'WHERE is_deleted = 0 AND id != ? AND LOWER(name) = LOWER(?) LIMIT 1',
      [excludeLocalId, trimmed],
    );
    if (rows.isNotEmpty) {
      throw DuplicateNameException(name: trimmed, kind: 'shelf location');
    }
  }

  Future<void> deleteCategory(int localId) async {
    final db = await _db.database;
    await db.update(
      AppDatabase.ttProductCategoriesTable,
      {
        'is_deleted': 1,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // ─── Shelf Location CRUD ──────────────────────────────────────────────────

  Future<List<CustomShelfLocation>> listShelfLocations({
    bool includeDeleted = false,
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      AppDatabase.ttShelfLocationsTable,
      where: includeDeleted ? null : 'is_deleted = 0',
      orderBy: 'name ASC',
    );
    return rows.map(CustomShelfLocation.fromLocalDb).toList();
  }

  Future<CustomShelfLocation> createShelfLocation(
    String name, {
    String description = '',
    String examples = '',
    String? imagePath,
  }) async {
    await _assertShelfLocationNameAvailable(name, excludeLocalId: -1);
    final db = await _db.database;
    final syncId = _uuid.v4();
    final now = DateTime.now().toIso8601String();
    await db.insert(AppDatabase.ttShelfLocationsTable, {
      'sync_id': syncId,
      'server_id': null,
      'name': name.trim(),
      'description': description.trim(),
      'examples': examples.trim(),
      'image_path': imagePath,
      'image_url': null,
      'is_deleted': 0,
      'is_dirty': 1,
      'created_at': now,
      'updated_at': now,
    });
    final rows = await db.query(
      AppDatabase.ttShelfLocationsTable,
      where: 'sync_id = ?',
      whereArgs: [syncId],
      limit: 1,
    );
    return CustomShelfLocation.fromLocalDb(rows.first);
  }

  /// Updates the editable fields of a shelf location.
  /// Any field left as [_updateSentinel] keeps its existing value.
  /// Passing a new [imagePath] also clears the previously cached `image_url`
  /// so the sync worker re-uploads the fresh file.
  Future<CustomShelfLocation> updateShelfLocation(
    int localId, {
    Object? name = _updateSentinel,
    Object? description = _updateSentinel,
    Object? examples = _updateSentinel,
    Object? imagePath = _updateSentinel,
  }) async {
    if (name is String) {
      await _assertShelfLocationNameAvailable(name, excludeLocalId: localId);
    }
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    final patch = <String, Object?>{'is_dirty': 1, 'updated_at': now};
    if (name is String) patch['name'] = name.trim();
    if (description is String) patch['description'] = description.trim();
    if (examples is String) patch['examples'] = examples.trim();
    if (imagePath != _updateSentinel) {
      patch['image_path'] = imagePath as String?;
      // New file means the previous remote URL no longer matches; force a
      // re-upload on the next sync run.
      patch['image_url'] = null;
    }
    await db.update(
      AppDatabase.ttShelfLocationsTable,
      patch,
      where: 'id = ?',
      whereArgs: [localId],
    );
    final rows = await db.query(
      AppDatabase.ttShelfLocationsTable,
      where: 'id = ?',
      whereArgs: [localId],
      limit: 1,
    );
    return CustomShelfLocation.fromLocalDb(rows.first);
  }

  Future<void> deleteShelfLocation(int localId) async {
    final db = await _db.database;
    await db.update(
      AppDatabase.ttShelfLocationsTable,
      {
        'is_deleted': 1,
        'is_dirty': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  static const Object _updateSentinel = Object();
}

/// Hard cap on the number of categories that can be pinned to the dashboard
/// chip row. Mirrors the server's enforcement in `inventory.service.ts`.
const int maxQuickAccessCategories = 10;

/// Thrown when a user tries to save a category or shelf location whose
/// trimmed name (case-insensitive) collides with an existing active row.
/// UI layers catch this to surface a friendly SnackBar.
class DuplicateNameException implements Exception {
  const DuplicateNameException({required this.name, required this.kind});

  /// The conflicting name the user attempted to save.
  final String name;

  /// Human-readable label of what kind of record clashed
  /// (e.g. `'category'`, `'shelf location'`).
  final String kind;

  @override
  String toString() => 'DuplicateNameException: $kind "$name" already exists';
}

/// Thrown by [LocalInventoryRepository] when pinning another category would
/// exceed [maxQuickAccessCategories]. UI layers catch this to surface a
/// user-friendly SnackBar without aborting the wider transaction.
class QuickAccessLimitException implements Exception {
  const QuickAccessLimitException({
    required this.limit,
    required this.attempted,
  });
  final int limit;
  final int attempted;

  @override
  String toString() =>
      'QuickAccessLimitException: $attempted exceeds limit of $limit';
}

class InventorySummary {
  final int totalProducts;
  final int totalStock;
  final int lowStockCount;
  final int outOfStockCount;

  /// Total inventory value at cost (sum of `costPrice * stockQuantity` across
  /// active products). Falls back to selling price when cost is 0 so the
  /// dashboard tile is never blank for shop owners who skip cost entry.
  final double totalStockValue;

  const InventorySummary({
    required this.totalProducts,
    required this.totalStock,
    required this.lowStockCount,
    required this.outOfStockCount,
    this.totalStockValue = 0,
  });
}
