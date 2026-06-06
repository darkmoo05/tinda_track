import '../../network/api_client.dart';

class ProductSerialNumberRemoteRepository {
  ProductSerialNumberRemoteRepository._();
  static final ProductSerialNumberRemoteRepository instance =
      ProductSerialNumberRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post(
      '/inventory/product-serial-numbers/push',
      records,
    );
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
    if (since != null) params['since'] = since;
    return await ApiClient.instance.getJsonList(
      '/inventory/product-serial-numbers/pull',
      params: params,
    );
  }
}
