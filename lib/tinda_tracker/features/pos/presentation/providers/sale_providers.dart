import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/sale_items_dao.dart';
import '../../../../../core/database/daos/tinda_tracker/sales_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/sale_repository_impl.dart';
import '../../domain/entities/sale.dart';
import '../../domain/repositories/sale_repository.dart';

final salesDaoProvider = Provider<SalesDao>((ref) {
  return SalesDao(ref.watch(appDatabaseProvider));
});

final saleItemsDaoProvider = Provider<SaleItemsDao>((ref) {
  return SaleItemsDao(ref.watch(appDatabaseProvider));
});

final saleRepositoryProvider = Provider<SaleRepository>((ref) {
  return SaleRepositoryImpl(
    ref.watch(appDatabaseProvider),
    ref.watch(salesDaoProvider),
    ref.watch(saleItemsDaoProvider),
  );
});

final salesStreamProvider = StreamProvider.autoDispose.family<List<Sale>, int?>(
  (ref, limit) {
    return ref.watch(saleRepositoryProvider).watchAll(limit: limit);
  },
);

final saleByIdProvider = FutureProvider.autoDispose.family<Sale?, String>(
  (ref, id) => ref.watch(saleRepositoryProvider).findById(id),
);

class SalesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Sale> save(Sale sale) async {
    state = const AsyncLoading();
    final repo = ref.read(saleRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(sale));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(saleRepositoryProvider).delete(id),
    );
  }
}

final salesNotifierProvider =
    AsyncNotifierProvider.autoDispose<SalesNotifier, void>(SalesNotifier.new);
