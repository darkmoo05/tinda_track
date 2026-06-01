import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/shelf_locations_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/shelf_location_repository_impl.dart';
import '../../domain/entities/shelf_location.dart';
import '../../domain/repositories/shelf_location_repository.dart';

final shelfLocationsDaoProvider = Provider<ShelfLocationsDao>((ref) {
  return ShelfLocationsDao(ref.watch(appDatabaseProvider));
});

final shelfLocationRepositoryProvider = Provider<ShelfLocationRepository>((
  ref,
) {
  return ShelfLocationRepositoryImpl(ref.watch(shelfLocationsDaoProvider));
});

final shelfLocationsStreamProvider =
    StreamProvider.autoDispose<List<ShelfLocation>>((ref) {
      return ref.watch(shelfLocationRepositoryProvider).watchAll();
    });

class ShelfLocationsNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<ShelfLocation> save(ShelfLocation location) async {
    state = const AsyncLoading();
    final repo = ref.read(shelfLocationRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(location));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(shelfLocationRepositoryProvider).delete(id),
    );
  }
}

final shelfLocationsNotifierProvider =
    AsyncNotifierProvider.autoDispose<ShelfLocationsNotifier, void>(
      ShelfLocationsNotifier.new,
    );
