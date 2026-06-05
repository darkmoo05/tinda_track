import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../../core/domain/sync_metadata.dart';

part 'product_serial_number.freezed.dart';
part 'product_serial_number.g.dart';

@freezed
class ProductSerialNumber with _$ProductSerialNumber {
  const factory ProductSerialNumber({
    required String id,
    required String productId,
    required String serialNumber,
    @Default('AVAILABLE') String status, // AVAILABLE, SOLD, WASTE, RETURNED
    required SyncMetadata sync,
  }) = _ProductSerialNumber;

  factory ProductSerialNumber.fromJson(Map<String, dynamic> json) =>
      _$ProductSerialNumberFromJson(json);
}
