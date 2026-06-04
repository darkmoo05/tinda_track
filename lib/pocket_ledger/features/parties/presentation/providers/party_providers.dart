import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/pocket_ledger/parties_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/party_repository_impl.dart';
import '../../domain/entities/party.dart';
import '../../domain/repositories/party_repository.dart';

final partiesDaoProvider = Provider<PartiesDao>(
  (ref) => PartiesDao(ref.watch(currentAppDatabaseProvider)),
);

final partyRepositoryProvider = Provider<PartyRepository>(
  (ref) => PartyRepositoryImpl(ref.watch(partiesDaoProvider)),
);

final partiesStreamProvider = StreamProvider.autoDispose<List<Party>>(
  (ref) => ref.watch(partyRepositoryProvider).watchAll(),
);

class PartiesNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Party> save(Party party) async {
    state = const AsyncLoading();
    final repo = ref.read(partyRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(party));
    state = result.whenData((_) => null);
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(partyRepositoryProvider).delete(id),
    );
  }
}

final partiesNotifierProvider =
    AsyncNotifierProvider.autoDispose<PartiesNotifier, void>(
      PartiesNotifier.new,
    );
