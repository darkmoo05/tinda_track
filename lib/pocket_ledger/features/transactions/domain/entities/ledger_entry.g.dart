// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LedgerEntryImpl _$$LedgerEntryImplFromJson(Map<String, dynamic> json) =>
    _$LedgerEntryImpl(
      id: json['id'] as String,
      transactionId: json['transactionId'] as String?,
      entryType: json['entryType'] as String,
      title: json['title'] as String? ?? '',
      note: json['note'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      amount: (json['amount'] as num).toDouble(),
      walletDelta: (json['walletDelta'] as num?)?.toDouble() ?? 0,
      mayaWalletDelta: (json['mayaWalletDelta'] as num?)?.toDouble() ?? 0,
      onHandDelta: (json['onHandDelta'] as num?)?.toDouble() ?? 0,
      recordedFlow: (json['recordedFlow'] as num?)?.toDouble() ?? 0,
      tag: json['tag'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? '',
      walletAccount: json['walletAccount'] as String? ?? '',
      ownerScope: json['ownerScope'] as String? ?? 'Business',
      ownerMovementType: json['ownerMovementType'] as String?,
      ownerCategory: json['ownerCategory'] as String?,
      ownerPartyName: json['ownerPartyName'] as String?,
      ownerPartyAccount: json['ownerPartyAccount'] as String?,
      entryDate: json['entryDate'] as String,
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$LedgerEntryImplToJson(_$LedgerEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transactionId': instance.transactionId,
      'entryType': instance.entryType,
      'title': instance.title,
      'note': instance.note,
      'reference': instance.reference,
      'amount': instance.amount,
      'walletDelta': instance.walletDelta,
      'mayaWalletDelta': instance.mayaWalletDelta,
      'onHandDelta': instance.onHandDelta,
      'recordedFlow': instance.recordedFlow,
      'tag': instance.tag,
      'iconKey': instance.iconKey,
      'walletAccount': instance.walletAccount,
      'ownerScope': instance.ownerScope,
      'ownerMovementType': instance.ownerMovementType,
      'ownerCategory': instance.ownerCategory,
      'ownerPartyName': instance.ownerPartyName,
      'ownerPartyAccount': instance.ownerPartyAccount,
      'entryDate': instance.entryDate,
      'sync': instance.sync,
    };
