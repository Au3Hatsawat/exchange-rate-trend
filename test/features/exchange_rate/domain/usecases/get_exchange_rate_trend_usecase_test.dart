import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart';

class MockExchangeRateRepository extends Mock implements ExchangeRateRepository {}

class FakeCurrencyPair extends Fake implements CurrencyPair {}

void main() {
  late MockExchangeRateRepository mockRepository;
  late GetExchangeRateTrendUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeCurrencyPair());
  });

  setUp(() {
    mockRepository = MockExchangeRateRepository();
    useCase = GetExchangeRateTrendUseCase(mockRepository);
  });

  const tPair = CurrencyPair(base: 'USD', quote: 'THB');
  const tDays = 30;
  final tTrend = ExchangeRateTrend(
    pair: tPair,
    days: tDays,
    points: [
      RatePoint(
        date: DateTime(2026, 9, 29),
        rate: 33.568,
        base: 'USD',
        quote: 'THB',
      ),
      RatePoint(
        date: DateTime(2026, 10, 29),
        rate: 33.750,
        base: 'USD',
        quote: 'THB',
      ),
    ],
    maxRate: 33.750,
    minRate: 33.568,
    changePercentage: 0.54,
    trendDirection: TrendDirection.up,
  );

  group('GetExchangeRateTrendUseCase', () {
    test(
      'TC-7.1: call: should forward pair and days to repository and return Right(ExchangeRateTrend)',
      () async {
        // Arrange
        when(
          () => mockRepository.getTrend(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => Right(tTrend));

        // Act
        final result = await useCase(pair: tPair, days: tDays);

        // Assert
        expect(result, equals(Right<Failure, ExchangeRateTrend>(tTrend)));
        verify(() => mockRepository.getTrend(pair: tPair, days: tDays)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'TC-7.2: call: should forward Left(Failure) directly from repository',
      () async {
        // Arrange
        const tFailure = NetworkFailure('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
        when(
          () => mockRepository.getTrend(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => const Left(tFailure));

        // Act
        final result = await useCase(pair: tPair, days: tDays);

        // Assert
        expect(result, equals(const Left<Failure, ExchangeRateTrend>(tFailure)));
        verify(() => mockRepository.getTrend(pair: tPair, days: tDays)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });
}
