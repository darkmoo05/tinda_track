import 'package:uuid/uuid.dart';

import '../../../../../core/database/daos/pocket_ledger/ledger_entries_dao.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/repositories/ledger_entry_repository.dart';
import '../mappers/ledger_entry_mapper.dart';

class LedgerEntryRepositoryImpl implements LedgerEntryRepository {
  LedgerEntryRepositoryImpl(this._dao, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final LedgerEntriesDao _dao;
  final Uuid _uuid;

  @override
  Stream<List<LedgerEntry>> watchAll({String? transactionId}) {
    return _dao
        .watchAll(transactionId: transactionId)
        .map((rows) => rows.map((r) => r.toDomain()).toList(growable: false));
  }

  @override
  Future<LedgerEntry?> findById(String id) async {
    final row = await _dao.findById(id);
    return row?.toDomain();
  }

  @override
  Future<LedgerEntry> save(LedgerEntry entry) async {
    final now = DateTime.now();
    final prepared = entry.copyWith(
      id: entry.id.isEmpty ? _uuid.v4() : entry.id,
      sync: entry.sync.copyWith(
        syncId: entry.sync.syncId.isEmpty ? _uuid.v4() : entry.sync.syncId,
        isDirty: true,
        updatedAt: now,
        createdAt: entry.sync.createdAt.millisecondsSinceEpoch == 0
            ? now
            : entry.sync.createdAt,
      ),
    );
    await _dao.upsertLocal(prepared.toCompanion());
    return prepared;
  }

  @override
  Future<void> delete(String id) => _dao.softDelete(id);
}
