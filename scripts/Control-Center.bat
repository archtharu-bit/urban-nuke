@echo off
REM Modern App Control Center
setlocal enabledelayedexpansion

:menu
cls
echo.
echo ========================================
echo   MODERN APP - Control Center
echo ========================================
echo.
echo   Project: C:\Users\VVIP_44\Downloads\CodebaseProject
echo.
echo   Select an action:
echo.
echo   1. Start API Server (Production)
echo   2. Start Dev Mode (Hot-reload)
echo   3. Run CLI
echo   4. Run Tests
echo   5. Check API Health
echo   6. Open in VS Code
echo   7. Lint & Format Code
echo   8. Build Project
echo   9. Exit
echo.
set /p choice="Enter choice (1-9): "

if "%choice%"=="1" goto start_api
if "%choice%"=="2" goto dev_mode
if "%choice%"=="3" goto cli
if "%choice%"=="4" goto tests
if "%choice%"=="5" goto health
if "%choice%"=="6" goto vscode
if "%choice%"=="7" goto lint
if "%choice%"=="8" goto build
if "%choice%"=="9" goto exit_menu

echo Invalid choice. Please try again.
timeout /t 2
goto menu

:start_api
cls
echo Starting API Server...
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
npm start
goto menu

:dev_mode
cls
echo Starting Development Mode...
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
npm run dev
goto menu

:cli
cls
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
echo Running CLI...
node dist/cli/index.js
goto menu

:tests
cls
echo Running Test Suite...
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
npm test -- --run
goto menu

:health
cls
echo Checking API Health...
timeout /t 2
curl -f http://localhost:3000/health
if errorlevel 1 (
    echo.
    echo SERVER NOT RUNNING - Start with option 1 or 2
) else (
    echo.
    echo API SERVER HEALTHY!
)
pause
goto menu

:vscode
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
code .
goto menu

:lint
cls
echo Linting and formatting code...
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
npm run lint:fix
npm run format
echo Done!
pause
goto menu

:build
cls
echo Building project...
cd /d "C:\Users\VVIP_44\Downloads\CodebaseProject"
npm run build
echo Done!
pause
goto menu

:exit_menu
exit /b 0
