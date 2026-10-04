#!/usr/bin/env bash
set -euo pipefail

install_web3() {
  print_info "Installing Web3 tools"

  npm install -g hardhat truffle ganache ethers
  python3 -m pip install web3 eth-hash eth-keys

  print_success "Web3 tools installed"
}
