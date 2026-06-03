import '../../network/api_client.dart';
class CustomerRemoteRepository {
  CustomerRemoteRepository._();
  static final CustomerRemoteRepository instance = CustomerRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/customers/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/customers/pull', params: params);
  }
}
