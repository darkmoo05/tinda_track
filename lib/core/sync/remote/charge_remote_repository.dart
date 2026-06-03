import '../../network/api_client.dart';
class ChargeRemoteRepository {
  ChargeRemoteRepository._();
  static final ChargeRemoteRepository instance = ChargeRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/charges/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
    if (since != null) {
      params['since'] = since;
    }
    return await ApiClient.instance.getJsonList('/charges/pull', params: params);
  }
}
