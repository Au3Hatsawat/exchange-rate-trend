# §5 · เกณฑ์การส่งมอบและการตรวจโค้ด (Definition of Done & Code Review Checklist)

> เอกสารนี้กำหนดข้อตกลงร่วมกันสำหรับคำว่า "งานเสร็จสมบูรณ์" (Definition of Done) และเกณฑ์การทำ Code Review ที่ ✋ Gate 7

---

## 1. นิยามความเสร็จสมบูรณ์ของใบงาน (Definition of Done - DoD)

ใบงานแต่ละใบจะถือว่าเสร็จสมบูรณ์พร้อม Merge เข้าสู่กิ่ง `main` ได้ ก็ต่อเมื่อผ่านเกณฑ์ทั้งหมดดังนี้:

1. **ครอบคลุม AC 100% (Acceptance Criteria Complete):**
   - ทุกข้อใน Acceptance Criteria ที่ระบุไว้ในใบงาน ต้องได้รับการ Implement และมี Automated Test ควบคุมครบถ้วน
2. **ชุดการทดสอบผ่าน 100% (Green Test Suite):**
   - คำสั่ง `fvm flutter test` ต้องรันผ่านทุกเคส (0 Failures, 0 Errors)
3. **คุณภาพโค้ดและ Linter ผ่านมาตรฐาน (Zero Warnings):**
   - รันคำสั่ง `fvm flutter analyze` ต้องได้ผลลัพธ์: `No issues found!`
   - โค้ดผ่านการจัดรูปแบบด้วย `dart format .`
4. **ตรงตามสเปคดีไซน์และ Design Tokens:**
   - ใช้ค่าสีจาก `AppColors` และฟอนต์ `IBM Plex Sans Thai` ตามที่กำหนดใน `docs/workspecs/1/design.md`
   - **ห้ามมี Hardcoded Colors** (เช่น ห้ามใช้ `Color(0xFF...)` ใน Widget ตรง ๆ)
   - ครบทั้ง 4 สถานะ: Loading, Empty, Error, และ Success
5. **ผ่านด่าน AI Pre-review:**
   - รันสกิล `code-review` ในโหมด `pre-review` จนไม่เหลือรายการในกลุ่ม "AI แก้ได้เลย"
6. **ผ่านการตรวจอนุมัติจากมนุษย์ (✋ Gate 7):**
   - Reviewer / Tech Lead ตรวจสอบโค้ดบน Draft PR และกดยืนยันอนุมัติ
7. **ผ่านการทดสอบ Stage D (QA ทั้ง 2 กอง):**
   - กอง Agent 🤖: ยืนยันผลการรันเทสอัตโนมัติ
   - กองมนุษย์ 🙋: ทดสอบมือจริงบน Simulator / เครื่องจริง

---

## 2. รายการตรวจ Code Review 6 มิติ (Review Checklist)

| มิติการตรวจ | รายละเอียดที่ต้องตรวจสอบ | เกณฑ์การผ่าน |
|---|---|---|
| **1. Architecture & Layers** | Presentation ไม่เรียก Data ตรง ๆ, Domain ไม่มี dependency ภายนอก | ไม่ละเมิด Clean Architecture |
| **2. Spec & AC Matching** | คำนวณ % ตรงตาม BR-3, แคชตรงตาม BR-2, แสดงครบ 4 สถานะ | ฟังก์ชันทำงานตรงสเปค 100% |
| **3. Error Handling** | จัดการกรณีเน็ตหลุด, HTTP 422, Timeout ไม่เกิด Red Screen of Death | มี Error State พร้อมปุ่ม Retry |
| **4. UI & Design Tokens** | ใช้สี, ฟอนต์, สัดส่วน และ Radius ตรงตาม `design.md` | Pixel & Token Accuracy |
| **5. Memory & Performance** | มีการ dispose controllers, ไม่สร้าง Provider ซ้ำซ้อน, ใช้ const constructor | ไม่มี Memory Leak |
| **6. Test Quality** | เทสครอบคลุม Edge Cases (เช่น response ว่าง `[]`, วันที่ไม่มีข้อมูล) | เทสมีความหมาย ไม่ใช่เทสหลอก |

---

## 3. มาตรฐานการ Commit โค้ด (Conventional Commits)

ทุก Commit ในกิ่งงานต้องเขียนตามรูปแบบ Conventional Commits ผ่านสกิล `commit-message`:
```text
<type>(<scope>): <short summary> (#<issue-number>)

[optional body]
```

### Types ที่อนุญาต:
- `feat`: เพิ่มฟีเจอร์ใหม่
- `fix`: แก้ไขบั๊ก
- `test`: เพิ่มหรือปรับปรุงเทส (ห้ามมีโค้ดแอป)
- `refactor`: ปรับโครงสร้างโค้ดโดยไม่เปลี่ยนพฤติกรรม
- `chore`: งานตั้งค่า, dependency, ไฟล์เอกสาร
- `docs`: แก้ไขเอกสาร SDD หรือ Workspects
