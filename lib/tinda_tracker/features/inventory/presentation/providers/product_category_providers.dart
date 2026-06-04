import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/product_categories_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/product_category_repository_impl.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_category_repository.dart';

final productCategoriesDaoProvider = Provider<ProductCategoriesDao>((ref) {
  return ProductCategoriesDao(ref.watch(currentAppDatabaseProvider));
});

final productCategoryRepositoryProvider = Provider<ProductCategoryRepository>((
  ref,
) {
  return ProductCategoryRepositoryImpl(ref.watch(productCategoriesDaoProvider));
});

final productCategoriesStreamProvider =
    StreamProvider.autoDispose<List<ProductCategory>>((ref) {
      return ref.watch(productCategoryRepositoryProvider).watchAll();
    });

class ProductCategoriesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ProductCategory> save(ProductCategory category) async {
    state = const AsyncLoading();
    final repo = ref.read(productCategoryRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(category));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productCategoryRepositoryProvider).delete(id),
    );
  }
}

final productCategoriesNotifierProvider =
    AsyncNotifierProvider.autoDispose<ProductCategoriesNotifier, void>(
      ProductCategoriesNotifier.new,
    );
