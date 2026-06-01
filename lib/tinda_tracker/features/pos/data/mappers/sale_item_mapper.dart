import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../domain/entities/sale_item.dart';

/// Sale items are not pushed to the server as standalone rows — they are
/// embedded inside the parent Sale's remote payload. Helpers here support
/// both the local repository and the sale mapper.
extension SaleItemRowMapper on SaleItemRow {
  SaleItem toDomain() => SaleItem(
    id: id,
    saleId: saleId,
    productId: productId,
    selectedUnit: selectedUnit,
    quantity: quantity,
    unitPrice: unitPrice,
    computedBaseQuantity: computedBaseQuantity,
    lineTotal: lineTotal,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  );
}

extension SaleItemCompanionMapper on SaleItem {
  SaleItemsCompanion toCompanion({bool isDirty = true}) => SaleItemsCompanion(
    id: Value(id),
    saleId: Value(saleId),
    productId: Value(productId),
    selectedUnit: Value(selectedUnit),
    quantity: Value(quantity),
    unitPrice: Value(unitPrice),
    computedBaseQuantity: Value(computedBaseQuantity),
    lineTotal: Value(lineTotal),
    createdAtMs: Value(createdAt.millisecondsSinceEpoch),
    isDirty: Value(isDirty),
  );
}

/// Encodes a sale item as part of the parent Sale's JSON.
Map<String, dynamic> saleItemToRemoteJson(SaleItem i) => {
  'id': i.id,
  'saleId': i.saleId,
  'productId': i.productId,
  'selectedUnit': i.selectedUnit,
  'quantity': i.quantity,
  'unitPrice': i.unitPrice,
  'computedBaseQuantity': i.computedBaseQuantity,
  'lineTotal': i.lineTotal,
  'createdAt': i.createdAt.toUtc().toIso8601String(),
};

/// Decodes a sale item embedded in a Sale remote payload.
SaleItemsCompanion saleItemCompanionFromRemoteJson(
  Map<String, dynamic> json, {
  required String saleId,
}) {
  return SaleItemsCompanion(
    id: Value(json['id'] as String),
    saleId: Value(saleId),
    productId: Value(json['productId'] as String),
    selectedUnit: Value(json['selectedUnit'] as String),
    quantity: Value((json['quantity'] as num).toDouble()),
    unitPrice: Value((json['unitPrice'] as num).toDouble()),
    computedBaseQuantity: Value(
      (json['computedBaseQuantity'] as num).toDouble(),
    ),
    lineTotal: Value((json['lineTotal'] as num).toDouble()),
    createdAtMs: Value(
      DateTime.parse(json['createdAt'] as String).millisecondsSinceEpoch,
    ),
    isDirty: const Value(false),
  );
}
