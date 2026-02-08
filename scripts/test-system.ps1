param([switch]$Fix)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== COMPLETE SYSTEM TEST & CONFIGURATION ===" -ForegroundColor Cyan

$results = @{
  Passed = 0
  Failed = 0
  Fixed = 0
}

# TEST 1: PROJECT LOCATION
Write-Host "`n[1/15] Project Location..." -ForegroundColor Green
$projectPath = "c:\Users\VVIP_44\Downloads\Telegram Desktop"
if (Test-Path $projectPath) {
  Write-Host "  PASS: Project found at $projectPath" -ForegroundColor Green
  Set-Location $projectPath
  $results.Passed++
} else {
  Write-Host "  FAIL: Project not found" -ForegroundColor Red
  $results.Failed++
}

# TEST 2: SCRIPTS FOLDER
Write-Host "`n[2/15] Scripts Folder..." -ForegroundColor Green
$scriptsPath = Join-Path $projectPath "scripts"
if (Test-Path $scriptsPath) {
  $scriptCount = (Get-ChildItem -Path $scriptsPath -Filter "*.ps1" -Recurse).Count
  Write-Host "  PASS: $scriptCount PowerShell scripts found" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  FAIL: Scripts folder missing" -ForegroundColor Red
  $results.Failed++
}

# TEST 3: GIT
Write-Host "`n[3/15] Git..." -ForegroundColor Green
try {
  $gitVersion = git --version
  Write-Host "  PASS: $gitVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: Git not installed" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    winget install --id Git.Git -e --silent
    $results.Fixed++
  }
}

# TEST 4: NODE.JS
Write-Host "`n[4/15] Node.js..." -ForegroundColor Green
try {
  $nodeVersion = node --version
  Write-Host "  PASS: Node $nodeVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: Node.js not installed" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    winget install --id OpenJS.NodeJS -e --silent
    $results.Fixed++
  }
}

# TEST 5: PYTHON
Write-Host "`n[5/15] Python..." -ForegroundColor Green
try {
  $pythonVersion = python --version
  Write-Host "  PASS: $pythonVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: Python not installed" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    winget install --id Python.Python.3.12 -e --silent
    $results.Fixed++
  }
}

# TEST 6: VS CODE
Write-Host "`n[6/15] VS Code..." -ForegroundColor Green
try {
  $codeVersion = code --version | Select-Object -First 1
  Write-Host "  PASS: VS Code $codeVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: VS Code not installed" -ForegroundColor Red
  $results.Failed++
}

# TEST 7: DOCKER
Write-Host "`n[7/15] Docker..." -ForegroundColor Green
try {
  $dockerVersion = docker --version
  Write-Host "  PASS: $dockerVersion" -ForegroundColor Green
  $results.Passed++
} catch {
  Write-Host "  FAIL: Docker not installed" -ForegroundColor Red
  $results.Failed++
}

# TEST 8: OLLAMA
Write-Host "`n[8/15] Ollama..." -ForegroundColor Green
try {
  $ollamaVersion = ollama --version
  Write-Host "  PASS: $ollamaVersion" -ForegroundColor Green
  
  # Check models
  $models = ollama list
  if ($models -match 'mistral') {
    Write-Host "  PASS: Mistral model installed" -ForegroundColor Green
  } else {
    Write-Host "  WARN: Mistral model missing" -ForegroundColor Yellow
    if ($Fix) {
      ollama pull mistral
      $results.Fixed++
    }
  }
  $results.Passed++
} catch {
  Write-Host "  FAIL: Ollama not installed" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    winget install --id Ollama.Ollama -e --silent
    $results.Fixed++
  }
}

# TEST 9: API KEYS
Write-Host "`n[9/15] API Keys..." -ForegroundColor Green
$envFile = Join-Path $projectPath ".env"
if (Test-Path $envFile) {
  $envContent = Get-Content $envFile -Raw
  if ($envContent -match 'OPENAI_API_KEY') {
    Write-Host "  PASS: OpenAI key configured" -ForegroundColor Green
    $results.Passed++
  } else {
    Write-Host "  FAIL: OpenAI key missing" -ForegroundColor Red
    $results.Failed++
  }
} else {
  Write-Host "  FAIL: .env file missing" -ForegroundColor Red
  $results.Failed++
}

# TEST 10: VS CODE EXTENSIONS
Write-Host "`n[10/15] VS Code Extensions..." -ForegroundColor Green
$requiredExtensions = @('GitHub.copilot', 'Continue.continue', 'eamodio.gitlens')
$installed = code --list-extensions
$missing = @()

foreach ($ext in $requiredExtensions) {
  if ($installed -contains $ext) {
    Write-Host "  PASS: $ext" -ForegroundColor Green
  } else {
    Write-Host "  FAIL: $ext missing" -ForegroundColor Red
    $missing += $ext
    $results.Failed++
  }
}

if ($Fix -and $missing.Count -gt 0) {
  foreach ($ext in $missing) {
    code --install-extension $ext --force
    $results.Fixed++
  }
}

# TEST 11: DEFENDER
Write-Host "`n[11/15] Windows Defender..." -ForegroundColor Green
$defender = Get-MpComputerStatus
if ($defender.RealTimeProtectionEnabled) {
  Write-Host "  PASS: Real-time protection enabled" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  FAIL: Real-time protection disabled" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    Set-MpPreference -DisableRealtimeMonitoring $false
    $results.Fixed++
  }
}

# TEST 12: FIREWALL
Write-Host "`n[12/15] Firewall..." -ForegroundColor Green
$firewall = Get-NetFirewallProfile
$allEnabled = ($firewall | Where-Object { -not $_.Enabled }).Count -eq 0
if ($allEnabled) {
  Write-Host "  PASS: All firewall profiles enabled" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  FAIL: Some firewall profiles disabled" -ForegroundColor Red
  $results.Failed++
  if ($Fix) {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    $results.Fixed++
  }
}

# TEST 13: DISK SPACE
Write-Host "`n[13/15] Disk Space..." -ForegroundColor Green
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
$totalGB = [math]::Round($disk.Size / 1GB, 2)
$freePercent = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 2)

if ($freePercent -gt 20) {
  Write-Host "  PASS: $freeGB GB free ($freePercent%)" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  WARN: Low disk space: $freeGB GB free ($freePercent%)" -ForegroundColor Yellow
  $results.Failed++
}

# TEST 14: MEMORY
Write-Host "`n[14/15] Memory..." -ForegroundColor Green
$os = Get-CimInstance Win32_OperatingSystem
$totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedPercent = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 2)

Write-Host "  INFO: $totalRAM GB total, $freeRAM GB free ($usedPercent% used)" -ForegroundColor Gray
if ($usedPercent -lt 90) {
  Write-Host "  PASS: Memory usage normal" -ForegroundColor Green
  $results.Passed++
} else {
  Write-Host "  WARN: High memory usage" -ForegroundColor Yellow
}

# TEST 15: GITHUB CONNECTION
Write-Host "`n[15/15] GitHub Connection..." -ForegroundColor Green
try {
  $gitRemote = git remote get-url origin 2>&1
  if ($gitRemote -match 'github.com') {
    Write-Host "  PASS: Connected to $gitRemote" -ForegroundColor Green
    $results.Passed++
  } else {
    Write-Host "  WARN: No GitHub remote" -ForegroundColor Yellow
  }
} catch {
  Write-Host "  WARN: Not a git repository" -ForegroundColor Yellow
}

# SUMMARY
Write-Host "`n=== TEST SUMMARY ===" -ForegroundColor Cyan
Write-Host "Passed: $($results.Passed)" -ForegroundColor Green
Write-Host "Failed: $($results.Failed)" -ForegroundColor Red
if ($Fix) {
  Write-Host "Fixed: $($results.Fixed)" -ForegroundColor Yellow
}

$score = [math]::Round(($results.Passed / ($results.Passed + $results.Failed)) * 100, 2)
Write-Host "`nScore: $score%" -ForegroundColor $(if($score -gt 80){'Green'}elseif($score -gt 60){'Yellow'}else{'Red'})

if ($results.Failed -gt 0 -and -not $Fix) {
  Write-Host "`nRun with -Fix to automatically fix issues:" -ForegroundColor Yellow
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\test-system.ps1 -Fix" -ForegroundColor White
}

# CREATE QUICK ACCESS SHORTCUTS
Write-Host "`n=== CREATING SHORTCUTS ===" -ForegroundColor Cyan
$shortcuts = @{
  "Desktop\Urban Nuke.lnk" = $projectPath
  "Desktop\Run Tests.lnk" = "$projectPath\scripts\test-system.ps1"
  "Desktop\Fix System.lnk" = "$projectPath\scripts\update-everything.ps1"
}

foreach ($shortcut in $shortcuts.Keys) {
  $shortcutPath = Join-Path $env:USERPROFILE $shortcut
  $targetPath = $shortcuts[$shortcut]
  
  if ($Fix) {
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$targetPath`""
    $Shortcut.WorkingDirectory = $projectPath
    $Shortcut.Save()
    Write-Host "  Created: $shortcut" -ForegroundColor Green
  }
}

Write-Host "`n=== ALL TESTS COMPLETE ===" -ForegroundColor Cyan
