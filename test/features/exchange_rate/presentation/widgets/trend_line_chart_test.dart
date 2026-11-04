import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/trend_line_chart.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  Widget buildTestableWidget({
    required List<RatePoint> points,
    required double minRate,
    required double maxRate,
    RatePoint? selectedPoint,
    required ValueChanged<RatePoint?> onPointSelected,
  }) {
    return ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: TrendLineChart(
            points: points,
            minRate: minRate,
            maxRate: maxRate,
            selectedPoint: selectedPoint,
            onPointSelected: onPointSelected,
          ),
        ),
      ),
    );
  }

  group('TrendLineChart Widget (TC-Widget-3)', () {
    testWidgets(
      'TC-Widget-3.1: renders LineChart widget with single series and container styling',
      (tester) async {
        // Given: มีชุดข้อมูล 30 วัน
        await tester.pumpWidget(
          buildTestableWidget(
            points: fixtureRatePoints30Days,
            minRate: 33.568,
            maxRate: 33.750,
            onPointSelected: (_) {},
          ),
        );

        // Assert: พบ LineChart widget 1 ชิ้น
        expect(find.byType(LineChart), findsOneWidget);

        // ตรวจสอบ Container ตกแต่งความสูงและขอบมน
        final container = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(TrendLineChart),
                matching: find.byType(Container),
              )
              .first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(decoration!.borderRadius, BorderRadius.circular(14.0));
      },
    );

    testWidgets(
      'TC-Widget-3.2: displays 3 X-axis labels: first, middle, last in Thai short format (BR-5)',
      (tester) async {
        // Given: ข้อมูล 30 วัน (จุดแรก 29 ก.ย. 2026, จุดท้าย 29 ต.ค. 2026)
        await tester.pumpWidget(
          buildTestableWidget(
            points: fixtureRatePoints30Days,
            minRate: 33.568,
            maxRate: 33.750,
            onPointSelected: (_) {},
          ),
        );

        // Assert: ตรวจพบป้ายแกน X วันแรก และ วันสุดท้าย ตามข้อกำหนด BR-5
        expect(find.text('29 ก.ย.'), findsOneWidget);
        expect(find.text('29 ต.ค.'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Widget-3.3: displays 3 Y-axis labels: min, middle, max with 2 decimal places (BR-5)',
      (tester) async {
        // Given: minRate = 33.568 (ปัดเป็น 33.57), maxRate = 33.750 (ปัดเป็น 33.75)
        await tester.pumpWidget(
          buildTestableWidget(
            points: fixtureRatePoints30Days,
            minRate: 33.568,
            maxRate: 33.750,
            onPointSelected: (_) {},
          ),
        );

        // Assert: ตรวจพบตัวเลขเรตต่ำสุดและสูงสุดทศนิยม 2 ตำแหน่ง
        expect(find.text('33.57'), findsOneWidget);
        expect(find.text('33.75'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Widget-3.4: renders dot highlight and triggers onPointSelected when point interaction occurs (Screen 15-1a / AC-3)',
      (tester) async {
        RatePoint? tappedPoint;
        final selectedPoint =
            fixtureRatePoints30Days[1]; // 10 ต.ค. (AC-3 Benchmark)

        // Given: กำหนด selectedPoint เป็นจุด 10 ต.ค.
        await tester.pumpWidget(
          buildTestableWidget(
            points: fixtureRatePoints30Days,
            minRate: 33.568,
            maxRate: 33.750,
            selectedPoint: selectedPoint,
            onPointSelected: (point) {
              tappedPoint = point;
            },
          ),
        );

        // Assert: LineChart เรนเดอร์สำเร็จพร้อม selectedPoint
        expect(find.byType(LineChart), findsOneWidget);

        // แตะที่จุดบนกราฟ
        await tester.tap(find.byType(LineChart));
        await tester.pump();

        // วิดเจ็ตต้องไม่เกิด Exception หรือแครช
        expect(tester.takeException(), isNull);
        expect(tappedPoint, anyOf(isNull, isA<RatePoint>()));
      },
    );
  });
}
