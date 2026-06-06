import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/products_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

final productsDaoProvider = Provider<ProductsDao>((ref) {
  return ProductsDao(ref.watch(currentAppDatabaseProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(productsDaoProvider));
});

/// Filter for [productsStreamProvider]. `categoryId` is optional, `activeOnly`
/// defaults to false.
class ProductsFilter {
  const ProductsFilter({this.categoryId, this.activeOnly = false});
  final String? categoryId;
  final bool activeOnly;

  @override
  bool operator ==(Object other) =>
      other is ProductsFilter &&
      other.categoryId == categoryId &&
      other.activeOnly == activeOnly;

  @override
  int get hashCode => Object.hash(categoryId, activeOnly);
}

final productsStreamProvider = StreamProvider.autoDispose
    .family<List<Product>, ProductsFilter>((ref, filter) {
      return ref
          .watch(productRepositoryProvider)
          .watchAll(
            categoryId: filter.categoryId,
            activeOnly: filter.activeOnly,
          );
    });

final productByIdProvider = FutureProvider.autoDispose.family<Product?, String>(
  (ref, id) => ref.watch(productRepositoryProvider).findById(id),
);

class ProductsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Product> save(Product product) async {
    state = const AsyncLoading();
    final repo = ref.read(productRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(product));
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).delete(id),
    );
  }

  Future<double> adjustStock(String productId, double delta) async {
    return ref.read(productRepositoryProvider).adjustStock(productId, delta);
  }
}

final productsNotifierProvider =
    AsyncNotifierProvider.autoDispose<ProductsNotifier, void>(
      ProductsNotifier.new,
    );
