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
