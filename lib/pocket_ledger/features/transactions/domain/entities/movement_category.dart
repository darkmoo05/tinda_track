import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'movement_category.freezed.dart';
part 'movement_category.g.dart';

/// Owner-movement classification lookup. Mirrors backend Prisma
/// `MovementCategory`.
@freezed
class MovementCategory with _$MovementCategory {
  const factory MovementCategory({
    required String id,
    required String name,
    required SyncMetadata sync,
  }) = _MovementCategory;

  factory MovementCategory.fromJson(Map<String, dynamic> json) =>
      _$MovementCategoryFromJson(json);
}
