import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiClient {
  late Dio dio;
  final logger = Logger();

  // Use local Wi-Fi IP for testing on physical devices
  static String baseUrl = 'http://10.124.13.107:3000/api';

  static void setBaseUrl(String url) {
    baseUrl = url;
    apiClient.dio.options.baseUrl = url;
  }

  ApiClient() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    // Logging Interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        logger.i('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        logger.i('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        logger.e('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        return handler.next(e);
      },
    ));
  }

  // Helper methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    return await dio.patch(path, data: data, options: options);
  }
}

// Global instance (can be replaced by Riverpod provider later)
final apiClient = ApiClient();
