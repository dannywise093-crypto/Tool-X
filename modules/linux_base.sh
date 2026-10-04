#!/usr/bin/env bash
set -euo pipefail

install_base() {
  print_info "Installing base Debian/Ubuntu packages"

  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    bash ca-certificates curl wget git build-essential \
    software-properties-common gnupg lsb-release unzip \
    apt-transport-https pkg-config jq xz-utils tar \
    python3 python3-pip python3-venv python3-dev \
    vim nano tmux htop net-tools dnsutils iputils-ping \
    openssh-client openssh-server

  print_success "Base packages installed"
}
