import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/product_recipe_ingredient.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension ProductRecipeIngredientRowMapper on ProductRecipeIngredientRow {
  ProductRecipeIngredient toDomain() => ProductRecipeIngredient(
    id: id,
    recipeProductId: recipeProductId,
    ingredientProductId: ingredientProductId,
    quantityNeeded: quantityNeeded,
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

extension ProductRecipeIngredientCompanionMapper on ProductRecipeIngredient {
  ProductRecipeIngredientsCompanion toCompanion() =>
      ProductRecipeIngredientsCompanion(
        id: Value(id),
        syncId: Value(sync.syncId),
        deviceId: Value(sync.deviceId),
        isDeleted: Value(sync.isDeleted),
        isDirty: Value(sync.isDirty),
        createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
        updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
        recipeProductId: Value(recipeProductId),
        ingredientProductId: Value(ingredientProductId),
        quantityNeeded: Value(quantityNeeded),
      );
}

ProductRecipeIngredientsCompanion productRecipeIngredientCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return ProductRecipeIngredientsCompanion(
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
    recipeProductId: Value(json['recipeProductId'] as String),
    ingredientProductId: Value(json['ingredientProductId'] as String),
    quantityNeeded: Value(asDouble(json['quantityNeeded'])),
  );
}

Map<String, dynamic> productRecipeIngredientToRemoteJson(
  ProductRecipeIngredient pri,
) => {
  'id': pri.id,
  'syncId': pri.sync.syncId,
  'deviceId': pri.sync.deviceId,
  'recipeProductId': pri.recipeProductId,
  'ingredientProductId': pri.ingredientProductId,
  'quantityNeeded': pri.quantityNeeded,
  'isDeleted': pri.sync.isDeleted,
  'createdAt': pri.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': pri.sync.updatedAt.toUtc().toIso8601String(),
};
