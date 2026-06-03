import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/utang_record.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension UtangRecordRowMapper on UtangRecordRow {
  UtangRecord toDomain() => UtangRecord(
    id: id,
    customerId: customerId,
    description: description,
    amount: amount,
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

extension UtangRecordCompanionMapper on UtangRecord {
  UtangRecordsCompanion toCompanion() => UtangRecordsCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    customerId: Value(customerId),
    description: Value(description),
    amount: Value(amount),
  );
}

UtangRecordsCompanion utangRecordCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return UtangRecordsCompanion(
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
    customerId: Value(json['customerId'] as String),
    description: Value((json['description'] as String?) ?? ''),
    amount: Value(asDouble(json['amount'])),
  );
}

Map<String, dynamic> utangRecordToRemoteJson(UtangRecord u) => {
  'id': u.id,
  'syncId': u.sync.syncId,
  'deviceId': u.sync.deviceId,
  'customerId': u.customerId,
  'description': u.description,
  'amount': u.amount,
  'isDeleted': u.sync.isDeleted,
  'createdAt': u.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': u.sync.updatedAt.toUtc().toIso8601String(),
};
