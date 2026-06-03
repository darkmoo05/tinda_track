import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/customer.dart';

extension CustomerRowMapper on CustomerRow {
  Customer toDomain() => Customer(
    id: id,
    name: name,
    phone: phone,
    address: address,
    notes: notes,
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

extension CustomerCompanionMapper on Customer {
  CustomersCompanion toCompanion() => CustomersCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    name: Value(name),
    phone: Value(phone),
    address: Value(address),
    notes: Value(notes),
  );
}

CustomersCompanion customerCompanionFromRemoteJson(Map<String, dynamic> json) {
  return CustomersCompanion(
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
    phone: Value((json['phone'] as String?) ?? ''),
    address: Value((json['address'] as String?) ?? ''),
    notes: Value((json['notes'] as String?) ?? ''),
  );
}

Map<String, dynamic> customerToRemoteJson(Customer c) => {
  'id': c.id,
  'syncId': c.sync.syncId,
  'deviceId': c.sync.deviceId,
  'name': c.name,
  'phone': c.phone,
  'address': c.address,
  'notes': c.notes,
  'isDeleted': c.sync.isDeleted,
  'createdAt': c.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': c.sync.updatedAt.toUtc().toIso8601String(),
};
