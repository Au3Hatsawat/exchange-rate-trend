import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/stat_card_compact.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/widgets/trend_summary_row.dart';

void main() {
  group('TrendSummaryRow & StatCardCompact Widgets (TC-Widget-4 & 5)', () {
    testWidgets(
      'TC-Widget-4.1: AC-2 Benchmark: TrendSummaryRow renders +0.54% and "สูงขึ้น" badge for upward trend',
      (tester) async {
        // Given: 30 วัน, +0.54%, ทิศทางขาขึ้น (Benchmark AC-2)
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TrendSummaryRow(
                  days: 30,
                  changePercentage: 0.54,
                  direction: TrendDirection.up,
                ),
              ),
            ),
          ),
        );

        // Assert: แสดงข้อความช่วงวัน, ตัวเลขเปอร์เซ็นต์บวก, ป้าย "สูงขึ้น" และไอคอนแนวโน้มขึ้น
        expect(find.text('เปลี่ยนแปลง 30 วัน'), findsOneWidget);
        expect(find.text('+0.54%'), findsOneWidget);
        expect(find.text('สูงขึ้น'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Widget-4.2: TrendSummaryRow renders negative percentage with "ลดลง" badge and 0.00% with "ทรงตัว" badge',
      (tester) async {
        // 1. เคสขาลง: 7 วัน, -0.44%, ทิศทางลดลง
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TrendSummaryRow(
                  days: 7,
                  changePercentage: -0.44,
                  direction: TrendDirection.down,
                ),
              ),
            ),
          ),
        );

        expect(find.text('เปลี่ยนแปลง 7 วัน'), findsOneWidget);
        expect(find.text('-0.44%'), findsOneWidget);
        expect(find.text('ลดลง'), findsOneWidget);
        expect(find.byIcon(Icons.trending_down), findsOneWidget);

        // 2. เคสทรงตัว: 90 วัน, 0.00%, ทิศทางทรงตัว
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TrendSummaryRow(
                  days: 90,
                  changePercentage: 0.00,
                  direction: TrendDirection.neutral,
                ),
              ),
            ),
          ),
        );

        expect(find.text('เปลี่ยนแปลง 90 วัน'), findsOneWidget);
        expect(find.text('0.00%'), findsOneWidget);
        expect(find.text('ทรงตัว'), findsOneWidget);
        expect(find.byIcon(Icons.remove), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Widget-4.3: StatCardCompact renders maximum rate card with 3 decimal places',
      (tester) async {
        // Given: การ์ดค่าสูงสุด เรต 33.750
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: StatCardCompact(label: 'สูงสุด', rate: 33.750),
              ),
            ),
          ),
        );

        // Assert: แสดงผล 'สูงสุด' และ '33.750' ทศนิยม 3 ตำแหน่ง
        expect(find.text('สูงสุด'), findsOneWidget);
        expect(find.text('33.750'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Widget-4.4: StatCardCompact renders minimum rate card with 3 decimal places and handles trailing zeros',
      (tester) async {
        // Given: การ์ดค่าต่ำสุด 33.568 และการ์ดที่มีเลขกลม 34.0
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    StatCardCompact(label: 'ต่ำสุด', rate: 33.568),
                    StatCardCompact(label: 'สูงสุด', rate: 34.0),
                  ],
                ),
              ),
            ),
          ),
        );

        // Assert: แสดง 'ต่ำสุด' '33.568' และเลขกลมต้องเติมศูนย์ครบ 3 ตำแหน่ง '34.000'
        expect(find.text('ต่ำสุด'), findsOneWidget);
        expect(find.text('33.568'), findsOneWidget);
        expect(find.text('34.000'), findsOneWidget);
      },
    );
  });
}
