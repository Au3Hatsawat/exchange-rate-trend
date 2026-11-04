import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/exchange_rate_provider.dart';
import '../providers/exchange_rate_state.dart';
import '../widgets/currency_selector_card.dart';
import '../widgets/date_point_detail_row.dart';
import '../widgets/period_segmented_control.dart';
import '../widgets/source_note_widget.dart';
import '../widgets/stat_card_compact.dart';
import '../widgets/states/empty_state_widget.dart';
import '../widgets/states/error_state_widget.dart';
import '../widgets/states/loading_state_widget.dart';
import '../widgets/trend_line_chart.dart';
import '../widgets/trend_summary_row.dart';

class ExchangeRateTrendScreen extends ConsumerStatefulWidget {
  const ExchangeRateTrendScreen({super.key});

  @override
  ConsumerState<ExchangeRateTrendScreen> createState() =>
      _ExchangeRateTrendScreenState();
}

class _ExchangeRateTrendScreenState
    extends ConsumerState<ExchangeRateTrendScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exchangeRateNotifierProvider.notifier).loadTrend();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exchangeRateNotifierProvider);
    final notifier = ref.read(exchangeRateNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แนวโน้มอัตรา',
          style: AppTypography.heading,
        ),
        backgroundColor: AppColors.bgSurface,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            color: AppColors.bgSubtle,
          ),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600.0),
            child: RefreshIndicator(
              onRefresh: () => notifier.loadTrend(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FR-2: Currency Selector Card
                    CurrencySelectorCard(
                      pair: state.pair,
                      onTap: () {
                        // เตรียมสำหรับเชื่อมต่อ Screen 15-2 ใน Issue ถัดไป
                      },
                    ),
                    const SizedBox(height: 16.0),

                    // FR-3: Period Segmented Control (7, 30, 90 วัน)
                    PeriodSegmentedControl(
                      selectedDays: state.selectedDays,
                      isLoading: state.status == ExchangeRateStatus.loading,
                      onPeriodSelected: (days) => notifier.changePeriod(days),
                    ),
                    const SizedBox(height: 16.0),

                    // FR-8 / 4 Screen States Switcher
                    _buildStateContent(state, notifier),
                    const SizedBox(height: 24.0),

                    // FR-8 (AC-6): Source Note
                    const SourceNoteWidget(),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateContent(
    ExchangeRateState state,
    ExchangeRateNotifier notifier,
  ) {
    switch (state.status) {
      case ExchangeRateStatus.initial:
      case ExchangeRateStatus.loading:
        return const LoadingStateWidget();

      case ExchangeRateStatus.empty:
        return EmptyStateWidget(
          message: state.errorMessage ?? 'ไม่มีข้อมูลในช่วงนี้',
        );

      case ExchangeRateStatus.error:
        return ErrorStateWidget(
          message: state.errorMessage ?? 'ดึงข้อมูลไม่สำเร็จ',
          onRetry: () => notifier.retry(),
        );

      case ExchangeRateStatus.success:
        final trend = state.trend!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // FR-4 & FR-7: Line Chart
            TrendLineChart(
              points: trend.points,
              minRate: trend.minRate,
              maxRate: trend.maxRate,
              selectedPoint: state.selectedPoint,
              onPointSelected: (point) => notifier.selectPoint(point),
            ),
            const SizedBox(height: 16.0),

            // FR-7 (Screen 15-1a): เมื่อแตะจุดบนกราฟ จะสลับมาแสดง Data Row ของจุดที่แตะแทน Stat Row และ Level Badge ตาม Figma 1:459
            if (state.selectedPoint != null) ...[
              DatePointDetailRow(point: state.selectedPoint!),
            ] else ...[
              // Screen 15-1: 2 Stat Cards แนวนอน (สูงสุด / ต่ำสุด)
              Row(
                children: [
                  Expanded(
                    child: StatCardCompact(label: 'สูงสุด', rate: trend.maxRate),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: StatCardCompact(label: 'ต่ำสุด', rate: trend.minRate),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Screen 15-1: Trend Summary Data Row + Level Badge
              TrendSummaryRow(
                days: state.selectedDays,
                changePercentage: trend.changePercentage,
                direction: trend.trendDirection,
                firstRate: trend.firstRate,
                lastRate: trend.lastRate,
              ),
            ],
          ],
        );
    }
  }
}
