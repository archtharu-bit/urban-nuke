param(
  [Parameter()]
  [string]$MyIniPath = "C:\ProgramData\MySQL\MySQL Server 8.0\my.ini",
  [Parameter()]
  [string]$OutDir = "reports",

  # Apply changes to my.ini (requires admin). If not set, script only writes a proposed tuned file.
  [Parameter()]
  [switch]$Apply
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

function Test-Admin {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Ensure-Dir $OutDir
$reportPath = New-ReportPath 'mysql-tune' $OutDir

Add-Content -Path $reportPath -Value "# MySQL Tuning Report"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))
Add-Content -Path $reportPath -Value ("Target my.ini: {0}" -f $MyIniPath)

if (-not (Test-Path -Path $MyIniPath)) {
  Add-Content -Path $reportPath -Value "`n## Status"
  Add-Content -Path $reportPath -Value "- my.ini not found at the expected path."
  Write-Host "Report created: $reportPath"
  exit 1
}

$raw = Get-Content -Path $MyIniPath -Raw
$tuned = $raw

$tuned = $tuned -replace "innodb_log_buffer_size=16M","innodb_log_buffer_size=64M"
$tuned = $tuned -replace "innodb_buffer_pool_size=128M","innodb_buffer_pool_size=4G"
$tuned = $tuned -replace "innodb_redo_log_capacity=100M","innodb_redo_log_capacity=512M"
$tuned = $tuned -replace "innodb_buffer_pool_instances=8","innodb_buffer_pool_instances=4"

if ($tuned -notmatch "max_heap_table_size") {
  $tuned = $tuned -replace "tmp_table_size=72M", "tmp_table_size=72M`r`nmax_heap_table_size=72M"
}

$proposedPath = Join-Path $OutDir "my.ini.tuned"
Set-Content -Path $proposedPath -Value $tuned

Add-Content -Path $reportPath -Value "`n## Proposed Changes"
Add-Content -Path $reportPath -Value "- innodb_buffer_pool_size: 128M -> 4G"
Add-Content -Path $reportPath -Value "- innodb_buffer_pool_instances: 8 -> 4"
Add-Content -Path $reportPath -Value "- innodb_log_buffer_size: 16M -> 64M"
Add-Content -Path $reportPath -Value "- innodb_redo_log_capacity: 100M -> 512M"
Add-Content -Path $reportPath -Value "- max_heap_table_size: set to 72M"

if (Test-Admin) {
  if ($Apply) {
    Copy-Item -Path $MyIniPath -Destination ("{0}.bak-{1}" -f $MyIniPath, (Get-Date -Format 'yyyyMMdd-HHmmss')) -Force
    Set-Content -Path $MyIniPath -Value $tuned -Force
    Add-Content -Path $reportPath -Value "`n## Apply"
    Add-Content -Path $reportPath -Value "- Applied changes to my.ini (admin)"
    Add-Content -Path $reportPath -Value "- Restart MySQL80 service to take effect"
    Write-Host "Applied changes. Restart MySQL80 service to take effect."
  } else {
    Add-Content -Path $reportPath -Value "`n## Apply"
    Add-Content -Path $reportPath -Value "- Not applied (run with -Apply to write changes to my.ini)."
    Add-Content -Path $reportPath -Value ("- Use the tuned file: {0}" -f $proposedPath)
  }
} else {
  Add-Content -Path $reportPath -Value "`n## Apply"
  Add-Content -Path $reportPath -Value "- Not applied (no admin rights)."
  Add-Content -Path $reportPath -Value ("- Use the tuned file: {0}" -f $proposedPath)
  Add-Content -Path $reportPath -Value "- Run this script as Administrator and pass -Apply to apply automatically."
}

Write-Host "Report created: $reportPath"
