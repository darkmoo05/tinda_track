/// Structured error taxonomy used by the sync engine.
///
/// Every failure during push/pull is normalised into one of these so the
/// [RetryPolicy] can classify "retry-worthy" transients (network, 5xx)
/// vs terminal failures (auth, validation, schema), and so the UI can
/// surface a meaningful message without inspecting Dio internals.
sealed class SyncError implements Exception {
  const SyncError(this.message, {this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;

  /// True for failures the engine should retry with backoff.
  bool get isTransient;

  @override
  String toString() => '$runtimeType($message, status=$statusCode)';
}

/// Network connectivity / DNS / TLS / timeout failures — always transient.
class NetworkSyncError extends SyncError {
  const NetworkSyncError(super.message, {super.cause})
    : super(statusCode: null);
  @override
  bool get isTransient => true;
}

/// 5xx server-side failure. Transient — backend may be deploying or rate-limited.
class ServerSyncError extends SyncError {
  const ServerSyncError(
    super.message, {
    super.cause,
    required int super.statusCode,
  });
  @override
  bool get isTransient => true;
}

/// 401/403 — authentication or authorisation. Terminal until the user
/// re-authenticates; retrying with the same credentials is pointless.
class AuthSyncError extends SyncError {
  const AuthSyncError(
    super.message, {
    super.cause,
    required int super.statusCode,
  });
  @override
  bool get isTransient => false;
}

/// 4xx validation / contract failures (e.g. malformed payload). Terminal.
class ValidationSyncError extends SyncError {
  const ValidationSyncError(
    super.message, {
    super.cause,
    required int super.statusCode,
  });
  @override
  bool get isTransient => false;
}

/// Response was not the expected JSON shape (HTML login page, wrong
/// content-type, missing `data` envelope). Terminal — indicates a routing
/// or proxy misconfiguration that retrying cannot fix.
class SchemaSyncError extends SyncError {
  const SchemaSyncError(super.message, {super.cause}) : super(statusCode: null);
  @override
  bool get isTransient => false;
}

/// The remote endpoint accepted the request but reported the batch as not
/// applied (returned `false`/non-2xx-but-handled). Terminal for this run —
/// rows stay dirty and will be retried on the next sync cycle, but the
/// engine must record this as a failure so the UI surfaces it.
class PushRejectedError extends SyncError {
  const PushRejectedError(super.message, {super.cause})
    : super(statusCode: null);
  @override
  bool get isTransient => false;
}
