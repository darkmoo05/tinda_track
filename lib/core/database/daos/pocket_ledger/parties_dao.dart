import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'parties_dao.g.dart';

@DriftAccessor(tables: [Parties])
class PartiesDao extends DatabaseAccessor<AppDatabase> with _$PartiesDaoMixin {
  PartiesDao(super.db);

  Stream<List<PartyRow>> watchAll() {
    return (select(parties)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<PartyRow?> findById(String id) =>
      (select(parties)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<PartyRow?> findBySyncId(String syncId) => (select(
    parties,
  )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();

  Future<void> upsertLocal(PartiesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(parties).insertOnConflictUpdate(
      companion.copyWith(
        isDirty: const Value(true),
        updatedAtMs: Value(now),
        createdAtMs: companion.createdAtMs.present
            ? companion.createdAtMs
            : Value(now),
      ),
    );
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(parties)..where((t) => t.id.equals(id))).write(
      PartiesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  Future<List<PartyRow>> pendingPush() =>
      (select(parties)..where((t) => t.isDirty.equals(true))).get();

  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(parties)..where((t) => t.syncId.isIn(syncIds))).write(
      const PartiesCompanion(isDirty: Value(false)),
    );
  }

  Future<bool> upsertFromRemote(PartiesCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        existing.updatedAtMs > remote.updatedAtMs.value &&
        existing.isDirty) {
      return false;
    }
    await into(
      parties,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      parties,
    )..addColumns([parties.updatedAtMs.max()])).getSingle();
    return row.read(parties.updatedAtMs.max()) ?? 0;
  }
}
