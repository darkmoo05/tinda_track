import 'package:dio/dio.dart';
import '../../network/api_client.dart';
import 'sync_logging.dart';

/// Remote endpoint wrapper for the `transactions` collection.
/// Endpoints: `POST /transactions/push`, `GET /transactions/pull?since=&deviceId=`.
class TransactionRemoteRepository {
  TransactionRemoteRepository._();
  static final TransactionRemoteRepository instance =
      TransactionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/transactions/push', records);
      return true;
    } on DioException catch (e) {
      logSyncFailure('/transactions/push', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    try {
      final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) {
        params['since'] = since;
      }
      final res = await ApiClient.instance.get(
        '/transactions/pull',
        params: params,
      );
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logSyncFailure('/transactions/pull', e, op: 'pull');
      return [];
    }
  }
}
