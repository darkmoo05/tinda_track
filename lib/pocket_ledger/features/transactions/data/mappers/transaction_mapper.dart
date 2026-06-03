import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/enums.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/transaction.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension TransactionRowMapper on TransactionRow {
  TxRecord toDomain() => TxRecord(
    id: id,
    walletProvider: WalletProvider.fromWire(walletProvider),
    direction: TransactionDirection.fromWire(direction),
    amount: amount,
    chargeAmount: chargeAmount,
    totalAmount: totalAmount,
    balanceBefore: balanceBefore,
    balanceAfter: balanceAfter,
    chargeLowerBound: chargeLowerBound,
    chargeUpperBound: chargeUpperBound,
    chargeHandling: chargeHandling,
    receiptImagePath: receiptImagePath,
    receiptOriginalName: receiptOriginalName,
    receiptMimeType: receiptMimeType,
    receiptUploadedAt: receiptUploadedAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(receiptUploadedAtMs!),
    ocrStatus: OcrStatus.fromWire(ocrStatus),
    ocrExtractedAmount: ocrExtractedAmount,
    ocrRawText: ocrRawText,
    ocrProcessedAt: ocrProcessedAtMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(ocrProcessedAtMs!),
    externalProvider: externalProvider,
    externalTransactionId: externalTransactionId,
    note: note,
    reference: reference,
    entryDate: entryDate,
    status: TransactionStatus.fromWire(status),
    sync: SyncMetadata(
      syncId: syncId,
      deviceId: deviceId,
      isDeleted: isDeleted,
      isDirty: isDirty,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAtMs),
    ),
  );
}

extension TxRecordCompanionMapper on TxRecord {
  TransactionsCompanion toCompanion() => TransactionsCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    walletProvider: Value(walletProvider.wire),
    direction: Value(direction.wire),
    amount: Value(amount),
    chargeAmount: Value(chargeAmount),
    totalAmount: Value(totalAmount),
    balanceBefore: Value(balanceBefore),
    balanceAfter: Value(balanceAfter),
    chargeLowerBound: Value(chargeLowerBound),
    chargeUpperBound: Value(chargeUpperBound),
    chargeHandling: Value(chargeHandling),
    receiptImagePath: Value(receiptImagePath),
    receiptOriginalName: Value(receiptOriginalName),
    receiptMimeType: Value(receiptMimeType),
    receiptUploadedAtMs: Value(receiptUploadedAt?.millisecondsSinceEpoch),
    ocrStatus: Value(ocrStatus.wire),
    ocrExtractedAmount: Value(ocrExtractedAmount),
    ocrRawText: Value(ocrRawText),
    ocrProcessedAtMs: Value(ocrProcessedAt?.millisecondsSinceEpoch),
    externalProvider: Value(externalProvider),
    externalTransactionId: Value(externalTransactionId),
    note: Value(note),
    reference: Value(reference),
    entryDate: Value(entryDate),
    status: Value(status.wire),
  );
}

TransactionsCompanion transactionCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  DateTime? parseDt(Object? v) =>
      v == null ? null : DateTime.parse(v as String);
  return TransactionsCompanion(
    id: Value(json['id'] as String),
    syncId: Value(json['syncId'] as String),
    deviceId: Value((json['deviceId'] as String?) ?? ''),
    isDeleted: Value((json['isDeleted'] as bool?) ?? false),
    isDirty: const Value(false),
    createdAtMs: Value(
      DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch,
    ),
    updatedAtMs: Value(
      DateTime.parse(json['updatedAt'] as String).millisecondsSinceEpoch,
    ),
    walletProvider: Value(json['walletProvider'] as String),
    direction: Value(json['direction'] as String),
    amount: Value(asDouble(json['amount'])),
    chargeAmount: Value(asDouble(json['chargeAmount'])),
    totalAmount: Value(asDouble(json['totalAmount'])),
    balanceBefore: Value(asDouble(json['balanceBefore'])),
    balanceAfter: Value(asDouble(json['balanceAfter'])),
    chargeLowerBound: Value(asDoubleOrNull(json['chargeLowerBound'])),
    chargeUpperBound: Value(asDoubleOrNull(json['chargeUpperBound'])),
    chargeHandling: Value((json['chargeHandling'] as String?) ?? 'addOnTop'),
    receiptImagePath: Value(json['receiptImagePath'] as String?),
    receiptOriginalName: Value(json['receiptOriginalName'] as String?),
    receiptMimeType: Value(json['receiptMimeType'] as String?),
    receiptUploadedAtMs: Value(
      parseDt(json['receiptUploadedAt'])?.millisecondsSinceEpoch,
    ),
    ocrStatus: Value((json['ocrStatus'] as String?) ?? 'PENDING'),
    ocrExtractedAmount: Value(asDoubleOrNull(json['ocrExtractedAmount'])),
    ocrRawText: Value(json['ocrRawText'] as String?),
    ocrProcessedAtMs: Value(
      parseDt(json['ocrProcessedAt'])?.millisecondsSinceEpoch,
    ),
    externalProvider: Value(json['externalProvider'] as String?),
    externalTransactionId: Value(json['externalTransactionId'] as String?),
    note: Value((json['note'] as String?) ?? ''),
    reference: Value((json['reference'] as String?) ?? ''),
    entryDate: Value(json['entryDate'] as String),
    status: Value((json['status'] as String?) ?? 'COMPLETED'),
  );
}

Map<String, dynamic> transactionToRemoteJson(TxRecord t) => {
  'id': t.id,
  'syncId': t.sync.syncId,
  'deviceId': t.sync.deviceId,
  'walletProvider': t.walletProvider.wire,
  'direction': t.direction.wire,
  'amount': t.amount,
  'chargeAmount': t.chargeAmount,
  'totalAmount': t.totalAmount,
  'balanceBefore': t.balanceBefore,
  'balanceAfter': t.balanceAfter,
  'chargeLowerBound': t.chargeLowerBound,
  'chargeUpperBound': t.chargeUpperBound,
  'chargeHandling': t.chargeHandling,
  'receiptImagePath': t.receiptImagePath,
  'receiptOriginalName': t.receiptOriginalName,
  'receiptMimeType': t.receiptMimeType,
  'receiptUploadedAt': t.receiptUploadedAt?.toUtc().toIso8601String(),
  'ocrStatus': t.ocrStatus.wire,
  'ocrExtractedAmount': t.ocrExtractedAmount,
  'ocrRawText': t.ocrRawText,
  'ocrProcessedAt': t.ocrProcessedAt?.toUtc().toIso8601String(),
  'externalProvider': t.externalProvider,
  'externalTransactionId': t.externalTransactionId,
  'note': t.note,
  'reference': t.reference,
  'entryDate': t.entryDate,
  'status': t.status.wire,
  'isDeleted': t.sync.isDeleted,
  'createdAt': t.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': t.sync.updatedAt.toUtc().toIso8601String(),
};
