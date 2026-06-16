import '../../network/api_client.dart';

/// Remote endpoint wrapper for the `monitoring_sessions` collection.
class MonitoringSessionRemoteRepository {
  MonitoringSessionRemoteRepository._();
  static final MonitoringSessionRemoteRepository instance =
      MonitoringSessionRemoteRepository._();

  Future<bool> push(List<Map<String, dynamic>> records) async {
    await ApiClient.instance.post('/monitoring-sessions/push', records);
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
    return await ApiClient.instance.getJsonList('/monitoring-sessions/pull', params: params);
  }
}
