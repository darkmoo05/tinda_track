import 'package:freezed_annotation/freezed_annotation.dart';

part 'sale_item.freezed.dart';
part 'sale_item.g.dart';

/// One line in a POS sale. Mirrors Prisma `SaleItem`.
///
/// Not separately synced — items travel with their parent Sale.
@freezed
class SaleItem with _$SaleItem {
  const factory SaleItem({
    required String id,
    required String saleId,
    required String productId,
    required String selectedUnit,
    required double quantity,
    required double unitPrice,
    required double computedBaseQuantity,
    required double lineTotal,
    required DateTime createdAt,
  }) = _SaleItem;

  factory SaleItem.fromJson(Map<String, dynamic> json) =>
      _$SaleItemFromJson(json);
}
