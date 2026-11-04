# Workspec (FE) — Issue #2: API Client & Caching Service

> **อ้างอิง Issue:** #2 — `[Service] Develop: API Client เชื่อมต่อ Frankfurter API พร้อมระบบแคชข้อมูลรายวัน`
> **ใบงานหลัก:** #1 — `[Story] MAT 15: ระบบดูกราฟแนวโน้มอัตราแลกเปลี่ยน (Exchange Rate Trend)`

---

## 1. ขอบเขตงานฝั่งหน้าจอ (UI Scope)

- **งานหน้าจอโดยตรง:** **ไม่มีงานหน้าจอใหม่ในใบงานนี้**
  - หน้าจอหลัก (15-1), แตะจุด (15-1a), เลือกสกุลเงิน (15-2) และสถานะ Loading/Empty/Error จะถูกพัฒนาในใบงานถัดไป (Issue #3, #4, และ #5)
- **สัญญาอินเทอร์เฟซที่ฝั่ง UI ต้องการจากใบงานนี้ (Contract for UI):**
  - UI ต้องการเรียกใช้ `GetExchangeRateTrendUseCase` ผ่าน Provider
  - พารามิเตอร์ที่ UI ส่งเข้ามา: `CurrencyPair(base: "USD", quote: "THB")` และ `days: 7 | 30 | 90`
  - ผลลัพธ์ที่ UI คาดหวัง:
    - กรณีสำเร็จ: `ExchangeRateTrend` (ประกอบด้วย `List<RatePoint>`, `maxRate`, `minRate`, `changePercentage`, `trendDirection`)
    - กรณีผิดพลาด: `Failure` (แยกประเภท NetworkFailure, ServerFailure เพื่อให้ UI แสดงผล Error State ได้ถูกต้อง)

---

## 2. ตารางมอบหมายความรับผิดชอบ (Responsibility Matrix)

| ข้อกำหนด (FR / AC) | ผู้รับผิดชอบ | หมายเหตุ |
|---|---|---|
| **FR-1:** Data Models (`RatePoint`, `ExchangeRateHistory`) | `Service / Data` | อยู่ในใบงานนี้ |
| **FR-2:** เชื่อมต่อ Frankfurter API v2 | `Service / Data` | อยู่ในใบงานนี้ |
| **FR-3 (BR-1):** คำนวณช่วงวันที่ `from / to` | `Service / Domain`| อยู่ในใบงานนี้ |
| **FR-4 (BR-2):** ระบบ In-memory / Local Cache | `Service / Data` | อยู่ในใบงานนี้ |
| **FR-5:** Business Calculation Helpers (% Change, Max, Min, Trend) | `Service / Domain`| อยู่ในใบงานนี้ |
| **FR-6:** จัดการ Error และ Failure Types | `Service / Data` | อยู่ในใบงานนี้ |
| **AC-2:** คำนวณ % การเปลี่ยนแปลงและแนวโน้มถูกต้อง | `Service / Domain`| ทดสอบด้วย Unit Test ในใบงานนี้ |
| **AC-4:** สลับช่วงเรียก API ใหม่ / แคชวันเดียวกัน | `Service / Data` | ทดสอบด้วย Unit Test ในใบงานนี้ |
| **AC-5:** คืนค่า Failure เมื่อ Network/API มีปัญหา | `Service / Data` | ทดสอบด้วย Unit Test ในใบงานนี้ |
