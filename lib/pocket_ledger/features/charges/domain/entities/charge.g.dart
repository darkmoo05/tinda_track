// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChargeImpl _$$ChargeImplFromJson(Map<String, dynamic> json) => _$ChargeImpl(
  id: json['id'] as String,
  lowerBound: (json['lowerBound'] as num).toDouble(),
  upperBound: (json['upperBound'] as num).toDouble(),
  chargeAmount: (json['chargeAmount'] as num).toDouble(),
  transactionTypeKey: json['transactionTypeKey'] as String? ?? 'gcash_cashin',
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ChargeImplToJson(_$ChargeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lowerBound': instance.lowerBound,
      'upperBound': instance.upperBound,
      'chargeAmount': instance.chargeAmount,
      'transactionTypeKey': instance.transactionTypeKey,
      'sync': instance.sync,
    };
