#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main"
SCRIPT_DIR="$(mktemp -d)"
trap 'rm -rf "$SCRIPT_DIR"' EXIT

export TOOL_X_HOME="${HOME}/.tool-x"
export TOOL_X_BIN="${TOOL_X_HOME}/bin"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export TOOL_X_LOGS="${TOOL_X_HOME}/logs"
export TOOL_X_CACHE="${TOOL_X_HOME}/cache"

usage() {
  cat <<'EOF'
Tool-X Installer

Usage:
  bash <(curl -s https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main/setup.sh) [--help|--check|--list]

Options:
  --help, -h     Show this help text
  --check        Check whether the current OS is supported
  --list         Show supported tool categories

Supported Platforms:
  - Termux / Android
  - Linux (Ubuntu/Debian)
  - macOS
  - Windows (Git Bash / WSL)
EOF
}

check_support() {
  case "${OSTYPE:-}" in
    darwin*) echo "Supported: macOS" ;;
    linux-andro*) echo "Supported: Termux / Android" ;;
    linux-gnu*) echo "Supported: Linux (Ubuntu/Debian)" ;;
    msys*|cygwin*|win32*) echo "Supported: Windows" ;;
    *) echo "Unsupported: ${OSTYPE:-unknown}"; exit 1 ;;
  esac
}

list_tools() {
  printf '%s\n' "Base tools" "Language runtimes" "Developer tools"     "Security tools (not installed by the Termux path)" "Cloud tools"     "DevOps tools" "AI/ML tools" "Web3 tools"
}

download_module() {
  local module_name="$1"
  local target="${SCRIPT_DIR}/${module_name}.sh"
  if ! curl -fsSL "${REPO_URL}/modules/${module_name}.sh" -o "$target"; then
    echo "[!] Failed to download module: ${module_name}"
    exit 1
  fi
  [[ -s "$target" ]] || { echo "[!] Empty module: ${module_name}"; exit 1; }
}

mkdir -p "$TOOL_X_HOME" "$TOOL_X_BIN" "$TOOL_X_TOOLS" "$TOOL_X_LOGS" "$TOOL_X_CACHE"

if [[ $# -gt 0 ]]; then
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --check) check_support; exit 0 ;;
    --list) list_tools; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
fi

echo
echo "Tool-X Multi-Platform Installer"
echo "=============================="
echo "Detecting platform: ${OSTYPE:-unknown}"
echo

case "${OSTYPE:-}" in
  linux-andro*)
    echo "Termux/Android detected."
    for m in common termux_base languages devtools toolx_cli; do download_module "$m"; done
    source "${SCRIPT_DIR}/common.sh"
    source "${SCRIPT_DIR}/termux_base.sh"
    source "${SCRIPT_DIR}/languages.sh"
    source "${SCRIPT_DIR}/devtools.sh"
    source "${SCRIPT_DIR}/toolx_cli.sh"
    install_base
    install_languages
    install_devtools
    install_toolx_cli
    ;;
  darwin*)
    for m in common macos_base languages devtools security cloud devops ai web3 toolx_cli; do download_module "$m"; done
    source "${SCRIPT_DIR}/common.sh"
    source "${SCRIPT_DIR}/macos_base.sh"
    source "${SCRIPT_DIR}/languages.sh"
    source "${SCRIPT_DIR}/devtools.sh"
    source "${SCRIPT_DIR}/security.sh"
    source "${SCRIPT_DIR}/cloud.sh"
    source "${SCRIPT_DIR}/devops.sh"
    source "${SCRIPT_DIR}/ai.sh"
    source "${SCRIPT_DIR}/web3.sh"
    source "${SCRIPT_DIR}/toolx_cli.sh"
    install_base; install_languages; install_devtools; install_security
    install_cloud; install_devops; install_ai; install_web3; install_toolx_cli
    ;;
  linux-gnu*)
    if ! grep -Eq 'Ubuntu|Debian' /etc/os-release 2>/dev/null; then
      echo "[!] This installer targets Ubuntu/Debian for generic Linux."
      echo "[!] Detected: $(grep '^NAME=' /etc/os-release 2>/dev/null || echo 'Unknown')"
      exit 1
    fi
    for m in common linux_base languages devtools security cloud devops ai web3 toolx_cli; do download_module "$m"; done
    source "${SCRIPT_DIR}/common.sh"
    source "${SCRIPT_DIR}/linux_base.sh"
    source "${SCRIPT_DIR}/languages.sh"
    source "${SCRIPT_DIR}/devtools.sh"
    source "${SCRIPT_DIR}/security.sh"
    source "${SCRIPT_DIR}/cloud.sh"
    source "${SCRIPT_DIR}/devops.sh"
    source "${SCRIPT_DIR}/ai.sh"
    source "${SCRIPT_DIR}/web3.sh"
    source "${SCRIPT_DIR}/toolx_cli.sh"
    install_base; install_languages; install_devtools; install_security
    install_cloud; install_devops; install_ai; install_web3; install_toolx_cli
    ;;
  msys*|cygwin*|win32*)
    for m in common windows_base languages devtools security cloud devops ai web3 toolx_cli; do download_module "$m"; done
    source "${SCRIPT_DIR}/common.sh"
    source "${SCRIPT_DIR}/windows_base.sh"
    source "${SCRIPT_DIR}/languages.sh"
    source "${SCRIPT_DIR}/devtools.sh"
    source "${SCRIPT_DIR}/security.sh"
    source "${SCRIPT_DIR}/cloud.sh"
    source "${SCRIPT_DIR}/devops.sh"
    source "${SCRIPT_DIR}/ai.sh"
    source "${SCRIPT_DIR}/web3.sh"
    source "${SCRIPT_DIR}/toolx_cli.sh"
    install_base; install_languages; install_devtools; install_security
    install_cloud; install_devops; install_ai; install_web3; install_toolx_cli
    ;;
  *) echo "[!] Unsupported platform: ${OSTYPE:-unknown}"; exit 1 ;;
esac

echo
echo "[✓] Tool-X installation complete."
echo "[✓] Run: toolx help"
echo