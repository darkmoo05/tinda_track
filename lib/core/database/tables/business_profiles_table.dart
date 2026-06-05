import 'package:drift/drift.dart';
import 'pocket_ledger_tables.dart' show SyncedRow;

/// BUSINESS PROFILE — Mirrors Prisma `BusinessProfile` (table `business_profiles`).
/// Keeps track of store settings, selected industry, and feature flags.
@DataClassName('BusinessProfileRow')
@TableIndex(name: 'business_profiles_is_dirty_idx', columns: {#isDirty})
class BusinessProfiles extends Table with SyncedRow {
  TextColumn get id => text()();
  TextColumn get businessType => text()(); // retail, food_service, etc.
  TextColumn get businessName => text()();
  TextColumn get defaultCurrency => text().withDefault(const Constant('PHP'))();
  TextColumn get preferencesJson => text().withDefault(const Constant('{}'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  String? get tableName => 'business_profiles';
}
