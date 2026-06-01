import '../../network/api_client.dart';
class MovementCategoryRemoteRepository {
  MovementCategoryRemoteRepository._();
  static final MovementCategoryRemoteRepository instance =
      MovementCategoryRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/movement-categories/push', records);
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
    return await ApiClient.instance.getJsonList('/movement-categories/pull', params: params);
  }
}
