# สเปคเชิงเทคนิคฉบับสมบูรณ์ (Consolidated Technical Specification) — Issue #3

> **ใบงานที่รับผิดชอบ:** Issue #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **ฐานงาน (Base Commit):** `cc2336ae7faa155b5758159d4469eea075922aec` (Merged PR #6)  
> **สถานะ:** พร้อมตรวจรับสำหรับ **✋ Gate 6 (Spec Approval)**  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1 - §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **เอกสารอ้างอิงประกอบ:**
> - [Figma Design Specification Issue #1 / #3](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md)
> - [Existing Inventory Report](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/existing-inventory.md)
> - [Frontend Technical Spec](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-fe.md)
> - [Backend & Data Technical Spec](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-be.md)
> - [Contract Check Report (Meeting Point 1)](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/contract-report.md)
> - [Test Plan](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/testplan.md)

---

## 1. บทสรุปและขอบเขตงาน (Executive Summary & Scope)

ใบงาน Issue #3 รับผิดชอบการพัฒนา **Presentation Layer** ของฟีเจอร์ MAT 15 อย่างสมบูรณ์ โดยเชื่อมต่อเข้ากับ Clean Architecture Service Core ที่สร้างเสร็จและผ่านการทดสอบ 100% ใน Issue #2 เพื่อแสดงผลหน้าจอแนวโน้มอัตราแลกเปลี่ยน กราฟเส้นความเคลื่อนไหว สถิติ และการโต้ตอบสัมผัสจุดข้อมูล

### ขอบเขตการทำงานหลัก:
1. **Core Theme & Design Tokens:**
   - สี Semantic ตาม Figma (`AppColors`): statusUp `#10B981`/`#059669`, statusDown `#EF4444`/`#DC2626`, statusNeutral `#525C6A`, brandPrimary `#2450D0`, bgScreen `#F8FAFC`, bgSurface `#FFFFFF`, bgSubtle `#F1F5F9`, borderDefault `#E2E8F0`
   - ฟอนต์ `IBM Plex Sans Thai` (`AppTypography`): Title (20px bold), Heading (16px semi-bold), BodyLarge (16px regular), BodyDefault (14px regular), BodySmall (12px regular), StatValue (18px bold)
   - `AppTheme`: Material 3 Light Theme กลาง
2. **Utility Enhancement:**
   - เพิ่มฟังก์ชัน `DateFormatter.formatThaiShortDate(DateTime date)` เช่น `29 ก.ย.`, `14 ต.ค.`, `29 ต.ค.` สำหรับแกน X (BR-5) และแถวรายละเอียดจุดสัมผัส (AC-3)
3. **State Management (Riverpod):**
   - `ExchangeRateState` (status: initial, loading, success, empty, error; pair; selectedDays; trend; selectedPoint; errorMessage)
   - `ExchangeRateNotifier` (loadTrend, changePeriod, selectPoint, retry)
   - Dependency Injection Providers เชื่อมโยง UseCase
4. **Widgets & UI Components:**
   - `ExchangeRateTrendScreen`: รองรับ Responsive Tablet (Max 600px กึ่งกลาง) และ Mobile (360px), Scaffold, Pull-to-refresh
   - `CurrencySelectorCard`: FR-2 แสดง `USD → THB` พร้อม Chevron ขวา
   - `PeriodSegmentedControl`: FR-3 3 แท็บ `7 วัน`, `30 วัน` (Default), `90 วัน`
   - `TrendLineChart`: FR-4 & FR-7 `fl_chart` กราฟเส้นเดี่ยวสีน้ำเงิน `#2450D0`, แกน X 3 จุด (แรก/กลาง/ท้าย), แกน Y 3 ค่า (ต่ำสุด/กลาง/สูงสุด), เส้นกริดประ `#DDE1E7`, และ Touch Callback อัปเดต selectedPoint
   - `DatePointDetailRow`: FR-7 (Screen 15-1a / AC-3) แสดงผลวันที่และเรตเมื่อแตะจุด เช่น `10 ต.ค. · 33.570`
   - `StatCardCompact`: FR-5 การ์ดคู่แสดงค่าสูงสุด / ต่ำสุด
   - `TrendSummaryRow`: FR-6 แถวสรุป % เปลี่ยนแปลง (เช่น `+0.54%`) พร้อม Pill Badge สีเขียว/แดง/เทา
   - `SourceNoteWidget`: FR-8 (AC-6) แถบ Frankfurter API เชื่อมต่อ `url_launcher`
   - 4 Screen State Widgets: `LoadingStateWidget` (15-1b), `EmptyStateWidget` (15-1c), `ErrorStateWidget` (15-1d)
5. **Entry Point Integration:**
   - ปรับปรุง `lib/main.dart` แทนที่ Counter App เดิมด้วย `ProviderScope`, `AppTheme.lightTheme` และ `ExchangeRateTrendScreen`

---

## 2. โครงสร้างไฟล์ที่จะสร้างและแก้ไข (Implementation File Matrix)

รวมทั้งสิ้น **18 ไฟล์** (แก้ไข 2 ไฟล์, สร้างใหม่ Production 10 ไฟล์, สร้างใหม่ Test 6 ไฟล์):

### 2.1 Production Code (12 ไฟล์ใน `app/lib/`)
```
lib/
├── main.dart                                                  # [แก้ไข] ครอบ ProviderScope, ThemeData, home: ExchangeRateTrendScreen
├── core/
│   ├── theme/
│   │   ├── app_colors.dart                                    # [สร้างใหม่] Color Palette tokens จาก Figma
│   │   ├── app_typography.dart                                # [สร้างใหม่] GoogleFonts.ibmPlexSansThai text styles
│   │   └── app_theme.dart                                     # [สร้างใหม่] Material 3 Light ThemeData
│   └── utils/
│       └── date_formatter.dart                                # [แก้ไข] เพิ่ม formatThaiShortDate (29 ก.ย.)
└── features/
    └── exchange_rate/
        └── presentation/
            ├── providers/
            │   ├── exchange_rate_state.dart                   # [สร้างใหม่] Equatable UI State (status, pair, days, trend, selectedPoint)
            │   └── exchange_rate_provider.dart                # [สร้างใหม่] Riverpod StateNotifierProvider & DI Providers
            ├── screens/
            │   └── exchange_rate_trend_screen.dart            # [สร้างใหม่] Screen 15-1 & 15-1a, Tablet responsive, pull-to-refresh
            └── widgets/
                ├── currency_selector_card.dart                # [สร้างใหม่] FR-2 การ์ดเลือกคู่สกุลเงิน
                ├── period_segmented_control.dart              # [สร้างใหม่] FR-3 ตัวเลือกช่วงเวลา 7d/30d/90d
                ├── trend_line_chart.dart                      # [สร้างใหม่] FR-4, FR-7 fl_chart กราฟเส้น แกน X/Y และ Touch callback
                ├── stat_card_compact.dart                     # [สร้างใหม่] FR-5 การ์ดสถิติสูงสุด/ต่ำสุด
                ├── trend_summary_row.dart                     # [สร้างใหม่] FR-6 แถวสรุป % เปลี่ยนแปลง และ Level Badge
                ├── date_point_detail_row.dart                 # [สร้างใหม่] FR-7 / 15-1a แถวรายละเอียดจุดสัมผัส (10 ต.ค. · 33.570)
                ├── source_note_widget.dart                    # [สร้างใหม่] FR-8 แถบ Frankfurter API และ url_launcher
                └── states/
                    ├── loading_state_widget.dart              # [สร้างใหม่] 15-1b CircularProgressIndicator & Shimmer
                    ├── empty_state_widget.dart                # [สร้างใหม่] 15-1c Empty state icon และข้อความ
                    └── error_state_widget.dart                # [สร้างใหม่] 15-1d Error state และปุ่ม "ลองใหม่อีกครั้ง"
```

### 2.2 Test Code (6 ไฟล์ใน `app/test/`)
```
test/
├── core/
│   └── utils/
│       └── date_formatter_thai_test.dart                      # [สร้างใหม่] 5 tests: formatThaiShortDate 12 เดือน, leap year, ข้ามปี
└── features/
    └── exchange_rate/
        └── presentation/
            ├── providers/
            │   └── exchange_rate_provider_test.dart           # [สร้างใหม่] 11 tests: Unit test Notifier (success, error, period switch, selectPoint)
            ├── screens/
            │   └── exchange_rate_trend_screen_test.dart       # [สร้างใหม่] 6 tests: Screen Integration 4 states, touch 15-1a, tablet responsive
            └── widgets/
                ├── trend_line_chart_test.dart                 # [สร้างใหม่] 4 tests: fl_chart render, X/Y axes 3 จุด, touch event
                ├── trend_summary_and_stat_cards_test.dart     # [สร้างใหม่] 4 tests: % change benchmark +0.54%, badges up/down/neutral, stat cards
                └── source_note_and_controls_test.dart         # [สร้างใหม่] 3 tests: CurrencySelector, SegmentedControl 7/30/90, url_launcher
```

---

## 3. สัญญาทางเทคนิคที่ผ่านการตรวจสอบ (Verified Contract Summary)

ผ่านการตรวจสอบ 7 มิติโดย Subagent `contract-checker` (Meeting Point 1) ด้วยสถานะ **✅ ผ่าน (PASS 100%)**:

| มิติการตรวจสอบ | ผลลัพธ์ | รายละเอียดสำคัญ |
|---|:---:|---|
| **1. FE Request vs BE Provision** | ✅ ผ่าน | Presentation Layer ใช้ `GetExchangeRateTrendUseCase` ที่ส่งมอบแล้วจาก Issue #2 พารามิเตอร์และผลลัพธ์ตรงกัน 100% |
| **2. Field Name & Casing** | ✅ ผ่าน | ทุกฟิลด์ตรงตาม camelCase (`points`, `maxRate`, `minRate`, `changePercentage`, `trendDirection`, `pair`, `days`, `selectedPoint`) |
| **3. Data Types & Safety** | ✅ ผ่าน | Type ปลอดภัย (`DateTime`, `double`, `enum TrendDirection`, `Either<Failure, ExchangeRateTrend>`) |
| **4. Nullability & Defaults** | ✅ ผ่าน | `selectedPoint` เป็น nullable เมื่อยังไม่แตะจุด และ fallback สู่ค่าล่าสุดเมื่อไม่มีการแตะ |
| **5. Error & Failure Mapping** | ✅ ผ่าน | 4 Failures แมปตรงกับ 4 Screen States และปุ่ม Retry / RefreshIndicator |
| **6. AC Coverage** | ✅ ผ่าน | รองรับครบทั้ง AC-1, AC-2, AC-3, AC-6 และ Tablet Responsive constraints |
| **7. Codebase Isolation & Re-use** | ✅ ผ่าน | **Zero Backend Changes** นำ Service & Domain Layer เดิมมาใช้ซ้ำ 100% ตาม Clean Architecture |

---

## 4. แผนการทดสอบเชิงบูรณาการ (Testing Strategy & Traceability Matrix)

จำแนกตามมาตรฐาน 3 รูปแบบตาม SDD §4:

### 4.1 🤖 Automated Tests (33 Test Cases)
- **AC-1 (แสดงกราฟเส้น ค่าสูงสุด ต่ำสุด และ % การเปลี่ยนแปลง):**  
  ทดสอบผ่าน `trend_line_chart_test.dart`, `trend_summary_and_stat_cards_test.dart`, และ `exchange_rate_trend_screen_test.dart`
- **AC-2 (คำนวณ % ถูกต้องและป้ายแนวโน้มสอดคล้องกับค่า Benchmark +0.54% "สูงขึ้น"):**  
  ทดสอบผ่าน `trend_summary_and_stat_cards_test.dart` และ `exchange_rate_provider_test.dart`
- **AC-3 (แตะจุดบนกราฟ 10 ต.ค. แสดงผล "10 ต.ค. · 33.570"):**  
  ทดสอบผ่าน `date_formatter_thai_test.dart`, `trend_line_chart_test.dart`, และ `exchange_rate_trend_screen_test.dart`
- **AC-6 (แถบ Source Note และกดเปิดลิงก์ภายนอกได้):**  
  ทดสอบผ่าน `source_note_and_controls_test.dart`
- **4 Screen States (Success, Loading 15-1b, Empty 15-1c, Error with Retry 15-1d):**  
  ทดสอบผ่าน `exchange_rate_trend_screen_test.dart`
- **Responsive Layout (Tablet centered max 600px vs Mobile 360px):**  
  ทดสอบผ่าน `exchange_rate_trend_screen_test.dart`

### 4.2 👁️ Review Checklist (สำหรับ Gate 7)
- [ ] ค่าสีและฟอนต์ `IBM Plex Sans Thai` ตรงตาม Design Tokens ใน Figma 100%
- [ ] Card radius 14px, Pill radius 999px, Screen padding 16px สอดคล้องตามดีไซน์
- [ ] Zero backend modifications (ไม่มีการแก้ Domain/Data layer เดิม)
- [ ] Clean Architecture Inversion of Control ผ่าน Riverpod DI Providers
- [ ] `flutter analyze` ผ่าน 0 warnings, 0 errors, 0 lints

### 4.3 🙋 Manual QA Scenarios (สำหรับ Stage D กองมนุษย์)
- **QA-1:** รันบน Emulator/Physical Device ตรวจสอบกราฟเส้นและสถิติ (Screen 15-1)
- **QA-2:** แตะจุดบนกราฟ (Screen 15-1a) ตรวจสอบไฮไลท์วงกลมและแถบรายละเอียดวันที่
- **QA-3:** สลับช่วงเวลา 7, 30, 90 วัน ตรวจสอบความเร็วแคช (Instant Render)
- **QA-4:** แตะ Source Note ตรวจสอบการเปิด URL `https://frankfurter.dev` ผ่านเบราว์เซอร์
- **QA-5:** หมุนจอแนวนอน / ทดสอบบนแท็บเล็ต ตรวจสอบการจำกัดความกว้าง 600px กึ่งกลาง

---

## 5. การตรวจสอบความพร้อมสำหรับประตูมนุษย์ (Gate 6 Readiness Checklist)

- [x] Workspec ละเอียดครอบคลุมทั้ง FE และ BE (`workspec-fe.md`, `workspec-be.md`)
- [x] สำรวจโค้ดเดิมและส่วนที่นำกลับมาใช้ซ้ำ 100% (`existing-inventory.md`)
- [x] จัดทำสเปคเทคนิคเชิงลึกครบทั้ง 2 เลเยอร์ (`spec-fe.md`, `spec-be.md`)
- [x] ตรวจสอบสัญญา 7 มิติ ผ่าน 100% ไร้ข้อขัดแย้ง (`contract-report.md`)
- [x] จัดทำแผนเคสทดสอบและ Traceability Matrix ครบทุก AC (`testplan.md`)
- [ ] 🛑 **✋ Gate 6 (Tech Lead Approval):** รอการตรวจรับและอนุมัติจาก Tech Lead (@Au3Hatsawat)

---

อ้างอิง SDD: [§01 Tech Stack Decisions](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/01-tech-stack.md), [§02 Architecture Layout](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/02-architecture-layout.md), [§03 API Contract & Data Layer](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/03-api-contract.md), [§04 Testing Guidelines](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/04-testing-guidelines.md), และ [§05 Code Review & DoD](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/05-review-and-dod.md)
