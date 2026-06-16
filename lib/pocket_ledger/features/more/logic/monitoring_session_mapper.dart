import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/sync/remote/json_coercion.dart';

/// Maps a database row [MonitoringSessionRow] to the JSON format expected by the NestJS server.
Map<String, dynamic> monitoringSessionToRemoteJson(MonitoringSessionRow row) => {
      'id': row.id,
      'syncId': row.syncId,
      'deviceId': row.deviceId,
      'name': row.name,
      'status': row.status,
      'startDateMs': row.startDateMs,
      'endDateMs': row.endDateMs,
      'startGcash': row.startGcash,
      'startMaya': row.startMaya,
      'startOnHand': row.startOnHand,
      'endGcash': row.endGcash,
      'endMaya': row.endMaya,
      'endOnHand': row.endOnHand,
      'isDeleted': row.isDeleted,
      'createdAt': DateTime.fromMillisecondsSinceEpoch(row.createdAtMs).toUtc().toIso8601String(),
      'updatedAt': DateTime.fromMillisecondsSinceEpoch(row.updatedAtMs).toUtc().toIso8601String(),
    };

/// Maps NestJS server JSON to a Drift [MonitoringSessionsCompanion] to be saved locally.
MonitoringSessionsCompanion monitoringSessionCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return MonitoringSessionsCompanion(
    id: Value(json['id'] as String),
    syncId: Value(json['syncId'] as String),
    deviceId: Value((json['deviceId'] as String?) ?? ''),
    name: Value(json['name'] as String),
    status: Value((json['status'] as String?) ?? 'ACTIVE'),
    startDateMs: Value(json['startDateMs'] as int),
    endDateMs: Value(json['endDateMs'] as int?),
    startGcash: Value(asDouble(json['startGcash'])),
    startMaya: Value(asDouble(json['startMaya'])),
    startOnHand: Value(asDouble(json['startOnHand'])),
    endGcash: Value(asDouble(json['endGcash'])),
    endMaya: Value(asDouble(json['endMaya'])),
    endOnHand: Value(asDouble(json['endOnHand'])),
    isDeleted: Value((json['isDeleted'] as bool?) ?? false),
    isDirty: const Value(false),
    createdAtMs: Value(
      DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch,
    ),
    updatedAtMs: Value(
      DateTime.parse(json['updatedAt'] as String).millisecondsSinceEpoch,
    ),
  );
}
