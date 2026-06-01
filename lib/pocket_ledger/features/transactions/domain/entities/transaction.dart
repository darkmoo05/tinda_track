import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/enums.dart';
import '../../../../../core/domain/sync_metadata.dart';

part 'transaction.freezed.dart';
part 'transaction.g.dart';

// Enum JSON converters — keep enum values lower-camel locally but emit/accept
// the uppercase wire form (GCASH / CASH_IN / PENDING …) over the network.

class _WalletProviderConverter
    implements JsonConverter<WalletProvider, String> {
  const _WalletProviderConverter();
  @override
  WalletProvider fromJson(String json) => WalletProvider.fromWire(json);
  @override
  String toJson(WalletProvider object) => object.wire;
}

class _TransactionDirectionConverter
    implements JsonConverter<TransactionDirection, String> {
  const _TransactionDirectionConverter();
  @override
  TransactionDirection fromJson(String json) =>
      TransactionDirection.fromWire(json);
  @override
  String toJson(TransactionDirection object) => object.wire;
}

class _OcrStatusConverter implements JsonConverter<OcrStatus, String> {
  const _OcrStatusConverter();
  @override
  OcrStatus fromJson(String json) => OcrStatus.fromWire(json);
  @override
  String toJson(OcrStatus object) => object.wire;
}

class _TransactionStatusConverter
    implements JsonConverter<TransactionStatus, String> {
  const _TransactionStatusConverter();
  @override
  TransactionStatus fromJson(String json) => TransactionStatus.fromWire(json);
  @override
  String toJson(TransactionStatus object) => object.wire;
}

/// Wallet transaction parent record. Mirrors backend Prisma `Transaction`.
@freezed
class TxRecord with _$TxRecord {
  const factory TxRecord({
    required String id,
    @_WalletProviderConverter() required WalletProvider walletProvider,
    @_TransactionDirectionConverter() required TransactionDirection direction,
    required double amount,
    @Default(0) double chargeAmount,
    required double totalAmount,
    required double balanceBefore,
    required double balanceAfter,
    double? chargeLowerBound,
    double? chargeUpperBound,
    @Default('addOnTop') String chargeHandling,
    String? receiptImagePath,
    String? receiptOriginalName,
    String? receiptMimeType,
    DateTime? receiptUploadedAt,
    @_OcrStatusConverter() @Default(OcrStatus.pending) OcrStatus ocrStatus,
    double? ocrExtractedAmount,
    String? ocrRawText,
    DateTime? ocrProcessedAt,
    String? externalProvider,
    String? externalTransactionId,
    @Default('') String note,
    @Default('') String reference,
    required String entryDate,
    @_TransactionStatusConverter()
    @Default(TransactionStatus.completed)
    TransactionStatus status,
    required SyncMetadata sync,
  }) = _TxRecord;

  factory TxRecord.fromJson(Map<String, dynamic> json) =>
      _$TxRecordFromJson(json);
}
