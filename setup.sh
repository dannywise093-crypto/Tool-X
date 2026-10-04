#!/bin/bash

################################################################################
# Tool-X Advanced Setup Script
# Comprehensive toolkit with Kali Linux, DevOps, Cloud, and Dev tools
# Usage: bash <(curl -s https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main/setup.sh)
################################################################################

set -o pipefail
trap 'handle_error $? $LINENO' ERR

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Global variables
TOOL_X_HOME="${HOME}/.toolx"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
TOOL_X_CONFIG="${TOOL_X_HOME}/config"
TOOL_X_LOGS="${TOOL_X_HOME}/logs"
TOOL_X_DATA="${TOOL_X_HOME}/data"
INSTALLED=()
FAILED=()
OS_TYPE=""
DISTRO=""

################################################################################
# Utility Functions
################################################################################

handle_error() {
    local line_num=$2
    local error_code=$1
    echo -e "${RED}[ERROR] Line $line_num failed with code $error_code${NC}"
    log_message "ERROR" "Line $line_num failed with code $error_code"
}

log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${TOOL_X_LOGS}/setup.log"
}

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║                   ${PURPLE}⚔️  TOOL-X v2.0  ⚔️${CYAN}                    ║
║         Advanced Security & DevOps Toolkit Suite              ║
║                                                                ║
║   Kali | Cloud | DevOps | Development | Forensics            ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[*]${NC} $1"
    log_message "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    log_message "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
    log_message "WARNING" "$1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
    log_message "ERROR" "$1"
}

detect_os() {
    print_status "Detecting operating system..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$(echo $ID | tr '[:upper:]' '[:lower:]')
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        DISTRO="macos"
    else
        print_error "Unsupported OS"
        exit 1
    fi
    
    print_success "Detected: ${OS_TYPE} (${DISTRO})"
}

check_sudo() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "Requesting sudo privileges..."
        sudo -v || { print_error "Failed to get sudo"; exit 1; }
    else
        print_success "Running with root privileges"
    fi
}

update_packages() {
    print_status "Updating package manager..."
    
    if [[ "$DISTRO" == "kali"* ]] || [[ "$DISTRO" == "debian"* ]] || [[ "$DISTRO" == "ubuntu"* ]]; then
        sudo apt-get update -y 2>/dev/null || print_warning "apt-get update had issues, continuing..."
        sudo apt-get upgrade -y 2>/dev/null || print_warning "apt-get upgrade had issues, continuing..."
    elif [[ "$DISTRO" == "fedora"* ]] || [[ "$DISTRO" == "rhel"* ]] || [[ "$DISTRO" == "centos"* ]]; then
        sudo dnf update -y 2>/dev/null || print_warning "dnf update had issues, continuing..."
    elif [[ "$DISTRO" == "arch"* ]]; then
        sudo pacman -Syu --noconfirm 2>/dev/null || print_warning "pacman update had issues, continuing..."
    elif [[ "$DISTRO" == "macos"* ]]; then
        brew update 2>/dev/null || print_warning "brew update had issues, continuing..."
        brew upgrade 2>/dev/null || print_warning "brew upgrade had issues, continuing..."
    fi
}

install_package() {
    local package=$1
    local alt_name=$2
    
    # Check if already installed
    if command -v "$package" &> /dev/null || command -v "$alt_name" &> /dev/null 2>&1; then
        print_success "$package already installed"
        INSTALLED+=("$package")
        return 0
    fi
    
    print_status "Installing $package..."
    
    local success=false
    
    if [[ "$DISTRO" == "kali"* ]] || [[ "$DISTRO" == "debian"* ]] || [[ "$DISTRO" == "ubuntu"* ]]; then
        sudo apt-get install -y "$package" 2>/dev/null && success=true
    elif [[ "$DISTRO" == "fedora"* ]] || [[ "$DISTRO" == "rhel"* ]] || [[ "$DISTRO" == "centos"* ]]; then
        sudo dnf install -y "$package" 2>/dev/null && success=true
    elif [[ "$DISTRO" == "arch"* ]]; then
        sudo pacman -S --noconfirm "$package" 2>/dev/null && success=true
    elif [[ "$DISTRO" == "macos"* ]]; then
        brew install "$package" 2>/dev/null && success=true
    fi
    
    if $success; then
        print_success "$package installed"
        INSTALLED+=("$package")
    else
        print_warning "Failed to install $package (continuing...)"
        FAILED+=("$package")
    fi
}

create_directories() {
    print_status "Creating directory structure..."
    mkdir -p "${TOOL_X_HOME}"/{bin,tools,config,logs,data,modules}
    print_success "Directory structure created"
}

################################################################################
# Install Tool Categories
################################################################################

install_kali_tools() {
    print_status "Installing Kali Linux Security Tools..."
    
    local tools=(
        "nmap"
        "masscan"
        "sqlmap"
        "nikto"
        "hydra"
        "john"
        "hashcat"
        "aircrack-ng"
        "wireshark"
        "metasploit-framework"
        "burpsuite"
        "zaproxy"
        "ghidra"
        "radare2"
        "binwalk"
        "steghide"
        "exiftool"
        "gobuster"
        "dirbuster"
        "wpscan"
        "dnsenum"
        "dnsmap"
        "fierce"
        "whois"
        "netcat"
        "socat"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
}

install_devops_tools() {
    print_status "Installing DevOps & Infrastructure Tools..."
    
    local tools=(
        "docker.io"
        "docker-compose"
        "git"
        "curl"
        "wget"
        "jq"
        "yq"
        "htop"
        "tmux"
        "vim"
        "nano"
        "openssh-client"
        "openssh-server"
        "telnet"
        "traceroute"
        "netcat-openbsd"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
    
    # Install Terraform
    install_terraform
    
    # Install Ansible
    install_ansible
    
    # Install Kubernetes tools
    install_kubernetes_tools
}

install_cloud_tools() {
    print_status "Installing Cloud CLI Tools..."
    
    # AWS CLI
    print_status "Installing AWS CLI..."
    if ! command -v aws &> /dev/null; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 2>/dev/null
        unzip -q awscliv2.zip 2>/dev/null
        sudo ./aws/install 2>/dev/null || print_warning "AWS CLI install skipped"
        rm -rf aws awscliv2.zip
        INSTALLED+=("aws-cli")
    else
        print_success "AWS CLI already installed"
        INSTALLED+=("aws-cli")
    fi
    
    # Azure CLI
    print_status "Installing Azure CLI..."
    if [[ "$DISTRO" == "ubuntu"* ]]; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash 2>/dev/null || print_warning "Azure CLI install skipped"
        INSTALLED+=("azure-cli")
    fi
    
    # Google Cloud SDK
    print_status "Installing Google Cloud SDK..."
    if ! command -v gcloud &> /dev/null; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list 2>/dev/null
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - 2>/dev/null
        sudo apt-get update && sudo apt-get install -y google-cloud-sdk 2>/dev/null || print_warning "GCP SDK install skipped"
        INSTALLED+=("gcloud")
    fi
}

install_programming_languages() {
    print_status "Installing Programming Languages..."
    
    # Python
    install_package "python3"
    install_package "python3-pip"
    
    # Node.js
    print_status "Installing Node.js..."
    if ! command -v node &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - 2>/dev/null || true
        install_package "nodejs"
        INSTALLED+=("nodejs")
    fi
    
    # Go
    print_status "Installing Go..."
    if ! command -v go &> /dev/null; then
        GO_VERSION="1.21.0"
        GO_OS="linux"
        [[ "$DISTRO" == "macos"* ]] && GO_OS="darwin"
        GO_ARCH="amd64"
        
        wget -q https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz -O /tmp/go.tar.gz 2>/dev/null
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz 2>/dev/null
        rm -f /tmp/go.tar.gz
        INSTALLED+=("go")
    else
        print_success "Go already installed"
        INSTALLED+=("go")
    fi
    
    # Rust
    print_status "Installing Rust..."
    if ! command -v rustc &> /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y 2>/dev/null
        INSTALLED+=("rust")
    else
        print_success "Rust already installed"
        INSTALLED+=("rust")
    fi
    
    # Ruby
    install_package "ruby"
}

install_database_tools() {
    print_status "Installing Database Tools..."
    
    local tools=(
        "postgresql"
        "postgresql-contrib"
        "mysql-server"
        "sqlite3"
        "redis-server"
        "mongodb"
    )
    
    for tool in "${tools[@]}"; do
        install_package "$tool"
    done
}

install_python_packages() {
    print_status "Installing Python Security & Dev Packages..."
    
    python3 -m pip install --upgrade pip 2>/dev/null || print_warning "pip upgrade skipped"
    
    local packages=(
        "paramiko"
        "requests"
        "beautifulsoup4"
        "scrapy"
        "cryptography"
        "pycryptodome"
        "shodan"
        "censys"
        "netaddr"
        "dnspython"
        "pwntools"
        "scapy"
        "impacket"
        "jinja2"
        "flask"
        "django"
        "sqlalchemy"
        "pytest"
        "numpy"
        "pandas"
        "matplotlib"
    )
    
    for pkg in "${packages[@]}"; do
        python3 -m pip install "$pkg" 2>/dev/null || print_warning "Failed to install $pkg, continuing..."
    done
}

install_nodejs_tools() {
    print_status "Installing Node.js Tools..."
    
    if command -v npm &> /dev/null; then
        npm install -g 2>/dev/null || true
        npm install -g \
            http-server \
            eslint \
            pm2 \
            webpack \
            mocha \
            2>/dev/null || print_warning "Some npm packages failed, continuing..."
    fi
}

install_terraform() {
    print_status "Installing Terraform..."
    
    if ! command -v terraform &> /dev/null; then
        TERRAFORM_VERSION="1.6.0"
        TERRAFORM_OS="linux"
        [[ "$DISTRO" == "macos"* ]] && TERRAFORM_OS="darwin"
        TERRAFORM_ARCH="amd64"
        
        wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${TERRAFORM_OS}_${TERRAFORM_ARCH}.zip -O /tmp/terraform.zip 2>/dev/null
        unzip -q /tmp/terraform.zip -d /tmp 2>/dev/null
        sudo mv /tmp/terraform /usr/local/bin/
        rm -f /tmp/terraform.zip
        INSTALLED+=("terraform")
    else
        print_success "Terraform already installed"
        INSTALLED+=("terraform")
    fi
}

install_ansible() {
    print_status "Installing Ansible..."
    
    if ! command -v ansible &> /dev/null; then
        python3 -m pip install --user ansible 2>/dev/null || print_warning "Ansible install skipped"
        INSTALLED+=("ansible")
    else
        print_success "Ansible already installed"
        INSTALLED+=("ansible")
    fi
}

install_kubernetes_tools() {
    print_status "Installing Kubernetes Tools..."
    
    # kubectl
    if ! command -v kubectl &> /dev/null; then
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" 2>/dev/null
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl 2>/dev/null
        rm -f kubectl
        INSTALLED+=("kubectl")
    fi
    
    # helm
    if ! command -v helm &> /dev/null; then
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash 2>/dev/null || print_warning "Helm install skipped"
        INSTALLED+=("helm")
    fi
}

download_security_tools() {
    print_status "Downloading Security Wordlists & Tools..."
    
    local repos=(
        "https://github.com/danielmiessler/SecLists.git:seclists"
        "https://github.com/projectdiscovery/nuclei-templates.git:nuclei-templates"
        "https://github.com/offensive-security/exploit-database.git:exploitdb"
    )
    
    for repo_info in "${repos[@]}"; do
        IFS=':' read -r url name <<< "$repo_info"
        print_status "Cloning $name..."
        git clone --depth 1 "$url" "${TOOL_X_TOOLS}/$name" 2>/dev/null && print_success "$name cloned" || print_warning "Failed to clone $name"
    done
}

create_main_command() {
    print_status "Creating Tool-X main command..."
    
    cat > "${TOOL_X_BIN}/toolx" << 'TOOLXEOF'
#!/bin/bash

TOOL_X_HOME="${HOME}/.toolx"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
TOOL_X_CONFIG="${TOOL_X_HOME}/config"

show_help() {
    cat << 'HELP'
╔════════════════════════════════════════════════════════════╗
║                    TOOL-X v2.0 Command                    ║
║           Advanced Security & DevOps Toolkit               ║
╚════════════════════════════════════════════════════════════╝

SECURITY TOOLS:
    toolx recon             - Reconnaissance tools
    toolx scan              - Network scanning
    toolx web               - Web app testing
    toolx exploit           - Exploitation frameworks
    toolx forensics         - Forensic analysis
    toolx crypto            - Encryption/decryption
    toolx wireless          - Wireless tools
    toolx reverse           - Reverse engineering

DEVOPS & CLOUD:
    toolx cloud             - Cloud CLI tools
    toolx k8s               - Kubernetes tools
    toolx docker            - Docker utilities
    toolx infra             - Infrastructure as Code

DEVELOPMENT:
    toolx dev               - Development tools
    toolx python            - Python environment
    toolx nodejs            - Node.js tools
    toolx web-dev           - Web development

SYSTEM:
    toolx status            - Show installation status
    toolx update            - Update Tool-X
    toolx logs              - View setup logs
    toolx help              - Show this help

EXAMPLES:
    toolx status
    toolx recon --help
    toolx web
    toolx k8s version

WORDLISTS:
    ${TOOL_X_TOOLS}/seclists/          - SecLists wordlists
    ${TOOL_X_TOOLS}/nuclei-templates/  - Nuclei templates
    ${TOOL_X_TOOLS}/exploitdb/         - Exploit database

HOME: ${TOOL_X_HOME}
HELP

    cat HELP
}

case "${1}" in
    recon|scan|web|exploit|forensics|crypto|wireless|reverse)
        echo "Security category: $1"
        echo "Run with --help for more details"
        ;;
    cloud|k8s|docker|infra)
        echo "DevOps/Cloud category: $1"
        echo "Run with --help for more details"
        ;;
    dev|python|nodejs|web-dev)
        echo "Development category: $1"
        echo "Run with --help for more details"
        ;;
    status)
        echo "Tool-X Installation Status:"
        echo "Home: ${TOOL_X_HOME}"
        echo "Bins: ${TOOL_X_BIN}"
        echo "Tools: ${TOOL_X_TOOLS}"
        echo ""
        echo "Installed tools:"
        ls -la ${TOOL_X_BIN}/ 2>/dev/null | tail -n +4
        ;;
    logs)
        less "${TOOL_X_HOME}/logs/setup.log"
        ;;
    update)
        echo "Updating Tool-X..."
        git -C "${TOOL_X_HOME}" pull 2>/dev/null || echo "Updates not available"
        ;;
    help|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac
TOOLXEOF
    
    chmod +x "${TOOL_X_BIN}/toolx"
    print_success "Tool-X command created"
}

setup_shell() {
    print_status "Setting up shell integration..."
    
    local rc_file="${HOME}/.bashrc"
    [[ -n "${ZSH_VERSION}" ]] && rc_file="${HOME}/.zshrc"
    
    if ! grep -q "Tool-X" "$rc_file" 2>/dev/null; then
        cat >> "$rc_file" << 'SHELLEOF'

# ==================== Tool-X Environment ====================
export PATH="${HOME}/.toolx/bin:${PATH}"
export TOOL_X_HOME="${HOME}/.toolx"
export TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
export GOPATH="${TOOL_X_HOME}/go"
export GOROOT="/usr/local/go"
export PATH="${GOROOT}/bin:${PATH}"

alias toolx='${HOME}/.toolx/bin/toolx'
alias ll='ls -lah'

# Add Rust to PATH if installed
[ -d "$HOME/.cargo/bin" ] && export PATH="$HOME/.cargo/bin:$PATH"

# ============================================================
SHELLEOF
        
        print_success "Shell integration added to $rc_file"
    fi
}

generate_report() {
    print_status "Generating installation report..."
    
    local report="${TOOL_X_LOGS}/installation_report.txt"
    
    cat > "$report" << EOF
╔════════════════════════════════════════════════════════════╗
║         TOOL-X v2.0 Installation Report                   ║
║         Generated: $(date)               ║
╚════════════════════════════════════════════════════════════╝

SYSTEM INFORMATION:
  OS Type:        ${OS_TYPE}
  Distribution:   ${DISTRO}
  Home Directory: ${TOOL_X_HOME}

INSTALLATION SUMMARY:
  Successfully Installed: ${#INSTALLED[@]}
  Failed Installations:   ${#FAILED[@]}

INSTALLED TOOLS:
$(printf '  ✓ %s\n' "${INSTALLED[@]}")

FAILED TOOLS (May require manual install):
$(printf '  ✗ %s\n' "${FAILED[@]}")

NEXT STEPS:
  1. Reload shell:  source ~/.bashrc
  2. Check status:  toolx status
  3. View help:     toolx help
  4. View logs:     toolx logs

TOOL LOCATIONS:
  Main Command:     ${TOOL_X_BIN}/toolx
  Tools Directory:  ${TOOL_X_TOOLS}
  Configuration:    ${TOOL_X_CONFIG}
  Logs:             ${TOOL_X_LOGS}

AVAILABLE CATEGORIES:
  • Security:       nmap, metasploit, sqlmap, burp, etc.
  • DevOps:         docker, kubernetes, terraform, ansible
  • Cloud:          aws-cli, gcloud, azure-cli
  • Development:    python, node, go, rust, ruby
  • Databases:      postgresql, mongodb, mysql, redis
  • Forensics:      binwalk, exiftool, steghide, radare2

To get started:
  ${TOOL_X_BIN}/toolx help

For detailed logs:
  tail -f ${TOOL_X_LOGS}/setup.log

EOF
    
    print_success "Installation report saved"
    cat "$report"
}

main() {
    print_banner
    
    mkdir -p "${TOOL_X_LOGS}"
    log_message "INFO" "Tool-X v2.0 setup started"
    
    detect_os
    check_sudo
    create_directories
    update_packages
    
    print_status "Installing tool categories..."
    install_kali_tools
    install_devops_tools
    install_cloud_tools
    install_programming_languages
    install_database_tools
    install_python_packages
    install_nodejs_tools
    
    print_status "Downloading security resources..."
    download_security_tools
    
    print_status "Creating commands..."
    create_main_command
    
    print_status "Configuring shell..."
    setup_shell
    
    generate_report
    
    echo ""
    print_success "Tool-X v2.0 installation completed!"
    echo -e "${CYAN}Next: ${YELLOW}source ~/.bashrc${CYAN} then ${YELLOW}toolx${NC}"
    
    log_message "INFO" "Tool-X setup completed"
}

main "$@"
