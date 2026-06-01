// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionTypeImpl _$$TransactionTypeImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionTypeImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  isOutflow: json['isOutflow'] as bool? ?? false,
  walletAccount: json['walletAccount'] as String? ?? 'GCash',
  sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$TransactionTypeImplToJson(
  _$TransactionTypeImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isOutflow': instance.isOutflow,
  'walletAccount': instance.walletAccount,
  'sync': instance.sync,
};
