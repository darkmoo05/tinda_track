import 'package:dio/dio.dart';
import 'api_config.dart';

class ApiClient {
  ApiClient._()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  static final ApiClient instance = ApiClient._();

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? params}) {
    return _dio.get(path, queryParameters: params);
  }

  Future<Response> post(String path, dynamic data) {
    return _dio.post(path, data: data);
  }
}
