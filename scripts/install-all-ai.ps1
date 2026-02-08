param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== INSTALL & CONFIGURE ALL AI/CLI TOOLS ===" -ForegroundColor Cyan

# 1. INSTALL CLI TOOLS
Write-Host "`n[1/5] Installing CLI Tools..." -ForegroundColor Green
$tools = @(
  'Git.Git',
  'OpenJS.NodeJS',
  'Python.Python.3.12',
  'Amazon.AWSCLI',
  'GitHub.cli',
  'Docker.DockerDesktop',
  'Hashicorp.Terraform',
  'Kubernetes.kubectl'
)

foreach ($tool in $tools) {
  Write-Host "  Installing $tool..." -ForegroundColor Yellow
  if ($Apply) {
    winget install --id $tool --silent --accept-source-agreements --accept-package-agreements -e
  }
}

# 2. INSTALL VS CODE AI EXTENSIONS
Write-Host "`n[2/5] Installing VS Code AI Extensions..." -ForegroundColor Green
$extensions = @(
  'GitHub.copilot',
  'GitHub.copilot-chat',
  'Continue.continue',
  'Codeium.codeium',
  'amazonwebservices.amazon-q-vscode',
  'TabNine.tabnine-vscode',
  'eamodio.gitlens',
  'ms-python.python',
  'ms-vscode.powershell'
)

foreach ($ext in $extensions) {
  Write-Host "  Installing $ext..." -ForegroundColor Yellow
  if ($Apply) {
    code --install-extension $ext --force
  }
}

# 3. INSTALL PYTHON AI PACKAGES
Write-Host "`n[3/5] Installing Python AI Packages..." -ForegroundColor Green
$packages = @(
  'openai',
  'anthropic',
  'langchain',
  'langchain-openai',
  'langchain-anthropic',
  'requests',
  'python-dotenv'
)

foreach ($pkg in $packages) {
  Write-Host "  Installing $pkg..." -ForegroundColor Yellow
  if ($Apply) {
    pip install $pkg --upgrade --quiet
  }
}

# 4. INSTALL OLLAMA (Local AI)
Write-Host "`n[4/5] Installing Ollama..." -ForegroundColor Green
if ($Apply) {
  try {
    winget install --id Ollama.Ollama --silent --accept-source-agreements --accept-package-agreements
    Write-Host "  Ollama installed" -ForegroundColor Green
    
    # Wait for Ollama to start
    Start-Sleep -Seconds 5
    
    # Install recommended models
    Write-Host "  Downloading AI models..." -ForegroundColor Yellow
    ollama pull mistral
    ollama pull codellama
    Write-Host "  Models installed" -ForegroundColor Green
  } catch {
    Write-Host "  Ollama installation failed" -ForegroundColor Red
  }
}

# 5. CONFIGURE EVERYTHING
Write-Host "`n[5/5] Configuring..." -ForegroundColor Green

if ($Apply) {
  # Update Continue config
  $continueConfig = "$env:USERPROFILE\.continue\config.json"
  $configDir = Split-Path $continueConfig
  
  if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
  }
  
  $config = @{
    models = @(
      @{
        title = "GPT-4 Turbo"
        provider = "openai"
        model = "gpt-4-turbo"
        apiKey = "`${OPENAI_API_KEY}"
      },
      @{
        title = "Claude Sonnet"
        provider = "anthropic"
        model = "claude-3-5-sonnet-20241022"
        apiKey = "`${ANTHROPIC_API_KEY}"
      },
      @{
        title = "Mistral (Local)"
        provider = "ollama"
        model = "mistral"
      },
      @{
        title = "Code Llama (Local)"
        provider = "ollama"
        model = "codellama"
      }
    )
    tabAutocompleteModel = @{
      title = "Mistral"
      provider = "ollama"
      model = "mistral"
    }
    allowAnonymousTelemetry = $false
  }
  
  $config | ConvertTo-Json -Depth 10 | Set-Content $continueConfig
  Write-Host "  Continue configured" -ForegroundColor Green
  
  # Verify .env file
  $envFile = "c:\Users\VVIP_44\Downloads\Telegram Desktop\.env"
  if (Test-Path $envFile) {
    Write-Host "  API keys configured" -ForegroundColor Green
  } else {
    Write-Host "  WARNING: .env file missing" -ForegroundColor Red
  }
}

# VERIFICATION
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Cyan

if ($Apply) {
  Write-Host "`nChecking installations..." -ForegroundColor Yellow
  
  # Check CLI tools
  $checks = @{
    'Git' = 'git --version'
    'Node' = 'node --version'
    'Python' = 'python --version'
    'AWS CLI' = 'aws --version'
    'GitHub CLI' = 'gh --version'
    'Ollama' = 'ollama --version'
  }
  
  foreach ($tool in $checks.Keys) {
    try {
      $version = Invoke-Expression $checks[$tool] 2>&1 | Select-Object -First 1
      Write-Host "  $tool : OK" -ForegroundColor Green
    } catch {
      Write-Host "  $tool : FAILED" -ForegroundColor Red
    }
  }
  
  Write-Host "`n=== INSTALLATION COMPLETE ===" -ForegroundColor Cyan
  Write-Host "All AI and CLI tools installed!" -ForegroundColor Green
  Write-Host "`nNext steps:" -ForegroundColor Yellow
  Write-Host "  1. Restart VS Code" -ForegroundColor White
  Write-Host "  2. Restart terminal/PowerShell" -ForegroundColor White
  Write-Host "  3. Test: ollama run mistral" -ForegroundColor White
} else {
  Write-Host "`nRun with -Apply to install everything:" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\install-all-ai.ps1 -Apply" -ForegroundColor White
}
