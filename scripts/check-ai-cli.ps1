param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== AI & CLI TOOLS CHECK ===" -ForegroundColor Cyan

# 1. VS CODE AI EXTENSIONS
Write-Host "`n[1/7] VS Code AI Extensions..." -ForegroundColor Green
$extensions = code --list-extensions
$aiExtensions = @(
  'GitHub.copilot',
  'GitHub.copilot-chat',
  'Continue.continue',
  'Codeium.codeium',
  'amazonwebservices.amazon-q-vscode',
  'TabNine.tabnine-vscode',
  'eamodio.gitlens'
)

foreach ($ext in $aiExtensions) {
  $installed = $extensions -contains $ext
  $color = if($installed) {'Green'} else {'Red'}
  Write-Host "  $ext : $(if($installed){'INSTALLED'}else{'MISSING'})" -ForegroundColor $color
  
  if (-not $installed -and $Apply) {
    code --install-extension $ext
    Write-Host "    INSTALLED" -ForegroundColor Yellow
  }
}

# 2. API KEYS
Write-Host "`n[2/7] API Keys Configuration..." -ForegroundColor Green
$envFile = "c:\Users\VVIP_44\Downloads\Telegram Desktop\.env"
if (Test-Path $envFile) {
  $envContent = Get-Content $envFile
  $keys = @('OPENAI_API_KEY', 'ANTHROPIC_API_KEY')
  
  foreach ($key in $keys) {
    $found = $envContent | Select-String $key
    if ($found) {
      $value = ($found -split '=')[1]
      $masked = $value.Substring(0, 10) + "..." + $value.Substring($value.Length - 4)
      Write-Host "  $key : $masked" -ForegroundColor Green
    } else {
      Write-Host "  $key : MISSING" -ForegroundColor Red
    }
  }
} else {
  Write-Host "  .env file not found" -ForegroundColor Red
}

# 3. CONTINUE CONFIG
Write-Host "`n[3/7] Continue AI Configuration..." -ForegroundColor Green
$continueConfig = "$env:USERPROFILE\.continue\config.json"
if (Test-Path $continueConfig) {
  $config = Get-Content $continueConfig -Raw | ConvertFrom-Json
  Write-Host "  Models configured: $($config.models.Count)" -ForegroundColor Gray
  foreach ($model in $config.models) {
    Write-Host "    - $($model.title)" -ForegroundColor Gray
  }
} else {
  Write-Host "  Continue config not found" -ForegroundColor Yellow
}

# 4. CLI TOOLS
Write-Host "`n[4/7] CLI Tools..." -ForegroundColor Green
$cliTools = @{
  'git' = 'git --version'
  'node' = 'node --version'
  'npm' = 'npm --version'
  'python' = 'python --version'
  'pip' = 'pip --version'
  'aws' = 'aws --version'
  'gh' = 'gh --version'
  'docker' = 'docker --version'
  'kubectl' = 'kubectl version --client'
  'terraform' = 'terraform --version'
}

foreach ($tool in $cliTools.Keys) {
  try {
    $version = Invoke-Expression $cliTools[$tool] 2>&1 | Select-Object -First 1
    Write-Host "  $tool : $version" -ForegroundColor Green
  } catch {
    Write-Host "  $tool : NOT INSTALLED" -ForegroundColor Red
  }
}

# 5. LOCAL AI MODELS (Ollama)
Write-Host "`n[5/7] Local AI Models (Ollama)..." -ForegroundColor Green
try {
  $ollamaModels = ollama list 2>&1
  if ($ollamaModels -match 'NAME') {
    Write-Host "  Ollama installed" -ForegroundColor Green
    $ollamaModels | Select-Object -Skip 1 | ForEach-Object {
      Write-Host "    $_" -ForegroundColor Gray
    }
  } else {
    Write-Host "  No models installed" -ForegroundColor Yellow
  }
} catch {
  Write-Host "  Ollama not installed" -ForegroundColor Red
  if ($Apply) {
    Write-Host "  Install from: https://ollama.ai" -ForegroundColor Yellow
  }
}

# 6. PYTHON AI PACKAGES
Write-Host "`n[6/7] Python AI Packages..." -ForegroundColor Green
$aiPackages = @('openai', 'anthropic', 'langchain', 'transformers', 'torch', 'tensorflow')
foreach ($pkg in $aiPackages) {
  try {
    $installed = pip show $pkg 2>&1 | Select-String 'Version'
    if ($installed) {
      Write-Host "  $pkg : $installed" -ForegroundColor Green
    } else {
      Write-Host "  $pkg : NOT INSTALLED" -ForegroundColor Yellow
    }
  } catch {
    Write-Host "  $pkg : NOT INSTALLED" -ForegroundColor Yellow
  }
}

# 7. LOCAL AI DOWNLOADS
Write-Host "`n[7/7] Local AI Downloads..." -ForegroundColor Green
$aiPaths = @(
  "$env:USERPROFILE\.ollama",
  "$env:USERPROFILE\.cache\huggingface",
  "$env:LOCALAPPDATA\Programs\Ollama",
  "$env:USERPROFILE\Downloads\*model*",
  "$env:USERPROFILE\Downloads\*ai*"
)

$totalSize = 0
foreach ($path in $aiPaths) {
  if (Test-Path $path) {
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
      Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum / 1GB
    if ($size -gt 0) {
      $totalSize += $size
      Write-Host "  $path : $([math]::Round($size, 2)) GB" -ForegroundColor Gray
    }
  }
}
Write-Host "  Total AI data: $([math]::Round($totalSize, 2)) GB" -ForegroundColor Yellow

# SUMMARY
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan

$issues = @()
if (-not (Test-Path $envFile)) { $issues += "Missing .env file" }
if (-not (code --list-extensions | Select-String 'copilot')) { $issues += "GitHub Copilot not installed" }

if ($issues.Count -gt 0) {
  Write-Host "`nISSUES:" -ForegroundColor Red
  foreach ($issue in $issues) {
    Write-Host "  - $issue" -ForegroundColor Yellow
  }
} else {
  Write-Host "`nAll AI tools configured!" -ForegroundColor Green
}

Write-Host "`nRECOMMENDATIONS:" -ForegroundColor Yellow
Write-Host "  1. Install Ollama for local AI: https://ollama.ai" -ForegroundColor White
Write-Host "  2. Download models: ollama pull mistral" -ForegroundColor White
Write-Host "  3. Install Python AI packages: pip install openai anthropic" -ForegroundColor White

if (-not $Apply) {
  Write-Host "`nRun with -Apply to install missing tools" -ForegroundColor Red
}
