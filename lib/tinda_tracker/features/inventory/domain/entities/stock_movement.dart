import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/enums.dart';

part 'stock_movement.freezed.dart';
part 'stock_movement.g.dart';

class _StockMovementTypeConverter
    implements JsonConverter<StockMovementType, String> {
  const _StockMovementTypeConverter();
  @override
  StockMovementType fromJson(String json) => StockMovementType.fromWire(json);
  @override
  String toJson(StockMovementType object) => object.wire;
}

/// Stock movement audit row. Mirrors Prisma `StockMovement`.
///
/// Not a synced entity on the backend (no syncId column there) — the local
/// layer tracks `isDirty` only for retry semantics.
@freezed
class StockMovement with _$StockMovement {
  const factory StockMovement({
    required String id,
    required String productId,
    @_StockMovementTypeConverter() required StockMovementType movementType,
    required double quantity,
    required double previousQuantity,
    required double newQuantity,
    @Default('') String note,
    @Default('') String reference,
    DateTime? expirationDate,
    required DateTime createdAt,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isDirty,
  }) = _StockMovement;

  factory StockMovement.fromJson(Map<String, dynamic> json) =>
      _$StockMovementFromJson(json);
}
