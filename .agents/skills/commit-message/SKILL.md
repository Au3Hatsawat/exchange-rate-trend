---
name: commit-message
description: Generates concise, standard Conventional Commit messages with issue references based on git diff.
---

# Conventional Commit Message Generator (การสร้างข้อความ Commit มาตรฐาน)

> สกิลนี้ช่วยวิเคราะห์ `git diff` เพื่อสร้างข้อความ Commit ตามมาตรฐาน **Conventional Commits** ที่กระชับ ชัดเจน และอ้างอิง Issue อย่างถูกต้อง

---

## รูปแบบมาตรฐาน (Commit Structure)

```text
<type>(<scope>): <short description in present tense>

[optional body: why this change was made and what was affected]

Refs: #<issue-number>
```

### ประเภทของ Commit (Types)
- `feat`: เพิ่มฟีเจอร์หรือความสามารถใหม่
- `fix`: แก้ไขบั๊กหรือข้อผิดพลาด
- `test`: เพิ่มหรือปรับปรุงชุดการทดสอบ (Unit, Integration, E2E)
- `refactor`: ปรับโครงสร้างโค้ดโดยไม่เปลี่ยนพฤติกรรมการทำงานภายนอก
- `docs`: แก้ไขหรือเพิ่มเติมเอกสาร (SDD, README, Workspects)
- `chore`: งานบำรุงรักษาทั่วไป, อัปเดต Dependency, จัดการ Script

---

## กฎการเขียนข้อความ Commit (Rules)

1. **ใช้ภาษาอังกฤษสำหรับ Commit Message เสมอ**
2. **ขึ้นต้นด้วย Verb ในรูป Present Tense (Imperative Mood):** เช่น `add`, `fix`, `update`, `remove` (ไม่ใช่ `added` หรือ `adds`)
3. **ห้ามขึ้นต้นด้วยตัวพิมพ์ใหญ่และไม่ต้องลงท้ายด้วยจุด (.) ในบรรทัดแรก**
4. **ระบุหมายเลขอ้างอิง Issue เสมอ:** เช่น `(#42)` หรือท้ายบรรทัด `Refs: #42`
