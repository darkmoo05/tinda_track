import '../../network/api_client.dart';
class UtangRecordRemoteRepository {
  UtangRecordRemoteRepository._();
  static final UtangRecordRemoteRepository instance =
      UtangRecordRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/utang-records/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/utang-records/pull', params: params);
  }
}
