import '../../network/api_client.dart';
/// Remote repository for [Sales]. The push payload includes embedded
/// `items` (sale lines); the pull payload likewise returns sales with their
/// lines so the local repository can replace them atomically.
class SaleRemoteRepository {
  SaleRemoteRepository._();
  static final SaleRemoteRepository instance = SaleRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/sales/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/sales/pull', params: params);
  }
}
