param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== FOLDER RESTRUCTURE ===" -ForegroundColor Cyan

$base = "c:\Users\VVIP_44\Downloads\Telegram Desktop"
$structure = @{
  "scripts\core" = @("urban-nuke.ps1", "run-all.ps1", "self-test.ps1", "_lib.ps1")
  "scripts\security" = @("admin-security.ps1", "security-baseline.ps1", "defender-*.ps1")
  "scripts\maintenance" = @("cleanup-scan.ps1", "duplicate-scan.ps1", "stability-scan.ps1", "windows-update-scan.ps1")
  "scripts\checks" = @("aws-cli-check.ps1", "local-check.ps1", "redhat-check.ps1", "remote-check.ps1", "vscode-scan.ps1", "health-check.ps1")
  "scripts\optimization" = @("mysql-tune.ps1", "apply-now.ps1")
  "scripts\reports" = @("analyze-collection.ps1", "report-collection.ps1", "reports-prune.ps1")
  "scripts\setup" = @("ssh-setup.ps1", "run-elevated-*.ps1", "run-defender-*.ps1")
}

Write-Host "`nRestructuring folders..." -ForegroundColor Green
foreach ($folder in $structure.Keys) {
  $fullPath = Join-Path $base $folder
  if ($Apply) {
    if (-not (Test-Path $fullPath)) {
      New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
      Write-Host "  Created: $folder" -ForegroundColor Yellow
    }
  } else {
    Write-Host "  Will create: $folder"
  }
  
  foreach ($pattern in $structure[$folder]) {
    $files = Get-ChildItem -Path "$base\scripts" -Filter $pattern -ErrorAction SilentlyContinue
    foreach ($file in $files) {
      if ($Apply) {
        Move-Item -Path $file.FullName -Destination $fullPath -Force -ErrorAction SilentlyContinue
        Write-Host "    Moved: $($file.Name) -> $folder"
      } else {
        Write-Host "    Will move: $($file.Name) -> $folder"
      }
    }
  }
}

Write-Host "`n=== COMPLETE ===" -ForegroundColor Cyan
if (-not $Apply) {
  Write-Host "Run with -Apply to execute" -ForegroundColor Red
}
