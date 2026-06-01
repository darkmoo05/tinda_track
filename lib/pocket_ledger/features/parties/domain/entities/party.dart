import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'party.freezed.dart';
part 'party.g.dart';

/// Counterparty (bank, e-wallet, person) referenced by ledger entries.
/// Mirrors backend Prisma `Party`.
@freezed
class Party with _$Party {
  const factory Party({
    required String id,
    required String name,
    @Default('') String accountNumber,
    @Default('') String entityId,
    @Default('') String description,
    required String joinDate,
    @Default(false) bool isVerified,
    required SyncMetadata sync,
  }) = _Party;

  factory Party.fromJson(Map<String, dynamic> json) => _$PartyFromJson(json);
}
