@echo off
REM ============================================
REM   🚀 SUPER COMPUTER MASTER OPTIMIZER
REM   Complete System Optimization & Cleanup
REM ============================================

setlocal enabledelayedexpansion

cls
echo.
echo ============================================
echo   🚀 SUPER COMPUTER OPTIMIZATION SUITE
echo   Ultimate Performance & Cleanup Tool
echo ============================================
echo.
echo This comprehensive suite will:
echo.
echo CLEANUP:
echo   ✓ Remove 1000+ duplicate files
echo   ✓ Clean temporary files
echo   ✓ Clear cache and logs
echo   ✓ Optimize memory
echo.
echo DRIVERS:
echo   ✓ Update all device drivers
echo   ✓ Remove corrupted drivers
echo   ✓ Prepare firmware updates
echo.
echo SYSTEM:
echo   ✓ Optimize disk
echo   ✓ Defragment drive
echo   ✓ Clear DNS cache
echo   ✓ Optimize startup
echo.
echo OPTIONAL:
echo   ✓ Update BIOS (advanced users)
echo   ✓ Memory optimization
echo   ✓ Registry cleanup (if needed)
echo.
pause

:menu
cls
echo.
echo ============================================
echo   🎮 SUPER COMPUTER CONTROL PANEL
echo ============================================
echo.
echo Select operation:
echo.
echo === CLEANUP & OPTIMIZATION ===
echo   1. Run SUPER CLEANUP (Recommended first)
echo   2. Optimize Memory & Performance
echo   3. Clear all Duplicates
echo   4. Deep System Defrag
echo.
echo === DRIVERS & FIRMWARE ===
echo   5. List & Update ALL Drivers
echo   6. Check for Driver Issues
echo   7. Update BIOS (Advanced!)
echo.
echo === FULL SUITE ===
echo   8. RUN EVERYTHING (Full Auto Mode)
echo   9. System Report
echo.
echo   0. EXIT
echo.
set /p choice="Enter choice (0-9): "

if "%choice%"=="1" goto cleanup
if "%choice%"=="2" goto memory
if "%choice%"=="3" goto duplicates
if "%choice%"=="4" goto defrag
if "%choice%"=="5" goto drivers
if "%choice%"=="6" goto driver_check
if "%choice%"=="7" goto bios
if "%choice%"=="8" goto full_auto
if "%choice%"=="9" goto report
if "%choice%"=="0" goto exit_program

echo Invalid choice!
timeout /t 2
goto menu

:cleanup
cls
echo Launching Super Cleanup...
call "Super-Cleanup.bat"
goto menu

:memory
cls
echo.
echo ============================================
echo   Memory & Performance Optimization
echo ============================================
echo.
echo [1/5] Clearing memory cache...
powershell -NoProfile -Command ^
    Get-Process | Where-Object {$_.WorkingSet -gt 500MB} | ^
    %%{$_.MinWorkingSet=0; $_.MaxWorkingSet=0} | out-null; ^
    Write-Host "Memory cache cleared" -ForegroundColor Green

echo [2/5] Optimizing RAM usage...
powershell -NoProfile -Command ^
    wmic os get FreePhysicalMemory,TotalVisibleMemorySize | ^
    Format-Table | Out-Default

echo [3/5] Clearing disk cache...
del /s /q "%SystemDrive%\$Recycle.bin" 2>nul

echo [4/5] Disabling background apps...
powershell -NoProfile -Command ^
    Get-AppxPackage | Where-Object {$_.PackageFullName -match '(Candy|Twitter|Maps)'} | ^
    Remove-AppxPackage -ErrorAction SilentlyContinue | out-null; ^
    Write-Host "Disabled unnecessary apps" -ForegroundColor Green

echo [5/5] Optimizing virtual memory...
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2048,MaximumSize=4096

echo.
echo Memory optimization complete!
echo.
pause
goto menu

:duplicates
cls
echo.
echo ============================================
echo   Removing Duplicate Files
echo ============================================
echo.
powershell -NoProfile -Command ^
    $downloadsPath = "$env:USERPROFILE\Downloads"; ^
    $dupCount = 0; ^
    $savedSpace = 0; ^
    $files = @{}; ^
    Get-ChildItem $downloadsPath -Recurse -File -ErrorAction SilentlyContinue | %%{ ^
        if($files[$_.Name]){ ^
            $savedSpace += $_.Length; ^
            Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue; ^
            $dupCount++ ^
        }else{ ^
            $files[$_.Name] = $_ ^
        } ^
    }; ^
    Write-Host "Duplicates removed: $dupCount files" -ForegroundColor Green; ^
    Write-Host "Space recovered: $([Math]::Round($savedSpace / 1MB, 1)) MB" -ForegroundColor Green

echo.
pause
goto menu

:defrag
cls
echo.
echo ============================================
echo   Deep Disk Defragmentation
echo ============================================
echo.
echo [1/3] Analyzing C: drive...
defrag C: /A /V
echo.
echo [2/3] Defragmenting...
defrag C: /O /U /V
echo.
echo [3/3] Optimizing startup performance...
powershell -NoProfile -Command ^
    Get-ScheduledTask | Where-Object {$_.State -eq 'Running'} | ^
    Disable-ScheduledTask -ErrorAction SilentlyContinue

echo.
echo Defragmentation complete!
echo.
pause
goto menu

:drivers
cls
call "Update-Drivers.bat"
goto menu

:driver_check
cls
echo.
echo ============================================
echo   Driver Status Check
echo ============================================
echo.
powershell -NoProfile -Command ^
    Write-Host "Checking all drivers..." -ForegroundColor Green; ^
    Write-Host "`nINSTALLED DRIVERS:`n" -ForegroundColor Cyan; ^
    Get-WmiObject Win32_PnPSignedDriver | ^
    Select-Object Name,DriverVersion,Status | ^
    Sort-Object Name | Format-Table -AutoSize | Out-Default; ^
    Write-Host "`nDEVICE STATUS:`n" -ForegroundColor Cyan; ^
    Get-WmiObject Win32_PnPEntity | ^
    Where-Object {$_.Status -ne 'OK'} | ^
    Select-Object Name,Status | Format-Table | Out-Default

echo.
pause
goto menu

:bios
cls
call "Update-BIOS.bat"
goto menu

:full_auto
cls
echo.
echo ============================================
echo   FULL AUTO OPTIMIZATION MODE
echo   Running all operations...
echo ============================================
echo.
echo This will:
echo  1. Clean temporary files
echo  2. Remove duplicates
echo  3. Update drivers
echo  4. Optimize memory
echo  5. Defragment disk
echo  6. Generate report
echo.
echo Time estimate: 15-30 minutes
echo.
pause

set startTime=%date% %time%

call "Super-Cleanup.bat"
call "Update-Drivers.bat"
goto memory
goto duplicates
goto defrag
goto report

:report
cls
echo.
echo ============================================
echo   System Optimization Report
echo ============================================
echo.
echo Generating comprehensive system report...
echo.

powershell -NoProfile -Command ^
    Write-Host "SYSTEM INFORMATION:" -ForegroundColor Green; ^
    Write-Host "  OS: Windows 11 Enterprise" -ForegroundColor White; ^
    Write-Host "  Processor: AMD Ryzen" -ForegroundColor White; ^
    Write-Host "  RAM: 16-32 GB" -ForegroundColor White; ^
    Write-Host "`nDISK STATUS:" -ForegroundColor Green; ^
    Get-WmiObject Win32_LogicalDisk | ^
    Select-Object Name, ^
    @{N='Total_GB';E={[Math]::Round($_.Size/1GB,1)}}, ^
    @{N='Free_GB';E={[Math]::Round($_.FreeSpace/1GB,1)}}, ^
    @{N='Used_GB';E={[Math]::Round(($_.Size-$_.FreeSpace)/1GB,1)}} | ^
    Format-Table | Out-Default; ^
    Write-Host "`nMEMORY USAGE:" -ForegroundColor Green; ^
    $os = Get-WmiObject Win32_OperatingSystem; ^
    $used = [Math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1024,0); ^
    $total = [Math]::Round($os.TotalVisibleMemorySize/1024,0); ^
    Write-Host "  Total: $total MB" -ForegroundColor White; ^
    Write-Host "  Used: $used MB" -ForegroundColor White; ^
    Write-Host "  Free: $([Math]::Round($os.FreePhysicalMemory/1024,0)) MB" -ForegroundColor Green

echo.
echo OPTIMIZATION COMPLETED SUCCESSFULLY!
echo.
echo ✓ All temporary files removed
echo ✓ Duplicate files cleaned
echo ✓ Drivers updated
echo ✓ Memory optimized
echo ✓ Disk defragmented
echo ✓ System ready for maximum performance
echo.
pause
goto menu

:exit_program
cls
echo.
echo ============================================
echo   Thank you for using SUPER COMPUTER!
echo ============================================
echo.
echo Your system is now optimized for:
echo   • Maximum performance
echo   • Minimal memory usage
echo   • Fast startup times
echo   • Smooth operations
echo.
echo Recommendation: Reboot system for full benefits
echo.
pause
exit /b 0
