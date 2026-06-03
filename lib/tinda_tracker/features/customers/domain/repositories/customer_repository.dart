import '../entities/customer.dart';

abstract class CustomerRepository {
  Stream<List<Customer>> watchAll();
  Future<Customer?> findById(String id);
  Future<Customer> save(Customer customer);
  Future<void> delete(String id);
}
