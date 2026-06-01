import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Centralised logger for sync remote-repository failures. Prior to this
/// helper, every push/pull catch block did `on DioException catch (_) { ... }`
/// — failures (HTTP 4xx/5xx, timeouts, validation errors) were swallowed and
/// the orchestrator silently recorded "0 synced" without surfacing a reason,
/// making field debugging impossible.
///
/// Now every catch funnels through here so we get the route, status, and the
/// server's response body in the device log (`flutter logs` or LogCat).
void logSyncFailure(String route, Object error, {String op = 'push'}) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    final body = error.response?.data;
    developer.log(
      '$op $route failed: status=$status type=${error.type} '
      'message=${error.message} body=$body',
      name: 'sync.remote',
      error: error,
    );
  } else {
    developer.log(
      '$op $route failed: $error',
      name: 'sync.remote',
      error: error,
    );
  }
}
