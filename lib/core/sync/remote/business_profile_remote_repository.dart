import '../../network/api_client.dart';

class BusinessProfileRemoteRepository {
  BusinessProfileRemoteRepository._();
  static final BusinessProfileRemoteRepository instance =
      BusinessProfileRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    // Unused by unified SyncEngine which calls /sync directly, but kept for standalone callbacks.
    await ApiClient.instance.post('/inventory/business-profiles/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
    if (since != null) params['since'] = since;
    return await ApiClient.instance.getJsonList('/inventory/business-profiles/pull', params: params);
  }
}
