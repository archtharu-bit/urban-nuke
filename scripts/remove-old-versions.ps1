param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== REMOVE SPECIFIC OLD VERSIONS ===" -ForegroundColor Cyan

# Get all installed programs
$programs = Get-WmiObject -Class Win32_Product

# 1. VISUAL C++ - Keep only latest 2022
Write-Host "`n[1/4] Visual C++ Cleanup..." -ForegroundColor Green
$vcpp = $programs | Where-Object { $_.Name -like "*Visual C++ 2022*" } | 
  Sort-Object Version -Descending

if ($vcpp.Count -gt 0) {
  $latest = $vcpp[0].Version
  Write-Host "  Keeping: Visual C++ 2022 v$latest" -ForegroundColor Green
  
  $toRemove = $vcpp | Where-Object { $_.Version -ne $latest }
  foreach ($old in $toRemove) {
    Write-Host "  Removing: $($old.Name) v$($old.Version)" -ForegroundColor Red
    if ($Apply) {
      $old.Uninstall() | Out-Null
      Write-Host "    UNINSTALLED" -ForegroundColor Yellow
    }
  }
}

# 2. PYTHON - Remove duplicate components, keep main install
Write-Host "`n[2/4] Python Cleanup..." -ForegroundColor Green
$python = $programs | Where-Object { $_.Name -like "*Python 3.14*" }

$toKeep = @("Python 3.14.3 Executables", "Python Launcher")
$toRemove = $python | Where-Object { 
  $_.Name -notlike "*Executables*" -and 
  $_.Name -notlike "*Launcher*" 
}

foreach ($old in $toRemove) {
  Write-Host "  Removing: $($old.Name)" -ForegroundColor Red
  if ($Apply) {
    $old.Uninstall() | Out-Null
    Write-Host "    UNINSTALLED" -ForegroundColor Yellow
  }
}

# 3. MYSQL - Remove old version
Write-Host "`n[3/4] MySQL Cleanup..." -ForegroundColor Green
$mysql = $programs | Where-Object { $_.Name -like "*MySQL Server 8.0*" }

foreach ($old in $mysql) {
  Write-Host "  Removing: $($old.Name) v$($old.Version)" -ForegroundColor Red
  if ($Apply) {
    $old.Uninstall() | Out-Null
    Write-Host "    UNINSTALLED" -ForegroundColor Yellow
  }
}

# 4. WINDOWS UPDATE CACHE
Write-Host "`n[4/4] Windows Update Cache..." -ForegroundColor Green
$updateCache = "$env:WINDIR\SoftwareDistribution\Download"
if (Test-Path $updateCache) {
  $size = (Get-ChildItem -Path $updateCache -Recurse -File -ErrorAction SilentlyContinue |
    Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
  
  Write-Host "  Cache size: $([math]::Round($size, 2)) MB" -ForegroundColor Yellow
  
  if ($Apply) {
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$updateCache\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Write-Host "    CLEARED" -ForegroundColor Yellow
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan

if (-not $Apply) {
  Write-Host "Run with -Apply to remove these items" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\remove-old-versions.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "Cleanup completed!" -ForegroundColor Green
  Write-Host "Restart recommended" -ForegroundColor Yellow
}
