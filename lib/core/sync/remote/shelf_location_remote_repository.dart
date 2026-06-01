import '../../network/api_client.dart';
class ShelfLocationRemoteRepository {
  ShelfLocationRemoteRepository._();
  static final ShelfLocationRemoteRepository instance =
      ShelfLocationRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/inventory/shelf-locations/push', records);
    return true;
  }

  Future<List<Map<String, dynamic>>> pull({
    required String deviceId,
    int? since,
  }) async {
    final params = <String, Object?>{'deviceId': deviceId};
      if (since != null) params['since'] = since;
      return await ApiClient.instance.getJsonList('/inventory/shelf-locations/pull', params: params);
  }
}
