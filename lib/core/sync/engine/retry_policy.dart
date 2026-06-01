import 'dart:async';
import 'dart:math';

import 'sync_errors.dart';

/// Exponential-backoff retry helper used by the sync engine.
///
/// The policy is intentionally conservative — sync runs in the foreground
/// and must not block the UI for long. Default: up to 3 attempts, base
/// 500ms, factor 2, jitter ±20%.
///
/// By default only [SyncError.isTransient] failures (network, 5xx) are
/// retried; auth/validation/schema errors fail fast.
class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.factor = 2,
    this.jitter = 0.2,
  });

  final int maxAttempts;
  final Duration baseDelay;
  final double factor;
  final double jitter;

  Future<T> run<T>(
    Future<T> Function() task, {
    bool Function(Object error)? retryWhen,
  }) async {
    final random = Random();
    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await task();
      } catch (error, stack) {
        lastError = error;
        lastStack = stack;
        final shouldRetry = (retryWhen ?? _defaultRetryWhen)(error);
        final isLast = attempt == maxAttempts - 1;
        if (!shouldRetry || isLast) break;

        final exp = baseDelay.inMilliseconds * pow(factor, attempt);
        final jitterMs = exp * jitter * (random.nextDouble() * 2 - 1);
        final delay = Duration(milliseconds: (exp + jitterMs).round());
        await Future<void>.delayed(delay);
      }
    }
    Error.throwWithStackTrace(lastError!, lastStack ?? StackTrace.current);
  }

  static bool _defaultRetryWhen(Object error) {
    if (error is SyncError) return error.isTransient;
    // Unknown error: retry once-ish to be safe (Dio quirks etc.).
    return true;
  }
}
