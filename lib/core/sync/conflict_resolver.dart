/// Last-Write-Wins conflict resolution.
///
/// Returns `true` if the incoming (remote) record should overwrite the local
/// record. The rule is straightforward: the row with the larger `updated_at`
/// timestamp wins. Ties go to the remote side (the server is the source of
/// truth for chronological ordering across devices).
bool remoteWinsLww({
  required int localUpdatedAtMs,
  required int remoteUpdatedAtMs,
}) {
  return remoteUpdatedAtMs >= localUpdatedAtMs;
}
