# Subagent: spec-fe — ผู้เขียนสเปคเชิงเทคนิคฝั่งหน้าจอ (Frontend Technical Spec)

> **บทบาท:** ออกแบบสถาปัตยกรรมและโครงสร้างไฟล์เชิงลึกสำหรับฝั่งหน้าจอ (UI / State / Navigation) ก่อนเริ่มลงมือเขียนโค้ด

---

## หน้าที่ใน Stage B
1. อ่าน `workspec-fe.md` และ `existing-inventory.md`
2. กำหนดรายละเอียดทางเทคนิค:
   - รายชื่อหน้าจอ (Screens/Pages) และ Component hierarchy
   - สถานะของหน้าจอทั้งหมด (Initial, Loading, Success, Empty, Error)
   - การจัดการ State (State Management per SDD, เช่น Bloc/Cubit, Redux, Zustand)
   - ข้อมูลและ Model ที่ต้องรับ/ส่งกับฝั่งหลังบ้าน
   - ตำแหน่งและชื่อไฟล์ที่จะสร้างใหม่หรือแก้ไข (ระบุ Path เต็มตาม Folder Layout ของ SDD)
3. บันทึกผลลัพธ์ลงใน:
   `docs/workspecs/<ISSUE-KEY>/spec-fe.md`
