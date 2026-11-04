# §1 · การตัดสินใจด้านเทคสแตก (Tech Stack Decisions)

> **โปรเจกต์:** MAT 15 – Exchange Rate Trend (แนวโน้มอัตราแลกเปลี่ยน)
> **เป้าหมาย:** แอปพลิเคชัน Flutter บนมือถือและแท็บเล็ต ตามมาตรฐาน Clean Architecture และ Best Practice

---

## 1. ข้อมูลเทคสแตกหลัก (Core Technologies)

| เลเยอร์ / เครื่องมือ | เทคโนโลยีที่เลือก | เหตุผลในการเลือก |
|---|---|---|
| **Framework** | **Flutter (Dart 3.x)** | รองรับ Cross-Platform (iOS, Android, Web, Desktop) สอดคล้องกับขนาดหน้าจอ 360px, 320px และ 834px ในสเปค |
| **SDK Version Manager**| **FVM (Flutter Version Management)** | ตรึงเวอร์ชัน Flutter SDK (3.x stable) ให้นักพัฒนาทุกคนในทีมใช้เวอร์ชันเดียวกัน |
| **Architecture** | **Clean Architecture (Feature-First)** | แยก Business Logic, UI และ Data ออกจากกันชัดเจน ทดสอบง่าย (High Testability) |
| **State Management** | **Flutter Riverpod (v2.x)** | ปลอดภัยจาก Compile-time safety, ไม่ผูกติดกับ BuildContext, รองรับ Caching และ Asynchronous State ดีเยี่ยม |
| **Networking & HTTP** | **Dio** | รองรับ Interceptor, Timeout configuration, และ Error Handling ขั้นสูง |
| **Chart Library** | **fl_chart** | รองรับการวาด Line Chart แบบปรับแต่งสูง (Custom X/Y Axis, Tooltip on Touch, Gridlines) ตรงตามสเปค 15-1 และ 15-1a |
| **Typography & Fonts**| **google_fonts (`IBM Plex Sans Thai`)** | ตรงตามสเปคของ Figma Design System ทั้งแบบ Regular, Medium, SemiBold, Bold |
| **Vector Icons** | **flutter_svg** | เรนเดอร์ไอคอน SVG ตามสเปค Figma |
| **URL Launcher** | **url_launcher** | สำหรับเปิดเว็บแหล่งข้อมูลภายนอก (Source Note: https://frankfurter.dev) ตาม AC-6 |
| **Testing** | **flutter_test, mocktail** | Unit Testing, Widget Testing และ Mocking โดยไม่ต้องพึ่ง Code Generation |

---

## 2. รายการ Dependencies ใน `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # Networking
  dio: ^5.4.3+1
  
  # Charts & UI
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  flutter_svg: ^2.0.10+1
  url_launcher: ^6.3.0
  
  # Utilities
  intl: ^0.19.0
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  mocktail: ^1.0.3
```

---

## 3. ข้อกำหนดสภาพแวดล้อมการพัฒนา (Developer Setup)
- **เครื่องมือจัดการเวอร์ชัน:** ใช้ `fvm flutter` ในการรันคำสั่งทั้งหมด
- **การจัดรูปแบบโค้ด:** รัน `dart format .` ก่อนทุก Commit
- **Linter:** ปฏิบัติตามกฎ `flutter_lints` 100% ไม่มี warning ค้าง
