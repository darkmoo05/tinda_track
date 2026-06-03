import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_metadata.freezed.dart';
part 'sync_metadata.g.dart';

/// Sync-related fields embedded in every synchronised domain entity.
///
/// `syncId`/`deviceId`/`isDeleted` are mirrored to the backend.
/// `isDirty` is **local-only** (never sent on the wire — the server doesn't
/// know about it). `createdAt`/`updatedAt` use ms-since-epoch on the wire,
/// matching how Drift stores them — we model them as `DateTime` in domain.
@freezed
class SyncMetadata with _$SyncMetadata {
  const factory SyncMetadata({
    required String syncId,
    @Default('') String deviceId,
    @Default(false) bool isDeleted,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(false)
    bool isDirty,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SyncMetadata;

  factory SyncMetadata.fromJson(Map<String, dynamic> json) =>
      _$SyncMetadataFromJson(json);
}
