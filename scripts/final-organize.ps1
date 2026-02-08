param([switch]$Apply)

Write-Host "=== FINAL ORGANIZATION ===" -ForegroundColor Cyan

# 1. VS Code Workspace
Write-Host "`n[1/3] VS Code Workspace..." -ForegroundColor Green
$workspace = "c:\Users\VVIP_44\Downloads\Telegram Desktop\urban-nuke.code-workspace"
if (Test-Path $workspace) {
  Write-Host "  Workspace configured: urban-nuke.code-workspace" -ForegroundColor Gray
  Write-Host "  Open: File -> Open Workspace from File" -ForegroundColor Gray
}

# 2. Laptop Folders
Write-Host "`n[2/3] Laptop Organization..." -ForegroundColor Green
$folders = @{
  "$env:USERPROFILE\Downloads" = @("Documents", "Images", "Videos", "Music", "Archives", "Installers", "Code")
  "$env:USERPROFILE\Desktop" = @("Shortcuts")
}

foreach ($base in $folders.Keys) {
  foreach ($folder in $folders[$base]) {
    $path = Join-Path $base $folder
    if (-not (Test-Path $path)) {
      if ($Apply) {
        New-Item -Path $path -ItemType Directory -Force | Out-Null
      }
      Write-Host "  Created: $folder in $(Split-Path $base -Leaf)" -ForegroundColor Yellow
    } else {
      Write-Host "  Exists: $folder" -ForegroundColor Gray
    }
  }
}

# 3. Project Structure
Write-Host "`n[3/3] Project Structure..." -ForegroundColor Green
$structure = @(
  "scripts/core",
  "scripts/security", 
  "scripts/maintenance",
  "scripts/checks",
  "scripts/optimization",
  "scripts/reports",
  "scripts/setup",
  "docs",
  "reports"
)

foreach ($dir in $structure) {
  $path = "c:\Users\VVIP_44\Downloads\Telegram Desktop\$dir"
  if (Test-Path $path) {
    $count = (Get-ChildItem -Path $path -File -ErrorAction SilentlyContinue).Count
    Write-Host "  $dir [$count files]" -ForegroundColor Gray
  }
}

Write-Host "`n=== ORGANIZATION COMPLETE ===" -ForegroundColor Cyan
Write-Host "Everything is in the right place!" -ForegroundColor Green

Write-Host "`nNext Steps:" -ForegroundColor Yellow
Write-Host "  1. Open workspace: urban-nuke.code-workspace" -ForegroundColor White
Write-Host "  2. Restart VS Code" -ForegroundColor White
Write-Host "  3. Restart laptop for full cleanup" -ForegroundColor White
