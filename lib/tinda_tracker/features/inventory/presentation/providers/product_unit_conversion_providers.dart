import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/product_unit_conversions_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/product_unit_conversion_repository_impl.dart';
import '../../domain/entities/product_unit_conversion.dart';
import '../../domain/repositories/product_unit_conversion_repository.dart';

final productUnitConversionsDaoProvider = Provider<ProductUnitConversionsDao>((
  ref,
) {
  return ProductUnitConversionsDao(ref.watch(appDatabaseProvider));
});

final productUnitConversionRepositoryProvider =
    Provider<ProductUnitConversionRepository>((ref) {
      return ProductUnitConversionRepositoryImpl(
        ref.watch(productUnitConversionsDaoProvider),
      );
    });

final productUnitConversionsStreamProvider = StreamProvider.autoDispose
    .family<List<ProductUnitConversion>, String>((ref, productId) {
      return ref
          .watch(productUnitConversionRepositoryProvider)
          .watchForProduct(productId);
    });

class ProductUnitConversionsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ProductUnitConversion> save(ProductUnitConversion conversion) async {
    state = const AsyncLoading();
    final repo = ref.read(productUnitConversionRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(conversion));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productUnitConversionRepositoryProvider).delete(id),
    );
  }
}

final productUnitConversionsNotifierProvider =
    AsyncNotifierProvider.autoDispose<ProductUnitConversionsNotifier, void>(
      ProductUnitConversionsNotifier.new,
    );
