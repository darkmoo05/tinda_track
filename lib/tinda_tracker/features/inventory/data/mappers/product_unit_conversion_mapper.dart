import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/sync_metadata.dart';
import '../../domain/entities/product_unit_conversion.dart';
import '../../../../../core/sync/remote/json_coercion.dart';

extension ProductUnitConversionRowMapper on ProductUnitConversionRow {
  ProductUnitConversion toDomain() => ProductUnitConversion(
    id: id,
    productId: productId,
    unitName: unitName,
    conversionFactor: conversionFactor,
    costPrice: costPrice,
    sellingPrice: sellingPrice,
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

extension ProductUnitConversionCompanionMapper on ProductUnitConversion {
  ProductUnitConversionsCompanion toCompanion() =>
      ProductUnitConversionsCompanion(
        id: Value(id),
        syncId: Value(sync.syncId),
        deviceId: Value(sync.deviceId),
        isDeleted: Value(sync.isDeleted),
        isDirty: Value(sync.isDirty),
        createdAtMs: Value(sync.createdAt.millisecondsSinceEpoch),
        updatedAtMs: Value(sync.updatedAt.millisecondsSinceEpoch),
        productId: Value(productId),
        unitName: Value(unitName),
        conversionFactor: Value(conversionFactor),
        costPrice: Value(costPrice),
        sellingPrice: Value(sellingPrice),
      );
}

ProductUnitConversionsCompanion productUnitConversionCompanionFromRemoteJson(
  Map<String, dynamic> json,
) {
  return ProductUnitConversionsCompanion(
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
    unitName: Value(json['unitName'] as String),
    conversionFactor: Value(asDouble(json['conversionFactor'])),
    costPrice: Value(asDouble(json['costPrice'])),
    sellingPrice: Value(asDouble(json['sellingPrice'])),
  );
}

Map<String, dynamic> productUnitConversionToRemoteJson(
  ProductUnitConversion c,
) => {
  'id': c.id,
  'syncId': c.sync.syncId,
  'deviceId': c.sync.deviceId,
  'productId': c.productId,
  'unitName': c.unitName,
  'conversionFactor': c.conversionFactor,
  'costPrice': c.costPrice,
  'sellingPrice': c.sellingPrice,
  'isDeleted': c.sync.isDeleted,
  'createdAt': c.sync.createdAt.toUtc().toIso8601String(),
  'updatedAt': c.sync.updatedAt.toUtc().toIso8601String(),
};
