#!/usr/bin/env bash
# Shared helper functions for AGY SDD scripts and hooks
set -euo pipefail

# Detect OS
is_macos() {
  [[ "$OSTYPE" == "darwin"* ]]
}

is_windows() {
  [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || -n "${WINDIR:-}" ]]
}

# Normalize git URL (strip trailing .git and /)
normalize_git_url() {
  local url="${1%/}"
  echo "${url%.git}"
}

# Resolve absolute path
resolve_path() {
  local path="$1"
  if [[ -d "$path" ]]; then
    (cd "$path" && pwd -P)
  elif [[ -f "$path" ]]; then
    local dir
    dir="$(cd "$(dirname "$path")" && pwd -P)"
    echo "$dir/$(basename "$path")"
  else
    echo "$path"
  fi
}

# Read JSON input from stdin (for hooks)
read_hook_input() {
  if [ -t 0 ]; then
    HOOK_INPUT="{}"
  else
    HOOK_INPUT="$(cat)"
  fi
}
