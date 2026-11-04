import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/core/errors/failures.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/exchange_rate_trend.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/rate_point.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart';

/// Mock สำหรับ UseCase (ใช้ใน Presentation Widget Tests และ StateNotifier Tests)
class MockGetExchangeRateTrendUseCase extends Mock
    implements GetExchangeRateTrendUseCase {}

/// Mock สำหรับ Repository
class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

/// Fake Class สำหรับ Argument Matching ของ Mocktail
class FakeCurrencyPair extends Fake implements CurrencyPair {}

void registerTestFallbacks() {
  registerFallbackValue(FakeCurrencyPair());
}

// ==========================================
// Standard Test Fixtures (ตาม spec-be.md §4.2)
// ==========================================

/// Fixture 30 วัน: Benchmark Standard +0.54% ตาม AC-1, AC-2, AC-3
final fixtureRatePoints30Days = [
  RatePoint(
    date: DateTime(2026, 9, 29),
    rate: 33.568,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(
      2026,
      10,
      10,
    ), // AC-3 Benchmark: แตะจุดนี้แสดง "10 ต.ค. · 33.570"
    rate: 33.570,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 20),
    rate: 33.620,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 29),
    rate: 33.750,
    base: 'USD',
    quote: 'THB',
  ),
];

final fixtureTrendSuccess30Days = ExchangeRateTrend(
  pair: const CurrencyPair(base: 'USD', quote: 'THB'),
  days: 30,
  points: fixtureRatePoints30Days,
  maxRate: 33.750,
  minRate: 33.568,
  changePercentage: 0.54, // +0.54% ตาม AC-2
  trendDirection: TrendDirection.up, // ป้าย "สูงขึ้น"
);

/// Fixture 7 วัน: แนวโน้มขาลง (-0.44%, TrendDirection.down)
final fixtureRatePoints7Days = [
  RatePoint(
    date: DateTime(2026, 10, 23),
    rate: 33.800,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 26),
    rate: 33.720,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 29),
    rate: 33.650,
    base: 'USD',
    quote: 'THB',
  ),
];

final fixtureTrendSuccess7Days = ExchangeRateTrend(
  pair: const CurrencyPair(base: 'USD', quote: 'THB'),
  days: 7,
  points: fixtureRatePoints7Days,
  maxRate: 33.800,
  minRate: 33.650,
  changePercentage: -0.44, // -0.44%
  trendDirection: TrendDirection.down, // ป้าย "ลดลง"
);

/// Fixture 90 วัน: แนวโน้มทรงตัว (0.00%, TrendDirection.neutral)
final fixtureRatePoints90Days = [
  RatePoint(
    date: DateTime(2026, 7, 31),
    rate: 33.500,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 8, 31),
    rate: 33.600,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 9, 30),
    rate: 33.550,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 29),
    rate: 33.500,
    base: 'USD',
    quote: 'THB',
  ),
];

final fixtureTrendSuccess90Days = ExchangeRateTrend(
  pair: const CurrencyPair(base: 'USD', quote: 'THB'),
  days: 90,
  points: fixtureRatePoints90Days,
  maxRate: 33.600,
  minRate: 33.500,
  changePercentage: 0.00, // 0.00%
  trendDirection: TrendDirection.neutral, // ป้าย "ทรงตัว"
);

/// Fixtures สำหรับสถานะข้อผิดพลาดและข้อมูลว่าง (Screen 15-1c & 15-1d)
const fixtureEmptyFailure = EmptyDataFailure('ไม่มีข้อมูลในช่วงนี้');
const fixtureNetworkFailure = NetworkFailure(
  'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้',
);
const fixtureServerFailure = ServerFailure('ดึงข้อมูลไม่สำเร็จ');
