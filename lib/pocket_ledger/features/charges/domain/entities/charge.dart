import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'charge.freezed.dart';
part 'charge.g.dart';

/// Tiered service-charge rule. Mirrors backend Prisma `Charge`.
@freezed
class Charge with _$Charge {
  const factory Charge({
    required String id,
    required double lowerBound,
    required double upperBound,
    required double chargeAmount,
    @Default('gcash_cashin') String transactionTypeKey,
    required SyncMetadata sync,
  }) = _Charge;

  factory Charge.fromJson(Map<String, dynamic> json) => _$ChargeFromJson(json);
}
