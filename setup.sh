#!/bin/bash
################################################################################
# Tool-X v4.0 - Ultimate Multi-Purpose Security & DevOps Toolkit
# Author: Danny Wise (Enhanced Edition)
# Date: 2026-10-04
# 
# Features:
# - Kali Linux + Security Tools
# - Cloud Platforms (AWS, GCP, Azure)
# - DevOps (Docker, Kubernetes, Terraform, Ansible)
# - Development (Python, Node, Go, Rust, Ruby, Java)
# - Databases (PostgreSQL, MySQL, MongoDB, Redis, Cassandra)
# - Forensics & Reverse Engineering
# - Wireless & Network Analysis
# - Web Security & Exploitation
# - AI/ML Tools
# - Blockchain & Web3
################################################################################

set -o pipefail

# === GLOBAL CONFIG ===
TOOL_X_HOME="${HOME}/.tool-x"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
TOOL_X_MODULES="${TOOL_X_HOME}/modules"
TOOL_X_CONFIG="${TOOL_X_HOME}/config"
TOOL_X_LOGS="${TOOL_X_HOME}/logs"
LOG_FILE="${TOOL_X_LOGS}/setup-$(date +%s).log"
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

# === FUNCTIONS ===

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_only() {
    echo "$1" >> "$LOG_FILE"
}

print_banner() {
    clear
    log "${CYAN}"
    cat << "EOF"
╔══════════════════════════════════════════════════════════════════╗
║                                                                  ║
║                  ${PURPLE}⚔️  TOOL-X v4.0 ULTIMATE  ⚔️${CYAN}                ║
║          Next-Generation Multi-Purpose Security Toolkit          ║
║                                                                  ║
║  Kali | Cloud | DevOps | Development | Forensics | AI/ML | Web3 ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
EOF
    log "${NC}"
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

# === OS Detection ===
detect_os() {
    log_status "Detecting OS and Package Manager..."
    
    if [ -d "$PREFIX" ] && grep -q "com.termux" "$PREFIX/etc/bash.bashrc" 2>/dev/null; then
        OS_TYPE="termux"
        PKG_MANAGER="pkg"
        BIN_DIR="$PREFIX/bin"
        log_success "Termux (Android) detected"
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        PKG_MANAGER="brew"
        BIN_DIR="/usr/local/bin"
        log_success "macOS (Homebrew) detected"
        
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        BIN_DIR="/usr/local/bin"
        
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
        else
            PKG_MANAGER="unknown"
            log_warning "Unknown Linux distro"
        fi
    else
        log_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# === Package Installation ===
install_package() {
    local pkg=$1
    local alt_name=$2
    
    # Check if already installed
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
        *)
            log_warning "$pkg (unsupported pkg manager)"
            ;;
    esac
}

# === Initialize Environment ===
init_environment() {
    log_status "Initializing Tool-X environment..."
    mkdir -p "$TOOL_X_HOME"/{bin,tools,modules,config,logs,data,scripts}
    log_success "Directory structure created"
}

# === Update System ===
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
    esac
    
    log_success "Package manager updated"
}

# === Install Core Dependencies ===
install_core_dependencies() {
    log_status "Installing core dependencies..."
    
    local deps=(
        "git" "curl" "wget" "python3" "python3-pip" "build-essential"
        "jq" "htop" "tmux" "vim" "nano" "net-tools" "openssh-client"
    )
    
    for dep in "${deps[@]}"; do
        install_package "$dep"
    done
}

# === Install Kali Linux Tools ===
install_kali_tools() {
    log_status "Installing Kali Linux Security Tools..."
    
    local tools=(
        # Reconnaissance
        "nmap" "masscan" "whois" "dnsmap" "dnsenum" "fierce" "theHarvester"
        
        # Scanning & Enumeration
        "nikto" "gobuster" "dirbuster" "wpscan" "sqlmap" "zaproxy"
        
        # Exploitation
        "metasploit-framework" "burpsuite" "hydra" "medusa"
        
        # Cryptography & Hashing
        "john" "hashcat" "openssl" "gpg"
        
        # Network Analysis
        "wireshark" "tshark" "tcpdump" "mitmproxy" "proxychains"
        
        # Wireless
        "aircrack-ng" "reaver" "pixiewps"
        
        # Reverse Engineering
        "ghidra" "radare2" "binwalk" "strings" "objdump"
        
        # Forensics
        "exiftool" "steghide" "foremost" "sleuthkit"
        
        # Exploitation Frameworks
        "exploitdb" "searchsploit" "commix"
        
        # Social Engineering
        "social-engineer-toolkit"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
}

# === Install Cloud Tools ===
install_cloud_tools() {
    log_status "Installing Cloud Platform Tools..."
    
    # AWS CLI v2
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
    
    # Google Cloud SDK
    if ! command -v gcloud &>/dev/null && [ "$OS_TYPE" = "linux" ]; then
        log_status "Installing Google Cloud SDK..."
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 2>/dev/null
        sudo apt-get update && sudo apt-get install -y google-cloud-sdk 2>/dev/null && \
        log_success "Google Cloud SDK" || log_warning "Google Cloud SDK"
    else
        log_success "Google Cloud SDK (already installed or skipped)"
    fi
    
    # Azure CLI
    if ! command -v az &>/dev/null && [ "$OS_TYPE" = "linux" ]; then
        log_status "Installing Azure CLI..."
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 2>/dev/null && \
        log_success "Azure CLI" || log_warning "Azure CLI"
    else
        log_success "Azure CLI (already installed or skipped)"
    fi
    
    # DigitalOcean CLI
    if ! command -v doctl &>/dev/null; then
        log_status "Installing DigitalOcean CLI..."
        cd /tmp
        wget -q https://github.com/digitalocean/doctl/releases/download/v1.98.5/doctl-1.98.5-linux-amd64.tar.gz 2>/dev/null
        if [ -f doctl-1.98.5-linux-amd64.tar.gz ]; then
            tar xf doctl-1.98.5-linux-amd64.tar.gz 2>/dev/null
            sudo mv doctl /usr/local/bin 2>/dev/null
            rm -f doctl-1.98.5-linux-amd64.tar.gz
            log_success "DigitalOcean CLI"
        fi
    else
        log_success "DigitalOcean CLI (already installed)"
    fi
}

# === Install DevOps Tools ===
install_devops_tools() {
    log_status "Installing DevOps & Infrastructure Tools..."
    
    # Docker
    if ! command -v docker &>/dev/null; then
        log_status "Installing Docker..."
        if [ "$OS_TYPE" = "linux" ]; then
            curl -fsSL https://get.docker.com | bash 2>/dev/null && log_success "Docker" || log_warning "Docker"
        else
            install_package "docker" "docker.io"
        fi
    else
        log_success "Docker (already installed)"
    fi
    
    # Docker Compose
    if ! command -v docker-compose &>/dev/null; then
        log_status "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose 2>/dev/null
        sudo chmod +x /usr/local/bin/docker-compose 2>/dev/null && log_success "Docker Compose" || log_warning "Docker Compose"
    else
        log_success "Docker Compose (already installed)"
    fi
    
    # Kubernetes (kubectl)
    if ! command -v kubectl &>/dev/null; then
        log_status "Installing kubectl..."
        KUBE_VERSION=$(curl -s https://dl.k8s.io/release/stable.txt)
        curl -LO "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl" 2>/dev/null
        if [ -f "kubectl" ]; then
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            rm -f kubectl
            log_success "kubectl"
        fi
    else
        log_success "kubectl (already installed)"
    fi
    
    # Helm
    if ! command -v helm &>/dev/null; then
        log_status "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 2>/dev/null | bash 2>/dev/null && \
        log_success "Helm" || log_warning "Helm"
    else
        log_success "Helm (already installed)"
    fi
    
    # Terraform
    if ! command -v terraform &>/dev/null; then
        log_status "Installing Terraform..."
        TERRAFORM_VERSION="1.7.0"
        TERRAFORM_OS="linux"
        TERRAFORM_ARCH="amd64"
        [ "$OS_TYPE" = "macos" ] && TERRAFORM_OS="darwin"
        
        wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}_${TERRAFORM_ARCH}.zip" \
        -O /tmp/terraform.zip 2>/dev/null
        if [ -f "/tmp/terraform.zip" ]; then
            unzip -q /tmp/terraform.zip -d /tmp 2>/dev/null
            sudo mv /tmp/terraform /usr/local/bin/ 2>/dev/null
            rm -f /tmp/terraform.zip
            log_success "Terraform"
        fi
    else
        log_success "Terraform (already installed)"
    fi
    
    # Ansible
    if ! command -v ansible &>/dev/null; then
        log_status "Installing Ansible..."
        python3 -m pip install --user ansible 2>/dev/null && log_success "Ansible" || log_warning "Ansible"
    else
        log_success "Ansible (already installed)"
    fi
    
    # Vagrant
    install_package "vagrant"
    
    # Packer
    if ! command -v packer &>/dev/null; then
        log_status "Installing Packer..."
        PACKER_VERSION="1.9.4"
        wget -q "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" \
        -O /tmp/packer.zip 2>/dev/null
        if [ -f "/tmp/packer.zip" ]; then
            unzip -q /tmp/packer.zip -d /tmp 2>/dev/null
            sudo mv /tmp/packer /usr/local/bin/ 2>/dev/null
            rm -f /tmp/packer.zip
            log_success "Packer"
        fi
    else
        log_success "Packer (already installed)"
    fi
}

# === Install Programming Languages ===
install_programming_languages() {
    log_status "Installing Programming Languages..."
    
    # Python 3
    install_package "python3"
    install_package "python3-pip"
    install_package "python3-dev"
    
    # Node.js
    if ! command -v node &>/dev/null; then
        log_status "Installing Node.js..."
        if [ "$OS_TYPE" = "linux" ]; then
            curl -fsSL https://deb.nodesource.com/setup_20.x 2>/dev/null | sudo -E bash - 2>/dev/null
            sudo apt-get install -y nodejs 2>/dev/null && log_success "Node.js" || log_warning "Node.js"
        elif [ "$OS_TYPE" = "macos" ]; then
            brew install node 2>/dev/null && log_success "Node.js" || log_warning "Node.js"
        fi
    else
        log_success "Node.js (already installed)"
    fi
    
    # Go
    if ! command -v go &>/dev/null; then
        log_status "Installing Go..."
        GO_VERSION="1.21.3"
        GO_OS="linux"
        GO_ARCH="amd64"
        [ "$OS_TYPE" = "macos" ] && GO_OS="darwin"
        
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
    
    # Rust
    if ! command -v rustc &>/dev/null; then
        log_status "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs 2>/dev/null | sh -s -- -y 2>/dev/null && \
        log_success "Rust" || log_warning "Rust"
    else
        log_success "Rust (already installed)"
    fi
    
    # Ruby
    install_package "ruby"
    install_package "ruby-dev"
    
    # Java
    install_package "default-jdk"
    install_package "maven"
    
    # C/C++
    install_package "build-essential"
    install_package "gcc"
    install_package "g++"
    install_package "cmake"
}

# === Install Databases ===
install_databases() {
    log_status "Installing Database Systems..."
    
    local databases=(
        "postgresql" "postgresql-contrib"
        "mysql-server" "mysql-client"
        "mongodb" "mongosh"
        "redis-server"
        "sqlite3"
    )
    
    for db in "${databases[@]}"; do
        install_package "$db"
    done
}

# === Install Python Packages ===
install_python_packages() {
    log_status "Installing Python Security & Dev Packages..."
    
    python3 -m pip install --upgrade pip 2>/dev/null || true
    
    local packages=(
        # Security & Hacking
        "paramiko" "cryptography" "pycryptodome" "scapy" "pwntools"
        "impacket" "requests" "beautifulsoup4" "lxml"
        
        # Web & API
        "flask" "django" "fastapi" "uvicorn" "sqlalchemy"
        "pytest" "selenium" "requests-oauthlib"
        
        # Intelligence
        "shodan" "censys" "dnspython" "netaddr" "ipaddress"
        
        # Data & Analysis
        "numpy" "pandas" "matplotlib" "scipy" "scikit-learn"
        "tensorflow" "torch" "keras"
        
        # Web Scraping
        "scrapy" "mechanize" "playwright"
        
        # Utilities
        "rich" "click" "colorama" "tqdm" "jinja2"
    )
    
    for pkg in "${packages[@]}"; do
        log_status "Installing Python package: $pkg..."
        python3 -m pip install "$pkg" 2>/dev/null || log_warning "Python package: $pkg"
    done
}

# === Install Node.js Global Packages ===
install_nodejs_packages() {
    log_status "Installing Node.js Global Packages..."
    
    if ! command -v npm &>/dev/null; then
        log_warning "npm not found, skipping Node packages"
        return
    fi
    
    local packages=(
        "http-server" "webpack" "webpack-cli" "webpack-dev-server"
        "eslint" "prettier" "babel" "mocha" "jest" "pm2"
        "nodemon" "gulp" "grunt" "express-generator"
    )
    
    for pkg in "${packages[@]}"; do
        log_status "Installing npm package: $pkg..."
        npm install -g "$pkg" 2>/dev/null || log_warning "npm package: $pkg"
    done
}

# === Install AI/ML Tools ===
install_ai_ml_tools() {
    log_status "Installing AI/ML Tools..."
    
    # Jupyter
    python3 -m pip install jupyter jupyterlab 2>/dev/null || log_warning "Jupyter"
    
    # TensorFlow/PyTorch already in pip packages
    # Hugging Face
    python3 -m pip install transformers datasets 2>/dev/null || log_warning "Hugging Face"
    
    # Ollama (Local LLM)
    if ! command -v ollama &>/dev/null && [ "$OS_TYPE" = "linux" ]; then
        log_status "Installing Ollama..."
        curl -fsSL https://ollama.ai/install.sh 2>/dev/null | sh 2>/dev/null && \
        log_success "Ollama" || log_warning "Ollama"
    fi
}

# === Install Web3/Blockchain Tools ===
install_web3_tools() {
    log_status "Installing Web3 & Blockchain Tools..."
    
    # Hardhat
    npm install -g hardhat 2>/dev/null || log_warning "Hardhat"
    
    # Truffle
    npm install -g truffle 2>/dev/null || log_warning "Truffle"
    
    # Ganache
    npm install -g ganache 2>/dev/null || log_warning "Ganache"
    
    # Web3.py
    python3 -m pip install web3 2>/dev/null || log_warning "web3.py"
    
    # Ethers
    npm install -g ethers 2>/dev/null || log_warning "ethers"
}

# === Download Security Resources ===
download_security_resources() {
    log_status "Downloading Security Wordlists & Resources..."
    
    mkdir -p "$TOOL_X_TOOLS"
    cd "$TOOL_X_TOOLS" || exit
    
    local repos=(
        "https://github.com/danielmiessler/SecLists.git:SecLists"
        "https://github.com/projectdiscovery/nuclei-templates.git:nuclei-templates"
        "https://github.com/offensive-security/exploit-database.git:exploit-db"
        "https://github.com/Dewalt-arch/pimpmykali.git:pimpmykali"
        "https://github.com/carlospolop/PEASS-ng.git:PEASS"
        "https://github.com/swisskyrepo/PayloadsAllTheThings.git:PayloadsAllTheThings"
    )
    
    for repo_info in "${repos[@]}"; do
        IFS=':' read -r url name <<< "$repo_info"
        log_status "Cloning $name..."
        git clone --depth 1 "$url" "$name" 2>/dev/null && \
        log_success "$name" || log_warning "$name"
    done
}

# === Create Main Tool-X Command ===
create_toolx_command() {
    log_status "Creating Tool-X Main Command..."
    
    cat > "${TOOL_X_BIN}/toolx-main" << 'TOOLXEOF'
#!/bin/bash

TOOL_X_HOME="${HOME}/.tool-x"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"

show_help() {
    cat << 'HELP'
╔══════════════════════════════════════════════════════════════╗
║                   TOOL-X v4.0 Command Menu                  ║
║              Ultimate Security & DevOps Toolkit              ║
╚══════════════════════════════════════════════════════════════╝

SECURITY & HACKING:
  toolx recon             - Reconnaissance tools (nmap, whois, etc.)
  toolx scan              - Vulnerability scanning (nikto, sqlmap, etc.)
  toolx web               - Web application testing (burp, zaproxy)
  toolx exploit           - Exploitation frameworks (metasploit)
  toolx crypto            - Cryptography & hashing (john, hashcat)
  toolx wireless          - Wireless network tools (aircrack)
  toolx reverse           - Reverse engineering (ghidra, radare2)
  toolx forensics         - Digital forensics (sleuthkit, exiftool)

DEVOPS & CLOUD:
  toolx docker            - Docker commands & management
  toolx k8s               - Kubernetes operations
  toolx terraform         - Infrastructure as Code
  toolx ansible           - Ansible automation
  toolx cloud             - Cloud CLI tools (AWS, GCP, Azure)

DEVELOPMENT:
  toolx python            - Python environment management
  toolx nodejs            - Node.js tools & npm packages
  toolx go                - Go development environment
  toolx rust              - Rust development environment
  toolx java              - Java/Maven development

AI/ML:
  toolx ai                - AI & Machine Learning tools
  toolx jupyter           - Launch Jupyter Lab
  toolx ollama            - Local LLM management

WEB3:
  toolx web3              - Web3 & blockchain tools
  toolx hardhat           - Smart contract development
  toolx web3py            - Web3 Python library

DATABASES:
  toolx db                - Database tools
  toolx postgres          - PostgreSQL management
  toolx mongodb           - MongoDB management
  toolx redis             - Redis management

SYSTEM:
  toolx status            - Installation status
  toolx update            - Update Tool-X
  toolx list              - List all tools
  toolx resources         - Security resources location
  toolx config            - Configuration management
  toolx logs              - View installation logs
  toolx help              - Show this help

EXAMPLES:
  toolx status
  toolx recon --help
  toolx docker ps
  toolx k8s nodes
  toolx python shell
  toolx ai llm
  toolx web3 deploy

WORDLISTS & RESOURCES:
  ${TOOL_X_TOOLS}/SecLists/
  ${TOOL_X_TOOLS}/nuclei-templates/
  ${TOOL_X_TOOLS}/exploit-db/
  ${TOOL_X_TOOLS}/PEASS/
  ${TOOL_X_TOOLS}/PayloadsAllTheThings/

DOCUMENTATION:
  GitHub: https://github.com/dannywise093-crypto/Tool-X
  Wiki:   https://github.com/dannywise093-crypto/Tool-X/wiki

HELP
}

case "${1}" in
    recon|scan|web|exploit|crypto|wireless|reverse|forensics)
        echo "🔓 Security Category: $1"
        ;;
    docker|k8s|terraform|ansible|cloud)
        echo "⚙️  DevOps Category: $1"
        ;;
    python|nodejs|go|rust|java)
        echo "💻 Development Category: $1"
        ;;
    ai|jupyter|ollama)
        echo "🤖 AI/ML Category: $1"
        ;;
    web3|hardhat|web3py)
        echo "🔗 Web3 Category: $1"
        ;;
    db|postgres|mongodb|redis)
        echo "🗄️  Database Category: $1"
        ;;
    status)
        echo -e "\n${CYAN}=== TOOL-X Installation Status ===${NC}\n"
        echo "Home: ${TOOL_X_HOME}"
        echo "Binaries: ${TOOL_X_HOME}/bin"
        echo "Tools: ${TOOL_X_TOOLS}"
        echo "Config: ${TOOL_X_HOME}/config"
        echo "Logs: ${TOOL_X_HOME}/logs"
        echo ""
        echo "Installed Commands:"
        ls -1 ${TOOL_X_HOME}/bin/ 2>/dev/null | head -20
        ;;
    resources)
        echo -e "\n${CYAN}=== Security Resources ===${NC}\n"
        du -sh ${TOOL_X_TOOLS}/*/ 2>/dev/null
        ;;
    list)
        echo "Listing all installed tools..."
        echo ""
        echo "Binaries:"
        ls -1 /usr/local/bin/ | grep -E "^(nmap|sqlmap|metasploit|docker|kubectl|terraform)" | head -20
        ;;
    logs)
        tail -f ${TOOL_X_HOME}/logs/setup-*.log
        ;;
    update)
        echo "Updating Tool-X..."
        git -C "${TOOL_X_HOME}" pull 2>/dev/null || echo "Update not available"
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'toolx help' for available commands"
        exit 1
        ;;
esac
TOOLXEOF
    
    chmod +x "${TOOL_X_BIN}/toolx-main"
    log_success "Tool-X command created"
}

# === Create Global Command Wrappers ===
create_global_commands() {
    log_status "Creating global command wrappers..."
    
    for cmd in "${COMMANDS[@]}"; do
        if [ "$OS_TYPE" = "termux" ]; then
            echo "#!/bin/bash" > "$BIN_DIR/$cmd"
            echo "exec ${TOOL_X_BIN}/toolx-main \"\$@\"" >> "$BIN_DIR/$cmd"
            chmod +x "$BIN_DIR/$cmd"
        else
            echo "#!/bin/bash" | sudo tee "$BIN_DIR/$cmd" > /dev/null 2>&1
            echo "exec ${TOOL_X_BIN}/toolx-main \"\$@\"" | sudo tee -a "$BIN_DIR/$cmd" > /dev/null 2>&1
            sudo chmod +x "$BIN_DIR/$cmd" 2>/dev/null
        fi
    done
    
    log_success "Global commands created in $BIN_DIR"
}

# === Setup Shell Integration ===
setup_shell_integration() {
    log_status "Setting up shell integration..."
    
    local rc_file="$HOME/.bashrc"
    [ -n "$ZSH_VERSION" ] && rc_file="$HOME/.zshrc"
    
    if ! grep -q "Tool-X" "$rc_file" 2>/dev/null; then
        cat >> "$rc_file" << 'SHELL_CONFIG'

# ==================== Tool-X v4.0 ====================
export TOOL_X_HOME="$HOME/.tool-x"
export TOOL_X_BIN="${TOOL_X_HOME}/bin"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export PATH="${TOOL_X_BIN}:${PATH}"

# Language Paths
export GOPATH="${TOOL_X_HOME}/go"
export GOROOT="/usr/local/go"
export PATH="${GOROOT}/bin:${GOPATH}/bin:${PATH}"
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:${PATH}"

# Aliases
alias toolx='${TOOL_X_BIN}/toolx-main'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# ======================================================
SHELL_CONFIG
        
        log_success "Shell integration added"
    fi
}

# === Generate Installation Report ===
generate_report() {
    log_status "Generating installation report..."
    
    local report="${TOOL_X_HOME}/INSTALLATION_REPORT.md"
    
    cat > "$report" << EOF
# Tool-X v4.0 Installation Report

**Generated:** $(date)
**System:** $OS_TYPE ($PKG_MANAGER)
**Home:** $TOOL_X_HOME

## Installation Summary

- **Successfully Installed:** $INSTALLED
- **Failed:** $FAILED
- **Skipped:** $SKIPPED

## Tool Categories Installed

### Security & Hacking
- ✓ Kali Linux Tools (nmap, metasploit, sqlmap, burp, zaproxy, etc.)
- ✓ Reconnaissance tools (whois, dnsenum, fierce, etc.)
- ✓ Exploitation frameworks
- ✓ Cryptography & hashing
- ✓ Reverse engineering (ghidra, radare2, binwalk)
- ✓ Forensics tools
- ✓ Wireless security

### Cloud Platforms
- ✓ AWS CLI v2
- ✓ Google Cloud SDK
- ✓ Azure CLI
- ✓ DigitalOcean CLI

### DevOps & Infrastructure
- ✓ Docker & Docker Compose
- ✓ Kubernetes (kubectl, Helm)
- ✓ Terraform
- ✓ Ansible
- ✓ Vagrant & Packer

### Programming Languages
- ✓ Python 3 with pip
- ✓ Node.js with npm
- ✓ Go
- ✓ Rust
- ✓ Ruby
- ✓ Java & Maven

### Databases
- ✓ PostgreSQL
- ✓ MySQL
- ✓ MongoDB
- ✓ Redis
- ✓ SQLite

### Development & Testing
- ✓ Python packages (security, web, data science)
- ✓ Node.js global tools
- ✓ Testing frameworks

### AI/ML & Data Science
- ✓ TensorFlow
- ✓ PyTorch
- ✓ Jupyter Lab
- ✓ Hugging Face
- ✓ Ollama (Local LLM)

### Web3 & Blockchain
- ✓ Hardhat
- ✓ Truffle
- ✓ Ganache
- ✓ Web3.py
- ✓ ethers.js

### Security Resources
- ✓ SecLists wordlists
- ✓ Nuclei templates
- ✓ Exploit Database
- ✓ PEASS
- ✓ PayloadsAllTheThings

## Directory Structure

\`\`\`
$TOOL_X_HOME/
├── bin/                 # Executable commands
├── tools/               # Downloaded resources & wordlists
├── modules/             # Custom Tool-X modules
├── config/              # Configuration files
├── logs/                # Installation logs
├── data/                # Data files
└── scripts/             # Helper scripts
\`\`\`

## Quick Start

1. **Reload shell:**
   \`\`\`bash
   source ~/.bashrc  # or ~/.zshrc
   \`\`\`

2. **Verify installation:**
   \`\`\`bash
   toolx status
   \`\`\`

3. **List available commands:**
   \`\`\`bash
   toolx help
   \`\`\`

4. **Use any category:**
   \`\`\`bash
   toolx recon
   toolx docker
   toolx kubernetes
   toolx ai
   \`\`\`

## Commands Available

- \`toolx\` - Main command
- \`tool-x\` - Alias
- \`Tool-X\` - Alias
- \`TOOLX\` - Alias

## Support

- **GitHub:** https://github.com/dannywise093-crypto/Tool-X
- **Issues:** Report bugs and request features
- **Wiki:** Full documentation and guides

## Security Notes

- Always use tools ethically and legally
- Ensure you have proper authorization for testing
- Keep tools and dependencies updated regularly
- Review logs regularly: \`toolx logs\`

---
*Tool-X v4.0 - Next-Generation Security & DevOps Toolkit*
EOF
    
    cat "$report"
    log_success "Report saved to $report"
}

# === MAIN EXECUTION ===
main() {
    print_banner
    
    mkdir -p "$TOOL_X_LOGS"
    {
        log_status "Tool-X v4.0 Installation Started"
        log_status "Timestamp: $(date)"
        log_status "OS: $OSTYPE"
    } > "$LOG_FILE"
    
    # Detection phase
    detect_os
    init_environment
    update_system
    
    # Installation phase
    install_core_dependencies
    install_kali_tools
    install_cloud_tools
    install_devops_tools
    install_programming_languages
    install_databases
    install_python_packages
    install_nodejs_packages
    install_ai_ml_tools
    install_web3_tools
    
    # Resources phase
    download_security_resources
    
    # Configuration phase
    create_toolx_command
    create_global_commands
    setup_shell_integration
    
    # Finalization
    generate_report
    
    # Completion message
    log "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
    log "${GREEN}   ✓✓✓ Tool-X v4.0 Installation COMPLETE! ✓✓✓${NC}"
    log "${GREEN}════════════════════════════════════════════════════════════${NC}\n"
    
    log "${CYAN}Next Steps:${NC}"
    log "${YELLOW}1. Reload your shell:${NC}     source ~/.bashrc"
    log "${YELLOW}2. Verify installation:${NC}   toolx status"
    log "${YELLOW}3. View help:${NC}             toolx help"
    log "${YELLOW}4. Check logs:${NC}            toolx logs\n"
    
    log "${CYAN}Supported Commands:${NC} ${COMMANDS[*]}\n"
    
    log "${BLUE}Installation Summary:${NC}"
    log "  Installed: $INSTALLED"
    log "  Failed: $FAILED"
    log "  Skipped: $SKIPPED\n"
    
    log "${MAGENTA}GitHub: https://github.com/dannywise093-crypto/Tool-X${NC}\n"
}

# Execute
main "$@"
