import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/core/utils/trend_calculator.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';

void main() {
  group('TrendCalculator', () {
    group('calculateChangePercentage', () {
      test(
        'TC-1.1: calculateChangePercentage: should return +0.54 for AC-2 benchmark (33.568 -> 33.750)',
        () {
          // Act
          final result = TrendCalculator.calculateChangePercentage(
            firstRate: 33.568,
            lastRate: 33.750,
          );

          // Assert
          expect(result, 0.54);
        },
      );

      test(
        'TC-1.2: calculateChangePercentage: should return negative percentage for downward trend',
        () {
          // Act
          final result = TrendCalculator.calculateChangePercentage(
            firstRate: 35.0,
            lastRate: 33.25,
          );

          // Assert
          expect(result, -5.00);
        },
      );

      test(
        'TC-1.3: calculateChangePercentage: should return 0.00 when rates are identical',
        () {
          // Act
          final result = TrendCalculator.calculateChangePercentage(
            firstRate: 33.500,
            lastRate: 33.500,
          );

          // Assert
          expect(result, 0.0);
        },
      );

      test(
        'TC-1.4: calculateChangePercentage: should handle zero firstRate safely without divide by zero',
        () {
          // Act
          final result = TrendCalculator.calculateChangePercentage(
            firstRate: 0.0,
            lastRate: 33.500,
          );

          // Assert
          expect(result, 0.0);
        },
      );

      test(
        'TC-1.5: calculateChangePercentage: should round strictly to 2 decimal places',
        () {
          // Act: ((33.5678 - 33.1234) / 33.1234) * 100 = 1.341649... -> 1.34
          final result = TrendCalculator.calculateChangePercentage(
            firstRate: 33.1234,
            lastRate: 33.5678,
          );

          // Assert
          expect(result, 1.34);
        },
      );
    });

    group('resolveTrendDirection', () {
      test(
        'TC-1.6: resolveTrendDirection: should return TrendDirection.up when change is positive',
        () {
          // Act
          final direction = TrendCalculator.resolveTrendDirection(0.54);

          // Assert
          expect(direction, TrendDirection.up);
        },
      );

      test(
        'TC-1.7: resolveTrendDirection: should return TrendDirection.down when change is negative',
        () {
          // Act
          final direction = TrendCalculator.resolveTrendDirection(-1.25);

          // Assert
          expect(direction, TrendDirection.down);
        },
      );

      test(
        'TC-1.8: resolveTrendDirection: should return TrendDirection.neutral when change is zero',
        () {
          // Act
          final direction = TrendCalculator.resolveTrendDirection(0.0);

          // Assert
          expect(direction, TrendDirection.neutral);
        },
      );
    });

    group('findMaxRate & findMinRate', () {
      final samplePoints = [
        RatePoint(
          date: DateTime(2026, 9, 29),
          rate: 33.551,
          base: 'USD',
          quote: 'THB',
        ),
        RatePoint(
          date: DateTime(2026, 9, 30),
          rate: 33.750,
          base: 'USD',
          quote: 'THB',
        ),
        RatePoint(
          date: DateTime(2026, 10, 1),
          rate: 33.568,
          base: 'USD',
          quote: 'THB',
        ),
      ];

      test('TC-1.9: findMaxRate: should return the highest rate in the points list', () {
        // Act
        final max = TrendCalculator.findMaxRate(samplePoints);

        // Assert
        expect(max, 33.750);
      });

      test('TC-1.10: findMinRate: should return the lowest rate in the points list', () {
        // Act
        final min = TrendCalculator.findMinRate(samplePoints);

        // Assert
        expect(min, 33.551);
      });

      test('TC-1.11: findMaxRate & findMinRate: should return 0.0 when points list is empty', () {
        // Act & Assert
        expect(TrendCalculator.findMaxRate([]), 0.0);
        expect(TrendCalculator.findMinRate([]), 0.0);
      });
    });
  });
}
