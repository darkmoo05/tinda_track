import 'package:drift/drift.dart';

import '../../../../../../core/database/app_database.dart';
import '../../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/transaction_type.dart';

extension TransactionTypeRowMapper on TransactionTypeRow {
  TransactionType toDomain() => TransactionType(
    id: id,
    name: name,
    isOutflow: isOutflow,
    walletAccount: walletAccount,
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

extension TransactionTypeCompanionMapper on TransactionType {
  TransactionTypesCompanion toCompanion() => TransactionTypesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    isOutflow: Value(isOutflow),
    walletAccount: Value(walletAccount),
  );
}

TransactionTypesCompanion transactionTypeCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return TransactionTypesCompanion(
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
    name: Value(json['name'] as String),
    isOutflow: Value((json['isOutflow'] as bool?) ?? false),
    walletAccount: Value((json['walletAccount'] as String?) ?? 'GCash'),
  );
}

Map<String, dynamic> transactionTypeToRemoteJson(TransactionType t) => {
  'id': t.id,
  'syncId': t.sync.syncId,
  'deviceId': t.sync.deviceId,
  'name': t.name,
  'isOutflow': t.isOutflow,
  'walletAccount': t.walletAccount,
  'isDeleted': t.sync.isDeleted,
  'createdAt': t.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': t.sync.updatedAt.toUtc().toIso8601String(),
};
