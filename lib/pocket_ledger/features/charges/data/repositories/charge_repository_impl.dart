import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/pocket_ledger/charges_dao.dart';
import '../../domain/entities/charge.dart';
import '../../domain/repositories/charge_repository.dart';
import '../mappers/charge_mapper.dart';

/// Concrete [ChargeRepository] backed by Drift via [ChargesDao].
class ChargeRepositoryImpl implements ChargeRepository {
  ChargeRepositoryImpl(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final ChargesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<Charge>> watchAll({String? transactionTypeKey}) {
    return _dao
        .watchAll(transactionTypeKey: transactionTypeKey)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<Charge?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<Charge> save(Charge charge) async {
    final now = DateTime.now();
    final prepared = charge.copyWith(
      id: charge.id.isEmpty ? _uuid.v4() : charge.id,
      sync: charge.sync.copyWith(
        syncId: charge.sync.syncId.isEmpty ? _uuid.v4() : charge.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: charge.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : charge.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
