// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fee_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeeTransactionImpl _$$FeeTransactionImplFromJson(Map<String, dynamic> json) =>
    _$FeeTransactionImpl(
      id: json['id'] as String,
      relatedTransactionSyncId: json['relatedTransactionSyncId'] as String?,
      feeAmount: (json['feeAmount'] as num).toDouble(),
      feeType: json['feeType'] as String,
      chargeDestination: json['chargeDestination'] as String,
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$FeeTransactionImplToJson(
  _$FeeTransactionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'relatedTransactionSyncId': instance.relatedTransactionSyncId,
  'feeAmount': instance.feeAmount,
  'feeType': instance.feeType,
  'chargeDestination': instance.chargeDestination,
  'sync': instance.sync,
};
