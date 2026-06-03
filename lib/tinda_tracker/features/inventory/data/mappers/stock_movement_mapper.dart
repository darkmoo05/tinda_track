import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../../core/domain/enums.dart';
import '../../domain/entities/stock_movement.dart';

/// Stock movements are not synced to the server as standalone rows, so this
/// mapper only converts between Drift and the domain model.
extension StockMovementRowMapper on StockMovementRow {
  StockMovement toDomain() => StockMovement(
    id: id,
    productId: productId,
    movementType: StockMovementType.fromWire(movementType),
    quantity: quantity,
    previousQuantity: previousQuantity,
    newQuantity: newQuantity,
    note: note,
    reference: reference,
    expirationDate: expirationDateMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(expirationDateMs!),
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    isDirty: isDirty,
  );
}

extension StockMovementCompanionMapper on StockMovement {
  StockMovementsCompanion toCompanion() => StockMovementsCompanion(
    id: Value(id),
    productId: Value(productId),
    movementType: Value(movementType.wire),
    quantity: Value(quantity),
    previousQuantity: Value(previousQuantity),
    newQuantity: Value(newQuantity),
    note: Value(note),
    reference: Value(reference),
    expirationDateMs: Value(expirationDate?.millisecondsSinceEpoch),
    createdAtMs: Value(createdAt.millisecondsSinceEpoch),
    isDirty: Value(isDirty),
  );
}
