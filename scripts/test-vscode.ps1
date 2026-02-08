param([switch]$Fix)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== VS CODE SYSTEM TEST ===" -ForegroundColor Cyan

$results = @{
  Passed = 0
  Failed = 0
  Fixed = 0
}

# TEST 1: VS CODE INSTALLATION
Write-Host "`n[1/8] VS Code Installation..." -ForegroundColor Green
try {
  $codeVersion = code --version 2>&1 | Select-Object -First 1
  Write-Host "  PASS: VS Code $codeVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: VS Code not installed or not in PATH" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    winget install --id Microsoft.VisualStudioCode -e --silent
    $results.Fixed++
  }
}

# TEST 2: REQUIRED EXTENSIONS
Write-Host "`n[2/8] Required Extensions..." -ForegroundColor Green
$requiredExtensions = @{
  'GitHub.copilot' = 'GitHub Copilot'
  'Continue.continue' = 'Continue'
  'eamodio.gitlens' = 'GitLens'
  'ms-vscode-remote.remote-wsl' = 'Remote WSL'
  'ms-vscode-remote.remote-ssh' = 'Remote SSH'
  'ms-vscode.powershell' = 'PowerShell'
  'amazonwebservices.amazon-q-vscode' = 'Amazon Q'
}

try {
  $installed = code --list-extensions 2>&1
  $missing = @()
  
  foreach ($ext in $requiredExtensions.Keys) {
    if ($installed -contains $ext) {
      Write-Host "  PASS: $($requiredExtensions[$ext])" -ForegroundColor Green
      $results.Passed++
    } else {
      Write-Host "  FAIL: $($requiredExtensions[$ext]) missing" -ForegroundColor Red
      $missing += $ext
      $results.Failed++
    }
  }
  
  if ($Fix -and $missing.Count -gt 0) {
    foreach ($ext in $missing) {
      Write-Host "  Installing $ext..." -ForegroundColor Yellow
      code --install-extension $ext --force
      $results.Fixed++
    }
  }
} catch {
  Write-Host "  FAIL: Cannot list extensions" -ForegroundColor Red
  $results.Failed++
}

# TEST 3: SETTINGS FILE
Write-Host "`n[3/8] Settings File..." -ForegroundColor Green
$settingsPath = "$env:APPDATA\Code\User\settings.json"
if (Test-Path $settingsPath) {
  Write-Host "  PASS: Settings file exists" -ForegroundColor Green
  $results.Passed++
  
  $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
  if ($settings.'github.copilot.enable') {
    Write-Host "  PASS: Copilot enabled" -ForegroundColor Green
  } else {
    Write-Host "  WARN: Copilot not enabled in settings" -ForegroundColor Yellow
  }
} else {
  Write-Host "  FAIL: Settings file missing" -ForegroundColor Red
  $results.Failed++
}

# TEST 4: WORKSPACE SETTINGS
Write-Host "`n[4/8] Workspace Settings..." -ForegroundColor Green
$projectPath = "c:\Users\VVIP_44\Downloads\Telegram Desktop"
$vscodeFolder = Join-Path $projectPath ".vscode"
$workspaceSettings = Join-Path $vscodeFolder "settings.json"

if (Test-Path $workspaceSettings) {
  Write-Host "  PASS: Workspace settings exist" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  FAIL: Workspace settings missing" -ForegroundColor Red
  $results.Failed++
  
  if ($Fix) {
    if (-not (Test-Path $vscodeFolder)) {
      New-Item -ItemType Directory -Path $vscodeFolder -Force | Out-Null
    }
    
    $defaultSettings = @{
      "files.autoSave" = "afterDelay"
      "editor.formatOnSave" = $true
      "powershell.codeFormatting.preset" = "OTBS"
    } | ConvertTo-Json -Depth 10
    
    Set-Content -Path $workspaceSettings -Value $defaultSettings
    Write-Host "  Created default workspace settings" -ForegroundColor Green
    $results.Fixed++
  }
}

# TEST 5: CONTINUE CONFIGURATION
Write-Host "`n[5/8] Continue Configuration..." -ForegroundColor Green
$continueConfig = "$env:USERPROFILE\.continue\config.json"
if (Test-Path $continueConfig) {
  Write-Host "  PASS: Continue config exists" -ForegroundColor Green
  $results.Passed++
  
  $config = Get-Content $continueConfig -Raw | ConvertFrom-Json
  if ($config.models) {
    Write-Host "  INFO: $($config.models.Count) models configured" -ForegroundColor Gray
  }
} else {
  Write-Host "  WARN: Continue not configured yet" -ForegroundColor Yellow
}

# TEST 6: AMAZON Q
Write-Host "`n[6/8] Amazon Q..." -ForegroundColor Green
$amazonQPath = "$env:USERPROFILE\.aws\amazonq"
if (Test-Path $amazonQPath) {
  Write-Host "  PASS: Amazon Q directory exists" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  WARN: Amazon Q not configured" -ForegroundColor Yellow
}

# TEST 7: GITHUB COPILOT
Write-Host "`n[7/8] GitHub Copilot..." -ForegroundColor Green
$copilotHosts = "$env:USERPROFILE\.config\github-copilot\hosts.json"
if (Test-Path $copilotHosts) {
  Write-Host "  PASS: Copilot authenticated" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  WARN: Copilot not authenticated" -ForegroundColor Yellow
  Write-Host "  Run: code --command 'github.copilot.signIn'" -ForegroundColor Gray
}

# TEST 8: RECENT WORKSPACES
Write-Host "`n[8/8] Recent Workspaces..." -ForegroundColor Green
$storageFile = "$env:APPDATA\Code\User\globalStorage\storage.json"
if (Test-Path $storageFile) {
  $storage = Get-Content $storageFile -Raw | ConvertFrom-Json
  if ($storage.'workbench.panel.recentFolders') {
    Write-Host "  PASS: Recent workspaces tracked" -ForegroundColor Green
    $results.Passed++
  }
} else {
  Write-Host "  INFO: No workspace history yet" -ForegroundColor Gray
}

# SUMMARY
Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "Passed: $($results.Passed)" -ForegroundColor Green
Write-Host "Failed: $($results.Failed)" -ForegroundColor Red
if ($Fix) {
  Write-Host "Fixed: $($results.Fixed)" -ForegroundColor Yellow
}

$total = $results.Passed + $results.Failed
if ($total -gt 0) {
  $score = [math]::Round(($results.Passed / $total) * 100, 2)
  Write-Host "`nScore: $score%" -ForegroundColor $(if($score -gt 80){'Green'}elseif($score -gt 60){'Yellow'}else{'Red'})
}

if ($results.Failed -gt 0 -and -not $Fix) {
  Write-Host "`nRun with -Fix to automatically fix issues:" -ForegroundColor Yellow
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\test-vscode.ps1 -Fix" -ForegroundColor White
}

Write-Host "`n=== VS CODE TEST COMPLETE ===" -ForegroundColor Cyan
