# Workspec (Service / Data) — Issue #2: API Client & Caching Service

> **อ้างอิง Issue:** #2 — `[Service] Develop: API Client เชื่อมต่อ Frankfurter API พร้อมระบบแคชข้อมูลรายวัน`
> **ใบงานหลัก:** #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`
> **มาตรฐานสถาปัตยกรรม:** [Project SDD §1, §2, §3](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)

---

## 1. ขอบเขตงานฝั่ง Service & Data Layer

ใบงานนี้เป็นแกนกลางด้านข้อมูล (Data & Business Core) สำหรับฟีเจอร์ MAT 15 ทั้งหมด มีหน้าที่ดึงข้อมูลอัตราแลกเปลี่ยนย้อนหลัง, คำนวณสถิติ, แคชข้อมูล และส่งมอบให้ Presentation Layer ใช้งาน

---

## 2. รายละเอียดข้อกำหนดการทำงาน (Functional Requirements Breakdown)

### 2.1 Domain Layer (Pure Dart)
1. **Entities:**
   - `RatePoint`: ประกอบด้วย `DateTime date`, `double rate`, `String base`, `String quote`
   - `ExchangeRateTrend`: ประกอบด้วย `List<RatePoint> points`, `double maxRate`, `double minRate`, `double changePercentage`, `TrendDirection trendDirection`
   - `CurrencyPair`: `String base`, `String quote` (ค่าเริ่มต้น: `USD`, `THB`)
   - `enum TrendDirection { up, down, neutral }`
2. **Repository Contract (Interface):**
   - `Future<Either<Failure, ExchangeRateTrend>> getTrend({required CurrencyPair pair, required int days});`
3. **UseCases:**
   - `GetExchangeRateTrendUseCase`: รับ `pair` และ `days` ➔ เรียก Repository

### 2.2 Data Layer
1. **Models (DTO):**
   - `RatePointModel`: แปลง JSON จาก API (`date`, `base`, `quote`, `rate`) ➔ map เข้าสู่ `RatePoint`
2. **DataSources:**
   - `ExchangeRateRemoteDataSource`:
     - ยิง HTTP GET ด้วย `DioClient`:
       `https://api.frankfurter.dev/v2/rates?from={from}&to={to}&base={base}&quotes={quote}`
     - คำนวณช่วงวันตาม **BR-1**: `from = วันนี้ - days`, `to = วันนี้` (Format: `YYYY-MM-DD`)
     - รองรับ HTTP 200 (คืน List ของ RatePointModel), HTTP 200 แต่ได้ `[]` (ข้อมูลว่าง), และดักจับ DioException
   - `ExchangeRateLocalDataSource` (Caching System ตาม **BR-2**):
     - แคชข้อมูลใน Memory (Map): Key = `${base}_${quote}_${days}_${currentDate}`
     - หากพบข้อมูลที่เคยแคชไว้ในวันเดียวกัน ให้คืนค่าทันทีโดยไม่ยิง Network Request ซ้ำ
3. **Repository Implementation:**
   - `ExchangeRateRepositoryImpl`: ประสานงานระหว่าง Local Cache และ Remote DataSource
   - คำนวณค่าทางสถิติตาม **BR-3** และ **BR-4**:
     - `maxRate` = ค่า rate สูงสุดใน points
     - `minRate` = ค่า rate ต่ำสุดใน points
     - `changePercentage` = `((lastRate - firstRate) / firstRate) * 100` (ปัดทศนิยม 2 ตำแหน่ง)
     - `trendDirection`: บวก = `TrendDirection.up`, ลบ = `TrendDirection.down`, 0 = `TrendDirection.neutral`
   - จัดการ Error mapping เข้าสู่ Failure Entities: `ServerFailure`, `NetworkFailure`, `EmptyDataFailure`

---

## 3. ไฟล์ที่จะสร้างในใบงานนี้ (Target Files)

| เลเยอร์ | ที่อยู่ไฟล์ (Path ใน `app/`) | หน้าที่ |
|---|---|---|
| **Core Network** | `lib/core/network/dio_client.dart` | Singleton / Factory สร้าง Dio พร้อม config timeout |
| **Core Network** | `lib/core/network/api_endpoints.dart` | เก็บ Base URL และ Endpoint constants |
| **Core Errors** | `lib/core/errors/failures.dart` | Failure objects สำหรับ Domain/UI |
| **Core Errors** | `lib/core/errors/exceptions.dart` | Exception objects สำหรับ Data Layer |
| **Core Utils** | `lib/core/utils/date_formatter.dart` | ฟังก์ชันฟอร์แมตวันที่ `YYYY-MM-DD` |
| **Core Utils** | `lib/core/utils/trend_calculator.dart` | ฟังก์ชันคำนวณ % change, max, min, trend direction |
| **Domain Entity** | `lib/features/exchange_rate/domain/entities/rate_point.dart` | Entity จุดข้อมูลอัตราแลกเปลี่ยน |
| **Domain Entity** | `lib/features/exchange_rate/domain/entities/exchange_rate_trend.dart` | Entity สรุปแนวโน้มและสถิติ |
| **Domain Entity** | `lib/features/exchange_rate/domain/entities/currency_pair.dart` | Entity คู่สกุลเงิน |
| **Domain Repo** | `lib/features/exchange_rate/domain/repositories/exchange_rate_repository.dart` | Interface สัญญาดึงข้อมูล |
| **Domain UseCase**| `lib/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase.dart` | UseCase ดึงแนวโน้มอัตราแลกเปลี่ยน |
| **Data Model** | `lib/features/exchange_rate/data/models/rate_point_model.dart` | DTO แปลง JSON จาก API |
| **Data Source** | `lib/features/exchange_rate/data/datasources/exchange_rate_remote_datasource.dart` | เรียก Frankfurter API |
| **Data Source** | `lib/features/exchange_rate/data/datasources/exchange_rate_local_datasource.dart` | ระบบ Cache รายวัน |
| **Data Repo** | `lib/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart` | ประสานงาน Cache + Remote + คำนวณ |
| **Test** | `test/core/utils/trend_calculator_test.dart` | Unit Test คำนวณสถิติ (AC-2) |
| **Test** | `test/features/exchange_rate/data/datasources/exchange_rate_remote_datasource_test.dart` | Unit Test ยิง API จริง / Mock Dio |
| **Test** | `test/features/exchange_rate/data/datasources/exchange_rate_local_datasource_test.dart` | Unit Test Caching (AC-4) |
| **Test** | `test/features/exchange_rate/data/repositories/exchange_rate_repository_impl_test.dart` | Unit Test Repo logic & error handling (AC-4, AC-5) |
| **Test** | `test/features/exchange_rate/domain/usecases/get_exchange_rate_trend_usecase_test.dart` | Unit Test UseCase |

---

## 4. เกณฑ์การยอมรับ (Acceptance Criteria Coverage)
- [x] **AC-2:** คำนวณค่าแรก 33.568 และค่าสุดท้าย 33.750 ได้ผลลัพธ์ `+0.54%` และสถานะ `TrendDirection.up`
- [x] **AC-4:** สลับช่วงเวลา 7 วันส่งคำขอใหม่ และเมื่อสลับกลับมาช่วง 30 วันเดิมคืนค่าจาก Cache
- [x] **AC-5:** เมื่อ Network หลุดหรือ API มีปัญหา คืนค่า Failure ให้ UI นำไปแสดง Error State
