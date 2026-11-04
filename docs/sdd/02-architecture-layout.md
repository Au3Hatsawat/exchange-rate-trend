# §2 · โครงสร้างโฟลเดอร์และขอบเขตเลเยอร์ (Architecture Layout & Layer Boundaries)

> **รูปแบบสถาปัตยกรรม:** Clean Architecture (Feature-First)
> โค้ดของระบบต้องจัดหมวดหมู่ตามความสามารถ (Feature) และแยก 3 เลเยอร์ตามกฎ Dependency Rule อย่างเคร่งครัด

---

## 1. ผังโครงสร้างโฟลเดอร์ของโปรเจกต์ (Full Folder Layout)

```text
lib/
├── main.dart                          # Entry point: ตั้งค่า ProviderScope และเริ่มต้นแอป
├── app.dart                           # MaterialApp: กำหนด Theme, Routes และ Title
│
├── core/                              # ชิ้นส่วนกลางที่แชร์ข้าม Feature
│   ├── constants/                     # ค่าคงที่ระบบ (เช่น URL API กลาง, รหัสสกุลเงินเริ่มต้น)
│   ├── errors/                        # Failures และ Exceptions กลาง
│   │   ├── exceptions.dart            # ServerException, CacheException, NetworkException
│   │   └── failures.dart              # Failure entity สำหรับส่งต่อให้ UI (ServerFailure, etc.)
│   ├── network/                       # การเชื่อมต่อเครือข่าย
│   │   ├── dio_client.dart            # Dio instance พร้อม Timeout และ Interceptor
│   │   └── api_endpoints.dart         # URL paths ทั้งหมด
│   ├── theme/                         # ดีไซน์และ Token ตาม Figma
│   │   ├── app_colors.dart            # Palette สี (Hex codes)
│   │   ├── app_typography.dart        # IBM Plex Sans Thai styles
│   │   └── app_theme.dart             # ThemeData
│   └── utils/                         # ตัวช่วยแปลงข้อมูล
│       ├── date_formatter.dart        # แปลงวันที่ YYYY-MM-DD และภาษาไทย
│       └── trend_calculator.dart      # สูตรคำนวณ % เปลี่ยนแปลง และ Max/Min
│
└── features/                          # ฟังก์ชันการทำงานแยกตามโดเมน
    └── exchange_rate/                 # ฟีเจอร์ MAT 15: แนวโน้มอัตราแลกเปลี่ยน
        ├── data/                      # Data Layer: จัดการข้อมูลภายนอกและแคช
        │   ├── datasources/           # แหล่งดึงข้อมูลจริง
        │   │   ├── exchange_rate_remote_datasource.dart
        │   │   └── exchange_rate_local_datasource.dart (Cache)
        │   ├── models/                # DTOs พร้อม fromJson/toJson
        │   │   └── rate_point_model.dart
        │   └── repositories/          # Implement Domain Repository
        │       └── exchange_rate_repository_impl.dart
        │
        ├── domain/                    # Domain Layer: แกนกลางของ Business Logic (Pure Dart)
        │   ├── entities/              # Business Objects (Immutable)
        │   │   ├── rate_point.dart    # จุดข้อมูลอัตราแลกเปลี่ยน (date, rate)
        │   │   ├── exchange_rate_trend.dart # รวมผลลัพธ์: list of points, max, min, change %
        │   │   └── currency_pair.dart # คู่สกุลเงิน (base, quote)
        │   ├── repositories/          # Repository Contract (Interface)
        │   │   └── exchange_rate_repository.dart
        │   └── usecases/              # Business Use Cases
        │       └── get_exchange_rate_trend_usecase.dart
        │
        └── presentation/              # Presentation Layer: Widget, State และ UI
            ├── providers/             # Riverpod State Notifiers & Providers
            │   ├── exchange_rate_provider.dart
            │   └── exchange_rate_state.dart # 4 States (Initial, Loading, Success, Empty, Error)
            ├── screens/               # หน้าจอเต็ม
            │   ├── exchange_rate_trend_screen.dart # Screen 15-1 & 15-1a
            │   └── currency_select_screen.dart     # Screen 15-2
            └── widgets/               # ชิ้นส่วน UI ย่อย
                ├── trend_line_chart.dart           # กราฟเส้น fl_chart
                ├── stat_card_compact.dart          # การ์ดแสดงค่าสูงสุด / ต่ำสุด
                ├── trend_summary_row.dart          # แถวสรุป % เปลี่ยนแปลง + Level Badge
                ├── date_point_detail_row.dart      # แถวแสดงรายละเอียดเมื่อแตะจุด (15-1a)
                ├── source_note_widget.dart         # แถบแสดงที่มา Frankfurter API (AC-6)
                └── states/                         # วิดเจ็ตแสดง 4 สถานะ
                    ├── loading_state_widget.dart   # 15-1b
                    ├── empty_state_widget.dart     # 15-1c
                    └── error_state_widget.dart     # 15-1d (พร้อมปุ่มลองอีกครั้ง)
```

---

## 2. กฎการขึ้นตรงต่อกันของเลเยอร์ (Layer Boundary Rules)

```text
[ Presentation Layer ] ──▶ [ Domain Layer (Core) ] ◀── [ Data Layer ]
  (Widgets, Providers)       (Entities, UseCases)        (Models, Repositories, API)
```

1. **Domain Layer คือศูนย์กลาง:**
   - **ห้าม import Flutter** (ยกเว้น meta/foundation annotations)
   - ห้าม import Dio, HTTP หรือ Database libraries ใด ๆ ทั้งสิ้น
   - ทุกคลาสใน Domain ต้องเป็น Pure Dart เท่านั้น เพื่อให้รัน Unit Test ได้เร็วที่สุด
2. **Presentation Layer ขึ้นตรงกับ Domain Layer เท่านั้น:**
   - Presentation เรียกใช้ UseCases หรือ Entities ผ่าน Riverpod Provider
   - **ห้าม Presentation import Data Layer เด็ดขาด** (ห้ามเห็น Models หรือ DataSources ตรง ๆ)
3. **Data Layer แปลงข้อมูลเข้าสู่ Domain:**
   - Models ใน Data Layer ต้อง extend หรือ map เข้าหา Entity ของ Domain เสมอ
   - Data Layer เป็นผู้รับผิดชอบการจัดการ Cache และ Network Exceptions แล้วแปลงเป็น Failures

---

## 3. กฎการตั้งชื่อและการสร้างไฟล์ (File Naming Conventions)
- ชื่อไฟล์ใช้ `snake_case.dart` เสมอ
- Class ใช้ `PascalCase`
- ตัวแปรและฟังก์ชันใช้ `camelCase`
- ไฟล์ Entity: `<name>.dart` (เช่น `rate_point.dart`)
- ไฟล์ Model: `<name>_model.dart` (เช่น `rate_point_model.dart`)
- ไฟล์ UseCase: `<action>_<name>_usecase.dart`
- ไฟล์ Repository Interface: `<name>_repository.dart`
- ไฟล์ Repository Impl: `<name>_repository_impl.dart`
- ไฟล์ Test: ล้อตามโครงสร้าง `lib/` โดยต่อท้ายด้วย `_test.dart` ในโฟลเดอร์ `test/`
