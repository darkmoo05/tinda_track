// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovementCategoryImpl _$$MovementCategoryImplFromJson(
  Map<String, dynamic> json,
) => _$MovementCategoryImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$MovementCategoryImplToJson(
  _$MovementCategoryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sync': instance.sync,
};
