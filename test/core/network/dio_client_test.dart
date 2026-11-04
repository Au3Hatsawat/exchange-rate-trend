import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/core/network/api_endpoints.dart';
import 'package:exchange_rate_trend/core/network/dio_client.dart';

void main() {
  group('DioClient', () {
    test('createDio: should return Dio instance configured with default Frankfurter API Base URL and 10s timeouts', () {
      final dio = DioClient.createDio();

      expect(dio.options.baseUrl, equals(ApiEndpoints.baseUrl));
      expect(dio.options.baseUrl, equals('https://api.frankfurter.dev'));
      expect(dio.options.connectTimeout, equals(const Duration(seconds: 10)));
      expect(dio.options.receiveTimeout, equals(const Duration(seconds: 10)));
      expect(dio.options.headers['Accept'], equals('application/json'));
    });

    test('createDio: should accept custom baseUrl if provided', () {
      const customUrl = 'https://custom.api.dev';
      final dio = DioClient.createDio(baseUrl: customUrl);

      expect(dio.options.baseUrl, equals(customUrl));
    });
  });
}
