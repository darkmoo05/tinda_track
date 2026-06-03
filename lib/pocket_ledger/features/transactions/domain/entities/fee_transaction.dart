import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'fee_transaction.freezed.dart';
part 'fee_transaction.g.dart';

/// Service-fee income row linked to a ledger entry by sync_id.
/// Mirrors backend Prisma `FeeTransaction`.
@freezed
class FeeTransaction with _$FeeTransaction {
  const factory FeeTransaction({
    required String id,
    String? relatedTransactionSyncId,
    required double feeAmount,
    required String feeType,
    required String chargeDestination,
    required SyncMetadata sync,
  }) = _FeeTransaction;

  factory FeeTransaction.fromJson(Map<String, dynamic> json) =>
      _$FeeTransactionFromJson(json);
}
