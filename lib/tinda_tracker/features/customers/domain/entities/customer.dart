import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/domain/sync_metadata.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

/// Sari-sari customer profile. Mirrors Prisma `Customer`.
@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String name,
    @Default('') String phone,
    @Default('') String address,
    @Default('') String notes,
    required SyncMetadata sync,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}
