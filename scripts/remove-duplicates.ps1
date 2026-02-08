param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== FIND ALL DUPLICATE SOFTWARE ===" -ForegroundColor Cyan

Write-Host "`nScanning installed programs..." -ForegroundColor Yellow
$programs = Get-WmiObject -Class Win32_Product | Sort-Object Name

# Group by base name (without version numbers)
$grouped = $programs | Group-Object { $_.Name -replace '\s+\d+(\.\d+)*.*$', '' }

$duplicates = $grouped | Where-Object { $_.Count -gt 1 }

Write-Host "`nFound $($duplicates.Count) programs with multiple versions:`n" -ForegroundColor Yellow

foreach ($group in $duplicates) {
  Write-Host "[$($group.Name)]" -ForegroundColor Cyan
  $sorted = $group.Group | Sort-Object Version -Descending
  
  $keep = $sorted[0]
  Write-Host "  KEEP:   $($keep.Name) v$($keep.Version)" -ForegroundColor Green
  
  $remove = $sorted | Select-Object -Skip 1
  foreach ($old in $remove) {
    Write-Host "  REMOVE: $($old.Name) v$($old.Version)" -ForegroundColor Red
    
    if ($Apply) {
      try {
        $old.Uninstall() | Out-Null
        Write-Host "    UNINSTALLED" -ForegroundColor Yellow
      } catch {
        Write-Host "    FAILED: $($_.Exception.Message)" -ForegroundColor Red
      }
    }
  }
  Write-Host ""
}

if (-not $Apply) {
  Write-Host "`nRun with -Apply to remove old versions:" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\remove-duplicates.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "Duplicate removal complete!" -ForegroundColor Green
}
