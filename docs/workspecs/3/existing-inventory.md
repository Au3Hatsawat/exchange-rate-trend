# รายงานการสำรวจโค้ดเดิมและส่วนประกอบที่มีอยู่ (Existing Codebase Inventory)

> **ใบงานที่สำรวจ:** Issue #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **สำรวจโดย:** Subagent `codebase-scout`  
> **วันที่สำรวจ:** 2026-11-04  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4, §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **เอกสารตั้งต้น:** [`workspec-fe.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-fe.md) · [`workspec-be.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-be.md) · [`design.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md)

---

## 1. ภาพรวมสถานะ Codebase ปัจจุบัน (Current Codebase Snapshot)

จากการสำรวจโครงสร้างไดเรกทอรี `app/` ทั้งหมดใน `lib/`, `test/`, ตลอดจน `pubspec.yaml` พบว่า:

1. **แกนหลัก Data & Domain จาก Issue #2 พัฒนาเสร็จสมบูรณ์ 100%:**
   - โครงสร้าง Clean Architecture ฝั่ง Data และ Domain พร้อมใช้งาน มี Unit Tests ครอบคลุม 28 เคส (Domain UseCases, Repositories, DataSources, Models, Utils, Network)
   - มีระบบ Daily In-Memory Caching (`ExchangeRateLocalDataSource`) รองรับข้อกำหนด AC-4 สลับช่วงเวลาโดยไม่ยิงซ้ำ
   - มีระบบคำนวณเปอร์เซ็นต์การเปลี่ยนแปลง และทิศทางแนวโน้ม (`TrendCalculator`) ตรงตามเกณฑ์ BR-3 และ BR-4
2. **สถานะ Presentation Layer:**
   - ยังไม่มีโค้ด Presentation Layer ของฟีเจอร์ Exchange Rate เลย
   - `lib/main.dart` ยังคงเป็น Flutter Counter App เริ่มต้น (`MyHomePage`) ที่มีปุ่มบวกและตัวนับ
   - `lib/core/theme/` ยังไม่มีโฟลเดอร์นี้ ต้องสร้าง Design Tokens (Colors, Typography, ThemeData) ขึ้นใหม่ทั้งหมด
3. **สถานะ Dependencies ใน `pubspec.yaml`:**
   - มีแพ็กเกจที่จำเป็นสำหรับ Presentation Layer ครบถ้วน ไม่ต้องเพิ่มไลบรารีใหม่:
     - `flutter_riverpod: ^2.5.1` (State Management)
     - `fl_chart: ^0.68.0` (Line Chart สำหรับแสดงกราฟแนวโน้ม)
     - `google_fonts: ^6.2.1` (ฟอนต์ IBM Plex Sans Thai)
     - `url_launcher: ^6.3.0` (สำหรับเปิดลิงก์ Frankfurter API ตาม AC-6)
     - `intl: ^0.19.0` (ฟอร์แมตวันที่และตัวเลข)
     - `equatable: ^2.0.5` (State & Entity Equality)
     - `mocktail: ^1.0.4` (สำหรับ Widget / Unit Tests)

---

## 2. ตารางสรุปสิ่งที่มีอยู่แล้ว vs สิ่งที่ต้องสร้างใหม่ (Inventory Breakdown)

### 2.1 ส่วนประกอบเดิมจาก Issue #2 ที่นำกลับมาใช้ซ้ำได้ 100% (Reusable Assets)

| ชิ้นส่วน / คลาส | ตำแหน่งไฟล์ใน `app/lib/` | สถานะ | บทบาทและจุดเชื่อมต่อกับ Screen 15-1 / 15-1a |
|---|---|:---:|---|
| **`CurrencyPair`** | `features/exchange_rate/domain/entities/currency_pair.dart` | 🟢 **ใช้ซ้ำ 100%** | โมเดลคู่สกุลเงิน มี `CurrencyPair.defaultPair` (`USD/THB`) ใช้เป็นค่าตั้งต้นของ `CurrencySelectorCard` |
| **`RatePoint`** | `features/exchange_rate/domain/entities/rate_point.dart` | 🟢 **ใช้ซ้ำ 100%** | โมเดลจุดข้อมูล (`date`, `rate`, `base`, `quote`) ใช้แปลงเป็นพิกัด `FlSpot` บน `fl_chart` และแสดงในแถวรายละเอียดจุดสัมผัส (15-1a) |
| **`ExchangeRateTrend`** | `features/exchange_rate/domain/entities/exchange_rate_trend.dart` | 🟢 **ใช้ซ้ำ 100%** | เอนทิตีหลักบรรจุ `points`, `maxRate`, `minRate`, `changePercentage`, `trendDirection` ส่งตรงสู่ Stat Cards และ Trend Summary Row |
| **`TrendDirection`** | `features/exchange_rate/domain/entities/exchange_rate_trend.dart` | 🟢 **ใช้ซ้ำ 100%** | Enum (`up`, `down`, `neutral`) นำมาแมปกับ Level Badge และไอคอนลูกศร |
| **`GetExchangeRateTrendUseCase`** | `features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart` | 🟢 **ใช้ซ้ำ 100%** | สัญญาหลักสำหรับโหลดข้อมูลแนวโน้ม รองรับพารามิเตอร์ `pair` และ `days` (7, 30, 90) ถูกฉีดเข้า `ExchangeRateNotifier` |
| **`ExchangeRateRepository`** | `features/exchange_rate/domain/repositories/exchange_rate_repository.dart` | 🟢 **ใช้ซ้ำ 100%** | อินเทอร์เฟซคลังข้อมูล คืนค่า `Future<Either<Failure, ExchangeRateTrend>>` |
| **`ExchangeRateRepositoryImpl`** | `features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart` | 🟢 **ใช้ซ้ำ 100%** | คลาสประสานงาน Data Sources พร้อมคำนวณและแคชข้อมูลอัตโนมัติ |
| **`ExchangeRateLocalDataSource`** | `features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart` | 🟢 **ใช้ซ้ำ 100%** | ระบบแคชข้อมูลรายวันในหน่วยความจำ จัดการ AC-4 ไม่ยิงเน็ตซ้ำ |
| **`ExchangeRateRemoteDataSource`** | `features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart` | 🟢 **ใช้ซ้ำ 100%** | API Client ดึงเรตย้อนหลังจาก Frankfurter API ผ่าน Dio |
| **`DioClient` & `ApiEndpoints`** | `core/network/` | 🟢 **ใช้ซ้ำ 100%** | โครงข่าย HTTP Client พร้อม Base Options และ Timeouts |
| **`Either<L, R>` & `Failures`** | `core/errors/failures.dart` | 🟢 **ใช้ซ้ำ 100%** | Sealed class พร้อม `.fold()` และประเภทความล้มเหลว `NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, `CacheFailure` |
| **`TrendCalculator`** | `core/utils/trend_calculator.dart` | 🟢 **ใช้ซ้ำ 100%** | ฟังก์ชันคำนวณ % change, max, min, และทิศทางแนวโน้ม |

---

### 2.2 ยูทิลิตี้เดิมที่ต้องปรับปรุงต่อยอด (Utility Extensions)

| ชิ้นส่วน / คลาส | ตำแหน่งไฟล์ใน `app/lib/` | สถานะ | รายละเอียดที่ต้องเพิ่มเติม |
|---|---|:---:|---|
| **`DateFormatter`** | `core/utils/date_formatter.dart` | 🟡 **ต้องเพิ่มฟังก์ชัน** | เดิมมีเพียง `formatYMD` (`YYYY-MM-DD`) และ `calculateDateRange`<br>👉 **สิ่งที่ต้องเพิ่ม:** ฟังก์ชันแปลงวันที่เป็นภาษาไทยแบบย่อ `formatThaiShortDate(DateTime date)` เช่น `29 ก.ย.`, `14 ต.ค.`, `29 ต.ค.` สำหรับแกน X (BR-5) และแถวรายละเอียด 15-1a (AC-3: `10 ต.ค. · 33.570`) |

---

### 2.3 ชิ้นส่วน Design Tokens และ Core Theme ที่ต้องสร้างใหม่ (Core Theme Layer)

| ชิ้นส่วน / คลาส | ตำแหน่งไฟล์เป้าหมาย | สถานะ | วัตถุประสงค์และการนำไปใช้ |
|---|---|:---:|---|
| **`AppColors`** | `lib/core/theme/app_colors.dart` | 🔴 **ต้องสร้างใหม่** | จัดเก็บ Color Tokens ตาม Figma Node 71-172:<br>• `textPrimary` (`#171B21`)<br>• `textSecondary` (`#525C6A`)<br>• `brandPrimary` (`#2450D0`)<br>• `bgScreen` (`#F7F8FA`)<br>• `bgSurface` (`#FFFFFF`)<br>• `bgSubtle` (`#EEF0F3`)<br>• `borderDefault` (`#DDE1E7`)<br>• `statusUp` (`#059669` หรือ `#2450D0`)<br>• `statusDown` (`#DC2626` หรือ `#C2410C`)<br>• `statusNeutral` (`#525C6A`) |
| **`AppTypography`** | `lib/core/theme/app_typography.dart` | 🔴 **ต้องสร้างใหม่** | กำหนดสไตล์ตัวอักษรโดยใช้ `GoogleFonts.ibmPlexSansThai()`:<br>• `title`: 24px SemiBold 600 (Line Height 34px)<br>• `heading`: 20px SemiBold 600 (Line Height 30px)<br>• `bodyLarge`: 18px Regular 400 (Line Height 28px)<br>• `bodyDefault`: 16px Regular 400 (Line Height 24px)<br>• `bodySmall`: 14px Regular 400 (Line Height 20px)<br>• `labelSmall`: 14px Medium 500 (Line Height 20px) |
| **`AppTheme`** | `lib/core/theme/app_theme.dart` | 🔴 **ต้องสร้างใหม่** | กำหนด `ThemeData` รวมของแอปพลิเคชัน (Light Theme) ตั้งค่า `scaffoldBackgroundColor`, `appBarTheme`, `cardTheme`, ฟอนต์ดีฟอลต์ และสี Material ColorScheme |

---

### 2.4 ชิ้นส่วน Presentation Layer และ UI Widgets ที่ต้องสร้างใหม่ (Screen 15-1 & 15-1a)

```text
lib/features/exchange_rate/presentation/
├── providers/
│   ├── exchange_rate_state.dart          # 🔴 State Model & Status Enums
│   └── exchange_rate_provider.dart       # 🔴 Riverpod StateNotifier & DI Providers
├── screens/
│   └── exchange_rate_trend_screen.dart   # 🔴 Main Responsive Screen (15-1 & 15-1a)
└── widgets/
    ├── currency_selector_card.dart       # 🔴 FR-2: การ์ดแสดง USD → THB พร้อม Chevron
    ├── period_segmented_control.dart     # 🔴 FR-3: ปุ่มเลือกช่วง 7 วัน / 30 วัน / 90 วัน
    ├── trend_line_chart.dart             # 🔴 FR-4 & FR-7: กราฟ fl_chart + Touch Events
    ├── stat_card_compact.dart            # 🔴 FR-5: การ์ดสถิติ สูงสุด / ต่ำสุด
    ├── trend_summary_row.dart            # 🔴 FR-6: แถวสรุป % เปลี่ยนแปลง + Level Badge
    ├── date_point_detail_row.dart        # 🔴 FR-7 (15-1a): แถวแสดงวันที่และเรตเมื่อแตะจุด
    ├── source_note_widget.dart           # 🔴 FR-8 (AC-6): แถบ Frankfurter API + url_launcher
    └── states/
        ├── loading_state_widget.dart     # 🔴 15-1b: Loading Block Indicator
        ├── empty_state_widget.dart       # 🔴 15-1c: "ไม่มีข้อมูลในช่วงนี้"
        └── error_state_widget.dart       # 🔴 15-1d: "ดึงข้อมูลไม่สำเร็จ" + ปุ่ม Retry
```

| รายการคอมโพเนนต์ | ที่อยู่ไฟล์ | สถานะ | ขอบเขตหน้าที่ตามข้อกำหนด |
|---|---|:---:|---|
| `ExchangeRateState` | `presentation/providers/exchange_rate_state.dart` | 🔴 **ใหม่** | Model เก็บสถานะ (`status`, `pair`, `selectedDays`, `trend`, `selectedPoint`, `errorMessage`) |
| `ExchangeRateNotifier` & Providers | `presentation/providers/exchange_rate_provider.dart` | 🔴 **ใหม่** | จัดการ State ด้วย Riverpod, มีฟังก์ชัน `loadTrend()`, `changePeriod()`, `selectPoint()`, `retry()` พร้อม Dependency Injection |
| `ExchangeRateTrendScreen` | `presentation/screens/exchange_rate_trend_screen.dart` | 🔴 **ใหม่** | หน้าจอหลักรองรับ Responsive (Handheld 360px & Tablet max 600px กึ่งกลาง) สลับแสดงผล 4 สถานะ |
| `CurrencySelectorCard` | `presentation/widgets/currency_selector_card.dart` | 🔴 **ใหม่** | แสดงคู่สกุลเงิน ปัจจุบัน `USD → THB` พร้อม Chevron เพื่อเตรียมต่อยอดไป Screen 15-2 (FR-2) |
| `PeriodSegmentedControl` | `presentation/widgets/period_segmented_control.dart` | 🔴 **ใหม่** | ปุ่มสลับ 7 วัน / 30 วัน (Default) / 90 วัน ล็อกปุ่มขณะ Loading (FR-3, BR-2) |
| `TrendLineChart` | `presentation/widgets/trend_line_chart.dart` | 🔴 **ใหม่** | วาดกราฟเส้นเดี่ยวสี `#2450D0` ด้วย `fl_chart`, แกน X 3 จุด, แกน Y 3 จุด, ดัก Touch Event ส่งต่อให้ Notifier (FR-4, FR-7) |
| `StatCardCompact` | `presentation/widgets/stat_card_compact.dart` | 🔴 **ใหม่** | การ์ดคู่แสดงค่าสูงสุด/ต่ำสุด ทศนิยม 3-4 ตำแหน่ง กรอบมน 14px ขอบ `#DDE1E7` (FR-5) |
| `TrendSummaryRow` | `presentation/widgets/trend_summary_row.dart` | 🔴 **ใหม่** | ข้อความ "เปลี่ยนแปลง {N} วัน", ตัวเลข % เช่น `+0.54%`, Pill Badge สูงขึ้น/ลดลง/ทรงตัว (FR-6, BR-3, BR-4) |
| `DatePointDetailRow` | `presentation/widgets/date_point_detail_row.dart` | 🔴 **ใหม่** | ปรากฏเมื่อแตะจุดบนกราฟ (Screen 15-1a) แสดงวันที่และอัตรา เช่น `10 ต.ค. · 33.570` (FR-7, AC-3) |
| `SourceNoteWidget` | `presentation/widgets/source_note_widget.dart` | 🔴 **ใหม่** | แถบระบุที่มา Frankfurter API แตะแล้วเรียก `url_launcher` เปิด `https://frankfurter.dev` (FR-8, AC-6) |
| `LoadingStateWidget` | `presentation/widgets/states/loading_state_widget.dart` | 🔴 **ใหม่** | แสดงสถานะกำลังโหลด (15-1b) บริเวณกราฟ |
| `EmptyStateWidget` | `presentation/widgets/states/empty_state_widget.dart` | 🔴 **ใหม่** | แสดงเมื่อได้รับข้อมูลว่างเปล่า "ไม่มีข้อมูลในช่วงนี้" (15-1c, BR-6) |
| `ErrorStateWidget` | `presentation/widgets/states/error_state_widget.dart` | 🔴 **ใหม่** | แสดงเมื่อเกิด Network/Server Error "ดึงข้อมูลไม่สำเร็จ" พร้อมปุ่ม "ลองอีกครั้ง" (15-1d) |

---

### 2.5 จุดเชื่อมต่อกับ `lib/main.dart` (Application Entry Point)

| ไฟล์ | สถานะปัจจุบัน | การปรับเปลี่ยนที่ต้องทำ |
|---|---|---|
| `lib/main.dart` | 🟡 เป็น Flutter Counter App เดิม (`MyApp`, `MyHomePage`, `_counter`) | 1. ครอบ `runApp()` ด้วย `ProviderScope` ของ Riverpod<br>2. เปลี่ยน `theme` ใน `MaterialApp` เป็น `AppTheme.lightTheme`<br>3. เปลี่ยน `home:` จาก `MyHomePage` เป็น `ExchangeRateTrendScreen`<br>4. ลบคลาส `MyHomePage` และ `_MyHomePageState` ที่ไม่ใช้งานออก |

---

### 2.6 รายการชุดการทดสอบอัตโนมัติ (Automated Test Suite)

| ไฟล์ชุดทดสอบ | สถานะ | ขอบเขตการทดสอบ |
|---|:---:|---|
| `test/widget_test.dart` | 🟡 **มีอยู่เดิม (ต้องอัปเดต)** | เดิมทดสอบ Counter App ต้องปรับเป็น Smoke Test ตรวจสอบว่าแอปเปิดขึ้นมาพร้อม `ExchangeRateTrendScreen` ได้อย่างถูกต้อง |
| `test/features/exchange_rate/presentation/providers/exchange_rate_notifier_test.dart` | 🔴 **ต้องสร้างใหม่** | Unit Test ทดสอบพฤติกรรมของ `ExchangeRateNotifier`:<br>• สถานะเริ่มต้นและโหลดสำเร็จ (Data State)<br>• สลับช่วงเวลา 7, 30, 90 วัน<br>• ดักจับ EmptyDataFailure -> empty status<br>• ดักจับ NetworkFailure -> error status<br>• การเลือกจุดบนกราฟ (selectPoint) |
| `test/features/exchange_rate/presentation/widgets/trend_line_chart_test.dart` | 🔴 **ต้องสร้างใหม่** | Widget Test ทดสอบการเรนเดอร์ `fl_chart`, ตรวจสอบแกน X และ Y, และจำลองการแตะจุด (Touch Interaction 15-1a) |
| `test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | 🔴 **ต้องสร้างใหม่** | Widget Test รวมระดับหน้าจอ:<br>• AC-1: แสดงผลกราฟ, สถิติสูงสุด/ต่ำสุด, % การเปลี่ยนแปลง<br>• AC-2: ค่า +0.54% และป้าย "สูงขึ้น"<br>• AC-3: แตะจุดวันที่ 10 ต.ค. แสดงข้อความ "10 ต.ค. · 33.570"<br>• AC-6: ตรวจสอบการกดปุ่ม Frankfurter API เรียก `launchUrl`<br>• ทดสอบ 4 สถานะ (Loading, Success, Empty, Error) |

---

## 3. การวิเคราะห์กฎสถาปัตยกรรมและการเชื่อมต่อ (Architectural Constraints)

1. **การปฏิบัติตามกฎเลเยอร์ Clean Architecture (SDD §2):**
   - **Presentation Layer** (`lib/features/exchange_rate/presentation/`) จะต้องเรียกใช้เฉพาะ **Domain Layer** (`GetExchangeRateTrendUseCase`, `ExchangeRateTrend`, `RatePoint`, `CurrencyPair`, `failures.dart`) เท่านั้น
   - **ห้าม** Presentation Widgets เรียกใช้ `DioClient`, `RemoteDataSource`, หรือ `RatePointModel` โดยตรง
   - การประกอบ Dependency (Dependency Injection) จะกระทำผ่าน Riverpod Providers ใน `exchange_rate_provider.dart` ซึ่งเป็นจุดเดียวที่อ้างอิง `ExchangeRateRepositoryImpl`
2. **การคงอยู่ของ Unit Test Baseline:**
   - โค้ดที่พัฒนาใน Issue #2 ทั้ง 28 เคสจะไม่ถูกแก้ไขหรือกระทบกระเทือน (Zero Regression Risk)
3. **การออกแบบให้รองรับ Responsive Layout (SDD §1 & design.md):**
   - สำหรับหน้าจอมือถือ (Handheld 360 × 780): ใช้ความกว้างเต็มจอพร้อม Screen Padding 16px
   - สำหรับหน้าจอแท็บเล็ต (Tablet 834 × 1194): กำหนดข้อจำกัด `ConstrainedBox(constraints: BoxConstraints(maxWidth: 600))` จัดกึ่งกลางหน้าจอ ไม่ให้กราฟยืดกว้างจนเกินความพอดี

---

## 4. ข้อเสนอแนะสำหรับขั้นตอนถัดไปใน Stage B

- **สำหรับ `spec-fe.md`:** นำโครงสร้าง Component Hierarchy ทั้ง 13 วิดเจ็ต/ไฟล์ และ State Definition ในตารางข้อ 2.4 ไปใช้ออกแบบ Property, Callbacks, และ Responsive Constraints อย่างละเอียด
- **สำหรับ `spec-be.md`:** ยืนยันว่าฝั่ง Backend ไม่มีการแก้ไขโค้ดใหม่ (Zero BE Code Changes) และเตรียม Fixtures จำลอง `RatePoint` วันที่ 10 ต.ค. เรต 33.570 สำหรับ AC-3 ให้ฝั่ง Widget Test
- **สำหรับ `testplan.md`:** กำหนด Test Cases ครอบคลุมทั้ง Notifier Unit Test, Widget Component Test, Screen Integration Test, และ Manual Test บน 3 ขนาดหน้าจอ (320px, 360px, 834px)

---
อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
