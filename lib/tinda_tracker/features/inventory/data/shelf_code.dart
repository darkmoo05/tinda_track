/// Shared encoding/decoding helpers for the QR codes printed on physical
/// shelves.
///
/// Payload format: `TT-SHELF-<syncId>`
///
/// * `TT` namespaces the value so it never collides with product barcodes
///   (which use `TT-YYMMDD-XXXX`) or third-party EAN/UPC codes.
/// * `<syncId>` is the UUID already stored on every `CustomShelfLocation`
///   row, so codes survive rename, re-photo, or server re-issue.
///
/// Use [shelfCodePayload] to encode and [tryParseShelfCodePayload] to
/// decode. Both are intentionally tiny + pure so they can be reused by the
/// scanner pipeline, the printable-label screen, and tests.
library;

const String _shelfCodePrefix = 'TT-SHELF-';

/// Builds the payload that should be encoded into the QR for a shelf with
/// the given [syncId].
String shelfCodePayload(String syncId) => '$_shelfCodePrefix$syncId';

/// Short, human-readable suffix shown beneath the QR (first 8 chars of the
/// sync_id). Long enough to disambiguate in a list, short enough to fit on
/// a 50mm × 30mm sticker.
String shelfCodeShortLabel(String syncId) {
  if (syncId.length <= 8) return syncId.toUpperCase();
  return syncId.substring(0, 8).toUpperCase();
}

/// Returns the sync_id encoded in [raw] when it follows the
/// `TT-SHELF-<syncId>` convention, otherwise `null`.
///
/// The check is case-insensitive on the prefix so a scanner that
/// up-cases the payload still works.
String? tryParseShelfCodePayload(String raw) {
  final trimmed = raw.trim();
  if (trimmed.length <= _shelfCodePrefix.length) return null;
  final prefix = trimmed.substring(0, _shelfCodePrefix.length);
  if (prefix.toUpperCase() != _shelfCodePrefix) return null;
  final syncId = trimmed.substring(_shelfCodePrefix.length);
  if (syncId.isEmpty) return null;
  return syncId;
}
