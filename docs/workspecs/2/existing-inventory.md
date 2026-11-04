# รายงานการสำรวจโค้ดเดิมและส่วนประกอบที่มีอยู่ (Existing Codebase Inventory)

> **ใบงานที่สำรวจ:** Issue #2 — `[Service] Develop: API Client เชื่อมต่อ Frankfurter API พร้อมระบบแคชข้อมูลรายวัน`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **สำรวจโดย:** Subagent `codebase-scout`  
> **วันที่สำรวจ:** 2026-11-04  
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3, §4](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)

---

## 1. ภาพรวมสถานะ Codebase ปัจจุบัน (Current Codebase Snapshot)

จากการสำรวจโครงสร้างไดเรกทอรี `app/` ทั้งใน `lib/` และ `test/` ตลอดจน `pubspec.yaml`:

- **สถานะโปรเจกต์:** เป็นโปรเจกต์ Flutter เริ่มต้น (Fresh Scaffold / Starter App) โครงสร้างโฟลเดอร์ Clean Architecture ยังไม่ได้ถูกสร้างขึ้น
- **โค้ดที่มีอยู่เดิมใน `lib/`:**
  - `lib/main.dart`: เป็น Default Flutter Counter App (`MyApp`, `MyHomePage`)
- **โค้ดที่มีอยู่เดิมใน `test/`:**
  - `test/widget_test.dart`: เป็น Default Smoke Test สำหรับ Counter App
- **สถานะ Dependencies ใน `pubspec.yaml`:**
  - มีแพ็กเกจหลักครบถ้วนตาม SDD §1:
    - Networking: `dio: ^5.4.3+1`
    - State Management: `flutter_riverpod: ^2.5.1`
    - Data & Models: `equatable: ^2.0.5`
    - Utilities: `intl: ^0.19.0`
    - Charts & UI: `fl_chart: ^0.68.0`, `google_fonts: ^6.2.1`, `flutter_svg: ^2.0.10+1`, `url_launcher: ^6.3.0`
    - Testing: `flutter_test`, `flutter_lints: ^5.0.0`, `mocktail: ^1.0.4`
  - **ข้อสังเกตสำคัญ (Critical Architectural Observation):**  
    โปรเจกต์ไม่ได้ติดตั้งไลบรารี Functional Programming เช่น `dartz` หรือ `fpdart` แต่ใน Workspec ระบุการใช้ `Either<Failure, ExchangeRateTrend>` ดังนั้นระบบจำเป็นต้องสร้าง lightweight custom `Either<L, R>` ใน `lib/core/errors/failures.dart` เพื่อให้สอดคล้องกับกฎ Pure Dart ใน Domain Layer (SDD §2) โดยไม่เพิ่ม third-party dependency ที่ไม่จำเป็น

---

## 2. ตารางสรุปสิ่งที่มีอยู่แล้ว vs สิ่งที่ต้องสร้างใหม่ (Inventory Breakdown)

### 2.1 โมเดลข้อมูล (Entities, DTOs & Enums)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `RatePoint` (Entity) | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/domain/entities/rate_point.dart` | Pure Dart Immutable Entity สำหรับจุดข้อมูล (date, rate, base, quote) |
| `ExchangeRateTrend` (Entity) | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart` | รวม List of RatePoint, maxRate, minRate, % change, trendDirection |
| `CurrencyPair` (Entity) | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/domain/entities/currency_pair.dart` | เก็บ base & quote (Default: USD/THB) |
| `TrendDirection` (Enum) | 🔴 **ต้องสร้างใหม่** | ใน `exchange_rate_trend.dart` | `enum TrendDirection { up, down, neutral }` |
| `RatePointModel` (DTO) | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/data/models/rate_point_model.dart` | DTO แปลง JSON array จาก Frankfurter API (`/v2/rates`) เข้าสู่ `RatePoint` |

### 2.2 โครงสร้างระบบเครือข่ายและข้อผิดพลาด (Core Network & Error Handling)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `DioClient` | 🔴 **ต้องสร้างใหม่** | `lib/core/network/dio_client.dart` | Factory / Singleton สร้าง instance Dio พร้อม BaseOptions, Timeout (connectTimeout, receiveTimeout) |
| `ApiEndpoints` | 🔴 **ต้องสร้างใหม่** | `lib/core/network/api_endpoints.dart` | เก็บ Base URL (`https://api.frankfurter.dev`) และ Path `/v2/rates` |
| `Failures` & `Either` | 🔴 **ต้องสร้างใหม่** | `lib/core/errors/failures.dart` | `Failure`, `ServerFailure`, `NetworkFailure`, `EmptyDataFailure`, `CacheFailure` พร้อม Lightweight `Either<L, R>` |
| `Exceptions` | 🔴 **ต้องสร้างใหม่** | `lib/core/errors/exceptions.dart` | `ServerException`, `NetworkException`, `EmptyDataException`, `CacheException` |

### 2.3 แหล่งข้อมูลและคลังข้อมูล (DataSources & Repositories)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `ExchangeRateRemoteDataSource` | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart` | ดึงข้อมูลอัตราแลกเปลี่ยนผ่าน Frankfurter API ด้วย DioClient |
| `ExchangeRateLocalDataSource` | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart` | ระบบ Caching ใน Memory ตาม BR-2 (Key: `${base}_${quote}_${days}_${currentDate}`) |
| `ExchangeRateRepository` (Interface) | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/domain/repositories/exchange_rate_repository.dart` | สัญญา interface คืนค่า `Future<Either<Failure, ExchangeRateTrend>>` |
| `ExchangeRateRepositoryImpl` | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart` | ประสานงาน Local DataSource (Cache) และ Remote DataSource พร้อมคำนวณสถิติ |

### 2.4 UseCases และ Business Logic Helpers (Domain Core & Utils)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `GetExchangeRateTrendUseCase` | 🔴 **ต้องสร้างใหม่** | `lib/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart` | UseCase กลางสำหรับ Presentation Layer เรียกใช้งาน |
| `TrendCalculator` | 🔴 **ต้องสร้างใหม่** | `lib/core/utils/trend_calculator.dart` | ฟังก์ชันคำนวณ % change (BR-3), หา max/min, และระบุ TrendDirection (BR-4) |
| `DateFormatter` | 🔴 **ต้องสร้างใหม่** | `lib/core/utils/date_formatter.dart` | ฟังก์ชันคำนวณช่วงวัน `from` / `to` และจัดรูปแบบ `YYYY-MM-DD` (BR-1) |

### 2.5 หน้าจอ วิดเจ็ต และ Routing (Presentation Layer)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `MyApp` / `MyHomePage` | 🟡 **มีอยู่เดิม (ไม่ใช้งานซ้ำ)** | `lib/main.dart` | เป็น Counter App เริ่มต้น ไม่เกี่ยวข้องกับ Issue #2 (จะถูกปรับปรุงใน Issue หน้าจอ) |
| หน้าจอและวิดเจ็ตสำหรับ Issue #2 | ⚪ **อยู่นอกขอบเขต (No UI Scope)** | - | Issue #2 เป็น Service/Data Layer สำหรับเตรียม Data Core เท่านั้น ไม่มีงาน UI |

### 2.6 ชุดการทดสอบ (Automated Test Suite)

| ชิ้นส่วน | สถานะ | ไฟล์เป้าหมาย / แหล่งที่มา | รายละเอียดและการนำไปใช้ |
|---|---|---|---|
| `widget_test.dart` | 🟡 **มีอยู่เดิม (ไม่ใช้งานซ้ำ)** | `test/widget_test.dart` | เป็น Smoke test ของ Counter App เริ่มต้น |
| `trend_calculator_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/core/utils/trend_calculator_test.dart` | Unit Test ตรวจสอบสูตรคำนวณ % change, max, min (AC-2) |
| `date_formatter_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/core/utils/date_formatter_test.dart` | Unit Test คำนวณช่วงวันที่ `from`/`to` (BR-1) |
| `exchange_rate_remote_datasource_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/features/exchange_rate/data/datasources/exchange_rate_remote_datasource_test.dart` | Unit Test ตรวจสอบการยิง Dio และจัดการ HTTP 200 / 422 / Exception |
| `exchange_rate_local_datasource_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/features/exchange_rate/data/datasources/exchange_rate_local_datasource_test.dart` | Unit Test ตรวจสอบระบบ Caching รายวัน (AC-4, BR-2) |
| `exchange_rate_repository_impl_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/features/exchange_rate/data/repositories/exchange_rate_repository_impl_test.dart` | Unit Test ตรวจสอบ Logic สลับช่วง, คืนค่า Cache, และ Failure handling (AC-4, AC-5) |
| `get_exchange_rate_trend_usecase_test.dart` | 🔴 **ต้องสร้างใหม่** | `test/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase_test.dart` | Unit Test ตรวจสอบ UseCase ส่งต่อพารามิเตอร์และผลลัพธ์ |

---

## 3. การวิเคราะห์ผลกระทบและความเสี่ยง (Side Effects & Risks)

1. **ไม่มีการกระทบโค้ดเดิม (Zero Regression Risk):**  
   เนื่องจาก Codebase ปัจจุบันมีเพียง Counter App เริ่มต้น การสร้าง Feature `exchange_rate` ใน `lib/core/` และ `lib/features/exchange_rate/` จึงเป็นชิ้นส่วนใหม่ทั้งหมด ไม่มีความเสี่ยงเรื่องการกระทบฟังก์ชันเดิม
2. **การจัดการ Lightweight `Either` Type:**  
   เนื่องจากไม่ได้ใช้ package เสริมอย่าง `dartz`/`fpdart` ผู้พัฒนาจะต้องสร้าง Sealed Class หรือ Abstract Class `Either<L, R>` ใน `lib/core/errors/failures.dart` ซึ่งจะช่วยลด dependency น้ำหนักเบา และสอดคล้องกับ Dart 3 pattern matching อย่างดี
3. **การทดสอบด้วย Mocktail:**  
   มี `mocktail: ^1.0.4` พร้อมใน `pubspec.yaml` ทำให้สามารถเขียน Mock class สำหรับ `Dio`, `RemoteDataSource`, และ `LocalDataSource` ได้ทันทีโดยไม่ต้องรัน `build_runner`

---

## 4. ข้อเสนอแนะสำหรับขั้นตอนถัดไป (Recommendations for Stage B)

- ทีมงานในขั้นตอนถัดไป (`spec-be.md`, `testplan.md`) สามารถอ้างอิงรายชื่อไฟล์ทั้ง 15 ไฟล์เป้าหมาย (9 ไฟล์โค้ดแอป + 6 ไฟล์เทส) ที่ระบุในรายงานนี้เป็นพิมพ์เขียวสำหรับทำ Technical Spec และ Test Matrix ได้ทันที
- สัญญา Interface ของ `GetExchangeRateTrendUseCase` และ `ExchangeRateTrend` Entity มีความชัดเจน พร้อมส่งมอบให้ฝั่ง UI ใน Issue ถัดไปตามที่กำหนดใน `workspec-fe.md`

---
อ้างอิง SDD: §2 โครงสร้างโฟลเดอร์และขอบเขตเลเยอร์ และ §3 ข้อกำหนด API และสัญญาการแลกเปลี่ยนข้อมูล
ลิงก์: [docs/sdd/02-architecture-layout.md](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/02-architecture-layout.md) · [docs/sdd/03-api-contract.md](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/03-api-contract.md)
