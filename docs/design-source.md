# Design from Design Tools (การอ่านสเปคดีไซน์จาก Figma และ ภาพแคปจอ)

> **อ่านเอกสารนี้ทุกครั้งก่อนอ่านดีไซน์จากใบงาน**
> อ้างอิงสถาปัตยกรรมกระบวนการ: [`.agents/rules/process.md`](../.agents/rules/process.md) และ [`.agents/rules/workspace-rules.md`](../.agents/rules/workspace-rules.md)

---

## 1. แหล่งดีไซน์ที่รองรับ (Supported Design Sources)

| แหล่งข้อมูล | รูปแบบข้อมูลในใบงาน | วิธีการอ่าน | เครื่องมือที่ใช้ |
|---|---|---|---|
| **Figma (ผ่าน MCP)** | ลิงก์ `figma.com/design/...` หรือ `figma.com/file/...` ที่มี `node-id` | สกัดข้อมูล Node, Layout, Components และค่า Variables | `Framelink MCP for Figma` (`get_figma_data`, `download_figma_images`) |
| **ภาพแคปจอ (Screenshots)** | รูปภาพวางใน `docs/workspecs/<ISSUE-KEY>/design.png` หรือใน `assets/` | สแกน Layout, Hierarchy, องค์ประกอบจอ และสีด้วย Multimodal Vision | AI Multimodal Vision (Gemini 3.8 / Pro) |
| **เอกสาร / ข้อความ** | ข้อความใน Issue Body / Comment ตามแม่แบบ `templates/design-issue.md` | อ่านข้อกำหนดตรง ๆ | AI Text Reader |

---

## 2. กฎเหล็ก: AI Session หลักเป็นผู้อ่านดีไซน์เพียงครั้งเดียว (Main Session Reads Once)

> **สำคัญมาก:** ห้ามให้ Subagent ไปยิงเรียก Figma MCP ซ้ำหลายรอบ
> 1. AI ใน Main Session จะเป็นผู้อ่านข้อมูลจาก Figma MCP หรือสแกนภาพแคปจอ **ก่อนส่งงานเข้า `dev-orchestrator`**
> 2. สรุปผลลัพธ์เป็นไฟล์ **`docs/workspecs/<ISSUE-KEY>/design.md`** และบันทึกภาพลง `docs/workspecs/<ISSUE-KEY>/design/`
> 3. Subagents ทุกตัว (`workspec-writer`, `spec-fe`, `contract-checker`) จะอ่านสเปคจาก `design.md` นี้เท่านั้น!

**ประโยชน์:**
- ไม่เปลืองโควต้า Figma API (Free/View seat มีโควต้าจำกัด)
- Subagents สามารถทำงานในโหมด Sandboxed โดยไม่ต้องพึ่งพา MCP Tool
- มีเอกสารสเปคดีไซน์ที่แน่นอนและสามารถตรวจสอบย้อนหลังได้ (Single Source of Truth)

---

## 3. สัญญาส่งมอบดีไซน์ (Design Handoff Contract)

สเปคใน `design.md` ต้องระบุให้ครบ 4 ด้าน:

1. **4 สถานะของหน้าจอ (4 Screen States):**
   - **Loading:** แสดง Shimmer หรือ Spinner อย่างไร
   - **Empty:** หน้าจอว่างเมื่อยังไม่มีข้อมูล
   - **Error:** หน้าจอเมื่อโหลดข้อมูลผิดพลาด หรือสัญญาณหลุด
   - **Data:** หน้าจอแสดงผลปกติที่มีข้อมูลครบถ้วน
2. **Design Tokens ตามบทบาท (Semantic Tokens):**
   - **สี (Colors):** ต้องระบุชื่อตามหน้าที่ เช่น `bg/primary`, `text/header`, `button/brand` พร้อมรหัส Hex
   - หากค่าใดไม่ได้ผูก Token ใน Figma ให้ระบุว่า `(ค่าดิบ ไม่มีชื่อ token)` เพื่อให้ Tech Lead ตรวจที่ Gate 6
3. **Typography & Spacing:**
   - Font Family, ขนาด (px/rem), น้ำหนัก (Font Weight), Line-height
   - ระยะห่าง Padding, Gap และ Border Radius
4. **สิ่งที่ไม่มีในดีไซน์:**
   - ระบุว่า `ยังไม่กำหนด` ห้าม AI เดาค่าเองเด็ดขาด

---

## 4. โครงสร้างไฟล์ `design.md` มาตรฐาน

เมื่อ Main Session อ่านดีไซน์แล้ว ให้บันทึกที่ `docs/workspecs/<ISSUE-KEY>/design.md` ดังนี้:

```markdown
# Design Specification: Issue #<n>

- **แหล่งที่มา:** [Figma URL หรือ Screenshot path]
- **อ่านเมื่อ:** [YYYY-MM-DD HH:MM] โดย @[login]
- **ขนาดหน้าจอที่ออกแบบ:** Mobile [390px] / Tablet / Desktop
- **สถานะ:** [สมบูรณ์ / มีจุดรอ Tech Lead ตัดสิน]

---

## 1. Design Tokens

### Color Palette
| Token Name | Hex Code | Tailwind / CSS Var | หน้าที่ (Semantic Role) |
|---|---|---|---|
| `color.brand.primary` | `#0066FF` | `primary-600` | ปุ่มหลัก, Header |
| `color.bg.surface` | `#FFFFFF` | `white` | พื้นหลังการ์ด |
| `color.text.muted` | `#64748B` | `slate-500` | คำอธิบายรอง |

### Typography
| Element | Font Family | Size | Weight | Line Height |
|---|---|---|---|---|
| Screen Title | Inter / Prompt | 24px | Bold (700) | 32px |
| Body Text | Inter / Prompt | 16px | Regular (400) | 24px |

### Spacing & Radius
- **Padding หน้าจอ:** 16px (Horizontal)
- **Gap ระหว่างการ์ด:** 12px
- **Border Radius:** 8px (`rounded-lg`)

---

## 2. หน้าจอและ 4 สถานะ (Screens & States)

- [ ] **Data State:** แสดงรายการพร้อมปุ่มกด Action
- [ ] **Loading State:** แสดง Skeleton Placeholder
- [ ] **Empty State:** ภาพ Illustration + ข้อความ "ยังไม่มีข้อมูล" + ปุ่มเริ่มสร้าง
- [ ] **Error State:** ข้อความแจ้งเตือน + ปุ่ม "ลองใหม่อีกครั้ง" (Retry)

---

## 3. Assets & Icons

- [x] `icon-arrow-left.svg` → ดาวน์โหลดไว้ที่ `assets/icons/arrow-left.svg`
- [x] `img-hero.png` → ดาวน์โหลดไว้ที่ `assets/images/hero.png`

---

## 4. ประเด็นที่ยังไม่กำหนด / ต้องถาม (Undecided Items)
- `(ค่าดิบ)` สีพื้นหลังปุ่มรองใน Figma ใช้ `#F1F5F9` โดยไม่มีชื่อ Token
- ไม่มีดีไซน์สำหรับหน้าจอเมื่อเน็ตหลุด (Network Timeout)
```
