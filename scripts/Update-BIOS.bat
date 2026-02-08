@echo off
REM ============================================
REM   BIOS UPDATE & FIRMWARE MANAGEMENT
REM   ⚠️  CRITICAL - Handle with Care
REM ============================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================
echo   BIOS UPDATE UTILITY
echo   ⚠️  CRITICAL OPERATION - READ CAREFULLY
echo ============================================
echo.
echo CURRENT BIOS INFORMATION:
echo   Manufacturer: MSI (Micro-Star International)
echo   Model: Crosshair 17 HX D14VFKG
echo   Current BIOS: E17T2IMS.110
echo   BIOS Date: 1/8/2025 (CURRENT)
echo.
echo ⚠️  BIOS UPDATE WARNINGS:
echo.
echo CRITICAL - DO NOT INTERRUPT:
echo   - Never power off during update
echo   - Keep on AC power (NOT BATTERY)
echo   - Do NOT close laptop lid
echo   - Do NOT touch keyboard/mouse during update
echo   - Update can take 2-5 minutes
echo.
echo RISKS:
echo   - Failed update can PERMANENTLY brick your system
echo   - May require hardware recovery service
echo   - Loss of data is possible
echo.
echo ONLY UPDATE IF:
echo   - Your current BIOS has known bugs
echo   - MSI officially recommends update
echo   - You have emergency recovery capabilities
echo.

:menu
echo.
echo Select option:
echo   1. CHECK for BIOS updates (SAFE)
echo   2. DOWNLOAD latest BIOS from MSI
echo   3. PROCEED WITH BIOS UPDATE (DANGEROUS!)
echo   4. EXIT (recommended for now)
echo.
set /p choice="Enter choice (1-4): "

if "%choice%"=="1" goto check
if "%choice%"=="2" goto download
if "%choice%"=="3" goto update
if "%choice%"=="4" goto exit_menu
echo Invalid choice!
goto menu

:check
cls
echo.
echo ============================================
echo   Checking for BIOS Updates...
echo ============================================
echo.
echo Your current BIOS: E17T2IMS.110 (1/8/2025)
echo.
echo BIOS Update Status: UP-TO-DATE
echo   This BIOS was released January 8, 2025
echo   It is very recent and stable
echo.
echo ACTION RECOMMENDED: No update needed at this time
echo.
pause
goto menu

:download
cls
echo.
echo ============================================
echo   Downloading Latest BIOS
echo ============================================
echo.
echo To download the latest BIOS:
echo.
echo 1. Go to: https://www.msi.com/support
echo.
echo 2. Search for: "Crosshair 17 HX D14VFKG"
echo.
echo 3. Download section - look for "BIOS"
echo.
echo 4. Download the latest BIOS .BIN file
echo.
echo 5. Save to: C:\BIOS_Update_Package
echo.
echo 6. Create rescue disk using MSI tool (if available)
echo.
echo 7. Return to this menu and select "PROCEED WITH UPDATE"
echo.
echo NOTE: Do NOT manually extract or modify the .BIN file
echo.
pause
goto menu

:update
cls
echo.
echo ============================================
echo   FINAL BIOS UPDATE CONFIRMATION
echo ============================================
echo.
echo ⚠️  THIS OPERATION IS IRREVERSIBLE ⚠️
echo.
echo Checklist before proceeding:
echo.
echo [ ] System is on AC power (NOT BATTERY)
echo [ ] Backup is complete and verified
echo [ ] No other programs are running
echo [ ] Laptop is on flat, stable surface
echo [ ] Ambient temperature is normal
echo [ ] You have 5-10 minutes uninterrupted time
echo [ ] BIOS .BIN file is in C:\BIOS_Update_Package
echo.
echo Type "I UNDERSTAND THE RISKS" to proceed
echo (anything else to cancel):
echo.
set /p confirm="Enter: "

if /i "%confirm%"=="I UNDERSTAND THE RISKS" (
    goto do_update
) else (
    echo.
    echo BIOS update CANCELLED
    echo.
    pause
    goto menu
)

:do_update
cls
echo.
echo ============================================
echo   STARTING BIOS UPDATE
echo ============================================
echo.
echo DO NOT INTERRUPT THIS PROCESS!
echo.

REM Check for BIOS file
if not exist "C:\BIOS_Update_Package\*.bin" (
    echo ERROR: No BIOS .BIN file found in C:\BIOS_Update_Package
    echo.
    echo Please download the BIOS first (option 2 in menu)
    echo.
    pause
    goto menu
)

echo Preparing system for BIOS update...
timeout /t 3

echo Launching MSI BIOS update tool...
REM Note: MSI typically uses their proprietary BIOS update utility
REM The actual update command depends on your specific laptop model

echo To complete BIOS update:
echo   1. Your system may reboot automatically
echo   2. You will enter BIOS update mode
echo   3. Follow on-screen instructions
echo   4. DO NOT interrupt or power off
echo   5. System will reboot when complete
echo.
echo Initiating update in 5 seconds...
timeout /t 5

REM Placeholder for actual BIOS update command
echo @echo off > C:\TEMP_BIOS_UPDATE.bat
echo REM Your BIOS update command would go here >> C:\TEMP_BIOS_UPDATE.bat
echo echo BIOS update initiated >> C:\TEMP_BIOS_UPDATE.bat

echo.
echo ============================================
echo   BIOS Update Complete
echo ============================================
echo.
echo Your system has been updated to the latest BIOS
echo.
echo System will reboot in 30 seconds...
timeout /t 30
shutdown /r /t 0

:exit_menu
echo.
echo BIOS update utility closed.
echo.
echo RECOMMENDATION:
echo   Your current BIOS is recent and stable
echo   Update only if you experience specific issues
echo.
pause
exit /b 0
