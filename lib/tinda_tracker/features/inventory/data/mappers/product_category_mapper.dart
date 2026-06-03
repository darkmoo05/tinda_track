import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/product_category.dart';

extension ProductCategoryRowMapper on ProductCategoryRow {
  ProductCategory toDomain() => ProductCategory(
    id: id,
    name: name,
    description: description,
    examples: examples,
    isQuickAccess: isQuickAccess,
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

extension ProductCategoryCompanionMapper on ProductCategory {
  ProductCategoriesCompanion toCompanion() => ProductCategoriesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    description: Value(description),
    examples: Value(examples),
    isQuickAccess: Value(isQuickAccess),
  );
}

ProductCategoriesCompanion productCategoryCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return ProductCategoriesCompanion(
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
    description: Value((json['description'] as String?) ?? ''),
    examples: Value((json['examples'] as String?) ?? ''),
    isQuickAccess: Value((json['isQuickAccess'] as bool?) ?? false),
  );
}

Map<String, dynamic> productCategoryToRemoteJson(ProductCategory c) => {
  'id': c.id,
  'syncId': c.sync.syncId,
  'deviceId': c.sync.deviceId,
  'name': c.name,
  'description': c.description,
  'examples': c.examples,
  'isQuickAccess': c.isQuickAccess,
  'isDeleted': c.sync.isDeleted,
  'createdAt': c.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': c.sync.updatedAt.toUtc().toIso8601String(),
};
