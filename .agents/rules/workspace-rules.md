# Workspace Rules (กฎการทำงานร่วมกันใน Workspace)

> เอกสารนี้กำหนดข้อตกลงในการปฏิบัติงานของ AI และทีมพัฒนา เพื่อความเป็นระเบียบและโปร่งใส

---

## 1. การรับใบงานและการจัดเก็บโฟลเดอร์ (Ticket & Folder Structure)

- **โฟลเดอร์เก็บเอกสารของแต่ละใบงาน:**
  `docs/workspecs/<ISSUE-KEY>/`
  ตัวอย่าง: Issue #42 → `docs/workspecs/42/`
- **ไฟล์สถานะการดำเนินงาน:**
  `docs/workspecs/<ISSUE-KEY>/_status.md`
  ไฟล์นี้บันทึกความคืบหน้าของทุก Stage (A → B → ✋ 6 → C → Pre-review → ✋ 7 → D)
- **โฟลเดอร์เก็บรายงาน Code Review:**
  `docs/code-review/`
- **การอ้างอิงกิ่งงาน (Branch Naming):**
  - กิ่งงานฟีเจอร์: `feat/<issue-number>-<short-slug>`
  - กิ่งงานแก้ไขบั๊ก: `fix/<issue-number>-<short-slug>`
  - แยกออกจาก `main` หรือ `master` เสมอ และอัปเดตด้วย `git fetch` ก่อนเริ่ม

---

## 2. ตัวตนของผู้อนุมัติ (Approver Identity) — ตรวจสอบจาก GitHub CLI

ทุกครั้งที่มีการอนุมัติประตูมนุษย์ (✋ 6, ✋ 7, Stage D หรือ Project SDD):
1. **ดึงตัวตนจริงจาก GitHub:**
   รันคำสั่ง: `gh api user --jq '.login + " (" + (.name // "") + ")"'`
2. **รูปแบบการบันทึก:**
   `อนุมัติโดย: @<login> (<name>) เมื่อ <YYYY-MM-DD HH:MM>`
3. **ข้อห้ามเด็ดขาด:**
   - ห้าม AI กรอกชื่อเองโดยไม่ถามหรือไม่ได้ตรวจจาก `gh`
   - Subagents ทุกตัวไม่มีสิทธิ์ติ๊กเครื่องหมาย `[x] 🛑` หรือ `[x] ✋` ใน `_status.md`
   - มีเพียงผู้ใช้สั่งตรงใน Main Session เท่านั้นที่ AI Main Session จะได้รับอนุญาตให้เขียนบรรทัดนี้แทน

---

## 3. กติกาการอ่าน Project SDD แบบ 3 ทาง (3-Way SDD Reading)

เมื่อเริ่มทำงานใบงานใด ๆ Agent ต้องค้นหาและอ่านข้อกำหนดใน `docs/sdd/` ผ่าน 3 ทาง:
1. **ทางตารางงาน (Task Type):** งานประเภทนี้ (เช่น เพิ่มหน้าจอ, ทำ API ใหม่, ย้ายข้อมูล) ต้องอ่าน § ใดบ้าง
2. **ทางไฟล์ที่แตะ (Touched Paths):** โค้ดที่ต้องแก้ไขหรือสร้างใหม่ อยู่ในโฟลเดอร์ใด ต้องอ่านกฎของเลเยอร์นั้น
3. **ทางคำสำคัญ (Keywords):** เช่น `JWT`, `Cache`, `Transaction`, `Pagination`, `State Management`
> **ต้องอ่านเนื้อหาเต็มของ § นั้น ๆ ไม่ใช่อ่านแค่หัวข้อสรุป**

---

## 4. ข้อกำหนดสำหรับ Subagents (Subagent Protocol)

- **ความโดดเดี่ยว (Isolation):** แต่ละ Subagent ได้รับมอบหมายงานเฉพาะเจาะจง และส่งผลลัพธ์กลับไปยัง Orchestrator
- **ห้ามข้ามขอบเขต:**
  - `implementer` ห้ามแก้ไขไฟล์ทดสอบ (`test/`, `*.spec.*`, `*_test.*`)
  - `test-author` ห้ามแก้ไขไฟล์โค้ดแอปพลิเคชัน
  - `contract-checker` ชี้จุดผิดพลาดในสเปคเท่านั้น ห้ามแก้ไขโค้ดเพื่อเอาใจสเปค
- **ส่งต่องานเป็นเอกสาร:** การสื่อสารระหว่างขั้นใช้ไฟล์เอกสาร Markdown ใน `docs/workspecs/<ISSUE-KEY>/` เสมอ

---

## 5. การเปิด Pull Request และการควบคุมความปลอดภัย

- **เปิด PR เป็น Draft เสมอ:** เมื่อจบขั้น Stage C และ AI Pre-review ให้เปิด PR เป็น Draft ก่อน
- **ห้าม Push ทับหลังส่งมอบ:** เมื่อ PR ผ่านการตรวจสอบและถูกตั้งเป็น "Ready for review" แล้ว ห้าม AI push โค้ดเพิ่มโดยพลการ
- **การ Commit โค้ด:** ทุก Commit ต้องเขียนข้อความผ่านรูปแบบ Conventional Commits ผ่าน skill `commit-message`
- **การ Merge:** สิทธิ์การกดปุ่ม Merge และ Close Issue อยู่ที่มนุษย์บน GitHub Web หรือคำสั่งของคนเท่านั้น

---

## 6. ข้อกำหนดด้าน UI/UX, Figma และ Design Tokens (UI & Design Assets)

- **การจัดเก็บรูปภาพและ Assets ของใบงาน:**
  - ภาพดีไซน์/ภาพแคปหน้าจอ: เก็บไว้ที่ `docs/workspecs/<ISSUE-KEY>/design.png` หรือ `docs/workspecs/<ISSUE-KEY>/design/`
  - สเปคดีไซน์ที่ Main Session สรุป: เก็บไว้ที่ `docs/workspecs/<ISSUE-KEY>/design.md` (ตามมาตรฐาน [`docs/design-source.md`](../../docs/design-source.md))
  - ไฟล์ไอคอน/รูปภาพ (SVG/PNG) ที่ดาวน์โหลดผ่าน Figma MCP: เก็บไว้ในโฟลเดอร์ Asset ตามที่สถาปัตยกรรมกำหนด (เช่น `src/assets/` หรือ `public/assets/`)
- **รูปแบบตาราง Design Tokens ใน `spec-fe.md`:**
  - **Color Palette:** Token Name | Hex Code | Tailwind / CSS Var | Semantic Role
  - **Typography:** Element | Font Family | Size | Weight | Line-height
  - **Spacing & Radius:** Token Name | Value (px / rem)
  - **4 Screen States:** Data, Loading, Empty, Error
  - **Assets:** Asset Name | File Path | Type (SVG / PNG)
