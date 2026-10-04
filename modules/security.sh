#!/usr/bin/env bash
set -euo pipefail

install_security() {
  print_info "Installing security tools"

  case "${OSTYPE}" in
    darwin*)
      brew install nmap sqlmap hydra john hashcat wireshark tcpdump ghidra radare2 binwalk exiftool steghide netcat socat aircrack-ng
      ;;

    linux-gnu*)
      sudo apt-get install -y \
        nmap masscan nikto gobuster sqlmap hydra john wireshark tcpdump \
        ghidra radare2 binwalk exiftool steghide netcat-openbsd socat \
        proxychains4 aircrack-ng dnsenum dnsrecon dsniff theharvester \
        whatweb enum4linux smbclient
      ;;

    msys*|cygwin*|win32*)
      winget install --id Nmap.Nmap -e || choco install -y nmap
      winget install --id WiresharkFoundation.Wireshark -e || choco install -y wireshark
      winget install --id JohnTheRipper.JohnTheRipper -e || choco install -y john
      winget install --id Hashcat.Hashcat -e || choco install -y hashcat
      ;;

    *)
      echo "[!] Unsupported platform for security install."
      exit 1
      ;;
  esac

  print_success "Security tools installed"
}
