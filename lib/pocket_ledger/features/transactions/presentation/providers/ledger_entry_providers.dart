import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/pocket_ledger/ledger_entries_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/ledger_entry_repository_impl.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/ledger_entry_repository.dart';

final ledgerEntriesDaoProvider = Provider<LedgerEntriesDao>((ref) {
  return LedgerEntriesDao(ref.watch(currentAppDatabaseProvider));
});

final ledgerEntryRepositoryProvider = Provider<LedgerEntryRepository>((ref) {
  return LedgerEntryRepositoryImpl(ref.watch(ledgerEntriesDaoProvider));
});

final ledgerEntriesStreamProvider = StreamProvider.autoDispose
    .family<List<LedgerEntry>, String?>((ref, transactionId) {
      return ref
          .watch(ledgerEntryRepositoryProvider)
          .watchAll(transactionId: transactionId);
    });

class LedgerEntriesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<LedgerEntry> save(LedgerEntry entry) async {
    state = const AsyncLoading();
    final repo = ref.read(ledgerEntryRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(entry));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(ledgerEntryRepositoryProvider).delete(id),
    );
  }
}

final ledgerEntriesNotifierProvider =
    AsyncNotifierProvider.autoDispose<LedgerEntriesNotifier, void>(
      LedgerEntriesNotifier.new,
    );
