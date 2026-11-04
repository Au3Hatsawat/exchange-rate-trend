# Design Specification: Issue #1 — MAT 15 Exchange Rate Trend

> **แหล่งข้อมูล:** [Figma: MAT 15 – Exchange Rate Trend](https://www.figma.com/design/O1nysCaeCKuz0bD3o2VEPa/MAT-15-%E2%80%93-Exchange-Rate-Trend)
> **UI System อ้างอิง:** [Demo Training - UI System (Node 71-172)](https://www.figma.com/design/9qHdbQEL7c4MXTAYd82doI/Demo-Training---UI-System?node-id=71-172)
> **อ่านเมื่อ:** 2026-11-04 10:55 โดย @Au3Hatsawat (Hatsawat Intrasod)
> **ขนาดหน้าจอ:** Handheld 360 × 780 (หลัก) · Small Mobile 320 × 568 · Tablet Portrait 834 × 1194 (max-width 600 center)

---

## 1. Design Tokens & Styling

### Color Palette
| Token Name | Hex Code | Semantic Role |
|---|---|---|
| `color.text.primary` | `#171B21` | ข้อความหลัก, ชื่อหน้าจอ, ค่าตัวเลขหลัก |
| `color.text.secondary` | `#525C6A` | ข้อความรอง, หน่วย, คำอธิบาย |
| `color.brand.primary` | `#2450D0` | สีไฮไลท์, เส้นกราฟ, ลิงก์, ปุ่ม Action |
| `color.bg.screen` | `#F7F8FA` | พื้นหลังของหน้าจอ |
| `color.bg.surface` | `#FFFFFF` | พื้นหลังการ์ด (Card Surface) |
| `color.bg.subtle` | `#EEF0F3` | พื้นหลังกล่องข้อความ / กรอบ Source Note |
| `color.border.default` | `#DDE1E7` | เส้นขอบการ์ด, เส้นกริดกราฟ |
| `color.status.up` | `#2450D0` / `#059669` | ป้าย "สูงขึ้น" (Trending Up) |
| `color.status.down` | `#C2410C` / `#DC2626` | ป้าย "ลดลง" (Trending Down) |
| `color.status.neutral` | `#525C6A` | ป้าย "ทรงตัว" |

### Typography (IBM Plex Sans Thai)
| Style Name | Size | Weight | Line Height | การใช้งาน |
|---|---|---|---|---|
| `Title` | 24px | SemiBold (600) | 34px | หัวข้อหน้าจอ (Top App Bar Title) |
| `Heading` | 20px | SemiBold (600) | 30px | หัวข้อส่วน (Section Header) |
| `Body/Large` | 18px | Regular (400) | 28px | ข้อความเน้น |
| `Body/Default`| 16px | Regular (400) | 24px | ข้อความทั่วไป, ข้อมูลแถว |
| `Body/Small`  | 14px | Regular (400) | 20px | คำอธิบายย่อย, ค่าในสถิติ |
| `Label/Small` | 14px | Medium (500) | 20px | ป้ายกำกับ, Badge, Segment Text |

### Spacing & Radius
- **Screen Padding:** 16px (Horizontal)
- **Component Gap:** 8px, 12px, 16px
- **Card Border Radius:** 14px (`borderRadius = 14px`, border `1px solid #DDE1E7`)
- **Pill / Badge Radius:** 999px

---

## 2. หน้าจอและ 4 สถานะ (Screens & States)

### 2.1 หน้าจอ 15-1 (Main Screen)
- **Top App Bar:** "แนวโน้มอัตราแลกเปลี่ยน"
- **Text Field (Select):** แสดงคู่สกุลเงิน เช่น `USD → THB` พร้อมไอคอนลูกศรขวา แตะแล้วไปหน้า 15-2
- **Segmented Control:** ตัวเลือก 3 ช่วง `7 วัน`, `30 วัน` (Default), `90 วัน`
- **Line Chart (Single Series):**
  - แสดงกราฟเส้นตามอัตราแลกเปลี่ยนรายวัน
  - แกน X: วันแรก · วันกลาง · วันสุดท้าย
  - แกน Y: ค่าต่ำสุด · ค่ากลาง · ค่าสูงสุด (ปัดทศนิยม 2 ตำแหน่ง)
- **Stat Cards (2 ใบแนวนอน):**
  - การ์ด "สูงสุด": แสดงค่า rate สูงสุดในช่วง
  - การ์ด "ต่ำสุด": แสดงค่า rate ต่ำสุดในช่วง
- **Data Row:** "เปลี่ยนแปลง 30 วัน" + ค่า % เช่น `+0.54%` + Level Badge "สูงขึ้น"
- **Source Note:** "Frankfurter API" แตะแล้วเปิด URL https://frankfurter.dev

### 2.2 หน้าจอ 15-1a (แตะจุดบนกราฟ)
- เมื่อแตะจุดข้อมูลบนกราฟ จะแสดง Data Row วันที่ที่เลือก เช่น `10 ต.ค. · 33.570`

### 2.3 หน้าจอ 15-1b (กำลังโหลด — Loading State)
- แสดง Block Loading ตรงกลางพื้นที่เนื้อหากราฟ
- ปุ่มกดและตัวเลือกช่วงเวลาล็อกไม่ให้กดซ้ำ

### 2.4 หน้าจอ 15-1c (ไม่มีข้อมูล — Empty State)
- แสดงเมื่อ API คืนค่า `[]`
- แสดง Icon กลางหน้าจอ + ข้อความ "ไม่มีข้อมูลในช่วงนี้"

### 2.5 หน้าจอ 15-1d (เกิดข้อผิดพลาด — Error State)
- แสดงเมื่อเรียก API ล้มเหลว หรือไม่มีอินเทอร์เน็ต
- แสดงข้อความ "ดึงข้อมูลไม่สำเร็จ" พร้อมปุ่ม "ลองอีกครั้ง" (Retry)

### 2.6 หน้าจอ 15-2 (เลือกสกุลเงิน — Currency Selector)
- Search Field สำหรับค้นหาตามชื่อหรือรหัสสกุลเงิน
- รายการ Data Row สกุลเงิน
- หากค้นหาไม่พบ แสดง Empty State "ไม่พบสกุลเงินที่ค้นหา"

---

## 3. Business Rules (BR-1 ถึง BR-6)
- **BR-1:** `from = วันนี้ − ช่วงวัน`, `to = วันนี้` รูปแบบ `YYYY-MM-DD`
- **BR-2:** สลับช่วงวันเรียก API ใหม่ แต่ช่วงที่เคยโหลดแล้วในวันเดียวกันให้ใช้ค่าแคชเดิม
- **BR-3:** เปอร์เซ็นต์การเปลี่ยนแปลง = `(ค่าสุดท้าย − ค่าแรก) ÷ ค่าแรก × 100` (ทศนิยม 2 ตำแหน่ง)
- **BR-4:** ป้ายแนวโน้ม: บวก Info "สูงขึ้น" (`trending_up`), ลบ Info "ลดลง" (`trending_down`), 0 Neutral "ทรงตัว"
- **BR-5:** ป้ายแกน X: วันแรก · วันกลาง · วันสุดท้าย, แกน Y: สูงสุด · กลาง · ต่ำสุด
- **BR-6:** Response `[]` → Empty State "ไม่มีข้อมูลในช่วงนี้"
