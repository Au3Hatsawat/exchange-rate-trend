---
name: create-task
description: Writes structured task details as User Story + Functional Requirements + Acceptance Criteria (Given/When/Then) from a task name and rough description. Can create the card directly on GitHub using `gh issue create`.
---

# Task & GitHub Issue Card Generator (การสร้างการ์ดงานและ Issue บน GitHub)

> **ภาษาที่ใช้:** เขียนการ์ดงาน, รายงาน, และคำถามเป็นภาษาไทย (หรือภาษาที่ Project SDD กำหนด)
> สกิลนี้ทำหน้าที่เป็น Product Owner / Business Analyst (PO/BA) ผู้เชี่ยวชาญการเขียน User Story และ Acceptance Criteria

---

## ตำแหน่งในกระบวนการ (Place in the Process)

สกิลนี้ทำงานในขั้นตอน **ก่อนเริ่ม Part 2** เพื่อสร้างการ์ดงานหรือ Issue บน GitHub
- ผลลัพธ์ที่เป็น **Main Story** หรือ **Action Task (`[FE] Develop` / `[BE] Develop`)** จะกลายเป็น Input สำคัญสำหรับ **Stage A** (`workspec-writer`)
- เกณฑ์การยอมรับ (AC) ที่สร้างจากสกิลนี้ จะถูกนำไปแปลงเป็นเคสทดสอบ (TDD) ใน Stages B และ C โดยตรง

---

## ข้อมูลที่รับเข้ามา (Input)

ผู้ใช้จะระบุ:
- **ชื่อ Task:** เช่น `ระบบล็อกอินด้วยเบอร์โทรศัพท์และ OTP`, `หน้าแสดงประวัติการสั่งซื้อ`
- **รายละเอียดคร่าว ๆ:** ความต้องการ หรือ Flow การทำงานคร่าว ๆ
- **(ทางเลือก) ธง `--github`:** หากต้องการให้เปิดขึ้น GitHub Issue โดยตรงทันที

---

## ขั้นตอนการทำงาน (What to do)

### 1. ถามคำถามเริ่มต้น 2 ข้อก่อนเขียนเสมอ (Starting Questions)
ห้ามเดาคำตอบเองเด็ดขาด ถามผู้ใช้ดังนี้:

> **คำถามที่ 1:** "Task นี้เป็น task ย่อยที่อ้างอิงจาก Story หลักของ BA หรือไม่?"
> - **ใช่ (Action Task):** มีการอ้างอิงใบใหญ่ ต้องระบุ Story ต้นทาง → ไปคำถามที่ 2
> - **ไม่ใช่ (Main Story):** เป็นฟีเจอร์หลักใหม่ → ไม่ต้องถามข้อ 2

> **คำถามที่ 2 (กรณีเป็น Task ย่อย):** "Story หลักคือ Issue เลขอะไร หรือลิงก์อะไรบน GitHub?"
> - ดึงข้อมูลด้วย `gh issue view <เลขหรือลิงก์> --json number,title,body,url` เพื่อนำมาอ้างอิง

### 2. ร่างเนื้อหาการ์ดงาน (Drafting the Card)
เขียนตามโครงสร้างมาตรฐานที่ระบุไว้ในหัวข้อ "รูปแบบการ์ดงาน (Card Template)"

### 3. กฎเหล็กในการเขียนการ์ดงาน (Hard Rules)
- **ห้ามใส่โค้ดเด็ดขาด:** ห้ามใส่ Code snippets, ชื่อฟังก์ชัน, ชื่อคลาส, ชื่อไลบรารี หรือคำสั่งทางเทคนิคที่ชี้นำวิธีการเขียนโค้ด
- การ์ดงานต้องอธิบายเฉพาะ **"สิ่งที่ระบบต้องทำได้ / สิ่งที่ผู้ใช้ต้องได้รับ" (WHAT)** และปล่อยให้ Developer / AI เป็นผู้ออกแบบ **"วิธีการเขียนโค้ด" (HOW)** ในขั้นตอน SDD เอง
- **Acceptance Criteria (AC):** ต้องเขียนเป็นรูปแบบ Given / When / Then ชัดเจน ห้ามใช้คำกำกวม เช่น "แสดงผลถูกต้อง"

### 4. การเปิด Issue บน GitHub (GitHub Publishing)
ถามผู้ใช้ว่าต้องการเปิด Issue บน GitHub เลยหรือไม่:
```bash
gh issue create --repo <owner/repo> \
  --title "[FE|BE] <ชื่อฟีเจอร์>" \
  --body-file <path_to_draft.md> \
  --label "story"
```

---

## รูปแบบการ์ดงาน (Card Template)

```markdown
## User Story

> อ้างอิงจาก: #[issue number] — [ชื่อ Story ต้นทาง] (หากมี)

> **ในฐานะ:** [ประเภทผู้ใช้ เช่น ลูกค้าทั่วไป, แอดมินร้านค้า]
> **ฉันต้องการ:** [สิ่งที่ต้องการทำในระบบ]
> **เพื่อที่จะ:** [คุณค่าหรือประโยชน์ที่ได้รับ]

---

## Functional Requirements (ข้อกำหนดการทำงาน)

- [ ] ระบบต้องสามารถ...
- [ ] เมื่อผู้ใช้กดปุ่ม... ระบบจะทำการ...
- [ ] มีการตรวจสอบความถูกต้องของข้อมูล (Validation)...

---

## Acceptance Criteria (เกณฑ์การยอมรับ)

- [ ] **AC-01: [ชื่อกรณีทดสอบ เช่น ส่ง OTP สำเร็จ]**
  - **Given:** [สถานการณ์เริ่มต้น]
  - **When:** [การกระทำของผู้ใช้หรือระบบ]
  - **Then:** [ผลลัพธ์ที่คาดหวัง]

- [ ] **AC-02: [ชื่อกรณีทดสอบ เช่น เบอร์โทรไม่ถูกต้อง]**
  - **Given:** [สถานการณ์เริ่มต้น]
  - **When:** [การกระทำ]
  - **Then:** [ผลลัพธ์ที่คาดหวัง]

---

## UI / UX Reference (แหล่งอ้างอิงดีไซน์)

- **Figma / Wireframe:** [วางลิงก์ Figma ที่นี่]()
- **Design Tokens / Flow:** [คำอธิบายเพิ่มเติม]()
```
