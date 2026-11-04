#!/usr/bin/env bash
# AGY SDD Doctor — ตรวจสอบความพร้อมของระบบและเครื่องมือก่อนเริ่มโปรเจกต์
# ใช้งาน: ./scripts/doctor.sh
set -u

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root" || exit 1

pass=0
warn=0
fail=0

ok() { pass=$((pass + 1)); printf '✅ PASS: %s\n' "$1"; }
wn() { warn=$((warn + 1)); printf '⚠️  WARN: %s\n     → วิธีแก้: %s\n' "$1" "$2"; }
no() { fail=$((fail + 1)); printf '❌ FAIL: %s\n     → วิธีแก้: %s\n' "$1" "$2"; }

echo "=========================================================="
echo "          AGY SDD Environment & Tooling Doctor            "
echo "=========================================================="
echo "โฟลเดอร์โปรเจกต์: $root"
echo ""

# 1. Bash
if [ "${BASH_VERSINFO[0]}" -gt 3 ] || { [ "${BASH_VERSINFO[0]}" -eq 3 ] && [ "${BASH_VERSINFO[1]}" -ge 2 ]; }; then
  ok "bash ${BASH_VERSION}"
else
  no "bash ${BASH_VERSION} เก่ากว่า 3.2" "ใช้ bash 3.2 ขึ้นไป (macOS มีในตัว, Windows ให้ใช้ Git Bash)"
fi

# 2. Git
if command -v git >/dev/null 2>&1; then
  ok "$(git --version)"
else
  no "ไม่พบ git" "ติดตั้ง git (macOS: xcode-select --install, Windows: Git for Windows)"
fi

# 3. jq (JSON Processor)
if command -v jq >/dev/null 2>&1; then
  jq_ver="$(jq --version 2>/dev/null || echo 'unknown')"
  ok "jq ($jq_ver)"
else
  no "ไม่พบ jq (จำเป็นสำหรับ AGY Hooks และ JSON processing)" "macOS: brew install jq · Windows: winget install jqlang.jq"
fi

# 4. GitHub CLI (gh)
if command -v gh >/dev/null 2>&1; then
  gh_ver="$(gh --version | head -n 1)"
  ok "$gh_ver"

  # Check authentication status
  if gh auth status >/dev/null 2>&1; then
    user_login="$(gh api user --jq .login 2>/dev/null || echo '')"
    ok "gh login แล้วในชื่อ: @$user_login"

    # Check project scope for GitHub Projects / board management
    if gh auth status 2>&1 | grep -q 'project'; then
      ok "gh token มี scope 'project' (สามารถจัดการ GitHub Projects Board ได้)"
    else
      wn "gh token ยังไม่มี scope 'project'" "รัน 'gh auth refresh -s project' เพื่อให้สร้างและจัดบอร์ดอัตโนมัติได้"
    fi
  else
    wn "gh ยังไม่ได้ล็อกอิน" "รัน 'gh auth login' และ 'gh auth setup-git' เพื่อให้ AI เชื่อมต่อกับ GitHub Issues ได้"
  fi
else
  no "ไม่พบ GitHub CLI (gh)" "ติดตั้ง gh (macOS: brew install gh · Windows: winget install GitHub.cli)"
fi

# 5. AGY Customization Directory & Rules
if [ -d "$root/.agents" ] && [ -f "$root/AGENTS.md" ]; then
  ok "พบโครงสร้าง .agents/ และ AGENTS.md ของ AGY ครบถ้วน"
else
  no "ไม่พบ .agents/ หรือ AGENTS.md ในโฟลเดอร์ราก" "ตรวจสอบว่ารัน script จากรากของโปรเจกต์ที่มีระบบ AGY SDD"
fi

# 6. Essential Unix Tools
missing_tools=""
for t in awk sed grep tr cut wc sort head tail find xargs; do
  command -v "$t" >/dev/null 2>&1 || missing_tools="$missing_tools $t"
done

if [ -z "$missing_tools" ]; then
  ok "เครื่องมือพื้นฐานครบ (sed, awk, grep, find, xargs, etc.)"
else
  no "ขาดเครื่องมือพื้นฐาน:$missing_tools" "ติดตั้งหรือตรวจสอบ PATH ของ shell"
fi

echo ""
echo "=========================================================="
echo "สรุปผล: PASS=$pass | WARN=$warn | FAIL=$fail"
if [ "$fail" -eq 0 ]; then
  echo "🎉 ระบบพร้อมสำหรับการใช้งาน AGY SDD Workflow!"
  exit 0
else
  echo "⚠️ กรุณาแก้ไขข้อผิดพลาด (FAIL) ข้างต้นก่อนเริ่มรันงานแบบอัตโนมัติ"
  exit 1
fi
