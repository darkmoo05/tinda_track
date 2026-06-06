import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/stock_movements_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/stock_movement_repository_impl.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/repositories/stock_movement_repository.dart';

final stockMovementsDaoProvider = Provider<StockMovementsDao>((ref) {
  return StockMovementsDao(ref.watch(currentAppDatabaseProvider));
});

final stockMovementRepositoryProvider = Provider<StockMovementRepository>((
  ref,
) {
  return StockMovementRepositoryImpl(ref.watch(stockMovementsDaoProvider));
});

final stockMovementsForProductStreamProvider = StreamProvider.autoDispose
    .family<List<StockMovement>, String>((ref, productId) {
      return ref
          .watch(stockMovementRepositoryProvider)
          .watchForProduct(productId);
    });

final recentStockMovementsProvider = FutureProvider.autoDispose
    .family<List<StockMovement>, int>((ref, limit) {
      return ref.watch(stockMovementRepositoryProvider).recent(limit: limit);
    });

class StockMovementsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<StockMovement> record(StockMovement movement) async {
    state = const AsyncLoading();
    final repo = ref.read(stockMovementRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.record(movement));
    state = result.whenData((_) {});
    return result.requireValue;
  }
}

final stockMovementsNotifierProvider =
    AsyncNotifierProvider.autoDispose<StockMovementsNotifier, void>(
      StockMovementsNotifier.new,
    );
