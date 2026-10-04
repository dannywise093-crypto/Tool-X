#!/usr/bin/env bash

install_linux() {
  print_info "Installing Linux/macOS comprehensive toolchain"

  # === SYSTEM UPDATE ===
  if [ "$PKG_MANAGER" = "apt" ]; then
    run_quiet sudo apt-get update -y
    run_quiet sudo apt-get upgrade -y
  elif [ "$PKG_MANAGER" = "pacman" ]; then
    run_quiet sudo pacman -Sy --noconfirm
  elif [ "$PKG_MANAGER" = "dnf" ]; then
    run_quiet sudo dnf check-update -y
    run_quiet sudo dnf upgrade -y
  elif [ "$PKG_MANAGER" = "brew" ]; then
    run_quiet brew update
    run_quiet brew upgrade
  fi

  # === CORE DEVELOPMENT ===
  print_info "Installing core development tools"
  local core_tools=(
    "git" "curl" "wget" "build-essential" "python3" "python3-pip" "python3-dev"
    "nodejs" "npm" "vim" "nano" "jq" "htop" "tmux" "screen"
    "openssh-client" "openssh-server" "openssh-sftp-server"
  )

  for tool in "${core_tools[@]}"; do
    run_quiet install_pkg "$tool" &
  done
  wait
  print_success "Core development tools"

  # === SECURITY & PENETRATION TESTING ===
  print_info "Installing security tools"
  local security_tools=(
    "nmap" "masscan" "whois" "dnsmap" "dnsenum" "fierce"
    "nikto" "gobuster" "dirbuster" "sqlmap" "zaproxy"
    "metasploit-framework" "burpsuite" "hydra" "john" "hashcat"
    "wireshark" "tcpdump" "tshark" "aircrack-ng"
    "ghidra" "radare2" "binwalk" "exiftool" "steghide"
    "netcat-openbsd" "socat" "proxychains" "mitmproxy"
    "searchsploit" "commix" "airspy" "rtl-sdr"
  )

  for tool in "${security_tools[@]}"; do
    run_quiet install_pkg "$tool" &
  done
  wait
  print_success "Security & penetration testing tools"

  # === NETWORK TOOLS ===
  print_info "Installing network tools"
  local network_tools=(
    "netcat" "telnet" "ssh" "sftp" "rsync" "nfs-common"
    "curl" "wget" "httpie" "w3m" "lynx" "links"
    "dig" "nslookup" "host" "traceroute" "mtr"
    "iftop" "nethogs" "vnstat" "iperf" "speedtest-cli"
    "ftp" "lftp" "ncftp" "sshpass"
  )

  for tool in "${network_tools[@]}"; do
    run_quiet install_pkg "$tool" &
  done
  wait
  print_success "Network tools"

  # === WEB FRAMEWORKS & SERVERS ===
  print_info "Installing web frameworks"
  local web_tools=(
    "apache2" "nginx" "php" "php-cli" "php-mysql" "php-curl"
    "mysql-server" "postgresql" "mariadb-server" "sqlite3"
  )

  for tool in "${web_tools[@]}"; do
    run_quiet install_pkg "$tool" &
  done
  wait
  print_success "Web frameworks & servers"

  # === PROGRAMMING LANGUAGES ===
  print_info "Installing programming languages"

  # Go
  if ! has_cmd go; then
    GO_VERSION="1.21.3"
    GO_OS="linux"
    GO_ARCH="amd64"
    [ "$PLATFORM" = "macos" ] && GO_OS="darwin"
    
    run_quiet wget -q "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz
    if [ -f "/tmp/go.tar.gz" ]; then
      run_quiet sudo rm -rf /usr/local/go
      run_quiet sudo tar -C /usr/local -xzf /tmp/go.tar.gz
      rm -f /tmp/go.tar.gz
      print_success "Go"
    fi
  else
    print_success "Go"
  fi

  # Rust
  if ! has_cmd rustc; then
    run_quiet curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    print_success "Rust"
  else
    print_success "Rust"
  fi

  # Ruby
  run_quiet install_pkg "ruby"
  print_success "Ruby"

  # Java
  run_quiet install_pkg "default-jdk"
  print_success "Java"

  # Maven & Gradle
  run_quiet install_pkg "maven"
  print_success "Maven"

  # === CLOUD PLATFORMS ===
  print_info "Installing cloud tools"

  # AWS CLI
  if ! has_cmd aws; then
    run_quiet curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
    if [ -f "/tmp/awscliv2.zip" ]; then
      run_quiet unzip -q /tmp/awscliv2.zip -d /tmp
      run_quiet sudo /tmp/aws/install
      rm -rf /tmp/aws /tmp/awscliv2.zip
      print_success "AWS CLI"
    fi
  else
    print_success "AWS CLI"
  fi

  # Google Cloud SDK
  if ! has_cmd gcloud && [ "$PLATFORM" = "linux" ]; then
    run_quiet echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    run_quiet curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    run_quiet sudo apt-get update
    run_quiet sudo apt-get install -y google-cloud-sdk
    print_success "Google Cloud SDK"
  else
    [ "$PLATFORM" = "linux" ] && print_success "Google Cloud SDK" || print_success "Google Cloud SDK (macOS/skip)"
  fi

  # Azure CLI
  if ! has_cmd az && [ "$PLATFORM" = "linux" ]; then
    run_quiet curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    print_success "Azure CLI"
  else
    [ "$PLATFORM" = "linux" ] && print_success "Azure CLI" || print_success "Azure CLI (macOS/skip)"
  fi

  # === DEVOPS & CONTAINERS ===
  print_info "Installing DevOps tools"

  # Docker
  if ! has_cmd docker; then
    if [ "$PLATFORM" = "linux" ]; then
      run_quiet curl -fsSL https://get.docker.com | bash
      print_success "Docker"
    else
      print_success "Docker (install manually on macOS)"
    fi
  else
    print_success "Docker"
  fi

  # Docker Compose
  if ! has_cmd docker-compose; then
    run_quiet sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    run_quiet sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose"
  else
    print_success "Docker Compose"
  fi

  # Kubernetes
  if ! has_cmd kubectl; then
    KUBE_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
    run_quiet curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
    if [ -f "kubectl" ]; then
      run_quiet sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      rm -f kubectl
      print_success "kubectl"
    fi
  else
    print_success "kubectl"
  fi

  # Helm
  if ! has_cmd helm; then
    run_quiet curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    print_success "Helm"
  else
    print_success "Helm"
  fi

  # Terraform
  if ! has_cmd terraform; then
    TERRAFORM_VERSION="1.7.0"
    TERRAFORM_OS="linux"
    [ "$PLATFORM" = "macos" ] && TERRAFORM_OS="darwin"
    TERRAFORM_ARCH="amd64"

    run_quiet wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}_${TERRAFORM_ARCH}.zip" -O /tmp/terraform.zip
    if [ -f "/tmp/terraform.zip" ]; then
      run_quiet unzip -q /tmp/terraform.zip -d /tmp
      run_quiet sudo mv /tmp/terraform /usr/local/bin/
      rm -f /tmp/terraform.zip
      print_success "Terraform"
    fi
  else
    print_success "Terraform"
  fi

  # Ansible
  if ! has_cmd ansible; then
    run_quiet python3 -m pip install --user ansible
    print_success "Ansible"
  else
    print_success "Ansible"
  fi

  # Vagrant
  run_quiet install_pkg "vagrant"
  print_success "Vagrant"

  # === DATABASES ===
  print_info "Installing databases"
  local databases=(
    "postgresql" "mysql-server" "sqlite3"
  )

  for db in "${databases[@]}"; do
    run_quiet install_pkg "$db" &
  done
  wait
  print_success "Database servers"

  # MongoDB (if available)
  if [ "$PKG_MANAGER" = "apt" ]; then
    run_quiet sudo apt-get install -y mongodb-org
    print_success "MongoDB"
  fi

  # Redis
  run_quiet install_pkg "redis-server"
  print_success "Redis"

  # === PYTHON PACKAGES ===
  print_info "Installing Python ecosystem"
  run_quiet python3 -m pip install --upgrade pip setuptools wheel

  # Core packages
  run_quiet python3 -m pip install \
    paramiko requests beautifulsoup4 cryptography pycryptodome \
    scapy pwntools impacket pycurl pycurl-requests
  print_success "Python security packages"

  # Web frameworks
  run_quiet python3 -m pip install \
    flask django fastapi sqlalchemy sqlmodel \
    pydantic marshmallow pytest selenium scrapy
  print_success "Python web frameworks"

  # OSINT & scanning
  run_quiet python3 -m pip install \
    shodan censys dnspython netaddr ipaddress
  print_success "Python OSINT packages"

  # Data science
  run_quiet python3 -m pip install \
    numpy pandas matplotlib scipy scikit-learn seaborn plotly
  print_success "Python data science packages"

  # Utils
  run_quiet python3 -m pip install \
    click colorama tqdm progressbar33 pexpect
  print_success "Python utility packages"

  # === NODE.JS PACKAGES ===
  print_info "Installing Node.js packages"
  if has_cmd npm; then
    run_quiet npm install -g \
      http-server webpack webpack-cli webpack-dev-server \
      eslint prettier babel-cli mocha jest pm2 \
      nodemon gulp grunt express fastify koa
    print_success "Node.js packages (18+)"

    # Web3
    run_quiet npm install -g ethers hardhat truffle ganache
    print_success "Node.js Web3 packages"
  fi

  # === AI/ML TOOLS ===
  print_info "Installing AI/ML tools"
  run_quiet python3 -m pip install \
    jupyter jupyterlab ipython \
    transformers datasets huggingface-hub \
    tensorflow torch keras pytorch torchvision
  print_success "AI/ML tools (Jupyter, TensorFlow, PyTorch)"

  # === WEB3/BLOCKCHAIN ===
  print_info "Installing Web3 tools"
  run_quiet python3 -m pip install web3 eth-keys eth-typing
  run_quiet npm install -g hardhat truffle ganache ethers
  print_success "Web3/Blockchain tools"

  # === EDITORS & IDE ===
  print_info "Installing editors"
  run_quiet install_pkg "code"
  print_success "VSCode"

  run_quiet install_pkg "sublime-text"
  print_success "Sublime Text"

  # === MISC UTILITIES ===
  print_info "Installing utilities"
  local utils=(
    "tree" "ripgrep" "fzf" "bat" "exa" "fd" "sd"
    "bottom" "du-dust" "procs" "lsd"
  )

  for util in "${utils[@]}"; do
    run_quiet install_pkg "$util" &
  done
  wait
  print_success "Utility tools"

  # === SECURITY WORDLISTS & RESOURCES ===
  print_info "Downloading security resources"
  mkdir -p "$TOOL_X_TOOLS"
  cd "$TOOL_X_TOOLS" || exit

  run_quiet git clone --depth 1 https://github.com/danielmiessler/SecLists.git
  print_success "SecLists"

  run_quiet git clone --depth 1 https://github.com/projectdiscovery/nuclei-templates.git
  print_success "Nuclei Templates"

  run_quiet git clone --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings.git
  print_success "PayloadsAllTheThings"

  run_quiet git clone --depth 1 https://github.com/trickest/cve.git
  print_success "CVE Database"

  run_quiet git clone --depth 1 https://github.com/devanshbatham/Awesome-Bugbounty-tools.git
  print_success "Awesome Bugbounty Tools"

  # === SHELL INTEGRATION ===
  print_info "Setting up shell integration"
  local rc_file="$HOME/.bashrc"
  [ -n "$ZSH_VERSION" ] && rc_file="$HOME/.zshrc"

  if ! grep -q "Tool-X" "$rc_file" 2>/dev/null; then
    cat >> "$rc_file" << 'SHELL_CONFIG'

# Tool-X v5.0 Environment
export TOOL_X_HOME="$HOME/.tool-x"
export TOOL_X_BIN="${TOOL_X_HOME}/bin"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export PATH="${TOOL_X_BIN}:${PATH}"
export GOPATH="${TOOL_X_HOME}/go"
export GOROOT="/usr/local/go"
export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:${PATH}"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:${PATH}"

alias toolx='${TOOL_X_BIN}/toolx'
alias ll='ls -lah'
alias l='ls -la'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
SHELL_CONFIG
    print_success "Shell integration"
  else
    print_success "Shell integration"
  fi

  print_success "Linux/macOS toolchain installation complete"
}

install_pkg() {
  local pkg="$1"
  local manager="${PKG_MANAGER:-unknown}"

  case "$manager" in
    apt)
      run_quiet sudo apt-get install -y "$pkg"
      ;;
    pacman)
      run_quiet sudo pacman -S --noconfirm "$pkg"
      ;;
    dnf)
      run_quiet sudo dnf install -y "$pkg"
      ;;
    yum)
      run_quiet sudo yum install -y "$pkg"
      ;;
    brew)
      run_quiet brew install "$pkg"
      ;;
    *)
      return 1
      ;;
  esac
}
