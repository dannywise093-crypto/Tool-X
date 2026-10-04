#!/bin/bash
################################################################################
# Tool-X v5.0 - Universal Multi-Platform Toolkit Installer
# Author: Danny Wise
# Date: 2026-10-04
#
# Features:
# - Auto-detect platform and install platform-specific tools
# - Windows: VSCode + Git + DevTools
# - Android (Termux): Micro editor + Security tools
# - iOS (iSH): Alpine-compatible tools
# - Linux/macOS: Full ecosystem
# - Kali Linux tools, Cloud, DevOps, AI/ML, Web3
# - One command, everything installed automatically
################################################################################

set -o pipefail

# === GLOBAL CONFIG ===
TOOL_X_HOME="${HOME}/.tool-x"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
TOOL_X_MODULES="${TOOL_X_HOME}/modules"
TOOL_X_CONFIG="${TOOL_X_HOME}/config"
TOOL_X_LOGS="${TOOL_X_HOME}/logs"
TOOL_X_CACHE="${TOOL_X_HOME}/cache"
LOG_FILE="${TOOL_X_LOGS}/install-$(date +%Y%m%d_%H%M%S).log"
REPO_URL="https://github.com/dannywise093-crypto/Tool-X"

# === COLORS ===
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
PURPLE='\033[1;35m'
MAGENTA='\033[1;35m'
WHITE='\033[1;37m'
NC='\033[0m'

# === COMMAND VARIATIONS ===
COMMANDS=("toolx" "tool-x" "Tool-X" "TOOLX")

# === COUNTERS ===
INSTALLED=0
FAILED=0
SKIPPED=0

# === PLATFORM DETECTION ===
PLATFORM=""
OS_TYPE=""
PKG_MANAGER=""
BIN_DIR=""
IS_WINDOWS=false
IS_ANDROID=false
IS_IOS=false
IS_LINUX=false
IS_MACOS=false

################################################################################
# UTILITY FUNCTIONS
################################################################################

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_status() {
    log "${BLUE}[*]${NC} $1"
}

log_success() {
    log "${GREEN}[✓]${NC} $1"
    ((INSTALLED++))
}

log_warning() {
    log "${YELLOW}[!]${NC} $1"
    ((SKIPPED++))
}

log_error() {
    log "${RED}[✗]${NC} $1"
    ((FAILED++))
}

print_banner() {
    clear
    log "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║                  ${PURPLE}⚔️  TOOL-X v5.0 MULTI-PLATFORM  ⚔️${CYAN}       ║
║        Universal Toolkit for All Platforms & Devices            ║
║                                                                  ║
║  Windows | macOS | Linux | Kali | Android | iOS | Cloud | Web3  ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    log "${NC}"
}

################################################################################
# PLATFORM DETECTION
################################################################################

detect_platform() {
    log_status "Detecting platform and device type..."
    
    # Check for Android/Termux
    if [ -d "$PREFIX" ] && grep -q "com.termux" "$PREFIX/etc/bash.bashrc" 2>/dev/null; then
        PLATFORM="termux"
        OS_TYPE="android"
        PKG_MANAGER="pkg"
        BIN_DIR="$PREFIX/bin"
        IS_ANDROID=true
        log_success "Android (Termux) detected"
        return
    fi
    
    # Check for iOS (iSH)
    if [ -f /etc/os-release ] && grep -q "iSH" /etc/os-release 2>/dev/null; then
        PLATFORM="ish"
        OS_TYPE="ios"
        PKG_MANAGER="apk"
        BIN_DIR="/usr/local/bin"
        IS_IOS=true
        log_success "iOS (iSH) detected"
        return
    fi
    
    # Check for Windows (Git Bash/MSYS2/WSL)
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        PLATFORM="windows"
        OS_TYPE="windows"
        IS_WINDOWS=true
        log_success "Windows detected"
        return
    fi
    
    # Check for macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        OS_TYPE="macos"
        PKG_MANAGER="brew"
        BIN_DIR="/usr/local/bin"
        IS_MACOS=true
        log_success "macOS (Homebrew) detected"
        return
    fi
    
    # Check for Linux distributions
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
        OS_TYPE="linux"
        BIN_DIR="/usr/local/bin"
        IS_LINUX=true
        
        if command -v apt-get &>/dev/null; then
            PKG_MANAGER="apt"
            log_success "Debian/Ubuntu/Kali detected"
        elif command -v pacman &>/dev/null; then
            PKG_MANAGER="pacman"
            log_success "Arch/Manjaro detected"
        elif command -v dnf &>/dev/null; then
            PKG_MANAGER="dnf"
            log_success "Fedora/RHEL detected"
        elif command -v yum &>/dev/null; then
            PKG_MANAGER="yum"
            log_success "Legacy RedHat detected"
        elif command -v apk &>/dev/null; then
            PKG_MANAGER="apk"
            log_success "Alpine detected"
        else
            PKG_MANAGER="unknown"
            log_warning "Unknown Linux distro"
        fi
        return
    fi
    
    log_error "Unknown platform: $OSTYPE"
    exit 1
}

################################################################################
# ENVIRONMENT INITIALIZATION
################################################################################

init_environment() {
    log_status "Initializing Tool-X environment..."
    mkdir -p "$TOOL_X_HOME"/{bin,tools,modules,config,logs,cache,data,scripts}
    log_success "Directory structure created"
}

install_package() {
    local pkg=$1
    local alt_name=$2
    
    if command -v "$pkg" &>/dev/null || command -v "$alt_name" &>/dev/null 2>&1; then
        log_success "$pkg (already installed)"
        return 0
    fi
    
    log_status "Installing $pkg..."
    
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get install -y "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        pacman)
            sudo pacman -S --noconfirm "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        dnf)
            sudo dnf install -y "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        yum)
            sudo yum install -y "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        brew)
            brew install "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        pkg)
            pkg install "$pkg" -y 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        apk)
            sudo apk add "$pkg" 2>/dev/null && log_success "$pkg" || log_warning "$pkg"
            ;;
        *)
            log_warning "$pkg (unsupported pkg manager)"
            ;;
    esac
}

################################################################################
# PLATFORM-SPECIFIC INSTALLERS
################################################################################

# === WINDOWS SPECIFIC ===
install_windows_tools() {
    log_status "Installing Windows-specific tools..."
    
    # VSCode
    if ! command -v code &>/dev/null; then
        log_status "Installing Visual Studio Code..."
        
        # Check if Windows
        if [[ "$OS" == "Windows_NT" ]] || [[ "$OSTYPE" == "msys" ]]; then
            # Use scoop or chocolatey if available
            if command -v choco &>/dev/null; then
                choco install vscode -y 2>/dev/null && log_success "VSCode installed" || log_warning "VSCode"
            elif command -v scoop &>/dev/null; then
                scoop install vscode 2>/dev/null && log_success "VSCode installed" || log_warning "VSCode"
            else
                log_warning "VSCode - install from https://code.visualstudio.com"
            fi
        fi
    else
        log_success "VSCode (already installed)"
    fi
    
    # Git
    install_package "git"
    
    # Python
    if ! command -v python &>/dev/null && ! command -v python3 &>/dev/null; then
        log_warning "Python - install from https://www.python.org"
    else
        log_success "Python (already installed)"
    fi
    
    # Node.js
    if ! command -v node &>/dev/null; then
        log_warning "Node.js - install from https://nodejs.org"
    else
        log_success "Node.js (already installed)"
    fi
}

# === ANDROID (TERMUX) SPECIFIC ===
install_android_tools() {
    log_status "Installing Android (Termux) specific tools..."
    
    # Update Termux
    log_status "Updating Termux packages..."
    pkg update -y 2>/dev/null || log_warning "pkg update"
    
    # Micro editor
    if ! command -v micro &>/dev/null; then
        log_status "Installing Micro text editor..."
        pkg install micro -y 2>/dev/null && log_success "Micro" || log_warning "Micro"
    else
        log_success "Micro (already installed)"
    fi
    
    # Core tools
    local tools=(
        "git" "curl" "wget" "python" "python-pip"
        "openssh" "openssl" "vim" "nano" "jq"
        "nmap" "hydra" "sqlmap" "metasploit"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
    
    # Security tools for Android
    log_status "Installing Android security toolkit..."
    pkg install termux-api termux-tools -y 2>/dev/null || log_warning "Termux API tools"
}

# === iOS (iSH) SPECIFIC ===
install_ios_tools() {
    log_status "Installing iOS (iSH) specific tools..."
    
    # Update Alpine
    log_status "Updating Alpine packages..."
    sudo apk update 2>/dev/null || log_warning "apk update"
    
    # Micro editor
    if ! command -v micro &>/dev/null; then
        log_status "Installing Micro text editor..."
        sudo apk add micro 2>/dev/null && log_success "Micro" || log_warning "Micro"
    else
        log_success "Micro (already installed)"
    fi
    
    # Core tools (Alpine compatible)
    local tools=(
        "git" "curl" "wget" "python3" "py3-pip"
        "openssh" "openssl" "vim" "nano" "jq"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
}

# === LINUX/MACOS SPECIFIC ===
install_linux_macos_tools() {
    log_status "Installing Linux/macOS tools..."
    
    # VSCode for Linux/macOS
    if ! command -v code &>/dev/null; then
        log_status "Installing Visual Studio Code..."
        
        if [ "$OS_TYPE" = "linux" ]; then
            curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg 2>/dev/null
            sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ 2>/dev/null
            sudo sh -c 'echo "deb [arch=amd64,arm64 signed-by=/etc/apt/trusted.gpg.d/microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' 2>/dev/null
            sudo apt-get update && sudo apt-get install -y code 2>/dev/null && log_success "VSCode" || log_warning "VSCode"
        elif [ "$OS_TYPE" = "macos" ]; then
            brew install --cask visual-studio-code 2>/dev/null && log_success "VSCode" || log_warning "VSCode"
        fi
    else
        log_success "VSCode (already installed)"
    fi
    
    # Core development tools
    log_status "Installing core development tools..."
    local core_tools=(
        "git" "curl" "wget" "build-essential" "python3" "python3-pip"
        "nodejs" "npm" "vim" "nano" "jq" "htop" "tmux"
    )
    
    for tool in "${core_tools[@]}"; do
        install_package "$tool"
    done
}

################################################################################
# UNIVERSAL TOOL INSTALLATION
################################################################################

update_system() {
    log_status "Updating package manager..."
    
    case "$PKG_MANAGER" in
        apt)
            sudo apt-get update -y 2>/dev/null && sudo apt-get upgrade -y 2>/dev/null
            ;;
        pacman)
            sudo pacman -Sy --noconfirm 2>/dev/null
            ;;
        dnf)
            sudo dnf check-update -y 2>/dev/null && sudo dnf upgrade -y 2>/dev/null
            ;;
        yum)
            sudo yum check-update -y 2>/dev/null && sudo yum upgrade -y 2>/dev/null
            ;;
        brew)
            brew update 2>/dev/null && brew upgrade 2>/dev/null
            ;;
        pkg)
            pkg update -y 2>/dev/null
            ;;
        apk)
            sudo apk update 2>/dev/null && sudo apk upgrade 2>/dev/null
            ;;
    esac
    
    log_success "Package manager updated"
}

install_kali_tools() {
    log_status "Installing Kali Linux Security Tools..."
    
    # Skip on iOS/Android if minimal
    if [ "$IS_IOS" = true ] || [ "$IS_ANDROID" = true ]; then
        log_warning "Skipping full Kali suite on mobile platform"
        return
    fi
    
    local tools=(
        "nmap" "masscan" "whois" "dnsmap" "dnsenum" "fierce"
        "nikto" "gobuster" "sqlmap" "zaproxy"
        "metasploit-framework" "burpsuite" "hydra" "john" "hashcat"
        "wireshark" "tcpdump" "aircrack-ng"
        "ghidra" "radare2" "binwalk" "exiftool"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
}

install_cloud_tools() {
    log_status "Installing Cloud Platform Tools..."
    
    # Skip on mobile platforms
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_warning "Skipping cloud tools on mobile platform"
        return
    fi
    
    # AWS CLI
    if ! command -v aws &>/dev/null; then
        log_status "Installing AWS CLI v2..."
        curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" 2>/dev/null
        if [ -f "/tmp/awscliv2.zip" ]; then
            unzip -q /tmp/awscliv2.zip -d /tmp 2>/dev/null
            sudo /tmp/aws/install 2>/dev/null && log_success "AWS CLI" || log_warning "AWS CLI"
            rm -rf /tmp/aws /tmp/awscliv2.zip
        fi
    else
        log_success "AWS CLI (already installed)"
    fi
}

install_devops_tools() {
    log_status "Installing DevOps Tools..."
    
    # Skip on mobile
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_warning "Skipping DevOps tools on mobile platform"
        return
    fi
    
    # Docker
    if ! command -v docker &>/dev/null; then
        log_status "Installing Docker..."
        if [ "$IS_LINUX" = true ]; then
            curl -fsSL https://get.docker.com | bash 2>/dev/null && log_success "Docker" || log_warning "Docker"
        else
            install_package "docker"
        fi
    else
        log_success "Docker (already installed)"
    fi
    
    # Kubernetes
    if ! command -v kubectl &>/dev/null; then
        log_status "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 2>/dev/null
        if [ -f "kubectl" ]; then
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm -f kubectl
            log_success "kubectl"
        fi
    else
        log_success "kubectl (already installed)"
    fi
}

install_programming_languages() {
    log_status "Installing Programming Languages..."
    
    # Python
    if ! command -v python3 &>/dev/null; then
        install_package "python3"
    else
        log_success "Python 3 (already installed)"
    fi
    
    install_package "python3-pip"
    
    # Node.js
    if ! command -v node &>/dev/null; then
        if [ "$IS_LINUX" = true ] && command -v apt-get &>/dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_20.x 2>/dev/null | sudo -E bash - 2>/dev/null
        fi
        install_package "nodejs"
    else
        log_success "Node.js (already installed)"
    fi
    
    # Go (skip on mobile)
    if [ "$IS_ANDROID" = false ] && [ "$IS_IOS" = false ]; then
        if ! command -v go &>/dev/null; then
            log_status "Installing Go..."
            GO_VERSION="1.21.3"
            GO_OS="linux"
            GO_ARCH="amd64"
            
            wget -q "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz 2>/dev/null
            if [ -f "/tmp/go.tar.gz" ]; then
                sudo rm -rf /usr/local/go
                sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>/dev/null
                rm -f /tmp/go.tar.gz
                log_success "Go"
            fi
        else
            log_success "Go (already installed)"
        fi
    fi
    
    # Rust (skip on mobile)
    if [ "$IS_ANDROID" = false ] && [ "$IS_IOS" = false ]; then
        if ! command -v rustc &>/dev/null; then
            log_status "Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs 2>/dev/null | sh -s -- -y 2>/dev/null && \
            log_success "Rust" || log_warning "Rust"
        else
            log_success "Rust (already installed)"
        fi
    fi
}

install_databases() {
    log_status "Installing Database Systems..."
    
    # Skip on mobile
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_warning "Skipping databases on mobile platform"
        return
    fi
    
    local databases=(
        "postgresql" "mysql-server" "mongodb" "redis-server" "sqlite3"
    )
    
    for db in "${databases[@]}"; do
        install_package "$db"
    done
}

install_python_packages() {
    log_status "Installing Python Packages..."
    
    python3 -m pip install --upgrade pip 2>/dev/null || true
    
    local packages=(
        "paramiko" "requests" "beautifulsoup4" "cryptography"
        "flask" "django" "pytest" "numpy" "pandas"
        "rich" "click" "colorama"
    )
    
    for pkg in "${packages[@]}"; do
        python3 -m pip install "$pkg" 2>/dev/null || log_warning "Python: $pkg"
    done
}

install_ai_ml_tools() {
    log_status "Installing AI/ML Tools..."
    
    # Skip on mobile/limited resources
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_warning "Skipping AI/ML tools on mobile platform"
        return
    fi
    
    python3 -m pip install jupyter jupyterlab 2>/dev/null || log_warning "Jupyter"
    python3 -m pip install transformers datasets 2>/dev/null || log_warning "Hugging Face"
}

install_web3_tools() {
    log_status "Installing Web3 Tools..."
    
    # Skip on mobile
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_warning "Skipping Web3 tools on mobile platform"
        return
    fi
    
    if command -v npm &>/dev/null; then
        npm install -g hardhat 2>/dev/null || log_warning "Hardhat"
        npm install -g truffle 2>/dev/null || log_warning "Truffle"
    fi
    
    python3 -m pip install web3 2>/dev/null || log_warning "web3.py"
}

download_security_resources() {
    log_status "Downloading Security Resources..."
    
    mkdir -p "$TOOL_X_TOOLS"
    cd "$TOOL_X_TOOLS" || exit
    
    # For mobile, only download lightweight resources
    if [ "$IS_ANDROID" = true ] || [ "$IS_IOS" = true ]; then
        log_status "Downloading mobile-friendly security resources..."
        git clone --depth 1 https://github.com/swisskyrepo/PayloadsAllTheThings.git 2>/dev/null && \
        log_success "PayloadsAllTheThings" || log_warning "PayloadsAllTheThings"
    else
        log_status "Downloading full security resources..."
        
        local repos=(
            "https://github.com/danielmiessler/SecLists.git:SecLists"
            "https://github.com/projectdiscovery/nuclei-templates.git:nuclei-templates"
            "https://github.com/swisskyrepo/PayloadsAllTheThings.git:PayloadsAllTheThings"
        )
        
        for repo_info in "${repos[@]}"; do
            IFS=':' read -r url name <<< "$repo_info"
            git clone --depth 1 "$url" "$name" 2>/dev/null && \
            log_success "$name" || log_warning "$name"
        done
    fi
}

################################################################################
# COMMAND & SHELL SETUP
################################################################################

create_toolx_command() {
    log_status "Creating Tool-X main command..."
    
    cat > "${TOOL_X_BIN}/toolx-main" << 'TOOLXEOF'
#!/bin/bash

TOOL_X_HOME="${HOME}/.tool-x"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"

show_help() {
    cat << 'HELP'
╔══════════════════════════════════════════════════════════════╗
║                   TOOL-X v5.0 Command Menu                  ║
║            Multi-Platform Universal Toolkit                  ║
╚══════════════════════════════════════════════════════════════╝

SECURITY:
  toolx recon              Reconnaissance tools
  toolx scan               Vulnerability scanning
  toolx exploit            Exploitation frameworks
  toolx crypto             Cryptography & hashing

DEVOPS:
  toolx docker             Docker management
  toolx k8s                Kubernetes operations
  toolx cloud              Cloud CLI tools

DEVELOPMENT:
  toolx python             Python environment
  toolx nodejs             Node.js tools
  toolx code               Visual Studio Code

SYSTEM:
  toolx status             Installation status
  toolx help               Show this help

HELP
}

case "${1}" in
    recon|scan|exploit|crypto) echo "🔓 Security: $1" ;;
    docker|k8s|cloud) echo "⚙️  DevOps: $1" ;;
    python|nodejs|code) echo "💻 Development: $1" ;;
    status) echo "Tool-X: ${TOOL_X_HOME}" ;;
    help|"") show_help ;;
    *) echo "Unknown: $1"; show_help; exit 1 ;;
esac
TOOLXEOF
    
    chmod +x "${TOOL_X_BIN}/toolx-main"
    log_success "Tool-X command created"
}

create_global_commands() {
    log_status "Creating global command wrappers..."
    
    for cmd in "${COMMANDS[@]}"; do
        if [ "$IS_ANDROID" = true ]; then
            echo "#!/bin/bash" > "$BIN_DIR/$cmd"
            echo "exec ${TOOL_X_BIN}/toolx-main \"\$@\"" >> "$BIN_DIR/$cmd"
            chmod +x "$BIN_DIR/$cmd"
        else
            echo "#!/bin/bash" | sudo tee "$BIN_DIR/$cmd" > /dev/null 2>&1
            echo "exec ${TOOL_X_BIN}/toolx-main \"\$@\"" | sudo tee -a "$BIN_DIR/$cmd" > /dev/null 2>&1
            sudo chmod +x "$BIN_DIR/$cmd" 2>/dev/null
        fi
    done
    
    log_success "Global commands created"
}

setup_shell_integration() {
    log_status "Setting up shell integration..."
    
    local rc_file="$HOME/.bashrc"
    [ -n "$ZSH_VERSION" ] && rc_file="$HOME/.zshrc"
    
    if ! grep -q "Tool-X" "$rc_file" 2>/dev/null; then
        cat >> "$rc_file" << 'SHELL_CONFIG'

# ==================== Tool-X v5.0 ====================
export TOOL_X_HOME="$HOME/.tool-x"
export TOOL_X_BIN="${TOOL_X_HOME}/bin"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export PATH="${TOOL_X_BIN}:${PATH}"

alias toolx='${TOOL_X_BIN}/toolx-main'
alias ll='ls -lah'

# ======================================================
SHELL_CONFIG
        
        log_success "Shell integration added"
    fi
}

################################################################################
# REPORTING
################################################################################

generate_report() {
    log_status "Generating installation report..."
    
    local report="${TOOL_X_HOME}/INSTALLATION_REPORT.md"
    
    cat > "$report" << EOF
# Tool-X v5.0 Installation Report

**Generated:** $(date)
**Platform:** $PLATFORM ($OS_TYPE)
**Package Manager:** $PKG_MANAGER
**Home:** $TOOL_X_HOME

## Installation Summary

- **Successfully Installed:** $INSTALLED
- **Failed:** $FAILED
- **Skipped:** $SKIPPED

## Platform Details

- Windows Support: VSCode, Git, Developer Tools
- Android (Termux): Micro editor, Security tools
- iOS (iSH): Alpine-compatible tools
- Linux/macOS: Full ecosystem

## Tools Installed by Category

- Security Tools
- Cloud Platforms
- DevOps & Infrastructure
- Programming Languages
- Databases
- Python Packages
- AI/ML Tools
- Web3/Blockchain

## Quick Start

1. Reload shell: \`source ~/.bashrc\`
2. Check status: \`toolx status\`
3. View help: \`toolx help\`

## Support

GitHub: https://github.com/dannywise093-crypto/Tool-X

---
*Tool-X v5.0 - Multi-Platform Universal Toolkit*
EOF
    
    cat "$report"
    log_success "Report generated"
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    print_banner
    
    mkdir -p "$TOOL_X_LOGS"
    {
        log "Tool-X v5.0 Installation Started"
        log "Timestamp: $(date)"
        log "OSTYPE: $OSTYPE"
    } > "$LOG_FILE"
    
    # Core setup
    detect_platform
    init_environment
    update_system
    
    # Platform-specific installation
    if [ "$IS_WINDOWS" = true ]; then
        install_windows_tools
    elif [ "$IS_ANDROID" = true ]; then
        install_android_tools
    elif [ "$IS_IOS" = true ]; then
        install_ios_tools
    else
        install_linux_macos_tools
    fi
    
    # Universal installations (skipped on mobile as needed)
    install_kali_tools
    install_cloud_tools
    install_devops_tools
    install_programming_languages
    install_databases
    install_python_packages
    install_ai_ml_tools
    install_web3_tools
    download_security_resources
    
    # Finalization
    create_toolx_command
    create_global_commands
    setup_shell_integration
    generate_report
    
    # Completion
    log "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
    log "${GREEN}   ✓✓✓ Tool-X v5.0 Installation COMPLETE! ✓✓✓${NC}"
    log "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    log "${CYAN}Next Steps:${NC}"
    log "${YELLOW}1. Reload shell:${NC}     source ~/.bashrc"
    log "${YELLOW}2. Verify setup:${NC}     toolx status"
    log "${YELLOW}3. View help:${NC}        toolx help\n"
    
    log "${BLUE}Summary:${NC}"
    log "  Platform: $PLATFORM"
    log "  Installed: $INSTALLED | Failed: $FAILED | Skipped: $SKIPPED\n"
    
    log "${MAGENTA}GitHub: https://github.com/dannywise093-crypto/Tool-X${NC}\n"
}

# Execute
main "$@"
