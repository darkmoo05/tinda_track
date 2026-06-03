import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'ledger_entry.freezed.dart';
part 'ledger_entry.g.dart';

/// Append-only ledger row. Mirrors backend Prisma `LedgerEntry`.
@freezed
class LedgerEntry with _$LedgerEntry {
  const factory LedgerEntry({
    required String id,
    String? transactionId,
    required String entryType,
    @Default('') String title,
    @Default('') String note,
    @Default('') String reference,
    required double amount,
    @Default(0) double walletDelta,
    @Default(0) double mayaWalletDelta,
    @Default(0) double onHandDelta,
    @Default(0) double recordedFlow,
    @Default('') String tag,
    @Default('') String iconKey,
    @Default('') String walletAccount,
    @Default('Business') String ownerScope,
    String? ownerMovementType,
    String? ownerCategory,
    String? ownerPartyName,
    String? ownerPartyAccount,
    required String entryDate,
    required SyncMetadata sync,
  }) = _LedgerEntry;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$LedgerEntryFromJson(json);
}
