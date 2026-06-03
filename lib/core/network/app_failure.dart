import 'package:dio/dio.dart';

/// Centralized model representing failures across network, database, and system operations.
class AppFailure {
  AppFailure({
    required this.message,
    this.correlationId,
    this.statusCode,
  });

  /// User-friendly error message.
  final String message;

  /// Correlation ID from the server response headers or payload, for logging/traceability.
  final String? correlationId;

  /// HTTP status code if the error was a network error.
  final int? statusCode;

  /// Factory constructor to parse Dio network errors into an [AppFailure].
  factory AppFailure.fromDioError(DioException error) {
    String message = 'An unexpected connection error occurred';
    String? correlationId;
    int? statusCode;

    if (error.response != null) {
      statusCode = error.response!.statusCode;
      correlationId = error.response!.headers.value('x-correlation-id');

      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
        if (correlationId == null && data['correlationId'] != null) {
          correlationId = data['correlationId'].toString();
        }
      } else {
        message = 'Server returned an invalid response (HTTP $statusCode)';
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Network timeout. Please check your connection stability';
          break;
        case DioExceptionType.connectionError:
          message = 'Unable to reach the server. Please check your internet connection';
          break;
        case DioExceptionType.cancel:
          message = 'The request was cancelled';
          break;
        default:
          message = 'A network error occurred. Please try again';
          break;
      }
    }

    return AppFailure(
      message: message,
      correlationId: correlationId,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    if (correlationId != null && correlationId!.isNotEmpty) {
      return '$message (Trace ID: $correlationId)';
    }
    return message;
  }
}
