#!/bin/bash

################################################################################
# Tool-X Setup Script
# A comprehensive bash tool suite with Kali Linux integration
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
NC='\033[0m' # No Color

# Global variables
TOOL_X_HOME="${HOME}/.toolx"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"
TOOL_X_CONFIG="${TOOL_X_HOME}/config"
TOOL_X_LOGS="${TOOL_X_HOME}/logs"
KALI_TOOLS_INSTALLED=()
KALI_TOOLS_FAILED=()
OS_TYPE=""
DISTRO=""

################################################################################
# Utility Functions
################################################################################

# Error handling function - continues on error
handle_error() {
    local line_num=$2
    local error_code=$1
    echo -e "${RED}[ERROR] Command failed at line $line_num with exit code $error_code${NC}"
    log_message "ERROR" "Command failed at line $line_num with exit code $error_code"
}

# Logging function
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" >> "${TOOL_X_LOGS}/setup.log"
}

# Print banner
print_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                                                                ║"
    echo "║                      ${PURPLE}⚔️  TOOL-X SETUP  ⚔️${CYAN}                       ║"
    echo "║                  Comprehensive Kali Linux Toolkit              ║"
    echo "║                                                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print status
print_status() {
    local message=$1
    echo -e "${BLUE}[*]${NC} ${message}"
    log_message "INFO" "$message"
}

# Print success
print_success() {
    local message=$1
    echo -e "${GREEN}[✓]${NC} ${message}"
    log_message "SUCCESS" "$message"
}

# Print warning
print_warning() {
    local message=$1
    echo -e "${YELLOW}[!]${NC} ${message}"
    log_message "WARNING" "$message"
}

# Print error
print_error() {
    local message=$1
    echo -e "${RED}[✗]${NC} ${message}"
    log_message "ERROR" "$message"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "This script requires root privileges for some operations"
        print_status "Requesting sudo privileges..."
        if ! sudo -v; then
            print_error "Failed to acquire sudo privileges"
            exit 1
        fi
    else
        print_success "Running with root privileges"
    fi
}

# Detect OS and distribution
detect_os() {
    print_status "Detecting operating system..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS_TYPE="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        elif command -v lsb_release &> /dev/null; then
            DISTRO=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        else
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
        DISTRO="macos"
    else
        OS_TYPE="unknown"
        print_error "Unsupported OS: $OSTYPE"
        exit 1
    fi
    
    print_success "Detected: ${OS_TYPE} (${DISTRO})"
}

# Update package manager (with error handling)
update_packages() {
    print_status "Updating package manager..."
    
    if [[ "$DISTRO" == "kali"* ]] || [[ "$DISTRO" == "debian"* ]] || [[ "$DISTRO" == "ubuntu"* ]]; then
        sudo apt-get update -y 2>/dev/null || print_warning "apt-get update encountered issues, continuing..."
        sudo apt-get upgrade -y 2>/dev/null || print_warning "apt-get upgrade encountered issues, continuing..."
    elif [[ "$DISTRO" == "fedora"* ]] || [[ "$DISTRO" == "rhel"* ]] || [[ "$DISTRO" == "centos"* ]]; then
        sudo dnf update -y 2>/dev/null || print_warning "dnf update encountered issues, continuing..."
    elif [[ "$DISTRO" == "arch"* ]]; then
        sudo pacman -Syu --noconfirm 2>/dev/null || print_warning "pacman update encountered issues, continuing..."
    elif [[ "$DISTRO" == "macos"* ]]; then
        brew update 2>/dev/null || print_warning "brew update encountered issues, continuing..."
    fi
    
    print_success "Package manager updated (or skipped on errors)"
}

# Install required dependencies
install_dependencies() {
    print_status "Installing core dependencies..."
    
    local deps=(
        "curl"
        "wget"
        "git"
        "python3"
        "python3-pip"
        "jq"
        "net-tools"
        "dnsutils"
        "whois"
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
        "ffmpeg"
        "imagemagick"
    )
    
    for dep in "${deps[@]}"; do
        install_package "$dep"
    done
}

# Install individual package with error handling
install_package() {
    local package=$1
    
    if command -v "$package" &> /dev/null; then
        print_success "$package is already installed"
        KALI_TOOLS_INSTALLED+=("$package")
        return 0
    fi
    
    print_status "Installing $package..."
    
    local installed=false
    
    if [[ "$DISTRO" == "kali"* ]] || [[ "$DISTRO" == "debian"* ]] || [[ "$DISTRO" == "ubuntu"* ]]; then
        if sudo apt-get install -y "$package" 2>/dev/null; then
            installed=true
        fi
    elif [[ "$DISTRO" == "fedora"* ]] || [[ "$DISTRO" == "rhel"* ]] || [[ "$DISTRO" == "centos"* ]]; then
        if sudo dnf install -y "$package" 2>/dev/null; then
            installed=true
        fi
    elif [[ "$DISTRO" == "arch"* ]]; then
        if sudo pacman -S --noconfirm "$package" 2>/dev/null; then
            installed=true
        fi
    elif [[ "$DISTRO" == "macos"* ]]; then
        if brew install "$package" 2>/dev/null; then
            installed=true
        fi
    fi
    
    if $installed; then
        print_success "$package installed successfully"
        KALI_TOOLS_INSTALLED+=("$package")
    else
        print_warning "Failed to install $package (continuing with other tools)"
        KALI_TOOLS_FAILED+=("$package")
    fi
}

# Create directory structure
create_directories() {
    print_status "Creating Tool-X directory structure..."
    
    mkdir -p "${TOOL_X_HOME}"
    mkdir -p "${TOOL_X_BIN}"
    mkdir -p "${TOOL_X_TOOLS}"
    mkdir -p "${TOOL_X_CONFIG}"
    mkdir -p "${TOOL_X_LOGS}"
    
    print_success "Directory structure created at ${TOOL_X_HOME}"
}

# Setup Python environment
setup_python_env() {
    print_status "Setting up Python virtual environment..."
    
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 not found, skipping virtual environment"
        return 1
    fi
    
    python3 -m venv "${TOOL_X_HOME}/venv" 2>/dev/null || print_warning "Failed to create venv, continuing..."
    
    if [ -f "${TOOL_X_HOME}/venv/bin/activate" ]; then
        source "${TOOL_X_HOME}/venv/bin/activate"
        pip install --upgrade pip 2>/dev/null || print_warning "pip upgrade encountered issues, continuing..."
        
        # Install Python security tools
        local py_tools=(
            "paramiko"
            "requests"
            "beautifulsoup4"
            "scrapy"
            "cryptography"
            "pycryptodome"
            "exploit-db"
            "shodan"
            "censys"
            "nmap"
            "netaddr"
        )
        
        for tool in "${py_tools[@]}"; do
            pip install "$tool" 2>/dev/null || print_warning "Failed to install $tool, continuing..."
        done
        
        deactivate
        print_success "Python environment configured"
    fi
}

# Download Kali Linux tools
download_kali_tools() {
    print_status "Downloading additional Kali Linux tools from repositories..."
    
    # Clone popular security tools
    local repos=(
        "https://github.com/Dewalt-arch/pimpmykali.git:pimpmykali"
        "https://github.com/offensive-security/exploit-database.git:exploitdb"
        "https://github.com/danielmiessler/SecLists.git:seclists"
        "https://github.com/projectdiscovery/nuclei-templates.git:nuclei"
    )
    
    for repo_url in "${repos[@]}"; do
        IFS=':' read -r repo name <<< "$repo_url"
        print_status "Cloning $name..."
        
        if git clone "$repo" "${TOOL_X_TOOLS}/$name" 2>/dev/null; then
            print_success "$name cloned successfully"
        else
            print_warning "Failed to clone $name, continuing..."
        fi
    done
}

# Create main Tool-X command
create_toolx_command() {
    print_status "Creating Tool-X main command..."
    
    cat > "${TOOL_X_BIN}/toolx" << 'EOF'
#!/bin/bash

# Tool-X Main Command Handler

TOOL_X_HOME="${HOME}/.toolx"
TOOL_X_BIN="${TOOL_X_HOME}/bin"
TOOL_X_TOOLS="${TOOL_X_HOME}/tools"

show_help() {
    cat << 'HELP'
╔════════════════════════════════════════════════════════════╗
║                       TOOL-X v1.0                          ║
║              Comprehensive Security Toolkit                ║
╚════════════════════════════════════════════════════════════╝

USAGE: toolx [command] [options]

COMMANDS:
    reconnaissance      - Perform reconnaissance tasks
    scanning           - Network and vulnerability scanning
    exploitation       - Exploitation tools and utilities
    cryptography       - Encryption/decryption tools
    forensics          - Digital forensics tools
    steganography      - Hide/extract data in files
    wordlists          - Access security wordlists
    web                - Web application testing tools
    wireless           - Wireless network tools
    reverse-eng        - Reverse engineering tools
    status             - Show Tool-X status
    update             - Update Tool-X and tools
    help               - Show this help message

EXAMPLES:
    toolx reconnaissance --help
    toolx scanning nmap --help
    toolx status

EOF
    cat HELP
}

case "${1}" in
    reconnaissance|scanning|exploitation|cryptography|forensics|steganography|wordlists|web|wireless|reverse-eng)
        echo "Tool category: $1"
        echo "Available tools in this category..."
        ;;
    status)
        echo "Tool-X Installation Status:"
        echo "Home: ${TOOL_X_HOME}"
        echo "Bin: ${TOOL_X_BIN}"
        echo "Tools: ${TOOL_X_TOOLS}"
        ;;
    update)
        echo "Updating Tool-X..."
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
EOF
    
    chmod +x "${TOOL_X_BIN}/toolx"
    print_success "Tool-X command created"
}

# Setup shell integration
setup_shell_integration() {
    print_status "Setting up shell integration..."
    
    local shell_rc=""
    
    if [ -n "${ZSH_VERSION}" ]; then
        shell_rc="${HOME}/.zshrc"
    else
        shell_rc="${HOME}/.bashrc"
    fi
    
    if ! grep -q "Tool-X" "$shell_rc" 2>/dev/null; then
        echo "" >> "$shell_rc"
        echo "# Tool-X Environment" >> "$shell_rc"
        echo "export PATH=\"${TOOL_X_BIN}:\$PATH\"" >> "$shell_rc"
        echo "export TOOL_X_HOME=\"${TOOL_X_HOME}\"" >> "$shell_rc"
        echo "alias toolx='${TOOL_X_BIN}/toolx'" >> "$shell_rc"
        
        print_success "Shell integration added to $shell_rc"
    fi
}

# Generate installation report
generate_report() {
    print_status "Generating installation report..."
    
    local report_file="${TOOL_X_LOGS}/installation_report.txt"
    
    cat > "$report_file" << EOF
╔════════════════════════════════════════════════════════════╗
║              TOOL-X Installation Report                    ║
║              Generated: $(date)                   ║
╚════════════════════════════════════════════════════════════╝

SYSTEM INFORMATION:
  OS Type:      ${OS_TYPE}
  Distribution: ${DISTRO}
  Home Dir:     ${TOOL_X_HOME}

INSTALLATION SUMMARY:
  Tools Installed:  ${#KALI_TOOLS_INSTALLED[@]}
  Tools Failed:     ${#KALI_TOOLS_FAILED[@]}

SUCCESSFULLY INSTALLED TOOLS:
$(printf '  - %s\n' "${KALI_TOOLS_INSTALLED[@]}")

INSTALLATION FAILURES:
$(printf '  - %s\n' "${KALI_TOOLS_FAILED[@]}")

NEXT STEPS:
  1. Reload your shell: source ~/.bashrc (or ~/.zshrc)
  2. Verify installation: toolx status
  3. Access tool: toolx [command]
  4. Check logs: less ${TOOL_X_LOGS}/setup.log

EOF
    
    print_success "Installation report saved to $report_file"
    cat "$report_file"
}

# Main setup flow
main() {
    print_banner
    
    # Initialize logging
    mkdir -p "${TOOL_X_LOGS}"
    log_message "INFO" "Tool-X setup started"
    
    print_status "Tool-X Setup v1.0 - Starting installation process..."
    
    # Detect OS
    detect_os
    
    # Check for sudo
    check_root
    
    # Create directories
    create_directories
    
    # Update packages
    update_packages
    
    # Install dependencies
    install_dependencies
    
    # Setup Python
    setup_python_env
    
    # Download tools
    download_kali_tools
    
    # Create commands
    create_toolx_command
    
    # Setup shell
    setup_shell_integration
    
    # Generate report
    generate_report
    
    echo ""
    print_success "Tool-X installation completed!"
    echo -e "${CYAN}Run: ${YELLOW}source ~/.bashrc${CYAN} and then ${YELLOW}toolx${CYAN} to get started${NC}"
    
    log_message "INFO" "Tool-X setup completed successfully"
}

# Run main function
main "$@"
