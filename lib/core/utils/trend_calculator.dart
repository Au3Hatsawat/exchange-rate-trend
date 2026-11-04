import '../../features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import '../../features/exchange_rate/domain/entities/rate_point.dart';

class TrendCalculator {
  static double calculateChangePercentage({
    required double firstRate,
    required double lastRate,
  }) {
    if (firstRate == 0) return 0.0;
    final change = ((lastRate - firstRate) / firstRate) * 100.0;
    final parsed = double.parse(change.toStringAsFixed(2));
    return parsed == 0.0 ? 0.0 : parsed;
  }

  static TrendDirection resolveTrendDirection(double changePercentage) {
    if (changePercentage > 0) return TrendDirection.up;
    if (changePercentage < 0) return TrendDirection.down;
    return TrendDirection.neutral;
  }

  static double findMaxRate(List<RatePoint> points) {
    if (points.isEmpty) return 0.0;
    return points.map((p) => p.rate).reduce((a, b) => a > b ? a : b);
  }

  static double findMinRate(List<RatePoint> points) {
    if (points.isEmpty) return 0.0;
    return points.map((p) => p.rate).reduce((a, b) => a < b ? a : b);
  }
}
