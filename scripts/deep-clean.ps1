param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== DEEP SYSTEM CLEANER ===" -ForegroundColor Cyan

$stats = @{
  OldDrivers = 0
  OldApps = 0
  TempFiles = 0
  SpaceFreed = 0
}

# 1. REMOVE OLD DRIVERS
Write-Host "`n[1/5] Scanning Old Drivers..." -ForegroundColor Green
$driverPaths = @(
  "$env:USERPROFILE\Downloads\LiveUpdate",
  "$env:USERPROFILE\Downloads\RealtekAudioDriver",
  "$env:SystemDrive\AMD",
  "$env:SystemDrive\NVIDIA",
  "$env:SystemDrive\Intel",
  "$env:WINDIR\System32\DriverStore\FileRepository"
)

foreach ($path in $driverPaths) {
  if (Test-Path $path) {
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | 
      Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
    
    if ($size -gt 0) {
      Write-Host "  Found: $path [$([math]::Round($size, 2)) MB]" -ForegroundColor Yellow
      $stats.SpaceFreed += $size
      $stats.OldDrivers++
      
      if ($Apply -and $path -notlike "*System32*") {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "  DELETED" -ForegroundColor Red
      }
    }
  }
}

# 2. REMOVE OLD APP VERSIONS
Write-Host "`n[2/5] Scanning Old App Versions..." -ForegroundColor Green
$appPaths = @(
  "$env:LOCALAPPDATA\Programs",
  "$env:ProgramFiles\WindowsApps",
  "$env:USERPROFILE\AppData\Local\Microsoft\WindowsApps"
)

$oldApps = @()
foreach ($path in $appPaths) {
  if (Test-Path $path) {
    $folders = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match '\d+\.\d+' } |
      Group-Object { $_.Name -replace '\d+\.\d+.*$', '' } |
      Where-Object { $_.Count -gt 1 }
    
    foreach ($group in $folders) {
      $sorted = $group.Group | Sort-Object Name -Descending
      $keep = $sorted[0]
      $remove = $sorted | Select-Object -Skip 1
      
      foreach ($old in $remove) {
        $size = (Get-ChildItem -Path $old.FullName -Recurse -File -ErrorAction SilentlyContinue |
          Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
        
        Write-Host "  Old: $($old.Name) [$([math]::Round($size, 2)) MB]" -ForegroundColor Yellow
        $stats.SpaceFreed += $size
        $stats.OldApps++
        
        if ($Apply) {
          Remove-Item -Path $old.FullName -Recurse -Force -ErrorAction SilentlyContinue
          Write-Host "  DELETED" -ForegroundColor Red
        }
      }
    }
  }
}

# 3. WINDOWS UPDATE CLEANUP
Write-Host "`n[3/5] Windows Update Cleanup..." -ForegroundColor Green
if ($Apply) {
  Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase
  Write-Host "  Component cleanup completed" -ForegroundColor Gray
}

# 4. CLEAR ALL CACHES
Write-Host "`n[4/5] Clearing Caches..." -ForegroundColor Green
$cachePaths = @(
  "$env:LOCALAPPDATA\Temp",
  "$env:TEMP",
  "$env:WINDIR\Temp",
  "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
  "$env:LOCALAPPDATA\Microsoft\Windows\WebCache",
  "$env:LOCALAPPDATA\CrashDumps",
  "$env:WINDIR\SoftwareDistribution\Download",
  "$env:LOCALAPPDATA\Package Cache"
)

foreach ($path in $cachePaths) {
  if (Test-Path $path) {
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
      Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1MB
    
    if ($size -gt 0) {
      Write-Host "  $path [$([math]::Round($size, 2)) MB]" -ForegroundColor Yellow
      $stats.SpaceFreed += $size
      $stats.TempFiles++
      
      if ($Apply) {
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
          Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
      }
    }
  }
}

# 5. UNINSTALL DUPLICATE/OLD PROGRAMS
Write-Host "`n[5/5] Scanning Installed Programs..." -ForegroundColor Green
$programs = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue |
  Group-Object { $_.Name -replace '\s+\d+.*$', '' } |
  Where-Object { $_.Count -gt 1 }

foreach ($group in $programs) {
  $sorted = $group.Group | Sort-Object Version -Descending
  $keep = $sorted[0]
  $remove = $sorted | Select-Object -Skip 1
  
  foreach ($old in $remove) {
    Write-Host "  Old: $($old.Name) v$($old.Version)" -ForegroundColor Yellow
    
    if ($Apply) {
      $old.Uninstall() | Out-Null
      Write-Host "  UNINSTALLED" -ForegroundColor Red
    }
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Old drivers found: $($stats.OldDrivers)" -ForegroundColor Yellow
Write-Host "Old app versions: $($stats.OldApps)" -ForegroundColor Yellow
Write-Host "Cache locations: $($stats.TempFiles)" -ForegroundColor Yellow
Write-Host "Total space to free: $([math]::Round($stats.SpaceFreed / 1024, 2)) GB" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "`nRun with -Apply to clean everything" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\deep-clean.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`nDeep clean completed!" -ForegroundColor Green
  Write-Host "Restart recommended" -ForegroundColor Yellow
}
