import '../../network/api_client.dart';
class LedgerEntryRemoteRepository {
  LedgerEntryRemoteRepository._();
  static final LedgerEntryRemoteRepository instance =
      LedgerEntryRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/entries/push', records);
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
    return await ApiClient.instance.getJsonList('/entries/pull', params: params);
  }
}
