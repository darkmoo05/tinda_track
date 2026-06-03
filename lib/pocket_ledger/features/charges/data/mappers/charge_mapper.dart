import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/charge.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

/// Bidirectional conversions between Drift rows, domain models and JSON.
///
/// The repository layer is the only place that knows about both shapes —
/// presentation only sees [Charge]; sync code only sees JSON.
extension ChargeRowMapper on ChargeRow {
  Charge toDomain() => Charge(
    id: id,
    lowerBound: lowerBound,
    upperBound: upperBound,
    chargeAmount: chargeAmount,
    transactionTypeKey: transactionTypeKey,
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

extension ChargeCompanionMapper on Charge {
  ChargesCompanion toCompanion() => ChargesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    lowerBound: Value(lowerBound),
    upperBound: Value(upperBound),
    chargeAmount: Value(chargeAmount),
    transactionTypeKey: Value(transactionTypeKey),
  );
}

/// Decodes a backend payload (camelCase JSON) into a Drift companion ready
/// for [ChargesDao.upsertFromRemote].
ChargesCompanion chargeCompanionFromRemoteJson(Map<String, dynamic> json) {
  return ChargesCompanion(
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
    lowerBound: Value(asDouble(json['lowerBound'])),
    upperBound: Value(asDouble(json['upperBound'])),
    chargeAmount: Value(asDouble(json['chargeAmount'])),
    transactionTypeKey: Value(
      (json['transactionTypeKey'] as String?) ?? 'gcash_cashin',
    ),
  );
}

/// Encodes a domain entity as the JSON the backend `/charges/push` expects.
Map<String, dynamic> chargeToRemoteJson(Charge charge) => {
  'id': charge.id,
  'syncId': charge.sync.syncId,
  'deviceId': charge.sync.deviceId,
  'lowerBound': charge.lowerBound,
  'upperBound': charge.upperBound,
  'chargeAmount': charge.chargeAmount,
  'transactionTypeKey': charge.transactionTypeKey,
  'isDeleted': charge.sync.isDeleted,
  'createdAt': charge.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': charge.sync.updatedAt.toUtc().toIso8601String(),
};
