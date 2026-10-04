#!/usr/bin/env bash
set -euo pipefail

install_toolx_cli() {
  print_info "Installing toolx launcher"

  mkdir -p "$TOOL_X_BIN"

  cat > "$TOOL_X_BIN/toolx" <<'LAUNCHER'
#!/usr/bin/env python3
import os
import shutil
import subprocess
import sys

TOOL_X_HOME = os.path.expanduser("~/.tool-x")

HELP_TEXT = """
Tool-X

Categories:
  Base tools
  Developer tools
  Programming languages
  Security tools
  Cloud tools
  DevOps
  AI/ML
  Web3
  Databases
  Utilities

Commands:
  help          Show this screen
  status        Show installation status
  languages     Show programming languages
  tools         Show tool categories
  doctor        Show installation health
  install       Install the default environment
"""

CATEGORIES = [
    "Base tools",
    "Developer tools",
    "Programming languages",
    "Security tools",
    "Cloud tools",
    "DevOps",
    "AI/ML",
    "Web3",
    "Databases",
    "Utilities",
]

PROGRAMMING_LANGUAGES = [
    ("C", "clang"),
    ("C++", "clang++"),
    ("C#", "dotnet"),
    ("Java", "java"),
    ("Python", "python"),
    ("JavaScript", "node"),
    ("TypeScript", "tsc"),
    ("Go", "go"),
    ("Rust", "rustc"),
    ("Ruby", "ruby"),
    ("PHP", "php"),
    ("Kotlin", "kotlinc"),
    ("Bash", "bash"),
    ("PowerShell", "pwsh"),
    ("SQL", "sqlite3"),
]

TOOLS = {
    "Base tools": [
        ("Git", "git", "git"),
        ("Curl", "curl", "curl"),
        ("Wget", "wget", "wget"),
        ("OpenSSH", "ssh", "openssh"),
        ("Zip", "zip", "zip"),
        ("Unzip", "unzip", "unzip"),
    ],
    "Developer tools": [
        ("GitHub CLI", "gh", "gh"),
        ("Make", "make", "make"),
        ("CMake", "cmake", "cmake"),
        ("Clang", "clang", "clang"),
        ("GDB", "gdb", "gdb"),
        ("Python PIP", "pip", "python-pip"),
    ],
    "Security tools": [
        ("OpenSSL", "openssl", "openssl"),
        ("GnuPG", "gpg", "gnupg"),
        ("CA certificates", "termux-change-repo", "ca-certificates"),
    ],
    "Cloud tools": [
        ("AWS CLI", "aws", "aws-cli"),
        ("Rclone", "rclone", "rclone"),
        ("Terraform", "terraform", "terraform"),
    ],
    "DevOps": [
        ("Docker CLI", "docker", "docker"),
        ("Kubectl", "kubectl", "kubectl"),
        ("Helm", "helm", "helm"),
        ("Ansible", "ansible", "ansible"),
    ],
    "AI/ML": [
        ("Python", "python", "python"),
        ("PIP", "pip", "python-pip"),
        ("NumPy", "numpy", "python-numpy"),
        ("Pandas", "pandas", "python-pandas"),
        ("Scikit-learn", "sklearn", "python-scikit-learn"),
    ],
    "Web3": [
        ("Node.js", "node", "nodejs"),
        ("NPM", "npm", "nodejs"),
        ("Python", "python", "python"),
        ("OpenSSL", "openssl", "openssl"),
    ],
    "Databases": [
        ("SQLite", "sqlite3", "sqlite"),
        ("PostgreSQL client", "psql", "postgresql"),
        ("Redis CLI", "redis-cli", "redis"),
        ("MariaDB client", "mariadb", "mariadb"),
    ],
    "Utilities": [
        ("JQ", "jq", "jq"),
        ("Tree", "tree", "tree"),
        ("Nano", "nano", "nano"),
        ("Vim", "vim", "vim"),
        ("Tmux", "tmux", "tmux"),
        ("Less", "less", "less"),
    ],
}

def status():
    print(f"Tool-X Home: {TOOL_X_HOME}")
    print("Status:", "Installed" if os.path.isdir(TOOL_X_HOME) else "Not installed")

def doctor():
    print("Tool-X environment check")
    print("- home:", TOOL_X_HOME)
    print("- status:", "installed" if os.path.isdir(TOOL_X_HOME) else "not installed")
    print("- python:", shutil.which("python3") or shutil.which("python") or "not found")
    print("- package manager:", "pkg" if shutil.which("pkg") else ("apt" if shutil.which("apt") else "not found"))

def languages():
    print("Programming languages")
    print("=====================")
    for language, executable in PROGRAMMING_LANGUAGES:
        state = "installed" if shutil.which(executable) else "not installed"
        print(f"- {language:<18} [{state}]")

def tools():
    print("Tool-X categories")
    print("=================")
    for category in CATEGORIES:
        print(f"- {category}")

def install():
    print("Use the installer for the full environment bootstrap.")
    print("Example: bash setup.sh")

def clear_screen():
    os.system("clear")

def run_install(package):
    if shutil.which("pkg"):
        command = ["pkg", "install", "-y", package]
    elif shutil.which("apt"):
        command = ["apt", "install", "-y", package]
    else:
        print("No supported package manager was found.")
        input("Press Enter to continue...")
        return
    print("Running:", " ".join(command))
    try:
        subprocess.run(command, check=False)
    except OSError as exc:
        print("Install failed:", exc)
    input("Press Enter to continue...")

def category_items(category):
    if category == "Programming languages":
        return [(name, executable, executable) for name, executable in PROGRAMMING_LANGUAGES]
    return TOOLS.get(category, [])

def category_menu(index):
    category = CATEGORIES[index - 1]
    items = category_items(category)
    while True:
        clear_screen()
        print("╔══════════════════════════════════════════════╗")
        print(f"║ {category:^44} ║")
        print("╠══════════════════════════════════════════════╣")
        for number, (name, executable, package) in enumerate(items, 1):
            state = "✓" if shutil.which(executable) else " "
            label = f"{number:>2}. [{state}] {name}"
            print(f"║ {label:<44} ║")
        print("║                                              ║")
        print("║  0. Back                                     ║")
        print("╚══════════════════════════════════════════════╝")
        choice = input("Select a tool (i<number> to install): ").strip().lower()

        if choice == "0":
            return

        if choice.startswith("i") and choice[1:].isdigit():
            number = int(choice[1:])
            if 1 <= number <= len(items):
                name, executable, package = items[number - 1]
                print(f"Installing {name}...")
                run_install(package)
                continue

        if choice.isdigit():
            number = int(choice)
            if 1 <= number <= len(items):
                name, executable, package = items[number - 1]
                state = "installed" if shutil.which(executable) else "not installed"
                print(f"{name}: {state}")
                print(f"Executable: {executable}")
                print(f"Package: {package}")
                input("Press Enter to continue...")
                continue

        print("Invalid selection.")
        input("Press Enter to continue...")

def interactive_menu():
    while True:
        clear_screen()
        print("╔══════════════════════════════════════════════╗")
        print("║                    TOOL-X                    ║")
        print("╠══════════════════════════════════════════════╣")
        for index, category in enumerate(CATEGORIES, 1):
            print(f"║ {index:>2}. {category:<37} ║")
        print("║                                              ║")
        print("║  0. Exit                                     ║")
        print("╚══════════════════════════════════════════════╝")
        choice = input("Select a category: ").strip().lower()
        if choice in {"0", "x", "q"}:
            return 0
        if choice.isdigit():
            number = int(choice)
            if 1 <= number <= len(CATEGORIES):
                category_menu(number)
                continue
        print("Invalid selection.")
        input("Press Enter to continue...")

def main():
    if len(sys.argv) < 2:
        return interactive_menu()

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

  local termux_bin=""
  if command -v bash >/dev/null 2>&1; then
    termux_bin="$(dirname "$(command -v bash)")"
  elif [[ -n "${PREFIX:-}" && -d "$PREFIX/bin" ]]; then
    termux_bin="$PREFIX/bin"
  fi

  if [[ -n "$termux_bin" && -d "$termux_bin" && -w "$termux_bin" ]]; then
    ln -sf "$TOOL_X_BIN/toolx" "$termux_bin/toolx"
    chmod +x "$termux_bin/toolx"
    print_success "Termux launcher linked: $termux_bin/toolx"
  fi

  ensure_path_entry "$TOOL_X_BIN"
  export PATH="$TOOL_X_BIN:$PATH"

  print_success "Launcher installed: $TOOL_X_BIN/toolx"
}
