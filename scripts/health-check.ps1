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
$reportPath = New-ReportPath 'health-check' $OutDir

Add-Content -Path $reportPath -Value "# Health Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

Add-Content -Path $reportPath -Value "`n## Git"
try {
  $git = git status -sb
  Add-Content -Path $reportPath -Value $git
} catch {
  Add-Content -Path $reportPath -Value "- Git not available"
}

Add-Content -Path $reportPath -Value "`n## MySQL Service"
try {
  $svc = Get-Service -Name MySQL80
  Add-Content -Path $reportPath -Value ("- {0}: {1}" -f $svc.Name, $svc.Status)
} catch {
  Add-Content -Path $reportPath -Value "- MySQL80 service not found"
}

Add-Content -Path $reportPath -Value "`n## Docker"
try {
  $docker = docker version
  Add-Content -Path $reportPath -Value $docker
} catch {
  Add-Content -Path $reportPath -Value "- Docker not installed or not in PATH"
}

Add-Content -Path $reportPath -Value "`n## WSL"
try {
  $wsl = wsl -l -v
  Add-Content -Path $reportPath -Value $wsl
} catch {
  Add-Content -Path $reportPath -Value "- WSL not available"
}

Add-Content -Path $reportPath -Value "`n## VS Code Extensions"
try {
  $ext = & code --list-extensions
  Add-Content -Path $reportPath -Value $ext
} catch {
  Add-Content -Path $reportPath -Value "- VS Code CLI not available"
}

Write-Host "Report created: $reportPath"
