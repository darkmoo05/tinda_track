// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShelfLocationImpl _$$ShelfLocationImplFromJson(Map<String, dynamic> json) =>
    _$ShelfLocationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      examples: json['examples'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ShelfLocationImplToJson(_$ShelfLocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'examples': instance.examples,
      'imageUrl': instance.imageUrl,
      'sync': instance.sync,
    };
