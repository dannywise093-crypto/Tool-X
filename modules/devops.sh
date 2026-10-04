#!/usr/bin/env bash
set -euo pipefail

install_devops() {
  print_info "Installing DevOps tools"

  case "${OSTYPE}" in
    darwin*)
      if ! has_cmd kubectl; then brew install kubectl; fi
      if ! has_cmd helm; then brew install helm; fi
      if ! has_cmd terraform; then brew install terraform; fi
      if ! has_cmd ansible; then python3 -m pip install --user ansible; fi
      ;;

    linux-gnu*)
      if ! has_cmd docker; then curl -fsSL https://get.docker.com | sh; fi
      if ! has_cmd kubectl; then
        curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm -f kubectl
      fi
      if ! has_cmd helm; then curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash; fi
      if ! has_cmd terraform; then
        wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
        unzip -o /tmp/terraform.zip -d /tmp
        sudo install -m 0755 /tmp/terraform /usr/local/bin/terraform
        rm -f /tmp/terraform /tmp/terraform.zip
      fi
      if ! has_cmd ansible; then python3 -m pip install --user ansible; fi
      ;;

    msys*|cygwin*|win32*)
      winget install --id Kubernetes.kubectl -e || choco install -y kubernetes-cli
      winget install --id Helm.Helm -e || choco install -y helm
      winget install --id Ansible.Ansible -e || choco install -y ansible
      ;;

    *)
      echo "[!] Unsupported platform for DevOps install."
      exit 1
      ;;
  esac

  print_success "DevOps tools installed"
}
