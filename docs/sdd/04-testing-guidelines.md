# §4 · มาตรฐานการทดสอบและแนวทาง TDD (Testing Guidelines & TDD Conventions)

> **แนวคิดหลัก:** Test-Driven Development (TDD)
> ทุกฟังก์ชันและทุกข้อใน Acceptance Criteria (AC-1 ถึง AC-6) ต้องมี Automated Test ดักไว้ก่อนเขียนโค้ดเสมอ

---

## 1. ลำดับการทดสอบ (Testing Pyramid)

| ระดับการเทส | ขอบเขตที่ต้องทดสอบ | เครื่องมือ | ความเร็ว |
|---|---|---|---|
| **Unit Tests** | UseCases, Repository Impl, Models, Calculation Helpers (BR-1..6) | `flutter_test`, `mocktail` | เร็วมาก (< 1 วินาที) |
| **Widget Tests** | หน้าจอแสดงผล 4 สถานะ (Loading, Empty, Error, Success), แตะจุดบนกราฟ (15-1a) | `flutter_test` | ปานกลาง (< 3 วินาที) |
| **Integration Tests** | E2E Flow: เปิดแอป ➔ โหลดกราฟ ➔ สลับช่วง 7/30/90 วัน ➔ แตะเลือกสกุลเงิน | `integration_test` | นาที |

---

## 2. กฎการทดสอบแบบ TDD (Red-Green-Refactor Protocol)

1. **Red (เขียนเทสให้พังก่อน):**
   - Agent `test-author` แปลงข้อกำหนดใน AC เป็น Unit/Widget Test ที่ยังไม่มี Implementation จริง
   - เทสต้องรันแล้วล้มเหลว (Red) ด้วยเหตุผลที่ถูกต้อง (เช่น ยังไม่มีคลาส หรือคืนค่าไม่ตรง)
2. **Green (เขียนโค้ดให้ผ่านพอดี):**
   - Agent `implementer` เขียนโค้ดแอปพลิเคชันเฉพาะส่วนที่จำเป็นเพื่อให้เทสผ่าน (Green)
   - **กฎเหล็ก:** `implementer` ห้ามแตะต้องหรือแก้ไขไฟล์ทดสอบเพื่อเอาใจโค้ดเด็ดขาด
3. **Refactor (จัดระเบียบโค้ด):**
   - `implementer` ปรับโครงสร้างโค้ดให้สะอาด เป็นไปตาม Clean Architecture โดยที่เทสทุกตัวต้องยังคงผ่าน (Green) 100%

---

## 3. ตารางความเชื่อมโยงระหว่าง AC และชุดการทดสอบ (Traceability Matrix)

| Acceptance Criteria | ประเภทเทส | ไฟล์ทดสอบเป้าหมาย | เงื่อนไขที่ตรวจ |
|---|---|---|---|
| **AC-1 (กราฟและสถิติ)** | Widget Test | `test/features/exchange_rate/presentation/screens/exchange_rate_trend_screen_test.dart` | กราฟเส้น, การ์ด Max/Min, และ Data Row แสดงผลเมื่อโหลดสำเร็จ |
| **AC-2 (คำนวณ %)** | Unit Test | `test/core/utils/trend_calculator_test.dart` | Input: 33.568 และ 33.750 $\rightarrow$ Output: `+0.54%` และป้าย "สูงขึ้น" |
| **AC-3 (แตะจุดบนกราฟ)** | Widget Test | `test/features/exchange_rate/presentation/widgets/trend_line_chart_test.dart` | เมื่อ Simulate tap ที่จุดวันที่ 10 ต.ค. แถวรายละเอียดอัปเดตเป็น `10 ต.ค. · 33.570` |
| **AC-4 (สลับช่วง & Cache)** | Unit Test | `test/features/exchange_rate/data/repositories/exchange_rate_repository_impl_test.dart` | สลับช่วง 7 วันเรียก RemoteDataSource, สลับกลับ 30 วันดึงจาก Cache โดยไม่เรียก HTTP ซ้ำ |
| **AC-5 (Error & Retry)** | Widget Test | `test/features/exchange_rate/presentation/widgets/states/error_state_widget_test.dart` | แสดงข้อความ "ดึงข้อมูลไม่สำเร็จ" และเมื่อกดปุ่ม "ลองอีกครั้ง" จะทริกเกอร์โหลดซ้ำ |
| **AC-6 (Source Note)** | Widget Test | `test/features/exchange_rate/presentation/widgets/source_note_widget_test.dart` | มีแถบ Source Note และกดแล้วเรียก URL Launcher ไปยัง Frankfurter |

---

## 4. ตัวอย่างโครงสร้างการเขียน Unit Test ด้วย Mocktail

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// import domain & data classes

class MockExchangeRateRemoteDataSource extends Mock implements ExchangeRateRemoteDataSource {}
class MockExchangeRateLocalDataSource extends Mock implements ExchangeRateLocalDataSource {}

void main() {
  late ExchangeRateRepositoryImpl repository;
  late MockExchangeRateRemoteDataSource mockRemoteDataSource;
  late MockExchangeRateLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockExchangeRateRemoteDataSource();
    mockLocalDataSource = MockExchangeRateLocalDataSource();
    repository = ExchangeRateRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getExchangeRateTrend', () {
    test('AC-4: ควรคืนค่าจาก Cache เมื่อเคยโหลดช่วงวันเดียวกันแล้ว', () async {
      // Arrange (Given)
      // Act (When)
      // Assert (Then)
    });
  });
}
```

---

## 5. คำสั่งที่ใช้ในการรันเทส (Test Commands)

```bash
# รันเทสทั้งหมดในโปรเจกต์
fvm flutter test

# รันเทสเฉพาะไฟล์
fvm flutter test test/core/utils/trend_calculator_test.dart

# รันเทสพร้อมคำนวณ Coverage
fvm flutter test --coverage
```
