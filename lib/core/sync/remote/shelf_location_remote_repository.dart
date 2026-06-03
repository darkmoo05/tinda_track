import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  Future<String?> uploadImage(String id, File file) async {
    File fileToUpload = file;
    final targetPath = '${file.parent.path}/compressed_${id}_${DateTime.now().millisecondsSinceEpoch}.webp';
    try {
      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 80,
        format: CompressFormat.webp,
        minWidth: 1024,
        minHeight: 1024,
      );
      if (compressedXFile != null) {
        fileToUpload = File(compressedXFile.path);
      }
    } catch (_) {
      // Fall back to original file if compression fails (e.g. invalid format)
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        fileToUpload.path,
        filename: fileToUpload.path.split(Platform.pathSeparator).last,
      ),
    });
    final response = await ApiClient.instance.dio.patch(
      '/inventory/shelf-locations/$id/image',
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
