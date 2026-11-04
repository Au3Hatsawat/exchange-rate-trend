import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart';
import 'package:exchange_rate_trend/features/exchange_rate/data/models/rate_point_model.dart';

void main() {
  late ExchangeRateLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = ExchangeRateLocalDataSourceImpl();
  });

  final tRatePoints = [
    RatePointModel(
      date: DateTime(2026, 11, 4),
      rate: 33.750,
      base: 'USD',
      quote: 'THB',
    ),
  ];

  group('ExchangeRateLocalDataSource', () {
    test('TC-5.1: getCachedRates: should return null when cache key does not exist', () {
      // Act
      final result = dataSource.getCachedRates('USD_THB_30_2026-11-04');

      // Assert
      expect(result, isNull);
    });

    test('TC-5.2: cacheRates & getCachedRates: should save and retrieve cached rates correctly', () {
      // Arrange
      const cacheKey = 'USD_THB_30_2026-11-04';

      // Act
      dataSource.cacheRates(cacheKey, tRatePoints);
      final result = dataSource.getCachedRates(cacheKey);

      // Assert
      expect(result, equals(tRatePoints));
    });

    test('TC-5.3: cacheRates: should differentiate cache entries by period days', () {
      // Arrange
      const key30 = 'USD_THB_30_2026-11-04';
      const key7 = 'USD_THB_7_2026-11-04';
      final tPoints7 = [
        RatePointModel(
          date: DateTime(2026, 11, 4),
          rate: 33.500,
          base: 'USD',
          quote: 'THB',
        ),
      ];

      // Act
      dataSource.cacheRates(key30, tRatePoints);
      dataSource.cacheRates(key7, tPoints7);

      // Assert
      expect(dataSource.getCachedRates(key30), equals(tRatePoints));
      expect(dataSource.getCachedRates(key7), equals(tPoints7));
      expect(dataSource.getCachedRates(key30), isNot(equals(tPoints7)));
    });

    test('TC-5.4: cacheRates: should naturally invalidate on date change (same-day validity)', () {
      // Arrange
      const keyToday = 'USD_THB_30_2026-11-04';
      const keyTomorrow = 'USD_THB_30_2026-11-05';

      // Act
      dataSource.cacheRates(keyToday, tRatePoints);

      // Assert
      expect(dataSource.getCachedRates(keyToday), equals(tRatePoints));
      expect(dataSource.getCachedRates(keyTomorrow), isNull);
    });

    test('TC-5.5: clearCache: should wipe all entries from memory', () {
      // Arrange
      const key = 'USD_THB_30_2026-11-04';
      dataSource.cacheRates(key, tRatePoints);

      // Act
      dataSource.clearCache();

      // Assert
      expect(dataSource.getCachedRates(key), isNull);
    });
  });
}
