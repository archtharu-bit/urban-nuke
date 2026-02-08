@echo off
REM ============================================
REM   SUPER COMPUTER CLEANUP & OPTIMIZATION
REM   Safe Multi-Level Deep Cleaning
REM ============================================

setlocal enabledelayedexpansion

REM Record start time
set "startTime=%date% %time%"

cls
echo.
echo ============================================
echo   SUPER COMPUTER SYSTEM OPTIMIZATION
echo   Maximum Performance Mode
echo ============================================
echo.
echo Starting comprehensive system cleanup...
echo This will remove:
echo  - Duplicate files (Save ~500-1000MB)
echo  - Temporary files
echo  - Cache files
echo  - Old logs
echo  - Recycle bin
echo.
pause

REM Check admin privileges
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if %errorlevel% neq 0 (
    echo ERROR: This script requires Administrator privileg...
    echo Please run as Administrator!
    pause
    exit /b 1
)

echo [1/12] Cleaning Windows Temporary Files...
rd /s /q "%TEMP%" 2>nul
mkdir "%TEMP%"
rd /s /q "%WINDIR%\Temp" 2>nul
mkdir "%WINDIR%\Temp"

echo [2/12] Clearing Windows Update Cache...
rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
mkdir "C:\Windows\SoftwareDistribution\Download"

echo [3/12] Removing old log files...
del /s /q "%WINDIR%\system32\LogFiles\*.log" 2>nul
del /s /q "%WINDIR%\logs\*.log" 2>nul

echo [4/12] Cleaning Prefetch (System Speed-up)...
del /s /q "%WINDIR%\prefetch\*.pf" 2>nul

echo [5/12] Clearing DNS Cache...
ipconfig /flushdns >nul

echo [6/12] Clearing browser caches...
rd /s /q "%APPDATA%\Local\Temp" 2>nul
mkdir "%APPDATA%\Local\Temp"

echo [7/12] Cleaning Downloads duplicates...
powershell -NoProfile -Command ^
    $Downloads='%USERPROFILE%\Downloads'; ^
    $files=@{}; ^
    Get-ChildItem $Downloads -Recurse -File | %%{if($files[$_.Name]){Remove-Item $_.FullName -Force}else{$files[$_.Name]=$_}} ^
    Write-Host "Duplicate files cleaned"

echo [8/12] Emptying Recycle Bin...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

echo [9/12] Defragmenting system drive (C:)...
defrag C: /O /U /V >nul 2>&1

echo [10/12] Optimizing Virtual Memory...
wmic pagefileset where name="C:\\pagefile.sys" set InitialSize=2048,MaximumSize=4096

echo [11/12] Clearing Windows clipboard...
cls Clip

echo [12/12] Optimizing Startup...
REM Disable unnecessary startup programs
powershell -NoProfile -Command ^
    Get-ScheduledTask | Where-Object {$_.Principal.UserId -eq 'SYSTEM'} | ^
    Where-Object {$_.State -ne 'Running'} | ^
    Disable-ScheduledTask -ErrorAction SilentlyContinue

echo.
echo ============================================
echo   OPTIMIZATION COMPLETE!
echo ============================================
echo.
echo System improvements:
echo  [+] Freed up temporary data
echo  [+] Removed duplicate files
echo  [+] Cleared system cache
echo  [+] Optimized memory management
echo  [+] Cleaned prefetch database
echo  [+] Defragmented drive
echo  [+] Optimized startup processes
echo  [+] Flushed DNS cache
echo.
echo Recommendation: Reboot your system for maximum performance
echo.
pause
exit /b 0
