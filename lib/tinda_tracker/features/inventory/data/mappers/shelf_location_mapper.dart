import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/shelf_location.dart';

extension ShelfLocationRowMapper on ShelfLocationRow {
  ShelfLocation toDomain() => ShelfLocation(
    id: id,
    name: name,
    description: description,
    examples: examples,
    imageUrl: imageUrl,
    imageLocalPath: imageLocalPath,
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

extension ShelfLocationCompanionMapper on ShelfLocation {
  ShelfLocationsCompanion toCompanion() => ShelfLocationsCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    description: Value(description),
    examples: Value(examples),
    imageUrl: Value(imageUrl),
    imageLocalPath: Value(imageLocalPath),
  );
}

ShelfLocationsCompanion shelfLocationCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return ShelfLocationsCompanion(
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
    description: Value((json['description'] as String?) ?? ''),
    examples: Value((json['examples'] as String?) ?? ''),
    imageUrl: Value(json['imageUrl'] as String?),
    // imageLocalPath is intentionally absent — local-only column.
  );
}

Map<String, dynamic> shelfLocationToRemoteJson(ShelfLocation s) => {
  'id': s.id,
  'syncId': s.sync.syncId,
  'deviceId': s.sync.deviceId,
  'name': s.name,
  'description': s.description,
  'examples': s.examples,
  'imageUrl': s.imageUrl,
  'isDeleted': s.sync.isDeleted,
  'createdAt': s.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': s.sync.updatedAt.toUtc().toIso8601String(),
};
