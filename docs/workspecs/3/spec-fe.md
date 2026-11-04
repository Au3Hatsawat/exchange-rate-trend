# Frontend Technical Specification — Issue #3: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **จัดทำโดย:** Subagent `spec-fe`  
> **วันที่จัดทำ:** 2026-11-04  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4, §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **ดีไซน์อ้างอิง:** [Design Specification Issue #1](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md) · [Figma: MAT 15 – Exchange Rate Trend](https://www.figma.com/design/O1nysCaeCKuz0bD3o2VEPa/MAT-15-%E2%80%93-Exchange-Rate-Trend)  
> **เอกสารตั้งต้น:** [`workspec-fe.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-fe.md) · [`existing-inventory.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/existing-inventory.md)

---

## 1. ภาพรวมสถาปัตยกรรมและขอบเขตงานฝั่งหน้าจอ (Frontend Architecture Overview)

ใบงาน Issue #3 รับผิดชอบการพัฒนา **Presentation Layer** ของฟีเจอร์ Exchange Rate Trend ทั้งหมด ประกอบด้วย:
1. การสร้าง **Core Design Tokens & Theme** (`AppColors`, `AppTypography`, `AppTheme`) ตาม Design System ใน Figma
2. การพัฒนา **State Management** ด้วย Flutter Riverpod (`ExchangeRateState`, `ExchangeRateNotifier`, Providers)
3. การพัฒนา **Screen 15-1 (Main Screen)** และ **Screen 15-1a (Touch Interaction State)**
4. การจัดการ **4 สถานะหน้าจอ (Screen States)**: Success (Data), Loading (15-1b), Empty (15-1c), และ Error (15-1d)
5. การต่อเติม **Utility ฟอร์แมตวันที่ภาษาไทยแบบย่อ** (`DateFormatter.formatThaiShortDate`)
6. การปรับปรุง **Application Entry Point** (`lib/main.dart`) เชื่อมต่อ `ProviderScope` และตั้ง `ExchangeRateTrendScreen` เป็นโฮมสกรีน

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        ExchangeRateTrendScreen                         │
│  (Responsive Wrapper: Max-Width 600px Centered for Tablet, 360px Mobile)│
├────────────────────────────────────────────────────────────────────────┤
│  1. Top App Bar: "แนวโน้มอัตราแลกเปลี่ยน" (24px SemiBold)                 │
│  2. CurrencySelectorCard: "USD → THB" + Chevron Icon (FR-2)            │
│  3. PeriodSegmentedControl: [ 7 วัน | 30 วัน | 90 วัน ] (FR-3, BR-2)   │
│  4. Screen State Switcher:                                             │
│     ├── Success (15-1):                                                │
│     │   ├── TrendLineChart (fl_chart Single Series, X/Y Axis, Grid)    │
│     │   ├── DatePointDetailRow (15-1a: แตะจุดแสดง "10 ต.ค. · 33.570")   │
│     │   ├── StatCardCompact × 2 (สูงสุด / ต่ำสุด) (FR-5)               │
│     │   └── TrendSummaryRow ("เปลี่ยนแปลง 30 วัน" + % + Badge) (FR-6)    │
│     ├── LoadingStateWidget (15-1b: Spinner / Skeleton, Lock Buttons)   │
│     ├── EmptyStateWidget (15-1c: "ไม่มีข้อมูลในช่วงนี้") (BR-6)         │
│     └── ErrorStateWidget (15-1d: "ดึงข้อมูลไม่สำเร็จ" + Retry Button)     │
│  5. SourceNoteWidget: "ข้อมูลจาก Frankfurter API" + External Link (FR-8) │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Watches / Triggers
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                   Riverpod State Management Layer                      │
│  - exchangeRateNotifierProvider (ExchangeRateNotifier)                 │
│  - ExchangeRateState (status, pair, selectedDays, trend, selectedPoint)│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Injects / Calls UseCase
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│              Domain Layer (Clean Architecture — Reused 100%)           │
│  - GetExchangeRateTrendUseCase                                         │
│  - Entities: ExchangeRateTrend, RatePoint, CurrencyPair, Failures      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. การสร้างและกำหนด Design Tokens & Theme (Core Theme Implementation)

จัดวางไว้ในโฟลเดอร์กลาง `lib/core/theme/` เพื่อให้สามารถใช้ซ้ำได้ทั่วทั้งแอปพลิเคชัน

### 2.1 Color Tokens: `lib/core/theme/app_colors.dart`

แมปค่าสี Hex ตาม Figma Token Node 71-172 และข้อกำหนด Semantic Colors:

```dart
// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand & Accent
  static const Color brandPrimary = Color(0xFF2450D0); // สีแบรนด์หลัก, เส้นกราฟ, ลิงก์
  static const Color brandSubtle = Color(0xFFEBF1FF);  // พื้นหลังไอคอน/ปุ่มแบบบาง

  // Typography & Neutral
  static const Color textPrimary = Color(0xFF171B21);   // ข้อความหลัก, หัวข้อ, ตัวเลขสถิติ
  static const Color textSecondary = Color(0xFF525C6A); // ข้อความรอง, หน่วย, คำอธิบายย่อย
  static const Color textDisabled = Color(0xFF9AA2AF);  // ข้อความที่ไม่พร้อมทำงาน

  // Backgrounds & Surface
  static const Color bgScreen = Color(0xFFF7F8FA);     // พื้นหลังหน้าจอทั้งหมด
  static const Color bgSurface = Color(0xFFFFFFFF);    // พื้นหลังการ์ด (Card Surface)
  static const Color bgSubtle = Color(0xFFEEF0F3);     // พื้นหลัง Segmented Control / กล่องรายละเอียด

  // Borders & Dividers
  static const Color borderDefault = Color(0xFFDDE1E7); // เส้นขอบการ์ด, เส้นกริดกราฟประ
  static const Color borderSubtle = Color(0xFFEDF0F4);

  // Status & Trend (Semantic)
  static const Color statusUp = Color(0xFF10B981);       // ป้าย "สูงขึ้น" (Green Alternative: #059669)
  static const Color statusUpSubtle = Color(0xFFE8FDF5); // พื้นหลัง Badge สูงขึ้น
  static const Color statusDown = Color(0xFFEF4444);     // ป้าย "ลดลง" (Red/Orange: #DC2626 / #C2410C)
  static const Color statusDownSubtle = Color(0xFFFEECEC); // พื้นหลัง Badge ลดลง
  static const Color statusNeutral = Color(0xFF525C6A);  // ป้าย "ทรงตัว"
  static const Color statusNeutralSubtle = Color(0xFFF1F3F5); // พื้นหลัง Badge ทรงตัว
}
```

### 2.2 Typography Styles: `lib/core/theme/app_typography.dart`

ใช้ `GoogleFonts.ibmPlexSansThai` ทุก Text Style เพื่อให้สระภาษาไทยและวรรณยุกต์แสดงผลได้ถูกต้องและไม่กระตุก:

```dart
// lib/core/theme/app_typography.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTypography {
  // Title (24px, SemiBold 600, Line-height 34px)
  static final TextStyle title = GoogleFonts.ibmPlexSansThai(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 34.0 / 24.0,
    color: AppColors.textPrimary,
  );

  // Heading (20px, SemiBold 600, Line-height 30px)
  static final TextStyle heading = GoogleFonts.ibmPlexSansThai(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 30.0 / 20.0,
    color: AppColors.textPrimary,
  );

  // Body / Large (18px, Regular 400, Line-height 28px)
  static final TextStyle bodyLarge = GoogleFonts.ibmPlexSansThai(
    fontSize: 18.0,
    fontWeight: FontWeight.w400,
    height: 28.0 / 18.0,
    color: AppColors.textPrimary,
  );

  // Body / Default (16px, Regular 400, Line-height 24px)
  static final TextStyle bodyDefault = GoogleFonts.ibmPlexSansThai(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    height: 24.0 / 16.0,
    color: AppColors.textPrimary,
  );

  // Body / Small (14px, Regular 400, Line-height 20px)
  static final TextStyle bodySmall = GoogleFonts.ibmPlexSansThai(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    height: 20.0 / 14.0,
    color: AppColors.textSecondary,
  );

  // Label / Small (14px, Medium 500, Line-height 20px)
  static final TextStyle labelSmall = GoogleFonts.ibmPlexSansThai(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 20.0 / 14.0,
    color: AppColors.textPrimary,
  );

  // Stat / Value (22px, SemiBold 600, Line-height 28px)
  static final TextStyle statValue = GoogleFonts.ibmPlexSansThai(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    height: 28.0 / 22.0,
    color: AppColors.textPrimary,
  );
}
```

### 2.3 Application ThemeData: `lib/core/theme/app_theme.dart`

กำหนดธีมระบบ (Material 3 Light Theme) รองรับ Component Theme กลาง:

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgScreen,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandPrimary,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: GoogleFonts.ibmPlexSansThai().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgScreen,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: false,
        titleTextStyle: AppTypography.title,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.bgSurface,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.0),
          side: const BorderSide(color: AppColors.borderDefault, width: 1.0),
        ),
      ),
    );
  }
}
```

---

## 3. การขยายความสามารถ Utility: `lib/core/utils/date_formatter.dart`

เพิ่มฟังก์ชัน `formatThaiShortDate(DateTime date)` เพื่อรองรับการแสดงผลชื่อเดือนย่อภาษาไทยสำหรับ:
1. ป้ายกำกับบนแกน X ของกราฟ (BR-5): วันแรก, วันกลาง, วันสุดท้าย (เช่น `29 ก.ย.`, `14 ต.ค.`, `29 ต.ค.`)
2. แถวรายละเอียดจุดที่แตะ (15-1a / AC-3): `10 ต.ค. · 33.570`

```dart
// lib/core/utils/date_formatter.dart
class DateFormatter {
  static const List<String> _thaiMonths = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  static String formatYMD(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// แปลง DateTime เป็นวันที่ย่อภาษาไทย เช่น 29 ก.ย., 14 ต.ค.
  static String formatThaiShortDate(DateTime date) {
    final day = date.day;
    final monthStr = _thaiMonths[date.month - 1];
    return '$day $monthStr';
  }

  static ({String from, String to}) calculateDateRange({
    required int days,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime.utc(current.year, current.month, current.day);
    final past = today.subtract(Duration(days: days));
    return (from: formatYMD(past), to: formatYMD(today));
  }
}
```

---

## 4. สถาปัตยกรรม State Management ด้วย Flutter Riverpod

### 4.1 State Model: `lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart`

```dart
// lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/exchange_rate_trend.dart';
import '../../domain/entities/rate_point.dart';

enum ExchangeRateStatus {
  initial,
  loading,
  success,
  empty,
  error,
}

class ExchangeRateState extends Equatable {
  final ExchangeRateStatus status;
  final CurrencyPair pair;
  final int selectedDays;
  final ExchangeRateTrend? trend;
  final RatePoint? selectedPoint; // จุดที่ผู้ใช้แตะบนกราฟ (Screen 15-1a)
  final String? errorMessage;

  const ExchangeRateState({
    this.status = ExchangeRateStatus.initial,
    this.pair = CurrencyPair.defaultPair, // USD -> THB
    this.selectedDays = 30,               // Default 30 วันตาม BR-2
    this.trend,
    this.selectedPoint,
    this.errorMessage,
  });

  ExchangeRateState copyWith({
    ExchangeRateStatus? status,
    CurrencyPair? pair,
    int? selectedDays,
    ExchangeRateTrend? trend,
    RatePoint? Function()? selectedPoint, // รองรับการเซ็ตกลับเป็น null
    String? errorMessage,
  }) {
    return ExchangeRateState(
      status: status ?? this.status,
      pair: pair ?? this.pair,
      selectedDays: selectedDays ?? this.selectedDays,
      trend: trend ?? this.trend,
      selectedPoint: selectedPoint != null ? selectedPoint() : this.selectedPoint,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        pair,
        selectedDays,
        trend,
        selectedPoint,
        errorMessage,
      ];
}
```

### 4.2 StateNotifier & Providers: `lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart`

```dart
// lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/exchange_rate_local_datasource.dart';
import '../../data/datasources/exchange_rate_remote_datasource.dart';
import '../../data/repositories/exchange_rate_repository_impl.dart';
import '../../domain/entities/currency_pair.dart';
import '../../domain/entities/rate_point.dart';
import '../../domain/repositories/exchange_rate_repository.dart';
import '../../domain/usecases/get_exchange_rate_trend_usecase.dart';
import 'exchange_rate_state.dart';

// --- Dependency Injection Providers ---

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

// --- StateNotifier Implementation ---

class ExchangeRateNotifier extends StateNotifier<ExchangeRateState> {
  final GetExchangeRateTrendUseCase _getExchangeRateTrendUseCase;

  ExchangeRateNotifier({
    required GetExchangeRateTrendUseCase getExchangeRateTrendUseCase,
  })  : _getExchangeRateTrendUseCase = getExchangeRateTrendUseCase,
        super(const ExchangeRateState());

  /// โหลดข้อมูลแนวโน้มอัตราแลกเปลี่ยน
  Future<void> loadTrend({CurrencyPair? pair, int? days}) async {
    final targetPair = pair ?? state.pair;
    final targetDays = days ?? state.selectedDays;

    state = state.copyWith(
      status: ExchangeRateStatus.loading,
      pair: targetPair,
      selectedDays: targetDays,
      selectedPoint: () => null, // รีเซ็ตจุดที่แตะค้างไว้เมื่อโหลดใหม่
      errorMessage: null,
    );

    final result = await _getExchangeRateTrendUseCase(
      pair: targetPair,
      days: targetDays,
    );

    result.fold(
      (failure) {
        if (failure is EmptyDataFailure) {
          state = state.copyWith(
            status: ExchangeRateStatus.empty,
            errorMessage: failure.message,
          );
        } else {
          state = state.copyWith(
            status: ExchangeRateStatus.error,
            errorMessage: failure.message,
          );
        }
      },
      (trend) {
        state = state.copyWith(
          status: ExchangeRateStatus.success,
          trend: trend,
          selectedPoint: () => null,
          errorMessage: null,
        );
      },
    );
  }

  /// สลับช่วงเวลา 7, 30, 90 วัน (BR-2)
  void changePeriod(int days) {
    if (state.status == ExchangeRateStatus.loading) return; // ล็อกขณะโหลด
    if (state.selectedDays == days && state.status == ExchangeRateStatus.success) return;
    loadTrend(days: days);
  }

  /// แตะเลือกจุดบนกราฟ (Screen 15-1a / AC-3)
  void selectPoint(RatePoint? point) {
    state = state.copyWith(selectedPoint: () => point);
  }

  /// ลองดึงข้อมูลใหม่อีกครั้ง (Retry)
  void retry() {
    loadTrend(pair: state.pair, days: state.selectedDays);
  }
}
```

---

## 5. ข้อมูลจำเพาะของ Widgets และหน้าจอ (Screen & Widget Specifications)

### 5.1 Main Screen: `lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart`

- **Responsive Container:**
  - บนมือถือ (Handheld 360 × 780): เต็มความกว้างหน้าจอ Padding แนวนอน 16px
  - บนแท็บเล็ต (Tablet 834 × 1194): จัดกึ่งกลางหน้าจอ ล็อกความกว้างสูงสุดไว้ที่ 600px ด้วย `ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600))`
- **Lifecycle & Initial Load:**
  - เรียก `loadTrend()` ใน `initState` ผ่าน `ref.read(exchangeRateNotifierProvider.notifier).loadTrend()`
- **โครงสร้าง Scaffold:**
  - `AppBar`: แสดงชื่อ "แนวโน้มอัตราแลกเปลี่ยน" (Style: `AppTypography.title`)
  - `SingleChildScrollView`: รองรับหน้าจอขนาดเล็ก (Small Mobile 320 × 568) โดยไม่เกิด RenderFlex Overflow
  - `RefreshIndicator`: เลื่อนดึงหน้าจอเพื่อ Refresh โหลดข้อมูลใหม่

```dart
// lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
  ConsumerState<ExchangeRateTrendScreen> createState() => _ExchangeRateTrendScreenState();
}

class _ExchangeRateTrendScreenState extends ConsumerState<ExchangeRateTrendScreen> {
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
        title: const Text('แนวโน้มอัตราแลกเปลี่ยน'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    const SizedBox(height: 12.0),

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

  Widget _buildStateContent(ExchangeRateState state, ExchangeRateNotifier notifier) {
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
            const SizedBox(height: 8.0),

            // FR-7 (Screen 15-1a): แถวแสดงวันที่และเรตเมื่อแตะจุด
            if (state.selectedPoint != null) ...[
              DatePointDetailRow(point: state.selectedPoint!),
              const SizedBox(height: 12.0),
            ] else ...[
              const SizedBox(height: 12.0),
            ],

            // FR-5: 2 Stat Cards แนวนอน (สูงสุด / ต่ำสุด)
            Row(
              children: [
                Expanded(
                  child: StatCardCompact(
                    label: 'สูงสุด',
                    rate: trend.maxRate,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: StatCardCompact(
                    label: 'ต่ำสุด',
                    rate: trend.minRate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // FR-6: Trend Summary Data Row (% และ Level Badge)
            TrendSummaryRow(
              days: state.selectedDays,
              changePercentage: trend.changePercentage,
              direction: trend.trendDirection,
            ),
          ],
        );
    }
  }
}
```

---

### 5.2 Currency Selector Card: `lib/features/exchange_rate/presentation/widgets/currency_selector_card.dart`

- **ข้อกำหนด (FR-2):** แสดงคู่สกุลเงิน เช่น `USD → THB` พร้อม Chevron Icon ด้านขวา แตะแล้วมี InkWell Ripple Effect เพื่อเตรียมนักพัฒนาไป Screen 15-2
- **ดีไซน์:** กรอบโค้งมน 14px, เส้นขอบ `1px solid #DDE1E7`, พื้นหลัง `#FFFFFF`

```dart
// lib/features/exchange_rate/presentation/widgets/currency_selector_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/currency_pair.dart';

class CurrencySelectorCard extends StatelessWidget {
  final CurrencyPair pair;
  final VoidCallback? onTap;

  const CurrencySelectorCard({
    super.key,
    required this.pair,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSurface,
      borderRadius: BorderRadius.circular(14.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: AppColors.borderDefault, width: 1.0),
          ),
          child: Row(
            children: [
              Text(
                '${pair.base} → ${pair.quote}',
                style: AppTypography.heading,
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 5.3 Period Segmented Control: `lib/features/exchange_rate/presentation/widgets/period_segmented_control.dart`

- **ข้อกำหนด (FR-3, BR-2):** ตัวเลือก 3 ช่วง `7 วัน`, `30 วัน` (Default), และ `90 วัน`
- **การล็อกสถานะ:** หากกำลังโหลด (`isLoading == true`) ห้ามให้กดเปลี่ยนแท็บซ้ำ
- **ดีไซน์:** คอนเทนเนอร์มน 12px พื้นหลัง `#EEF0F3` แท็บที่ถูกเลือกพื้นหลัง `#FFFFFF` เงาบางและเส้นขอบเบา

```dart
// lib/features/exchange_rate/presentation/widgets/period_segmented_control.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class PeriodSegmentedControl extends StatelessWidget {
  final int selectedDays;
  final bool isLoading;
  final ValueChanged<int> onPeriodSelected;

  const PeriodSegmentedControl({
    super.key,
    required this.selectedDays,
    required this.isLoading,
    required this.onPeriodSelected,
  });

  static const List<int> _periods = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: _periods.map((days) {
          final isSelected = selectedDays == days;
          return Expanded(
            child: GestureDetector(
              onTap: isLoading ? null : () => onPeriodSelected(days),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.bgSurface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$days วัน',
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

---

### 5.4 Trend Line Chart: `lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart`

- **ข้อกำหนด (FR-4 & FR-7):**
  - แสดงกราฟเส้นเดี่ยวสี `#2450D0` ความหนา 2.5px
  - แกน X (BR-5): แสดง 3 ป้ายกำกับ — จุดแรก (index 0), จุดกลาง (`length ~/ 2`), และจุดท้าย (`length - 1`) ด้วย `DateFormatter.formatThaiShortDate(date)`
  - แกน Y (BR-5): แสดง 3 ค่า — ต่ำสุด, กลาง `((min + max) / 2)`, และสูงสุด ปัดทศนิยม 2 ตำแหน่ง
  - เส้นกริดประสี `#DDE1E7` ในแนวนอน
  - แตะจุด (Screen 15-1a): ดักจับ `LineTouchData.touchCallback` ส่ง `RatePoint` ที่แตะไปยัง callback `onPointSelected`
  - หาก `selectedPoint` ไม่ใช่ null ให้วาดวงกลมไฮไลท์ตรงพิกัดจุดนั้น

```dart
// lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart
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

    // ระยะ Margin สำหรับแกน Y
    final yRange = (maxRate - minRate).abs();
    final yPadding = yRange > 0 ? yRange * 0.1 : 0.1;
    final chartMinY = minRate - yPadding;
    final chartMaxY = maxRate + yPadding;

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
          minY: chartMinY,
          maxY: chartMaxY,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
              if (event is FlTapUpEvent || event is FlPanUpdateEvent) {
                if (touchResponse != null &&
                    touchResponse.lineBarSpots != null &&
                    touchResponse.lineBarSpots!.isNotEmpty) {
                  final spotIndex = touchResponse.lineBarSpots!.first.spotIndex;
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
            horizontalInterval: yRange > 0 ? yRange / 2 : 1.0,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.borderDefault,
              strokeWidth: 1.0,
              dashArray: [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 46.0,
                interval: yRange > 0 ? yRange / 2 : 1.0,
                getTitlesWidget: (value, meta) {
                  // แสดง 3 ค่าตาม BR-5: ต่ำสุด, กลาง, สูงสุด
                  final midRate = (minRate + maxRate) / 2.0;
                  final isMin = (value - minRate).abs() < (yRange * 0.15);
                  final isMid = (value - midRate).abs() < (yRange * 0.15);
                  final isMax = (value - maxRate).abs() < (yRange * 0.15);

                  if (isMin) {
                    return Text(minRate.toStringAsFixed(2), style: AppTypography.bodySmall);
                  } else if (isMid) {
                    return Text(midRate.toStringAsFixed(2), style: AppTypography.bodySmall);
                  } else if (isMax) {
                    return Text(maxRate.toStringAsFixed(2), style: AppTypography.bodySmall);
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

                  // แสดง 3 ป้ายกำกับตาม BR-5: แรก, กลาง, ท้าย
                  if (index == firstIdx || index == midIdx || index == lastIdx) {
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
                  // แสดงจุดกลมเฉพาะ index ที่ผู้ใช้แตะเลือก
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
                color: AppColors.brandPrimary.withOpacity(0.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5.5 Date Point Detail Row: `lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart`

- **ข้อกำหนด (FR-7 / Screen 15-1a / AC-3):** เมื่อแตะจุดของวันที่ 10 ต.ค. จะปรากฏแถวแสดงข้อความ `10 ต.ค. · 33.570` (ฟอร์แมต: วันที่ย่อไทย · อัตราแลกเปลี่ยนทศนิยม 3 หรือ 4 ตำแหน่ง)

```dart
// lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/rate_point.dart';

class DatePointDetailRow extends StatelessWidget {
  final RatePoint point;

  const DatePointDetailRow({
    super.key,
    required this.point,
  });

  @override
  Widget build(BuildContext context) {
    final thaiDate = DateFormatter.formatThaiShortDate(point.date);
    final rateStr = point.rate.toStringAsFixed(3);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppColors.bgSubtle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.0,
            height: 8.0,
            decoration: const BoxDecoration(
              color: AppColors.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8.0),
          Text(
            '$thaiDate · $rateStr',
            style: AppTypography.bodyDefault.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6.0),
          Text(
            point.quote,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}
```

---

### 5.6 Stat Card Compact: `lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart`

- **ข้อกำหนด (FR-5):** การ์ดแสดงค่าสูงสุด และ ต่ำสุด ในช่วงเวลา กรอบมน 14px เส้นขอบ `#DDE1E7` ตัวเลขทศนิยม 3 ตำแหน่ง เช่น `33.750`

```dart
// lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class StatCardCompact extends StatelessWidget {
  final String label;
  final double rate;

  const StatCardCompact({
    super.key,
    required this.label,
    required this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 4.0),
          Text(
            rate.toStringAsFixed(3),
            style: AppTypography.statValue,
          ),
        ],
      ),
    );
  }
}
```

---

### 5.7 Trend Summary Row: `lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart`

- **ข้อกำหนด (FR-6, BR-3, BR-4, AC-2):**
  - ข้อความระบุช่วง: "เปลี่ยนแปลง {N} วัน" (เช่น `เปลี่ยนแปลง 30 วัน`)
  - ค่า %: เครื่องหมายบวก/ลบ เช่น `+0.54%` ทศนิยม 2 ตำแหน่ง
  - Level Badge (Pill Radius 999px):
    - `up`: ไอคอน `arrow_upward` + ข้อความ "สูงขึ้น" (สีเขียว `#10B981` หรือ `#059669`)
    - `down`: ไอคอน `arrow_downward` + ข้อความ "ลดลง" (สีแดง/ส้ม `#EF4444` หรือ `#DC2626`)
    - `neutral`: ไอคอน `remove` + ข้อความ "ทรงตัว" (สีเทา `#525C6A`)

```dart
// lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/exchange_rate_trend.dart';

class TrendSummaryRow extends StatelessWidget {
  final int days;
  final double changePercentage;
  final TrendDirection direction;

  const TrendSummaryRow({
    super.key,
    required this.days,
    required this.changePercentage,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeText, badgeIcon, textColor, bgColor) = switch (direction) {
      TrendDirection.up => (
          'สูงขึ้น',
          Icons.arrow_upward,
          AppColors.statusUp,
          AppColors.statusUpSubtle,
        ),
      TrendDirection.down => (
          'ลดลง',
          Icons.arrow_downward,
          AppColors.statusDown,
          AppColors.statusDownSubtle,
        ),
      TrendDirection.neutral => (
          'ทรงตัว',
          Icons.remove,
          AppColors.statusNeutral,
          AppColors.statusNeutralSubtle,
        ),
    };

    final prefix = changePercentage > 0 ? '+' : '';
    final formattedPercent = '$prefix${changePercentage.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Row(
        children: [
          Text(
            'เปลี่ยนแปลง $days วัน',
            style: AppTypography.bodyDefault.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            formattedPercent,
            style: AppTypography.heading.copyWith(
              color: textColor,
            ),
          ),
          const SizedBox(width: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(999.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  badgeIcon,
                  size: 14.0,
                  color: textColor,
                ),
                const SizedBox(width: 4.0),
                Text(
                  badgeText,
                  style: AppTypography.labelSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 5.8 Source Note Widget: `lib/features/exchange_rate/presentation/widgets/source_note_widget.dart`

- **ข้อกำหนด (FR-8, AC-6):** แถบด้านล่างสุดแสดง "ข้อมูลจาก Frankfurter API" พร้อมไอคอน Open in New แตะแล้วเปิด URL `https://frankfurter.dev` ด้วย `url_launcher`

```dart
// lib/features/exchange_rate/presentation/widgets/source_note_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class SourceNoteWidget extends StatelessWidget {
  const SourceNoteWidget({super.key});

  static const String frankfurterUrl = 'https://frankfurter.dev';

  Future<void> _openSourceUrl() async {
    final uri = Uri.parse(frankfurterUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: _openSourceUrl,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'ข้อมูลจาก Frankfurter API',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4.0),
              const Icon(
                Icons.open_in_new,
                size: 14.0,
                color: AppColors.brandPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### 5.9 Widgets สำหรับ 4 สถานะ (Screen State Widgets)

#### 1) Loading State Widget: `lib/features/exchange_rate/presentation/widgets/states/loading_state_widget.dart`
- ปรากฏตรงกลางพื้นที่แสดงกราฟและสถิติ (Screen 15-1b)

```dart
// lib/features/exchange_rate/presentation/widgets/states/loading_state_widget.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class LoadingStateWidget extends StatelessWidget {
  const LoadingStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.0,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.brandPrimary,
            ),
            const SizedBox(height: 16.0),
            Text(
              'กำลังโหลดข้อมูล...',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 2) Empty State Widget: `lib/features/exchange_rate/presentation/widgets/states/empty_state_widget.dart`
- ปรากฏเมื่อได้รับข้อมูลว่างเปล่า (Screen 15-1c, BR-6)

```dart
// lib/features/exchange_rate/presentation/widgets/states/empty_state_widget.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;

  const EmptyStateWidget({
    super.key,
    this.message = 'ไม่มีข้อมูลในช่วงนี้',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.0,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bar_chart_outlined,
              size: 48.0,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: AppTypography.bodyDefault.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

#### 3) Error State Widget: `lib/features/exchange_rate/presentation/widgets/states/error_state_widget.dart`
- ปรากฏเมื่อเกิดข้อผิดพลาดในการดึงข้อมูล พร้อมปุ่ม Retry (Screen 15-1d)

```dart
// lib/features/exchange_rate/presentation/widgets/states/error_state_widget.dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260.0,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppColors.borderDefault, width: 1.0),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48.0,
              color: AppColors.statusDown,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: AppTypography.bodyDefault.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18.0),
              label: const Text('ลองอีกครั้ง'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. การปรับปรุง Entry Point: `lib/main.dart`

ลบ Boilerplate Flutter Counter App ออก และตั้งค่า `ProviderScope`, `AppTheme.lightTheme` และ `ExchangeRateTrendScreen`:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ExchangeRateApp(),
    ),
  );
}

class ExchangeRateApp extends StatelessWidget {
  const ExchangeRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exchange Rate Trend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const ExchangeRateTrendScreen(),
    );
  }
}
```

---

## 7. ตารางสรุปไฟล์ที่จะสร้างใหม่และแก้ไข (File Manifest)

| หมวดหมู่ | ตำแหน่งไฟล์เป้าหมาย (Path ใน `app/`) | สถานะ | หน้าที่รับผิดชอบ |
|---|---|:---:|---|
| **Theme** | `lib/core/theme/app_colors.dart` | 🔴 **สร้างใหม่** | กำหนดรหัสสี Color Tokens ทุกตัวตาม Figma |
| **Theme** | `lib/core/theme/app_typography.dart` | 🔴 **สร้างใหม่** | กำหนด Text Styles ทั้งหมดด้วย `GoogleFonts.ibmPlexSansThai` |
| **Theme** | `lib/core/theme/app_theme.dart` | 🔴 **สร้างใหม่** | กำหนด Material 3 ThemeData สำหรับแอปพลิเคชัน |
| **Utility** | `lib/core/utils/date_formatter.dart` | 🟡 **แก้ไข** | เพิ่มฟังก์ชัน `formatThaiShortDate(DateTime date)` |
| **State** | `lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart` | 🔴 **สร้างใหม่** | Model เก็บสถานะหน้าจอ 4 สถานะ และจุดที่เลือก |
| **Provider** | `lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart` | 🔴 **สร้างใหม่** | Riverpod StateNotifier และ Dependency Injection |
| **Screen** | `lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart` | 🔴 **สร้างใหม่** | Scaffold Responsive Container (360px & max 600px) สลับสถานะหน้าจอ |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/currency_selector_card.dart` | 🔴 **สร้างใหม่** | แสดงคู่สกุลเงิน `USD → THB` พร้อม Chevron (FR-2) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/period_segmented_control.dart` | 🔴 **สร้างใหม่** | ตัวเลือกช่วงเวลา 7, 30, 90 วัน (FR-3, BR-2) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart` | 🔴 **สร้างใหม่** | กราฟเส้น `fl_chart` พร้อมแกน X/Y 3 จุด และ Touch Callback (FR-4, FR-7) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart` | 🔴 **สร้างใหม่** | การ์ดแสดงค่า สูงสุด / ต่ำสุด ในช่วงเวลา (FR-5) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart` | 🔴 **สร้างใหม่** | แถวสรุป % และ Level Badge สูงขึ้น/ลดลง/ทรงตัว (FR-6, BR-3, BR-4) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart` | 🔴 **สร้างใหม่** | แสดงผล `10 ต.ค. · 33.570` เมื่อแตะจุดบนกราฟ (FR-7, AC-3) |
| **Widget** | `lib/features/exchange_rate/presentation/widgets/source_note_widget.dart` | 🔴 **สร้างใหม่** | แสดงแหล่งข้อมูล Frankfurter API พร้อม `url_launcher` (FR-8, AC-6) |
| **Widget State**| `lib/features/exchange_rate/presentation/widgets/states/loading_state_widget.dart` | 🔴 **สร้างใหม่** | แสดงสถานะกำลังโหลด (Screen 15-1b) |
| **Widget State**| `lib/features/exchange_rate/presentation/widgets/states/empty_state_widget.dart` | 🔴 **สร้างใหม่** | แสดงสถานะข้อมูลว่างเปล่า (Screen 15-1c, BR-6) |
| **Widget State**| `lib/features/exchange_rate/presentation/widgets/states/error_state_widget.dart` | 🔴 **สร้างใหม่** | แสดงสถานะเกิดข้อผิดพลาดพร้อมปุ่มลองอีกครั้ง (Screen 15-1d) |
| **Main App** | `lib/main.dart` | 🟡 **แก้ไข** | ครอบด้วย `ProviderScope`, ใช้งาน `AppTheme` และตั้งหน้าจอหลัก |

---

## 8. กลยุทธ์การทดสอบฝั่งหน้าจอ (Frontend Testing Alignment)

สเปคในเอกสารนี้สอดคล้องกับแผนการทดสอบอัตโนมัติ (Automated Tests) ที่กำหนดไว้สำหรับ Stage B & Stage C:
1. **Unit Test สำหรับ `ExchangeRateNotifier` (`exchange_rate_notifier_test.dart`):**
   - ทดสอบ Initial State: status = initial, pair = USD/THB, selectedDays = 30
   - ทดสอบ `loadTrend()` โหลดสำเร็จ -> status = success, trend มีข้อมูลถูกต้อง
   - ทดสอบ `loadTrend()` โหลดล้มเหลว -> EmptyDataFailure -> status = empty, NetworkFailure -> status = error
   - ทดสอบ `changePeriod(int days)` สลับช่วงวันและโหลดใหม่
   - ทดสอบ `selectPoint(RatePoint)` อัปเดต selectedPoint ใน state
2. **Widget Test สำหรับ `TrendLineChart` (`trend_line_chart_test.dart`):**
   - ตรวจสอบการพล็อตจุด `FlSpot` บนกราฟ
   - ตรวจสอบป้ายกำกับแกน X (แรก, กลาง, ท้าย) และแกน Y (ต่ำสุด, กลาง, สูงสุด)
   - จำลอง Tap Event บนกราฟและตรวจว่า Callback `onPointSelected` ทำงานถูกต้อง
3. **Screen Widget Integration Test (`exchange_rate_trend_screen_test.dart`):**
   - ทดสอบการแสดงผลหน้าจอครบตาม AC-1 (AppBar, Currency Card, Period Control, Chart, Stat Cards, Summary Row, Source Note)
   - ทดสอบ AC-2 (แสดงผล % เช่น `+0.54%` และ Badge "สูงขึ้น")
   - ทดสอบ AC-3 (แตะจุดวันที่ 10 ต.ค. แล้วแสดง `10 ต.ค. · 33.570`)
   - ทดสอบ AC-6 (แตะ Source Note แล้วเรียก `launchUrl`)
   - ทดสอบการสลับ 4 สถานะ (Loading, Success, Empty, Error พร้อมกด Retry)
4. **Smoke Test (`test/widget_test.dart`):**
   - ตรวจสอบว่าแอปเปิดขึ้นมาพร้อม `ExchangeRateTrendScreen` ได้อย่างราบรื่น

---

อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
