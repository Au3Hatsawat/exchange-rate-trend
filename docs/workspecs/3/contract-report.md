# รายงานผลการตรวจสอบสัญญาทางเทคนิค (Contract Verification Report — Meeting Point 1)

> **อ้างอิง Issue:** #3 — `[FE] Develop: หน้าจอแสดงกราฟแนวโน้มอัตราแลกเปลี่ยนและสถิติ (Screen 15-1 & 15-1a)`  
> **ใบงานหลัก:** Issue #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`  
> **กิ่งงาน (Branch):** `feat/3-trend-chart-screen`  
> **ผู้ตรวจสอบ:** Subagent `contract-checker` (Meeting Point 1)  
> **วันที่ตรวจสอบ:** 2026-11-04  
> **เอกสารที่นำมาเปรียบเทียบ:**
> - สเปคฝั่งหน้าจอ: [`docs/workspecs/3/spec-fe.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-fe.md)
> - สเปคฝั่งเซอร์วิส/ข้อมูล: [`docs/workspecs/3/spec-be.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/spec-be.md)
> - การสำรวจโค้ดเดิม: [`docs/workspecs/3/existing-inventory.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/existing-inventory.md)
> - สเปคงานดีไซน์: [`docs/workspecs/3/design.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/design.md)
> - แผนงานตั้งต้น: [`docs/workspecs/3/workspec-fe.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-fe.md) · [`docs/workspecs/3/workspec-be.md`](file:///Users/hatsawat.i/Desktop/Dev/training/docs/workspecs/3/workspec-be.md)
> - มาตรฐานสถาปัตยกรรม: [Project SDD §1, §2, §3, §4, §5](file:///Users/hatsawat.i/Desktop/Dev/training/docs/sdd/)

---

## 1. บทสรุปสถานะการตรวจสอบ (Executive Summary)

### **สถานะภาพรวม: ✅ ผ่าน (PASS)**

จากการตรวจสอบและเปรียบเทียบสัญญาทางเทคนิคระหว่างฝั่งหน้าจอ (`spec-fe.md`) และฝั่งเซอร์วิส/ข้อมูล (`spec-be.md`) ร่วมกับโค้ดจริงในคลังข้อมูลและดีไซน์ใน Figma อย่างละเอียดครบทั้ง 7 มิติ พบว่า **สัญญาทั้งสองฝั่งมีความสอดคล้อง เข้ากันได้อย่างสมบูรณ์ 100%** ไม่มีข้อขัดแย้งเชิงโครงสร้างข้อมูล ชนิดข้อมูล หรือ Null Safety และครอบคลุม Acceptance Criteria ทั้งหมด (AC-1, AC-2, AC-3, AC-4, AC-6) ตามเกณฑ์ Definition of Done

> [!NOTE] **บันทึกการปรับประสานสัญญาที่ดำเนินการในรอบนี้ (Harmonization Actions):**  
> 1. **Constructor Parameter ของ `ExchangeRateNotifier`:** ฝั่ง `spec-be.md` ได้รับการปรับให้ใช้ชื่อพารามิเตอร์ `getExchangeRateTrendUseCase` ให้ตรงกับ `spec-fe.md`
> 2. **Dependency Injection Providers ใน `exchange_rate_provider.dart`:** ทั้งสองฝั่งใช้โครงสร้างและชื่อ Provider เป็นมาตรฐานเดียวกัน (`dioProvider`, `remoteDataSourceProvider`, `localDataSourceProvider`, `exchangeRateRepositoryProvider`, `getExchangeRateTrendUseCaseProvider`, `exchangeRateNotifierProvider`) พร้อมรองรับการ Override ในระดับ Widget Test ได้อย่างสมบูรณ์แบบ

---

## 2. ตารางสรุปผลการตรวจสอบ 7 มิติ (7-Dimension Contract Checkmatrix)

```text
┌────────────────────────────────────────────────────────────────────────┐
│                   7-DIMENSION CONTRACT CHECKMATRIX                     │
├────────────────────────────────────────┬────────┬──────────────────────┤
│ มิติที่ตรวจสอบ                         │ ผลตรวจ │ หมายเหตุ             │
├────────────────────────────────────────┼────────┼──────────────────────┤
│ 1. FE ขอในสิ่งที่ BE ไม่มีหรือไม่      │ ✅ ผ่าน│ Method, UseCase ตรงกัน│
│ 2. ชื่อฟิลด์ตรงกันหรือไม่              │ ✅ ผ่าน│ camelCase ตรงกัน 100%│
│ 3. Data Type ตรงกันหรือไม่             │ ✅ ผ่าน│ Type ปลอดภัย ไร้ข้อขัดแย้ง│
│ 4. Nullability & Null Safety           │ ✅ ผ่าน│ Safe Nullable & Guards│
│ 5. รูปแบบ Error Response & Failures    │ ✅ ผ่าน│ 4 Failures แมป 4 States│
│ 6. ครอบคลุมทุก Acceptance Criteria     │ ✅ ผ่าน│ AC-1, 2, 3, 4, 6 ครบ │
│ 7. ป้องกันการเขียนซ้ำกับโค้ดเดิม       │ ✅ ผ่าน│ Re-use 100% Zero Dupl│
└────────────────────────────────────────┴────────┴──────────────────────┘
```

---

## 3. ผลการประเมินรายมิติอย่างละเอียด (Detailed Dimension Assessment)

### มิติ 1: FE ขอในสิ่งที่ BE ไม่มีหรือไม่ (Interface & Provider Signatures)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

- **UseCase Invocation Signature:**
  - ฝั่ง FE เรียกใช้ UseCase ผ่าน StateNotifier:
    ```dart
    final result = await _getExchangeRateTrendUseCase(
      pair: targetPair,
      days: targetDays,
    );
    ```
  - ฝั่ง BE ส่งมอบ `GetExchangeRateTrendUseCase` ที่พัฒนาและผ่าน Unit Tests แล้วใน Issue #2:
    ```dart
    Future<Either<Failure, ExchangeRateTrend>> call({
      required CurrencyPair pair,
      required int days,
    });
    ```
    พารามิเตอร์ `pair` และ `days` ตรงกันทุกประการ
- **ความต้องการของ Presentation Layer ต่อ Entity:**
  - `trend.points` $\rightarrow$ `List<RatePoint>` ใช้พล็อตบน `TrendLineChart` (`fl_chart`)
  - `trend.maxRate` $\rightarrow$ `double` ส่งให้ `StatCardCompact(label: 'สูงสุด')`
  - `trend.minRate` $\rightarrow$ `double` ส่งให้ `StatCardCompact(label: 'ต่ำสุด')`
  - `trend.changePercentage` $\rightarrow$ `double` ส่งให้ `TrendSummaryRow` แสดง `+0.54%`
  - `trend.trendDirection` $\rightarrow$ `TrendDirection` ส่งให้ `TrendSummaryRow` เรนเดอร์ Level Badge
  - `state.pair` $\rightarrow$ `CurrencyPair` ส่งให้ `CurrencySelectorCard` แสดง `USD → THB`
  - `state.selectedDays` $\rightarrow$ `int` ส่งให้ `PeriodSegmentedControl` และข้อความ `เปลี่ยนแปลง {N} วัน`
- **ข้อสรุป:** ทุกข้อมูลและอินเทอร์เฟซที่ UI ร้องขอมีอยู่ใน Domain Layer จาก Issue #2 พร้อมใช้งานจริง ไม่มีการขอเกินขอบเขตที่ BE มีอยู่

---

### มิติ 2: ชื่อฟิลด์ตรงกันหรือไม่ (Field Naming & Case Convention)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

ทุกฟิลด์สะกดด้วย Dart Convention (`lowerCamelCase`) ตรงกัน 100% ดังนี้:

| เอนทิตี / คลาส | ฟิลด์ใน `spec-be.md` | ฟิลด์ใน `spec-fe.md` | การใช้งานใน Presentation Layer | ผลตรวจ |
|---|---|---|---|:---:|
| `RatePoint` | `date`, `rate`, `base`, `quote` | `date`, `rate`, `base`, `quote` | จุดบนกราฟ และแถว `DatePointDetailRow` | ✅ ตรงกัน |
| `CurrencyPair` | `base`, `quote`, `defaultPair` | `base`, `quote`, `defaultPair` | การ์ด `CurrencySelectorCard` (`USD → THB`) | ✅ ตรงกัน |
| `ExchangeRateTrend` | `points` | `points` | พิกัดกราฟ `fl_chart` | ✅ ตรงกัน |
| `ExchangeRateTrend` | `maxRate` | `maxRate` | ค่าสถิติสูงสุดในการ์ด `StatCardCompact` | ✅ ตรงกัน |
| `ExchangeRateTrend` | `minRate` | `minRate` | ค่าสถิติต่ำสุดในการ์ด `StatCardCompact` | ✅ ตรงกัน |
| `ExchangeRateTrend` | `changePercentage` | `changePercentage` | ตัวเลข % ใน `TrendSummaryRow` | ✅ ตรงกัน |
| `ExchangeRateTrend` | `trendDirection` | `direction` (param) | กำหนดสีและป้ายกำกับ Level Badge | ✅ ตรงกัน |
| `ExchangeRateState` | `selectedPoint` | `selectedPoint` | จุดสัมผัสบนกราฟสำหรับ Screen 15-1a | ✅ ตรงกัน |
| `ExchangeRateState` | `errorMessage` | `errorMessage` | ข้อความ Error/Empty State | ✅ ตรงกัน |

---

### มิติ 3: Data Type ตรงกันหรือไม่ (Type Safety & Format Mapping)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

- **วันเวลา (`date`):**
  - ใช้ `DateTime` ทั้งสองฝั่ง โดยใน Presentation Layer มี `DateFormatter.formatThaiShortDate(DateTime date)` รับ `DateTime` แล้วแปลงเป็น `29 ก.ย.`, `10 ต.ค.`, `29 ต.ค.` อย่างถูกต้อง
- **อัตราแลกเปลี่ยนและค่าสถิติ (`rate`, `maxRate`, `minRate`, `changePercentage`):**
  - ใช้ `double` ทุกตัว ไม่มีการใช้ `num` หรือ `String` ที่อาจทำให้เกิด runtime cast error
  - การจัดรูปแบบแสดงผล:
    - แกน Y: `toStringAsFixed(2)` ตาม BR-5
    - Stat Cards: `toStringAsFixed(3)` เช่น `33.750`, `33.568` ตาม AC-1
    - Data Row จุดสัมผัส: `toStringAsFixed(3)` เช่น `33.570` ตาม AC-3
    - เปอร์เซ็นต์: `toStringAsFixed(2)` เช่น `+0.54%` ตาม AC-2 และ BR-3
- **ทิศทางแนวโน้ม (`trendDirection`):**
  - ทั้งสองฝั่งอ้างอิง `enum TrendDirection { up, down, neutral }` เดียวกันจาก `domain/entities/exchange_rate_trend.dart`
  - FE นำไปใช้ใน Dart 3 Pattern Matching switch:
    - `TrendDirection.up` $\rightarrow$ "สูงขึ้น" (สีเขียว `AppColors.statusUp`, ไอคอน `Icons.arrow_upward`)
    - `TrendDirection.down` $\rightarrow$ "ลดลง" (สีแดง `AppColors.statusDown`, ไอคอน `Icons.arrow_downward`)
    - `TrendDirection.neutral` $\rightarrow$ "ทรงตัว" (สีเทา `AppColors.statusNeutral`, ไอคอน `Icons.remove`)
- **ผลลัพธ์การเรียกใช้งาน (`Either<Failure, ExchangeRateTrend>`):**
  - ทั้งสองฝั่งใช้ `fold((failure) => ..., (trend) => ...)` ตามสัญญากลางใน `core/errors/failures.dart`

---

### มิติ 4: ความสามารถในการเป็น Null (Nullability & Null Safety)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

- **การจัดการ `selectedPoint` (Screen 15-1a Interaction):**
  - สถานะเริ่มต้นเมื่อโหลดหน้าจอ: `selectedPoint` เป็น `null` (เรนเดอร์เฉพาะ Screen 15-1 ตามปกติ)
  - เมื่อผู้ใช้แตะจุดบนกราฟ: `selectedPoint` เปลี่ยนเป็น `RatePoint` ที่ถูกแตะ (แสดง Screen 15-1a พร้อม `DatePointDetailRow`)
  - เมื่อผู้ใช้สลับช่วงเวลา 7, 30, 90 วัน: `selectedPoint` ถูกรีเซ็ตกลับเป็น `null` ด้วย `selectedPoint: () => null` ใน `copyWith`
  - การป้องกัน Crash: วิดเจ็ตมีเงื่อนไข `if (state.selectedPoint != null) DatePointDetailRow(point: state.selectedPoint!)` จึงปลอดภัยจากการเกิด Null Dereference
- **ความไม่เป็น Null ของ Domain Entities:**
  - ฟิลด์ทั้งหมดใน `ExchangeRateTrend`, `RatePoint`, และ `CurrencyPair` ถูกประกาศเป็น `required non-nullable` ทำให้เมื่อสถานะเป็น `ExchangeRateStatus.success` ตัวแปร `state.trend!` จะมีข้อมูลครบถ้วนเสมอ
- **ค่า Fallback ป้องกัน UI พัง:**
  - `EmptyStateWidget`: มี fallback `state.errorMessage ?? 'ไม่มีข้อมูลในช่วงนี้'`
  - `ErrorStateWidget`: มี fallback `state.errorMessage ?? 'ดึงข้อมูลไม่สำเร็จ'`

---

### มิติ 5: รูปแบบ Error Response และ Failure Mapping
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

การแปลง Failure จาก Domain Layer ไปสู่ Presentation State และ UI Widget มีความชัดเจนและครอบคลุมทุกกรณี:

| Failure Entity | สาเหตุที่เกิด | State ใน Presentation | Widget ที่แสดงผล | พฤติกรรมที่รองรับ |
|---|---|---|---|---|
| `EmptyDataFailure` | API คืนค่า Array ว่าง (`[]`) ตาม BR-6 | `status: ExchangeRateStatus.empty` | `EmptyStateWidget` (Screen 15-1c) | แสดง Icon สถิติว่าง + ข้อความ `"ไม่มีข้อมูลในช่วงนี้"` (ไม่มีปุ่มลองอีกครั้ง) |
| `NetworkFailure` | ไม่มีสัญญาณเน็ต หรือ Connection Timeout | `status: ExchangeRateStatus.error` | `ErrorStateWidget` (Screen 15-1d) | แสดง Icon ข้อผิดพลาด + `"ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้"` + ปุ่ม `"ลองอีกครั้ง"` (`retry()`) |
| `ServerFailure` | เซิร์ฟเวอร์ตอบกลับ 422, 500 หรือ Parse พัง | `status: ExchangeRateStatus.error` | `ErrorStateWidget` (Screen 15-1d) | แสดง Icon ข้อผิดพลาด + `"ดึงข้อมูลไม่สำเร็จ"` + ปุ่ม `"ลองอีกครั้ง"` (`retry()`) |
| `CacheFailure` | แคชในเครื่องมีปัญหา | จัดการภายใน Repository | - | Repository ทำ Fallback ไปดึง Remote ให้อัตโนมัติ หากยังล้มเหลวจึงส่ง `ServerFailure` |

- **วงจรการทำงานของปุ่ม Retry และ Refresh:**
  - ปุ่ม "ลองอีกครั้ง" บน `ErrorStateWidget` ผูกกับ `notifier.retry()` ซึ่งจะเรียก `loadTrend(pair: state.pair, days: state.selectedDays)`
  - วิดเจ็ตหน้าจอยังถูกครอบด้วย `RefreshIndicator` เพื่อให้ผู้ใช้ดึงหน้าจอเพื่อโหลดใหม่ได้ตลอดเวลา

---

### มิติ 6: ครอบคลุมทุก Acceptance Criteria (AC-1 ถึง AC-6 Traceability)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

| ข้อกำหนด AC / FR | ความต้องการใน User Story | สัญญาฝั่ง BE (`spec-be.md`) | สัญญาฝั่ง FE (`spec-fe.md`) | สถานะ |
|---|---|---|---|:---:|
| **AC-1** | แสดงกราฟเส้น, สถิติสูงสุด, ต่ำสุด และเปอร์เซ็นต์การเปลี่ยนแปลง | ส่งมอบ `ExchangeRateTrend` บรรจุ `points`, `maxRate`, `minRate`, `changePercentage` | ประกอบหน้าจอด้วย `TrendLineChart`, `StatCardCompact` x2, `TrendSummaryRow` | ✅ ครบถ้วน |
| **AC-2** | คำนวณเปอร์เซ็นต์ถูกต้องและป้ายแนวโน้มสอดคล้อง (Benchmark: `+0.54%` ป้าย "สูงขึ้น") | จัดเตรียม `fixtureTrendSuccess30Days` พร้อม `changePercentage: 0.54`, `trendDirection: TrendDirection.up` | แสดง `+0.54%` สีเขียว พร้อม Level Badge "สูงขึ้น" และไอคอนลูกศรชี้ขึ้น | ✅ ครบถ้วน |
| **AC-3** | แตะจุดของวันที่ 10 ต.ค. แสดงผล "10 ต.ค. · 33.570" ในแถวรายละเอียด (Screen 15-1a) | จัดเตรียมจุดใน Fixture `RatePoint(date: DateTime(2026, 10, 10), rate: 33.570)` | `fl_chart` Touch Callback จับคู่ index ส่งต่อให้ `DatePointDetailRow` เรนเดอร์ `10 ต.ค. · 33.570` | ✅ ครบถ้วน |
| **AC-4** | สลับช่วง 7 วัน / 30 วัน / 90 วัน ไม่ยิง API ซ้ำเมื่อมีข้อมูลในแคช | มี `ExchangeRateLocalDataSource` จัดการ Daily In-Memory Caching | `PeriodSegmentedControl` มีกลไกล็อกปุ่มขณะโหลด และเรียก `changePeriod(days)` | ✅ ครบถ้วน |
| **AC-6** | แถบ Source Note อ้างอิง Frankfurter API และกดเปิดลิงก์ภายนอกได้ | กำหนด Host Frankfurter API และรับรองความสอดคล้อง | `SourceNoteWidget` แสดงข้อความและไอคอน `open_in_new` เรียก `url_launcher` เปิด `https://frankfurter.dev` | ✅ ครบถ้วน |
| **Responsive** | รองรับจอ 360px (Handheld), 320px (Small Mobile), 834px (Tablet) | Mock Fixtures รองรับการเรนเดอร์ทุกขนาด | ครอบด้วย `ConstrainedBox(maxWidth: 600)` จัดกึ่งกลาง และใช้ `SingleChildScrollView` ป้องกัน Overflow | ✅ ครบถ้วน |

---

### มิติ 7: ป้องกันการเขียนซ้ำกับโค้ดเดิม (Clean Architecture & Code Reusability)
**ผลการประเมิน:** ✅ **ผ่าน (Pass)**

- **Zero Backend / Domain Changes:**
  - ยืนยันว่าไม่มีการแก้ไขหรือสร้างซ้ำใน Data Layer และ Domain Layer ทุกส่วนถูกดึงมาใช้ซ้ำ 100% จาก Issue #2:
    - Entities: `ExchangeRateTrend`, `RatePoint`, `CurrencyPair`, `TrendDirection`
    - UseCase: `GetExchangeRateTrendUseCase`
    - Repository: `ExchangeRateRepository`, `ExchangeRateRepositoryImpl`
    - Core Errors: `Either<L, R>`, `Failure`, `NetworkFailure`, `ServerFailure`, `EmptyDataFailure`, `CacheFailure`
    - Core Network: `DioClient`, `ApiEndpoints`
    - Core Utils: `TrendCalculator`
- **การต่อเติมเฉพาะที่จำเป็น (Additive Utility Extension):**
  - ใน `lib/core/utils/date_formatter.dart`: ไม่มีการแก้ไขฟังก์ชันเดิม (`formatYMD`, `calculateDateRange`) แต่ทำการเพิ่มฟังก์ชันใหม่ `formatThaiShortDate(DateTime date)` สำหรับแปลงชื่อเดือนภาษาไทยย่อ
- **การปฏิบัติตามกฎเลเยอร์ Clean Architecture (SDD §2):**
  - Widgets ทั้งหมดใน `presentation/widgets/` และ `presentation/screens/` เรียกใช้เฉพาะ Domain Entities และ Notifier เท่านั้น **ห้าม** อ้างอิง `Dio`, `RemoteDataSource`, หรือ `RatePointModel` โดยตรง
  - การประกอบ Dependency ทั้งหมดถูกจำกัดไว้ที่ `exchange_rate_provider.dart` ซึ่งทำหน้าที่เป็น Composition Root เพียงจุดเดียว

---

## 4. แผนรองรับสำหรับการพัฒนาแบบ TDD ใน Stage C (TDD Alignment)

เพื่อให้นักพัฒนาฝั่ง `test-author` และ `implementer` สามารถดำเนินการได้ทันทีตามขั้นตอน TDD:
1. **Mock Class ใน Widget Test:**
   - ใช้ `MockGetExchangeRateTrendUseCase` จากแพ็กเกจ `mocktail`
   - ทำการลงทะเบียน `FakeCurrencyPair` ผ่าน `registerFallbackValue`
2. **Provider Overrides:**
   - ทดสอบหน้าจอระดับ Screen Test โดยไม่ต้องแตะต้อง Network Client:
     ```dart
     ProviderScope(
       overrides: [
         getExchangeRateTrendUseCaseProvider.overrideWithValue(mockUseCase),
       ],
       child: const MaterialApp(home: ExchangeRateTrendScreen()),
     )
     ```
3. **Smoke Test Baseline:**
   - ปรับปรุง `test/widget_test.dart` ให้ตรวจจับ `ExchangeRateTrendScreen` และยืนยันว่าการเริ่มต้นระบบด้วย `ProviderScope` ทำงานได้ราบรื่น

---

## 5. สรุปความพร้อมส่งมอบสู่ขั้นตอนถัดไป (Handover Conclusion)

สัญญาเชิงเทคนิคระหว่าง `spec-fe.md` และ `spec-be.md` มีความสมบูรณ์ ครบถ้วน และสอดคล้องกันทุกมิติ พร้อมที่จะดำเนินการต่อไปยัง:
1. ให้ Subagent **`test-author`** จัดทำแผนการทดสอบฉบับละเอียดใน `docs/workspecs/3/testplan.md`
2. รวบรวมเอกสารสเปคฉบับสมบูรณ์ใน `docs/workspecs/3/spec.md`
3. นำเสนอสเปคและแผนเทสต่อ Tech Lead ที่ **✋ Gate 6 (Spec Approval)**

---
อ้างอิง SDD: [§01 Tech Stack Decisions](../../sdd/01-tech-stack.md), [§02 Architecture Layout & Layer Boundaries](../../sdd/02-architecture-layout.md), [§03 API Contract & Data Formats](../../sdd/03-api-contract.md), [§04 Testing Guidelines](../../sdd/04-testing-guidelines.md), และ [§05 Review Checklist & Definition of Done](../../sdd/05-review-and-dod.md)
