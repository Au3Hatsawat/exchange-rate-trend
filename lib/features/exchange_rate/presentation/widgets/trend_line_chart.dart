import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/rate_point.dart';

class TrendLineChart extends StatelessWidget {
  final List<RatePoint> points;
  final double minRate;
  final double maxRate;
  final RatePoint? selectedPoint;
  final ValueChanged<RatePoint?> onPointSelected;

  const TrendLineChart({
    super.key,
    required this.points,
    required this.minRate,
    required this.maxRate,
    this.selectedPoint,
    required this.onPointSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.rate);
    }).toList();

    // หา index ของ selectedPoint (ถ้ามี)
    final selectedIndex = selectedPoint != null
        ? points.indexWhere((p) => p.date == selectedPoint!.date)
        : -1;

    final yRange = (maxRate - minRate).abs();
    final midRate = (minRate + maxRate) / 2.0;
    final interval = yRange > 0 ? yRange / 2.0 : 1.0;

    return Container(
      height: 230.0,
      padding: const EdgeInsets.fromLTRB(12.0, 20.0, 20.0, 12.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: LineChart(
        LineChartData(
          minX: 0.0,
          maxX: (points.length - 1).toDouble(),
          minY: minRate,
          maxY: maxRate,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                    if (touchResponse != null &&
                        touchResponse.lineBarSpots != null &&
                        touchResponse.lineBarSpots!.isNotEmpty) {
                      final spotIndex =
                          touchResponse.lineBarSpots!.first.spotIndex;
                      if (spotIndex >= 0 && spotIndex < points.length) {
                        onPointSelected(points[spotIndex]);
                      }
                    }
                  }
                },
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.borderDefault,
              strokeWidth: 1.0,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46.0,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if ((value - minRate).abs() < 0.005) {
                    return Text(
                      minRate.toStringAsFixed(2),
                      style: AppTypography.bodySmall,
                    );
                  } else if ((value - midRate).abs() < 0.005) {
                    return Text(
                      midRate.toStringAsFixed(2),
                      style: AppTypography.bodySmall,
                    );
                  } else if ((value - maxRate).abs() < 0.005) {
                    return Text(
                      maxRate.toStringAsFixed(2),
                      style: AppTypography.bodySmall,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28.0,
                interval: 1.0,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  final firstIdx = 0;
                  final midIdx = points.length ~/ 2;
                  final lastIdx = points.length - 1;

                  if (index == firstIdx ||
                      index == midIdx ||
                      index == lastIdx) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormatter.formatThaiShortDate(points[index].date),
                        style: AppTypography.bodySmall,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: AppColors.brandPrimary,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  return selectedIndex != -1 && spot.x.toInt() == selectedIndex;
                },
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5.5,
                    color: AppColors.bgSurface,
                    strokeWidth: 3.0,
                    strokeColor: AppColors.brandPrimary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color.fromRGBO(36, 80, 208, 0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
