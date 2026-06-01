import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import 'sale_item_mapper.dart';

extension SaleRowMapper on SaleRow {
  /// Note: items are populated separately by the repository, since they live
  /// in another table. This returns a Sale with `items` left empty.
  Sale toDomain({List<SaleItem> items = const <SaleItem>[]}) => Sale(
    id: id,
    reference: reference,
    note: note,
    subtotal: subtotal,
    totalAmount: totalAmount,
    paidAmount: paidAmount,
    changeAmount: changeAmount,
    totalItems: totalItems,
    items: items,
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

extension SaleCompanionMapper on Sale {
  SalesCompanion toCompanion() => SalesCompanion(
    id: Value(id),
    syncId: Value(sync.syncId),
    deviceId: Value(sync.deviceId),
    isDeleted: Value(sync.isDeleted),
    isDirty: Value(sync.isDirty),
    createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
    updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
    reference: Value(reference),
    note: Value(note),
    subtotal: Value(subtotal),
    totalAmount: Value(totalAmount),
    paidAmount: Value(paidAmount),
    changeAmount: Value(changeAmount),
    totalItems: Value(totalItems),
  );
}

SalesCompanion saleCompanionFromRemoteJson(Map<String, dynamic> json) {
  return SalesCompanion(
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
    reference: Value(json['reference'] as String),
    note: Value((json['note'] as String?) ?? ''),
    subtotal: Value((json['subtotal'] as num).toDouble()),
    totalAmount: Value((json['totalAmount'] as num).toDouble()),
    paidAmount: Value((json['paidAmount'] as num).toDouble()),
    changeAmount: Value(((json['changeAmount'] as num?) ?? 0).toDouble()),
    totalItems: Value((json['totalItems'] as num).toInt()),
  );
}

/// Extracts embedded items from a Sale remote JSON. Returns an empty list if
/// the payload does not include them.
List<SaleItemsCompanion> saleItemCompanionsFromRemoteJson(
  Map<String, dynamic> json,
) {
  final raw = json['items'] as List<dynamic>?;
  if (raw == null || raw.isEmpty) return const <SaleItemsCompanion>[];
  return raw
      .cast<Map<String, dynamic>>()
      .map(
        (j) => saleItemCompanionFromRemoteJson(j, saleId: json['id'] as String),
      )
      .toList(growable: false);
}

Map<String, dynamic> saleToRemoteJson(Sale s) => {
  'id': s.id,
  'syncId': s.sync.syncId,
  'deviceId': s.sync.deviceId,
  'reference': s.reference,
  'note': s.note,
  'subtotal': s.subtotal,
  'totalAmount': s.totalAmount,
  'paidAmount': s.paidAmount,
  'changeAmount': s.changeAmount,
  'totalItems': s.totalItems,
  'items': s.items.map(saleItemToRemoteJson).toList(growable: false),
  'isDeleted': s.sync.isDeleted,
  'createdAt': s.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': s.sync.updatedAt.toUtc().toIso8601String(),
};
