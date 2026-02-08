param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== COMPLETE AI EXPLORATION & VERIFICATION ===" -ForegroundColor Cyan

$report = @{
  Installed = @()
  Missing = @()
  Configured = @()
  NotConfigured = @()
  Working = @()
  NotWorking = @()
}

# 1. EXPLORE VS CODE EXTENSIONS
Write-Host "`n[1/10] Exploring VS Code Extensions..." -ForegroundColor Green
$installed = code --list-extensions
$allExtensions = @{
  'GitHub.copilot' = 'GitHub Copilot (GPT-4)'
  'GitHub.copilot-chat' = 'Copilot Chat'
  'Continue.continue' = 'Continue (Multi-model)'
  'Codeium.codeium' = 'Codeium'
  'amazonwebservices.amazon-q-vscode' = 'Amazon Q'
  'TabNine.tabnine-vscode' = 'Tabnine'
  'supermaven.supermaven' = 'Supermaven'
  'Anthropic.claude-code' = 'Claude Code'
  'saoudrizwan.claude-dev' = 'Claude Dev (Cline)'
  'eamodio.gitlens' = 'GitLens'
  'ms-python.python' = 'Python'
  'ms-toolsai.jupyter' = 'Jupyter'
  'ms-vscode-remote.remote-containers' = 'Dev Containers'
  'ms-azuretools.vscode-docker' = 'Docker'
}

foreach ($ext in $allExtensions.Keys) {
  if ($installed -contains $ext) {
    Write-Host "  ✓ $($allExtensions[$ext])" -ForegroundColor Green
    $report.Installed += $allExtensions[$ext]
  } else {
    Write-Host "  ✗ $($allExtensions[$ext])" -ForegroundColor Red
    $report.Missing += $allExtensions[$ext]
    if ($Apply) {
      code --install-extension $ext --force
    }
  }
}

# 2. VERIFY OLLAMA & MODELS
Write-Host "`n[2/10] Verifying Ollama Models..." -ForegroundColor Green
try {
  $ollamaList = ollama list 2>&1
  if ($ollamaList -match 'NAME') {
    Write-Host "  ✓ Ollama running" -ForegroundColor Green
    $report.Working += "Ollama"
    
    $lines = $ollamaList -split "`n" | Select-Object -Skip 1
    foreach ($line in $lines) {
      if ($line.Trim()) {
        $modelName = ($line -split '\s+')[0]
        Write-Host "    • $modelName" -ForegroundColor Gray
        $report.Installed += "Ollama: $modelName"
      }
    }
  }
} catch {
  Write-Host "  ✗ Ollama not running" -ForegroundColor Red
  $report.NotWorking += "Ollama"
  if ($Apply) {
    Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
  }
}

# 3. TEST OLLAMA API
Write-Host "`n[3/10] Testing Ollama API..." -ForegroundColor Green
try {
  $response = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -TimeoutSec 5
  Write-Host "  ✓ API responding" -ForegroundColor Green
  $report.Working += "Ollama API"
} catch {
  Write-Host "  ✗ API not responding" -ForegroundColor Red
  $report.NotWorking += "Ollama API"
}

# 4. VERIFY API KEYS
Write-Host "`n[4/10] Verifying API Keys..." -ForegroundColor Green
$envFile = "c:\Users\VVIP_44\Downloads\Telegram Desktop\.env"
if (Test-Path $envFile) {
  $envContent = Get-Content $envFile -Raw
  $keys = @{
    'OPENAI_API_KEY' = 'OpenAI (GPT-4, GPT-4o)'
    'ANTHROPIC_API_KEY' = 'Anthropic (Claude)'
    'GOOGLE_API_KEY' = 'Google (Gemini)'
    'COHERE_API_KEY' = 'Cohere'
    'HUGGINGFACE_API_KEY' = 'HuggingFace'
  }
  
  foreach ($key in $keys.Keys) {
    if ($envContent -match $key) {
      Write-Host "  ✓ $($keys[$key])" -ForegroundColor Green
      $report.Configured += $keys[$key]
    } else {
      Write-Host "  ✗ $($keys[$key])" -ForegroundColor Yellow
      $report.NotConfigured += $keys[$key]
    }
  }
} else {
  Write-Host "  ✗ .env file not found" -ForegroundColor Red
}

# 5. VERIFY CONTINUE CONFIG
Write-Host "`n[5/10] Verifying Continue Configuration..." -ForegroundColor Green
$continueConfig = "$env:USERPROFILE\.continue\config.json"
if (Test-Path $continueConfig) {
  $config = Get-Content $continueConfig -Raw | ConvertFrom-Json
  Write-Host "  ✓ Continue configured" -ForegroundColor Green
  Write-Host "    Models: $($config.models.Count)" -ForegroundColor Gray
  foreach ($model in $config.models) {
    Write-Host "      • $($model.title)" -ForegroundColor Gray
  }
  $report.Configured += "Continue ($($config.models.Count) models)"
} else {
  Write-Host "  ✗ Continue not configured" -ForegroundColor Red
  $report.NotConfigured += "Continue"
}

# 6. VERIFY PYTHON AI PACKAGES
Write-Host "`n[6/10] Verifying Python AI Packages..." -ForegroundColor Green
$packages = @('openai', 'anthropic', 'langchain', 'transformers', 'torch')
foreach ($pkg in $packages) {
  try {
    $version = pip show $pkg 2>&1 | Select-String 'Version:'
    if ($version) {
      Write-Host "  ✓ $pkg" -ForegroundColor Green
      $report.Installed += "Python: $pkg"
    }
  } catch {
    Write-Host "  ✗ $pkg" -ForegroundColor Red
    $report.Missing += "Python: $pkg"
    if ($Apply) {
      pip install $pkg --quiet
    }
  }
}

# 7. VERIFY CLI TOOLS
Write-Host "`n[7/10] Verifying CLI Tools..." -ForegroundColor Green
$cliTools = @{
  'git' = 'git --version'
  'node' = 'node --version'
  'python' = 'python --version'
  'docker' = 'docker --version'
  'aws' = 'aws --version'
  'gh' = 'gh --version'
  'ollama' = 'ollama --version'
}

foreach ($tool in $cliTools.Keys) {
  try {
    $version = Invoke-Expression $cliTools[$tool] 2>&1 | Select-Object -First 1
    Write-Host "  ✓ $tool : $version" -ForegroundColor Green
    $report.Working += "CLI: $tool"
  } catch {
    Write-Host "  ✗ $tool not found" -ForegroundColor Red
    $report.NotWorking += "CLI: $tool"
  }
}

# 8. VERIFY DOCKER
Write-Host "`n[8/10] Verifying Docker..." -ForegroundColor Green
try {
  $dockerInfo = docker info 2>&1
  if ($dockerInfo -match 'Server Version') {
    Write-Host "  ✓ Docker running" -ForegroundColor Green
    $report.Working += "Docker"
    
    # Check dev containers
    $composeFile = "c:\Users\VVIP_44\Downloads\Telegram Desktop\docker-compose.yml"
    if (Test-Path $composeFile) {
      Write-Host "  ✓ docker-compose.yml found" -ForegroundColor Green
      $report.Configured += "Docker Compose"
    }
  }
} catch {
  Write-Host "  ✗ Docker not running" -ForegroundColor Red
  $report.NotWorking += "Docker"
}

# 9. VERIFY VS CODE SETTINGS
Write-Host "`n[9/10] Verifying VS Code Settings..." -ForegroundColor Green
$settingsPath = "c:\Users\VVIP_44\Downloads\Telegram Desktop\.vscode\settings.json"
if (Test-Path $settingsPath) {
  $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
  
  $criticalSettings = @{
    'github.copilot.enable' = 'Copilot enabled'
    'continue.enableTabAutocomplete' = 'Continue autocomplete'
    'workbench.statusBar.visible' = 'Status bar visible'
  }
  
  foreach ($setting in $criticalSettings.Keys) {
    $value = $settings.$setting
    if ($value) {
      Write-Host "  ✓ $($criticalSettings[$setting])" -ForegroundColor Green
      $report.Configured += $criticalSettings[$setting]
    } else {
      Write-Host "  ✗ $($criticalSettings[$setting])" -ForegroundColor Yellow
      $report.NotConfigured += $criticalSettings[$setting]
    }
  }
} else {
  Write-Host "  ✗ VS Code settings not found" -ForegroundColor Red
}

# 10. VERIFY WORKSPACE
Write-Host "`n[10/10] Verifying Workspace..." -ForegroundColor Green
$workspace = "c:\Users\VVIP_44\Downloads\Telegram Desktop\urban-nuke.code-workspace"
if (Test-Path $workspace) {
  Write-Host "  ✓ Workspace file exists" -ForegroundColor Green
  $report.Configured += "VS Code Workspace"
} else {
  Write-Host "  ✗ Workspace file missing" -ForegroundColor Red
  $report.NotConfigured += "VS Code Workspace"
}

# GENERATE REPORT
Write-Host "`n=== COMPREHENSIVE REPORT ===" -ForegroundColor Cyan

Write-Host "`n✓ INSTALLED ($($report.Installed.Count)):" -ForegroundColor Green
$report.Installed | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

Write-Host "`n✓ CONFIGURED ($($report.Configured.Count)):" -ForegroundColor Green
$report.Configured | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

Write-Host "`n✓ WORKING ($($report.Working.Count)):" -ForegroundColor Green
$report.Working | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

if ($report.Missing.Count -gt 0) {
  Write-Host "`n✗ MISSING ($($report.Missing.Count)):" -ForegroundColor Red
  $report.Missing | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}

if ($report.NotConfigured.Count -gt 0) {
  Write-Host "`n✗ NOT CONFIGURED ($($report.NotConfigured.Count)):" -ForegroundColor Yellow
  $report.NotConfigured | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}

if ($report.NotWorking.Count -gt 0) {
  Write-Host "`n✗ NOT WORKING ($($report.NotWorking.Count)):" -ForegroundColor Red
  $report.NotWorking | ForEach-Object { Write-Host "  • $_" -ForegroundColor Yellow }
}

# SCORE
$total = $report.Installed.Count + $report.Configured.Count + $report.Working.Count
$issues = $report.Missing.Count + $report.NotConfigured.Count + $report.NotWorking.Count
$score = if (($total + $issues) -gt 0) { [math]::Round(($total / ($total + $issues)) * 100, 2) } else { 0 }

Write-Host "`n=== SCORE: $score% ===" -ForegroundColor $(if($score -gt 80){'Green'}elseif($score -gt 60){'Yellow'}else{'Red'})

if (-not $Apply -and $issues -gt 0) {
  Write-Host "`nRun with -Apply to fix issues:" -ForegroundColor Yellow
  Write-Host "  cd 'c:\Users\VVIP_44\Downloads\Telegram Desktop'" -ForegroundColor White
  Write-Host "  .\scripts\explore-verify.ps1 -Apply" -ForegroundColor White
}

# SAVE REPORT
$reportPath = "c:\Users\VVIP_44\Downloads\Telegram Desktop\reports\ai-verification-$(Get-Date -Format 'yyyyMMdd-HHmmss').md"
$reportContent = @"
# AI System Verification Report
Generated: $(Get-Date)

## Summary
- Score: $score%
- Installed: $($report.Installed.Count)
- Configured: $($report.Configured.Count)
- Working: $($report.Working.Count)
- Missing: $($report.Missing.Count)
- Not Configured: $($report.NotConfigured.Count)
- Not Working: $($report.NotWorking.Count)

## Details
$(if ($report.Installed.Count -gt 0) { "### Installed`n" + ($report.Installed | ForEach-Object { "- $_" }) -join "`n" })
$(if ($report.Missing.Count -gt 0) { "`n### Missing`n" + ($report.Missing | ForEach-Object { "- $_" }) -join "`n" })
"@

$reportContent | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "`nReport saved: $reportPath" -ForegroundColor Gray
