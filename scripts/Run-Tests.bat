@echo off
REM Run the test suite
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"

echo.
echo ========================================
echo   Running Test Suite
echo ========================================
echo.

npm test -- --run
pause
