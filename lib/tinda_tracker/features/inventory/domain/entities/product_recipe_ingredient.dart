import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/domain/sync_metadata.dart';

part 'product_recipe_ingredient.freezed.dart';
part 'product_recipe_ingredient.g.dart';

@freezed
class ProductRecipeIngredient with _$ProductRecipeIngredient {
  const factory ProductRecipeIngredient({
    required String id,
    required String recipeProductId,
    required String ingredientProductId,
    required double quantityNeeded,
    required SyncMetadata sync,
  }) = _ProductRecipeIngredient;

  factory ProductRecipeIngredient.fromJson(Map<String, dynamic> json) =>
      _$ProductRecipeIngredientFromJson(json);
}
