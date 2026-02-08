@echo off
REM Check API server health
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"

echo.
echo ========================================
echo   Checking API Server Health
echo ========================================
echo.

timeout /t 2
curl -f http://localhost:3000/health
if errorlevel 1 (
    echo.
    echo ERROR: API server is not running
    echo Start it first with "Start-API-Server.bat"
) else (
    echo.
    echo SUCCESS: API server is healthy!
)
pause
