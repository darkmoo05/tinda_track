// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utang_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UtangRecordImpl _$$UtangRecordImplFromJson(Map<String, dynamic> json) =>
    _$UtangRecordImpl(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      description: json['description'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UtangRecordImplToJson(_$UtangRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'description': instance.description,
      'amount': instance.amount,
      'sync': instance.sync,
    };
