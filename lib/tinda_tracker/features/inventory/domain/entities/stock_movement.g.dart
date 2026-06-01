// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StockMovementImpl _$$StockMovementImplFromJson(Map<String, dynamic> json) =>
    _$StockMovementImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      movementType: const _StockMovementTypeConverter().fromJson(
        json['movementType'] as String,
      ),
      quantity: (json['quantity'] as num).toDouble(),
      previousQuantity: (json['previousQuantity'] as num).toDouble(),
      newQuantity: (json['newQuantity'] as num).toDouble(),
      note: json['note'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StockMovementImplToJson(_$StockMovementImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productId': instance.productId,
      'movementType': const _StockMovementTypeConverter().toJson(
        instance.movementType,
      ),
      'quantity': instance.quantity,
      'previousQuantity': instance.previousQuantity,
      'newQuantity': instance.newQuantity,
      'note': instance.note,
      'reference': instance.reference,
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
