import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/tinda_tracker_tables.dart';

part 'product_recipe_ingredients_dao.g.dart';

@DriftAccessor(tables: [ProductRecipeIngredients])
class ProductRecipeIngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductRecipeIngredientsDaoMixin {
  ProductRecipeIngredientsDao(super.db);

  Stream<List<ProductRecipeIngredientRow>> watchForRecipe(String recipeProductId) {
    return (select(productRecipeIngredients)
          ..where(
            (t) => t.recipeProductId.equals(recipeProductId) & t.isDeleted.equals(false),
          ))
        .watch();
  }

  Future<List<ProductRecipeIngredientRow>> listForRecipe(String recipeProductId) {
    return (select(productRecipeIngredients)..where(
          (t) => t.recipeProductId.equals(recipeProductId) & t.isDeleted.equals(false),
        ))
        .get();
  }

  Future<ProductRecipeIngredientRow?> findById(String id) {
    return (select(
      productRecipeIngredients,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ProductRecipeIngredientRow?> findBySyncId(String syncId) {
    return (select(
      productRecipeIngredients,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  Future<void> upsertLocal(ProductRecipeIngredientsCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(productRecipeIngredients).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(productRecipeIngredients)..where((t) => t.id.equals(id))).write(
      ProductRecipeIngredientsCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<ProductRecipeIngredientRow>> pendingPush() {
    return (select(
      productRecipeIngredients,
    )..where((t) => t.isDirty.equals(true))).get();
  }

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(productRecipeIngredients)..where((t) => t.syncId.isIn(syncIds)))
        .write(const ProductRecipeIngredientsCompanion(isDirty: Value(false)));
  }

  Future<bool> upsertFromRemote(ProductRecipeIngredientsCompanion remote) async {
    final existing = await findBySyncId(remote.syncId.value);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    final patched = (existing != null && existing.id != remote.id.value)
        ? remote.copyWith(id: Value(existing.id), isDirty: const Value(false))
        : remote.copyWith(isDirty: const Value(false));
    await into(productRecipeIngredients).insertOnConflictUpdate(patched);
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      productRecipeIngredients,
    )..addColumns([productRecipeIngredients.updatedAtMs.max()])).getSingle();
    return row.read(productRecipeIngredients.updatedAtMs.max()) ?? 0;
  }
}
