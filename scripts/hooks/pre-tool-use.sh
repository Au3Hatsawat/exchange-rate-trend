#!/usr/bin/env bash
# AGY SDD PreToolUse Guard Dispatcher
# Inspects tool calls before execution to enforce SDD safety rules.
# Input is JSON on stdin.
# Exit 0 = allow. Exit 2 = block (reason printed to stderr). Exit 1 = warn.
set -u

case "${BASH_SOURCE[0]}" in */*) here="${BASH_SOURCE[0]%/*}" ;; *) here=. ;; esac

if ! command -v jq >/dev/null 2>&1; then
  # If jq is missing, do not block development, warn only
  echo "[AGY SDD Hook] Warning: jq is not installed. Safety checks skipped." >&2
  exit 0
fi

INPUT="$(cat)"

# Quick string inspection
case "$INPUT" in
  *"run_command"*)
    # Extract command line
    cmd="$(echo "$INPUT" | jq -r '.tool_input.CommandLine // empty' 2>/dev/null || true)"
    if [ -n "$cmd" ]; then
      # 1. Guard: Never push directly to master or main
      if echo "$cmd" | grep -Eq 'git\s+push\s+.*(origin\s+)?(master|main)(\s|$)'; then
        echo "🛑 [AGY SDD Blocked] ไม่อนุญาตให้ git push เข้า branch master หรือ main โดยตรง!" >&2
        echo "   กติกา SDD: โค้ดทั้งหมดต้องแตก branch งาน และส่งผ่าน Pull Request เท่านั้น" >&2
        exit 2
      fi

      # 2. Guard: Never auto-merge PR or close/delete issues via AI
      if echo "$cmd" | grep -Eq 'gh\s+pr\s+(merge|close)(\s|$)'; then
        echo "🛑 [AGY SDD Blocked] ไม่อนุญาตให้ AI สั่ง merge หรือ close Pull Request อัตโนมัติ" >&2
        echo "   กติกา SDD ข้อ 8: การตรวจและกด merge PR เป็นหน้าที่ของมนุษย์ (Reviewer / Tech Lead) เท่านั้น" >&2
        exit 2
      fi

      if echo "$cmd" | grep -Eq 'gh\s+issue\s+(close|delete)(\s|$)'; then
        echo "🛑 [AGY SDD Blocked] ไม่อนุญาตให้ AI สั่ง close หรือ delete Issue อัตโนมัติ" >&2
        echo "   กติกา SDD ข้อ 8: การปิดหรือลบ Issue บน GitHub ต้องทำโดยคนเท่านั้น" >&2
        exit 2
      fi
    fi
    ;;

  *"edit_file"*|*"write_file"*)
    # Check if attempting to tick human gate lines [x] 🛑 in _status.md
    file_path="$(echo "$INPUT" | jq -r '.tool_input.Path // empty' 2>/dev/null || true)"
    content="$(echo "$INPUT" | jq -r '.tool_input.Content // .tool_input.Replacement // empty' 2>/dev/null || true)"

    if [[ "$file_path" == *"_status.md" ]]; then
      # Detect if subagent attempts to tick 🛑 line
      # Note: Subagents cannot tick [x] 🛑. Only human or main session with explicit order.
      if echo "$content" | grep -Eq '\[[xX]\]\s*(🛑|✋)'; then
        if [ -n "${AGY_SUBAGENT:-}" ]; then
          echo "🛑 [AGY SDD Blocked] Subagent ไม่มีสิทธิ์ติ๊กประตู [x] 🛑 หรือ [x] ✋ ใน _status.md" >&2
          echo "   กติกา SDD: ประตูมนุษย์ต้องได้รับการอนุมัติจากผู้ใช้จริงเท่านั้น" >&2
          exit 2
        fi
      fi
    fi
    ;;
esac

exit 0
