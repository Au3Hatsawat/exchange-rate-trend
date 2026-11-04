# Frontend Technical Specification — Issue #2: API Client & Caching Service

> **อ้างอิง Issue:** #2 — `[Service] Develop: API Client เชื่อมต่อ Frankfurter API พร้อมระบบแคชข้อมูลรายวัน`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **จัดทำโดย:** Subagent `spec-fe`  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **ดีไซน์อ้างอิง:** [Design Specification Issue #1](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/design.md)  

---

## 1. ขอบเขตงานฝั่งหน้าจอและสัญญาการส่งมอบ (Presentation Scope & Contract)

### 1.1 คำชี้แจงบทบาทของ Issue #2 ต่อฝั่งหน้าจอ
- **ไม่มีการสร้าง Screen / Widget UI ใหม่ในใบงานนี้:**  
  งานพัฒนาหน้าจอหลัก (15-1), แตะจุดบนกราฟ (15-1a), สถานะ Loading/Empty/Error (15-1b, 15-1c, 15-1d) และหน้าต่างเลือกสกุลเงิน (15-2) ถูกจัดสรรไปอยู่ในใบงานถัดไป (Issue #3, #4, #5)
- **พันธกิจหลักของสเปคฝั่งหน้าจอในใบงานนี้:**  
  กำหนด **Presentation Interface Contract** ให้ชัดเจน รัดกุม เพื่อให้ฝั่ง Service/Data พัฒนาแกนข้อมูลที่ตรงกับความต้องการของ UI 100% และจัดเตรียม **Design Tokens (Theme, Colors, Typography)** รองรับสถานะหน้าจอทั้ง 5 สถานะ

```text
┌────────────────────────────────────────────────────────┐
│               Presentation Layer (UI / Future)         │
│  - ExchangeRateTrendScreen (15-1, 15-1a)               │
│  - LoadingState (15-1b) / EmptyState (15-1c)           │
│  - ErrorState (15-1d) / CurrencySelect (15-2)          │
└───────────────────────────┬────────────────────────────┘
                            │ Watch / Listen
                            ▼
┌────────────────────────────────────────────────────────┐
│          Riverpod State & Provider Contract            │
│  - exchangeRateNotifierProvider                        │
│  - ExchangeRateState (Initial, Loading, Success, etc.) │
└───────────────────────────┬────────────────────────────┘
                            │ Calls UseCase
                            ▼
┌────────────────────────────────────────────────────────┐
│             Domain Layer (Implemented in #2)           │
│  - GetExchangeRateTrendUseCase                         │
│  - Entities: ExchangeRateTrend, RatePoint, CurrencyPair│
└────────────────────────────────────────────────────────┘
```

---

## 2. เอนทิตีและสัญญาข้อมูลที่ฝั่ง UI ใช้งาน (Domain Contracts Consumed by UI)

ฝั่ง UI จะรับข้อมูลเฉพาะ Domain Entities แบบ Pure Dart เท่านั้น โดยไม่เข้าถึง Data Models/DTOs ตามกฎ Clean Architecture (SDD §2):

### 2.1 รายการ Contract Types
| Entity / Enum | หน้าที่ในฝั่ง UI | แอตทริบิวต์หลัก |
|---|---|---|
| `CurrencyPair` | ระบุคู่สกุลเงินที่กำลังแสดงผล | `String base`, `String quote` (Default: `USD`, `THB`) |
| `RatePoint` | จุดข้อมูลเดี่ยวสำหรับพล็อตบน `fl_chart` และแสดงแถว 15-1a | `DateTime date`, `double rate`, `String base`, `String quote` |
| `TrendDirection` | บ่งชี้ทิศทางแนวโน้มเพื่อเลือกสีและไอคอน Badge | `enum TrendDirection { up, down, neutral }` |
| `ExchangeRateTrend` | ข้อมูลรวมสำหรับเรนเดอร์หน้าจอ 15-1 ทั้งหมด | `CurrencyPair pair`, `int days`, `List<RatePoint> points`, `double maxRate`, `double minRate`, `double changePercentage`, `TrendDirection trendDirection` |

### 2.2 โครงสร้างคลาสในภาษา Dart (Domain Entities)

```dart
// lib/features/exchange_rate/domain/entities/currency_pair.dart
import 'package:equatable/equatable.dart';

class CurrencyPair extends Equatable {
  final String base;
  final String quote;

  const CurrencyPair({
    required this.base,
    required this.quote,
  });

  static const defaultPair = CurrencyPair(base: 'USD', quote: 'THB');

  @override
  List<Object?> get props => [base, quote];
}
```

```dart
// lib/features/exchange_rate/domain/entities/rate_point.dart
import 'package:equatable/equatable.dart';

class RatePoint extends Equatable {
  final DateTime date;
  final double rate;
  final String base;
  final String quote;

  const RatePoint({
    required this.date,
    required this.rate,
    required this.base,
    required this.quote,
  });

  @override
  List<Object?> get props => [date, rate, base, quote];
}
```

```dart
// lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart
import 'package:equatable/equatable.dart';
import 'currency_pair.dart';
import 'rate_point.dart';

enum TrendDirection { up, down, neutral }

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
```

---

## 3. การออกแบบสถานะหน้าจอและ Riverpod Provider (Presentation State Contract)

### 3.1 นิยาม 5 สถานะหน้าจอ (5 Screen States)
เพื่อให้รองรับ State ของหน้าจอตาม Figma Design และ SDD §2:
1. **Initial (`ExchangeRateInitial`):** สถานะเริ่มต้นก่อนมีการโหลดข้อมูล (คู่เริ่มต้น USD/THB, ช่วงเริ่มต้น 30 วัน)
2. **Loading (`ExchangeRateLoading`):** หน้าจอ 15-1b กำลังดึงข้อมูลจาก API หรือคำนวณ โดยส่งผ่านค่า `pair` และ `days` เพื่อให้ Segmented Control แสดงสถานะกำลังโหลดได้
3. **Success (`ExchangeRateSuccess`):** หน้าจอ 15-1 แสดงผลสำเร็จ พร้อมรองรับ 15-1a ผ่าน `selectedPoint` เมื่อผู้ใช้แตะจุดบนกราฟ
4. **Empty (`ExchangeRateEmpty`):** หน้าจอ 15-1c เมื่อ API ตอบกลับ `[]` ไม่พบข้อมูลในช่วงวันดังกล่าว
5. **Error (`ExchangeRateError`):** หน้าจอ 15-1d เมื่อเกิดข้อผิดพลาด พร้อมข้อความและประเภท Failure เพื่อแสดงผลและรองรับปุ่มลองใหม่ (Retry)

### 3.2 โครงสร้าง State ด้วย Dart 3 Sealed Class

```dart
// lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/exchange_rate_trend.dart';
import '../../domain/entities/rate_point.dart';

sealed class ExchangeRateState extends Equatable {
  const ExchangeRateState();

  @override
  List<Object?> get props => [];
}

class ExchangeRateInitial extends ExchangeRateState {
  final CurrencyPair pair;
  final int days;

  const ExchangeRateInitial({
    this.pair = CurrencyPair.defaultPair,
    this.days = 30,
  });

  @override
  List<Object?> get props => [pair, days];
}

class ExchangeRateLoading extends ExchangeRateState {
  final CurrencyPair pair;
  final int days;

  const ExchangeRateLoading({
    required this.pair,
    required this.days,
  });

  @override
  List<Object?> get props => [pair, days];
}

class ExchangeRateSuccess extends ExchangeRateState {
  final ExchangeRateTrend trend;
  final RatePoint? selectedPoint; // สำหรับรองรับ Interaction หน้าจอ 15-1a

  const ExchangeRateSuccess({
    required this.trend,
    this.selectedPoint,
  });

  ExchangeRateSuccess copyWith({
    ExchangeRateTrend? trend,
    RatePoint? selectedPoint,
    bool clearSelectedPoint = false,
  }) {
    return ExchangeRateSuccess(
      trend: trend ?? this.trend,
      selectedPoint: clearSelectedPoint ? null : (selectedPoint ?? this.selectedPoint),
    );
  }

  @override
  List<Object?> get props => [trend, selectedPoint];
}

class ExchangeRateEmpty extends ExchangeRateState {
  final CurrencyPair pair;
  final int days;
  final String message;

  const ExchangeRateEmpty({
    required this.pair,
    required this.days,
    this.message = 'ไม่มีข้อมูลในช่วงนี้',
  });

  @override
  List<Object?> get props => [pair, days, message];
}

class ExchangeRateError extends ExchangeRateState {
  final CurrencyPair pair;
  final int days;
  final String message;
  final Failure failure;

  const ExchangeRateError({
    required this.pair,
    required this.days,
    required this.message,
    required this.failure,
  });

  @override
  List<Object?> get props => [pair, days, message, failure];
}
```

### 3.3 Riverpod Provider Signature
ใช้ `StateNotifier<ExchangeRateState>` เพื่อความเข้ากันได้ดีกับ `flutter_riverpod: ^2.5.1` โดยไม่ต้องพึ่งพา `build_runner`:

```dart
// lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/rate_point.dart';
import '../../domain/usecases/get_exchange_rate_trend_usecase.dart';
import 'exchange_rate_state.dart';

// UseCase Provider
final getExchangeRateTrendUseCaseProvider = Provider<GetExchangeRateTrendUseCase>((ref) {
  // ดึง implementation จาก repository provider
  throw UnimplementedError('ผูก dependency ผ่าน Service Locator / Providers');
});

// StateNotifier Provider
final exchangeRateNotifierProvider =
    StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>((ref) {
  final useCase = ref.watch(getExchangeRateTrendUseCaseProvider);
  return ExchangeRateNotifier(useCase: useCase);
});

class ExchangeRateNotifier extends StateNotifier<ExchangeRateState> {
  final GetExchangeRateTrendUseCase _useCase;

  ExchangeRateNotifier({required GetExchangeRateTrendUseCase useCase})
      : _useCase = useCase,
        super(const ExchangeRateInitial());

  /// ดึงข้อมูลแนวโน้มอัตราแลกเปลี่ยน (สลับช่วงวัน หรือเปลี่ยนคู่สกุลเงิน)
  Future<void> fetchTrend({CurrencyPair? pair, int? days}) async {
    final currentPair = pair ?? _getCurrentPair();
    final currentDays = days ?? _getCurrentDays();

    state = ExchangeRateLoading(pair: currentPair, days: currentDays);

    final result = await _useCase(pair: currentPair, days: currentDays);

    result.fold(
      (failure) {
        if (failure is EmptyDataFailure) {
          state = ExchangeRateEmpty(
            pair: currentPair,
            days: currentDays,
            message: failure.message,
          );
        } else {
          state = ExchangeRateError(
            pair: currentPair,
            days: currentDays,
            message: failure.message,
            failure: failure,
          );
        }
      },
      (trend) {
        if (trend.points.isEmpty) {
          state = ExchangeRateEmpty(
            pair: currentPair,
            days: currentDays,
          );
        } else {
          state = ExchangeRateSuccess(trend: trend);
        }
      },
    );
  }

  /// ลองเรียกใหม่อีกครั้ง (จากปุ่ม Retry ในหน้าจอ 15-1d)
  Future<void> retry() async {
    await fetchTrend();
  }

  /// เลือกจุดบนกราฟเพื่อแสดงข้อมูลในแถว 15-1a
  void selectPoint(RatePoint? point) {
    if (state is ExchangeRateSuccess) {
      final currentSuccess = state as ExchangeRateSuccess;
      state = currentSuccess.copyWith(selectedPoint: point);
    }
  }

  CurrencyPair _getCurrentPair() {
    return switch (state) {
      ExchangeRateInitial(pair: final p) => p,
      ExchangeRateLoading(pair: final p) => p,
      ExchangeRateSuccess(trend: final t) => t.pair,
      ExchangeRateEmpty(pair: final p) => p,
      ExchangeRateError(pair: final p) => p,
    };
  }

  int _getCurrentDays() {
    return switch (state) {
      ExchangeRateInitial(days: final d) => d,
      ExchangeRateLoading(days: final d) => d,
      ExchangeRateSuccess(trend: final t) => t.days,
      ExchangeRateEmpty(days: final d) => d,
      ExchangeRateError(days: final d) => d,
    };
  }
}
```

---

## 4. การแปลง Error / Failure สู่ข้อความสำหรับผู้ใช้ (Error Mapping Contract)

ตามสัญญาใน SDD §3 Presentation Layer จะแปลง `Failure` จาก Domain Layer สู่ข้อความภาษาไทยที่เข้าใจง่ายและเป็นมิตรกับผู้ใช้งาน:

| ประเภท Failure (Domain) | สัญญาณสาเหตุ | ข้อความใน UI (Title & Message) | ป้ายปุ่ม Action (Retry) | สถานะเป้าหมาย |
|---|---|---|---|---|
| `NetworkFailure` | เครือข่ายหลุด / Timeout / ไม่มีอินเทอร์เน็ต | **Title:** "ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้"<br>**Subtitle:** "กรุณาตรวจสอบสัญญาณอินเทอร์เน็ตแล้วลองใหม่อีกครั้ง" | "ลองอีกครั้ง" (`retry()`) | `ExchangeRateError` (15-1d) |
| `ServerFailure` | HTTP 500 / 422 / เซิร์ฟเวอร์ไม่ตอบสนอง | **Title:** "ดึงข้อมูลไม่สำเร็จ"<br>**Subtitle:** "ระบบขัดข้องชั่วคราว กรุณาลองใหม่อีกครั้งในภายหลัง" | "ลองอีกครั้ง" (`retry()`) | `ExchangeRateError` (15-1d) |
| `EmptyDataFailure` | API คืนค่า `[]` (HTTP 200 แต่ไม่มีประวัติ) | **Title:** "ไม่มีข้อมูลในช่วงนี้"<br>**Subtitle:** "ไม่พบประวัติอัตราแลกเปลี่ยนสำหรับช่วงเวลาที่เลือก" | ไม่มีปุ่ม Retry (เปลี่ยนช่วงวัน/คู่สกุลเงิน) | `ExchangeRateEmpty` (15-1c) |
| `CacheFailure` | ข้อมูลแคชในหน่วยความจำเสียหาย | แปลงเป็นการดึงจาก Network อัตโนมัติ (Fallback) หากยังล้มเหลวจะคืน `ServerFailure` | "ลองอีกครั้ง" (`retry()`) | `ExchangeRateError` (15-1d) |

---

## 5. ตาราง Design Tokens และ Theme Constants (UI Design System Tokens)

สอดคล้องกับ Figma Spec ([`design.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/design.md)) เพื่อให้สร้าง Constants ไว้ใน `lib/core/theme/` พร้อมใช้:

### 5.1 Color Palette Tokens
| Token Name | Hex Code | ค่าคงที่ Dart (`AppColors`) | บทบาทการใช้งาน (Semantic Role) |
|---|---|---|---|
| `color.text.primary` | `#171B21` | `AppColors.textPrimary` | ข้อความหลัก, ชื่อหัวข้อหน้าจอ, ค่าอัตราแลกเปลี่ยนหลัก |
| `color.text.secondary` | `#525C6A` | `AppColors.textSecondary` | ข้อความรอง, หน่วยสกุลเงิน, วันที่, ป้ายกำกับสถิติ |
| `color.brand.primary` | `#2450D0` | `AppColors.brandPrimary` | สีไฮไลท์หลัก, เส้นกราฟ `fl_chart`, ลิงก์ที่มา, ปุ่ม Action |
| `color.bg.screen` | `#F7F8FA` | `AppColors.bgScreen` | พื้นหลังของทั้งหน้าจอ (Scaffold background) |
| `color.bg.surface` | `#FFFFFF` | `AppColors.bgSurface` | พื้นหลัง Card (Stat cards, Chart card surface) |
| `color.bg.subtle` | `#EEF0F3` | `AppColors.bgSubtle` | พื้นหลัง Segmented Control, กล่อง Source note |
| `color.border.default`| `#DDE1E7` | `AppColors.borderDefault` | เส้นขอบ Card, เส้นกริดกราฟ (Gridlines) |
| `color.status.up` | `#10B981` | `AppColors.statusUp` | ป้าย Badge "สูงขึ้น", ลูกศรแนวโน้มขึ้น (Trending Up) |
| `color.status.up.dark`| `#059669` | `AppColors.statusUpDark` | สีตัวหนังสือ/ไอคอนบนป้ายแนวโน้มขึ้น |
| `color.status.down` | `#EF4444` | `AppColors.statusDown` | ป้าย Badge "ลดลง", ลูกศรแนวโน้มลง (Trending Down) |
| `color.status.down.dark`| `#DC2626` | `AppColors.statusDownDark` | สีตัวหนังสือ/ไอคอนบนป้ายแนวโน้มลง |
| `color.status.neutral`| `#525C6A` | `AppColors.statusNeutral` | ป้าย Badge "ทรงตัว" (Trending Neutral) |

### 5.2 Typography Tokens (IBM Plex Sans Thai)
กำหนดสไตล์ผ่าน `google_fonts` ใน `lib/core/theme/app_typography.dart`:

| Style Name | ขนาด (Size) | น้ำหนัก (Weight) | ความสูงบรรทัด (Height) | ค่าคงที่ Dart (`AppTypography`) | การใช้งาน |
|---|---|---|---|---|---|
| `Title` | 24px | SemiBold (600) | 34px | `AppTypography.title` | ชื่อหน้าจอ "แนวโน้มอัตราแลกเปลี่ยน" |
| `Heading` | 20px | SemiBold (600) | 30px | `AppTypography.heading` | หัวข้อส่วน, ค่าตัวเลขอัตราแลกเปลี่ยนตัวใหญ่ |
| `Body/Large` | 18px | Regular (400) | 28px | `AppTypography.bodyLarge` | ข้อความสำคัญ, ตัวเลขใน Stat card |
| `Body/Default`| 16px | Regular (400) | 24px | `AppTypography.bodyDefault`| ข้อความแถวข้อมูล, รายชื่อสกุลเงิน |
| `Body/Small` | 14px | Regular (400) | 20px | `AppTypography.bodySmall` | ข้อความอธิบายย่อย, วันที่ในแกนกราฟ |
| `Label/Small` | 14px | Medium (500) | 20px | `AppTypography.labelSmall`| ป้ายกำกับ Badge ("สูงขึ้น", "ลดลง"), Segment Text |

### 5.3 Spacing, Border Radius & Layout Dimensions
| Token Name | ค่าคงที่ (Value) | การนำไปใช้ |
|---|---|---|
| `padding.screen.horizontal` | 16px | ขอบซ้าย-ขวาของหน้าจอหลัก |
| `spacing.small` | 8px | ระยะห่างระหว่างไอคอนกับข้อความ |
| `spacing.medium` | 12px | ระยะห่างระหว่าง Stat Card หรือข้อมูลแถว |
| `spacing.large` | 16px | ระยะห่างระหว่าง Card แต่ละส่วน |
| `radius.card` | 14px | เส้นโค้งมนของการ์ดกราฟและการ์ดสถิติ (`borderRadius: BorderRadius.circular(14)`) |
| `radius.pill` | 999px | เส้นโค้งมนของ Badge แนวโน้ม และ Segmented Control |
| `border.width.thin` | 1.0px | ความหนาของขอบการ์ดและเส้นแบ่ง |

### 5.4 การผูก Design Tokens กับ 5 สถานะหน้าจอ (State-to-Token Mapping)
| สถานะหน้าจอ | องค์ประกอบภาพหลัก | Design Tokens ที่เกี่ยวข้อง |
|---|---|---|
| **Loading (15-1b)** | CircularProgressIndicator หรือ Shimmer Block กึ่งกลางหน้า | `AppColors.brandPrimary`, `AppColors.bgSubtle` |
| **Success (15-1)** | Line Chart + Stat Cards + Trend Badge | `AppColors.brandPrimary` (Chart line), `AppColors.statusUp` / `AppColors.statusDown` (Badge), `AppColors.bgSurface` (Cards) |
| **Success Interaction (15-1a)** | Tooltip / Selected Point Highlight | `AppColors.brandPrimary` (จุด Indicator), `AppColors.textPrimary` (ค่า rate ที่เลือก), `AppTypography.bodyDefault` |
| **Empty (15-1c)** | Icon แจ้งเตือน + ข้อความ "ไม่มีข้อมูลในช่วงนี้" | `AppColors.textSecondary`, `AppColors.bgSubtle`, `AppTypography.bodyDefault` |
| **Error (15-1d)** | Icon ข้อผิดพลาด + ข้อความแจ้งเตือน + ปุ่ม "ลองอีกครั้ง" | `AppColors.statusDown`, `AppColors.brandPrimary` (ปุ่ม Retry), `AppTypography.heading`, `AppTypography.bodyDefault` |

---

## 6. ตำแหน่งไฟล์ที่เกี่ยวข้อง (Target File Locations)

### 6.1 ไฟล์ที่จะสร้างและทดสอบใน Issue #2 (Core Service & Contracts)
| พาธไฟล์ (ใน `app/`) | เลเยอร์ | ความรับผิดชอบใน Issue #2 |
|---|---|---|
| `lib/core/theme/app_colors.dart` | Core Theme | สร้าง Palette ค่าคงที่สีตาม Figma สำหรับรองรับ State |
| `lib/core/theme/app_typography.dart` | Core Theme | สร้าง Typography สไตล์ภาษาไทย IBM Plex Sans Thai |
| `lib/features/exchange_rate/domain/entities/rate_point.dart` | Domain | สร้าง Immutable RatePoint Entity |
| `lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart` | Domain | สร้าง Immutable ExchangeRateTrend Entity + TrendDirection |
| `lib/features/exchange_rate/domain/entities/currency_pair.dart` | Domain | สร้าง Immutable CurrencyPair Entity |
| `lib/features/exchange_rate/domain/repositories/exchange_rate_repository.dart` | Domain | สัญญาดึงข้อมูลของ Repository |
| `lib/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart` | Domain | UseCase สำหรับส่งต่อข้อมูลให้ Riverpod Notifier |
| `lib/core/errors/failures.dart` | Core Errors | Failure types (`NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, etc.) |

### 6.2 ไฟล์ที่จะสร้างใน Issue ถัดไป (Issue #3 หน้าจอ 15-1, 15-1a, 15-1b, 15-1c, 15-1d)
- `lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart`
- `lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart`
- `lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart`
- `lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart`
- `lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart`
- `lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart`
- `lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart`
- `lib/features/exchange_rate/presentation/widgets/source_note_widget.dart`
- `lib/features/exchange_rate/presentation/widgets/states/loading_state_widget.dart`
- `lib/features/exchange_rate/presentation/widgets/states/empty_state_widget.dart`
- `lib/features/exchange_rate/presentation/widgets/states/error_state_widget.dart`

---

## 7. สรุปความพร้อมสำหรับขั้นตอนถัดไป (Handover to Contract Checker & Stage C)

1. สัญญา Interface ทั้งหมดระหว่างฝั่ง UI และฝั่ง Service ถูกกำหนดชัดเจนในรูปแบบ Pure Dart Entities
2. State Machine ของ Presentation Layer รองรับครบถ้วน 5 สถานะตามเกณฑ์ใน Figma และ SDD
3. มีการเตรียม Design Tokens ทั้งชุดสี Up/Down/Neutral/Brand และฟอนต์ภาษาไทยไว้อย่างเป็นระบบ เพื่อให้ Implementer สามารถนำไปสร้าง Theme Constants ได้ทันทีใน Stage C
4. พร้อมสำหรับการตรวจสอบความสอดคล้องกับ `spec-be.md` ในขั้นตอน Contract Checker (จุดบรรจบ 1)

---
อ้างอิง SDD: §1 การตัดสินใจด้านเทคสแตก และ §2 โครงสร้างโฟลเดอร์และขอบเขตเลเยอร์  
ลิงก์: [docs/sdd/01-tech-stack.md](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/01-tech-stack.md) · [docs/sdd/02-architecture-layout.md](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/02-architecture-layout.md) · [docs/sdd/03-api-contract.md](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/03-api-contract.md)
