import '../../network/api_client.dart';
class ProductUnitConversionRemoteRepository {
  ProductUnitConversionRemoteRepository._();
  static final ProductUnitConversionRemoteRepository instance =
      ProductUnitConversionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post(
        '/inventory/product-unit-conversions/push',
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
      return await ApiClient.instance.getJsonList('/inventory/product-unit-conversions/pull', params: params);
  }
}
