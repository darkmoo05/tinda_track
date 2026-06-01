// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleImpl _$$SaleImplFromJson(Map<String, dynamic> json) => _$SaleImpl(
  id: json['id'] as String,
  reference: json['reference'] as String,
  note: json['note'] as String? ?? '',
  subtotal: (json['subtotal'] as num).toDouble(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  paidAmount: (json['paidAmount'] as num).toDouble(),
  changeAmount: (json['changeAmount'] as num?)?.toDouble() ?? 0,
  totalItems: (json['totalItems'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <SaleItem>[],
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$SaleImplToJson(_$SaleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reference': instance.reference,
      'note': instance.note,
      'subtotal': instance.subtotal,
      'totalAmount': instance.totalAmount,
      'paidAmount': instance.paidAmount,
      'changeAmount': instance.changeAmount,
      'totalItems': instance.totalItems,
      'items': instance.items,
      'sync': instance.sync,
    };
