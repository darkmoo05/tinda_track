import '../../network/api_client.dart';
class PartyRemoteRepository {
  PartyRemoteRepository._();
  static final PartyRemoteRepository instance = PartyRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/parties/push', records);
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
    return await ApiClient.instance.getJsonList('/parties/pull', params: params);
  }
}
