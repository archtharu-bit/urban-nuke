param(
  [Parameter()]
  [string]$OutDir = "reports"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

Ensure-Dir $OutDir

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") report
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") security
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") hardware
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") network
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "vscode-scan.ps1")
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "remote-check.ps1")
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "mysql-tune.ps1")
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "aws-cli-check.ps1")
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "redhat-check.ps1")
& powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "local-check.ps1")

Write-Host "All automation complete. Check reports folder."
