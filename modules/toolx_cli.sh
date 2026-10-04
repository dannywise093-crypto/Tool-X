#!/usr/bin/env bash
set -euo pipefail

install_toolx_cli() {
  print_info "Installing toolx launcher"

  mkdir -p "$TOOL_X_BIN"

  cat > "$TOOL_X_BIN/toolx" <<'LAUNCHER'
#!/usr/bin/env python3
import os
import sys

TOOL_X_HOME = os.path.expanduser("~/.tool-x")

HELP_TEXT = """
Tool-X

Commands:
  help          Show this screen
  status        Show installation status
  languages     Show language runtimes
  tools         Show tool categories
  doctor        Show installation health
  install       Install the default environment
"""

def status():
    print(f"Tool-X Home: {TOOL_X_HOME}")
    if os.path.isdir(TOOL_X_HOME):
        print("Installed")
    else:
        print("Not installed")


def doctor():
    print("Tool-X environment check")
    print("- home:", TOOL_X_HOME)
    if os.path.isdir(TOOL_X_HOME):
        print("- status: installed")
    else:
        print("- status: not installed")


def languages():
    print("C, C++, C#, Java, Python, JavaScript, TypeScript, Go, Rust, Ruby, PHP, Kotlin, Bash, PowerShell, SQL")


def tools():
    print("Base tools, developer tools, security tools, cloud tools, DevOps, AI/ML, Web3, databases, utilities")


def install():
    print("Use the installer for the full environment bootstrap.")
    print("Example: bash <(curl -s https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main/setup.sh)")


def main():
    if len(sys.argv) < 2:
        print(HELP_TEXT)
        return 0

    command = sys.argv[1].lower()

    if command in {"help", "--help", "-h"}:
        print(HELP_TEXT)
        return 0

    if command == "status":
        status()
        return 0

    if command == "doctor":
        doctor()
        return 0

    if command == "languages":
        languages()
        return 0

    if command == "tools":
        tools()
        return 0

    if command == "install":
        install()
        return 0

    print(f"Unknown command: {command}")
    return 1

if __name__ == "__main__":
    raise SystemExit(main())
LAUNCHER

  chmod +x "$TOOL_X_BIN/toolx"

  # Termux already keeps $PREFIX/bin on PATH. Install a stable launcher there
  # so `toolx` works immediately in the current shell and after reopening Termux.
  if [[ "${OSTYPE:-}" == linux-andro* && -n "${PREFIX:-}" && -d "$PREFIX/bin" ]]; then
    ln -sf "$TOOL_X_BIN/toolx" "$PREFIX/bin/toolx"
    chmod +x "$PREFIX/bin/toolx"
  fi

  ensure_path_entry "$TOOL_X_BIN"
  export PATH="$TOOL_X_BIN:$PATH"

  print_success "Launcher installed: $TOOL_X_BIN/toolx"
  if [[ "${OSTYPE:-}" == linux-andro* ]]; then
    print_success "Termux launcher linked: $PREFIX/bin/toolx"
  fi
}
