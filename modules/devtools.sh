#!/usr/bin/env bash
set -euo pipefail

install_devtools() {
  print_info "Installing developer tools"

  case "${OSTYPE}" in
    darwin*)
      brew install git-lfs cmake ninja make maven gradle sqlite mysql redis jq ripgrep fzf bat fd tree tmux exa
      npm install -g eslint prettier webpack webpack-cli typescript ts-node nodemon pm2
      ;;
    linux-andro*)
      pkg install -y git-lfs cmake make ninja sqlite postgresql jq ripgrep fd fzf bat tree tmux
      npm install -g eslint prettier typescript ts-node nodemon pm2
      ;;
    linux-gnu*)
      sudo apt-get install -y git-lfs cmake make ninja-build maven gradle sqlite3 postgresql-client mysql-client redis-tools jq ripgrep fd-find fzf bat exa silversearcher-ag curl wget unzip tree tmux
      sudo npm install -g eslint prettier webpack webpack-cli typescript ts-node nodemon pm2
      ;;
    msys*|cygwin*|win32*)
      winget install --id GitHub.cli -e || choco install -y gh
      winget install --id Docker.DockerDesktop -e || choco install -y docker-desktop
      winget install --id Hashicorp.Terraform -e || choco install -y terraform
      npm install -g eslint prettier webpack webpack-cli typescript ts-node nodemon pm2
      ;;
    *)
      echo "[!] Unsupported platform for devtools install."
      exit 1
      ;;
  esac

  print_success "Developer tools installed"
}
