import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/providers/database_providers.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return ref.watch(localTransactionRepositoryProvider);
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
    state = result.whenData((_) {});
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
