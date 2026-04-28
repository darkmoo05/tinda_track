import 'package:dio/dio.dart';
import '../../network/api_client.dart';

class LedgerEntryRemoteRepository {
  LedgerEntryRemoteRepository._();
  static final LedgerEntryRemoteRepository instance =
      LedgerEntryRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    try {
      await ApiClient.instance.post('/entries/push', records);
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
      final res = await ApiClient.instance.get(
        '/entries/pull',
        params: {'deviceId': deviceId, if (since != null) 'since': since},
      );
      final data = res.data['data'] as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (_) {
      return [];
    }
  }
}
