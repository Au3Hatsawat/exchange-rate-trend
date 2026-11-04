import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/providers/exchange_rate_provider.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetExchangeRateTrendUseCase mockUseCase;

  setUpAll(() {
    registerTestFallbacks();
  });

  setUp(() {
    mockUseCase = MockGetExchangeRateTrendUseCase();
  });

  Widget buildTestableScreen({List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: [
        getExchangeRateTrendUseCaseProvider.overrideWithValue(mockUseCase),
        ...overrides,
      ],
      child: const MaterialApp(home: ExchangeRateTrendScreen()),
    );
  }

  group('ExchangeRateTrendScreen (TC-Screen-1)', () {
    testWidgets(
      'TC-Screen-1.1: AC-1 & AC-2: renders full success screen (15-1) with chart, stat cards and +0.54% badge',
      (tester) async {
        // Given: UseCase คืนค่า fixture 30 วันสำเร็จ
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

        // When: ปั๊มหน้าจอ ExchangeRateTrendScreen
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Assert: ตรวจสอบองค์ประกอบตาม AC-1 และ AC-2
        expect(find.text('แนวโน้มอัตรา'), findsOneWidget); // AppBar (Figma EL-0c3cf6b7)
        expect(find.text('คู่สกุล'), findsOneWidget); // Currency Selector Label
        expect(find.text('USD → THB'), findsOneWidget); // Currency Selector
        expect(find.text('30 วัน'), findsOneWidget); // Period tab
        expect(find.text('+0.54%'), findsOneWidget); // AC-2 Benchmark %
        expect(find.text('สูงขึ้น'), findsOneWidget); // Level Badge
        expect(find.text('33.750'), findsOneWidget); // Max Stat Card
        expect(find.text('33.568'), findsOneWidget); // Min Stat Card
        expect(
          find.text('อัตราแลกเปลี่ยนจาก Frankfurter (frankfurter.dev)'),
          findsOneWidget,
        ); // Source note
      },
    );

    testWidgets(
      'TC-Screen-1.2: Screen 15-1b: displays LoadingStateWidget while fetching trend data',
      (tester) async {
        // Given: การดึงข้อมูลยังไม่เสร็จ (ค้างไว้ใน Completer)
        final completer = Completer<Either<Failure, ExchangeRateTrend>>();
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) => completer.future);

        // When: ปั๊มหน้าจอ
        await tester.pumpWidget(buildTestableScreen());
        await tester.pump(); // ขยับ 1 เฟรมแต่ยังไม่ settle

        // Assert: แสดงสถานะ Loading (Spinner และข้อความกำลังโหลด)
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('กำลังโหลดข้อมูล...'), findsOneWidget);

        // ทำความสะอาด future
        completer.complete(Right(fixtureTrendSuccess30Days));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'TC-Screen-1.3: Screen 15-1c: displays EmptyStateWidget when API returns EmptyDataFailure',
      (tester) async {
        // Given: UseCase คืนค่า EmptyDataFailure (BR-6)
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => const Left(fixtureEmptyFailure));

        // When: ปั๊มหน้าจอจนเสร็จ
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Assert: แสดง Empty State พร้อมไอคอนและข้อความ "ไม่มีข้อมูลในช่วงนี้"
        expect(find.text('ไม่มีข้อมูลในช่วงนี้'), findsOneWidget);
        expect(find.byIcon(Icons.bar_chart_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Screen-1.4: Screen 15-1d: displays ErrorStateWidget and retries successfully when tapping retry',
      (tester) async {
        // Given: ครั้งแรกเกิด Network Error
        var callCount = 0;
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return const Left(fixtureNetworkFailure);
          }
          return Right(fixtureTrendSuccess30Days);
        });

        // When: ปั๊มหน้าจอครั้งแรก
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Assert: แสดง Error State พร้อมปุ่ม "ลองอีกครั้ง"
        expect(find.text('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'), findsOneWidget);
        expect(find.text('ลองอีกครั้ง'), findsOneWidget);

        // When: แตะปุ่มลองอีกครั้ง
        await tester.tap(find.text('ลองอีกครั้ง'));
        await tester.pumpAndSettle();

        // Assert: สลับกลับมาแสดงผลสำเร็จตาม AC-1
        expect(find.text('+0.54%'), findsOneWidget);
        expect(find.text('33.750'), findsOneWidget);
      },
    );

    testWidgets(
      'TC-Screen-1.5: AC-3 & Screen 15-1a: selecting a chart point displays DatePointDetailRow with "10 ต.ค. · 33.570" and "THB"',
      (tester) async {
        // Given: โหลดข้อมูล 30 วันสำเร็จ
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // When: สั่งให้ StateNotifier เลือกจุด 10 ต.ค. (AC-3 Benchmark)
        final element = tester.element(find.byType(ExchangeRateTrendScreen));
        final container = ProviderScope.containerOf(element);
        container
            .read(exchangeRateNotifierProvider.notifier)
            .selectPoint(fixtureRatePoints30Days[1]);

        await tester.pumpAndSettle();

        // Assert: ปรากฏแถวข้อมูล Screen 15-1a แสดงวันที่ 10 ต.ค., เรต 33.570 และ THB
        expect(find.textContaining('10 ต.ค.'), findsOneWidget);
        expect(find.text('33.570'), findsOneWidget);
        expect(find.text('THB'), findsOneWidget);
        // ตรวจว่าในโหมด 15-1a สลับซ่อน Stat Cards ตาม Figma 1:459
        expect(find.text('สูงสุด'), findsNothing);
        expect(find.text('ต่ำสุด'), findsNothing);
      },
    );

    testWidgets(
      'TC-Screen-1.6: Responsive: renders cleanly on handheld (360x780) and constrains to max 600px centered on tablet (834x1194)',
      (tester) async {
        when(
          () => mockUseCase.call(
            pair: any(named: 'pair'),
            days: any(named: 'days'),
          ),
        ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

        // 1. ทดสอบบน Handheld Mobile (360 × 780)
        tester.view.physicalSize = const Size(360, 780);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Assert: ไม่มี RenderFlex Overflow ข้อผิดพลาดใด ๆ
        expect(tester.takeException(), isNull);

        // 2. ทดสอบบน Tablet Portrait (834 × 1194)
        tester.view.physicalSize = const Size(834, 1194);
        await tester.pumpWidget(buildTestableScreen());
        await tester.pumpAndSettle();

        // Assert: กล่องเนื้อหาถูกจำกัด maxWidth ไว้ที่ 600.0
        final constrainedBoxFinder = find.byWidgetPredicate(
          (widget) =>
              widget is ConstrainedBox && widget.constraints.maxWidth == 600.0,
        );
        expect(constrainedBoxFinder, findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
