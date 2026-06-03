// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_unit_conversion.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductUnitConversionImpl _$$ProductUnitConversionImplFromJson(
  Map<String, dynamic> json,
) => _$ProductUnitConversionImpl(
  id: json['id'] as String,
  productId: json['productId'] as String,
  unitName: json['unitName'] as String,
  conversionFactor: (json['conversionFactor'] as num).toDouble(),
  costPrice: (json['costPrice'] as num).toDouble(),
  sellingPrice: (json['sellingPrice'] as num).toDouble(),
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProductUnitConversionImplToJson(
  _$ProductUnitConversionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'unitName': instance.unitName,
  'conversionFactor': instance.conversionFactor,
  'costPrice': instance.costPrice,
  'sellingPrice': instance.sellingPrice,
  'sync': instance.sync,
};
