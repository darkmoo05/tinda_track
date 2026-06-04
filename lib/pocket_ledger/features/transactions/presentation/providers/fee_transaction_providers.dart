import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/pocket_ledger/fee_transactions_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/fee_transaction_repository_impl.dart';
import '../../domain/entities/fee_transaction.dart';
import '../../domain/repositories/fee_transaction_repository.dart';

final feeTransactionsDaoProvider = Provider<FeeTransactionsDao>((ref) {
  return FeeTransactionsDao(ref.watch(currentAppDatabaseProvider));
});

final feeTransactionRepositoryProvider = Provider<FeeTransactionRepository>((
  ref,
) {
  return FeeTransactionRepositoryImpl(ref.watch(feeTransactionsDaoProvider));
});

final feeTransactionsStreamProvider = StreamProvider.autoDispose
    .family<List<FeeTransaction>, String?>((ref, relatedTransactionSyncId) {
      return ref
          .watch(feeTransactionRepositoryProvider)
          .watchAll(relatedTransactionSyncId: relatedTransactionSyncId);
    });

class FeeTransactionsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<FeeTransaction> save(FeeTransaction fee) async {
    state = const AsyncLoading();
    final repo = ref.read(feeTransactionRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(fee));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(feeTransactionRepositoryProvider).delete(id),
    );
  }
}

final feeTransactionsNotifierProvider =
    AsyncNotifierProvider.autoDispose<FeeTransactionsNotifier, void>(
      FeeTransactionsNotifier.new,
    );
