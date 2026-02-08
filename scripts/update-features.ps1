param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== FIRMWARE & FEATURES CHECK ===" -ForegroundColor Cyan

# 1. BIOS/UEFI INFO
Write-Host "`n[1/6] BIOS/UEFI Information..." -ForegroundColor Green
$bios = Get-CimInstance Win32_BIOS
$baseboard = Get-CimInstance Win32_BaseBoard

Write-Host "  Manufacturer: $($bios.Manufacturer)" -ForegroundColor Gray
Write-Host "  Version: $($bios.SMBIOSBIOSVersion)" -ForegroundColor Gray
Write-Host "  Release Date: $($bios.ReleaseDate)" -ForegroundColor Gray
Write-Host "  Motherboard: $($baseboard.Manufacturer) $($baseboard.Product)" -ForegroundColor Gray

# 2. WINDOWS FEATURES
Write-Host "`n[2/6] Windows Optional Features..." -ForegroundColor Green
$features = Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq 'Enabled' }
Write-Host "  Enabled features: $($features.Count)" -ForegroundColor Gray

$recommended = @(
  'Microsoft-Windows-Subsystem-Linux',
  'VirtualMachinePlatform',
  'Microsoft-Hyper-V-All',
  'Containers',
  'NetFx3'
)

foreach ($feature in $recommended) {
  $status = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
  if ($status) {
    $color = if($status.State -eq 'Enabled') {'Green'} else {'Yellow'}
    Write-Host "  $feature : $($status.State)" -ForegroundColor $color
    
    if ($Apply -and $status.State -ne 'Enabled') {
      Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue
      Write-Host "    ENABLED" -ForegroundColor Green
    }
  }
}

# 3. WINDOWS CAPABILITIES
Write-Host "`n[3/6] Windows Capabilities..." -ForegroundColor Green
$capabilities = Get-WindowsCapability -Online | Where-Object { $_.State -eq 'Installed' }
Write-Host "  Installed capabilities: $($capabilities.Count)" -ForegroundColor Gray

# 4. CHIPSET & DRIVERS
Write-Host "`n[4/6] Hardware Drivers..." -ForegroundColor Green
$devices = Get-WmiObject Win32_PnPEntity | Where-Object { 
  $_.ConfigManagerErrorCode -ne 0 -or $_.Status -ne 'OK' 
}

if ($devices) {
  Write-Host "  ISSUES FOUND:" -ForegroundColor Red
  foreach ($dev in $devices) {
    Write-Host "    $($dev.Name) - Status: $($dev.Status)" -ForegroundColor Yellow
  }
  
  if ($Apply) {
    pnputil /scan-devices
    Write-Host "  Driver scan completed" -ForegroundColor Gray
  }
} else {
  Write-Host "  All drivers OK" -ForegroundColor Green
}

# 5. FIRMWARE UPDATES (via Windows Update)
Write-Host "`n[5/6] Firmware Updates..." -ForegroundColor Green
if ($Apply) {
  $firmwareUpdates = Get-WindowsUpdate -Category 'Firmware' -ErrorAction SilentlyContinue
  if ($firmwareUpdates) {
    Write-Host "  Found $($firmwareUpdates.Count) firmware updates" -ForegroundColor Yellow
    Install-WindowsUpdate -Category 'Firmware' -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
    Write-Host "  Firmware updates installed" -ForegroundColor Green
  } else {
    Write-Host "  No firmware updates available" -ForegroundColor Gray
  }
}

# 6. POWER FEATURES
Write-Host "`n[6/6] Power Features..." -ForegroundColor Green
$powerScheme = powercfg /getactivescheme
Write-Host "  Active: $powerScheme" -ForegroundColor Gray

if ($Apply) {
  # Enable high performance
  powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  Write-Host "  Set to: High Performance" -ForegroundColor Green
  
  # Disable fast startup (can cause issues)
  powercfg /hibernate off
  Write-Host "  Hibernation: Disabled" -ForegroundColor Gray
}

# SUMMARY
Write-Host "`n=== RECOMMENDATIONS ===" -ForegroundColor Cyan

$recommendations = @()

if ($bios.ReleaseDate -lt (Get-Date).AddYears(-1)) {
  $recommendations += "BIOS is over 1 year old - check manufacturer website for updates"
}

if ($devices) {
  $recommendations += "Fix $($devices.Count) driver issues"
}

if ($recommendations.Count -gt 0) {
  Write-Host "`nACTIONS NEEDED:" -ForegroundColor Yellow
  foreach ($rec in $recommendations) {
    Write-Host "  - $rec" -ForegroundColor White
  }
} else {
  Write-Host "`nAll features up to date!" -ForegroundColor Green
}

if (-not $Apply) {
  Write-Host "`nRun with -Apply to enable features and update:" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\update-features.ps1 -Apply" -ForegroundColor White
}
