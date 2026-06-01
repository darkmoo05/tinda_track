import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/fee_transaction.dart';

extension FeeTransactionRowMapper on FeeTransactionRow {
  FeeTransaction toDomain() => FeeTransaction(
    id: id,
    relatedTransactionSyncId: relatedTransactionSyncId,
    feeAmount: feeAmount,
    feeType: feeType,
    chargeDestination: chargeDestination,
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

extension FeeTransactionCompanionMapper on FeeTransaction {
  FeeTransactionsCompanion toCompanion() => FeeTransactionsCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    relatedTransactionSyncId: Value(relatedTransactionSyncId),
    feeAmount: Value(feeAmount),
    feeType: Value(feeType),
    chargeDestination: Value(chargeDestination),
  );
}

FeeTransactionsCompanion feeTransactionCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return FeeTransactionsCompanion(
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
    relatedTransactionSyncId: Value(
      json['relatedTransactionSyncId'] as String?,
    ),
    feeAmount: Value((json['feeAmount'] as num).toDouble()),
    feeType: Value(json['feeType'] as String),
    chargeDestination: Value(json['chargeDestination'] as String),
  );
}

Map<String, dynamic> feeTransactionToRemoteJson(FeeTransaction f) => {
  'id': f.id,
  'syncId': f.sync.syncId,
  'deviceId': f.sync.deviceId,
  'relatedTransactionSyncId': f.relatedTransactionSyncId,
  'feeAmount': f.feeAmount,
  'feeType': f.feeType,
  'chargeDestination': f.chargeDestination,
  'isDeleted': f.sync.isDeleted,
  'createdAt': f.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': f.sync.updatedAt.toUtc().toIso8601String(),
};
