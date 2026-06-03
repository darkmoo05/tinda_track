import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/party.dart';

extension PartyRowMapper on PartyRow {
  Party toDomain() => Party(
    id: id,
    name: name,
    accountNumber: accountNumber,
    entityId: entityId,
    description: description,
    joinDate: joinDate,
    isVerified: isVerified,
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

extension PartyCompanionMapper on Party {
  PartiesCompanion toCompanion() => PartiesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    accountNumber: Value(accountNumber),
    entityId: Value(entityId),
    description: Value(description),
    joinDate: Value(joinDate),
    isVerified: Value(isVerified),
  );
}

PartiesCompanion partyCompanionFromRemoteJson(Map<String, dynamic> json) {
  return PartiesCompanion(
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
    accountNumber: Value((json['accountNumber'] as String?) ?? ''),
    entityId: Value((json['entityId'] as String?) ?? ''),
    description: Value((json['description'] as String?) ?? ''),
    joinDate: Value(json['joinDate'] as String),
    isVerified: Value((json['isVerified'] as bool?) ?? false),
  );
}

Map<String, dynamic> partyToRemoteJson(Party p) => {
  'id': p.id,
  'syncId': p.sync.syncId,
  'deviceId': p.sync.deviceId,
  'name': p.name,
  'accountNumber': p.accountNumber,
  'entityId': p.entityId,
  'description': p.description,
  'joinDate': p.joinDate,
  'isVerified': p.isVerified,
  'isDeleted': p.sync.isDeleted,
  'createdAt': p.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': p.sync.updatedAt.toUtc().toIso8601String(),
};
