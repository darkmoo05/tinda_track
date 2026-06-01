import 'package:dio/dio.dart';
import '../../network/api_client.dart';
import 'sync_logging.dart';

/// Remote endpoint wrapper for the `fee_transactions` collection.
class FeeTransactionRemoteRepository {
  FeeTransactionRemoteRepository._();
  static final FeeTransactionRemoteRepository instance =
      FeeTransactionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/fee-transactions/push', records);
      return true;
    } on DioException catch (e) {
      logSyncFailure('/fee-transactions/push', e);
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
        '/fee-transactions/pull',
        params: params,
      );
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logSyncFailure('/fee-transactions/pull', e, op: 'pull');
      return [];
    }
  }
}
