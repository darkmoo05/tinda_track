import '../entities/charge.dart';

/// Domain-layer contract for charge persistence. Presentation depends on
/// this interface, never the Drift DAO directly.
abstract class ChargeRepository {
  Stream<List<Charge>> watchAll({String? transactionTypeKey});
  Future<Charge?> findById(String id);

  /// Creates or updates a charge locally. Marks the row dirty so the next
  /// sync push will send it. Returns the persisted entity.
  Future<Charge> save(Charge charge);

  /// Soft-deletes the charge by id (sets is_deleted=true, is_dirty=true).
  Future<void> delete(String id);
}
