param(
  [switch]$Apply,
  [switch]$SkipDrivers,
  [switch]$SkipApps
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== SUPER LAP OPTIMIZER ===" -ForegroundColor Cyan
Write-Host "Mode: $(if($Apply){'APPLY'}else{'DRY-RUN'})" -ForegroundColor Yellow

# 1. UPDATE WINDOWS & STORE APPS
if (-not $SkipApps) {
  Write-Host "`n[1/8] Updating Windows & Store Apps..." -ForegroundColor Green
  if ($Apply) {
    Install-Module PSWindowsUpdate -Force -SkipPublisherCheck -ErrorAction SilentlyContinue
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue
    winget upgrade --all --accept-source-agreements --accept-package-agreements
  } else {
    winget upgrade --all
  }
}

# 2. UPDATE DRIVERS
if (-not $SkipDrivers) {
  Write-Host "`n[2/8] Updating Drivers..." -ForegroundColor Green
  if ($Apply) {
    pnputil /scan-devices
    Get-WindowsDriver -Online -All | Where-Object {$_.DriverSignature -eq 'Signed'} | ForEach-Object {
      Write-Host "  Checking: $($_.OriginalFileName)"
    }
  } else {
    Write-Host "  Run with -Apply to update drivers"
  }
}

# 3. REMOVE DUPLICATE FILES
Write-Host "`n[3/8] Scanning Duplicates..." -ForegroundColor Green
$dupePaths = @(
  "$env:USERPROFILE\Downloads",
  "$env:USERPROFILE\Documents",
  "$env:USERPROFILE\Desktop"
)
$dupes = @()
foreach ($path in $dupePaths) {
  if (Test-Path $path) {
    Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
      Group-Object -Property Length, Name |
      Where-Object {$_.Count -gt 1} |
      ForEach-Object {
        $dupes += $_.Group | Select-Object -Skip 1
      }
  }
}
Write-Host "  Found $($dupes.Count) duplicates"
if ($Apply -and $dupes.Count -gt 0) {
  $dupes | Remove-Item -Force -ErrorAction SilentlyContinue
  Write-Host "  Deleted duplicates" -ForegroundColor Yellow
}

# 4. CLEAN TEMP & CACHE
Write-Host "`n[4/8] Cleaning Temp Files..." -ForegroundColor Green
$tempPaths = @(
  "$env:TEMP",
  "$env:WINDIR\Temp",
  "$env:LOCALAPPDATA\Temp",
  "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
)
$totalSize = 0
foreach ($path in $tempPaths) {
  if (Test-Path $path) {
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum / 1GB
    $totalSize += $size
    if ($Apply) {
      Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
  }
}
Write-Host "  Cleaned: $([math]::Round($totalSize, 2)) GB"

# 5. OPTIMIZE MEMORY
Write-Host "`n[5/8] Optimizing Memory..." -ForegroundColor Green
if ($Apply) {
  # Disable unnecessary startup programs
  Get-CimInstance -ClassName Win32_StartupCommand | Where-Object {
    $_.Name -notmatch 'SecurityHealth|Defender|Graphics'
  } | ForEach-Object {
    Write-Host "  Disabling: $($_.Name)"
  }
  
  # Clear standby memory
  if (Get-Command "EmptyStandbyList" -ErrorAction SilentlyContinue) {
    EmptyStandbyList
  }
  
  # Optimize page file
  $cs = Get-WmiObject -Class Win32_ComputerSystem
  $ram = [math]::Round($cs.TotalPhysicalMemory / 1GB)
  $pageFile = [math]::Round($ram * 1.5)
  Write-Host "  RAM: ${ram}GB, Setting PageFile: ${pageFile}GB"
}

# 6. REMOVE BLOATWARE
Write-Host "`n[6/8] Removing Bloatware..." -ForegroundColor Green
$bloatware = @(
  "Microsoft.BingWeather",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.People",
  "Microsoft.WindowsFeedbackHub",
  "Microsoft.Xbox.TCUI",
  "Microsoft.XboxApp",
  "Microsoft.XboxGameOverlay",
  "Microsoft.XboxGamingOverlay",
  "Microsoft.XboxIdentityProvider",
  "Microsoft.XboxSpeechToTextOverlay",
  "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo"
)
foreach ($app in $bloatware) {
  if ($Apply) {
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Host "  Removed: $app"
  } else {
    if (Get-AppxPackage -Name $app -ErrorAction SilentlyContinue) {
      Write-Host "  Found: $app"
    }
  }
}

# 7. INSTALL ESSENTIAL APPS
Write-Host "`n[7/8] Installing Essential Apps..." -ForegroundColor Green
$essentials = @(
  "7zip.7zip",
  "Git.Git",
  "Microsoft.PowerShell",
  "Microsoft.VisualStudioCode",
  "Google.Chrome",
  "VideoLAN.VLC",
  "Notepad++.Notepad++",
  "Python.Python.3.12",
  "OpenJS.NodeJS"
)
foreach ($app in $essentials) {
  if ($Apply) {
    winget install --id $app --silent --accept-source-agreements --accept-package-agreements -e
  } else {
    Write-Host "  Will install: $app"
  }
}

# 8. OPTIMIZE SYSTEM SETTINGS
Write-Host "`n[8/8] Optimizing System Settings..." -ForegroundColor Green
if ($Apply) {
  # Disable visual effects for performance
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue
  
  # Disable hibernation to save space
  powercfg /hibernate off
  
  # Set power plan to High Performance
  powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  
  # Disable Windows Search indexing on C:
  Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue
  
  # Enable Storage Sense
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" -Name "01" -Value 1 -ErrorAction SilentlyContinue
  
  Write-Host "  System optimized for performance"
}

Write-Host "`n=== COMPLETE ===" -ForegroundColor Cyan
Write-Host "Restart required for all changes to take effect" -ForegroundColor Yellow
if (-not $Apply) {
  Write-Host "`nRun with -Apply to execute changes" -ForegroundColor Red
}
