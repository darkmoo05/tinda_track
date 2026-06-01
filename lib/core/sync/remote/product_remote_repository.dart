import '../../network/api_client.dart';
class ProductRemoteRepository {
  ProductRemoteRepository._();
  static final ProductRemoteRepository instance = ProductRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/inventory/products/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/inventory/products/pull', params: params);
  }
}
