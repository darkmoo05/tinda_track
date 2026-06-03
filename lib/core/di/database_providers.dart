/// Legacy import path — re-exports the canonical
/// `appDatabaseProvider` from
/// `core/database/providers/database_providers.dart`.
///
/// Kept so existing imports of `core/di/database_providers.dart` keep
/// resolving. New code should depend on the canonical path directly.
library;

export '../database/providers/database_providers.dart';
