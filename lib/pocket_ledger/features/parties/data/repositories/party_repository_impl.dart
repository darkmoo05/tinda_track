import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/pocket_ledger/parties_dao.dart';
import '../../domain/entities/party.dart';
import '../../domain/repositories/party_repository.dart';
import '../mappers/party_mapper.dart';

class PartyRepositoryImpl implements PartyRepository {
  PartyRepositoryImpl(this._dao, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final PartiesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<Party>> watchAll() => _dao.watchAll().map(
    (rows) => rows.map((r) => r.toDomain()).toList(growable: false),
  );

  @override
  Future<Party?> findById(String id) async =>
      (await _dao.findById(id))?.toDomain();

  @override
  Future<Party> save(Party party) async {
    final now = DateTime.now();
    final prepared = party.copyWith(
      id: party.id.isEmpty ? _uuid.v4() : party.id,
      sync: party.sync.copyWith(
        syncId: party.sync.syncId.isEmpty ? _uuid.v4() : party.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: party.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : party.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
