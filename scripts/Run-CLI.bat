@echo off
REM Run the CLI application
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"

echo.
echo ========================================
echo   Modern App CLI
echo ========================================
echo.

node dist/cli/index.js %*
pause
