import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/exceptions.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/models/rate_point_model.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';

class MockExchangeRateRemoteDataSource extends Mock implements ExchangeRateRemoteDataSource {}
class MockExchangeRateLocalDataSource extends Mock implements ExchangeRateLocalDataSource {}

class FakeCurrencyPair extends Fake implements CurrencyPair {}

void main() {
  late MockExchangeRateRemoteDataSource mockRemoteDataSource;
  late MockExchangeRateLocalDataSource mockLocalDataSource;
  late ExchangeRateRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(FakeCurrencyPair());
    registerFallbackValue(<RatePointModel>[]);
  });

  setUp(() {
    mockRemoteDataSource = MockExchangeRateRemoteDataSource();
    mockLocalDataSource = MockExchangeRateLocalDataSource();
    repository = ExchangeRateRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tPair = CurrencyPair(base: 'USD', quote: 'THB');
  final tMockPoints = [
    RatePointModel(
      date: DateTime(2026, 9, 29),
      rate: 33.568,
      base: 'USD',
      quote: 'THB',
    ),
    RatePointModel(
      date: DateTime(2026, 10, 15),
      rate: 33.551,
      base: 'USD',
      quote: 'THB',
    ),
    RatePointModel(
      date: DateTime(2026, 10, 29),
      rate: 33.750,
      base: 'USD',
      quote: 'THB',
    ),
  ];

  group('ExchangeRateRepositoryImpl', () {
    test(
      'TC-6.1: getTrend: should call remote, cache data, and return Right(ExchangeRateTrend) on Cache Miss',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedRates(any())).thenReturn(null);
        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => tMockPoints);
        when(() => mockLocalDataSource.cacheRates(any(), any())).thenReturn(null);

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isRight, isTrue);
        result.fold(
          (failure) => fail('Expected Right(ExchangeRateTrend) but got Left($failure)'),
          (trend) {
            expect(trend.changePercentage, 0.54);
            expect(trend.trendDirection, TrendDirection.up);
            expect(trend.maxRate, 33.750);
            expect(trend.minRate, 33.551);
            expect(trend.days, 30);
            expect(trend.points.length, 3);
          },
        );
        verify(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).called(1);
        verify(() => mockLocalDataSource.cacheRates(any(), tMockPoints)).called(1);
      },
    );

    test(
      'TC-6.2: getTrend: should return Right from Cache without calling RemoteDataSource on Cache Hit',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedRates(any())).thenReturn(tMockPoints);

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isRight, isTrue);
        result.fold(
          (failure) => fail('Expected Right from cache but got Left($failure)'),
          (trend) {
            expect(trend.changePercentage, 0.54);
            expect(trend.points.length, 3);
          },
        );
        verify(() => mockLocalDataSource.getCachedRates(any())).called(1);
        verifyZeroInteractions(mockRemoteDataSource);
      },
    );

    test(
      'TC-6.3: getTrend: should demonstrate period switching flow (30d Remote -> 7d Remote -> 30d Cache Hit)',
      () async {
        // Arrange: In-memory store simulation
        final cacheStorage = <String, List<RatePointModel>>{};

        when(() => mockLocalDataSource.getCachedRates(any())).thenAnswer((invocation) {
          final key = invocation.positionalArguments[0] as String;
          return cacheStorage[key];
        });

        when(() => mockLocalDataSource.cacheRates(any(), any())).thenAnswer((invocation) {
          final key = invocation.positionalArguments[0] as String;
          final data = invocation.positionalArguments[1] as List<RatePointModel>;
          cacheStorage[key] = data;
        });

        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => tMockPoints);

        // 1. Call 30 days (Cache Miss -> Remote called)
        final res30First = await repository.getTrend(pair: tPair, days: 30);
        expect(res30First.isRight, isTrue);

        // 2. Call 7 days (Cache Miss -> Remote called)
        final res7 = await repository.getTrend(pair: tPair, days: 7);
        expect(res7.isRight, isTrue);

        // 3. Call 30 days again (Cache Hit -> Remote NOT called)
        final res30Second = await repository.getTrend(pair: tPair, days: 30);
        expect(res30Second.isRight, isTrue);

        // Assert: Remote should only be invoked 2 times total
        verify(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).called(2);
      },
    );

    test(
      'TC-6.4: getTrend: should return Left(NetworkFailure) when RemoteDataSource throws NetworkException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedRates(any())).thenReturn(null);
        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenThrow(const NetworkException('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'));

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isLeft, isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<NetworkFailure>());
            expect(failure.message, 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
          },
          (r) => fail('Expected Left(NetworkFailure) but got Right'),
        );
      },
    );

    test(
      'TC-6.5: getTrend: should return Left(ServerFailure) when RemoteDataSource throws ServerException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedRates(any())).thenReturn(null);
        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenThrow(const ServerException('เกิดข้อผิดพลาดจากเซิร์ฟเวอร์'));

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isLeft, isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (r) => fail('Expected Left(ServerFailure) but got Right'),
        );
      },
    );

    test(
      'TC-6.6: getTrend: should return Left(EmptyDataFailure) when RemoteDataSource throws EmptyDataException',
      () async {
        // Arrange (BR-6)
        when(() => mockLocalDataSource.getCachedRates(any())).thenReturn(null);
        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenThrow(const EmptyDataException('ไม่มีข้อมูลในช่วงนี้'));

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isLeft, isTrue);
        result.fold(
          (failure) => expect(failure, isA<EmptyDataFailure>()),
          (r) => fail('Expected Left(EmptyDataFailure) but got Right'),
        );
      },
    );

    test(
      'TC-6.7: getTrend: should gracefully fallback to RemoteDataSource if LocalDataSource throws CacheException',
      () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedRates(any())).thenThrow(
          const CacheException('เกิดข้อผิดพลาดในการเข้าถึงแคช'),
        );
        when(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => tMockPoints);
        when(() => mockLocalDataSource.cacheRates(any(), any())).thenReturn(null);

        // Act
        final result = await repository.getTrend(pair: tPair, days: 30);

        // Assert
        expect(result.isRight, isTrue);
        verify(
          () => mockRemoteDataSource.getRates(
            pair: any(named: 'pair'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).called(1);
      },
    );
  });
}
