// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      baseUnit: json['baseUnit'] as String? ?? 'pcs',
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      sellingPrice: (json['sellingPrice'] as num).toDouble(),
      stockInBaseUnit: (json['stockInBaseUnit'] as num?)?.toDouble() ?? 0,
      reorderPoint: (json['reorderPoint'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      shelfLocation: json['shelfLocation'] as String? ?? 'Counter',
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      categoryId: json['categoryId'] as String?,
      shelfLocationId: json['shelfLocationId'] as String?,
      itemType: json['itemType'] as String? ?? 'standard',
      customAttributes:
          json['customAttributes'] as Map<String, dynamic>? ??
          const <String, dynamic>{},
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sku': instance.sku,
      'description': instance.description,
      'category': instance.category,
      'baseUnit': instance.baseUnit,
      'costPrice': instance.costPrice,
      'sellingPrice': instance.sellingPrice,
      'stockInBaseUnit': instance.stockInBaseUnit,
      'reorderPoint': instance.reorderPoint,
      'isActive': instance.isActive,
      'imageUrl': instance.imageUrl,
      'shelfLocation': instance.shelfLocation,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'categoryId': instance.categoryId,
      'shelfLocationId': instance.shelfLocationId,
      'itemType': instance.itemType,
      'customAttributes': instance.customAttributes,
      'sync': instance.sync,
    };
