import 'package:drift/drift.dart';

import '../../app_database.dart';
import '../../lww.dart';
import '../../tables/pocket_ledger_tables.dart';

part 'charges_dao.g.dart';

/// Data-access object for the `charges` table.
///
/// All write paths set `is_dirty = true` and refresh `updated_at_ms`. The
/// SyncOrchestrator consumes dirty rows via [pendingPush], clears the flag
/// via [markClean], and applies LWW conflict resolution via [upsertFromRemote].
@DriftAccessor(tables: [Charges])
class ChargesDao extends DatabaseAccessor<AppDatabase> with _$ChargesDaoMixin {
  ChargesDao(super.db);

  // ── Reactive reads ────────────────────────────────────────────────────────

  Stream<List<ChargeRow>> watchAll({String? transactionTypeKey}) {
    final q = select(charges)..where((t) => t.isDeleted.equals(false));
    if (transactionTypeKey != null) {
      q.where((t) => t.transactionTypeKey.equals(transactionTypeKey));
    }
    q.orderBy([(t) => OrderingTerm.asc(t.lowerBound)]);
    return q.watch();
  }

  Future<ChargeRow?> findById(String id) {
    return (select(charges)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<ChargeRow?> findBySyncId(String syncId) {
    return (select(
      charges,
    )..where((t) => t.syncId.equals(syncId))).getSingleOrNull();
  }

  // ── Local writes (UI-driven) ──────────────────────────────────────────────

  Future<void> upsertLocal(ChargesCompanion companion) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final patched = companion.copyWith(
      isDirty: const Value(true),
      updatedAtMs: Value(now),
      createdAtMs: companion.createdAtMs.present
          ? companion.createdAtMs
          : Value(now),
    );
    await into(charges).insertOnConflictUpdate(patched);
  }

  Future<void> softDelete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(charges)..where((t) => t.id.equals(id))).write(
      ChargesCompanion(
        isDeleted: const Value(true),
        isDirty: const Value(true),
        updatedAtMs: Value(now),
      ),
    );
  }

  // ── Sync hooks ────────────────────────────────────────────────────────────

  /// Returns all locally-modified rows pending push.
  Future<List<ChargeRow>> pendingPush() {
    return (select(charges)..where((t) => t.isDirty.equals(true))).get();
  }

  /// Marks rows as synced after the server acknowledged them.
  Future<void> markClean(Iterable<String> syncIds) async {
    if (syncIds.isEmpty) return;
    await (update(charges)..where((t) => t.syncId.isIn(syncIds))).write(
      const ChargesCompanion(isDirty: Value(false)),
    );
  }

  /// LWW upsert from a server payload. Caller must convert the JSON to a
  /// [ChargesCompanion] first (see ChargeMapper).
  ///
  /// Returns true when the row was written (remote won), false when the local
  /// version was newer.
  Future<bool> upsertFromRemote(ChargesCompanion remote) async {
    final syncId = remote.syncId.value;
    final existing = await findBySyncId(syncId);
    if (existing != null &&
        Lww.localShouldKeep(
          localUpdatedAtMs: existing.updatedAtMs,
          localIsDirty: existing.isDirty,
          remoteUpdatedAtMs: remote.updatedAtMs.value,
        )) {
      return false;
    }
    await into(
      charges,
    ).insertOnConflictUpdate(remote.copyWith(isDirty: const Value(false)));
    return true;
  }

  /// Highest `updated_at_ms` across all charges — used to bump the per-module
  /// pull cursor after a successful sync.
  Future<int> maxUpdatedAt() async {
    final row = await (selectOnly(
      charges,
    )..addColumns([charges.updatedAtMs.max()])).getSingle();
    return row.read(charges.updatedAtMs.max()) ?? 0;
  }
}
