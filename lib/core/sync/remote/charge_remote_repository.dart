import 'package:dio/dio.dart';
import '../../network/api_client.dart';

class ChargeRemoteRepository {
  ChargeRemoteRepository._();
  static final ChargeRemoteRepository instance = ChargeRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/charges/push', records);
      return true;
    } on DioException catch (_) {
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
      final res = await ApiClient.instance.get('/charges/pull', params: params);
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (_) {
      return [];
    }
  }
}
