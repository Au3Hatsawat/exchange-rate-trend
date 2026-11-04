import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/exceptions.dart';
import 'package:exchange_rate_trend/core/network/api_endpoints.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/models/rate_point_model.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late ExchangeRateRemoteDataSourceImpl dataSource;

  setUp(() {
    mockDio = MockDio();
    dataSource = ExchangeRateRemoteDataSourceImpl(dio: mockDio);
  });

  const tPair = CurrencyPair(base: 'USD', quote: 'THB');
  const tFrom = '2026-09-29';
  const tTo = '2026-10-29';
  final tExpectedQueryParams = {
    'from': tFrom,
    'to': tTo,
    'base': 'USD',
    'quotes': 'THB',
  };

  final tRawResponseList = [
    {
      'date': '2026-09-29',
      'base': 'USD',
      'quote': 'THB',
      'rate': 33.568,
    },
    {
      'date': '2026-10-29',
      'base': 'USD',
      'quote': 'THB',
      'rate': 33.750,
    },
  ];

  group('ExchangeRateRemoteDataSource', () {
    test('TC-4.1: getRates: should send GET request with exact query parameters', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tRawResponseList,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act
      await dataSource.getRates(pair: tPair, from: tFrom, to: tTo);

      // Assert
      verify(
        () => mockDio.get(
          ApiEndpoints.rates,
          queryParameters: tExpectedQueryParams,
        ),
      ).called(1);
    });

    test('TC-4.2: getRates: should return List<RatePointModel> on HTTP 200 with data', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: tRawResponseList,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act
      final result = await dataSource.getRates(pair: tPair, from: tFrom, to: tTo);

      // Assert
      expect(result, isA<List<RatePointModel>>());
      expect(result.length, 2);
      expect(result.first.date, DateTime(2026, 9, 29));
      expect(result.first.rate, 33.568);
      expect(result.last.date, DateTime(2026, 10, 29));
      expect(result.last.rate, 33.750);
    });

    test('TC-4.3: getRates: should throw EmptyDataException when API returns empty array []', () async {
      // Arrange (BR-6)
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: <dynamic>[],
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getRates(pair: tPair, from: tFrom, to: tTo),
        throwsA(isA<EmptyDataException>()),
      );
    });

    test('TC-4.4: getRates: should throw ServerException on HTTP 422 Unprocessable Entity', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 422,
            data: {'message': 'not found or invalid parameter'},
            requestOptions: RequestOptions(path: ApiEndpoints.rates),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getRates(pair: tPair, from: tFrom, to: tTo),
        throwsA(isA<ServerException>()),
      );
    });

    test('TC-4.5: getRates: should throw ServerException on HTTP 500 Server Error', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            data: {'message': 'internal server error'},
            requestOptions: RequestOptions(path: ApiEndpoints.rates),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getRates(pair: tPair, from: tFrom, to: tTo),
        throwsA(isA<ServerException>()),
      );
    });

    test('TC-4.6: getRates: should throw NetworkException on connection/receive timeout', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getRates(pair: tPair, from: tFrom, to: tTo),
        throwsA(isA<NetworkException>()),
      );
    });

    test('TC-4.7: getRates: should throw NetworkException on connection error (no internet)', () async {
      // Arrange
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: 'queryParameters'),
        ),
      ).thenThrow(
        DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: ApiEndpoints.rates),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getRates(pair: tPair, from: tFrom, to: tTo),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
