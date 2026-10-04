# Tool-X

Tool-X is a multi-platform developer environment installer designed to bootstrap a practical software toolchain on Linux, macOS, and Windows.

It is built to install real development tools, language runtimes, cloud CLIs, security tooling, DevOps utilities, AI/ML dependencies, and Web3 tooling using native package managers where possible.

## Features

- Ubuntu/Debian Linux support
- macOS support
- Windows support
- Real package-manager-based installs
- Language runtime installation
- Dev tooling
- Security tooling
- Cloud tooling
- DevOps tooling
- AI/ML environment setup
- Web3 tooling
- Unified `toolx` launcher

## Supported Platforms

- Ubuntu / Debian Linux
- macOS
- Windows (Git Bash / WSL / native PowerShell environments)

## Quick Start

### Linux

```bash
git clone https://github.com/dannywise093-crypto/Tool-X.git
cd Tool-X
chmod +x setup.sh
./setup.sh
```

### macOS

```bash
git clone https://github.com/dannywise093-crypto/Tool-X.git
cd Tool-X
chmod +x setup.sh
./setup.sh
```

### Windows

Use Git Bash or WSL:

```bash
git clone https://github.com/dannywise093-crypto/Tool-X.git
cd Tool-X
chmod +x setup.sh
./setup.sh
```

## After Installation

```bash
toolx help
```

## Project Structure

```text
Tool-X/
├── README.md
├── .gitignore
├── setup.sh
├── tool-x.py
├── modules/
│   ├── common.sh
│   ├── linux_base.sh
│   ├── macos_base.sh
│   ├── windows_base.sh
│   ├── languages.sh
│   ├── devtools.sh
│   ├── security.sh
│   ├── cloud.sh
│   ├── devops.sh
│   ├── ai.sh
│   ├── web3.sh
│   └── toolx_cli.sh
└── .tool-x/
```

## Notes

This project is intended to be a practical developer environment bootstrapper rather than a placeholder repository. The design emphasizes actual tool installation workflows and real developer workflows across major operating systems.

## License

MIT
