# แผนการทดสอบเชิงเทคนิค (Technical Test Plan) — Issue #3: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **ผู้จัดทำ:** Subagent `test-author` (Planning Mode ใน Stage B)  
> **วันที่จัดทำ:** 2026-11-04  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4, §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **เอกสารอ้างอิง:**
> - สเปคฝั่งหน้าจอ: [`docs/workspecs/3/spec-fe.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-fe.md)
> - สเปคฝั่งเซอร์วิส/ข้อมูล: [`docs/workspecs/3/spec-be.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-be.md)
> - รายงานตรวจสัญญา: [`docs/workspecs/3/contract-report.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/contract-report.md)
> - สเปคงานดีไซน์: [`docs/workspecs/3/design.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md)
> - มาตรฐานการทดสอบ: [`docs/sdd/04-testing-guidelines.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/04-testing-guidelines.md)

---

## 1. บทสรุปและกลยุทธ์การทดสอบ (Test Strategy & Traceability Matrix)

แผนการทดสอบฉบับนี้จัดทำขึ้นตามข้อกำหนดของ **Software Development Discipline (SDD) Automation-First** เพื่อรองรับกระบวนการพัฒนาแบบ **Test-Driven Development (TDD: Red ➔ Green ➔ Refactor)** ใน Stage C โดยแปลง Functional Requirements (FR-1 ถึง FR-8), Acceptance Criteria (AC-1 ถึง AC-6), และ Business Rules (BR-1 ถึง BR-6) ให้เป็นแผนการทดสอบครอบคลุม 3 ระดับอย่างชัดเจน:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                      TESTING STRATEGY OVERVIEW                         │
├────────────────────────────────────────────────────────────────────────┤
│ 1. 🤖 AUTOMATED TESTS (Unit & Widget Tests)                            │
│    - Unit Tests: DateFormatter, StateNotifier, State Model            │
│    - Component Widget Tests: CurrencyCard, SegmentedControl, Chart,    │
│      StatCard, SummaryRow, DateDetailRow, SourceNote, 4 States         │
│    - Screen Integration Tests: Full Screen Flow & Responsive Layout   │
│    - Smoke Test: Entry point & ProviderScope in main.dart             │
├────────────────────────────────────────────────────────────────────────┤
│ 2. 👁️ REVIEW TESTS (Gate 7 Code Review Checklist)                     │
│    - 5 จุดตรวจโดย Tech Lead/Reviewer บน GitHub Pull Request            │
├────────────────────────────────────────────────────────────────────────┤
│ 3. 🙋 MANUAL QA TESTS (Stage D Human Verification)                     │
│    - 5 แผนการทดสอบมือบน Emulator / Physical Device                     │
└────────────────────────────────────────────────────────────────────────┘
```

---

### 1.1 ตารางความเชื่อมโยงครอบคลุมข้อกำหนด (AC & FR Traceability Matrix)

| Acceptance Criteria / FR | รูปแบบการทดสอบ | ไฟล์ทดสอบเป้าหมาย | เงื่อนไขและผลลัพธ์ที่ตรวจ |
|---|:---:|---|---|
| **FR-1, FR-2:** Top App Bar & Currency Selector (`USD → THB`) | 🤖 Automated<br>👁️ Review | `test/features/exchange_rate/presentation/widgets/currency_selector_card_test.dart`<br>`test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | - แสดงชื่อ "แนวโน้มอัตราแลกเปลี่ยน"<br>- แสดง "USD → THB" พร้อม Chevron Icon<br>- มี InkWell Ripple Effect เมื่อกด |
| **FR-3, BR-2:** Period Control สลับ 7, 30, 90 วัน และการล็อก | 🤖 Automated<br>🙋 Manual QA | `test/features/exchange_rate/presentation/widgets/period_segmented_control_test.dart`<br>`test/features/exchange_rate/presentation/providers/exchange_rate_notifier_test.dart` | - แสดง 3 ตัวเลือก `7 วัน`, `30 วัน` (Default), `90 วัน`<br>- แตะเปลี่ยนช่วงแล้วเรียก Notifier `changePeriod(days)`<br>- ล็อกปุ่ม (disabled) ไม่ให้กดซ้ำขณะสถานะ Loading |
| **FR-4, BR-5, AC-1:** Line Chart เส้นเดี่ยว, แกน X/Y 3 จุด | 🤖 Automated<br>🙋 Manual QA | `test/features/exchange_rate/presentation/widgets/trend_line_chart_test.dart` | - วาดเส้นกราฟสีน้ำเงิน `#2450D0` ความหนา 2.5px<br>- แกน X: แสดง 3 ป้ายกำกับ วันแรก, วันกลาง, วันสุดท้าย เป็นภาษาไทยย่อ (BR-5)<br>- แกน Y: แสดง ต่ำสุด, กลาง, สูงสุด ทศนิยม 2 ตำแหน่ง |
| **FR-5, AC-1:** Stat Cards แนวนอน 2 ใบ (สูงสุด / ต่ำสุด) | 🤖 Automated<br>👁️ Review | `test/features/exchange_rate/presentation/widgets/stat_card_compact_test.dart` | - แสดงการ์ด "สูงสุด" และ "ต่ำสุด"<br>- ตัวเลขเรตจัดรูปแบบทศนิยม 3 ตำแหน่ง เช่น `33.750`, `33.568` |
| **FR-6, AC-2, BR-3, BR-4:** Data Row คำนวณ % และ Level Badge | 🤖 Automated | `test/features/exchange_rate/presentation/widgets/trend_summary_row_test.dart` | - แสดงข้อความ "เปลี่ยนแปลง 30 วัน"<br>- Benchmark AC-2: `+0.54%` สีเขียว พร้อม Level Badge "สูงขึ้น"<br>- รองรับเคสขาลง `-0.44%` ป้าย "ลดลง", และทรงตัว `0.00%` ป้าย "ทรงตัว" |
| **FR-7, AC-3:** แตะจุดบนกราฟแสดงแถวรายละเอียด (Screen 15-1a) | 🤖 Automated<br>🙋 Manual QA | `test/features/exchange_rate/presentation/widgets/date_point_detail_row_test.dart`<br>`test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | - จำลอง Touch Event บนจุดกราฟ 10 ต.ค.<br>- แสดงแถว `10 ต.ค. · 33.570 THB`<br>- จุดบนกราฟมีไฮไลท์วงกลม |
| **FR-8, AC-6:** แถบ Source Note และเปิด URL ภายนอก | 🤖 Automated<br>🙋 Manual QA | `test/features/exchange_rate/presentation/widgets/source_note_widget_test.dart` | - แสดง "ข้อมูลจาก Frankfurter API" พร้อมไอคอน Open in New<br>- กดแล้วเรียก `url_launcher` ไปยัง `https://frankfurter.dev` |
| **4 Screen States:** Loading (15-1b), Empty (15-1c), Error (15-1d), Success (15-1) | 🤖 Automated | `test/features/exchange_rate/presentation/widgets/states/loading_state_widget_test.dart`<br>`test/features/exchange_rate/presentation/widgets/states/empty_state_widget_test.dart`<br>`test/features/exchange_rate/presentation/widgets/states/error_state_widget_test.dart` | - Loading: Spinner + ข้อความ<br>- Empty: ไอคอน + "ไม่มีข้อมูลในช่วงนี้"<br>- Error: ไอคอน + ข้อความ + ปุ่ม "ลองอีกครั้ง" (Retry) |
| **Responsive:** Handheld 360px vs Tablet centered max 600px | 🤖 Automated<br>🙋 Manual QA | `test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | - หน้าจอ 360px: ขยายเต็มความกว้าง Padding 16px ไม่เกิด Overflow<br>- หน้าจอ 834px (Tablet): ถูกจำกัดความกว้างไว้ที่ max 600px กึ่งกลางจอ |

---

### 1.2 โครงสร้างไดเรกทอรีชุดทดสอบของ Issue #3

```text
app/test/
├── core/
│   └── utils/
│       └── date_formatter_test.dart                         # [TC-Unit-1] ทดสอบ formatThaiShortDate
├── features/
│   └── exchange_rate/
│       └── presentation/
│           ├── providers/
│           │   └── exchange_rate_notifier_test.dart         # [TC-Unit-2] ทดสอบ StateNotifier & Riverpod States
│           ├── widgets/
│           │   ├── currency_selector_card_test.dart         # [TC-Widget-1] Card คู่สกุลเงิน USD -> THB
│           │   ├── period_segmented_control_test.dart       # [TC-Widget-2] แท็บเลือกช่วง 7d, 30d, 90d
│           │   ├── trend_line_chart_test.dart               # [TC-Widget-3] fl_chart เส้น, แกน X/Y, จุดสัมผัส
│           │   ├── stat_card_compact_test.dart              # [TC-Widget-4] การ์ดสถิติ สูงสุด / ต่ำสุด
│           │   ├── trend_summary_row_test.dart              # [TC-Widget-5] แถวสรุป % + Badge 3 ทิศทาง
│           │   ├── date_point_detail_row_test.dart          # [TC-Widget-6] แถว 10 ต.ค. · 33.570 (Screen 15-1a)
│           │   ├── source_note_widget_test.dart             # [TC-Widget-7] Frankfurter link & URL launcher
│           │   └── states/
│           │       ├── loading_state_widget_test.dart       # [TC-Widget-8a] Screen 15-1b Loading UI
│           │       ├── empty_state_widget_test.dart         # [TC-Widget-8b] Screen 15-1c Empty UI (BR-6)
│           │       └── error_state_widget_test.dart         # [TC-Widget-8c] Screen 15-1d Error UI + Retry
│           └── screens/
│               └── exchange_rate_trend_screen_test.dart     # [TC-Screen-1] Screen Integration & Responsive
└── widget_test.dart                                         # [TC-Smoke-1] Entry Point & ProviderScope Smoke
```

---

## 2. 🤖 หมวดหมู่ที่ 1: แผนชุดทดสอบอัตโนมัติ (Automated Tests)

---

### 2.1 [TC-Unit-1] `DateFormatter.formatThaiShortDate` Unit Tests
- **ไฟล์ทดสอบ:** `test/core/utils/date_formatter_test.dart`
- **Target Method:** `DateFormatter.formatThaiShortDate(DateTime date)` (`lib/core/utils/date_formatter.dart`)
- **การแมป AC / BR:** **AC-3, BR-5 (ชื่อเดือนย่อภาษาไทยสำหรับแกนกราฟและแถวสัมผัส)**

| รหัสเคส | ชื่อ Test Case | Input (Given) | การกระทำ (When) | ผลลัพธ์ที่คาดหวัง (Then) |
|---|---|---|---|---|
| **TC-Unit-1.1** | `'formatThaiShortDate: should format single-digit day and middle month correctly'` | `DateTime(2026, 9, 5)` | `DateFormatter.formatThaiShortDate(date)` | คืน `'5 ก.ย.'` |
| **TC-Unit-1.2** | `'formatThaiShortDate: should format AC-3 benchmark date 10 Oct accurately'` | `DateTime(2026, 10, 10)` | `DateFormatter.formatThaiShortDate(date)` | คืน `'10 ต.ค.'` ตรงตาม AC-3 |
| **TC-Unit-1.3** | `'formatThaiShortDate: should map all 12 Thai months accurately'` | วันที่ 15 ของทุกเดือน (1..12) | วนลูปเรียก `formatThaiShortDate` ทั้ง 12 เดือน | คืนเดือนย่อตรงตามลำดับ: `ม.ค.`, `ก.พ.`, `มี.ค.`, `เม.ย.`, `พ.ค.`, `มิ.ย.`, `ก.ค.`, `ส.ค.`, `ก.ย.`, `ต.ค.`, `พ.ย.`, `ธ.ค.` |
| **TC-Unit-1.4** | `'formatThaiShortDate: should format leap year date 29 Feb accurately'` | `DateTime(2024, 2, 29)` | `DateFormatter.formatThaiShortDate(date)` | คืน `'29 ก.พ.'` |
| **TC-Unit-1.5** | `'formatThaiShortDate: should format start and end of year dates accurately'` | `DateTime(2026, 1, 1)` และ `DateTime(2026, 12, 31)` | เรียก `formatThaiShortDate` | คืน `'1 ม.ค.'` และ `'31 ธ.ค.'` ตามลำดับ |

---

### 2.2 [TC-Unit-2] `ExchangeRateNotifier` & `ExchangeRateState` Unit Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/providers/exchange_rate_notifier_test.dart`
- **Target Class:** `ExchangeRateNotifier`, `ExchangeRateState` (`lib/features/exchange_rate/presentation/providers/`)
- **Mock Dependencies:** `MockGetExchangeRateTrendUseCase extends Mock implements GetExchangeRateTrendUseCase`
- **การแมป AC / BR:** **AC-1, AC-2, AC-3, AC-4, AC-5, BR-2, BR-6**

| รหัสเคส | ชื่อ Test Case | Mock Setup / Given | การกระทำ (When) | ผลลัพธ์ที่คาดหวัง (Then) |
|---|---|---|---|---|
| **TC-Unit-2.1** | `'initial state: should have default pair USD/THB, 30 days and initial status'` | สร้าง Notifier ตัวใหม่ | ตรวจสอบ `notifier.state` | `status == ExchangeRateStatus.initial`, `pair == CurrencyPair.defaultPair`, `selectedDays == 30`, `trend == null`, `selectedPoint == null` |
| **TC-Unit-2.2** | `'loadTrend: should transition from loading to success with trend data'` | Mock UseCase คืน `Right(fixtureTrendSuccess30Days)` | `await notifier.loadTrend()` | State ปรับเป็น `status == ExchangeRateStatus.success`, `trend == fixtureTrendSuccess30Days`, `selectedPoint == null` |
| **TC-Unit-2.3** | `'loadTrend: should transition to empty state when UseCase returns EmptyDataFailure'` | Mock UseCase คืน `Left(EmptyDataFailure('ไม่มีข้อมูลในช่วงนี้'))` | `await notifier.loadTrend()` | State ปรับเป็น `status == ExchangeRateStatus.empty`, `errorMessage == 'ไม่มีข้อมูลในช่วงนี้'` (BR-6) |
| **TC-Unit-2.4** | `'loadTrend: should transition to error state when UseCase returns NetworkFailure'` | Mock UseCase คืน `Left(NetworkFailure('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'))` | `await notifier.loadTrend()` | State ปรับเป็น `status == ExchangeRateStatus.error`, `errorMessage == 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'` |
| **TC-Unit-2.5** | `'loadTrend: should transition to error state when UseCase returns ServerFailure'` | Mock UseCase คืน `Left(ServerFailure('ดึงข้อมูลไม่สำเร็จ'))` | `await notifier.loadTrend()` | State ปรับเป็น `status == ExchangeRateStatus.error`, `errorMessage == 'ดึงข้อมูลไม่สำเร็จ'` |
| **TC-Unit-2.6** | `'changePeriod: should update selectedDays and trigger loadTrend for new period'` | Mock UseCase คืน `Right(fixtureTrendSuccess7Days)` | `notifier.changePeriod(7)` | UseCase ถูกเรียกด้วย `days: 7`, State มี `selectedDays == 7`, `status == ExchangeRateStatus.success` |
| **TC-Unit-2.7** | `'changePeriod: should ignore request when state is currently loading'` | State อยู่ในสถานะ `ExchangeRateStatus.loading` | `notifier.changePeriod(90)` | ไม่มีการเรียก UseCase ซ้ำ |
| **TC-Unit-2.8** | `'changePeriod: should ignore request when selecting identical period with success state'` | State อยู่ที่ `selectedDays == 30` และ `status == success` | `notifier.changePeriod(30)` | ไม่มีการเรียก UseCase ซ้ำ |
| **TC-Unit-2.9** | `'selectPoint: should update selectedPoint in state without modifying trend'` | State สำเร็จมี trend อยู่แล้ว | `notifier.selectPoint(point10Oct)` | `state.selectedPoint == point10Oct`, `state.trend` ยังคงเดิม |
| **TC-Unit-2.10**| `'selectPoint: should allow resetting selectedPoint to null'` | State มี `selectedPoint` อยู่ | `notifier.selectPoint(null)` | `state.selectedPoint == null` |
| **TC-Unit-2.11**| `'retry: should invoke loadTrend with current pair and selectedDays'` | State อยู่ใน Error สถานะ (30 วัน) | `notifier.retry()` | UseCase ถูกเรียกซ้ำด้วย `pair: state.pair`, `days: 30` |

---

### 2.3 [TC-Widget-1] `CurrencySelectorCard` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/currency_selector_card_test.dart`
- **Target Widget:** `CurrencySelectorCard` (`lib/features/exchange_rate/presentation/widgets/currency_selector_card.dart`)
- **การแมป AC / FR:** **FR-1, FR-2 (Card แสดงผลคู่สกุลเงิน)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-1.1** | `'renders base and quote currency correctly'` | `pair = CurrencyPair(base: 'USD', quote: 'THB')` | `pumpWidget` | พบข้อความ `'USD → THB'`, พบไอคอน `Icons.chevron_right` |
| **TC-Widget-1.2** | `'renders alternate currency pair correctly'` | `pair = CurrencyPair(base: 'EUR', quote: 'JPY')` | `pumpWidget` | พบข้อความ `'EUR → JPY'` |
| **TC-Widget-1.3** | `'triggers onTap callback when tapped'` | ส่ง `onTap: () => tapped = true` | `tester.tap(find.byType(CurrencySelectorCard))` | ตัวแปร `tapped` มีค่าเป็น `true` |

---

### 2.4 [TC-Widget-2] `PeriodSegmentedControl` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/period_segmented_control_test.dart`
- **Target Widget:** `PeriodSegmentedControl` (`lib/features/exchange_rate/presentation/widgets/period_segmented_control.dart`)
- **การแมป AC / FR:** **FR-3, BR-2 (ตัวเลือกช่วงเวลา 7, 30, 90 วัน)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-2.1** | `'renders 3 period tabs: 7 วัน, 30 วัน, 90 วัน'` | `selectedDays = 30`, `isLoading = false` | `pumpWidget` | พบข้อความ `'7 วัน'`, `'30 วัน'`, `'90 วัน'` ครบทั้ง 3 แท็บ |
| **TC-Widget-2.2** | `'highlights the currently selected period tab'` | `selectedDays = 30` | `pumpWidget` | แท็บ `'30 วัน'` มีสีตัวอักษรเป็น `AppColors.brandPrimary` และน้ำหนัก `FontWeight.w600` |
| **TC-Widget-2.3** | `'triggers onPeriodSelected when tapping unselected tab'` | `selectedDays = 30`, `isLoading = false` | `tester.tap(find.text('7 วัน'))` | Callback ถูกเรียกพร้อมค่า `7` |
| **TC-Widget-2.4** | `'does not trigger onPeriodSelected when isLoading is true'` | `selectedDays = 30`, `isLoading = true` | `tester.tap(find.text('90 วัน'))` | Callback ไม่ถูกเรียก (ปุ่มล็อกป้องกันการกดซ้ำตาม FR-3) |

---

### 2.5 [TC-Widget-3] `TrendLineChart` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/trend_line_chart_test.dart`
- **Target Widget:** `TrendLineChart` (`lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart`)
- **การแมป AC / FR:** **FR-4, FR-7, BR-5, AC-1, AC-3 (กราฟเส้น, แกน X/Y, และ Touch Event)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-3.1** | `'renders LineChart with single series and container styling'` | `points = fixtureRatePoints30Days`, `minRate = 33.568`, `maxRate = 33.750` | `pumpWidget` | พบ Widget `LineChart` 1 ตัว แสดงผลภายใน Container ขอบมน 14px |
| **TC-Widget-3.2** | `'displays 3 X-axis labels: first, middle, last in Thai short format (BR-5)'` | จุดวันแรก `29 ก.ย.`, จุดกลาง `14 ต.ค.`, จุดท้าย `29 ต.ค.` | `pumpWidget` | พบข้อความ `'29 ก.ย.'`, `'14 ต.ค.'`, `'29 ต.ค.'` บนแกน X |
| **TC-Widget-3.3** | `'displays 3 Y-axis labels: min, middle, max with 2 decimal places (BR-5)'` | `minRate = 33.568`, `maxRate = 33.750` (กลาง: 33.66) | `pumpWidget` | พบข้อความ `'33.57'`, `'33.66'`, `'33.75'` บนแกน Y |
| **TC-Widget-3.4** | `'renders dot highlight when selectedPoint is provided (Screen 15-1a)'` | ส่ง `selectedPoint = RatePoint(2026-10-10, 33.570)` | `pumpWidget` | กราฟเปิดใช้งาน `checkToShowDot` สำหรับ index วันที่ 10 ต.ค. |
| **TC-Widget-3.5** | `'renders empty SizedBox when points list is empty'` | `points = []` | `pumpWidget` | คืนค่า `SizedBox.shrink()` โดยไม่เกิดข้อผิดพลาด |

---

### 2.6 [TC-Widget-4] `StatCardCompact` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/stat_card_compact_test.dart`
- **Target Widget:** `StatCardCompact` (`lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart`)
- **การแมป AC / FR:** **FR-5, AC-1 (การ์ดแสดงค่าสูงสุดและต่ำสุด)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-4.1** | `'renders maximum rate card with 3 decimal places'` | `label = 'สูงสุด'`, `rate = 33.750` | `pumpWidget` | พบข้อความ `'สูงสุด'` และ `'33.750'` (ฟอนต์ `statValue` 22px SemiBold) |
| **TC-Widget-4.2** | `'renders minimum rate card with 3 decimal places'` | `label = 'ต่ำสุด'`, `rate = 33.568` | `pumpWidget` | พบข้อความ `'ต่ำสุด'` และ `'33.568'` |
| **TC-Widget-4.3** | `'formats trailing zeros accurately to 3 digits'` | `label = 'สูงสุด'`, `rate = 34.0` | `pumpWidget` | พบข้อความ `'34.000'` |

---

### 2.7 [TC-Widget-5] `TrendSummaryRow` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/trend_summary_row_test.dart`
- **Target Widget:** `TrendSummaryRow` (`lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart`)
- **การแมป AC / FR:** **FR-6, AC-2, BR-3, BR-4 (แถวสรุป % และ Level Badge)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-5.1** | `'AC-2 Benchmark: renders +0.54% and "สูงขึ้น" badge for upward trend'` | `days = 30`, `changePercentage = 0.54`, `direction = TrendDirection.up` | `pumpWidget` | พบข้อความ `'เปลี่ยนแปลง 30 วัน'`, `'+0.54%'`, `'สูงขึ้น'`, ไอคอน `Icons.arrow_upward` พร้อมสีเขียว |
| **TC-Widget-5.2** | `'renders negative percentage and "ลดลง" badge for downward trend'` | `days = 7`, `changePercentage = -0.44`, `direction = TrendDirection.down` | `pumpWidget` | พบข้อความ `'เปลี่ยนแปลง 7 วัน'`, `'-0.44%'`, `'ลดลง'`, ไอคอน `Icons.arrow_downward` พร้อมสีแดง |
| **TC-Widget-5.3** | `'renders 0.00% and "ทรงตัว" badge for neutral trend'` | `days = 90`, `changePercentage = 0.00`, `direction = TrendDirection.neutral` | `pumpWidget` | พบข้อความ `'เปลี่ยนแปลง 90 วัน'`, `'0.00%'`, `'ทรงตัว'`, ไอคอน `Icons.remove` พร้อมสีเทา |

---

### 2.8 [TC-Widget-6] `DatePointDetailRow` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/date_point_detail_row_test.dart`
- **Target Widget:** `DatePointDetailRow` (`lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart`)
- **การแมป AC / FR:** **FR-7, AC-3 (Screen 15-1a แตะจุดแสดงรายละเอียดวันที่และเรต)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-6.1** | `'AC-3 Benchmark: renders "10 ต.ค. · 33.570" and quote currency'` | `point = RatePoint(date: 2026-10-10, rate: 33.570, base: 'USD', quote: 'THB')` | `pumpWidget` | พบข้อความ `'10 ต.ค. · 33.570'`, พบข้อความ `'THB'` |
| **TC-Widget-6.2** | `'renders circle indicator bullet with primary brand color'` | `point = fixtureRatePoint` | `pumpWidget` | พบวงกลม bullet สี `AppColors.brandPrimary` ขนาด 8x8px |
| **TC-Widget-6.3** | `'formats rate to exactly 3 decimal places'` | `point = RatePoint(date: 2026-10-10, rate: 33.5, base: 'USD', quote: 'THB')` | `pumpWidget` | พบข้อความ `'10 ต.ค. · 33.500'` |

---

### 2.9 [TC-Widget-7] `SourceNoteWidget` Component Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/widgets/source_note_widget_test.dart`
- **Target Widget:** `SourceNoteWidget` (`lib/features/exchange_rate/presentation/widgets/source_note_widget.dart`)
- **การแมป AC / FR:** **FR-8, AC-6 (ที่มาข้อมูล Frankfurter API และ External Link)**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-7.1** | `'renders "ข้อมูลจาก Frankfurter API" text and external link icon'` | โหลดวิดเจ็ต | `pumpWidget` | พบข้อความ `'ข้อมูลจาก Frankfurter API'`, พบไอคอน `Icons.open_in_new` |
| **TC-Widget-7.2** | `'is wrapped in InkWell with rounded border for touch interaction'` | โหลดวิดเจ็ต | `pumpWidget` | พบ `InkWell` ครอบพื้นที่สัมผัส |

---

### 2.10 [TC-Widget-8] 4 Screen States Widgets Tests
- **ไฟล์ทดสอบ:**
  - `test/features/exchange_rate/presentation/widgets/states/loading_state_widget_test.dart`
  - `test/features/exchange_rate/presentation/widgets/states/empty_state_widget_test.dart`
  - `test/features/exchange_rate/presentation/widgets/states/error_state_widget_test.dart`
- **Target Widgets:** `LoadingStateWidget`, `EmptyStateWidget`, `ErrorStateWidget`
- **การแมป AC / FR:** **FR-8, BR-6, AC-5 (Screen 15-1b, 15-1c, 15-1d)**

| รหัสเคส | ชื่อ Test Case | Target Widget / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Widget-8.1** | `'Screen 15-1b: LoadingStateWidget renders spinner and "กำลังโหลดข้อมูล..."'` | `LoadingStateWidget()` | `pumpWidget` | พบ `CircularProgressIndicator`, พบข้อความ `'กำลังโหลดข้อมูล...'` |
| **TC-Widget-8.2** | `'Screen 15-1c: EmptyStateWidget renders bar chart icon and "ไม่มีข้อมูลในช่วงนี้" (BR-6)'` | `EmptyStateWidget()` | `pumpWidget` | พบไอคอน `Icons.bar_chart_outlined`, พบข้อความ `'ไม่มีข้อมูลในช่วงนี้'` |
| **TC-Widget-8.3** | `'EmptyStateWidget renders custom message when provided'` | `EmptyStateWidget(message: 'ไม่พบข้อมูลสกุลเงินนี้')` | `pumpWidget` | พบข้อความ `'ไม่พบข้อมูลสกุลเงินนี้'` |
| **TC-Widget-8.4** | `'Screen 15-1d: ErrorStateWidget renders error icon, message and retry button'` | `ErrorStateWidget(message: 'ดึงข้อมูลไม่สำเร็จ', onRetry: () {})` | `pumpWidget` | พบไอคอน `Icons.error_outline`, ข้อความ `'ดึงข้อมูลไม่สำเร็จ'`, ปุ่ม `'ลองอีกครั้ง'` พร้อมไอคอน `Icons.refresh` |
| **TC-Widget-8.5** | `'ErrorStateWidget triggers onRetry callback when retry button is tapped'` | ส่ง callback `onRetry: () => retried = true` | `tester.tap(find.text('ลองอีกครั้ง'))` | ตัวแปร `retried` กลายเป็น `true` |

---

### 2.11 [TC-Screen-1] `ExchangeRateTrendScreen` Integration Tests
- **ไฟล์ทดสอบ:** `test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart`
- **Target Screen:** `ExchangeRateTrendScreen` (`lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart`)
- **เครื่องมือจำลอง:** `MockGetExchangeRateTrendUseCase` ผ่าน `ProviderScope(overrides: [...])`
- **การแมป AC / FR:** **AC-1, AC-2, AC-3, AC-4, AC-5, AC-6, Responsive (Handheld 360px vs Tablet centered max 600px)**

| รหัสเคส | ชื่อ Test Case | Mock UseCase Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Screen-1.1** | `'AC-1 & AC-2: renders full success screen (15-1) with chart, stat cards and +0.54% badge'` | Mock คืน `Right(fixtureTrendSuccess30Days)` | `pumpWidget` + `pumpAndSettle` | พบ Title `'แนวโน้มอัตราแลกเปลี่ยน'`, Card `'USD → THB'`, ปุ่ม `'30 วัน'`, ค่า Max `'33.750'`, Min `'33.568'`, `'+0.54%'`, ป้าย `'สูงขึ้น'`, และ Source Note |
| **TC-Screen-1.2** | `'AC-3 & Screen 15-1a: tapping a chart point displays DatePointDetailRow with "10 ต.ค. · 33.570"'` | Mock คืน `Right(fixtureTrendSuccess30Days)` | เรียก Notifier `selectPoint(point10Oct)` แล้ว `pumpAndSettle` | ปรากฏแถว `DatePointDetailRow` แสดงผล `'10 ต.ค. · 33.570'` และ `'THB'` กลางหน้าจอ |
| **TC-Screen-1.3** | `'Screen 15-1b: displays LoadingStateWidget while fetching trend data'` | Mock UseCase จำลอง Delay ค้างไว้ | `tester.pump()` (ก่อน Settle) | พบ `LoadingStateWidget` กลางหน้าจอ |
| **TC-Screen-1.4** | `'Screen 15-1c: displays EmptyStateWidget when API returns EmptyDataFailure'` | Mock คืน `Left(EmptyDataFailure('ไม่มีข้อมูลในช่วงนี้'))` | `pumpWidget` + `pumpAndSettle` | พบ `EmptyStateWidget` แสดง `'ไม่มีข้อมูลในช่วงนี้'` |
| **TC-Screen-1.5** | `'Screen 15-1d: displays ErrorStateWidget and retries successfully when tapping retry'` | ครั้งที่ 1 คืน `Left(NetworkFailure(...))`, ครั้งที่ 2 คืน `Right(fixtureTrendSuccess30Days)` | แตะปุ่ม `'ลองอีกครั้ง'` แล้ว `pumpAndSettle` | หน้าจอเปลี่ยนจาก Error State กลับมาแสดงข้อมูลกราฟสำเร็จตาม AC-1 |
| **TC-Screen-1.6** | `'Responsive Handheld (360x780): renders cleanly without RenderFlex overflow'` | กำหนด Surface Size `360 × 780` (Physical Handheld) | `pumpWidget` + `pumpAndSettle` | ไม่มีข้อผิดพลาด RenderFlex Overflow, Layout มี Horizontal Padding 16px |
| **TC-Screen-1.7** | `'Responsive Small Mobile (320x568): scrollable without overflow'` | กำหนด Surface Size `320 × 568` (Small Mobile) | `pumpWidget` + `pumpAndSettle` | ไม่มี RenderFlex Overflow เลื่อนหน้าจอด้วย `SingleChildScrollView` ได้ราบรื่น |
| **TC-Screen-1.8** | `'Responsive Tablet (834x1194): constrained to max-width 600px centered'` | กำหนด Surface Size `834 × 1194` (Tablet Portrait) | `pumpWidget` + `pumpAndSettle` | กล่องเนื้อหากลางหน้าจอถูกล็อกความกว้างสูงสุดไว้ที่ `600px` ด้วย `ConstrainedBox` และจัดกึ่งกลาง |

---

### 2.12 [TC-Smoke-1] Application Entry Point Smoke Test
- **ไฟล์ทดสอบ:** `test/widget_test.dart`
- **Target File:** `lib/main.dart`
- **การแมป AC / FR:** **Smoke Test ยืนยันความพร้อมในการรันแอปพลิเคชันจริง**

| รหัสเคส | ชื่อ Test Case | Given / Setup | When | Then / Assert |
|---|---|---|---|---|
| **TC-Smoke-1.1** | `'ExchangeRateApp launches with ProviderScope and renders ExchangeRateTrendScreen'` | Mock UseCase คืน `Right(fixtureTrendSuccess30Days)` ใน ProviderScope override | `pumpWidget(const ProviderScope(child: ExchangeRateApp()))` | แอปพลิเคชันสตาร์ทขึ้นมาได้โดยไม่แครช พบหน้าจอ `ExchangeRateTrendScreen` และชื่อ `'แนวโน้มอัตราแลกเปลี่ยน'` |

---

## 3. 👁️ หมวดหมู่ที่ 2: จุดตรวจสอบด้วยสายตา (Review Tests สำหรับ Gate 7)

จุดตรวจสอบ 5 ข้อต่อไปนี้จะถูกประเมินโดย Tech Lead และ Code Reviewer ในขั้นตอน **Gate 7 (Code Review Approval)** บน GitHub PR:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   GATE 7 CODE REVIEW CHECKLIST                         │
├────────────────────────────────────────────────────────────────────────┤
│ [ ] CHECK-1: ความถูกต้องของ Design Tokens และ Typography               │
│ [ ] CHECK-2: การคงความบริสุทธิ์ของ Service Layer (Zero BE Changes)     │
│ [ ] CHECK-3: ความถูกต้องของ ProviderScope และ Application Entry Point  │
│ [ ] CHECK-4: ขอบเขตของ Presentation Layer (Clean Architecture Bounds) │
│ [ ] CHECK-5: คุณภาพของโค้ดและการปฏิบัติตาม Linter (Zero Warnings)      │
└────────────────────────────────────────────────────────────────────────┘
```

### 1) CHECK-1: ความถูกต้องของ Design Tokens และ Typography เทียบกับ Figma
- **เกณฑ์การตรวจ:**
  - โค้ดสีใน `lib/core/theme/app_colors.dart` ตรงตาม Figma Token Node 71-172:
    - `brandPrimary == Color(0xFF2450D0)`
    - `bgScreen == Color(0xFFF7F8FA)`
    - `bgSurface == Color(0xFFFFFFFF)`
    - `borderDefault == Color(0xFFDDE1E7)`
    - `statusUp == Color(0xFF10B981)` หรือ `#059669`
    - `statusDown == Color(0xFFEF4444)` หรือ `#DC2626`
  - ทุก Text Style ใน `lib/core/theme/app_typography.dart` ใช้ `GoogleFonts.ibmPlexSansThai`
  - ขอบมนของการ์ด (`CardTheme`, `CurrencySelectorCard`, `TrendLineChart`, `StatCardCompact`) ใช้ `BorderRadius.circular(14.0)` และเส้นขอบสี `borderDefault`
  - หน้าจอมี Horizontal Padding 16px และระยะห่าง Component Gap เป็นไปตาม 8px, 12px, 16px

### 2) CHECK-2: การคงความบริสุทธิ์ของ Service Layer (Zero BE Changes)
- **เกณฑ์การตรวจ:**
  - ไม่มีโค้ดใหม่หรือการแก้ไขใน `lib/features/exchange_rate/data/` (ยกเว้น Provider Wiring ที่อยู่ใน Presentation)
  - ไม่มีการแก้ไข Entity หรือ UseCase ใน `lib/features/exchange_rate/domain/`
  - ไม่มีการแตะต้อง `DioClient` หรือ Base URL นอกเหนือจากสัญญาเดิม
  - โค้ด Domain และ Data จาก Issue #2 ถูกนำมาใช้งานซ้ำ 100%

### 3) CHECK-3: ความถูกต้องของ ProviderScope และ Application Entry Point
- **เกณฑ์การตรวจ:**
  - `lib/main.dart` ครอบแอปพลิเคชันด้วย `ProviderScope` ที่ระดับ Root
  - กำหนด `theme: AppTheme.lightTheme` และกำหนด `home: const ExchangeRateTrendScreen()`
  - ลบโค้ด Boilerplate Flutter Counter App ออกหมดจด

### 4) CHECK-4: ขอบเขตของ Presentation Layer (Clean Architecture Boundaries)
- **เกณฑ์การตรวจ:**
  - Widgets ทุกตัวใน `presentation/widgets/` และ `presentation/screens/` สื่อสารผ่าน Notifier และ Domain Entities เท่านั้น
  - **ห้าม** วิดเจ็ตเรียกใช้งาน `Dio`, `RemoteDataSource`, หรือ DTO Models (`RatePointModel`) โดยตรงเด็ดขาด
  - การเชื่อมโยง Dependency ทั้งหมดรวมอยู่ที่ `exchange_rate_provider.dart` ซึ่งทำหน้าที่เป็น Composition Root เพียงแห่งเดียว

### 5) CHECK-5: คุณภาพของโค้ดและการปฏิบัติตาม Linter (Zero Warnings)
- **เกณฑ์การตรวจ:**
  - รัน `fvm flutter analyze` ต้องผ่านโดย **ไม่มี Error หรือ Warning แม้แต่จุดเดียว (0 issues found)**
  - ไม่มี Dead Code, ไม่มี Unused Imports, และไม่มีการเรียกใช้ `print()`
  - การจัดการ State ทุกจุดปลอดภัยจาก Race Condition หรือ Unmounted Widget (`mounted` check หรือใช้ Riverpod State Lifecycle)

---

## 4. 🙋 หมวดหมู่ที่ 3: แผนการทดสอบมือ (Manual QA Tests สำหรับ Stage D)

การทดสอบมือโดยมนุษย์จะดำเนินการใน **Stage D (Manual QA Pile)** บนอุปกรณ์จริง (Physical Device) หรือ Emulator/Simulator โดยมีรายการทดสอบ 5 ข้อดังนี้:

---

### QA-1: รันแอปพลิเคชันและตรวจสอบกราฟเส้นและสถิติ (Screen 15-1)
- **อุปกรณ์ทดสอบ:** Android Emulator (Pixel 7 / 360x780) หรือ iOS Simulator (iPhone 15)
- **ขั้นตอนการทดสอบ:**
  1. เปิดแอปพลิเคชัน `ExchangeRateApp`
  2. สังเกตหน้าจอเริ่มต้นเมื่อโหลดข้อมูลสำเร็จ
- **ผลลัพธ์ที่คาดหวัง:**
  - แสดงหัวข้อ "แนวโน้มอัตราแลกเปลี่ยน" บน AppBar
  - กล่องสกุลเงินแสดง `USD → THB` พร้อมไอคอนลูกศรขวา
  - แท็บช่วงเวลาเริ่มต้นถูกเลือกไว้ที่ `30 วัน`
  - กราฟเส้นสีน้ำเงินแสดงผลต่อเนื่อง แกน X แสดงวันที่ย่อภาษาไทย 3 จุด (แรก, กลาง, ท้าย), แกน Y แสดงเรต 3 ระดับ
  - การ์ดสถิติแสดงค่า "สูงสุด" และ "ต่ำสุด" ในช่วง 30 วัน
  - แถวสรุปแสดง "เปลี่ยนแปลง 30 วัน" พร้อมเปอร์เซ็นต์และป้าย Level Badge สีสันถูกต้อง

---

### QA-2: แตะจุดบนกราฟเพื่อดูรายละเอียดวันที่และเรต (Screen 15-1a)
- **อุปกรณ์ทดสอบ:** Physical Device หรือ Simulator ที่รองรับ Touch / Pointer
- **ขั้นตอนการทดสอบ:**
  1. ใช้นิ้วแตะที่จุดใดจุดหนึ่งบนเส้นกราฟ
  2. สังเกตการเปลี่ยนแปลงบนกราฟและพื้นที่ใต้กราฟ
- **ผลลัพธ์ที่คาดหวัง:**
  - จุดที่แตะบนเส้นกราฟจะปรากฏวงกลมไฮไลท์ขอบน้ำเงินพื้นขาว
  - ใต้กราฟปรากฏแถบข้อมูลสีเทาอ่อน แสดงวันที่ย่อภาษาไทยและค่าเรตทศนิยม 3 ตำแหน่ง เช่น `10 ต.ค. · 33.570 THB`
  - เมื่อแตะเปลี่ยนจุดอื่น ข้อมูลจะอัปเดตตามจุดที่แตะอย่างลื่นไหลโดยไม่มีการกระตุก

---

### QA-3: สลับช่วงเวลา 7 วัน, 30 วัน, 90 วัน และทดสอบความเร็วของแคช
- **อุปกรณ์ทดสอบ:** Mobile Device / Emulator
- **ขั้นตอนการทดสอบ:**
  1. แตะที่ปุ่ม `7 วัน` สังเกตสถานะการโหลดและข้อมูลกราฟใหม่
  2. แตะที่ปุ่ม `90 วัน` สังเกตการโหลดและช่วงวันที่บนแกน X ที่กว้างขึ้น
  3. แตะกลับมาที่ `30 วัน` อีกครั้ง
- **ผลลัพธ์ที่คาดหวัง:**
  - ในการแตะครั้งแรกของแต่ละช่วง อาจเห็น Loading State ในเสี้ยววินาที แล้วกราฟจะเปลี่ยนไปตามช่วงเวลาที่เลือก
  - เมื่อแตะสลับกลับมาที่ `30 วัน` ข้อมูลจะแสดงผลทันทีแบบ Instant Render (ดึงจาก In-Memory Cache โดยไม่เกิดการกระตุกหรือหมุนโหลดซ้ำ)
  - ขณะที่กำลังโหลด ตัวเลือกช่วงเวลาจะไม่สามารถกดย้ำซ้ำได้

---

### QA-4: แตะเปิดลิงก์ Frankfurter API ผ่านเบราว์เซอร์ภายนอก
- **อุปกรณ์ทดสอบ:** Mobile Device ที่ติดตั้งเว็บเบราว์เซอร์ (Chrome / Safari)
- **ขั้นตอนการทดสอบ:**
  1. เลื่อนหน้าจอลงมาด้านล่างสุด
  2. แตะที่ข้อความ "ข้อมูลจาก Frankfurter API"
- **ผลลัพธ์ที่คาดหวัง:**
  - ระบบจะเรียกเปิดเบราว์เซอร์ภายนอกและนำทางไปยัง `https://frankfurter.dev` ได้อย่างราบรื่น
  - เมื่อสลับกลับมาที่แอป แอปพลิเคชันยังคงรักษาหน้าจอเดิมไว้โดยไม่แครช

---

### QA-5: หมุนจอเป็นแนวนอนและทดสอบบนแท็บเล็ต (Responsive Verification)
- **อุปกรณ์ทดสอบ:** iPad Simulator (834 × 1194) หรือ หมุนจอ Android เป็นแนวนอน (Landscape)
- **ขั้นตอนการทดสอบ:**
  1. เปิดแอปพลิเคชันบนจอแท็บเล็ต หรือหมุนหน้าจอมือถือเป็นแนวนอน
  2. สังเกตการจัดวาง Layout และความกว้างของคอนเทนเนอร์
- **ผลลัพธ์ที่คาดหวัง:**
  - กล่องเนื้อหาหลักจะไม่ขยายยืดแผ่เต็มหน้าจอจนเสียสัดส่วน แต่จะถูกจำกัดความกว้างไว้ที่สูงสุด 600px และจัดกึ่งกลางหน้าจออย่างสวยงาม
  - ตัวหนังสือ, ปุ่มกด, และกราฟคงสัดส่วนที่อ่านง่าย สมดุลกับขนาดหน้าจอ

---

## 5. คำสั่งการทดสอบและเกณฑ์การยอมรับ (Commands & DoD Verification)

### 5.1 คำสั่งสำหรับรันชุดทดสอบ
```bash
# 1. รันชุดทดสอบทั้งหมดในโปรเจกต์
fvm flutter test

# 2. รันเฉพาะชุดทดสอบของ Issue #3
fvm flutter test test/features/exchange_rate/presentation/
fvm flutter test test/core/utils/date_formatter_test.dart

# 3. รันเพื่อตรวจสอบ Test Coverage
fvm flutter test --coverage

# 4. ตรวจสอบคุณภาพโค้ดและ Linter
fvm flutter analyze
```

### 5.2 เกณฑ์การยอมรับสำหรับส่งมอบสู่ Stage C (Definition of Done)
- [x] เคสทดสอบอัตโนมัติครบถ้วนทั้ง Unit, Widget, Screen Integration, และ Smoke Test รวม 33 เคส
- [x] ครอบคลุมทุกข้อกำหนดใน Acceptance Criteria (AC-1 ถึง AC-6) และ Business Rules (BR-1 ถึง BR-6)
- [x] ตรวจสอบความสอดคล้องกับ Design Tokens และ 4 Screen States จาก Figma ครบ 100%
- [x] มีจุดตรวจ 5 Review Items สำหรับ Gate 7 และ 5 แผนการทดสอบมือสำหรับ Stage D

---

อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
