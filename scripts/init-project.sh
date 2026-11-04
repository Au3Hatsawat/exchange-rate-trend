#!/usr/bin/env bash
# AGY SDD Initializer — นำระบบ AGY SDD Workflow ไปติดตั้งหรือเริ่มต้นใช้งานกับโปรเจกต์ใดก็ได้
#
# การใช้งาน:
#   1. ติดตั้งในโปรเจกต์ปัจจุบัน:
#      ./scripts/init-project.sh .
#
#   2. ติดตั้งในโปรเจกต์เป้าหมาย (Existing Repository):
#      ./scripts/init-project.sh /path/to/other-project
#
#   3. ตั้งค่า GitHub Repository เริ่มต้น:
#      ./scripts/init-project.sh . --github owner/repo
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

usage() {
  echo "Usage: ./scripts/init-project.sh <target-dir> [--github owner/repo]"
  echo "ตัวอย่าง:"
  echo "  ./scripts/init-project.sh ."
  echo "  ./scripts/init-project.sh /Users/dev/my-new-app"
  echo "  ./scripts/init-project.sh . --github my-org/my-app"
  exit 1
}

[[ $# -ge 1 ]] || usage
TARGET_DIR="$1"
shift || true

GITHUB_REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --github)
      GITHUB_REPO="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "==> กำลังตั้งค่า AGY SDD Workflow ไปยัง: $TARGET_DIR"

# 1. ตรวจสอบ Git
if [[ ! -d "$TARGET_DIR/.git" ]]; then
  echo "==> ไม่พบ .git ใน $TARGET_DIR กำลังเริ่ม 'git init'..."
  git -C "$TARGET_DIR" init -b main
fi

# 2. คัดลอกโฟลเดอร์แกนหลัก (.agents, docs, scripts, templates)
echo "==> ติดตั้งโฟลเดอร์ .agents (Rules, Skills, Subagents, Hooks)..."
mkdir -p "$TARGET_DIR/.agents"
cp -R "$FRAMEWORK_ROOT/.agents/"* "$TARGET_DIR/.agents/" 2>/dev/null || true

echo "==> ติดตั้งโฟลเดอร์ docs/ (sdd, workspecs, code-review)..."
mkdir -p "$TARGET_DIR/docs/sdd"
mkdir -p "$TARGET_DIR/docs/workspecs"
mkdir -p "$TARGET_DIR/docs/code-review"
touch "$TARGET_DIR/docs/workspecs/.gitkeep"
touch "$TARGET_DIR/docs/code-review/.gitkeep"

echo "==> ติดตั้งโฟลเดอร์ scripts/..."
mkdir -p "$TARGET_DIR/scripts"
cp -R "$FRAMEWORK_ROOT/scripts/"* "$TARGET_DIR/scripts/" 2>/dev/null || true
chmod +x "$TARGET_DIR/scripts/"*.sh 2>/dev/null || true

echo "==> ติดตั้ง templates/..."
mkdir -p "$TARGET_DIR/templates"
cp -R "$FRAMEWORK_ROOT/templates/"* "$TARGET_DIR/templates/" 2>/dev/null || true

# 3. สร้างไฟล์ AGENTS.md และ GEMINI.md ถ้ายังไม่มี
if [[ ! -f "$TARGET_DIR/AGENTS.md" ]]; then
  echo "==> สร้าง AGENTS.md จากแม่แบบ..."
  if [[ -f "$FRAMEWORK_ROOT/templates/AGENTS.template.md" ]]; then
    cp "$FRAMEWORK_ROOT/templates/AGENTS.template.md" "$TARGET_DIR/AGENTS.md"
  elif [[ -f "$FRAMEWORK_ROOT/AGENTS.md" ]]; then
    cp "$FRAMEWORK_ROOT/AGENTS.md" "$TARGET_DIR/AGENTS.md"
  fi
fi

if [[ ! -f "$TARGET_DIR/GEMINI.md" ]]; then
  echo "==> เชื่อมโยง GEMINI.md..."
  ln -sf "AGENTS.md" "$TARGET_DIR/GEMINI.md" 2>/dev/null || cp "$TARGET_DIR/AGENTS.md" "$TARGET_DIR/GEMINI.md"
fi

# 4. ตั้งค่า GitHub Remote หากมีการระบุ
if [[ -n "$GITHUB_REPO" ]]; then
  echo "==> กำหนดค่า GitHub Repository: $GITHUB_REPO ใน AGENTS.md..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|<owner/repo>|$GITHUB_REPO|g" "$TARGET_DIR/AGENTS.md" 2>/dev/null || true
  else
    sed -i "s|<owner/repo>|$GITHUB_REPO|g" "$TARGET_DIR/AGENTS.md" 2>/dev/null || true
  fi
fi

# 5. ตั้งค่า .gitignore
if [[ ! -f "$TARGET_DIR/.gitignore" ]]; then
  cat << 'EOF' > "$TARGET_DIR/.gitignore"
# OS & IDE
.DS_Store
Thumbs.db
.vscode/
.idea/

# Environment & Secrets
.env
.env.local
*.pem
*.key

# Temporary & Cache
tmp/
*.log
EOF
fi

# 6. ตรวจสอบสภาพแวดล้อม
echo ""
echo "==> รันการตรวจสอบความพร้อมด้วย doctor.sh..."
(cd "$TARGET_DIR" && ./scripts/doctor.sh) || true

echo ""
echo "🎉 ติดตั้ง AGY SDD Workflow เรียบร้อยแล้ว!"
echo "เริ่มต้นใช้งานในโปรเจกต์นี้ด้วยการพิมพ์:"
echo "1. เปิดใช้งาน Antigravity CLI: agy"
echo "2. หรือสั่งให้ AI รัน Part 1 (First-round SDD): 'เริ่มต้น Project SDD สำหรับโปรเจกต์นี้'"
echo "3. หรือสร้างการ์ด Issue แรก: '/create-task <ชื่อฟีเจอร์>'"
