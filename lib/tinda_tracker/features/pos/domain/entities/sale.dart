import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';
import 'sale_item.dart';

part 'sale.freezed.dart';
part 'sale.g.dart';

/// POS sale aggregate. Mirrors Prisma `Sale` (with embedded line items).
@freezed
class Sale with _$Sale {
  const factory Sale({
    required String id,
    required String reference,
    @Default('') String note,
    required double subtotal,
    required double totalAmount,
    required double paidAmount,
    @Default(0) double changeAmount,
    required int totalItems,
    @Default(<SaleItem>[]) List<SaleItem> items,
    required SyncMetadata sync,
  }) = _Sale;

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
}
