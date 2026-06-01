import 'dart:async';
import 'dart:math';

/// Exponential-backoff retry helper used by sync orchestrators.
///
/// The policy is intentionally conservative — sync should never block the UI
/// thread for long. Default: up to 3 attempts, base 500ms, factor 2,
/// jitter ±20%.
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
        final shouldRetry = retryWhen?.call(error) ?? true;
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
}
