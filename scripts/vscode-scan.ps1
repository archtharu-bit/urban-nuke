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
$reportPath = New-ReportPath 'vscode-scan' $OutDir

Add-Content -Path $reportPath -Value "# VS Code Scan"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

$extensions = & code --list-extensions --show-versions

Add-Content -Path $reportPath -Value "`n## Extensions"
foreach ($ext in $extensions) {
  Add-Content -Path $reportPath -Value ("- {0}" -f $ext)
}

Write-Host "Report created: $reportPath"
