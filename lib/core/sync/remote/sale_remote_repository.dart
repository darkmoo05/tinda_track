import 'package:dio/dio.dart';

import '../../network/api_client.dart';
import 'sync_logging.dart';

/// Remote repository for [Sales]. The push payload includes embedded
/// `items` (sale lines); the pull payload likewise returns sales with their
/// lines so the local repository can replace them atomically.
class SaleRemoteRepository {
  SaleRemoteRepository._();
  static final SaleRemoteRepository instance = SaleRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/sales/push', records);
      return true;
    } on DioException catch (e) {
      logSyncFailure('/sales/push', e);
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
      final res = await ApiClient.instance.get('/sales/pull', params: params);
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      logSyncFailure('/sales/pull', e, op: 'pull');
      return [];
    }
  }
}
