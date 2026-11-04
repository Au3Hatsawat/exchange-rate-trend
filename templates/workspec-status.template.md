# สถานะใบงาน: #[ISSUE-KEY] — <ชื่อใบงาน>

- **กิ่งงาน (Branch):** `feat/<ISSUE-KEY>-<slug>`
- **ฐานงาน (Base Commit):** `<commit sha>`
- **ผู้รับผิดชอบ (Owner):** `@<github-login>`

---

## ความคืบหน้าของขั้นตอน (Pipeline Progress)

- [ ] **Stage A:** แตกใบงานเป็น Workspec (`workspec-fe.md`, `workspec-be.md`)
- [ ] **Stage B:** จัดทำสเปคเชิงเทคนิคและแผนการทดสอบ
  - [ ] `codebase-scout` (สำรวจโค้ดเดิม)
  - [ ] `spec-fe.md` (สเปคหน้าจอ)
  - [ ] `spec-be.md` (สเปค API และข้อมูล)
  - [ ] `contract-checker` (จุดบรรจบ 1 — ตรวจสัญญา 7 มิติ)
  - [ ] `testplan.md` (แผนเคสทดสอบ 🤖/👁️/🙋)
  - [ ] `spec.md` (รวมสเปคฉบับสมบูรณ์)
- [ ] 🛑 **✋ Gate 6 (อนุมัติสเปค):**
  - อนุมัติโดย: `@<login>` เมื่อ `<date>`
- [ ] **Stage C:** การพัฒนาตามแนวทาง TDD
  - [ ] เขียน Automated Test ให้พังก่อน (`test-author`)
  - [ ] เขียนโค้ดแอปให้เทสผ่าน (`implementer`)
  - [ ] ปรับโครงสร้างโค้ด Refactor (`implementer`)
  - [ ] ตรวจสอบ Coverage และ AC (`test-reviewer`)
- [ ] **จุดบรรจบ 2:** รวมโค้ดสองฝั่งและรัน End-to-End Tests
- [ ] **🤖 AI Pre-review:** ตรวจและแก้ไขข้อบกพร่องอัตโนมัติ (ไม่เกิน 3 รอบ)
  - รอบ 1: แก้ไขแล้ว / คงเหลือ
- [ ] 🛑 **✋ Gate 7 (อนุมัติโค้ด):**
  - ตรวจทานบน PR: `<pr url>`
  - อนุมัติโดย: `@<login>` เมื่อ `<date>`
- [ ] **Stage D:** การตรวจรับ QA (2 กอง)
  - [ ] กอง Agent 🤖: ชุดเทสอัตโนมัติผ่าน 100%
  - [ ] 🛑 **กองมนุษย์ 🙋:** ยืนยันผลการทดสอบมือ (Hardware/Manual UX)
    - ผู้ทดสอบ: `@<login>` เมื่อ `<date>`
- [ ] **ส่งมอบ:** Mark Ready for review บน GitHub PR
