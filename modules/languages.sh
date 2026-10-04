#!/usr/bin/env bash
set -euo pipefail

install_languages() {
  print_info "Installing language runtimes"

  case "${OSTYPE}" in
    darwin*)
      if ! has_cmd node; then brew install node; fi
      if ! has_cmd go; then brew install go; fi
      if ! has_cmd rustc; then curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; fi
      if ! has_cmd javac; then brew install openjdk; fi
      if ! has_cmd gcc; then xcode-select --install; fi
      if ! has_cmd dotnet; then brew install --cask dotnet; fi
      if ! has_cmd ruby; then brew install ruby; fi
      if ! has_cmd php; then brew install php; fi
      if ! has_cmd kotlin; then brew install kotlin; fi
      ;;
    linux-andro*)
      print_info "Termux provides language runtimes through pkg; no apt/sudo setup is required."
      ;;
    linux-gnu*)
      if ! has_cmd node; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
        sudo apt-get install -y nodejs
      fi
      if ! has_cmd go; then
        curl -fsSL https://go.dev/dl/go1.22.4.linux-amd64.tar.gz -o /tmp/go.tar.gz
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm -f /tmp/go.tar.gz
        echo 'export PATH="/usr/local/go/bin:$PATH"' >> "$HOME/.bashrc"
      fi
      if ! has_cmd rustc; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
      fi
      if ! has_cmd javac; then sudo apt-get install -y default-jdk; fi
      if ! has_cmd gcc || ! has_cmd g++; then sudo apt-get install -y gcc g++; fi
      if ! has_cmd dotnet; then
        wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb
        sudo dpkg -i /tmp/packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-8.0
      fi
      if ! has_cmd ruby; then sudo apt-get install -y ruby-full; fi
      if ! has_cmd php; then sudo apt-get install -y php php-cli php-mbstring; fi
      if ! has_cmd kotlinc; then sudo apt-get install -y kotlin; fi
      ;;
    msys*|cygwin*|win32*)
      if ! has_cmd node; then winget install --id OpenJS.NodeJS.LTS -e || choco install -y nodejs || scoop install nodejs; fi
      if ! has_cmd go; then winget install --id GoLang.Go -e || choco install -y golang || scoop install go; fi
      if ! has_cmd rustc; then winget install --id Rustlang.Rustup -e; fi
      if ! has_cmd java; then winget install --id Oracle.JDK.21 -e || choco install -y openjdk; fi
      if ! has_cmd dotnet; then winget install --id Microsoft.DotNet.SDK.8 -e; fi
      if ! has_cmd ruby; then winget install --id RubyInstallerTeam.Ruby.3.3 -e || choco install -y ruby; fi
      if ! has_cmd php; then winget install --id PHP.PHP.8.3 -e || choco install -y php; fi
      ;;
    *)
      echo "[!] Unsupported platform for language install."
      exit 1
      ;;
  esac

  print_success "Language runtimes installed"
}
