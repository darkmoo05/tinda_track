import '../../network/api_client.dart';
class ProductCategoryRemoteRepository {
  ProductCategoryRemoteRepository._();
  static final ProductCategoryRemoteRepository instance =
      ProductCategoryRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/inventory/categories/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/inventory/categories/pull', params: params);
  }
}
