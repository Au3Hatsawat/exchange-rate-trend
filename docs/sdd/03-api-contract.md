# §3 · ข้อกำหนด API และสัญญาการแลกเปลี่ยนข้อมูล (API Contract & Data Formats)

> **API Provider:** [Frankfurter API v2](https://frankfurter.dev) (Open-source, ไม่ต้องใช้ API Key)
> **เอกสารอ้างอิง:** [MAT 00 – API Reference](https://www.figma.com/design/lfzQAC9TI2kPTqVZkdhQUi?node-id=1-2)

---

## 1. ข้อมูล Endpoint และ Parameter

### `GET /v2/rates` (ดึงประวัติอัตราแลกเปลี่ยนย้อนหลัง)
- **Base URL:** `https://api.frankfurter.dev`
- **Path:** `/v2/rates`
- **HTTP Method:** `GET`
- **Query Parameters:**
  | Parameter | ชนิดข้อมูล | จำเป็น | ตัวอย่าง | คำอธิบาย |
  |---|---|---|---|---|
  | `from` | `String (YYYY-MM-DD)` | ใช่ | `2026-09-29` | วันเริ่มต้นของช่วงเวลา (ตาม BR-1) |
  | `to` | `String (YYYY-MM-DD)` | ใช่ | `2026-10-29` | วันสิ้นสุดของช่วงเวลา (วันนี้) |
  | `base` | `String (ISO 4217)` | ใช่ | `USD` | สกุลเงินต้นทาง (ค่าเริ่มต้น `USD`) |
  | `quotes` | `String (ISO 4217)` | ใช่ | `THB` | สกุลเงินปลายทางที่ต้องการเทียบ (ค่าเริ่มต้น `THB`) |

#### ตัวอย่าง Request URL เต็ม:
```http
GET https://api.frankfurter.dev/v2/rates?from=2026-09-29&to=2026-10-29&base=USD&quotes=THB HTTP/1.1
Host: api.frankfurter.dev
Accept: application/json
```

---

## 2. รูปแบบ Response สำเร็จ (HTTP 200 OK)

API คืนค่าเป็น JSON Array ของอ็อบเจกต์รายวัน เรียงลำดับจากอดีตไปหาปัจจุบัน:

```json
[
  {
    "date": "2026-09-29",
    "base": "USD",
    "quote": "THB",
    "rate": 33.568
  },
  {
    "date": "2026-09-30",
    "base": "USD",
    "quote": "THB",
    "rate": 33.551
  },
  {
    "date": "2026-10-29",
    "base": "USD",
    "quote": "THB",
    "rate": 33.750
  }
]
```

### การแปลงเข้าสู่ Domain Entity:
- `date`: แปลงเป็น `DateTime` (ตัดเวลาทิ้ง ให้เหลือเฉพาะวัน)
- `rate`: แปลงเป็น `double`

---

## 3. การจัดการกรณีผิดพลาด (Error Handling Contract)

| กรณี | HTTP Status | พฤติกรรมที่ระบบต้องทำ | ผลลัพธ์ใน UI |
|---|---|---|---|
| **ไม่มีข้อมูลในช่วงนี้ (BR-6)** | `200 OK` (คืนค่า `[]`) | มองว่าเป็นข้อมูลว่าง ไม่ใช่ Error | แสดง **Empty State (15-1c)**: "ไม่มีข้อมูลในช่วงนี้" |
| **พารามิเตอร์ไม่ถูกต้อง** | `422 Unprocessable` | โยน `ServerFailure(message: "พารามิเตอร์ไม่ถูกต้อง")` | แสดง **Error State (15-1d)** พร้อมปุ่ม Retry |
| **เครือข่ายหลุด / Timeout** | Socket / Timeout | โยน `NetworkFailure(message: "ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้")` | แสดง **Error State (15-1d)** พร้อมปุ่ม Retry |
| **เซิร์ฟเวอร์ขัดข้อง** | `500 Internal Server` | โยน `ServerFailure(message: "ดึงข้อมูลไม่สำเร็จ")` | แสดง **Error State (15-1d)** พร้อมปุ่ม Retry |

---

## 4. กฎการคำนวณและแคช (Business Logic & Caching Contract)

### กฎการคำนวณสถิติ (BR-3 & BR-4):
1. **Max Rate / Min Rate:** หาค่า `double` สูงสุดและต่ำสุดจาก Array ของ `rate` ในช่วงเวลานั้น
2. **เปอร์เซ็นต์การเปลี่ยนแปลง (% Change):**
   $$\Delta\% = \frac{\text{lastRate} - \text{firstRate}}{\text{firstRate}} \times 100$$
   - ปัดทศนิยม 2 ตำแหน่ง
   - แสดงเครื่องหมายบวกนำหน้าเมื่อค่าเป็นบวก (เช่น `+0.54%`)
3. **ป้ายแนวโน้ม (Level Badge):**
   - $\Delta\% > 0$ $\rightarrow$ "สูงขึ้น" (`TrendDirection.up`, สีเขียว/น้ำเงิน)
   - $\Delta\% < 0$ $\rightarrow$ "ลดลง" (`TrendDirection.down`, สีส้ม/แดง)
   - $\Delta\% == 0$ $\rightarrow$ "ทรงตัว" (`TrendDirection.neutral`, สีเทา)

### กฎการแคชข้อมูลรายวัน (BR-2):
- **Cache Key:** `${base}_${quotes}_${days}_${currentDate}` (เช่น `USD_THB_30_2026-11-04`)
- **นโยบาย:** ข้อมูลอัตราแลกเปลี่ยนของวันเดิมจะไม่มีการเปลี่ยนแปลงระหว่างวัน หากมีข้อมูลใน Cache แล้ว ให้ดึงจาก Memory Cache ทันทีโดยไม่ต้องส่ง Network Request ซ้ำ
