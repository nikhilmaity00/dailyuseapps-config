#!/usr/bin/env bash

# Detect whether VS Code (code) or VSCodium (codium) is available
if command -v codium &> /dev/null; then
    VSCODE_CLI="codium"
elif command -v code &> /dev/null; then
    VSCODE_CLI="code"
else
    echo "Error: Neither VS Code (code) nor VSCodium (codium) CLI found in your PATH." >&2
    exit 1
fi

echo "Detected editor CLI: $VSCODE_CLI"

# Array of essential cloud/DevOps extension identifiers
EXTENSIONS=(
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "hashicorp.terraform"
#    "redhat.ansible"
    "redhat.vscode-yaml"
#    "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-containers"
    "eamodio.gitlens"
    "humao.rest-client"
)

echo "Starting extension installation..."
for ext in "${EXTENSIONS[@]}"; do
    echo "Installing -> $ext"
    "$VSCODE_CLI" --install-extension "$ext" --force
done

echo "Setup complete! All cloud/DevOps extensions have been installed."
