import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/providers/exchange_rate_provider.dart';
import 'package:exchange_rate_trend/features/exchange_rate/presentation/providers/exchange_rate_state.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  late MockGetExchangeRateTrendUseCase mockGetExchangeRateTrendUseCase;
  late ExchangeRateNotifier notifier;

  setUpAll(() {
    registerTestFallbacks();
  });

  setUp(() {
    mockGetExchangeRateTrendUseCase = MockGetExchangeRateTrendUseCase();
    notifier = ExchangeRateNotifier(
      getExchangeRateTrendUseCase: mockGetExchangeRateTrendUseCase,
    );
  });

  group('ExchangeRateNotifier (TC-Unit-2)', () {
    test('TC-Unit-2.1: initial state: should have default pair USD/THB, 30 days and initial status', () {
      // Assert: ตรวจสอบค่าเริ่มต้นของ State
      expect(notifier.state.status, ExchangeRateStatus.initial);
      expect(notifier.state.pair, CurrencyPair.defaultPair);
      expect(notifier.state.selectedDays, 30);
      expect(notifier.state.trend, isNull);
      expect(notifier.state.selectedPoint, isNull);
      expect(notifier.state.errorMessage, isNull);
    });

    test('TC-Unit-2.2: loadTrend: should transition from loading to success with trend data', () async {
      // Given: UseCase คืนค่าข้อมูลแนวโน้ม 30 วันสำเร็จ
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

      // When: เรียก loadTrend
      final future = notifier.loadTrend();

      // Assert: ระหว่างที่กำลังโหลด สถานะต้องเป็น loading
      expect(notifier.state.status, ExchangeRateStatus.loading);

      await future;

      // Assert: เมื่อเสร็จสิ้น สถานะต้องเป็น success และมีข้อมูล trend ครบถ้วน
      expect(notifier.state.status, ExchangeRateStatus.success);
      expect(notifier.state.trend, fixtureTrendSuccess30Days);
      expect(notifier.state.selectedPoint, isNull);
      expect(notifier.state.errorMessage, isNull);
      verify(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: CurrencyPair.defaultPair,
          days: 30,
        ),
      ).called(1);
    });

    test('TC-Unit-2.3: loadTrend: should transition to empty state when UseCase returns EmptyDataFailure', () async {
      // Given: UseCase คืนค่า EmptyDataFailure (BR-6)
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(fixtureEmptyFailure));

      // When: เรียก loadTrend
      await notifier.loadTrend();

      // Assert: สถานะต้องเป็น empty พร้อมข้อความแจ้งเตือน
      expect(notifier.state.status, ExchangeRateStatus.empty);
      expect(notifier.state.errorMessage, 'ไม่มีข้อมูลในช่วงนี้');
      expect(notifier.state.trend, isNull);
    });

    test('TC-Unit-2.4: loadTrend: should transition to error state when UseCase returns NetworkFailure', () async {
      // Given: UseCase คืนค่า NetworkFailure
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(fixtureNetworkFailure));

      // When: เรียก loadTrend
      await notifier.loadTrend();

      // Assert: สถานะต้องเป็น error พร้อมข้อความเน็ตเวิร์ก
      expect(notifier.state.status, ExchangeRateStatus.error);
      expect(notifier.state.errorMessage, 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');
      expect(notifier.state.trend, isNull);
    });

    test('TC-Unit-2.5: loadTrend: should transition to error state when UseCase returns ServerFailure', () async {
      // Given: UseCase คืนค่า ServerFailure
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: any(named: 'days'),
        ),
      ).thenAnswer((_) async => const Left(fixtureServerFailure));

      // When: เรียก loadTrend
      await notifier.loadTrend();

      // Assert: สถานะต้องเป็น error พร้อมข้อความเซิร์ฟเวอร์
      expect(notifier.state.status, ExchangeRateStatus.error);
      expect(notifier.state.errorMessage, 'ดึงข้อมูลไม่สำเร็จ');
      expect(notifier.state.trend, isNull);
    });

    test('TC-Unit-2.6: changePeriod: should update selectedDays and trigger loadTrend for new period', () async {
      // Given: UseCase คืนค่าสำเร็จสำหรับ 7 วัน
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 7,
        ),
      ).thenAnswer((_) async => Right(fixtureTrendSuccess7Days));

      // When: ผู้ใช้สลับช่วงเวลาเป็น 7 วัน
      notifier.changePeriod(7);

      // Assert: สถานะต้องเปลี่ยนเป็น 7 วันและข้อมูลอัปเดต
      await pumpEventQueue();
      expect(notifier.state.selectedDays, 7);
      expect(notifier.state.status, ExchangeRateStatus.success);
      expect(notifier.state.trend, fixtureTrendSuccess7Days);
      verify(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: CurrencyPair.defaultPair,
          days: 7,
        ),
      ).called(1);
    });

    test('TC-Unit-2.7: changePeriod: should ignore request when state is currently loading', () async {
      // Given: การโหลดรอบแรกยังค้างอยู่ด้วย Completer
      final completer = Completer<Either<Failure, ExchangeRateTrend>>();
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 30,
        ),
      ).thenAnswer((_) => completer.future);

      notifier.loadTrend();
      expect(notifier.state.status, ExchangeRateStatus.loading);

      // When: พยายามกดเปลี่ยนช่วงเวลาเป็น 90 วันขณะสถานะยังเป็น loading
      notifier.changePeriod(90);

      // Assert: ต้องไม่มีการยิง UseCase สำหรับ 90 วัน
      verifyNever(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 90,
        ),
      );

      // ทำความสะอาด Future ให้จบ
      completer.complete(Right(fixtureTrendSuccess30Days));
      await pumpEventQueue();
    });

    test('TC-Unit-2.8: changePeriod: should ignore request when selecting identical period with success state', () async {
      // Given: โหลดข้อมูล 30 วันสำเร็จแล้ว
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 30,
        ),
      ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

      await notifier.loadTrend();
      expect(notifier.state.status, ExchangeRateStatus.success);
      expect(notifier.state.selectedDays, 30);
      clearInteractions(mockGetExchangeRateTrendUseCase);

      // When: กดเลือก 30 วันซ้ำอีกรอบ
      notifier.changePeriod(30);

      // Assert: ไม่มีการเรียก UseCase ซ้ำ
      verifyZeroInteractions(mockGetExchangeRateTrendUseCase);
    });

    test('TC-Unit-2.9: selectPoint: should update selectedPoint in state without modifying trend', () async {
      // Given: มีข้อมูลแนวโน้มสำเร็จอยู่ใน State
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 30,
        ),
      ).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

      await notifier.loadTrend();
      final pointToSelect = fixtureRatePoints30Days[1]; // 10 ต.ค.

      // When: ผู้ใช้แตะเลือกจุดบนกราฟ
      notifier.selectPoint(pointToSelect);

      // Assert: selectedPoint ใน state อัปเดต และ trend ยังคงเดิม
      expect(notifier.state.selectedPoint, pointToSelect);
      expect(notifier.state.trend, fixtureTrendSuccess30Days);
    });

    test(
      'TC-Unit-2.10: selectPoint: should allow resetting selectedPoint to null',
      () {
        // Given: มีจุดเลือกอยู่
        final pointToSelect = fixtureRatePoints30Days[1];
        notifier.selectPoint(pointToSelect);
        expect(notifier.state.selectedPoint, isNotNull);

        // When: ยกเลิกการเลือกจุดด้วยการส่ง null
        notifier.selectPoint(null);

        // Assert: selectedPoint กลับเป็น null
        expect(notifier.state.selectedPoint, isNull);
      },
    );

    test('TC-Unit-2.11: retry: should invoke loadTrend with current pair and selectedDays', () async {
      // Given: State อยู่ในสถานะ error ที่ 90 วัน
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 90,
        ),
      ).thenAnswer((_) async => const Left(fixtureNetworkFailure));

      await notifier.loadTrend(days: 90);
      expect(notifier.state.status, ExchangeRateStatus.error);
      expect(notifier.state.selectedDays, 90);

      // ตั้งค่าให้ครั้งถัดไปสำเร็จ
      when(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: any(named: 'pair'),
          days: 90,
        ),
      ).thenAnswer((_) async => Right(fixtureTrendSuccess90Days));

      // When: ผู้ใช้กด Retry
      notifier.retry();
      await pumpEventQueue();

      // Assert: UseCase ถูกเรียกซ้ำด้วย 90 วัน และสถานะกลายเป็น success
      expect(notifier.state.status, ExchangeRateStatus.success);
      expect(notifier.state.trend, fixtureTrendSuccess90Days);
      verify(
        () => mockGetExchangeRateTrendUseCase.call(
          pair: CurrencyPair.defaultPair,
          days: 90,
        ),
      ).called(2);
    });
  });
}
