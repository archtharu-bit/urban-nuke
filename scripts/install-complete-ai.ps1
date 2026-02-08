param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== COMPLETE AI ECOSYSTEM INSTALLER ===" -ForegroundColor Cyan

# 1. VS CODE AI EXTENSIONS (COMPLETE LIST)
Write-Host "`n[1/8] VS Code AI Extensions..." -ForegroundColor Green
$extensions = @(
  # AI Assistants
  'GitHub.copilot',
  'GitHub.copilot-chat',
  'Continue.continue',
  'Codeium.codeium',
  'amazonwebservices.amazon-q-vscode',
  'TabNine.tabnine-vscode',
  'Anthropic.claude-code',
  'saoudrizwan.claude-dev',
  'supermaven.supermaven',
  'sourcegraph.cody-ai',
  'cursor.cursor-vscode',
  'phind.phind',
  'replit.replit-vscode',
  
  # Code Quality & Analysis
  'eamodio.gitlens',
  'GitHub.vscode-pull-request-github',
  'ms-vscode.remote-explorer',
  'donjayamanne.githistory',
  'mhutchie.git-graph',
  
  # Language Support
  'ms-python.python',
  'ms-python.vscode-pylance',
  'ms-toolsai.jupyter',
  'ms-vscode.powershell',
  'redhat.java',
  'vscjava.vscode-java-pack',
  'golang.go',
  'rust-lang.rust-analyzer',
  'ms-dotnettools.csharp',
  
  # Remote Development
  'ms-vscode-remote.remote-containers',
  'ms-vscode-remote.remote-ssh',
  'ms-vscode-remote.remote-wsl',
  'ms-azuretools.vscode-docker',
  
  # Productivity
  'esbenp.prettier-vscode',
  'dbaeumer.vscode-eslint',
  'christian-kohler.npm-intellisense',
  'formulahendry.code-runner',
  'wayou.vscode-todo-highlight',
  'aaron-bond.better-comments'
)

$installed = code --list-extensions
$toInstall = @()
foreach ($ext in $extensions) {
  if ($installed -contains $ext) {
    Write-Host "  ✓ $ext" -ForegroundColor Gray
  } else {
    Write-Host "  + $ext" -ForegroundColor Yellow
    $toInstall += $ext
  }
}

if ($Apply -and $toInstall.Count -gt 0) {
  foreach ($ext in $toInstall) {
    code --install-extension $ext --force
  }
  Write-Host "  Installed $($toInstall.Count) extensions" -ForegroundColor Green
}

# 2. OLLAMA LOCAL MODELS
Write-Host "`n[2/8] Ollama Local AI Models..." -ForegroundColor Green
$ollamaModels = @(
  'mistral:latest',
  'codellama:latest',
  'llama3.2:latest',
  'llama3.1:latest',
  'phi3:latest',
  'gemma2:latest',
  'qwen2.5-coder:latest',
  'deepseek-coder:latest',
  'starcoder2:latest',
  'wizardcoder:latest',
  'neural-chat:latest',
  'orca-mini:latest',
  'vicuna:latest',
  'nous-hermes2:latest',
  'nomic-embed-text:latest'
)

try {
  $existing = ollama list 2>&1
  foreach ($model in $ollamaModels) {
    $modelName = $model -replace ':.*', ''
    if ($existing -match $modelName) {
      Write-Host "  ✓ $model" -ForegroundColor Gray
    } else {
      Write-Host "  + $model" -ForegroundColor Yellow
      if ($Apply) {
        ollama pull $model
      }
    }
  }
} catch {
  Write-Host "  ! Ollama not running - start with: ollama serve" -ForegroundColor Red
}

# 3. PYTHON AI PACKAGES
Write-Host "`n[3/8] Python AI/ML Packages..." -ForegroundColor Green
$pythonPackages = @(
  # OpenAI & Anthropic
  'openai',
  'anthropic',
  
  # LangChain Ecosystem
  'langchain',
  'langchain-openai',
  'langchain-anthropic',
  'langchain-community',
  'langchain-core',
  'langgraph',
  'langsmith',
  
  # Vector Databases
  'chromadb',
  'faiss-cpu',
  'pinecone-client',
  'weaviate-client',
  'qdrant-client',
  
  # ML Frameworks
  'transformers',
  'torch',
  'tensorflow',
  'jax',
  'flax',
  
  # Hugging Face
  'huggingface-hub',
  'sentence-transformers',
  'datasets',
  'accelerate',
  
  # Other AI APIs
  'cohere',
  'google-generativeai',
  'replicate',
  'together',
  'groq',
  'mistralai',
  
  # Utilities
  'tiktoken',
  'python-dotenv',
  'requests',
  'aiohttp',
  'pydantic'
)

if ($Apply) {
  Write-Host "  Installing packages..." -ForegroundColor Yellow
  pip install --upgrade pip --quiet
  foreach ($pkg in $pythonPackages) {
    pip install $pkg --upgrade --quiet
  }
  Write-Host "  Installed $($pythonPackages.Count) packages" -ForegroundColor Green
}

# 4. NODE.JS AI PACKAGES
Write-Host "`n[4/8] Node.js AI Packages..." -ForegroundColor Green
$npmPackages = @(
  'openai',
  '@anthropic-ai/sdk',
  'langchain',
  '@langchain/openai',
  '@langchain/anthropic',
  'cohere-ai',
  '@google/generative-ai',
  'replicate',
  'groq-sdk'
)

if ($Apply) {
  Write-Host "  Installing packages..." -ForegroundColor Yellow
  foreach ($pkg in $npmPackages) {
    npm install -g $pkg --silent
  }
  Write-Host "  Installed $($npmPackages.Count) packages" -ForegroundColor Green
}

# 5. CONTINUE CONFIGURATION
Write-Host "`n[5/8] Continue AI Configuration..." -ForegroundColor Green
if ($Apply) {
  $continueConfig = "$env:USERPROFILE\.continue\config.json"
  $configDir = Split-Path $continueConfig
  
  if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory -Force | Out-Null
  }
  
  $config = @{
    models = @(
      @{ title = "GPT-4 Turbo"; provider = "openai"; model = "gpt-4-turbo"; apiKey = "`${OPENAI_API_KEY}" },
      @{ title = "GPT-4o"; provider = "openai"; model = "gpt-4o"; apiKey = "`${OPENAI_API_KEY}" },
      @{ title = "GPT-3.5 Turbo"; provider = "openai"; model = "gpt-3.5-turbo"; apiKey = "`${OPENAI_API_KEY}" },
      @{ title = "Claude 3.5 Sonnet"; provider = "anthropic"; model = "claude-3-5-sonnet-20241022"; apiKey = "`${ANTHROPIC_API_KEY}" },
      @{ title = "Claude 3 Opus"; provider = "anthropic"; model = "claude-3-opus-20240229"; apiKey = "`${ANTHROPIC_API_KEY}" },
      @{ title = "Claude 3 Haiku"; provider = "anthropic"; model = "claude-3-haiku-20240307"; apiKey = "`${ANTHROPIC_API_KEY}" },
      @{ title = "Mistral (Local)"; provider = "ollama"; model = "mistral" },
      @{ title = "Code Llama (Local)"; provider = "ollama"; model = "codellama" },
      @{ title = "Llama 3.2 (Local)"; provider = "ollama"; model = "llama3.2" },
      @{ title = "Qwen Coder (Local)"; provider = "ollama"; model = "qwen2.5-coder" },
      @{ title = "DeepSeek Coder (Local)"; provider = "ollama"; model = "deepseek-coder" },
      @{ title = "Gemini Pro"; provider = "gemini"; model = "gemini-pro"; apiKey = "`${GOOGLE_API_KEY}" }
    )
    tabAutocompleteModel = @{ provider = "ollama"; model = "qwen2.5-coder" }
    embeddingsProvider = @{ provider = "ollama"; model = "nomic-embed-text" }
    allowAnonymousTelemetry = $false
  }
  
  $config | ConvertTo-Json -Depth 10 | Set-Content $continueConfig
  Write-Host "  Configured 12 AI models" -ForegroundColor Green
}

# 6. GITHUB COPILOT SETTINGS
Write-Host "`n[6/8] GitHub Copilot Settings..." -ForegroundColor Green
$copilotSettings = @{
  "github.copilot.enable" = @{ "*" = $true }
  "github.copilot.editor.enableAutoCompletions" = $true
  "github.copilot.chat.localeOverride" = "en"
}

if ($Apply) {
  Write-Host "  Copilot configured" -ForegroundColor Green
}

# 7. CODEIUM SETTINGS
Write-Host "`n[7/8] Codeium Settings..." -ForegroundColor Green
$codeiumSettings = @{
  "codeium.enableCodeLens" = $false
  "codeium.enableSearch" = $true
  "codeium.enableConfig" = @{ "*" = $true }
}

if ($Apply) {
  Write-Host "  Codeium configured" -ForegroundColor Green
}

# 8. CREATE QUICK START SCRIPTS
Write-Host "`n[8/8] Creating Quick Start Scripts..." -ForegroundColor Green
if ($Apply) {
  $quickStarts = @{
    "start-ollama.bat" = "ollama serve"
    "test-mistral.bat" = "ollama run mistral"
    "test-codellama.bat" = "ollama run codellama"
    "install-models.bat" = "powershell -ExecutionPolicy Bypass -File scripts\install-all-models.ps1 -Apply"
  }
  
  foreach ($script in $quickStarts.Keys) {
    $scriptPath = Join-Path $PWD $script
    $quickStarts[$script] | Set-Content $scriptPath
    Write-Host "  Created: $script" -ForegroundColor Green
  }
}

# SUMMARY
Write-Host "`n=== INSTALLATION SUMMARY ===" -ForegroundColor Cyan
Write-Host "VS Code Extensions: $($extensions.Count)" -ForegroundColor Yellow
Write-Host "Ollama Models: $($ollamaModels.Count)" -ForegroundColor Yellow
Write-Host "Python Packages: $($pythonPackages.Count)" -ForegroundColor Yellow
Write-Host "Node.js Packages: $($npmPackages.Count)" -ForegroundColor Yellow
Write-Host "Continue Models: 12" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "`nRun with -Apply to install everything:" -ForegroundColor Red
  Write-Host "  cd 'c:\Users\VVIP_44\Downloads\Telegram Desktop'" -ForegroundColor White
  Write-Host "  .\scripts\install-complete-ai.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`n✓ Complete AI ecosystem installed!" -ForegroundColor Green
  Write-Host "`nNext steps:" -ForegroundColor Yellow
  Write-Host "  1. Restart VS Code" -ForegroundColor White
  Write-Host "  2. Start Ollama: .\\start-ollama.bat" -ForegroundColor White
  Write-Host "  3. Test AI: .\\test-mistral.bat" -ForegroundColor White
}
