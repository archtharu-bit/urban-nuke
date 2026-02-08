param([switch]$Force)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== REBUILD CODIUM/VS CODE ===" -ForegroundColor Cyan

# 1. Check for status bar issues
Write-Host "`n[1/5] Checking for issues..." -ForegroundColor Green
$vscodeProcesses = Get-Process -Name "Code" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
  Write-Host "  VS Code is running" -ForegroundColor Yellow
  if ($Force) {
    Write-Host "  Closing VS Code..." -ForegroundColor Yellow
    $vscodeProcesses | Stop-Process -Force
    Start-Sleep -Seconds 2
  } else {
    Write-Host "  Close VS Code manually or use -Force" -ForegroundColor Red
    exit
  }
}

# 2. Clear extension cache
Write-Host "`n[2/5] Clearing extension cache..." -ForegroundColor Green
$cachePaths = @(
  "$env:USERPROFILE\.vscode\extensions",
  "$env:APPDATA\Code\Cache",
  "$env:APPDATA\Code\CachedData",
  "$env:APPDATA\Code\CachedExtensions",
  "$env:APPDATA\Code\CachedExtensionVSIXs"
)

foreach ($path in $cachePaths) {
  if (Test-Path $path) {
    Write-Host "  Clearing: $path" -ForegroundColor Gray
    Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
  }
}

# 3. Reinstall problematic extensions
Write-Host "`n[3/5] Reinstalling extensions..." -ForegroundColor Green
$extensions = @(
  'Codeium.codeium',
  'eamodio.gitlens',
  'Continue.continue'
)

foreach ($ext in $extensions) {
  Write-Host "  Reinstalling: $ext" -ForegroundColor Yellow
  code --uninstall-extension $ext --force
  Start-Sleep -Seconds 1
  code --install-extension $ext --force
}

# 4. Reset settings
Write-Host "`n[4/5] Resetting conflicting settings..." -ForegroundColor Green
$settingsPath = "c:\Users\VVIP_44\Downloads\Telegram Desktop\.vscode\settings.json"
if (Test-Path $settingsPath) {
  $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
  
  # Disable conflicting features
  $settings.'codeium.enableCodeLens' = $false
  $settings.'gitlens.codeLens.enabled' = $false
  $settings.'gitlens.blame.highlight.enabled' = $false
  $settings.'workbench.statusBar.visible' = $true
  
  $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
  Write-Host "  Settings updated" -ForegroundColor Green
}

# 5. Start VS Code
Write-Host "`n[5/5] Starting VS Code..." -ForegroundColor Green
Start-Process "code" -ArgumentList "c:\Users\VVIP_44\Downloads\Telegram Desktop"

Write-Host "`n=== REBUILD COMPLETE ===" -ForegroundColor Cyan
Write-Host "VS Code restarted with clean configuration" -ForegroundColor Green
Write-Host "Status bar should now work correctly" -ForegroundColor Green
