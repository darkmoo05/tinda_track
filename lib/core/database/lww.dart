/// Last-Write-Wins conflict resolution helper used by every synced DAO.
///
/// The canonical rule: when a remote row arrives via `upsertFromRemote`,
/// the local copy is **kept** (remote ignored) only when it is both
/// **newer** and **still dirty**. Otherwise the remote row wins.
///
/// "Still dirty" is essential: once the server has acknowledged a row, it
/// is free to be replaced by an authoritative server copy even if the
/// local timestamp happens to be newer (clock skew across devices).
///
/// All DAOs in `lib/core/database/daos/**` delegate to [Lww.localShouldKeep]
/// so the predicate has exactly one definition. Do not duplicate this
/// logic — extend the helper instead.
abstract final class Lww {
  /// Returns true when the **local** row should be kept and the incoming
  /// remote row ignored. Returns false when the remote row should win.
  static bool localShouldKeep({
    required int localUpdatedAtMs,
    required bool localIsDirty,
    required int remoteUpdatedAtMs,
  }) {
    return localIsDirty && localUpdatedAtMs > remoteUpdatedAtMs;
  }
}
