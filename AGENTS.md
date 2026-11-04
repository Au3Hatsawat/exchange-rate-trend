# AGENTS.md — สำหรับ AI Assistant ทุกตัวใน Antigravity (AGY)

> โปรเจกต์นี้ใช้กระบวนการ **Software Development Discipline (SDD) ร่วมกับ AI Automation**
> โครงสร้างนี้ใช้ได้กับทุกภาษาและทุกเทคสแตก (Frontend, Backend, Mobile, Fullstack Monorepo)

---

## 1. ลำดับการอ่านเอกสารก่อนตอบหรือทำงาน (Read Order)

ก่อนเริ่มทำงานทุกครั้ง AI ต้องอ่านเอกสารตามลำดับดังนี้:
1. **ไฟล์นี้ (`AGENTS.md`):** สรุปภาพรวมและข้อมูลโปรเจกต์
2. **[`.agents/rules/workspace-rules.md`](.agents/rules/workspace-rules.md):** กฎการทำงานร่วมกัน, การตั้งโฟลเดอร์, การยืนยันตัวตนผู้อนุมัติ
3. **[`.agents/rules/process.md`](.agents/rules/process.md):** ลำดับขั้นตอนทั้งหมด (Part 1 SDD + Part 2 Stages A → D)
4. **หมวดหมู่ใน `docs/sdd/` ที่เกี่ยวข้องกับงาน:** อ่านกฎเฉพาะเลเยอร์และสถาปัตยกรรมของโปรเจกต์นี้

---

## 2. ข้อมูลโปรเจกต์นี้ (Project Context)

> ค่าเหล่านี้ถูกปรับแต่งตามแต่ละโปรเจกต์ (ตั้งค่าตอนเริ่มโปรเจกต์ด้วย `project-sdd-writer`)

- **Repository:** `Au3Hatsawat/exchange-rate-trend`
- **Main Branch:** `main`
- **เทคสแตกหลัก:** `Flutter (Clean Architecture + Riverpod / BLoC)`
- **ที่เก็บเอกสารของใบงาน:** `docs/workspecs/<ISSUE-KEY>/`
- **ที่เก็บรายงาน Code Review:** `docs/code-review/`

---

## 3. ทักษะและคำสั่งที่พร้อมใช้งาน (Skills & Slash Commands)

| คำสั่ง / ทักษะ | หน้าที่ | วิธีเรียกใช้ |
|---|---|---|
| `/create-task` | สร้างการ์ดงาน User Story + FR + AC และเปิดบน GitHub | `/create-task <ชื่อฟีเจอร์และรายละเอียด>` |
| `/split-issue` | แตก Issue ก้อนใหญ่เป็นใบงานย่อย `[FE]` / `[BE]` | `/split-issue <URL ของ issue บน GitHub>` |
| `/assign-issues`| มอบหมายใบงานที่เปิดอยู่ให้คนในทีม | `/assign-issues` |
| `project-sdd-writer` | ร่างมาตรฐานสถาปัตยกรรม Part 1 (First-round SDD) | "เริ่ม Project SDD สำหรับโปรเจกต์นี้" |
| `dev-orchestrator` | ขับเคลื่อนใบงานใน Part 2 (Stages A → D) | "ทำใบงาน #<เลข> ด้วย dev-orchestrator" หรือ "ไปต่อ" |
| `/code-review` | ตรวจสอบคุณภาพโค้ด (โหมด pre-review หรือ review) | `/code-review` |
| `/commit-message` | สร้าง Conventional Commit Message ที่ถูกต้อง | `/commit-message` |

---

## 4. ประตูมนุษย์ (Human Gates ✋)

- **✋ Gate 6 (Spec Approval):** Tech Lead ตรวจและอนุมัติสเปค + แผนเทสก่อนลงมือเขียนโค้ด
- **✋ Gate 7 (Code Review Approval):** Reviewer ตรวจและอนุมัติโค้ดบน PR
- **✋ Stage D (Human Pile):** Tester ทดสอบระบบมือในส่วนที่ไม่สามารถรันอัตโนมัติได้
- **กฎเหล็ก:** AI ห้ามติ๊กเครื่องหมาย `[x] 🛑` หรือ `[x] ✋` เองโดยเด็ดขาด การอนุมัติต้องมาจากผู้ใช้ที่เป็นมนุษย์

---

## 5. การอ้างอิงเอกสาร (SDD Reference)

ทุกคำตอบที่มีการเขียน, แก้ไข, หรือรีวิวโค้ด จะต้องลงท้ายด้วย:
`อ้างอิง SDD: §<เลขหรือหัวข้อ>` พร้อมระบุลิงก์ไปยังไฟล์ข้อกำหนดที่เกี่ยวข้อง
