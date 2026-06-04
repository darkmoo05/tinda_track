import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/pocket_ledger/charges_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/charge_repository_impl.dart';
import '../../domain/entities/charge.dart';
import '../../domain/repositories/charge_repository.dart';

/// DAO and repository providers — singleton-per-container, no rebuilds.
final chargesDaoProvider = Provider<ChargesDao>((ref) {
  return ChargesDao(ref.watch(currentAppDatabaseProvider));
});

final chargeRepositoryProvider = Provider<ChargeRepository>((ref) {
  return ChargeRepositoryImpl(ref.watch(chargesDaoProvider));
});

/// Reactive list of all charges (optionally filtered by transaction-type key).
final chargesStreamProvider = StreamProvider.autoDispose
    .family<List<Charge>, String?>((ref, transactionTypeKey) {
      return ref
          .watch(chargeRepositoryProvider)
          .watchAll(transactionTypeKey: transactionTypeKey);
    });

/// `AsyncNotifier` for mutations. The UI calls [save] / [delete]; the list
/// view rebuilds automatically via [chargesStreamProvider] thanks to Drift's
/// built-in change streams.
class ChargesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Charge> save(Charge charge) async {
    state = const AsyncLoading();
    final repo = ref.read(chargeRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(charge));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(chargeRepositoryProvider).delete(id),
    );
  }
}

final chargesNotifierProvider =
    AsyncNotifierProvider.autoDispose<ChargesNotifier, void>(
      ChargesNotifier.new,
    );
