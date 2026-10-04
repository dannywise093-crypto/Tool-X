#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export TOOL_X_HOME="${HOME}/.tool-x"
export TOOL_X_BIN="${TOOL_X_HOME}/bin"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export TOOL_X_LOGS="${TOOL_X_HOME}/logs"
export TOOL_X_CACHE="${TOOL_X_HOME}/cache"

mkdir -p "$TOOL_X_HOME" "$TOOL_X_BIN" "$TOOL_X_TOOLS" "$TOOL_X_LOGS" "$TOOL_X_CACHE"

echo ""
echo "Tool-X Multi-Platform Installer"
echo "=============================="
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
  source "$SCRIPT_DIR/modules/common.sh"
  source "$SCRIPT_DIR/modules/macos_base.sh"
  source "$SCRIPT_DIR/modules/languages.sh"
  source "$SCRIPT_DIR/modules/devtools.sh"
  source "$SCRIPT_DIR/modules/security.sh"
  source "$SCRIPT_DIR/modules/cloud.sh"
  source "$SCRIPT_DIR/modules/devops.sh"
  source "$SCRIPT_DIR/modules/ai.sh"
  source "$SCRIPT_DIR/modules/web3.sh"
  source "$SCRIPT_DIR/modules/toolx_cli.sh"

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

  source "$SCRIPT_DIR/modules/common.sh"
  source "$SCRIPT_DIR/modules/linux_base.sh"
  source "$SCRIPT_DIR/modules/languages.sh"
  source "$SCRIPT_DIR/modules/devtools.sh"
  source "$SCRIPT_DIR/modules/security.sh"
  source "$SCRIPT_DIR/modules/cloud.sh"
  source "$SCRIPT_DIR/modules/devops.sh"
  source "$SCRIPT_DIR/modules/ai.sh"
  source "$SCRIPT_DIR/modules/web3.sh"
  source "$SCRIPT_DIR/modules/toolx_cli.sh"

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
  source "$SCRIPT_DIR/modules/common.sh"
  source "$SCRIPT_DIR/modules/windows_base.sh"
  source "$SCRIPT_DIR/modules/languages.sh"
  source "$SCRIPT_DIR/modules/devtools.sh"
  source "$SCRIPT_DIR/modules/security.sh"
  source "$SCRIPT_DIR/modules/cloud.sh"
  source "$SCRIPT_DIR/modules/devops.sh"
  source "$SCRIPT_DIR/modules/ai.sh"
  source "$SCRIPT_DIR/modules/web3.sh"
  source "$SCRIPT_DIR/modules/toolx_cli.sh"

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
