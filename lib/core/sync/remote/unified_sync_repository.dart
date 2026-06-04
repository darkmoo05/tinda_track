import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../../network/api_client.dart';

class UnifiedSyncRepository {
  UnifiedSyncRepository._();
  static final UnifiedSyncRepository instance = UnifiedSyncRepository._();

  /// Executes push and pull in a single round-trip.
  /// Sends device identifier, the last sync timestamp cursor,
  /// and the map of dirty entity records to push.
  /// Returns the server response containing server timestamp and pull data.
  Future<Map<String, dynamic>> sync({
    required String deviceId,
    int? lastSync,
    required Map<String, dynamic> pushData,
  }) async {
    final payload = <String, dynamic>{
      'deviceId': deviceId,
      'push': pushData,
    };
    if (lastSync != null && lastSync > 0) {
      payload['lastSync'] = lastSync;
    }
    
    try {
      final response = await ApiClient.instance.post('/sync', payload);
      final body = response.data;
      if (body is Map<String, dynamic>) {
        return body;
      }
      throw StateError('Invalid response from sync server, expected JSON object.');
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData != null) {
        // Log detailed validation / server errors locally
        developer.log(
          'Sync server error: Status ${e.response?.statusCode}, Body: $responseData',
          name: 'sync.remote',
          error: e,
        );
        // Rethrow a new DioException with the descriptive body message so it surfaces in logs
        throw DioException(
          requestOptions: e.requestOptions,
          response: e.response,
          type: e.type,
          error: 'DioException [${e.response?.statusCode}]: $responseData',
          message: 'DioException [${e.response?.statusCode}]: $responseData',
        );
      }
      rethrow;
    }
  }
}
