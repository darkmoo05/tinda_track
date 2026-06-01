import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'product_category.freezed.dart';
part 'product_category.g.dart';

/// User-managed product classification. Mirrors Prisma `ProductCategory`.
@freezed
class ProductCategory with _$ProductCategory {
  const factory ProductCategory({
    required String id,
    required String name,
    @Default('') String description,
    @Default('') String examples,
    @Default(false) bool isQuickAccess,
    required SyncMetadata sync,
  }) = _ProductCategory;

  factory ProductCategory.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryFromJson(json);
}
