#!/usr/bin/env bash
set -euo pipefail

install_base() {
  print_info "Installing Windows base packages"

  if has_cmd winget; then
    winget install --id Git.Git -e
    winget install --id Python.Python.3.12 -e
    winget install --id OpenJS.NodeJS.LTS -e
    winget install --id Microsoft.VisualStudioCode -e
  elif has_cmd choco; then
    choco install -y git python nodejs vscode
  elif has_cmd scoop; then
    scoop install git python nodejs vscode
  else
    echo "[!] No supported Windows package manager was found."
    exit 1
  fi

  print_success "Base packages installed"
}
