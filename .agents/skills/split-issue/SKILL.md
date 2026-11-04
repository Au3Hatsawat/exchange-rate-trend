---
name: split-issue
description: Splits one large parent issue into ticket-sized issues ([FE] Develop, [BE] Develop, [Design]) with clear owners for every AC, checks for conflicts between stories, and opens them on GitHub in dependency order.
---

# Split Large Issue into Tickets (การแตกใบงานก้อนใหญ่เป็นตั๋วงานย่อย)

> **ภาษาที่ใช้:** เขียนเนื้อหา Issue, รายงาน และคำถามเป็นภาษาไทย (หรือตามที่ Project SDD กำหนด)
> สกิลนี้ใช้แยก Issue ก้อนใหญ่ (Epic, BA Story, API Spec) ออกเป็นตั๋วงานย่อยที่พร้อมพัฒนา

---

## ตำแหน่งในกระบวนการ (Place in the Process)

- ทำงานในขั้น **ก่อนเริ่ม Part 2**
- รับ Input: Issue ก้อนใหญ่ 1 ใบ (อาจรวมหลายหน้าจอ, หลายฝั่ง, หรือมีเฉพาะ API Data)
- สร้าง Output: ตั๋วงาน `[FE] Develop: ...` และ `[BE] Develop: ...` ที่เปิดขึ้นบน GitHub พร้อมเป็น Input ให้กับ **Stage A** (`workspec-writer`)

---

## ขั้นตอนการทำงาน (Steps)

### 1. อ่านข้อมูลจาก Issue ก้อนใหญ่ให้ครบถ้วน
```bash
gh issue view <url หรือ เลข issue> --json number,title,body,url,labels,comments
```
- อ่านทั้ง **Body และทุก Comment** (Comment ที่ปรับเปลี่ยนหรือเพิ่มลด Scope นับเป็นส่วนหนึ่งของ Issue)
- หากมีข้อขัดแย้งใน Comment → **หยุดถามผู้ใช้ทันที ห้ามเลือกเอง**
- **ห้ามแก้ไข Issue ต้นทาง** (ห้าม edit, ห้าม comment, ห้ามแก้ label เดิม)

### 2. ป้องกันการแตกซ้ำ (Guard Against Splitting Twice)
สร้าง Tag ป้องกัน: `split-from-<parent-number>`
ตรวจสอบว่าเคยแตกตั๋วงานไปแล้วหรือไม่:
```bash
gh issue list --label "split-from-<parent-number>" --state all --json number,title,url
```
หากพบว่าเคยแตกแล้ว ให้หยุดและถามผู้ใช้ก่อน

### 3. แยกรายการและมอบหมายเจ้าของทุกข้อ (Owner Assignment)
แตกทุก Requirement และทุก AC ออกเป็นข้อย่อย และระบุเจ้าของ:
- `FE`: งานฝั่งหน้าจอ / UI / Client
- `BE`: งานฝั่งหลังบ้าน / API / Database
- `ทีมอื่น`: งานที่ไม่เกี่ยวกับ Repo นี้ (ระบุชัดเจน แต่ไม่เปิดตั๋วใน Repo นี้)
- `ต้องถาม`: ประเด็นที่กำกวม หรือไม่แน่ชัดว่าใครรับผิดชอบ

### 4. รวมกลุ่มเป็น Story และตรวจสอบความขัดแย้ง (Conflict Check)
- **1 Story = 1 User Journey** (หน้าที่ผู้ใช้ทำเพื่อเป้าหมายหนึ่ง)
- ตั๋วงานที่ทำงานพร้อมกันได้ ต้องไม่แก้ไขไฟล์หรือโมดูลเดียวกัน
- หากแตะโมดูลเดียวกัน ให้แยก "ชิ้นส่วนส่วนกลาง (Shared Piece)" ออกมาเป็นตั๋วงานแรก และให้ Story อื่นรอ

### 5. ด่านตรวจดีไซน์ (Design Gate)
สำหรับ Story ที่มีการเพิ่มหน้าจอใหม่หรือเปลี่ยน UI Flow:
- มีดีไซน์แล้วใน Figma → เดินหน้าเปิดตั๋ว `[FE]` / `[BE]` ได้เลย
- ยังไม่มีดีไซน์ → เปิดตั๋ว `[Design] <ชื่อ Story>` นำหน้า เพื่อให้ทำงานด้านดีไซน์ให้เสร็จก่อน

### 6. จัดลำดับและการพึ่งพา (Dependency Ordering)
1. ชิ้นส่วนที่คนอื่นต้องใช้ก่อน (เช่น Shared Model, Schema)
2. ตั๋วงาน `[Design]`
3. ตั๋วงาน `[BE] Develop` และ `[FE] Develop`

### 7. เปิดตั๋วงานบน GitHub (Opening the Tickets)
สร้างตั๋วงานโดยใช้รูปแบบของ `create-task`:
```bash
# บันทึกเนื้อหาตั๋วในไฟล์ชั่วคราว
gh issue create --repo <owner/repo> \
  --title "[FE] Develop: <ชื่องาน>" \
  --body-file /tmp/issue-body.md \
  --label "split-from-<parent-number>"
```
และเชื่อมโยงความสัมพันธ์ (Blocked By / Parent Sub-issue) ให้ครบถ้วน
