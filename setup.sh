#!/bin/bash
# Author: Danny Wise (Enhanced)
# Original Author: Lokesh Kumar
# Update: 2026-10-04
# Project: Tool-X Universal Installer v3.0
# Enhanced with: Kali Tools, Cloud, DevOps, Development, Forensics, Reverse Eng

set -o pipefail

TOOL_DIR="$HOME/tool-x"
REPO_URL="https://github.com/dannywise093-crypto/Tool-X"
INSTALLER_SCRIPT="tool-x.py"
LOG_FILE="$TOOL_DIR/install.log"

# Command variations
COMMANDS=("toolx" "Toolx" "Tool-x" "tool-x")

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
NC='\033[0m'

# Logging function
log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Error handler - continue on error
error_handler() {
    log "${RED}[!] Error at line $1${NC}"
}
trap 'error_handler $LINENO' ERR

print_banner() {
    clear
    log "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║               ${PURPLE}⚔️  TOOL-X v3.0 UNIVERSAL  ⚔️${CYAN}              ║
║          Advanced Multi-Purpose Security & DevOps Toolkit     ║
║                                                               ║
║  Kali | Cloud | DevOps | Development | Forensics | Reverse   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    log "${NC}"
}

# Create log file
mkdir -p "$TOOL_DIR" 2>/dev/null || true
touch "$LOG_FILE"

print_banner

log "\n${GREEN}[*] Initializing Tool-X v3.0 Universal Setup...${NC}"

# --- STEP 1: OS & Package Manager Detection ---
log "${YELLOW}[*] Detecting Operating System and Package Manager...${NC}"

INSTALL_CMD=""
PKG_MANAGER=""

if [ -d "$PREFIX" ] && grep -q "com.termux" "$PREFIX/etc/bash.bashrc" 2>/dev/null; then
    OS_TYPE="termux"
    BIN_DIR="$PREFIX/bin"
    PKG_MANAGER="pkg"
    log "${GREEN}[+] Environment: Termux (Android) Detected.${NC}"
    pkg update -y 2>/dev/null || log "${YELLOW}[!] pkg update failed${NC}"
    pkg install git python -y 2>/dev/null || log "${YELLOW}[!] pkg install failed${NC}"

elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
    BIN_DIR="$HOME/bin"
    log "${GREEN}[+] Environment: Windows (Git Bash/MSYS2) Detected.${NC}"
    mkdir -p "$BIN_DIR"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    BIN_DIR="/usr/local/bin"
    PKG_MANAGER="brew"
    log "${GREEN}[+] Environment: macOS (Homebrew) Detected.${NC}"
    if command -v brew >/dev/null; then
        brew update 2>/dev/null || log "${YELLOW}[!] brew update failed${NC}"
        brew install git python3 2>/dev/null || log "${YELLOW}[!] brew install failed${NC}"
    else
        log "${RED}[!] Homebrew not found. Install from https://brew.sh${NC}"
    fi

else
    OS_TYPE="linux"
    BIN_DIR="/usr/local/bin"
    
    if command -v apt-get >/dev/null 2>&1; then
        log "${GREEN}[+] Environment: Debian/Ubuntu/Kali/Parrot Detected.${NC}"
        PKG_MANAGER="apt"
        INSTALL_CMD="sudo apt-get install -y"
        sudo apt-get update -y 2>/dev/null || log "${YELLOW}[!] apt update failed${NC}"
        
    elif command -v pacman >/dev/null 2>&1; then
        log "${GREEN}[+] Environment: Arch/Manjaro/BlackArch Detected.${NC}"
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        sudo pacman -Sy --noconfirm 2>/dev/null || log "${YELLOW}[!] pacman update failed${NC}"
        
    elif command -v dnf >/dev/null 2>&1; then
        log "${GREEN}[+] Environment: Fedora/RedHat/CentOS Detected.${NC}"
        PKG_MANAGER="dnf"
        INSTALL_CMD="sudo dnf install -y"
        sudo dnf check-update -y 2>/dev/null || log "${YELLOW}[!] dnf check-update failed${NC}"
        
    elif command -v yum >/dev/null 2>&1; then
        log "${GREEN}[+] Environment: Legacy RedHat/CentOS Detected.${NC}"
        PKG_MANAGER="yum"
        INSTALL_CMD="sudo yum install -y"
        
    else
        log "${RED}[!] Unknown Linux Distro. Continuing with manual setup...${NC}"
        PKG_MANAGER="unknown"
    fi
fi

# --- STEP 2: Install Python & Dependencies ---
log "\n${YELLOW}[*] Installing Python and Core Dependencies...${NC}"

if [ "$OS_TYPE" = "termux" ]; then
    pip install rich requests beautifulsoup4 --break-system-packages 2>/dev/null || \
    pip install rich requests beautifulsoup4 2>/dev/null || log "${YELLOW}[!] pip install skipped${NC}"
else
    python3 -m pip install --upgrade pip 2>/dev/null || log "${YELLOW}[!] pip upgrade skipped${NC}"
    pip3 install rich requests beautifulsoup4 --break-system-packages 2>/dev/null || \
    pip3 install rich requests beautifulsoup4 2>/dev/null || log "${YELLOW}[!] pip3 install skipped${NC}"
fi

# --- STEP 3: Install Kali Linux Tools ---
log "\n${YELLOW}[*] Installing Kali Linux Security Tools...${NC}"

KALI_TOOLS=(
    "nmap" "masscan" "sqlmap" "nikto" "hydra" "john" "hashcat"
    "aircrack-ng" "wireshark" "metasploit-framework" "burpsuite" "zaproxy"
    "ghidra" "radare2" "binwalk" "steghide" "exiftool" "gobuster"
    "dirbuster" "wpscan" "dnsenum" "dnsmap" "fierce" "whois"
    "netcat-openbsd" "socat" "tcpdump" "tshark" "mitmproxy"
    "hoppy" "proxychains" "privesc" "kernel-exploits"
)

install_tool() {
    local tool=$1
    if command -v "$tool" >/dev/null 2>&1; then
        log "${GREEN}[+] $tool already installed${NC}"
    else
        log "${BLUE}[*] Installing $tool...${NC}"
        
        if [ "$PKG_MANAGER" = "apt" ]; then
            $INSTALL_CMD "$tool" 2>/dev/null || log "${YELLOW}[!] Failed to install $tool${NC}"
        elif [ "$PKG_MANAGER" = "pacman" ]; then
            $INSTALL_CMD "$tool" 2>/dev/null || log "${YELLOW}[!] Failed to install $tool${NC}"
        elif [ "$PKG_MANAGER" = "dnf" ] || [ "$PKG_MANAGER" = "yum" ]; then
            $INSTALL_CMD "$tool" 2>/dev/null || log "${YELLOW}[!] Failed to install $tool${NC}"
        elif [ "$PKG_MANAGER" = "brew" ]; then
            brew install "$tool" 2>/dev/null || log "${YELLOW}[!] Failed to install $tool${NC}"
        elif [ "$PKG_MANAGER" = "pkg" ]; then
            pkg install "$tool" -y 2>/dev/null || log "${YELLOW}[!] Failed to install $tool${NC}"
        fi
    fi
}

for tool in "${KALI_TOOLS[@]}"; do
    install_tool "$tool"
done

# --- STEP 4: Install DevOps Tools ---
log "\n${YELLOW}[*] Installing DevOps & Infrastructure Tools...${NC}"

DEVOPS_TOOLS=(
    "docker.io" "docker-compose" "git" "curl" "wget" "jq" "yq"
    "htop" "tmux" "vim" "nano" "openssh-client" "openssh-server"
    "telnet" "traceroute" "net-tools" "dnsutils" "postgresql"
    "mysql-server" "mongodb" "redis-server" "sqlite3"
)

for tool in "${DEVOPS_TOOLS[@]}"; do
    install_tool "$tool"
done

# --- STEP 5: Install Cloud CLI Tools ---
log "\n${YELLOW}[*] Installing Cloud CLI Tools...${NC}"

# AWS CLI
if ! command -v aws >/dev/null 2>&1; then
    log "${BLUE}[*] Installing AWS CLI...${NC}"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" 2>/dev/null
    if [ -f "/tmp/awscliv2.zip" ]; then
        unzip -q /tmp/awscliv2.zip -d /tmp 2>/dev/null
        sudo /tmp/aws/install 2>/dev/null || log "${YELLOW}[!] AWS CLI install skipped${NC}"
        rm -rf /tmp/aws /tmp/awscliv2.zip
    fi
fi

# Google Cloud SDK
if ! command -v gcloud >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Google Cloud SDK...${NC}"
    if [ "$OS_TYPE" = "linux" ]; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 2>/dev/null
        sudo apt-get update && sudo apt-get install -y google-cloud-sdk 2>/dev/null || \
        log "${YELLOW}[!] Google Cloud SDK install skipped${NC}"
    fi
fi

# Azure CLI
if ! command -v az >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Azure CLI...${NC}"
    if [ "$OS_TYPE" = "linux" ]; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 2>/dev/null || \
        log "${YELLOW}[!] Azure CLI install skipped${NC}"
    fi
fi

# --- STEP 6: Install Programming Languages ---
log "\n${YELLOW}[*] Installing Programming Languages...${NC}"

# Node.js
if ! command -v node >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Node.js...${NC}"
    if [ "$OS_TYPE" = "linux" ]; then
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - 2>/dev/null
        sudo apt-get install -y nodejs 2>/dev/null || log "${YELLOW}[!] Node.js install skipped${NC}"
    elif [ "$OS_TYPE" = "macos" ]; then
        brew install node 2>/dev/null || log "${YELLOW}[!] Node.js install skipped${NC}"
    fi
fi

# Go
if ! command -v go >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Go...${NC}"
    GO_VERSION="1.21.0"
    GO_OS="linux"
    GO_ARCH="amd64"
    [ "$OS_TYPE" = "macos" ] && GO_OS="darwin"
    
    wget -q https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz -O /tmp/go.tar.gz 2>/dev/null
    if [ -f "/tmp/go.tar.gz" ]; then
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>/dev/null
        rm -f /tmp/go.tar.gz
        log "${GREEN}[+] Go installed${NC}"
    fi
fi

# Rust
if ! command -v rustc >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Rust...${NC}"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null || \
    log "${YELLOW}[!] Rust install skipped${NC}"
fi

# Ruby
install_tool "ruby"

# --- STEP 7: Install Python Packages ---
log "\n${YELLOW}[*] Installing Python Security & Dev Packages...${NC}"

PYTHON_PACKAGES=(
    "paramiko" "requests" "beautifulsoup4" "scrapy" "cryptography"
    "pycryptodome" "shodan" "censys" "netaddr" "dnspython"
    "pwntools" "scapy" "impacket" "jinja2" "flask" "django"
    "sqlalchemy" "pytest" "numpy" "pandas" "matplotlib"
)

for pkg in "${PYTHON_PACKAGES[@]}"; do
    pip3 install "$pkg" 2>/dev/null || log "${YELLOW}[!] Failed to install $pkg${NC}"
done

# --- STEP 8: Install Node.js Tools ---
log "\n${YELLOW}[*] Installing Node.js Global Tools...${NC}"

if command -v npm >/dev/null 2>&1; then
    npm install -g http-server eslint pm2 webpack mocha 2>/dev/null || \
    log "${YELLOW}[!] Some npm packages failed${NC}"
fi

# --- STEP 9: Install Kubernetes Tools ---
log "\n${YELLOW}[*] Installing Kubernetes Tools...${NC}"

if ! command -v kubectl >/dev/null 2>&1; then
    log "${BLUE}[*] Installing kubectl...${NC}"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 2>/dev/null
    if [ -f "kubectl" ]; then
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm -f kubectl
    fi
fi

if ! command -v helm >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Helm...${NC}"
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>/dev/null || \
    log "${YELLOW}[!] Helm install skipped${NC}"
fi

# --- STEP 10: Install Terraform & Ansible ---
log "\n${YELLOW}[*] Installing Infrastructure as Code Tools...${NC}"

if ! command -v terraform >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Terraform...${NC}"
    TERRAFORM_VERSION="1.6.0"
    TERRAFORM_OS="linux"
    TERRAFORM_ARCH="amd64"
    [ "$OS_TYPE" = "macos" ] && TERRAFORM_OS="darwin"
    
    wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}_${TERRAFORM_ARCH}.zip \
    -O /tmp/terraform.zip 2>/dev/null
    if [ -f "/tmp/terraform.zip" ]; then
        unzip -q /tmp/terraform.zip -d /tmp
        sudo mv /tmp/terraform /usr/local/bin/
        rm -f /tmp/terraform.zip
    fi
fi

if ! command -v ansible >/dev/null 2>&1; then
    log "${BLUE}[*] Installing Ansible...${NC}"
    pip3 install --user ansible 2>/dev/null || log "${YELLOW}[!] Ansible install skipped${NC}"
fi

# --- STEP 11: Download Security Wordlists & Resources ---
log "\n${YELLOW}[*] Downloading Security Wordlists & Exploit Database...${NC}"

mkdir -p "$TOOL_DIR/tools" 2>/dev/null || true

REPOS=(
    "https://github.com/danielmiessler/SecLists.git:seclists"
    "https://github.com/projectdiscovery/nuclei-templates.git:nuclei-templates"
    "https://github.com/offensive-security/exploit-database.git:exploitdb"
    "https://github.com/Dewalt-arch/pimpmykali.git:pimpmykali"
)

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r url name <<< "$repo_info"
    log "${BLUE}[*] Cloning $name...${NC}"
    git clone --depth 1 "$url" "$TOOL_DIR/tools/$name" 2>/dev/null && \
    log "${GREEN}[+] $name cloned${NC}" || log "${YELLOW}[!] Failed to clone $name${NC}"
done

# --- STEP 12: Clone or Update Tool-X Repo ---
log "\n${YELLOW}[*] Setting up Tool-X Repository...${NC}"

if [ -d "$TOOL_DIR/.git" ]; then
    log "${BLUE}[*] Updating Tool-X Repository...${NC}"
    cd "$TOOL_DIR" || exit
    git pull 2>/dev/null || log "${YELLOW}[!] git pull failed${NC}"
else
    log "${BLUE}[*] Cloning Tool-X Repository...${NC}"
    git clone "$REPO_URL" "$TOOL_DIR" 2>/dev/null || log "${YELLOW}[!] git clone failed${NC}"
    cd "$TOOL_DIR" || exit
fi

chmod +x "$INSTALLER_SCRIPT" 2>/dev/null || true

# --- STEP 13: Create Global Commands ---
log "\n${YELLOW}[*] Centralizing Commands for Global Access...${NC}"

create_wrapper() {
    local cmd=$1
    local wrapper_code=$2
    
    if [ "$OS_TYPE" = "windows" ]; then
        echo "@echo off" > "$TOOL_DIR/$cmd.bat"
        echo "python \"$TOOL_DIR/$INSTALLER_SCRIPT\" %*" >> "$TOOL_DIR/$cmd.bat"
    else
        if [ "$OS_TYPE" = "termux" ]; then
            echo -e "$wrapper_code" > "$BIN_DIR/$cmd"
            chmod +x "$BIN_DIR/$cmd"
        else
            echo -e "$wrapper_code" | sudo tee "$BIN_DIR/$cmd" > /dev/null 2>&1 || \
            echo -e "$wrapper_code" > "$BIN_DIR/$cmd" 2>/dev/null
            sudo chmod +x "$BIN_DIR/$cmd" 2>/dev/null || chmod +x "$BIN_DIR/$cmd" 2>/dev/null
        fi
    fi
}

for cmd in "${COMMANDS[@]}"; do
    WRAPPER="#!/bin/bash\npython3 \"$TOOL_DIR/$INSTALLER_SCRIPT\" \"\$@\""
    create_wrapper "$cmd" "$WRAPPER"
done

log "${GREEN}[+] Commands created in $BIN_DIR${NC}"

# --- STEP 14: Shell Integration ---
log "\n${YELLOW}[*] Setting up Shell Integration...${NC}"

SHELL_RC="$HOME/.bashrc"
[ -n "$ZSH_VERSION" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "Tool-X" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'SHELL_CONFIG'

# ============ Tool-X Environment ==============
export PATH="/usr/local/bin:$PATH"
export TOOL_X_HOME="$HOME/tool-x"
export TOOL_X_TOOLS="$TOOL_X_HOME/tools"

alias toolx='python3 $TOOL_X_HOME/tool-x.py'
alias ll='ls -lah'

# ==============================================
SHELL_CONFIG
    
    log "${GREEN}[+] Shell integration added${NC}"
fi

# --- STEP 15: Generate Installation Report ---
log "\n${YELLOW}[*] Generating Installation Report...${NC}"

REPORT_FILE="$TOOL_DIR/INSTALLATION_REPORT.txt"
cat > "$REPORT_FILE" << EOF
╔═══════════════════════════════════════════════════════════════╗
║         TOOL-X v3.0 Installation Report                       ║
║         Generated: $(date)                      ║
╚═══════════════════════════════════════════════════════════════╝

SYSTEM INFORMATION:
  OS Type:           $OS_TYPE
  Package Manager:   $PKG_MANAGER
  Home Directory:    $TOOL_DIR
  Binary Location:   $BIN_DIR

INSTALLED CATEGORIES:
  ✓ Kali Linux Security Tools
  ✓ DevOps & Infrastructure Tools
  ✓ Cloud Platform CLIs (AWS, GCP, Azure)
  ✓ Programming Languages (Python, Node, Go, Rust, Ruby)
  ✓ Database Systems (PostgreSQL, MySQL, MongoDB, Redis)
  ✓ Development Tools (Docker, Kubernetes, Terraform, Ansible)
  ✓ Python Security Packages
  ✓ Node.js Global Tools
  ✓ Security Wordlists & Exploit Database

COMMANDS AVAILABLE:
  $(echo "  → ${COMMANDS[@]}")

NEXT STEPS:
  1. Reload shell:     source ~/.bashrc (or ~/.zshrc)
  2. Verify setup:     toolx --help
  3. View tool docs:   ls -la \$TOOL_X_TOOLS
  4. Check logs:       tail -f $LOG_FILE

TOOL DIRECTORIES:
  Main:               $TOOL_DIR
  Tools/Resources:    $TOOL_DIR/tools
  Logs:               $LOG_FILE

SECURITY RESOURCES LOCATION:
  SecLists:           $TOOL_DIR/tools/seclists
  Nuclei Templates:   $TOOL_DIR/tools/nuclei-templates
  Exploit Database:   $TOOL_DIR/tools/exploitdb

SUPPORT:
  GitHub:             https://github.com/dannywise093-crypto/Tool-X
  Issues:             Report bugs and request features

Generated on: $(date)
EOF

cat "$REPORT_FILE"

# --- Completion ---
log "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
log "${GREEN}   ✓ Tool-X v3.0 Installation Complete! ${NC}"
log "${GREEN}════════════════════════════════════════════════════════════${NC}"
log "\n${CYAN}Next Step: ${YELLOW}source ~/.bashrc${NC}${CYAN} and run ${YELLOW}toolx${NC}\n"
log "${YELLOW}Supported Commands: ${COMMANDS[*]}${NC}\n"

if [ "$OS_TYPE" = "windows" ]; then
    log "${RED}[!] Windows Note: Add '$TOOL_DIR' to System PATH for CMD/PowerShell${NC}\n"
fi

log "${BLUE}Installation logs saved to: $LOG_FILE${NC}\n"
