import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/database/daos/tinda_tracker/customers_dao.dart';
import '../../../../../core/di/database_providers.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';

final customersDaoProvider = Provider<CustomersDao>((ref) {
  return CustomersDao(ref.watch(currentAppDatabaseProvider));
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepositoryImpl(ref.watch(customersDaoProvider));
});

final customersStreamProvider = StreamProvider.autoDispose<List<Customer>>((
  ref,
) {
  return ref.watch(customerRepositoryProvider).watchAll();
});

final customerByIdProvider = FutureProvider.autoDispose
    .family<Customer?, String>(
      (ref, id) => ref.watch(customerRepositoryProvider).findById(id),
    );

class CustomersNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<Customer> save(Customer customer) async {
    state = const AsyncLoading();
    final repo = ref.read(customerRepositoryProvider);
    final result = await AsyncValue.guard(() => repo.save(customer));
    state = result.whenData((_) {});
    return result.requireValue;
  }

  Future<void> delete(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(customerRepositoryProvider).delete(id),
    );
  }
}

final customersNotifierProvider =
    AsyncNotifierProvider.autoDispose<CustomersNotifier, void>(
      CustomersNotifier.new,
    );
