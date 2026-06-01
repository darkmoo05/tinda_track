import 'package:dio/dio.dart';

import '../../network/api_client.dart';
import 'sync_logging.dart';

class CustomerRemoteRepository {
  CustomerRemoteRepository._();
  static final CustomerRemoteRepository instance = CustomerRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/customers/push', records);
      return true;
    } on DioException catch (e) {
      logSyncFailure('/customers/push', e);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    try {
      final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      final res = await ApiClient.instance.get(
        '/customers/pull',
        params: params,
      );
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logSyncFailure('/customers/pull', e, op: 'pull');
      return [];
    }
  }
}
