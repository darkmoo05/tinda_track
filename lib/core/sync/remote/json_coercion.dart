/// Tolerant JSON numeric coercion for remote pull payloads.
///
/// The NestJS backend uses Prisma `Decimal(p,s)` columns which are serialised
/// as JSON **strings** (e.g. `"12.50"`), not numbers. Naive `as num` casts
/// throw at runtime. These helpers accept `num`, numeric strings, or null.
library;

double asDouble(Object? v, {double fallback = 0}) {
  if (v == null) return fallback;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return fallback;
    return double.tryParse(s) ?? fallback;
  }
  return fallback;
}

int asInt(Object? v, {int fallback = 0}) {
  if (v == null) return fallback;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return fallback;
    final asI = int.tryParse(s);
    if (asI != null) return asI;
    final asD = double.tryParse(s);
    if (asD != null) return asD.toInt();
  }
  return fallback;
}

double? asDoubleOrNull(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }
  return null;
}

int? asIntOrNull(Object? v) {
  if (v == null) return null;
  if (v is num) return v.toInt();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return null;
    final asI = int.tryParse(s);
    if (asI != null) return asI;
    final asD = double.tryParse(s);
    return asD?.toInt();
  }
  return null;
}
