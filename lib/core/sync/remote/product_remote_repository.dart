import 'package:dio/dio.dart';

import '../../network/api_client.dart';
import 'sync_logging.dart';

class ProductRemoteRepository {
  ProductRemoteRepository._();
  static final ProductRemoteRepository instance = ProductRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/inventory/products/push', records);
      return true;
    } on DioException catch (e) {
      logSyncFailure('/inventory/products/push', e);
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
        '/inventory/products/pull',
        params: params,
      );
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logSyncFailure('/inventory/products/pull', e, op: 'pull');
      return [];
    }
  }
}
