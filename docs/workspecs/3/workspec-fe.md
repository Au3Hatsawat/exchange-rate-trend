# Workspec (Frontend) — Issue #3: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **แหล่งอ้างอิงดีไซน์:** [Figma: MAT 15 – Exchange Rate Trend](https://www.figma.com/design/O1nysCaeCKuz0bD3o2VEPa/MAT-15-%E2%80%93-Exchange-Rate-Trend) · [`docs/workspecs/3/design.md`](design.md)  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1 - §5](../../sdd/)  

---

## 1. ขอบเขตงานฝั่งหน้าจอ (Frontend Presentation Scope)

ใบงานนี้รับผิดชอบการสร้างและประกอบหน้าจอหลักของฟีเจอร์ MAT 15 ทั้งหมด ประกอบด้วย **Screen 15-1 (Main Screen)** และ **Screen 15-1a (Touch Interaction State)** รวมถึงการจัดการ 4 สถานะของหน้าจอ (Data, Loading, Empty, Error) โดยเชื่อมต่อกับ Service Layer (`GetExchangeRateTrendUseCase`) ที่พัฒนาเสร็จสิ้นแล้วจาก Issue #2 ผ่าน State Management ด้วย **Flutter Riverpod (v2.x)**

### 1.1 หน้าจอที่ต้องพัฒนา
1. **Screen 15-1 (Main Screen):**
   - **Top App Bar:** แสดงข้อความ "แนวโน้มอัตราแลกเปลี่ยน" (Style: `Title` 24px SemiBold `#171B21`)
   - **Currency Selector Field:** ช่องแสดงคู่สกุลเงินปัจจุบัน (เช่น `USD → THB`) มี Chevron Icon ชี้ขวา พร้อม Tap Gesture เพื่อเตรียมนำทางสู่ Screen 15-2 (Currency Select)
   - **Period Segmented Control:** ปุ่มเลือกช่วงเวลา 3 ตัวเลือก `7 วัน`, `30 วัน` (Default), และ `90 วัน`
   - **Trend Line Chart (`fl_chart`):**
     - กราฟเส้นเดี่ยว (Single Series) วาดตามจุดข้อมูล `RatePoint`
     - สีเส้นกราฟ Brand Primary `#2450D0` ความหนา 2.5px
     - แกน X: แสดง 3 ป้ายกำกับ — วันแรก, วันกลาง, วันสุดท้าย (Format ภาษาไทย เช่น `29 ก.ย.`, `14 ต.ค.`, `29 ต.ค.`)
     - แกน Y: แสดง 3 ป้ายกำกับ — ค่าต่ำสุด, ค่ากลาง, ค่าสูงสุด (ปัดทศนิยม 2 ตำแหน่ง)
     - เส้นกริดประ (Gridlines) สี `#DDE1E7`
   - **Stat Cards (2 ใบแนวนอน):**
     - การ์ด "สูงสุด": แสดงค่า rate สูงสุดในช่วงเวลา (ทศนิยม 3 หรือ 4 ตำแหน่งตามค่าจริง เช่น `33.750`)
     - การ์ด "ต่ำสุด": แสดงค่า rate ต่ำสุดในช่วงเวลา (เช่น `33.551`)
     - กรอบการ์ดมน 14px (`borderRadius: 14`), พื้นหลัง `#FFFFFF`, เส้นขอบ `1px solid #DDE1E7`
   - **Trend Summary Data Row:**
     - ข้อความระบุช่วง: "เปลี่ยนแปลง {N} วัน" (เช่น `เปลี่ยนแปลง 30 วัน`)
     - ตัวเลขเปอร์เซ็นต์: แสดงเครื่องหมายบวก/ลบ เช่น `+0.54%` (ทศนิยม 2 ตำแหน่ง ตาม BR-3)
     - Level Badge: ป้ายกำกับแนวโน้ม (Pill Radius 999px)
       - `up`: ข้อความ "สูงขึ้น" (สีเขียว `#059669` หรือสีน้ำเงิน `#2450D0` พร้อมไอคอนขึ้น)
       - `down`: ข้อความ "ลดลง" (สีส้ม/แดง `#DC2626` / `#C2410C` พร้อมไอคอนลง)
       - `neutral`: ข้อความ "ทรงตัว" (สีเทา `#525C6A`)
   - **Source Note:** แถบล่างสุดแสดง "Frankfurter API" พร้อมไอคอน Open in New แตะแล้วเปิด URL `https://frankfurter.dev` ด้วย `url_launcher` (AC-6)

2. **Screen 15-1a (Touch Interaction State บนกราฟ):**
   - เมื่อผู้ใช้แตะจุดใด ๆ บน Line Chart:
     - กราฟจะไฮไลท์จุดที่เลือก (จุดวงกลมสีขาวขอบน้ำเงิน หรือขยายรัศมีจุด)
     - ปรากฏแถวข้อมูล `DatePointDetailRow` เหนือหรือใต้กราฟ แสดงวันที่และอัตราแลกเปลี่ยนของวันนั้น เช่น `10 ต.ค. · 33.570` (ตาม AC-3)

3. **4 Screen States (การจัดการสถานะหน้าจอตาม BR-6 & FR-8):**
   - **Data (Success):** แสดงผลกราฟและสถิติครบถ้วน
   - **Loading (15-1b):** แสดง Block Loading หรือ Skeleton/Shimmer กึ่งกลางพื้นที่กราฟ ล็อกไม่ให้กดสลับช่วงเวลาซ้ำ
   - **Empty (15-1c):** แสดงเมื่อ API คืนค่า `[]` (เกิด `EmptyDataFailure`) แสดงไอคอนข้อมูลว่าง + ข้อความ "ไม่มีข้อมูลในช่วงนี้"
   - **Error (15-1d):** แสดงเมื่อเกิด `NetworkFailure` หรือ `ServerFailure` แสดงข้อความ "ดึงข้อมูลไม่สำเร็จ" พร้อมปุ่ม "ลองอีกครั้ง" (Retry) เพื่อดึงข้อมูลใหม่

4. **ขนาดหน้าจอและ Responsive Layout:**
   - **Handheld (360 × 780):** Layout หลัก Horizontal padding 16px
   - **Small Mobile (320 × 568):** รองรับจอแคบ ไม่เกิด Overflow
   - **Tablet Portrait (834 × 1194):** ล็อก Max-width เนื้อหาไว้ที่ 600px และจัดกึ่งกลางหน้าจอ

---

## 2. โครงสร้างชิ้นส่วน Widgets ย่อย (Component & Widget Hierarchy)

```text
lib/features/exchange_rate/presentation/
├── screens/
│   └── exchange_rate_trend_screen.dart       # Scaffold, Responsive Container, Main ConsumerWidget
└── widgets/
    ├── currency_selector_card.dart          # FR-2: USD → THB Field with trailing chevron
    ├── period_segmented_control.dart        # FR-3: 7 วัน | 30 วัน | 90 วัน
    ├── trend_line_chart.dart                # FR-4, FR-7: fl_chart LineChart with touch interaction
    ├── stat_card_compact.dart               # FR-5: การ์ดค่าสูงสุด / ต่ำสุด
    ├── trend_summary_row.dart               # FR-6: "เปลี่ยนแปลง 30 วัน" + % + Level Badge
    ├── date_point_detail_row.dart           # FR-7 (15-1a): วันที่และค่า rate เมื่อแตะจุด
    ├── source_note_widget.dart              # FR-8 (AC-6): Frankfurter API link with url_launcher
    └── states/
        ├── loading_state_widget.dart        # 15-1b: Loading indicator block
        ├── empty_state_widget.dart          # 15-1c: "ไม่มีข้อมูลในช่วงนี้"
        └── error_state_widget.dart          # 15-1d: "ดึงข้อมูลไม่สำเร็จ" + Retry Button
```

---

## 3. สถาปัตยกรรม State Management ด้วย Flutter Riverpod

### 3.1 สถานะหน้าจอ (`ExchangeRateState`)
```dart
enum ExchangeRateStatus { initial, loading, success, empty, error }

class ExchangeRateState extends Equatable {
  final ExchangeRateStatus status;
  final CurrencyPair pair;
  final int selectedDays;
  final ExchangeRateTrend? trend;
  final RatePoint? selectedPoint; // สำหรับ 15-1a เมื่อแตะจุด
  final String? errorMessage;

  const ExchangeRateState({
    this.status = ExchangeRateStatus.initial,
    this.pair = CurrencyPair.defaultPair,
    this.selectedDays = 30, // Default 30 วันตาม BR-2
    this.trend,
    this.selectedPoint,
    this.errorMessage,
  });

  // copyWith และ props
}
```

### 3.2 ตัวจัดการสถานะ (`ExchangeRateNotifier`)
- **`loadTrend({CurrencyPair? pair, int? days})`**: เรียก `GetExchangeRateTrendUseCase`
  - หากกำลังโหลด: อัปเดต `status = ExchangeRateStatus.loading`
  - หากสำเร็จ: อัปเดต `status = ExchangeRateStatus.success`, เก็บ `trend`, รีเซ็ต `selectedPoint = null`
  - หากข้อมูลว่าง (`EmptyDataFailure`): อัปเดต `status = ExchangeRateStatus.empty`
  - หากเกิดข้อผิดพลาด (`NetworkFailure` / `ServerFailure`): อัปเดต `status = ExchangeRateStatus.error` และเก็บ `errorMessage`
- **`changePeriod(int days)`**: สลับช่วงวัน (7, 30, 90) และเรียก `loadTrend(days: days)`
- **`selectPoint(RatePoint? point)`**: อัปเดต `selectedPoint` สำหรับการแสดงผล 15-1a
- **`retry()`**: เรียกโหลดข้อมูลช่วงวันและคู่เงินเดิมซ้ำอีกครั้ง

### 3.3 Providers Registry
- `exchangeRateNotifierProvider`: `StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>`
- `getExchangeRateTrendUseCaseProvider`: Provider เชื่อมต่อจาก Issue #2 Domain UseCase

---

## 4. การนำ Design Tokens มาใช้งาน (Design Token Implementation)

จัดเตรียม Theme Tokens กลางใน `lib/core/theme/`:

### 4.1 สี (Color Palette) — `lib/core/theme/app_colors.dart`
- `AppColors.textPrimary = Color(0xFF171B21)`
- `AppColors.textSecondary = Color(0xFF525C6A)`
- `AppColors.brandPrimary = Color(0xFF2450D0)`
- `AppColors.bgScreen = Color(0xFFF7F8FA)`
- `AppColors.bgSurface = Color(0xFFFFFFFF)`
- `AppColors.bgSubtle = Color(0xFFEEF0F3)`
- `AppColors.borderDefault = Color(0xFFDDE1E7)`
- `AppColors.statusUp = Color(0xFF059669)` (หรือ `#2450D0`)
- `AppColors.statusDown = Color(0xFFDC2626)` (หรือ `#C2410C`)
- `AppColors.statusNeutral = Color(0xFF525C6A)`

### 4.2 แบบอักษร (Typography: IBM Plex Sans Thai) — `lib/core/theme/app_typography.dart`
ใช้ `GoogleFonts.ibmPlexSansThai()`:
- `AppTypography.title`: 24px, FontWeight 600 (SemiBold), Line-height 34px
- `AppTypography.heading`: 20px, FontWeight 600 (SemiBold), Line-height 30px
- `AppTypography.bodyLarge`: 18px, FontWeight 400 (Regular), Line-height 28px
- `AppTypography.bodyDefault`: 16px, FontWeight 400 (Regular), Line-height 24px
- `AppTypography.bodySmall`: 14px, FontWeight 400 (Regular), Line-height 20px
- `AppTypography.labelSmall`: 14px, FontWeight 500 (Medium), Line-height 20px

### 4.3 ระยะขอบและส่วนโค้ง (Spacing & Radii)
- Horizontal Screen Padding: 16.0 px
- Card Border Radius: `BorderRadius.circular(14.0)`
- Badge / Pill Radius: `BorderRadius.circular(999.0)`
- Gap Spacing: 8.0, 12.0, 16.0, 24.0 px

---

## 5. ตารางรายการไฟล์ที่จะสร้างใหม่ในฝั่ง Frontend

| หมวดหมู่ | ที่อยู่ไฟล์ (Path ใน `app/`) | หน้าที่รับผิดชอบ |
|---|---|---|
| **Core Theme** | `lib/core/theme/app_colors.dart` | กำหนดค่า Color Tokens ทั้งหมดตาม Figma |
| **Core Theme** | `lib/core/theme/app_typography.dart` | กำหนดค่า Font Styles `IBM Plex Sans Thai` |
| **Core Theme** | `lib/core/theme/app_theme.dart` | ThemeData หลักของแอปพลิเคชัน (Light Theme) |
| **Presentation State** | `lib/features/exchange_rate/presentation/providers/exchange_rate_state.dart` | State Model สำหรับ Screen 15-1, 15-1a และ 4 States |
| **Presentation Provider**| `lib/features/exchange_rate/presentation/providers/exchange_rate_provider.dart` | Riverpod StateNotifier และ Dependency Injection |
| **Presentation Screen** | `lib/features/exchange_rate/presentation/screens/exchange_rate_trend_screen.dart` | Screen 15-1 & 15-1a และตัวครอบ Responsive Width |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/currency_selector_card.dart` | แสดงคู่สกุลเงินปัจจุบัน + แตะเพื่อไปหน้า 15-2 |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/period_segmented_control.dart` | ตัวเลือกช่วงเวลา 7, 30, 90 วัน |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/trend_line_chart.dart` | กราฟเส้น `fl_chart` พร้อมแกน X/Y และ Touch Callback |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/stat_card_compact.dart` | การ์ดแสดงค่า สูงสุด / ต่ำสุด |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/trend_summary_row.dart` | แถวสรุป % และ Level Badge สูงขึ้น/ลดลง/ทรงตัว |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/date_point_detail_row.dart` | รายละเอียดวันที่และเรตเมื่อแตะจุดบนกราฟ (15-1a) |
| **Presentation Widget** | `lib/features/exchange_rate/presentation/widgets/source_note_widget.dart` | แถบ Frankfurter API + url_launcher |
| **Presentation States** | `lib/features/exchange_rate/presentation/widgets/states/loading_state_widget.dart` | Loading State (15-1b) |
| **Presentation States** | `lib/features/exchange_rate/presentation/widgets/states/empty_state_widget.dart` | Empty State (15-1c) |
| **Presentation States** | `lib/features/exchange_rate/presentation/widgets/states/error_state_widget.dart` | Error State (15-1d) พร้อมปุ่ม Retry |
| **Widget Test** | `test/features/exchange_rate/presentation/providers/exchange_rate_notifier_test.dart` | Unit Test ตรรกะของ Riverpod Notifier |
| **Widget Test** | `test/features/exchange_rate/presentation/widgets/trend_line_chart_test.dart` | Widget Test กราฟเส้น และ Touch Interaction (15-1a) |
| **Widget Test** | `test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | Widget Test ทั้งหน้าจอ ครอบคลุม AC-1, AC-2, AC-3, AC-6 |

---

## 6. ตารางความรับผิดชอบ (Responsibility Matrix)

| ข้อกำหนด (FR / AC) | ผู้รับผิดชอบ | ขอบเขตการทำงานในใบงานนี้ |
|---|:---:|---|
| **FR-1:** Top App Bar แสดงชื่อ "แนวโน้มอัตราแลกเปลี่ยน" | `FE` | สร้าง AppBar พร้อมฟอนต์ `IBM Plex Sans Thai` ตามดีไซน์ |
| **FR-2:** Text Field แสดงคู่สกุลเงินปัจจุบัน (เช่น `USD → THB`) กดแล้วนำทางไปหน้า 15-2 | `FE` | แสดงการ์ดสกุลเงิน USD/THB พร้อม Chevron และกำหนด Callback นำทาง |
| **FR-3:** Segmented Control ตัวเลือก 3 ช่วง: `7 วัน`, `30 วัน` (Default), `90 วัน` | `FE` | วิดเจ็ต Segmented Control ผูกกับ `changePeriod` ของ Riverpod |
| **FR-4:** Line Chart แสดงแนวโน้ม (แกน X: วันแรก/กลาง/ท้าย, แกน Y: ต่ำสุด/กลาง/สูงสุด) | `FE` | ปรับแต่ง `fl_chart` แสดงผลแกนและเส้นกราฟจาก `RatePoint` |
| **FR-5:** Stat Cards การ์ด "สูงสุด" และ "ต่ำสุด" | `FE` | นำค่า `maxRate` และ `minRate` จาก Entity มาแสดงในการ์ดคู่ |
| **FR-6:** Data Row สรุปการเปลี่ยนแปลง (% และ Level Badge สูงขึ้น/ลดลง/ทรงตัว) | `FE` | นำ `changePercentage` และ `trendDirection` มาแสดงพร้อม Styling Badge |
| **FR-7:** แตะจุดบนกราฟ (15-1a) แสดงวันที่และอัตราแลกเปลี่ยน | `FE` | จัดการ Touch Interaction ของ `fl_chart` และแสดงผล `DatePointDetailRow` |
| **FR-8:** แถบ Source Note อ้างอิง Frankfurter API ด้านล่างสุด | `FE` | แสดงข้อความและลิงก์ พร้อมเรียก `url_launcher` ไปยัง https://frankfurter.dev |
| **AC-1:** แสดงกราฟเส้น ค่าสูงสุด ต่ำสุด และเปอร์เซ็นต์การเปลี่ยนแปลง | `FE` | ประกอบหน้าจอและผูกข้อมูลจาก UseCase แสดงผลได้ครบถ้วน |
| **AC-2:** คำนวณเปอร์เซ็นต์ถูกต้องและป้ายแนวโน้มสอดคล้องกับค่า | `FE + BE` | BE คำนวณเสร็จใน Issue #2 / FE นำผลลัพธ์มาแมปสีและป้ายแสดงผลให้ถูกต้อง |
| **AC-3:** แตะจุดของวันที่ 10 ต.ค. แสดงผล "10 ต.ค. · 33.570" ในแถวรายละเอียด | `FE` | ดักจับ Event แตะจุดและเรนเดอร์ข้อความตามฟอร์แมต AC-3 |
| **AC-6:** มีแถบ Source Note และกดเปิดลิงก์ภายนอกได้ | `FE` | ทดสอบการคลิกเปิด URL ด้วย url_launcher |

---

อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
