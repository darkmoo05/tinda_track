// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TxRecordImpl _$$TxRecordImplFromJson(Map<String, dynamic> json) =>
    _$TxRecordImpl(
      id: json['id'] as String,
      walletProvider: const _WalletProviderConverter().fromJson(
        json['walletProvider'] as String,
      ),
      direction: const _TransactionDirectionConverter().fromJson(
        json['direction'] as String,
      ),
      amount: (json['amount'] as num).toDouble(),
      chargeAmount: (json['chargeAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      balanceBefore: (json['balanceBefore'] as num).toDouble(),
      balanceAfter: (json['balanceAfter'] as num).toDouble(),
      chargeLowerBound: (json['chargeLowerBound'] as num?)?.toDouble(),
      chargeUpperBound: (json['chargeUpperBound'] as num?)?.toDouble(),
      chargeHandling: json['chargeHandling'] as String? ?? 'addOnTop',
      receiptImagePath: json['receiptImagePath'] as String?,
      receiptOriginalName: json['receiptOriginalName'] as String?,
      receiptMimeType: json['receiptMimeType'] as String?,
      receiptUploadedAt: json['receiptUploadedAt'] == null
          ? null
          : DateTime.parse(json['receiptUploadedAt'] as String),
      ocrStatus: json['ocrStatus'] == null
          ? OcrStatus.pending
          : const _OcrStatusConverter().fromJson(json['ocrStatus'] as String),
      ocrExtractedAmount: (json['ocrExtractedAmount'] as num?)?.toDouble(),
      ocrRawText: json['ocrRawText'] as String?,
      ocrProcessedAt: json['ocrProcessedAt'] == null
          ? null
          : DateTime.parse(json['ocrProcessedAt'] as String),
      externalProvider: json['externalProvider'] as String?,
      externalTransactionId: json['externalTransactionId'] as String?,
      note: json['note'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      entryDate: json['entryDate'] as String,
      status: json['status'] == null
          ? TransactionStatus.completed
          : const _TransactionStatusConverter().fromJson(
              json['status'] as String,
            ),
      sync: SyncMetadata.fromJson(json['sync'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TxRecordImplToJson(_$TxRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'walletProvider': const _WalletProviderConverter().toJson(
        instance.walletProvider,
      ),
      'direction': const _TransactionDirectionConverter().toJson(
        instance.direction,
      ),
      'amount': instance.amount,
      'chargeAmount': instance.chargeAmount,
      'totalAmount': instance.totalAmount,
      'balanceBefore': instance.balanceBefore,
      'balanceAfter': instance.balanceAfter,
      'chargeLowerBound': instance.chargeLowerBound,
      'chargeUpperBound': instance.chargeUpperBound,
      'chargeHandling': instance.chargeHandling,
      'receiptImagePath': instance.receiptImagePath,
      'receiptOriginalName': instance.receiptOriginalName,
      'receiptMimeType': instance.receiptMimeType,
      'receiptUploadedAt': instance.receiptUploadedAt?.toIso8601String(),
      'ocrStatus': const _OcrStatusConverter().toJson(instance.ocrStatus),
      'ocrExtractedAmount': instance.ocrExtractedAmount,
      'ocrRawText': instance.ocrRawText,
      'ocrProcessedAt': instance.ocrProcessedAt?.toIso8601String(),
      'externalProvider': instance.externalProvider,
      'externalTransactionId': instance.externalTransactionId,
      'note': instance.note,
      'reference': instance.reference,
      'entryDate': instance.entryDate,
      'status': const _TransactionStatusConverter().toJson(instance.status),
      'sync': instance.sync,
    };
