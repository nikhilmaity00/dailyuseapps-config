# Detect VS Code or VSCodium

if (Get-Command codium -ErrorAction SilentlyContinue) {
    $VSCodeCLI = "codium"
}
elseif (Get-Command code -ErrorAction SilentlyContinue) {
    $VSCodeCLI = "code"
}
else {
    Write-Error "Neither VS Code (code) nor VSCodium (codium) CLI was found in PATH."
    exit 1
}

Write-Host "Detected editor CLI: $VSCodeCLI" -ForegroundColor Green

# Essential Cloud / DevOps Extensions
$Extensions = @(
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "hashicorp.terraform"
    # "redhat.ansible"
    "redhat.vscode-yaml"
    # "ms-vscode-remote.remote-ssh"
    "ms-vscode-remote.remote-containers"
    "eamodio.gitlens"
    "humao.rest-client"
)

Write-Host "Starting extension installation..." -ForegroundColor Cyan

foreach ($Extension in $Extensions) {
    Write-Host "Installing -> $Extension"
    & $VSCodeCLI --install-extension $Extension --force
}

Write-Host "Setup complete! All Cloud/DevOps extensions have been installed." -ForegroundColor Green