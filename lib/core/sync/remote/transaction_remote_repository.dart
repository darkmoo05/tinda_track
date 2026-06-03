import '../../network/api_client.dart';
/// Remote endpoint wrapper for the `transactions` collection.
/// Endpoints: `POST /transactions/push`, `GET /transactions/pull?since=&deviceId=`.
class TransactionRemoteRepository {
  TransactionRemoteRepository._();
  static final TransactionRemoteRepository instance =
      TransactionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/transactions/push', records);
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
    return await ApiClient.instance.getJsonList('/transactions/pull', params: params);
  }
}
