# สเปคเชิงเทคนิคฝั่งเซอร์วิสและข้อมูล (Backend & Data Technical Specification)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **ผู้จัดทำ:** Subagent `spec-be`  
> **วันที่จัดทำ:** 2026-11-04  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4, §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **เอกสารตั้งต้น:** [`workspec-be.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-be.md) · [`existing-inventory.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/existing-inventory.md) · [`design.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md)

---

## 1. ขอบเขตและภาพรวมทางเทคนิค (Technical Scope Confirmation)

### 1.1 ยืนยันการไม่แก้ไขโค้ดฝั่งหลังบ้าน (Zero Backend / Data Code Changes)
- **ไม่สร้างและไม่แก้ไข API Endpoint ใด ๆ เพิ่มเติม:** Frankfurter API v2 (`/v2/rates`) คงที่ ไม่มีการเรียก Endpoint ใหม่ หรือแก้ไข Query Parameters
- **ไม่มีการแก้ไขฐานข้อมูลหรือ Local Storage ใหม่:** ระบบแคชใช้ `ExchangeRateLocalDataSource` (In-Memory Cache) ที่พัฒนาเสร็จสมบูรณ์ใน Issue #2
- **ความสมบูรณ์ของแกนกลางโดเมน:** Domain Entities (`ExchangeRateTrend`, `RatePoint`, `CurrencyPair`), UseCase (`GetExchangeRateTrendUseCase`), Failure Entities (`NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, `CacheFailure`) และยูทิลิตี้คำนวณ (`TrendCalculator`) ผ่าน Unit Tests ครบถ้วน 28 เคส พร้อมส่งมอบให้ฝั่ง UI 100%

### 1.2 ภารกิจหลักของฝั่ง Service & Data ใน Issue #3
1. **ยืนยันสัญญาข้อมูล (Contract Stability):** รับประกันความเข้ากันได้ระหว่าง Presentation Layer และ Domain/Data Layer
2. **ออกแบบ Dependency Injection (DI) ด้วย Riverpod:** ระบุลำดับการประกอบ Providers ใน `lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart`
3. **จัดเตรียม Mock Classes และ Test Fixtures:** สนับสนุนการทำ TDD และ Widget Tests ฝั่ง Presentation (Screen 15-1, 15-1a, 15-1b, 15-1c, 15-1d) โดยเฉพาะเคส Benchmark +0.54% ตาม AC-2 และจุดวันที่ 10 ต.ค. ตาม AC-3

---

## 2. สัญญาข้อมูลระหว่าง Data/Domain Layer และ Presentation Layer

ตามกฎ Clean Architecture SDD §2: Presentation Layer จะเข้าถึง Data ผ่าน **Domain Layer เท่านั้น** (ห้าม Presentation Layer เรียก Data Layer โดยตรง)

```text
┌────────────────────────────────────────────────────────┐
│                  Presentation Layer                    │
│      ExchangeRateNotifier ───▶ ExchangeRateState       │
└───────────────────────────┬────────────────────────────┘
                            │ depends on (UseCase only)
                            ▼
┌────────────────────────────────────────────────────────┐
│                     Domain Layer                       │
│             GetExchangeRateTrendUseCase                │
│    ExchangeRateRepository (Contract Interface)         │
│    Entities: ExchangeRateTrend, RatePoint, CurrencyPair │
│    Failures: Either<Failure, ExchangeRateTrend>        │
└───────────────────────────▲────────────────────────────┘
                            │ implements
┌───────────────────────────┴────────────────────────────┐
│                      Data Layer                        │
│    ExchangeRateRepositoryImpl                          │
│    ExchangeRateRemoteDataSource / LocalDataSource      │
└────────────────────────────────────────────────────────┘
```

### 2.1 UseCase Call Signature
```dart
class GetExchangeRateTrendUseCase {
  final ExchangeRateRepository repository;

  GetExchangeRateTrendUseCase(this.repository);

  Future<Either<Failure, ExchangeRateTrend>> call({
    required CurrencyPair pair,
    required int days,
  });
}
```

### 2.2 Input Contract Specifications

| พารามิเตอร์ | ชนิดข้อมูล | ค่าที่อนุญาต | ค่าเริ่มต้น | ความสัมพันธ์กับ UI (Screen 15-1) |
|---|---|---|---|---|
| `pair` | `CurrencyPair` | `base` และ `quote` เป็นรหัส ISO 4217 (3 ตัวอักษร) | `CurrencyPair.defaultPair` (`USD/THB`) | แสดงใน `CurrencySelectorCard` (FR-2) |
| `days` | `int` | `7`, `30`, `90` | `30` | ควบคุมโดย `PeriodSegmentedControl` (FR-3, BR-1) |

### 2.3 Output Contract Specifications (`ExchangeRateTrend`)

เมื่อ UseCase ส่งผลลัพธ์เป็น `Right(ExchangeRateTrend)`:

| Field Name | ชนิดข้อมูล | รายละเอียด | จุดนำไปเรนเดอร์ใน UI |
|---|---|---|---|
| `pair` | `CurrencyPair` | คู่สกุลเงิน เช่น `USD/THB` | ส่วนหัวหน้าจอ / กล่องเลือกคู่เงิน |
| `days` | `int` | ช่วงวันที่เลือก (7, 30, 90) | ข้อความสรุป: "เปลี่ยนแปลง {N} วัน" (FR-6) |
| `points` | `List<RatePoint>` | รายการจุดอัตราแลกเปลี่ยน เรียงจากอดีตไปปัจจุบัน (`date`, `rate`, `base`, `quote`) | วาดเส้นกราฟ `TrendLineChart` (`fl_chart`) และแสดงจุดสัมผัส (FR-4, FR-7) |
| `maxRate` | `double` | อัตราแลกเปลี่ยนสูงสุดในช่วงเวลา | การ์ดสถิติ `StatCardCompact` ด้านซ้าย (FR-5) |
| `minRate` | `double` | อัตราแลกเปลี่ยนต่ำสุดในช่วงเวลา | การ์ดสถิติ `StatCardCompact` ด้านขวา (FR-5) |
| `changePercentage` | `double` | เปอร์เซ็นต์การเปลี่ยนแปลง ปัดทศนิยม 2 ตำแหน่งตาม BR-3 | แสดงตัวเลข % ใน `TrendSummaryRow` (FR-6, AC-2) |
| `trendDirection` | `TrendDirection` | Enum: `up`, `down`, `neutral` ตาม BR-4 | กำหนดสีและข้อความของ Level Badge ใน `TrendSummaryRow` (FR-6, AC-2) |

#### กฎการแมป TrendDirection กับ Badge ใน Presentation Layer:
- `TrendDirection.up` $\rightarrow$ ข้อความ `"สูงขึ้น"`, สี Badge สีเขียว/น้ำเงิน (`#2450D0` หรือ `#059669`), สัญลักษณ์ลูกศรขึ้น
- `TrendDirection.down` $\rightarrow$ ข้อความ `"ลดลง"`, สี Badge สีส้ม/แดง (`#DC2626` หรือ `#C2410C`), สัญลักษณ์ลูกศรลง
- `TrendDirection.neutral` $\rightarrow$ ข้อความ `"ทรงตัว"`, สี Badge สีเทา (`#525C6A`), สัญลักษณ์ขีดแนวนอน

### 2.4 Error & Failure Contract Specifications

เมื่อ UseCase ส่งผลลัพธ์เป็น `Left(Failure)`:

| Concrete Failure | สาเหตุ | ข้อความดีฟอลต์ | พฤติกรรมที่ Presentation Layer ต้องทำ |
|---|---|---|---|
| `EmptyDataFailure` | API คืนค่า Array ว่าง (`[]`) ตาม BR-6 | `"ไม่มีข้อมูลในช่วงนี้"` | แสดง **Empty State Widget (Screen 15-1c)**: ไอคอนข้อมูลว่าง + ข้อความ |
| `NetworkFailure` | เครือข่ายมีปัญหา, Connection Timeout, Socket Exception | `"ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้"` | แสดง **Error State Widget (Screen 15-1d)**: ข้อความ Error + ปุ่ม "ลองอีกครั้ง" |
| `ServerFailure` | HTTP 422, 500 หรือ Parse ข้อมูลผิดพลาด | `"ดึงข้อมูลไม่สำเร็จ"` | แสดง **Error State Widget (Screen 15-1d)**: ข้อความ Error + ปุ่ม "ลองอีกครั้ง" |
| `CacheFailure` | ข้อมูลแคชเสียหายหรือไม่สามารถอ่านได้ | `"เกิดข้อผิดพลาดของระบบแคช"` | Repository จัดการ Fallback ไปดึง Remote อัตโนมัติ หากยังล้มเหลวจะส่ง `ServerFailure` |

---

## 3. การตั้งค่า Dependency Injection (DI) ผ่าน Riverpod

ตามโครงสร้าง SDD §2 Presentation Layer ต้องใช้ Riverpod ในการฉีด Dependencies เพื่อให้สามารถ Override Provider ในการทำ Unit / Widget Test ได้อย่างสมบูรณ์

### 3.1 โครงสร้าง Provider Hierarchy ใน `exchange_rate_provider.dart`

```text
[dioProvider] ──▶ [remoteDataSourceProvider] ┐
                                             ├──▶ [exchangeRateRepositoryProvider] ──▶ [getExchangeRateTrendUseCaseProvider] ──▶ [exchangeRateNotifierProvider]
[localDataSourceProvider] ───────────────────┘
```

### 3.2 รายละเอียดการประกาศ Provider

```dart
// lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/exchange_rate_local_datasource.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/usecases/get_exchange_rate_trend_usecase.dart';
import 'exchange_rate_notifier.dart';
import 'exchange_rate_state.dart';

/// 1. Dio Provider (Core Network)
final dioProvider = Provider<Dio>((ref) {
  return DioClient.createDio();
});

/// 2. Remote Data Source Provider
final remoteDataSourceProvider = Provider<ExchangeRateRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ExchangeRateRemoteDataSourceImpl(dio: dio);
});

/// 3. Local Data Source Provider (In-Memory Cache)
final localDataSourceProvider = Provider<ExchangeRateLocalDataSource>((ref) {
  return ExchangeRateLocalDataSourceImpl();
});

/// 4. Repository Provider
final exchangeRateRepositoryProvider = Provider<ExchangeRateRepository>((ref) {
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  final localDataSource = ref.watch(localDataSourceProvider);
  return ExchangeRateRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

/// 5. Domain Use Case Provider
final getExchangeRateTrendUseCaseProvider = Provider<GetExchangeRateTrendUseCase>((ref) {
  final repository = ref.watch(exchangeRateRepositoryProvider);
  return GetExchangeRateTrendUseCase(repository);
});

/// 6. Presentation StateNotifier Provider
final exchangeRateNotifierProvider =
    StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>((ref) {
  final useCase = ref.watch(getExchangeRateTrendUseCaseProvider);
  return ExchangeRateNotifier(getExchangeRateTrendUseCase: useCase);
});
```

---

## 4. ข้อกำหนด Mock Classes และ Test Fixtures สำหรับ Widget Tests

เพื่อสนับสนุนการพัฒนาแบบ TDD ใน Stage C และการทดสอบ Acceptance Criteria (AC-1 ถึง AC-6) ฝั่ง Backend ขอกำหนด Mock Classes และ Test Fixtures มาตรฐานดังนี้:

### 4.1 Mock Classes Definition (ใช้แพ็กเกจ `mocktail`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/entities/currency_pair.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:exchange_rate_trend/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart';

/// Mock สำหรับ UseCase (ใช้สำหรับ Widget Test ของ Presentation Layer)
class MockGetExchangeRateTrendUseCase extends Mock
    implements GetExchangeRateTrendUseCase {}

/// Mock สำหรับ Repository (ใช้สำหรับ Notifier Unit Test หรือ Repository Level)
class MockExchangeRateRepository extends Mock
    implements ExchangeRateRepository {}

/// Fake Class สำหรับ Argument Matching
class FakeCurrencyPair extends Fake implements CurrencyPair {}

void registerTestFallbacks() {
  registerFallbackValue(FakeCurrencyPair());
}
```

### 4.2 Standard Test Fixtures

#### ชุดที่ 1: Fixture 30 วัน (Benchmark Standard +0.54% ตาม AC-1, AC-2, AC-3)
ตรงตามข้อมูล Figma และเกณฑ์ประเมิน AC-2 และ AC-3 (แตะจุด 10 ต.ค. แสดงเรต 33.570):
```dart
final fixtureRatePoints30Days = [
  RatePoint(
    date: DateTime(2026, 9, 29),
    rate: 33.568,
    base: 'USD',
    quote: 'THB',
  ),
  RatePoint(
    date: DateTime(2026, 10, 10), // AC-3: แตะจุดนี้แสดง "10 ต.ค. · 33.570"
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
```

#### ชุดที่ 2: Fixture 7 วัน (แนวโน้มขาลง — Trend Direction Down)
สำหรับทดสอบการสลับช่วงเวลา 7 วัน (AC-4) และตรวจสอบป้ายแนวโน้ม "ลดลง":
```dart
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
```

#### ชุดที่ 3: Fixture 90 วัน (แนวโน้มทรงตัว — Trend Direction Neutral)
สำหรับทดสอบการสลับช่วงเวลา 90 วัน และตรวจสอบป้ายแนวโน้ม "ทรงตัว":
```dart
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
```

#### ชุดที่ 4: Fixture ข้อผิดพลาดและข้อมูลว่าง (Failure Responses)
```dart
/// ข้อมูลว่าง (Empty State Screen 15-1c & BR-6)
const fixtureEmptyFailure = EmptyDataFailure('ไม่มีข้อมูลในช่วงนี้');

/// ปัญหาเครือข่าย (Error State Screen 15-1d)
const fixtureNetworkFailure = NetworkFailure('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้');

/// ปัญหาฝั่งเซิร์ฟเวอร์ (Error State Screen 15-1d)
const fixtureServerFailure = ServerFailure('ดึงข้อมูลไม่สำเร็จ');
```

---

## 5. รูปแบบการทำ Widget Test Isolation (Riverpod Provider Override)

เมื่อทดสอบ UI Components และ Screens ใน Stage C ทีมพัฒนาสามารถฉีด Mock UseCase ได้โดยตรงโดยไม่ต้องยุ่งเกี่ยวกับ Network Client หรือ Data Sources:

```dart
testWidgets('Screen 15-1 renders chart, stat cards and +0.54% badge (AC-1 & AC-2)', (tester) async {
  registerTestFallbacks();
  final mockUseCase = MockGetExchangeRateTrendUseCase();

  when(() => mockUseCase.call(
    pair: any(named: 'pair'),
    days: any(named: 'days'),
  )).thenAnswer((_) async => Right(fixtureTrendSuccess30Days));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getExchangeRateTrendUseCaseProvider.overrideWithValue(mockUseCase),
      ],
      child: const MaterialApp(
        home: ExchangeRateTrendScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();

  // ตรวจสอบการแสดงผลตาม AC-1 และ AC-2
  expect(find.text('+0.54%'), findsOneWidget);
  expect(find.text('สูงขึ้น'), findsOneWidget);
  expect(find.text('33.750'), findsOneWidget); // maxRate
  expect(find.text('33.568'), findsOneWidget); // minRate
});
```

---

## 6. วงจรการทำงานของข้อมูลและการควบคุม State (State & Data Lifecycle)

1. **Initial Load (Screen 15-1 เปิดขึ้นมา):**
   - Notifier เริ่มต้นเรียก `loadTrend(pair: CurrencyPair.defaultPair, days: 30)`
   - State ปรับเป็น `status: ExchangeRateStatus.loading` (แสดง Block Loading 15-1b)
   - UseCase ส่งคำขอผ่าน Repository $\rightarrow$ Local Cache (ถ้ามี) หรือ Remote DataSource
   - เมื่อสำเร็จ: State ปรับเป็น `status: ExchangeRateStatus.success`, เก็บ `trend` ใน State และแสดงผลกราฟ
2. **User Switches Period (กด 7 วัน หรือ 90 วันตาม BR-2):**
   - Notifier เรียก `changePeriod(newDays)`
   - ถ้ามีข้อมูลใน Daily Cache (`localDataSource`): ส่งค่าคืนทันทีในระดับ Microsecond
   - ถ้าไม่มีข้อมูล: เข้าสู่ Loading State แล้วดึงข้อมูลจาก Frankfurter API
3. **User Taps Chart Spot (แตะจุดบนกราฟ 15-1a ตาม AC-3):**
   - Touch Callback บน `TrendLineChart` จับคู่ X-value กับ `RatePoint` ใน `points`
   - เรียก Notifier `selectPoint(ratePoint)`
   - State อัปเดตเฉพาะฟิลด์ `selectedPoint: ratePoint`
   - UI แสดงผล `DatePointDetailRow` (เช่น `"10 ต.ค. · 33.570"`) โดย**ไม่มีการเรียก Service ซ้ำ**
4. **Error Handling & Retry:**
   - หากเกิด Network / Server Error: State ปรับเป็น `status: ExchangeRateStatus.error`
   - เมื่อผู้ใช้แตะปุ่ม "ลองอีกครั้ง" (Retry): เรียก Notifier `retry()` ทำการยิงคำขอใหม่อีกครั้ง

---

## 7. สรุปความพร้อมในการส่งมอบให้ Stage C (Checklist)

- [x] ยืนยันว่าไม่มีการแก้ไข API หรือโค้ด Data/Domain ใหม่ (Zero BE Changes)
- [x] สัญญาข้อมูล Domain Entities และ Failures ถูกนิยามอย่างชัดเจนและครบถ้วน
- [x] Dependency Injection Setup ผ่าน 6 Riverpod Providers ได้รับการกำหนดโครงสร้างพร้อมนำไปเขียนโค้ด
- [x] Test Fixtures ครบทั้ง 30d (Benchmark +0.54% / AC-2), 7d (Down), 90d (Neutral), Empty (15-1c), และ Errors (15-1d)
- [x] แนวทางการ Override Provider ใน Widget Test ถูกจัดเตรียมพร้อมสำหรับ `test-author`

---

อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
