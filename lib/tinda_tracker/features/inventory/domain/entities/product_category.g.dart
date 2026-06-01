// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductCategoryImpl _$$ProductCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$ProductCategoryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  examples: json['examples'] as String? ?? '',
  isQuickAccess: json['isQuickAccess'] as bool? ?? false,
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProductCategoryImplToJson(
  _$ProductCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'examples': instance.examples,
  'isQuickAccess': instance.isQuickAccess,
  'sync': instance.sync,
};
