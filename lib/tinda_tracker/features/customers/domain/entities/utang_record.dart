import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'utang_record.freezed.dart';
part 'utang_record.g.dart';

/// Credit ("utang") record attached to a customer. Mirrors Prisma
/// `UtangRecord`.
@freezed
class UtangRecord with _$UtangRecord {
  const factory UtangRecord({
    required String id,
    required String customerId,
    @Default('') String description,
    required double amount,
    required SyncMetadata sync,
  }) = _UtangRecord;

  factory UtangRecord.fromJson(Map<String, dynamic> json) =>
      _$UtangRecordFromJson(json);
}
