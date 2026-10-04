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
"""

def main():
    if len(sys.argv) < 2:
        print(HELP_TEXT)
        return 0

    command = sys.argv[1].lower()

    if command in {"help", "--help", "-h"}:
        print(HELP_TEXT)
        return 0

    if command == "status":
        print(f"Tool-X Home: {TOOL_X_HOME}")
        if os.path.isdir(TOOL_X_HOME):
            print("Installed")
        else:
            print("Not installed")
        return 0

    if command == "languages":
        print("C, C++, C#, Java, Python, JavaScript, TypeScript, Go, Rust, Ruby, PHP, Kotlin, Bash, PowerShell, SQL")
        return 0

    if command == "tools":
        print("Dev tools, security tools, cloud tools, DevOps, AI/ML, Web3, databases, utilities")
        return 0

    print(f"Unknown command: {command}")
    return 1

if __name__ == "__main__":
    raise SystemExit(main())
