param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== COMPREHENSIVE DUPLICATE FINDER ===" -ForegroundColor Cyan

$allDuplicates = @()

# METHOD 1: Registry (Uninstall keys)
Write-Host "`n[Method 1] Scanning Registry..." -ForegroundColor Green
$regPaths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$regApps = @()
foreach ($path in $regPaths) {
  $regApps += Get-ItemProperty $path -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName } |
    Select-Object DisplayName, DisplayVersion, UninstallString
}

# METHOD 2: Win32_Product
Write-Host "[Method 2] Scanning Win32_Product..." -ForegroundColor Green
$win32Apps = Get-WmiObject -Class Win32_Product -ErrorAction SilentlyContinue |
  Select-Object Name, Version, @{N='UninstallString';E={$_.IdentifyingNumber}}

# METHOD 3: AppX Packages
Write-Host "[Method 3] Scanning AppX Packages..." -ForegroundColor Green
$appxApps = Get-AppxPackage -AllUsers -ErrorAction SilentlyContinue |
  Select-Object Name, Version, @{N='UninstallString';E={$_.PackageFullName}}

# METHOD 4: Chocolatey (if installed)
Write-Host "[Method 4] Scanning Chocolatey..." -ForegroundColor Green
if (Get-Command choco -ErrorAction SilentlyContinue) {
  $chocoApps = choco list --local-only | Select-String "^\w" |
    ForEach-Object { $_.Line }
} else {
  $chocoApps = @()
}

# METHOD 5: Program Files folders
Write-Host "[Method 5] Scanning Program Files..." -ForegroundColor Green
$programFolders = @(
  "$env:ProgramFiles",
  "${env:ProgramFiles(x86)}",
  "$env:LOCALAPPDATA\Programs"
)

$folderApps = @()
foreach ($folder in $programFolders) {
  if (Test-Path $folder) {
    $folderApps += Get-ChildItem -Path $folder -Directory -ErrorAction SilentlyContinue |
      Select-Object Name, @{N='Path';E={$_.FullName}}
  }
}

# COMBINE AND FIND DUPLICATES
Write-Host "`n[Analysis] Finding Duplicates..." -ForegroundColor Yellow

# Combine all sources
$allApps = @()
$allApps += $regApps | Select-Object @{N='Name';E={$_.DisplayName}}, @{N='Version';E={$_.DisplayVersion}}, @{N='Source';E={'Registry'}}, UninstallString
$allApps += $win32Apps | Select-Object @{N='Name';E={$_.Name}}, Version, @{N='Source';E={'Win32'}}, UninstallString
$allApps += $appxApps | Select-Object Name, Version, @{N='Source';E={'AppX'}}, UninstallString

# Group by base name
$grouped = $allApps | Where-Object { $_.Name } |
  Group-Object { $_.Name -replace '\s+\d+(\.\d+)*.*$', '' -replace '\s+\(.*\)$', '' }

$duplicates = $grouped | Where-Object { $_.Count -gt 1 }

Write-Host "`nFound $($duplicates.Count) programs with multiple versions:`n" -ForegroundColor Cyan

foreach ($group in $duplicates) {
  Write-Host "[$($group.Name)]" -ForegroundColor Cyan
  $sorted = $group.Group | Sort-Object Version -Descending
  
  $keep = $sorted[0]
  Write-Host "  KEEP:   $($keep.Name) v$($keep.Version) [$($keep.Source)]" -ForegroundColor Green
  
  $remove = $sorted | Select-Object -Skip 1
  foreach ($old in $remove) {
    Write-Host "  REMOVE: $($old.Name) v$($old.Version) [$($old.Source)]" -ForegroundColor Red
    
    if ($Apply) {
      try {
        if ($old.Source -eq 'Win32' -and $old.UninstallString) {
          $product = Get-WmiObject -Class Win32_Product | Where-Object { $_.IdentifyingNumber -eq $old.UninstallString }
          if ($product) {
            $product.Uninstall() | Out-Null
            Write-Host "    UNINSTALLED (Win32)" -ForegroundColor Yellow
          }
        }
        elseif ($old.Source -eq 'AppX') {
          Remove-AppxPackage -Package $old.UninstallString -ErrorAction SilentlyContinue
          Write-Host "    UNINSTALLED (AppX)" -ForegroundColor Yellow
        }
        elseif ($old.Source -eq 'Registry' -and $old.UninstallString) {
          Start-Process -FilePath "cmd.exe" -ArgumentList "/c $($old.UninstallString) /quiet" -Wait -NoNewWindow -ErrorAction SilentlyContinue
          Write-Host "    UNINSTALLED (Registry)" -ForegroundColor Yellow
        }
      } catch {
        Write-Host "    FAILED: $($_.Exception.Message)" -ForegroundColor Red
      }
    }
  }
  Write-Host ""
}

# SHOW FOLDER DUPLICATES
Write-Host "`n[Folder Analysis] Duplicate Program Folders:" -ForegroundColor Yellow
$folderDupes = $folderApps | Group-Object { $_.Name -replace '\s+\d+(\.\d+)*.*$', '' } |
  Where-Object { $_.Count -gt 1 }

foreach ($group in $folderDupes) {
  Write-Host "`n[$($group.Name)]" -ForegroundColor Cyan
  foreach ($folder in $group.Group) {
    Write-Host "  $($folder.Path)" -ForegroundColor Gray
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Duplicate programs: $($duplicates.Count)" -ForegroundColor Yellow
Write-Host "Duplicate folders: $($folderDupes.Count)" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "`nRun with -Apply to remove duplicates:" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\find-all-duplicates.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`nDuplicate removal complete!" -ForegroundColor Green
  Write-Host "Restart recommended" -ForegroundColor Yellow
}
