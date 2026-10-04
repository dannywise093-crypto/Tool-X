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
    "C", "C++", "C#", "Java", "Python", "JavaScript", "TypeScript",
    "Go", "Rust", "Ruby", "PHP", "Kotlin", "Bash", "PowerShell", "SQL",
]

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
    print("Programming languages")
    print("=====================")
    for language in PROGRAMMING_LANGUAGES:
        print(f"- {language}")


def tools():
    print("Tool-X categories")
    print("=================")
    for category in CATEGORIES:
        print(f"- {category}")


def install():
    print("Use the installer for the full environment bootstrap.")
    print("Example: bash <(curl -s https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main/setup.sh)")


def clear_screen():
    os.system("clear")


def print_menu():
    print("╔══════════════════════════════════════════════╗")
    print("║                    TOOL-X                    ║")
    print("╠══════════════════════════════════════════════╣")
    for index, category in enumerate(CATEGORIES, 1):
        print(f"║ {index:>2}. {category:<37} ║")
    print("║                                              ║")
    print("║  0. Exit                                     ║")
    print("╚══════════════════════════════════════════════╝")


def category_menu(index):
    category = CATEGORIES[index - 1]
    while True:
        clear_screen()
        print(f"╔══════════════════════════════════════════════╗")
        print(f"║ {category:^44} ║")
        print("╠══════════════════════════════════════════════╣")
        if category == "Programming languages":
            for number, language in enumerate(PROGRAMMING_LANGUAGES, 1):
                print(f"║ {number:>2}. {language:<37} ║")
        else:
            print("║ Category selected.                            ║")
            print("║ More entries can be added safely later.      ║")
        print("║                                              ║")
        print("║  0. Back                                     ║")
        print("╚══════════════════════════════════════════════╝")
        choice = input("Select an option: ").strip().lower()
        if choice == "0":
            return
        if category == "Programming languages" and choice.isdigit():
            number = int(choice)
            if 1 <= number <= len(PROGRAMMING_LANGUAGES):
                print(f"Selected: {PROGRAMMING_LANGUAGES[number - 1]}")
                input("Press Enter to continue...")


def interactive_menu():
    while True:
        clear_screen()
        print_menu()
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

  # Termux: put a stable launcher in the same bin directory as Termux's
  # existing executables. Do not depend on OSTYPE/PREFIX being exported by
  # the shell that invoked the installer.
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
