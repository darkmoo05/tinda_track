import '../../network/api_client.dart';
class TransactionTypeRemoteRepository {
  TransactionTypeRemoteRepository._();
  static final TransactionTypeRemoteRepository instance =
      TransactionTypeRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/transaction-types/push', records);
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
    return await ApiClient.instance.getJsonList('/transaction-types/pull', params: params);
  }
}
