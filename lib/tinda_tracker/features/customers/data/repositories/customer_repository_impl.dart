import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/tinda_tracker/customers_dao.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../mappers/customer_mapper.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final CustomersDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<Customer>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<Customer?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<Customer> save(Customer customer) async {
    final now = DateTime.now();
    final prepared = customer.copyWith(
      id: customer.id.isEmpty ? _uuid.v4() : customer.id,
      sync: customer.sync.copyWith(
        syncId: customer.sync.syncId.isEmpty
            ? _uuid.v4()
            : customer.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: customer.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : customer.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
