param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host @"
╔═══════════════════════════════════════════════════════════╗
║           SUPER LAP TRANSFORMATION SUITE                  ║
║  Complete System Optimization, Cleanup & Restructure      ║
╚═══════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

if (-not $Apply) {
  Write-Host "`n⚠️  DRY-RUN MODE - No changes will be made" -ForegroundColor Yellow
  Write-Host "Run with -Apply to execute all changes`n" -ForegroundColor Yellow
}

$scripts = @(
  @{Name="Super Optimizer"; Path="scripts\super-optimizer.ps1"; Desc="Update apps, drivers, clean system"}
  @{Name="Folder Restructure"; Path="scripts\restructure-folders.ps1"; Desc="Organize project structure"}
)

foreach ($script in $scripts) {
  Write-Host "`n▶ Running: $($script.Name)" -ForegroundColor Green
  Write-Host "  $($script.Desc)" -ForegroundColor Gray
  
  $scriptPath = Join-Path (Get-Location) $script.Path
  if (Test-Path $scriptPath) {
    if ($Apply) {
      & $scriptPath -Apply
    } else {
      & $scriptPath
    }
  } else {
    Write-Host "  ⚠️  Script not found: $scriptPath" -ForegroundColor Red
  }
  
  Start-Sleep -Seconds 2
}

Write-Host "`n╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    TRANSFORMATION COMPLETE                 ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($Apply) {
  Write-Host "`n✅ All optimizations applied!" -ForegroundColor Green
  Write-Host "🔄 Restart your computer to complete the transformation" -ForegroundColor Yellow
} else {
  Write-Host "`n💡 Review the changes above, then run:" -ForegroundColor Yellow
  Write-Host "   powershell -ExecutionPolicy Bypass -File scripts\transform-system.ps1 -Apply" -ForegroundColor White
}
