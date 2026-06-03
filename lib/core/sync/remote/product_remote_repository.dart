import 'dart:io';
import 'package:dio/dio.dart';
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

  Future<String?> uploadImage(String id, File file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });
    final response = await ApiClient.instance.dio.patch(
      '/inventory/products/$id/image',
      data: formData,
    );
    if (response.statusCode == 200) {
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return data['imageUrl'] as String?;
        }
      }
    }
    return null;
  }
}
