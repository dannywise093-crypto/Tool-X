# Tool-X v4.0

A modern universal installer and toolkit for security, cloud, DevOps, AI/ML, and software development.

## Overview

Tool-X is a comprehensive environment setup tool designed to install a broad range of developer, security, cloud, and infrastructure utilities. It supports multiple operating systems and package managers and keeps the installation process resilient by continuing even when some packages fail.

## Features

- Kali Linux security tools
- Cloud CLI tools (AWS, GCP, Azure, DigitalOcean)
- DevOps tools (Docker, Kubernetes, Terraform, Ansible, Vagrant, Packer)
- Programming languages (Python, Node.js, Go, Rust, Ruby, Java)
- Database systems (PostgreSQL, MySQL, MongoDB, Redis, SQLite)
- Python package ecosystem
- Node.js packages and tooling
- AI/ML tools (Jupyter, transformers, Ollama)
- Web3 and blockchain tools
- Security resource repositories (SecLists, Nuclei, Exploit DB, PEASS, PayloadsAllTheThings)
- Global `toolx` command wrapper
- Shell integration and installation reporting

## Quick Start

```bash
bash <(curl -s https://raw.githubusercontent.com/dannywise093-crypto/Tool-X/main/setup.sh)
```

## Commands

After installation, use:

```bash
toolx help
toolx status
toolx recon
toolx docker
toolx k8s
toolx cloud
toolx ai
```

## Requirements

- Linux, macOS, or Termux-based environment
- Internet access
- Root or sudo access for package installs

## License

MIT
