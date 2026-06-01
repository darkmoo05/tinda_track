import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/product.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension ProductRowMapper on ProductRow {
  Product toDomain() => Product(
    id: id,
    name: name,
    sku: sku,
    description: description,
    category: category,
    baseUnit: baseUnit,
    costPrice: costPrice,
    sellingPrice: sellingPrice,
    stockInBaseUnit: stockInBaseUnit,
    reorderPoint: reorderPoint,
    isActive: isActive,
    imageUrl: imageUrl,
    imageLocalPath: imageLocalPath,
    shelfLocation: shelfLocation,
    expirationDate: expirationDateMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expirationDateMs!),
    categoryId: categoryId,
    shelfLocationId: shelfLocationId,
    sync: SyncMetadata(
      syncId: syncId,
      deviceId: deviceId,
      isDeleted: isDeleted,
      isDirty: isDirty,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    ),
  );
}

extension ProductCompanionMapper on Product {
  ProductsCompanion toCompanion() => ProductsCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    sku: Value(sku),
    description: Value(description),
    category: Value(category),
    baseUnit: Value(baseUnit),
    costPrice: Value(costPrice),
    sellingPrice: Value(sellingPrice),
    stockInBaseUnit: Value(stockInBaseUnit),
    reorderPoint: Value(reorderPoint),
    isActive: Value(isActive),
    imageUrl: Value(imageUrl),
    imageLocalPath: Value(imageLocalPath),
    shelfLocation: Value(shelfLocation),
    expirationDateMs: Value(expirationDate?.millisecondsSinceEpoch),
    categoryId: Value(categoryId),
    shelfLocationId: Value(shelfLocationId),
  );
}

ProductsCompanion productCompanionFromRemoteJson(Map<String, dynamic> json) {
  return ProductsCompanion(
    id: Value(json['id'] as String),
    syncId: Value(json['syncId'] as String),
    deviceId: Value((json['deviceId'] as String?) ?? ''),
    isDeleted: Value((json['isDeleted'] as bool?) ?? false),
    isDirty: const Value(false),
    createdAtMs: Value(
      DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch,
    ),
    updatedAtMs: Value(
      DateTime.parse(json['updatedAt'] as String).millisecondsSinceEpoch,
    ),
    name: Value(json['name'] as String),
    sku: Value(json['sku'] as String),
    description: Value((json['description'] as String?) ?? ''),
    category: Value((json['category'] as String?) ?? 'General'),
    baseUnit: Value((json['baseUnit'] as String?) ?? 'pcs'),
    costPrice: Value(asDouble(json['costPrice'])),
    sellingPrice: Value(asDouble(json['sellingPrice'])),
    stockInBaseUnit: Value(asDouble(json['stockInBaseUnit'])),
    reorderPoint: Value(asInt(json['reorderPoint'])),
    isActive: Value((json['isActive'] as bool?) ?? true),
    imageUrl: Value(json['imageUrl'] as String?),
    shelfLocation: Value((json['shelfLocation'] as String?) ?? 'Counter'),
    expirationDateMs: Value(
      json['expirationDate'] == null
          ? null
          : DateTime.parse(
              json['expirationDate'] as String,
            ).millisecondsSinceEpoch,
    ),
    categoryId: Value(json['categoryId'] as String?),
    shelfLocationId: Value(json['shelfLocationId'] as String?),
    // imageLocalPath omitted — local-only.
  );
}

Map<String, dynamic> productToRemoteJson(Product p) => {
  'id': p.id,
  'syncId': p.sync.syncId,
  'deviceId': p.sync.deviceId,
  'name': p.name,
  'sku': p.sku,
  'description': p.description,
  'category': p.category,
  'baseUnit': p.baseUnit,
  'costPrice': p.costPrice,
  'sellingPrice': p.sellingPrice,
  'stockInBaseUnit': p.stockInBaseUnit,
  'reorderPoint': p.reorderPoint,
  'isActive': p.isActive,
  'imageUrl': p.imageUrl,
  'shelfLocation': p.shelfLocation,
  'expirationDate': p.expirationDate?.toUtc().toIso8601String(),
  'categoryId': p.categoryId,
  'shelfLocationId': p.shelfLocationId,
  'isDeleted': p.sync.isDeleted,
  'createdAt': p.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': p.sync.updatedAt.toUtc().toIso8601String(),
};
