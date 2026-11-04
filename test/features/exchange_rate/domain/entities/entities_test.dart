import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';

void main() {
  group('Domain Entities Equality', () {
    test('CurrencyPair equality and defaultPair', () {
      const pair1 = CurrencyPair(base: 'USD', quote: 'THB');
      const pair2 = CurrencyPair(base: 'USD', quote: 'THB');
      const pair3 = CurrencyPair(base: 'EUR', quote: 'THB');

      expect(pair1, equals(pair2));
      expect(pair1, isNot(equals(pair3)));
      expect(CurrencyPair.defaultPair, equals(pair1));
    });

    test('ExchangeRateTrend equality', () {
      final now = DateTime(2026, 11, 4);
      final trend1 = ExchangeRateTrend(
        pair: const CurrencyPair(base: 'USD', quote: 'THB'),
        days: 30,
        points: [
          RatePoint(date: now, rate: 33.5, base: 'USD', quote: 'THB'),
        ],
        maxRate: 33.5,
        minRate: 33.5,
        changePercentage: 0.0,
        trendDirection: TrendDirection.neutral,
      );
      final trend2 = ExchangeRateTrend(
        pair: const CurrencyPair(base: 'USD', quote: 'THB'),
        days: 30,
        points: [
          RatePoint(date: now, rate: 33.5, base: 'USD', quote: 'THB'),
        ],
        maxRate: 33.5,
        minRate: 33.5,
        changePercentage: 0.0,
        trendDirection: TrendDirection.neutral,
      );

      expect(trend1, equals(trend2));
      expect(trend1.props, equals(trend2.props));
    });
  });
}
