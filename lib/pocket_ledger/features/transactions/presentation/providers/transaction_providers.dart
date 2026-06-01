import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/pocket_ledger/transactions_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return TransactionsDao(ref.watch(appDatabaseProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(transactionsDaoProvider));
});

final transactionsStreamProvider = StreamProvider.autoDispose
    .family<List<TxRecord>, String?>((ref, walletProvider) {
      return ref
          .watch(transactionRepositoryProvider)
          .watchAll(walletProvider: walletProvider);
    });

class TransactionsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<TxRecord> save(TxRecord tx) async {
    state = const AsyncLoading();
    final repo = ref.read(transactionRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(tx));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionRepositoryProvider).delete(id),
    );
  }
}

final transactionsNotifierProvider =
    AsyncNotifierProvider.autoDispose<TransactionsNotifier, void>(
      TransactionsNotifier.new,
    );
