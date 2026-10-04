#!/usr/bin/env bash
set -euo pipefail

print_info() {
  printf '[*] %s\n' "$*"
}

print_success() {
  printf '[✓] %s\n' "$*"
}

print_warn() {
  printf '[!] %s\n' "$*" >&2
}

has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

ensure_path_entry() {
  local dir="$1"
  local shell_file="${HOME}/.bashrc"
  [[ -f "$shell_file" ]] || touch "$shell_file"
  if ! grep -Fqx "export PATH=\"$dir:\$PATH\"" "$shell_file" 2>/dev/null; then
    printf '%s\n' "export PATH=\"$dir:\$PATH\"" >> "$shell_file"
  fi
}