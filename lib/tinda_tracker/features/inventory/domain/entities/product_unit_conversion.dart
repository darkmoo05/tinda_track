import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'product_unit_conversion.freezed.dart';
part 'product_unit_conversion.g.dart';

/// Alternate unit definition for a product. Mirrors Prisma
/// `ProductUnitConversion`. Decimal(12,2) on Postgres → double locally;
/// the repository rounds to 2dp on write.
@freezed
class ProductUnitConversion with _$ProductUnitConversion {
  const factory ProductUnitConversion({
    required String id,
    required String productId,
    required String unitName,
    required double conversionFactor,
    required double costPrice,
    required double sellingPrice,
    required SyncMetadata sync,
  }) = _ProductUnitConversion;

  factory ProductUnitConversion.fromJson(Map<String, dynamic> json) =>
      _$ProductUnitConversionFromJson(json);
}
