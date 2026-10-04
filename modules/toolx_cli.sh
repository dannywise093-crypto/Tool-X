#!/usr/bin/env bash
set -euo pipefail

install_toolx_cli() {
  mkdir -p "${TOOL_X_BIN}"

  cat > "${TOOL_X_BIN}/toolx" <<'EOF'
#!/usr/bin/env bash
python3 "$HOME/.tool-x/tool-x.py" "$@"
EOF

  chmod +x "${TOOL_X_BIN}/toolx"

  if ! grep -q '.tool-x/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.tool-x/bin:$PATH"' >> "$HOME/.bashrc"
  fi

  print_success "Global command installed: toolx"
}
