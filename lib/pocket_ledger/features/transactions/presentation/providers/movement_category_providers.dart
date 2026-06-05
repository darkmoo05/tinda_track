import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/database/daos/pocket_ledger/movement_categories_dao.dart';
import '../../../../../../core/di/database_providers.dart';
import '../../data/repositories/movement_category_repository_impl.dart';
import '../../domain/entities/movement_category.dart';
import '../../domain/repositories/movement_category_repository.dart';

final movementCategoriesDaoProvider = Provider<MovementCategoriesDao>(
  (ref) => MovementCategoriesDao(ref.watch(currentAppDatabaseProvider)),
);

final movementCategoryRepositoryProvider = Provider<MovementCategoryRepository>(
  (ref) =>
      MovementCategoryRepositoryImpl(ref.watch(movementCategoriesDaoProvider)),
);

final movementCategoriesStreamProvider =
    StreamProvider.autoDispose<List<MovementCategory>>(
      (ref) => ref.watch(movementCategoryRepositoryProvider).watchAll(),
    );

class MovementCategoriesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<MovementCategory> save(MovementCategory category) async {
    state = const AsyncLoading();
    final repo = ref.read(movementCategoryRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(category));
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(movementCategoryRepositoryProvider).delete(id),
    );
  }
}

final movementCategoriesNotifierProvider =
    AsyncNotifierProvider.autoDispose<MovementCategoriesNotifier, void>(
      MovementCategoriesNotifier.new,
    );
