import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/product_serial_number.dart';

extension ProductSerialNumberRowMapper on ProductSerialNumberRow {
  ProductSerialNumber toDomain() => ProductSerialNumber(
    id: id,
    productId: productId,
    serialNumber: serialNumber,
    status: status,
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

extension ProductSerialNumberCompanionMapper on ProductSerialNumber {
  ProductSerialNumbersCompanion toCompanion() =>
      ProductSerialNumbersCompanion(
        id: Value(id),
        syncId: Value(sync.syncId),
        deviceId: Value(sync.deviceId),
        isDeleted: Value(sync.isDeleted),
        isDirty: Value(sync.isDirty),
        createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
        updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
        productId: Value(productId),
        serialNumber: Value(serialNumber),
        status: Value(status),
      );
}

ProductSerialNumbersCompanion productSerialNumberCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return ProductSerialNumbersCompanion(
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
    productId: Value(json['productId'] as String),
    serialNumber: Value(json['serialNumber'] as String),
    status: Value((json['status'] as String?) ?? 'AVAILABLE'),
  );
}

Map<String, dynamic> productSerialNumberToRemoteJson(
  ProductSerialNumber sn,
) => {
  'id': sn.id,
  'syncId': sn.sync.syncId,
  'deviceId': sn.sync.deviceId,
  'productId': sn.productId,
  'serialNumber': sn.serialNumber,
  'status': sn.status,
  'isDeleted': sn.sync.isDeleted,
  'createdAt': sn.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': sn.sync.updatedAt.toUtc().toIso8601String(),
};
