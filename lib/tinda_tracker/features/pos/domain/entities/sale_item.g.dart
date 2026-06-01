// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleItemImpl _$$SaleItemImplFromJson(Map<String, dynamic> json) =>
    _$SaleItemImpl(
      id: json['id'] as String,
      saleId: json['saleId'] as String,
      productId: json['productId'] as String,
      selectedUnit: json['selectedUnit'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      computedBaseQuantity: (json['computedBaseQuantity'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SaleItemImplToJson(_$SaleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'saleId': instance.saleId,
      'productId': instance.productId,
      'selectedUnit': instance.selectedUnit,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'computedBaseQuantity': instance.computedBaseQuantity,
      'lineTotal': instance.lineTotal,
      'createdAt': instance.createdAt.toIso8601String(),
    };
