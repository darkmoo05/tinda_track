import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'transaction_type.freezed.dart';
part 'transaction_type.g.dart';

/// User-defined transaction label. Mirrors backend Prisma `TransactionType`.
@freezed
class TransactionType with _$TransactionType {
  const factory TransactionType({
    required String id,
    required String name,
    @Default(false) bool isOutflow,
    @Default('GCash') String walletAccount,
    required SyncMetadata sync,
  }) = _TransactionType;

  factory TransactionType.fromJson(Map<String, dynamic> json) =>
      _$TransactionTypeFromJson(json);
}
