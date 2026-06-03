import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Inventory product. Mirrors Prisma `Product`.
///
/// `imageLocalPath` is a local-only column kept out of JSON.
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required String sku,
    @Default('') String description,
    @Default('General') String category,
    @Default('pcs') String baseUnit,
    @Default(0) double costPrice,
    required double sellingPrice,
    @Default(0) double stockInBaseUnit,
    @Default(0) int reorderPoint,
    @Default(true) bool isActive,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    @Default('Counter') String? shelfLocation,
    DateTime? expirationDate,
    String? categoryId,
    String? shelfLocationId,
    required SyncMetadata sync,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
