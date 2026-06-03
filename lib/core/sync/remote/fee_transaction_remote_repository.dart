import '../../network/api_client.dart';
/// Remote endpoint wrapper for the `fee_transactions` collection.
class FeeTransactionRemoteRepository {
  FeeTransactionRemoteRepository._();
  static final FeeTransactionRemoteRepository instance =
      FeeTransactionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/fee-transactions/push', records);
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
    return await ApiClient.instance.getJsonList('/fee-transactions/pull', params: params);
  }
}
