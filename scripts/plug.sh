#!/usr/bin/env bash
# AGY SDD Plug — นำระบบ AGY SDD ไปเสียบ (Plug-in) ในโปรเจกต์เดิมที่มีอยู่แล้ว
#
# การใช้งาน:
#   ./scripts/plug.sh <path-to-target-project>
#
# ตัวอย่าง:
#   ./scripts/plug.sh ../my-existing-app
#   ./scripts/plug.sh /Users/hatsawat.i/Desktop/Dev/my-api-service
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  echo "Usage: ./scripts/plug.sh <target-project-directory>"
  echo "ตัวอย่าง:"
  echo "  ./scripts/plug.sh ../my-backend-app"
  echo "  ./scripts/plug.sh /path/to/my-frontend"
  exit 1
}

[[ $# -ge 1 ]] || usage
TARGET="$1"

# แปลงเป็น absolute path
TARGET="$(cd "$TARGET" 2>/dev/null && pwd || echo "$TARGET")"

if [[ ! -d "$TARGET" ]]; then
  echo "❌ ไม่พบโฟลเดอร์ปลายทาง: $TARGET"
  exit 1
fi

echo "=========================================================="
echo "          🚀 AGY SDD Project Plug-in Installer            "
echo "=========================================================="
echo "ต้นทาง: $FRAMEWORK_ROOT"
echo "ปลายทาง: $TARGET"
echo ""

# 1. ตรวจสอบ Git ในโปรเจกต์ปลายทาง
if [[ ! -d "$TARGET/.git" ]]; then
  echo "⚠️  ไม่พบ .git ในโปรเจกต์ปลายทาง — กำลังเริ่ม 'git init'..."
  git -C "$TARGET" init -b main
fi

# 2. คัดลอก .agents/
echo "==> คัดลอกระบบ .agents/ (Rules, Skills, Subagents)..."
mkdir -p "$TARGET/.agents"
cp -R "$FRAMEWORK_ROOT/.agents/"* "$TARGET/.agents/"

# 3. คัดลอก scripts/
echo "==> คัดลอก scripts/..."
mkdir -p "$TARGET/scripts"
cp -R "$FRAMEWORK_ROOT/scripts/"* "$TARGET/scripts/"
chmod +x "$TARGET/scripts/"*.sh 2>/dev/null || true
chmod +x "$TARGET/scripts/hooks/"*.sh 2>/dev/null || true

# 4. คัดลอก docs/ โครงสร้างและแนวทาง
echo "==> จัดเตรียม docs/ (workspecs, code-review, design-source)..."
mkdir -p "$TARGET/docs/sdd"
mkdir -p "$TARGET/docs/workspecs"
mkdir -p "$TARGET/docs/code-review"
touch "$TARGET/docs/workspecs/.gitkeep"
touch "$TARGET/docs/code-review/.gitkeep"
if [[ -f "$FRAMEWORK_ROOT/docs/design-source.md" ]]; then
  cp "$FRAMEWORK_ROOT/docs/design-source.md" "$TARGET/docs/design-source.md"
fi

# 5. คัดลอก templates/
echo "==> คัดลอก templates/..."
mkdir -p "$TARGET/templates"
cp -R "$FRAMEWORK_ROOT/templates/"* "$TARGET/templates/"

# 6. คัดลอก AGENTS.md และ GEMINI.md
if [[ ! -f "$TARGET/AGENTS.md" ]]; then
  echo "==> สร้าง AGENTS.md..."
  cp "$FRAMEWORK_ROOT/AGENTS.md" "$TARGET/AGENTS.md"
fi
if [[ ! -f "$TARGET/GEMINI.md" ]]; then
  echo "==> เชื่อมโยง GEMINI.md..."
  cp "$FRAMEWORK_ROOT/GEMINI.md" "$TARGET/GEMINI.md"
fi

# 7. ตรวจสอบสภาพแวดล้อมด้วย doctor.sh
echo ""
echo "==> กำลังรัน doctor.sh ในโปรเจกต์เป้าหมาย..."
(cd "$TARGET" && ./scripts/doctor.sh) || true

echo ""
echo "=========================================================="
echo "🎉 ติดตั้ง AGY SDD เข้าโปรเจกต์เป้าหมายเรียบร้อยแล้ว!"
echo "โฟลเดอร์: $TARGET"
echo ""
echo "ขั้นตอนถัดไปในโปรเจกต์เป้าหมาย:"
echo "1. เข้าไปยังโฟลเดอร์: cd \"$TARGET\""
echo "2. เปิดใช้งาน Antigravity CLI หรือ IDE ของคุณ"
echo "3. สั่งให้ AI ร่าง SDD สถาปัตยกรรม: 'เริ่ม Project SDD สำหรับโปรเจกต์นี้'"
echo "=========================================================="
