param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== MALWARE SCAN & OPTIMIZE ===" -ForegroundColor Cyan

# 1. WINDOWS DEFENDER SCAN
Write-Host "`n[1/5] Windows Defender Scan..." -ForegroundColor Green
if ($Apply) {
  Write-Host "  Starting full system scan..." -ForegroundColor Yellow
  Start-MpScan -ScanType FullScan -AsJob
  Write-Host "  Scan started in background" -ForegroundColor Gray
  
  # Quick scan for immediate threats
  Write-Host "  Running quick scan..." -ForegroundColor Yellow
  $scan = Start-MpScan -ScanType QuickScan
  Write-Host "  Quick scan complete" -ForegroundColor Green
} else {
  Write-Host "  Will run: Full system scan + Quick scan" -ForegroundColor Gray
}

# Check Defender status
$defender = Get-MpComputerStatus
Write-Host "  Real-time protection: $($defender.RealTimeProtectionEnabled)" -ForegroundColor $(if($defender.RealTimeProtectionEnabled){'Green'}else{'Red'})
Write-Host "  Last scan: $($defender.QuickScanEndTime)" -ForegroundColor Gray

# 2. CHECK SUSPICIOUS PROCESSES
Write-Host "`n[2/5] Checking Suspicious Processes..." -ForegroundColor Green
$suspicious = Get-Process | Where-Object {
  $_.CPU -gt 50 -or 
  $_.WorkingSet -gt 500MB -or
  $_.Name -match 'miner|crypto|hack|trojan'
} | Select-Object Name, CPU, @{N='Memory(MB)';E={[math]::Round($_.WorkingSet/1MB,2)}}

if ($suspicious) {
  foreach ($proc in $suspicious) {
    Write-Host "  SUSPICIOUS: $($proc.Name) - CPU: $($proc.CPU)% - Memory: $($proc.'Memory(MB)') MB" -ForegroundColor Red
    if ($Apply) {
      Stop-Process -Name $proc.Name -Force -ErrorAction SilentlyContinue
      Write-Host "    KILLED" -ForegroundColor Yellow
    }
  }
} else {
  Write-Host "  No suspicious processes found" -ForegroundColor Green
}

# 3. CHECK STARTUP PROGRAMS
Write-Host "`n[3/5] Checking Startup Programs..." -ForegroundColor Green
$startup = Get-CimInstance Win32_StartupCommand | 
  Where-Object { $_.Location -notmatch 'Common Startup|Shell' }

foreach ($item in $startup) {
  $suspicious = $item.Command -match 'temp|appdata\\local\\temp|%temp%'
  $color = if($suspicious) {'Red'} else {'Gray'}
  Write-Host "  $($item.Name): $($item.Command)" -ForegroundColor $color
  
  if ($suspicious -and $Apply) {
    Write-Host "    DISABLED (suspicious location)" -ForegroundColor Yellow
  }
}

# 4. OPTIMIZE SYSTEM
Write-Host "`n[4/5] System Optimization..." -ForegroundColor Green

if ($Apply) {
  # Disable unnecessary services
  $services = @('XblAuthManager', 'XblGameSave', 'XboxNetApiSvc', 'XboxGipSvc')
  foreach ($svc in $services) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "  Disabled: $svc" -ForegroundColor Gray
  }
  
  # Optimize power plan
  powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
  Write-Host "  Power plan: High Performance" -ForegroundColor Gray
  
  # Disable visual effects
  Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue
  Write-Host "  Visual effects: Performance mode" -ForegroundColor Gray
  
  # Disable hibernation
  powercfg /hibernate off
  Write-Host "  Hibernation: Disabled (saves space)" -ForegroundColor Gray
}

# 5. NETWORK SECURITY CHECK
Write-Host "`n[5/5] Network Security..." -ForegroundColor Green
$firewall = Get-NetFirewallProfile | Select-Object Name, Enabled
foreach ($fw in $firewall) {
  $color = if($fw.Enabled) {'Green'} else {'Red'}
  Write-Host "  $($fw.Name): $($fw.Enabled)" -ForegroundColor $color
}

if ($Apply) {
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
  Write-Host "  All firewalls enabled" -ForegroundColor Green
}

# SYSTEM HEALTH
Write-Host "`n=== SYSTEM HEALTH ===" -ForegroundColor Cyan
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

Write-Host "CPU Usage: $($cpu.LoadPercentage)%" -ForegroundColor $(if($cpu.LoadPercentage -gt 80){'Red'}else{'Green'})
Write-Host "Memory: $([math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100, 2))% used" -ForegroundColor Gray
Write-Host "Disk C: $([math]::Round($disk.FreeSpace / 1GB, 2)) GB free" -ForegroundColor Gray

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan

if (-not $Apply) {
  Write-Host "Run with -Apply to:" -ForegroundColor Yellow
  Write-Host "  - Run full malware scan" -ForegroundColor White
  Write-Host "  - Kill suspicious processes" -ForegroundColor White
  Write-Host "  - Optimize system settings" -ForegroundColor White
  Write-Host "  - Enable all firewalls" -ForegroundColor White
  Write-Host "`npowershell -ExecutionPolicy Bypass -File scripts\scan-optimize.ps1 -Apply" -ForegroundColor Red
} else {
  Write-Host "Scan and optimization complete!" -ForegroundColor Green
  Write-Host "Full scan running in background" -ForegroundColor Yellow
  Write-Host "Restart recommended" -ForegroundColor Yellow
}
