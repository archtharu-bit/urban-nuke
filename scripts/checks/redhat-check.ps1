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
$reportPath = New-ReportPath 'redhat-check' $OutDir

Add-Content -Path $reportPath -Value "# Red Hat (Java) Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

$java = $null
try { $java = java -version 2>&1 } catch { $java = $null }
if ($java) {
  Add-Content -Path $reportPath -Value "- Java detected:"
  Add-Content -Path $reportPath -Value $java
} else {
  Add-Content -Path $reportPath -Value "- Java not found on PATH"
}

$extensions = & code --list-extensions
if ($extensions -contains "redhat.java") {
  Add-Content -Path $reportPath -Value "- VS Code extension: redhat.java installed"
} else {
  Add-Content -Path $reportPath -Value "- VS Code extension: redhat.java missing"
}

Write-Host "Report created: $reportPath"
