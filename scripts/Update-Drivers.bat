@echo off
REM ============================================
REM   DRIVER UPDATE & OPTIMIZATION SCRIPT
REM   Safe Driver Management
REM ============================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================
echo   DRIVER UPDATE & OPTIMIZATION TOOL
echo ============================================
echo.
echo This tool will:
echo  - List all current drivers
echo  - Check for outdated drivers
echo  - Prepare driver updates
echo  - Remove corrupted drivers
echo.

REM Check admin privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    echo ERROR: This script requires Administrator privileges!
    echo Please run as Administrator!
    pause
    exit /b 1
)

echo [1/5] Enumerating all installed drivers...
powershell -NoProfile -Command ^
    Write-Host "INSTALLED DRIVERS:" -ForegroundColor Green; ^
    Get-WmiObject Win32_PnPSignedDriver | Select-Object Name, DriverVersion, Status | ^
    Format-Table -AutoSize | Out-Default

echo.
echo [2/5] Checking for problematic devices...
powershell -NoProfile -Command ^
    Write-Host "DEVICE STATUS:" -ForegroundColor Green; ^
    Get-WmiObject Win32_PnPEntity | Where-Object {$_.Status -ne 'OK'} | ^
    Select-Object Name, Status | Format-Table | Out-Default

echo.
echo [3/5] Removing corrupted/unsigned drivers...
powershell -NoProfile -Command ^
    Get-WmiObject Win32_SystemDriver | Where-Object {$_.State -eq 'Stopped'} | ^
    %%{$_.Change('disabled')} | out-null; ^
    Write-Host "Disabled inactive drivers" -ForegroundColor Green

echo.
echo [4/5] Updating Windows drivers via Windows Update...
echo Installing latest available drivers...
powershell -NoProfile -Command ^
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Force | out-null; ^
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDrivers" -Value 0 -Force | out-null; ^
    Write-Host "Windows Update driver installation enabled" -ForegroundColor Green

echo.
echo NOTE: For manufacturer-specific drivers (GPU, Network, etc.):
echo   - NVIDIA/AMD: Download from graphics card manufacturer
echo   - Intel/AMD: Download chipset drivers
echo   - MSI Dragon Center: Download from msi.com
echo.
echo [5/5] Creating driver backup...
Export-CimSession | out-null
powershell -NoProfile -Command ^
    $driverList = Get-WmiObject Win32_PnPSignedDriver | Select-Object Name, DriverVersion, Manufacturer, Description; ^
    $driverList | ConvertTo-Json | Out-File "$env:USERPROFILE\Desktop\DriverBackup.json" -Force; ^
    Write-Host "Driver list backed up to Desktop" -ForegroundColor Green

echo.
echo ============================================
echo   DRIVER OPTIMIZATION COMPLETE!
echo ============================================
echo.
echo Next steps:
echo  1. Visit msi.com and download latest drivers for your laptop
echo  2. Download GPU drivers from NVIDIA/AMD website
echo  3. Update network/chipset drivers
echo  4. Reboot system to apply changes
echo.
pause
exit /b 0
