# Workspec (Service / Data) — Issue #3: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1 - §5](../../sdd/)  
> **เอกสารส่งมอบเดิม:** [Issue #2 Technical Spec](../2/spec.md)  

---

## 1. ขอบเขตงานฝั่ง Service & Data Layer (Backend Scope Analysis)

### 1.1 การประเมินงานฝั่ง Service / Backend
- **ไม่มีการสร้างหรือแก้ไข Service / Data Layer ใหม่ในใบงานนี้ (Zero Backend Code Changes):**
  - แกนกลางข้อมูลและตรรกะทางธุรกิจทั้งหมดถูกพัฒนา, ทดสอบ (Unit Tests 28 เคส), และส่งมอบเรียบร้อยแล้วใน **Issue #2 (`feat/2-frankfurter-api-client`)**
  - ฝั่ง Backend มีหน้าที่ตรวจสอบความพร้อมของสัญญาอินเทอร์เฟซ (Contract Stability), ยืนยันว่า UseCase รองรับความต้องการของหน้าจอ 15-1 และ 15-1a ครบ 100%, และสนับสนุนชุดข้อมูลจำลอง (Mock Fixtures) สำหรับการทำ Widget Test ในฝั่ง Frontend

---

## 2. ตรวจสอบความพร้อมของ Service Assets จาก Issue #2

โครงสร้างและสัญญาข้อมูลที่พร้อมให้ Presentation Layer ใช้งานทันที:

| Asset / Component | ตำแหน่งไฟล์ใน `app/` | สถานะความพร้อมและหน้าที่ต่อ Screen 15-1 |
|---|---|---|
| **`GetExchangeRateTrendUseCase`** | `lib/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart` | ✅ พร้อมใช้งาน: รับ `pair` และ `days` (7, 30, 90) คืนค่า `Future<Either<Failure, ExchangeRateTrend>>` |
| **`ExchangeRateTrend`** (Entity) | `lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart` | ✅ พร้อมใช้งาน: บรรจุ `points`, `maxRate`, `minRate`, `changePercentage`, `trendDirection`, `pair`, `days` ครบถ้วนตามที่ Stat Cards และ Data Row ต้องการ |
| **`RatePoint`** (Entity) | `lib/features/exchange_rate/domain/entities/rate_point.dart` | ✅ พร้อมใช้งาน: บรรจุ `date`, `rate`, `base`, `quote` เพื่อใช้วาดจุดบน Line Chart และแสดงผลเมื่อแตะจุด (15-1a) |
| **`CurrencyPair`** (Entity) | `lib/features/exchange_rate/domain/entities/currency_pair.dart` | ✅ พร้อมใช้งาน: มี `CurrencyPair.defaultPair` (`USD/THB`) เป็นค่าเริ่มต้น |
| **`TrendDirection`** (Enum) | `lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart` | ✅ พร้อมใช้งาน: มีค่า `up`, `down`, `neutral` สอดคล้องกับ 3 สถานะของ Level Badge |
| **`Either<Failure, T>`** (Monad) | `lib/core/errors/failures.dart` | ✅ พร้อมใช้งาน: Sealed class รองรับการแตกเคส `Left(Failure)` vs `Right(ExchangeRateTrend)` |
| **`Failure` Entities** | `lib/core/errors/failures.dart` | ✅ พร้อมใช้งาน: `NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, `CacheFailure` เพื่อให้ UI แสดงผล Error State และ Empty State ได้ตรงจุด |
| **`TrendCalculator`** (Util) | `lib/core/utils/trend_calculator.dart` | ✅ คำนวณเสร็จสิ้น: สูตร % Change และการปัดทศนิยม 2 ตำแหน่งตาม AC-2 |
| **`ExchangeRateLocalDataSource`** | `lib/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart` | ✅ แคชรายวันทำงานอัตโนมัติ: ป้องกันการยิง API ซ้ำเมื่อสลับช่วงเวลา 7, 30, 90 วันตาม AC-4 |

---

## 3. การสนับสนุนฝั่ง Frontend สำหรับการทดสอบ (Mock Data & Test Support)

เพื่อสนับสนุนกระบวนการ TDD ในฝั่ง Frontend (Stage C) ฝั่ง Backend ขอยืนยันความพร้อมของ Test Fixtures ที่สามารถนำไปใช้ใน `WidgetTest` ได้ทันที:

### 3.1 ชุดข้อมูลสำเร็จสำหรับ AC-1 และ AC-2
```dart
final mockRatePoints = [
  RatePoint(date: DateTime(2026, 9, 29), rate: 33.568, base: 'USD', quote: 'THB'),
  RatePoint(date: DateTime(2026, 10, 10), rate: 33.570, base: 'USD', quote: 'THB'), // สำหรับ AC-3
  RatePoint(date: DateTime(2026, 10, 29), rate: 33.750, base: 'USD', quote: 'THB'),
];

final mockTrendSuccess30Days = ExchangeRateTrend(
  pair: const CurrencyPair(base: 'USD', quote: 'THB'),
  days: 30,
  points: mockRatePoints,
  maxRate: 33.750,
  minRate: 33.568,
  changePercentage: 0.54, // +0.54% ตามเกณฑ์ AC-2
  trendDirection: TrendDirection.up, // ป้าย "สูงขึ้น"
);
```

### 3.2 ชุดข้อมูลจำลองสำหรับ Failure States
- **Empty State (15-1c):** `Left(EmptyDataFailure('ไม่มีข้อมูลในช่วงนี้'))`
- **Error State (15-1d):** `Left(NetworkFailure('ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'))` หรือ `Left(ServerFailure('ดึงข้อมูลไม่สำเร็จ'))`

---

## 4. ตารางความรับผิดชอบ (Responsibility Matrix — Service/Backend Perspective)

| ข้อกำหนด (FR / AC) | ผู้รับผิดชอบ | ขอบเขตหน้าที่ของฝั่ง Service / Backend |
|---|:---:|---|
| **FR-1:** Top App Bar แสดงชื่อ | `FE` | ไม่เกี่ยวกับฝั่ง Service |
| **FR-2:** Text Field แสดงคู่สกุลเงินปัจจุบัน | `FE` | Service ส่งมอบ Entity `CurrencyPair` ให้แล้ว |
| **FR-3:** Segmented Control ตัวเลือก 3 ช่วง | `FE` | Service รองรับพารามิเตอร์ `days: 7, 30, 90` แล้ว |
| **FR-4:** Line Chart แสดงแนวโน้มและจุดข้อมูล | `FE` | Service ส่งมอบ `List<RatePoint>` เรียงลำดับตามวันให้แล้ว |
| **FR-5:** Stat Cards การ์ด "สูงสุด" และ "ต่ำสุด" | `FE` | Service คำนวณและส่งมอบ `maxRate`, `minRate` ใน Entity แล้ว |
| **FR-6:** Data Row สรุปการเปลี่ยนแปลง (% และ Badge) | `FE` | Service คำนวณ `changePercentage` และ `trendDirection` ให้แล้ว |
| **FR-7:** แตะจุดบนกราฟ (15-1a) แสดงรายละเอียด | `FE` | Service ส่งมอบอ็อบเจกต์ `RatePoint` ที่มี `date` และ `rate` แล้ว |
| **FR-8:** แถบ Source Note อ้างอิง Frankfurter API | `FE` | ไม่เกี่ยวกับฝั่ง Service |
| **AC-1:** แสดงกราฟเส้น ค่าสูงสุด ต่ำสุด และ % Change | `FE` | Service เตรียมข้อมูลผ่าน UseCase เรียบร้อยแล้ว |
| **AC-2:** คำนวณเปอร์เซ็นต์ถูกต้องและป้ายแนวโน้มสอดคล้อง | `FE + BE` | **BE:** ตรวจสอบสูตรคำนวณใน Unit Test เรียบร้อย (+0.54% / TrendDirection.up) / **FE:** นำไปเรนเดอร์ใน UI |
| **AC-3:** แตะจุด 10 ต.ค. แสดง "10 ต.ค. · 33.570" | `FE` | ข้อมูลจุดวันที่ 10 ต.ค. มีอยู่ใน Mock/API Data Stream |
| **AC-6:** แถบ Source Note เปิดลิงก์ภายนอก | `FE` | ไม่เกี่ยวกับฝั่ง Service |

---

## 5. สรุปความพร้อมในการต่อยอดสู่ Stage B (Definition of Ready)

- [x] Service API และ Domain Contracts พร้อมใช้งาน 100%
- [x] ไม่มี API หรือ Dependency ใหม่ที่ต้องพัฒนาเพิ่มใน Data/Domain Layer
- [x] Presentation Layer สามารถ Import ได้เฉพาะ Domain Layer (`GetExchangeRateTrendUseCase`, `ExchangeRateTrend`, `CurrencyPair`, `RatePoint`, `failures.dart`) ตามกฎ Clean Architecture SDD §2
- [x] พร้อมเข้าสู่ Stage B (จัดทำ Technical Specs เชิงลึกร่วมกันใน `spec-fe.md`, `spec-be.md`, `contract-report.md`, และ `testplan.md`)

---

อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
