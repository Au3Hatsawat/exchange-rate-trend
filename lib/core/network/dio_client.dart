import 'package:dio/dio.dart';
import 'api_endpoints.dart';

class DioClient {
  static Dio createDio({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: const {
          'Accept': 'application/json',
        },
      ),
    );
    return dio;
  }
}
