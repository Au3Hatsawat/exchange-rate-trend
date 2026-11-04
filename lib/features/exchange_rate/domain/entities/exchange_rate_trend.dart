import 'package:equatable/equatable.dart';
import 'currency_pair.dart';
import 'rate_point.dart';

enum TrendDirection {
  up,
  down,
  neutral,
}

class ExchangeRateTrend extends Equatable {
  final CurrencyPair pair;
  final int days;
  final List<RatePoint> points;
  final double maxRate;
  final double minRate;
  final double changePercentage;
  final TrendDirection trendDirection;

  const ExchangeRateTrend({
    required this.pair,
    required this.days,
    required this.points,
    required this.maxRate,
    required this.minRate,
    required this.changePercentage,
    required this.trendDirection,
  });

  double? get firstRate => points.isNotEmpty ? points.first.rate : null;
  double? get lastRate => points.isNotEmpty ? points.last.rate : null;

  @override
  List<Object?> get props => [
        pair,
        days,
        points,
        maxRate,
        minRate,
        changePercentage,
        trendDirection,
      ];
}
