#!/usr/bin/env bash
set -euo pipefail

print_success() {
  echo "[✓] $1"
}

print_info() {
  echo "[*] $1"
}

run_quiet() {
  "$@" >/dev/null 2>&1
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_path_entry() {
  local entry="$1"
  if ! grep -Fq "$entry" "$HOME/.bashrc" 2>/dev/null; then
    echo "export PATH=\"$entry:\$PATH\"" >> "$HOME/.bashrc"
  fi
}

log_step() {
  echo "[$(date +%H:%M:%S)] $1" >> "${TOOL_X_LOGS:-$HOME/.tool-x/logs}/toolx.log"
}
