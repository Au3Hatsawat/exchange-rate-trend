---
name: assign-issues
description: Assigns open unassigned tickets ([FE], [BE], [Design]) to team members based on story continuity, area of responsibility, and capacity.
---

# Issue Assignment (การมอบหมายใบงานให้คนในทีม)

> สกิลนี้ใช้จัดสรรและมอบหมายใบงานที่เปิดอยู่บน GitHub ให้กับสมาชิกในทีม โดยยึดหลักความต่อเนื่องของบริบทงาน (Context Continuity)

---

## กฎการมอบหมายงาน (Assignment Rules)

1. **มอบหมายงานทั้ง Story ให้คนเดิม:** ใบงานที่เป็นเรื่องเดียวกันหรือต่อเนื่องกัน ควรอยู่กับผู้รับผิดชอบคนเดียวกัน เพื่อไม่ต้องส่งต่อบริบท
2. **ชิ้นส่วนส่วนกลาง (Shared Piece):** มอบหมายให้ Senior หรือผู้ที่มีความคุ้นเคยกับโมดูลแกนหลัก
3. **ตรวจสอบผู้รับผิดชอบผ่าน `gh`:**
   ```bash
   gh issue list --state open --json number,title,assignees
   ```
4. **บันทึกผู้รับผิดชอบบน GitHub:**
   ```bash
   gh issue edit <number> --add-assignee <github-login>
   ```
