#!/usr/bin/env bash
set -euo pipefail

install_cloud() {
  print_info "Installing cloud tools"

  case "${OSTYPE}" in
    darwin*)
      brew install awscli azure-cli
      brew install --cask google-cloud-sdk
      ;;

    linux-gnu*)
      if ! has_cmd aws; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
        unzip -q /tmp/awscliv2.zip -d /tmp
        sudo /tmp/aws/install
      fi

      if ! has_cmd az; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
      fi

      if ! has_cmd gcloud; then
        echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
        curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo tee /usr/share/keyrings/cloud.google.gpg
        sudo apt-get update
        sudo apt-get install -y google-cloud-sdk
      fi
      ;;

    msys*|cygwin*|win32*)
      winget install --id Amazon.AWSCLI -e || choco install -y awscli
      winget install --id Microsoft.AzureCLI -e || choco install -y azure-cli
      winget install --id Google.CloudSDK -e || choco install -y gcloud-sdk
      ;;

    *)
      echo "[!] Unsupported platform for cloud install."
      exit 1
      ;;
  esac

  print_success "Cloud tools installed"
}
