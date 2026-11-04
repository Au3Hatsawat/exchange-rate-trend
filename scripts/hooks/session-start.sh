#!/usr/bin/env bash
# AGY SDD SessionStart Hook
# Runs once when a session starts or resumes to check environment health.
set -u

case "${BASH_SOURCE[0]}" in */*) here="${BASH_SOURCE[0]%/*}" ;; *) here=. ;; esac
root="$(cd "$here/../.." && pwd)"

# Run quick doctor check
if [ -f "$root/scripts/doctor.sh" ]; then
  # Only run if terminal is available or output quick status
  bash "$root/scripts/doctor.sh" >/dev/null 2>&1 || {
    echo "⚠️ [AGY SDD] ตรวจพบการตั้งค่าบางอย่างยังไม่พร้อม — รัน './scripts/doctor.sh' เพื่อตรวจสอบรายละเอียด"
  }
fi

exit 0
