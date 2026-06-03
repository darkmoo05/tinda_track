import 'package:drift/drift.dart';

import '../../../../../../core/database/app_database.dart';
import '../../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/movement_category.dart';

extension MovementCategoryRowMapper on MovementCategoryRow {
  MovementCategory toDomain() => MovementCategory(
    id: id,
    name: name,
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

extension MovementCategoryCompanionMapper on MovementCategory {
  MovementCategoriesCompanion toCompanion() => MovementCategoriesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
  );
}

MovementCategoriesCompanion movementCategoryCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return MovementCategoriesCompanion(
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
  );
}

Map<String, dynamic> movementCategoryToRemoteJson(MovementCategory c) => {
  'id': c.id,
  'syncId': c.sync.syncId,
  'deviceId': c.sync.deviceId,
  'name': c.name,
  'isDeleted': c.sync.isDeleted,
  'createdAt': c.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': c.sync.updatedAt.toUtc().toIso8601String(),
};
