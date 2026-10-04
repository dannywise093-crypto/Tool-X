#!/usr/bin/env python3
"""Tool-X CLI entry point.

Provides a lightweight Python wrapper for the shell tool launcher and future extensibility.
"""

import os
import sys

HOME_DIR = os.path.expanduser("~")
TOOL_X_HOME = os.path.join(HOME_DIR, ".tool-x")


def main() -> int:
    if len(sys.argv) < 2:
        print("Tool-X v4.0")
        print("Use: toolx help")
        return 0

    command = sys.argv[1]
    if command in {"help", "--help", "-h"}:
        print("Tool-X v4.0")
        print("Commands: help, status, recon, docker, k8s, cloud, ai, web3")
        return 0

    if command == "status":
        print(f"Tool-X Home: {TOOL_X_HOME}")
        print("Installed successfully.")
        return 0

    print(f"Command '{command}' is available via the shell launcher.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
