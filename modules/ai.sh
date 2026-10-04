#!/usr/bin/env bash
set -euo pipefail

install_ai() {
  print_info "Installing AI/ML tools"

  python3 -m pip install --upgrade pip
  python3 -m pip install \
    numpy pandas matplotlib seaborn scipy scikit-learn \
    jupyter jupyterlab \
    transformers datasets huggingface_hub \
    torch tensorflow keras

  print_success "AI/ML tools installed"
}
