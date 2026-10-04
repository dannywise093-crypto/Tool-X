#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main"
SCRIPT_DIR="$(mktemp -d)"
TRAP_CLEANUP() { rm -rf "$SCRIPT_DIR"; }
trap TRAP_CLEANUP EXIT

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

Notes:
  Linux is the primary supported target.
  macOS and Windows are included as optional platform modules.
EOF
}

check_support() {
  case "$OSTYPE" in
    darwin*) echo "Supported: macOS" ;;
    linux-gnu*) echo "Supported: Linux (Ubuntu/Debian)" ;;
    msys*|cygwin*|win32*) echo "Supported: Windows" ;;
    *) echo "Unsupported: $OSTYPE" ; exit 1 ;;
  esac
}

list_tools() {
  echo "Base tools"
  echo "Language runtimes"
  echo "Developer tools"
  echo "Security tools"
  echo "Cloud tools"
  echo "DevOps tools"
  echo "AI/ML tools"
  echo "Web3 tools"
}

download_module() {
  local module_name="$1"
  curl -s "${REPO_URL}/modules/${module_name}.sh" -o "${SCRIPT_DIR}/${module_name}.sh"
  if [[ ! -f "${SCRIPT_DIR}/${module_name}.sh" ]]; then
    echo "[!] Failed to download module: ${module_name}"
    exit 1
  fi
}

mkdir -p "$TOOL_X_HOME" "$TOOL_X_BIN" "$TOOL_X_TOOLS" "$TOOL_X_LOGS" "$TOOL_X_CACHE"

if [[ $# -gt 0 ]]; then
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --check)
      check_support
      exit 0
      ;;
    --list)
      list_tools
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
fi

echo ""
echo "Tool-X Multi-Platform Installer"
echo "=============================="
echo ""
echo "Downloading modules..."

download_module "common"
download_module "languages"
download_module "devtools"
download_module "security"
download_module "cloud"
download_module "devops"
download_module "ai"
download_module "web3"
download_module "toolx_cli"

if [[ "$OSTYPE" == "darwin"* ]]; then
  download_module "macos_base"
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

  install_base
  install_languages
  install_devtools
  install_security
  install_cloud
  install_devops
  install_ai
  install_web3
  install_toolx_cli

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if ! grep -Eq 'Ubuntu|Debian' /etc/os-release 2>/dev/null; then
    echo "[!] This version is written for Ubuntu/Debian Linux."
    exit 1
  fi

  download_module "linux_base"
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

  install_base
  install_languages
  install_devtools
  install_security
  install_cloud
  install_devops
  install_ai
  install_web3
  install_toolx_cli

elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || "$OSTYPE" == "win32"* ]]; then
  download_module "windows_base"
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

  install_base
  install_languages
  install_devtools
  install_security
  install_cloud
  install_devops
  install_ai
  install_web3
  install_toolx_cli

else
  echo "[!] Unsupported platform: ${OSTYPE}"
  exit 1
fi

echo ""
echo "[✓] Tool-X installation complete."
echo "[✓] Run: toolx help"
echo ""
