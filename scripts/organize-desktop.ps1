param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== ORGANIZE DESKTOP TO WORKSPACE ===" -ForegroundColor Cyan

$desktop = "$env:USERPROFILE\Desktop"
$workspace = "c:\Users\VVIP_44\Downloads\Telegram Desktop"

$organize = @{
  "scripts" = @(
    "*.ps1", "*.bat", "*.vbs"
  )
  "docs" = @(
    "*.txt", "*.md"
  )
  "reports" = @(
    "*.xml", "*REPORT*.txt"
  )
}

$moved = 0
$skipped = 0

foreach ($folder in $organize.Keys) {
  $targetPath = Join-Path $workspace $folder
  
  foreach ($pattern in $organize[$folder]) {
    $files = Get-ChildItem -Path $desktop -Filter $pattern -File -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
      # Skip shortcuts
      if ($file.Extension -eq ".lnk") {
        $skipped++
        continue
      }
      
      Write-Host "`n[MOVE] $($file.Name)" -ForegroundColor Yellow
      Write-Host "  From: Desktop" -ForegroundColor Gray
      Write-Host "  To:   $folder\" -ForegroundColor Gray
      
      if ($Apply) {
        try {
          Move-Item -Path $file.FullName -Destination $targetPath -Force
          $moved++
          Write-Host "  MOVED" -ForegroundColor Green
        } catch {
          Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        }
      }
    }
  }
}

# Clean empty .github folder on desktop
$githubFolder = Join-Path $desktop ".github"
if (Test-Path $githubFolder) {
  Write-Host "`n[DELETE] .github folder" -ForegroundColor Yellow
  if ($Apply) {
    Remove-Item -Path $githubFolder -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  DELETED" -ForegroundColor Green
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Files to move: $moved" -ForegroundColor Yellow
Write-Host "Shortcuts skipped: $skipped" -ForegroundColor Gray

if (-not $Apply) {
  Write-Host "`nRun with -Apply to move files" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\organize-desktop.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`nDesktop organized!" -ForegroundColor Green
}
