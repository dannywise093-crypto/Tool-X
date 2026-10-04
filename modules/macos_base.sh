#!/usr/bin/env bash
set -euo pipefail

install_base() {
  print_info "Installing macOS base packages"

  brew update

  brew install \
    curl wget git unzip jq tmux htop \
    python node openssl xz zstd \
    vim nano dnsutils

  print_success "Base packages installed"
}
