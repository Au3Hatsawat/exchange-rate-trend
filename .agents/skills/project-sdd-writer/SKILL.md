---
name: project-sdd-writer
description: First-round SDD for the whole project (Part 1) — takes the Tech Lead's architecture decisions and expands them into structured Project SDD documentation in `docs/sdd/` and `AGENTS.md` for ANY tech stack, then stops for Tech Lead approval.
---

# project-sdd-writer — การสร้างมาตรฐานสถาปัตยกรรม (Part 1 SDD)

> **ภาษาที่ใช้:** เขียนไฟล์เอกสารเป็นภาษาไทย (หรือภาษาที่ Project SDD กำหนด)
> สกิลนี้ทำงานใน **Part 1 (First-round SDD)** ทำครั้งเดียวเมื่อเริ่มโปรเจกต์ใหม่ หรือเมื่อมีสถาปัตยกรรมใหม่

---

## ตำแหน่งในกระบวนการ (Place in the Process)

- **ก่อนเริ่ม:** Tech Lead ระบุข้อกำหนดสั้น ๆ เช่น ภาษา, เฟรมเวิร์ก, ฐานข้อมูล, สถาปัตยกรรม
- **หน้าที่:** ขยายข้อกำหนดให้เป็นเอกสารมาตรฐานที่ AI และคนสามารถปฏิบัติตามได้จริง
- **ผลลัพธ์:** เอกสารมาตรฐานใน `docs/sdd/` และข้อมูลใน `AGENTS.md`
- **ถัดไป:** ✋ Tech Lead ตรวจและอนุมัติ (บันทึกบรรทัด "Project SDD อนุมัติโดย...") จึงจะเริ่มพัฒนาใบงานใน Part 2 ได้

---

## 12 หัวข้อที่ Project SDD ต้องครอบคลุม (The 12 Core Topics)

เมื่อรันสกิลนี้ ให้สร้างเอกสารแยกเป็นหมวดหมู่ใน `docs/sdd/NN-<slug>.md`:

1. **ข้อมูลโปรเจกต์ (Project Info):** Repo นี้มีฝั่งใดบ้าง (FE / BE / Both), ลิงก์ Repo, Main Branch
2. **การตัดสินใจด้านเทคสแตก (Tech Stack):** ภาษา, Framework, Database, Third-party Libraries สำคัญ
3. **โครงสร้างโฟลเดอร์เต็ม (Full Folder Layout):** ระบุเลเยอร์ทั้งหมด (Clean Arch / Hexagonal), แต่ละเลเยอร์ทำอะไร, เลเยอร์ไหนเรียกเลเยอร์ไหนได้หรือไม่ได้
4. **กฎการสร้างไฟล์ใหม่แต่ละประเภท (File Conventions):** การตั้งชื่อไฟล์, การจัดวางโฟลเดอร์, คำสั่ง Generate (ถ้ามี)
5. **ชุดไฟล์ตัวอย่างเริ่มต้น (Starter Example Files):** ชี้ไปยังโค้ดตัวอย่างที่สมบูรณ์ 1 ชุดเป็นต้นแบบ
6. **รูปแบบ API และ Error Format กลาง:** โครงสร้าง JSON ของ Request/Response, Pagination, วันเวลา (Timezone), รหัส Error
7. **กฎสำหรับฝั่งหน้าจอ (Frontend Rules):** State Management, Navigation, Theme/Tokens, จัดการสถานะ Loading/Empty/Error
8. **กฎสำหรับฝั่งหลังบ้าน (Backend Rules):** Layering, Database Migration, Transaction, Auth & Authorization
9. **การทดสอบ (Testing Conventions):** ไลบรารีสำหรับ Unit Test, Integration Test, E2E Test, คำสั่งรันเทสทั้งหมด
10. **Checklist สำหรับ Code Review และข้อผิดพลาดที่พบบ่อย (Common Mistakes):** รายการตรวจคุณภาพโค้ด
11. **Definition of Done (DoD):** เกณฑ์ที่บ่งบอกว่างานเสร็จสมบูรณ์พร้อมส่งมอบ
12. **ข้อกำหนดการ Commit โค้ด (Commit Conventions):** รูปแบบ Conventional Commits ผ่าน skill `commit-message`

---

## ขั้นตอนการสร้าง (Steps)

1. **รับคำสั่งจาก Tech Lead:** หากข้อมูลข้อใดไม่ชัดเจน ให้ถามในรอบเดียว ห้ามเดาเอง
2. **สร้างไฟล์ใน `docs/sdd/`:**
   - `docs/sdd/01-tech-stack.md`
   - `docs/sdd/02-architecture-layout.md`
   - `docs/sdd/03-api-contract.md`
   - `docs/sdd/04-testing-guidelines.md`
   - `docs/sdd/05-review-and-dod.md`
3. **อัปเดต `AGENTS.md`:** ระบุข้อมูลโปรเจกต์และตารางเชื่อมโยง
4. **🛑 หยุดเพื่อรอการอนุมัติ (Stop for Tech Lead Approval):**
   สรุปผลลัพธ์และรอ Tech Lead พิมพ์รับรอง:
   `Project SDD อนุมัติโดย: @<login> (<name>) เมื่อ <YYYY-MM-DD>`
