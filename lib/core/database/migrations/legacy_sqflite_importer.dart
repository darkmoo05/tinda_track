import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as legacy;
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../daos/app_meta_dao.dart';

/// One-shot importer that copies data from the historical sqflite
/// `tinda_track.db` into the new Drift database, then deletes the old file.
///
/// Lifecycle (idempotent):
/// 1. On first launch after the Drift cutover, [runIfNeeded] is called by
///    main.dart.
/// 2. Reads `legacy_import_status` from `app_meta`.
///    * `done` / `not_found`     → return immediately.
///    * any other value (or null) → attempt import.
/// 3. Opens the legacy db read-only via `sqflite_common_ffi`.
/// 4. For each pocket-ledger table, copies rows into Drift, preserving
///    `is_dirty` (so the next sync run will re-push anything that wasn't
///    acknowledged on the old client).
/// 5. On full success: deletes the legacy file and marks status `done`.
/// 6. On any failure: marks status `failed` and leaves the file intact so a
///    later run can retry without losing data.
///
/// Tinda-tracker import is intentionally a TODO until Phase 4 lands DAOs.
class LegacyImporter {
  LegacyImporter(this._db, this._appMeta);

  final AppDatabase _db;
  final AppMetaDao _appMeta;

  static const String _statusKey = 'legacy_import_status';
  static const String _legacyDbName = 'tinda_track.db';

  static const String _statusDone = 'done';
  static const String _statusNotFound = 'not_found';
  static const String _statusFailed = 'failed';

  /// Idempotent entry-point. Call once on app startup after the Drift database
  /// is opened. Returns true when an import actually ran (legacy data was
  /// migrated), false otherwise.
  Future<bool> runIfNeeded() async {
    final status = await _appMeta.get(_statusKey);
    if (status == _statusDone || status == _statusNotFound) {
      return false;
    }

    legacy.sqfliteFfiInit();
    final factory = legacy.databaseFactoryFfi;
    final dir = await factory.getDatabasesPath();
    final legacyPath = p.join(dir, _legacyDbName);

    if (!await File(legacyPath).exists()) {
      await _appMeta.set(_statusKey, _statusNotFound);
      _log('No legacy DB at $legacyPath — nothing to import.');
      return false;
    }

    legacy.Database? legacyDb;
    try {
      legacyDb = await factory.openDatabase(
        legacyPath,
        options: legacy.OpenDatabaseOptions(readOnly: true),
      );
      final rows = await _import(legacyDb);
      await legacyDb.close();
      legacyDb = null;

      await _deleteLegacyFile(legacyPath);
      await _appMeta.set(_statusKey, _statusDone);
      _log('Imported $rows row(s) from legacy DB and deleted file.');
      return true;
    } catch (e, st) {
      await legacyDb?.close();
      await _appMeta.set(_statusKey, _statusFailed);
      developer.log(
        'Legacy import failed: $e',
        name: 'legacy_importer',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  // ── Import driver ──────────────────────────────────────────────────────────

  Future<int> _import(legacy.Database src) async {
    var total = 0;
    await _db.transaction(() async {
      total += await _importTransactionTypes(src);
      total += await _importMovementCategories(src);
      total += await _importParties(src);
      total += await _importCharges(src);
      total += await _importLedgerEntries(src);
      total += await _importFeeTransactions(src);
      // NOTE: legacy DB has no `transactions` table — that entity is new in
      // Drift and starts empty.
      // NOTE: tinda_tracker (tt_*) tables are TODO — wait for Phase 4 DAOs.
    });
    return total;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the legacy `sync_id` if present, otherwise generates a stable
  /// UUID. The new schema's primary key reuses this value so subsequent pulls
  /// from the server (which key on syncId) won't create duplicates.
  String _syncId(Map<String, Object?> row) {
    final v = row['sync_id'] as String?;
    if (v != null && v.isNotEmpty) return v;
    return const Uuid().v4();
  }

  int _ms(Object? v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final asInt = int.tryParse(v);
      if (asInt != null) return asInt;
      final dt = DateTime.tryParse(v);
      if (dt != null) return dt.millisecondsSinceEpoch;
    }
    return fallback;
  }

  bool _bool(Object? v, {bool fallback = false}) {
    if (v == null) return fallback;
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final lower = v.toLowerCase();
      return lower == '1' || lower == 'true';
    }
    return fallback;
  }

  double _real(Object? v, {double fallback = 0}) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  String _str(Object? v, {String fallback = ''}) {
    if (v == null) return fallback;
    return v.toString();
  }

  /// Resolves the timestamps a SyncedRow expects.
  ({int createdAt, int updatedAt}) _timestamps(Map<String, Object?> row) {
    final created = _ms(row['created_at_ms']) != 0
        ? _ms(row['created_at_ms'])
        : _ms(row['created_at']);
    final updated = _ms(row['updated_at_ms']) != 0
        ? _ms(row['updated_at_ms'])
        : (_ms(row['updated_at']) != 0
              ? _ms(row['updated_at'])
              : (created != 0
                    ? created
                    : DateTime.now().millisecondsSinceEpoch));
    return (createdAt: created != 0 ? created : updated, updatedAt: updated);
  }

  // ── Per-table importers ────────────────────────────────────────────────────

  Future<int> _importCharges(legacy.Database src) async {
    final rows = await _safeQuery(src, 'charges');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db
          .into(_db.charges)
          .insertOnConflictUpdate(
            ChargesCompanion.insert(
              id: id,
              lowerBound: _real(r['lower_bound']),
              upperBound: _real(r['upper_bound']),
              chargeAmount: _real(r['charge_amount']),
              transactionTypeKey: Value(
                _str(r['transaction_type_key'], fallback: 'gcash_cashin'),
              ),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importParties(legacy.Database src) async {
    final rows = await _safeQuery(src, 'parties');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db
          .into(_db.parties)
          .insertOnConflictUpdate(
            PartiesCompanion.insert(
              id: id,
              name: _str(r['name']),
              accountNumber: Value(_str(r['account_number'])),
              entityId: Value(_str(r['entity_id'])),
              description: Value(_str(r['description'])),
              joinDate: _str(r['join_date'], fallback: ''),
              isVerified: Value(_bool(r['is_verified'])),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importTransactionTypes(legacy.Database src) async {
    final rows = await _safeQuery(src, 'transaction_types');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db
          .into(_db.transactionTypes)
          .insertOnConflictUpdate(
            TransactionTypesCompanion.insert(
              id: id,
              name: _str(r['name']),
              isOutflow: Value(_bool(r['is_outflow'])),
              walletAccount: Value(
                _str(r['wallet_account'], fallback: 'GCash'),
              ),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importMovementCategories(legacy.Database src) async {
    // Legacy table name is `owner_movement_categories`; new is
    // `movement_categories`.
    final rows = await _safeQuery(src, 'owner_movement_categories');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      await _db
          .into(_db.movementCategories)
          .insertOnConflictUpdate(
            MovementCategoriesCompanion.insert(
              id: id,
              name: _str(r['name']),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importLedgerEntries(legacy.Database src) async {
    final rows = await _safeQuery(src, 'ledger_entries');
    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      // Legacy ledger has no `entry_date` column — fall back to created_at
      // (the canonical "when did this happen" timestamp on the old client).
      final entryDate = _str(r['entry_date'], fallback: _str(r['created_at']));
      await _db
          .into(_db.ledgerEntries)
          .insertOnConflictUpdate(
            LedgerEntriesCompanion.insert(
              id: id,
              entryType: _str(r['entry_type']),
              amount: _real(r['amount']),
              entryDate: entryDate,
              transactionId: const Value(
                null,
              ), // legacy DB pre-dates the transactions table
              title: Value(_str(r['title'])),
              note: Value(_str(r['note'])),
              reference: Value(_str(r['reference'])),
              walletDelta: Value(_real(r['wallet_delta'])),
              mayaWalletDelta: Value(_real(r['maya_wallet_delta'])),
              onHandDelta: Value(_real(r['on_hand_delta'])),
              recordedFlow: Value(_real(r['recorded_flow'])),
              tag: Value(_str(r['tag'])),
              iconKey: Value(_str(r['icon_key'])),
              walletAccount: Value(_str(r['wallet_account'])),
              ownerScope: Value(_str(r['owner_scope'], fallback: 'Business')),
              ownerMovementType: Value(r['owner_movement_type'] as String?),
              ownerCategory: Value(r['owner_category'] as String?),
              ownerPartyName: Value(r['owner_party_name'] as String?),
              ownerPartyAccount: Value(r['owner_party_account'] as String?),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  Future<int> _importFeeTransactions(legacy.Database src) async {
    final rows = await _safeQuery(src, 'fee_transactions');
    // Legacy used INTEGER `related_transaction_id` (the ledger row's PK). The
    // new schema stores `related_transaction_sync_id` (TEXT). We can't resolve
    // the FK without the original ledger row's sync_id, so we look it up
    // inline. If the parent row was never assigned a sync_id, leave null.
    Future<String?> resolveSyncId(int? legacyId) async {
      if (legacyId == null) return null;
      final res = await src.rawQuery(
        'SELECT sync_id FROM ledger_entries WHERE id = ? LIMIT 1',
        [legacyId],
      );
      if (res.isEmpty) return null;
      final v = res.first['sync_id'] as String?;
      return (v != null && v.isNotEmpty) ? v : null;
    }

    for (final r in rows) {
      final id = _syncId(r);
      final ts = _timestamps(r);
      final relatedSyncId = await resolveSyncId(
        r['related_transaction_id'] as int?,
      );
      await _db
          .into(_db.feeTransactions)
          .insertOnConflictUpdate(
            FeeTransactionsCompanion.insert(
              id: id,
              feeAmount: _real(r['fee_amount']),
              feeType: _str(r['fee_type']),
              chargeDestination: _str(r['charge_destination']),
              relatedTransactionSyncId: Value(relatedSyncId),
              syncId: id,
              deviceId: Value(_str(r['device_id'])),
              isDeleted: Value(_bool(r['is_deleted'])),
              isDirty: Value(_bool(r['is_dirty'], fallback: true)),
              createdAtMs: ts.createdAt,
              updatedAtMs: ts.updatedAt,
            ),
          );
    }
    return rows.length;
  }

  // ── Utilities ──────────────────────────────────────────────────────────────

  Future<List<Map<String, Object?>>> _safeQuery(
    legacy.Database src,
    String table,
  ) async {
    // Older DBs may pre-date some tables (especially fee_transactions /
    // movement_categories). Returning [] on missing table keeps the import
    // resilient instead of aborting the whole migration.
    final exists = await src.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    if (exists.isEmpty) return const [];
    return src.query(table);
  }

  Future<void> _deleteLegacyFile(String path) async {
    try {
      await File(path).delete();
      // Best-effort: also remove the journal/wal/shm siblings sqflite leaves.
      for (final ext in const ['-journal', '-wal', '-shm']) {
        final sibling = File('$path$ext');
        if (await sibling.exists()) {
          await sibling.delete();
        }
      }
    } catch (e) {
      _log('Failed to delete legacy DB file $path: $e');
    }
  }

  void _log(String message) {
    developer.log(message, name: 'legacy_importer');
  }
}
