#!/usr/bin/env bash
set -euo pipefail

install_base() {
  print_info "Installing Termux base packages"
  command -v pkg >/dev/null 2>&1 || {
    echo "[!] This path requires Termux with pkg available."
    exit 1
  }

  pkg update -y
  pkg upgrade -y
  pkg install -y bash ca-certificates curl wget git clang make cmake     pkg-config python nodejs golang rust openjdk-17 ruby php     jq unzip tar xz-utils ripgrep fd fzf tree tmux nano vim

  print_success "Termux base packages installed"
}
