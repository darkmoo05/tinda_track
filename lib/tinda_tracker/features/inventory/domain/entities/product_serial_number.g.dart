// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_serial_number.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductSerialNumberImpl _$$ProductSerialNumberImplFromJson(
  Map<String, dynamic> json,
) => _$ProductSerialNumberImpl(
  id: json['id'] as String,
  productId: json['productId'] as String,
  serialNumber: json['serialNumber'] as String,
  status: json['status'] as String? ?? 'AVAILABLE',
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProductSerialNumberImplToJson(
  _$ProductSerialNumberImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'serialNumber': instance.serialNumber,
  'status': instance.status,
  'sync': instance.sync,
};
