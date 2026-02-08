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

function New-ReportPath([string]$Prefix, [string]$OutDir) {
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  return Join-Path $OutDir ("{0}-{1}.md" -f $Prefix, $timestamp)
}

Ensure-Dir $OutDir
$reportPath = New-ReportPath 'remote-check' $OutDir

Add-Content -Path $reportPath -Value "# Remote Setup Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

Add-Content -Path $reportPath -Value "`n## WSL"
try {
  $wsl = wsl -l -v
  Add-Content -Path $reportPath -Value $wsl
} catch {
  Add-Content -Path $reportPath -Value "- WSL not available"
}

Add-Content -Path $reportPath -Value "`n## Docker"
try {
  $docker = docker version
  Add-Content -Path $reportPath -Value $docker
} catch {
  Add-Content -Path $reportPath -Value "- Docker not installed or not in PATH"
}

Add-Content -Path $reportPath -Value "`n## SSH Config"
$sshConfig = Join-Path $env:USERPROFILE ".ssh\config"
if (Test-Path -Path $sshConfig) {
  Add-Content -Path $reportPath -Value (Get-Content -Path $sshConfig)
} else {
  Add-Content -Path $reportPath -Value "- No SSH config found at $sshConfig"
}

Write-Host "Report created: $reportPath"
