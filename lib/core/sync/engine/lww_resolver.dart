/// Last-Write-Wins conflict resolution helpers.
///
/// The canonical rule: the side with the larger `updated_at_ms` wins; ties
/// go to the remote because the server is the source of truth for
/// chronological ordering across devices.
///
/// A local row is only protected against being overwritten when it is both
/// **newer** *and* **still dirty** — once acknowledged, it's free to be
/// replaced by an authoritative server copy.
abstract final class Lww {
  /// Should the incoming remote row overwrite the local one?
  ///
  /// * [localUpdatedAtMs] / [remoteUpdatedAtMs] — UTC millis-since-epoch.
  /// * [localIsDirty] — true if the local row has unsynced changes.
  ///
  /// Returns false (keep local) only when the local copy is strictly newer
  /// AND still dirty.
  static bool remoteShouldWin({
    required int localUpdatedAtMs,
    required int remoteUpdatedAtMs,
    required bool localIsDirty,
  }) {
    if (localIsDirty && localUpdatedAtMs > remoteUpdatedAtMs) return false;
    return true;
  }
}
