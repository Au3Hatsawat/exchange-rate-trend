# สเปคเชิงเทคนิคฉบับสมบูรณ์ (Consolidated Technical Specification) — Issue #2

> **ใบงานที่รับผิดชอบ:** Issue #2 — `[Service] Develop: API Client เชื่อมต่อ Frankfurter API พร้อมระบบแคชข้อมูลรายวัน`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/2-frankfurter-api-client`  
> **สถานะ:** พร้อมตรวจรับสำหรับ **✋ Gate 6 (Spec Approval)**  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1 - §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)  
> **เอกสารอ้างอิงประกอบ:**
> - [Existing Inventory](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/existing-inventory.md)
> - [Frontend Technical Spec](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/spec-fe.md)
> - [Backend Technical Spec](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/spec-be.md)
> - [Contract Check Report (Meeting Point 1)](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/contract-report.md)
> - [Test Plan](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/2/testplan.md)

---

## 1. บทสรุปและขอบเขตงาน (Executive Summary & Scope)

ใบงาน Issue #2 ทำหน้าที่เป็น **แกนกลางข้อมูลและตรรกะทางธุรกิจ (Data & Business Core)** สำหรับระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (MAT 15) ทั้งหมด โดยวางรากฐานสถาปัตยกรรมแบบ Clean Architecture (Feature-First) เพื่อให้ใบงานหน้าจอถัดไป (Issue #3, #4, #5) สามารถเรียกใช้งานได้อย่างปลอดภัย ไร้รอยต่อ และเป็นไปตาม Business Rules ที่กำหนด

### ขอบเขตที่ต้องส่งมอบใน Issue #2:
1. **Core Network & Infrastructure:** `DioClient` พร้อม Timeout (10s), Base URL Frankfurter API, และ Error Interceptor
2. **Core Utilities & Business Calculations:**
   - `TrendCalculator`: คำนวณ $\Delta\% = \frac{\text{lastRate} - \text{firstRate}}{\text{firstRate}} \times 100$ (ปัด 2 ตำแหน่ง), กำหนด `TrendDirection` (up, down, neutral), และหาค่า Max/Min Rate
   - `DateFormatter`: คำนวณช่วงวันย้อนหลัง `from = today - days` (7, 30, 90 วัน) ฟอร์แมต `YYYY-MM-DD` ปลอดภัยข้ามเดือน/ปี
3. **Domain Layer (Pure Dart):**
   - Entities: `RatePoint`, `ExchangeRateTrend`, `CurrencyPair`, `TrendDirection`
   - Repository Interface: `ExchangeRateRepository`
   - UseCase: `GetExchangeRateTrendUseCase`
   - Zero-dependency FP Monad: Sealed Class `Either<Failure, T>` พร้อม Subclasses `Left` และ `Right` ใน `lib/core/errors/failures.dart`
4. **Data Layer:**
   - Model DTO: `RatePointModel` แปลงข้อมูล JSON Array จาก Frankfurter API อย่างปลอดภัย ป้องกัน Type Mismatch
   - Remote Data Source: `ExchangeRateRemoteDataSource` เชื่อมต่อ Frankfurter API `/v2/rates`
   - Local Data Source: `ExchangeRateLocalDataSource` ระบบแคช In-Memory รายวัน คีย์ `${base}_${quote}_${days}_${currentDate}`
   - Repository Implementation: `ExchangeRateRepositoryImpl` บริหารจัดการ Cache-First, Fallback Remote, และ Exception Mapping สู่ Failures
5. **Presentation Contract & Design Tokens:**
   - นิยามโครงสร้าง 5 หน้าจอ State: `Initial`, `Loading`, `Success`, `Empty`, `Error`
   - กำหนด Provider Signature สำหรับ Riverpod
   - บันทึก Design Tokens (Colors Palette, Typography `IBM Plex Sans Thai`, Spacing) สำหรับรองรับ UI ใน Phase ถัดไป

---

## 2. โครงสร้างไฟล์ที่จะสร้างใหม่ทั้งหมด (Implementation File Matrix)

รวมทั้งสิ้น **22 ไฟล์** แบ่งเป็น Production Code 15 ไฟล์ และ Test Code 7 ไฟล์:

### 2.1 Production Code (15 ไฟล์ใน `app/lib/`)
```
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart                   # ServerException, NetworkException, EmptyDataException, CacheException
│   │   └── failures.dart                     # Sealed Either<L, R>, Failure, ServerFailure, NetworkFailure, EmptyDataFailure, CacheFailure
│   ├── network/
│   │   ├── api_endpoints.dart                # Base URL: https://api.frankfurter.dev, Path: /v2/rates
│   │   └── dio_client.dart                   # Factory Dio with ConnectTimeout(10s), ReceiveTimeout(10s)
│   └── utils/
│       ├── date_formatter.dart               # formatIsoDate, calculateStartDate (7, 30, 90 days)
│       └── trend_calculator.dart             # calculatePercentageChange, determineTrend, findMax/Min
└── features/
    └── exchange_rate/
        ├── data/
        │   ├── datasources/
        │   │   ├── exchange_rate_local_datasource.dart     # In-Memory Daily Cache with daily key
        │   │   └── exchange_rate_remote_datasource.dart    # Dio HTTP GET /v2/rates
        │   ├── models/
        │   │   └── rate_point_model.dart                   # DTO json parsing num -> double
        │   └── repositories/
        │       └── exchange_rate_repository_impl.dart      # Orchestrate Local + Remote + TrendCalculator
        └── domain/
            ├── entities/
            │   ├── currency_pair.dart                      # Immutable base & quote (default USD/THB)
            │   ├── exchange_rate_trend.dart                # List<RatePoint>, max, min, % change, trend, pair, days
            │   └── rate_point.dart                         # DateTime date, double rate, base, quote
            ├── repositories/
            │   └── exchange_rate_repository.dart           # Future<Either<Failure, ExchangeRateTrend>> getTrend(...)
            └── usecases/
                └── get_exchange_rate_trend_usecase.dart    # Pure Dart UseCase calling Repository
```

### 2.2 Test Code (7 ไฟล์ใน `app/test/`)
```
test/
├── core/
│   └── utils/
│       ├── date_formatter_test.dart                        # 5 tests: 7/30/90 days, leap year, zero-padding
│       └── trend_calculator_test.dart                      # 6 tests: % change AC-2 (+0.54%), trend up/down/neutral, max/min
└── features/
    └── exchange_rate/
        ├── data/
        │   ├── datasources/
        │   │   ├── exchange_rate_local_datasource_test.dart # 4 tests: cache hit/miss, daily key invalidation
        │   │   └── exchange_rate_remote_datasource_test.dart# 5 tests: Dio mocktail HTTP 200/422/500, empty [], timeout
        │   ├── models/
        │   │   └── rate_point_model_test.dart               # 4 tests: parse json array, num casting, equatable
        │   └── repositories/
        │       └── exchange_rate_repository_impl_test.dart  # 4 tests: cache first, remote fallback, failure mapping
        └── domain/
            └── usecases/
                └── get_exchange_rate_trend_usecase_test.dart# 2 tests: domain passthrough, failure propagation
```

---

## 3. สัญญาทางเทคนิคที่ผ่านการตรวจสอบ (Verified Contract Summary)

ผ่านการตรวจสอบ 7 มิติโดย Subagent `contract-checker` (Meeting Point 1) ด้วยสถานะ **✅ ผ่าน (PASS)**:

| มิติการตรวจสอบ | ผลลัพธ์ | รายละเอียดสำคัญ |
|---|:---:|---|
| **1. FE Request vs BE Provision** | ✅ ผ่าน | UseCase & Repository methods มี Parameter (`CurrencyPair`, `days`) และ Return Type (`Either<Failure, ExchangeRateTrend>`) สอดคล้องกันสมบูรณ์ |
| **2. Field Name & Casing** | ✅ ผ่าน | ทุกฟิลด์ใช้ `camelCase` ตรงกัน 100% (`points`, `maxRate`, `minRate`, `changePercentage`, `trendDirection`, `pair`, `days`) |
| **3. Data Types & Monads** | ✅ ผ่าน | `DateTime`, `double`, `enum TrendDirection { up, down, neutral }` และ Sealed `Either<L, R>` ตรงกัน |
| **4. Nullability & Safety** | ✅ ผ่าน | Required fields ทั้งหมดเป็น Non-nullable, มี fallback ค่าเริ่มต้น ปลอดภัยต่อ null crash |
| **5. Error & Failure Mapping** | ✅ ผ่าน | ครอบคลุม 4 ประเภทความผิดพลาด: `NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, `CacheFailure` สอดรับกับ 5 Screen States |
| **6. AC Coverage** | ✅ ผ่าน | รองรับครบทุกข้อกำหนด AC-1 ถึง AC-6 |
| **7. Codebase Isolation** | ✅ ผ่าน | โครงสร้างแยกเลเยอร์ชัดเจน ไม่ทับซ้อนกับ Starter Code เดิม และเป็น Pure Dart ใน Domain Layer |

---

## 4. แผนการทดสอบเชิงบูรณาการ (Testing Strategy & Traceability Matrix)

จำแนกตามมาตรฐาน 3 รูปแบบตาม SDD §4:

### 4.1 🤖 Automated Tests (28 Unit Test Cases)
- **AC-1 (ช่วงเวลา 7, 30, 90 วัน):** ทดสอบผ่าน `date_formatter_test.dart` และ `exchange_rate_remote_datasource_test.dart`
- **AC-2 (การคำนวณสถิติและร้อยละ Benchmark):**  
  ทดสอบผ่าน `trend_calculator_test.dart` ค่าแรก `33.568` และค่าสุดท้าย `33.750` ได้ผลลัพธ์ `+0.54%` และสถานะ `TrendDirection.up`
- **AC-3 (การเรียงลำดับจุดข้อมูล):** ทดสอบผ่าน `rate_point_model_test.dart` และ `trend_calculator_test.dart`
- **AC-4 (ระบบแคชข้อมูลรายวัน):**  
  ทดสอบผ่าน `exchange_rate_local_datasource_test.dart` และ `exchange_rate_repository_impl_test.dart` สลับช่วงเวลาส่งคำขอใหม่ สลับกลับมาคืนค่าจากแคชโดยไม่ยิง Network ซ้ำ
- **AC-5 (การจัดการข้อผิดพลาด):**  
  ทดสอบผ่าน `exchange_rate_remote_datasource_test.dart` และ `exchange_rate_repository_impl_test.dart` คืนค่า `Left(NetworkFailure)` หรือ `Left(ServerFailure)` เมื่อเกิดปัญหา
- **AC-6 (Empty State สำหรับข้อมูลว่าง):**  
  ทดสอบผ่าน `exchange_rate_remote_datasource_test.dart` แปลง `[]` เป็น `Left(EmptyDataFailure)`

### 4.2 👁️ Review Checklist (สำหรับ Gate 7)
- [ ] Domain Layer เป็น Pure Dart ปลอด package Flutter หรือ Dio
- [ ] คลาส `Either<L, R>` ใน `failures.dart` เป็น Sealed Class ที่ไม่มี external dependency
- [ ] Connect Timeout และ Receive Timeout ถูกตั้งค่าไว้ที่ 10 วินาที
- [ ] Unit Test ทุกตัวใช้ Mocktail ห้ามมีการยิง Network จริงเด็ดขาด
- [ ] สถาปัตยกรรมปฏิบัติตาม Inversion of Control (IoC)

### 4.3 🙋 Manual QA Scenarios (สำหรับ Stage D กองมนุษย์)
- **QA-1:** รันแอปพร้อมต่อเน็ตจริง ดึงข้อมูลจาก `https://api.frankfurter.dev/v2/rates` ได้ข้อมูลถูกต้อง
- **QA-2:** เปิด Airplane Mode / ปิด Wi-Fi ทดสอบระบบส่งคืน `NetworkFailure` และแสดง Error State
- **QA-3:** กดเลือก 30 วัน -> 7 วัน -> 30 วัน สังเกตรอบที่สองตอบสนองทันทีโดยไม่มี Network Request
- **QA-4:** ทดสอบกรณีวันหยุดยาวหรือสกุลเงินที่ไม่มีการซื้อขาย ให้ระบบแสดง Empty State

---

## 5. การตรวจสอบความพร้อมสำหรับประตูมนุษย์ (Gate 6 Readiness Checklist)

- [x] Workspec ละเอียดครอบคลุมทั้ง FE และ BE (`workspec-fe.md`, `workspec-be.md`)
- [x] สำรวจโค้ดเดิมและสรุปรายการที่ต้องสร้างใหม่ 22 ไฟล์ (`existing-inventory.md`)
- [x] จัดทำสเปคเทคนิคเชิงลึกครบทั้ง 2 เลเยอร์ (`spec-fe.md`, `spec-be.md`)
- [x] ตรวจสอบสัญญา 7 มิติ ผ่าน 100% ไร้ข้อขัดแย้ง (`contract-report.md`)
- [x] จัดทำแผนเคสทดสอบและ Traceability Matrix ครบทุก AC (`testplan.md`)
- [ ] 🛑 **✋ Gate 6 (Tech Lead Approval):** รอการตรวจรับและอนุมัติจาก Tech Lead (@Au3Hatsawat)

---

อ้างอิง SDD: [§02 Architecture Layout](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/02-architecture-layout.md), [§03 API Contract & Data Layer](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/03-api-contract.md), [§04 Testing Guidelines](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/04-testing-guidelines.md), และ [§05 Code Review & DoD](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/05-review-and-dod.md)
