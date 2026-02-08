param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== COMPLETE SYSTEM UPDATE & CHECK ===" -ForegroundColor Cyan

# 1. WINDOWS UPDATE
Write-Host "`n[1/8] Windows Update..." -ForegroundColor Green
if ($Apply) {
  Install-Module PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction SilentlyContinue
  Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot -ErrorAction SilentlyContinue
  Write-Host "  Windows updates installed" -ForegroundColor Gray
} else {
  $updates = Get-WindowsUpdate -ErrorAction SilentlyContinue
  Write-Host "  Available updates: $($updates.Count)" -ForegroundColor Yellow
}

# 2. WINGET APPS
Write-Host "`n[2/8] Updating Apps (winget)..." -ForegroundColor Green
if ($Apply) {
  winget upgrade --all --accept-source-agreements --accept-package-agreements --silent
} else {
  winget upgrade --all
}

# 3. MICROSOFT STORE APPS
Write-Host "`n[3/8] Microsoft Store Apps..." -ForegroundColor Green
if ($Apply) {
  Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" |
    Invoke-CimMethod -MethodName UpdateScanMethod -ErrorAction SilentlyContinue
  Write-Host "  Store apps update triggered" -ForegroundColor Gray
}

# 4. DRIVERS
Write-Host "`n[4/8] Checking Drivers..." -ForegroundColor Green
if ($Apply) {
  pnputil /scan-devices
  Write-Host "  Driver scan completed" -ForegroundColor Gray
}
$drivers = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceName -and $_.DriverVersion }
Write-Host "  Total drivers: $($drivers.Count)" -ForegroundColor Gray

# 5. POWERSHELL MODULES
Write-Host "`n[5/8] PowerShell Modules..." -ForegroundColor Green
if ($Apply) {
  Update-Module -Force -ErrorAction SilentlyContinue
  Write-Host "  Modules updated" -ForegroundColor Gray
}

# 6. VS CODE EXTENSIONS
Write-Host "`n[6/8] VS Code Extensions..." -ForegroundColor Green
if ($Apply) {
  code --update-extensions
  Write-Host "  Extensions updated" -ForegroundColor Gray
}

# 7. SYSTEM HEALTH CHECK
Write-Host "`n[7/8] System Health..." -ForegroundColor Green
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$mem = Get-CimInstance Win32_PhysicalMemory

Write-Host "  OS: $($os.Caption) Build $($os.BuildNumber)" -ForegroundColor Gray
Write-Host "  CPU: $($cpu.Name) - $($cpu.LoadPercentage)% usage" -ForegroundColor Gray
Write-Host "  RAM: $([math]::Round(($mem | Measure-Object Capacity -Sum).Sum / 1GB, 2)) GB" -ForegroundColor Gray
Write-Host "  Disk C: $([math]::Round($disk.FreeSpace / 1GB, 2)) GB free / $([math]::Round($disk.Size / 1GB, 2)) GB total" -ForegroundColor Gray

# 8. SECURITY CHECK
Write-Host "`n[8/8] Security Status..." -ForegroundColor Green
$defender = Get-MpComputerStatus
$firewall = Get-NetFirewallProfile

Write-Host "  Defender:" -ForegroundColor Gray
Write-Host "    Real-time: $($defender.RealTimeProtectionEnabled)" -ForegroundColor $(if($defender.RealTimeProtectionEnabled){'Green'}else{'Red'})
Write-Host "    Last scan: $($defender.QuickScanEndTime)" -ForegroundColor Gray
Write-Host "    Signatures: $($defender.AntivirusSignatureLastUpdated)" -ForegroundColor Gray

Write-Host "  Firewall:" -ForegroundColor Gray
foreach ($fw in $firewall) {
  Write-Host "    $($fw.Name): $($fw.Enabled)" -ForegroundColor $(if($fw.Enabled){'Green'}else{'Red'})
}

# FINAL CHECKS
Write-Host "`n=== FINAL VERIFICATION ===" -ForegroundColor Cyan

# Check for issues
$issues = @()

if (-not $defender.RealTimeProtectionEnabled) { $issues += "Defender real-time protection OFF" }
if ($cpu.LoadPercentage -gt 80) { $issues += "High CPU usage: $($cpu.LoadPercentage)%" }
if ($disk.FreeSpace / $disk.Size -lt 0.1) { $issues += "Low disk space: $([math]::Round($disk.FreeSpace / 1GB, 2)) GB" }
if (-not ($firewall | Where-Object { $_.Enabled })) { $issues += "Firewall disabled" }

if ($issues.Count -gt 0) {
  Write-Host "`nISSUES FOUND:" -ForegroundColor Red
  foreach ($issue in $issues) {
    Write-Host "  - $issue" -ForegroundColor Yellow
  }
} else {
  Write-Host "`nALL CHECKS PASSED!" -ForegroundColor Green
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan

if (-not $Apply) {
  Write-Host "Run with -Apply to update everything:" -ForegroundColor Yellow
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\update-everything.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "All updates completed!" -ForegroundColor Green
  Write-Host "Restart recommended" -ForegroundColor Yellow
}
