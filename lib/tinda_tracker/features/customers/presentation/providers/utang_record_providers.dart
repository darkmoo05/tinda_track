import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/utang_records_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/utang_record_repository_impl.dart';
import '../../domain/entities/utang_record.dart';
import '../../domain/repositories/utang_record_repository.dart';

final utangRecordsDaoProvider = Provider<UtangRecordsDao>((ref) {
  return UtangRecordsDao(ref.watch(currentAppDatabaseProvider));
});

final utangRecordRepositoryProvider = Provider<UtangRecordRepository>((ref) {
  return UtangRecordRepositoryImpl(ref.watch(utangRecordsDaoProvider));
});

final utangRecordsStreamProvider =
    StreamProvider.autoDispose<List<UtangRecord>>(
      (ref) => ref.watch(utangRecordRepositoryProvider).watchAll(),
    );

final utangRecordsForCustomerProvider = StreamProvider.autoDispose
    .family<List<UtangRecord>, String>((ref, customerId) {
      return ref
          .watch(utangRecordRepositoryProvider)
          .watchForCustomer(customerId);
    });

class UtangRecordsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<UtangRecord> save(UtangRecord record) async {
    state = const AsyncLoading();
    final repo = ref.read(utangRecordRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(record));
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(utangRecordRepositoryProvider).delete(id),
    );
  }
}

final utangRecordsNotifierProvider =
    AsyncNotifierProvider.autoDispose<UtangRecordsNotifier, void>(
      UtangRecordsNotifier.new,
    );
