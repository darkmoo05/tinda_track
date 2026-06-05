// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_recipe_ingredient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductRecipeIngredientImpl _$$ProductRecipeIngredientImplFromJson(
  Map<String, dynamic> json,
) => _$ProductRecipeIngredientImpl(
  id: json['id'] as String,
  recipeProductId: json['recipeProductId'] as String,
  ingredientProductId: json['ingredientProductId'] as String,
  quantityNeeded: (json['quantityNeeded'] as num).toDouble(),
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProductRecipeIngredientImplToJson(
  _$ProductRecipeIngredientImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'recipeProductId': instance.recipeProductId,
  'ingredientProductId': instance.ingredientProductId,
  'quantityNeeded': instance.quantityNeeded,
  'sync': instance.sync,
};
