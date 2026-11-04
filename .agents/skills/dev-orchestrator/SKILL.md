---
name: dev-orchestrator
description: Master orchestrator for 1 ticket (Part 2), driving stages A -> B -> ✋6 -> C -> ⋈2 -> AI Pre-review -> ✋7 -> D. Dispatches subagents, merges results, and strictly enforces human gates.
---

# dev-orchestrator — ผู้ขับเคลื่อนกระบวนการพัฒนาใบงาน (Part 2)

> **ภาษาที่ใช้:** เขียนรายงาน, สรุป และไฟล์เอกสารเป็นภาษาไทย (หรือตามที่ Project SDD กำหนด)
> สกิลนี้ทำหน้าที่เป็น Orchestrator ดูแลการพัฒนาทีละ 1 ใบงานตั้งแต่เริ่มต้นจนพร้อม Merge

---

## กฎเหล็กของ dev-orchestrator (Hard Rules)

1. **ทำทีละ 1 ขั้นตอนแล้วหยุดรายงานเสมอ (One stage at a time):**
   เมื่อจบแต่ละ Stage ต้องหยุดรายงานความคืบหน้าให้มนุษย์ทราบ และรอคำสั่ง "ไปต่อ" จึงจะเริ่มขั้นถัดไป ห้ามไหลข้ามขั้นเองเด็ดขาด
2. **ไม่เขียนโค้ดหรือสเปคเอง (Do not write code or specs directly):**
   หน้าที่ของ Orchestrator คือแจกจ่ายงานให้ Subagents, รวมผลลัพธ์, และควบคุมลำดับขั้นตอน
3. **ประตูมนุษย์เป็นของคนเท่านั้น (✋ Gates belong to humans):**
   ห้าม AI ติ๊กเครื่องหมาย `[x] 🛑` หรือเขียนบรรทัดอนุมัติเองโดยไม่ได้รับคำสั่งตรงจากผู้ใช้ใน Main Session
4. **ตรวจสอบสถานะปัจจุบันได้เอง (Self-stage inference):**
   เมื่อผู้ใช้สั่ง "ไปต่อ" หรือสั่งให้ทำใบงาน Orchestrator จะตรวจสอบไฟล์จริงใน `docs/workspecs/<ISSUE-KEY>/` เพื่อประเมินว่าอยู่ในขั้นใดทันที

---

## ตารางประเมินขั้นตอนปัจจุบัน (Stage Inference Table)

| ไฟล์ที่พบบนดิสก์ | หมายความว่า | ขั้นตอนถัดไปที่จะรัน |
|---|---|---|
| ยังไม่มีโฟลเดอร์ใบงาน หรือไม่มี workspec | ยังไม่เริ่ม | **Stage A:** เรียก `workspec-writer` |
| มี `workspec-fe.md` และ `workspec-be.md` แล้ว | Stage A เสร็จสิ้น | **Stage B:** เรียก `codebase-scout`, `spec-fe`, `spec-be` |
| มีสเปคสองฝั่งแล้ว แต่ยังไม่มี `contract-report.md` | ยังไม่ได้เทียบสัญญา | **Meeting Point 1:** เรียก `contract-checker` |
| `contract-report.md` ยังติด ❌ | สัญญาสองฝั่งไม่ตรงกัน | ส่งกลับให้ `spec-fe` / `spec-be` แก้ไข |
| `contract-report.md` ผ่าน ✅ แต่ยังไม่มี `testplan.md` | สัญญาตรงกันแล้ว | เรียก `test-author` ทำแผนเคสทดสอบ |
| มี `testplan.md` แล้ว แต่ยังไม่มี `spec.md` | แผนเทสพร้อมแล้ว | รวมเนื้อหาทั้งหมดเป็น `spec.md` |
| มี `spec.md` แล้ว และยังไม่มีการติ๊ก ✋ 6 | สเปคพร้อมตรวจ | **🛑 หยุดรอ ✋ Gate 6 (Tech Lead อนุมัติสเปค)** |
| ✋ 6 อนุมัติแล้ว แต่โค้ด/เทสยังไม่เสร็จ | สเปคผ่านแล้ว | **Stage C:** TDD Loop (`test-author` → `implementer`) |
| เทสทุกตัวผ่านหมดแล้ว แต่ยังไม่มีรายงาน Pre-review | TDD ผ่านแล้ว | **🤖 AI Pre-review:** เรียก `code-review` (โหมด pre-review) |
| AI Pre-review จบแล้ว แต่ยังไม่มีการติ๊ก ✋ 7 | โค้ดพร้อมตรวจ | **🛑 หยุดรอ ✋ Gate 7 (Reviewer ตรวจโค้ดบน PR)** |
| ✋ 7 อนุมัติแล้ว | โค้ดผ่านการตรวจแล้ว | **Stage D:** QA (กอง Agent 🤖 + กองมนุษย์ 🙋) |
| กองมนุษย์ 🙋 ได้รับการยืนยันแล้ว | QA ผ่านสมบูรณ์ | **จบงาน:** ตั้ง PR เป็น Ready for review แจ้งคนกด Merge |

---

## ขั้นตอนการสั่งงาน Subagents ในแต่ละ Stage

### การเตรียมก่อนเริ่ม (Design Input)
- ตรวจสอบว่าใน `docs/workspecs/<ISSUE-KEY>/` มีไฟล์ `design.md` หรือไม่
- หากใบงานมีลิงก์ Figma หรือภาพแคปจอ แต่ยังไม่มี `design.md` ให้ Main Session สร้างขึ้นตามข้อกำหนดใน `docs/design-source.md` ก่อน

### Stage A: แตกใบงาน
- เรียกใช้งาน subagent `workspec-writer`
- ตรวจสอบว่าทุก FR และทุก AC มีผู้รับผิดชอบ (`FE`, `BE`, หรือ `FE+BE`)

### Stage B: ทำสเปคให้เสร็จก่อนเขียนโค้ด
- สั่ง `codebase-scout`, `spec-fe`, `spec-be` ทำงานร่วมกัน
- สำหรับ `spec-fe`: ให้อ่านข้อมูลหน้าจอและ Design Tokens จาก `design.md` (Colors, Typography, Spacing, 4 Screen States, Assets) มาบันทึกใน `spec-fe.md`
- เรียก `contract-checker` ตรวจความเข้ากันได้ 7 มิติ (ชื่อฟิลด์, data type, nullability, error, etc.)
- เรียก `test-author` สร้าง `testplan.md` แบ่งเคสเป็น 🤖 Automated / 👁️ Review (รวมการตรวจเทียบ UI กับ Design Tokens) / 🙋 Manual QA
- รวมไฟล์เป็น `spec.md` และหยุดรอ **✋ Gate 6**

### Stage C: TDD Loop
- ตรวจสอบว่า ✋ 6 ได้รับการอนุมัติแล้ว
- สำหรับแต่ละ AC:
  1. `test-author` เขียน Unit/Integration Test ที่ล้มเหลว (Red)
  2. `implementer` เขียนโค้ดเฉพาะส่วนที่จำเป็นเพื่อให้เทสผ่าน (Green) โดยฝั่ง Frontend นำค่าสีและฟอนต์จาก `spec-fe.md` ไปใช้โดยตรง
  3. `implementer` ปรับแต่งโค้ด (Refactor)
- `test-reviewer` ตรวจความครอบคลุมของเทสต่อทุก AC

### AI Pre-review
- รัน skill `code-review` ในโหมด `pre-review`
- ส่งสิ่งที่ "AI แก้ได้เลย" ให้ `implementer` จัดการ
- ส่งสิ่งที่ "ต้องมีเทสก่อน" ให้ `test-author` เขียนเทสแล้วให้ `implementer` แก้
- วนลูปไม่เกิน 3 รอบ แล้วสรุปรายงานเฉพาะสิ่งที่ "ต้องให้คนตัดสิน" ไว้ที่ **✋ Gate 7**

### Stage D: QA
- กอง Agent 🤖: รันเทสทั้งหมดและรายงานผล
- กองมนุษย์ 🙋: เตรียม Checklist ให้คนทดสอบมือจริง
- เมื่อผ่านทั้งสองกอง → สรุปผลพร้อมส่งมอบ PR

---

## รูปแบบการหยุดรายงาน (Stopping Format)
ทุกครั้งที่จบ Stage หรือหยุดรอคน ให้ขึ้นต้นด้วย:
> **👉 สิ่งที่คุณต้องทำตอนนี้:** [คำสั่งเดียว เช่น "พิมพ์ว่า ไปต่อ", "ตรวจสเปคและอนุมัติ Gate 6"]
