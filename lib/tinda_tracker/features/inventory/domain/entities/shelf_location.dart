import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'shelf_location.freezed.dart';
part 'shelf_location.g.dart';

/// Store zone / placement lookup. Mirrors Prisma `ShelfLocation`.
///
/// `imageLocalPath` is local-only — never serialised.
@freezed
class ShelfLocation with _$ShelfLocation {
  const factory ShelfLocation({
    required String id,
    required String name,
    @Default('') String description,
    @Default('') String examples,
    String? imageUrl,
    @JsonKey(includeFromJson: false, includeToJson: false)
    String? imageLocalPath,
    required SyncMetadata sync,
  }) = _ShelfLocation;

  factory ShelfLocation.fromJson(Map<String, dynamic> json) =>
      _$ShelfLocationFromJson(json);
}
