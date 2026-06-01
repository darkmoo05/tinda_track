import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/database/daos/pocket_ledger/transaction_types_dao.dart';
import '../../../../../../core/di/database_providers.dart';
import '../../data/repositories/transaction_type_repository_impl.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_type_repository.dart';

final transactionTypesDaoProvider = Provider<TransactionTypesDao>(
  (ref) => TransactionTypesDao(ref.watch(appDatabaseProvider)),
);

final transactionTypeRepositoryProvider = Provider<TransactionTypeRepository>(
  (ref) =>
      TransactionTypeRepositoryImpl(ref.watch(transactionTypesDaoProvider)),
);

final transactionTypesStreamProvider =
    StreamProvider.autoDispose<List<TransactionType>>(
      (ref) => ref.watch(transactionTypeRepositoryProvider).watchAll(),
    );

class TransactionTypesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<TransactionType> save(TransactionType type) async {
    state = const AsyncLoading();
    final repo = ref.read(transactionTypeRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(type));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(transactionTypeRepositoryProvider).delete(id),
    );
  }
}

final transactionTypesNotifierProvider =
    AsyncNotifierProvider.autoDispose<TransactionTypesNotifier, void>(
      TransactionTypesNotifier.new,
    );
