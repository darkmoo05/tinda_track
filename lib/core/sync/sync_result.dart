/// Outcome of a single sync run for one module.
class SyncResult {
  const SyncResult({
    required this.moduleKey,
    required this.pulledCount,
    required this.pushedCount,
    required this.conflictsResolved,
    this.error,
    this.startedAt,
    this.finishedAt,
  });

  final String moduleKey;
  final int pulledCount;
  final int pushedCount;
  final int conflictsResolved;
  final Object? error;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  bool get ok => error == null;

  factory SyncResult.empty(String moduleKey) => SyncResult(
    moduleKey: moduleKey,
    pulledCount: 0,
    pushedCount: 0,
    conflictsResolved: 0,
  );

  factory SyncResult.failed(String moduleKey, Object error) => SyncResult(
    moduleKey: moduleKey,
    pulledCount: 0,
    pushedCount: 0,
    conflictsResolved: 0,
    error: error,
  );
}
