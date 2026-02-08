param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== INSTALL ALL AI MODELS & AGENTS ===" -ForegroundColor Cyan

# 1. VS CODE AI EXTENSIONS
Write-Host "`n[1/4] VS Code AI Extensions..." -ForegroundColor Green
$extensions = @(
  'GitHub.copilot',
  'GitHub.copilot-chat',
  'Continue.continue',
  'Codeium.codeium',
  'amazonwebservices.amazon-q-vscode',
  'TabNine.tabnine-vscode',
  'eamodio.gitlens',
  'Anthropic.claude-code',
  'saoudrizwan.claude-dev',
  'supermaven.supermaven',
  'ms-python.python',
  'ms-python.vscode-pylance',
  'ms-toolsai.jupyter',
  'ms-toolsai.vscode-jupyter-cell-tags',
  'ms-toolsai.jupyter-keymap',
  'ms-toolsai.jupyter-renderers',
  'ms-vscode.remote-explorer',
  'ms-vscode-remote.remote-containers',
  'ms-vscode-remote.remote-ssh',
  'ms-vscode-remote.remote-wsl',
  'ms-azuretools.vscode-docker',
  'redhat.java',
  'vscjava.vscode-java-pack',
  'GitHub.vscode-pull-request-github',
  'GitHub.github-vscode-theme',
  'ms-vscode.powershell',
  'ms-vscode.makefile-tools'
)

$installed = code --list-extensions
foreach ($ext in $extensions) {
  if ($installed -contains $ext) {
    Write-Host "  OK: $ext" -ForegroundColor Gray
  } else {
    Write-Host "  INSTALLING: $ext" -ForegroundColor Yellow
    if ($Apply) {
      code --install-extension $ext --force
    }
  }
}

# 2. OLLAMA MODELS
Write-Host "`n[2/4] Ollama Local Models..." -ForegroundColor Green
$models = @(
  'mistral',
  'codellama',
  'llama3.2',
  'phi3',
  'gemma2',
  'qwen2.5-coder',
  'deepseek-coder',
  'starcoder2',
  'wizardcoder'
)

try {
  $existing = ollama list
  foreach ($model in $models) {
    if ($existing -match $model) {
      Write-Host "  OK: $model" -ForegroundColor Gray
    } else {
      Write-Host "  DOWNLOADING: $model" -ForegroundColor Yellow
      if ($Apply) {
        ollama pull $model
      }
    }
  }
} catch {
  Write-Host "  ERROR: Ollama not running" -ForegroundColor Red
}

# 3. PYTHON AI PACKAGES
Write-Host "`n[3/4] Python AI Packages..." -ForegroundColor Green
$packages = @(
  'openai',
  'anthropic',
  'langchain',
  'langchain-openai',
  'langchain-anthropic',
  'langchain-community',
  'transformers',
  'torch',
  'tensorflow',
  'huggingface-hub',
  'sentence-transformers',
  'chromadb',
  'faiss-cpu',
  'pinecone-client',
  'cohere',
  'google-generativeai',
  'replicate',
  'together',
  'groq'
)

foreach ($pkg in $packages) {
  Write-Host "  INSTALLING: $pkg" -ForegroundColor Yellow
  if ($Apply) {
    pip install $pkg --upgrade --quiet
  }
}

# 4. CONTINUE CONFIGURATION
Write-Host "`n[4/4] Continue Configuration..." -ForegroundColor Green
if ($Apply) {
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
        title = "GPT-4o"
        provider = "openai"
        model = "gpt-4o"
        apiKey = "`${OPENAI_API_KEY}"
      },
      @{
        title = "Claude 3.5 Sonnet"
        provider = "anthropic"
        model = "claude-3-5-sonnet-20241022"
        apiKey = "`${ANTHROPIC_API_KEY}"
      },
      @{
        title = "Claude 3 Opus"
        provider = "anthropic"
        model = "claude-3-opus-20240229"
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
      },
      @{
        title = "Llama 3.2 (Local)"
        provider = "ollama"
        model = "llama3.2"
      },
      @{
        title = "Qwen Coder (Local)"
        provider = "ollama"
        model = "qwen2.5-coder"
      },
      @{
        title = "DeepSeek Coder (Local)"
        provider = "ollama"
        model = "deepseek-coder"
      },
      @{
        title = "Gemini Pro"
        provider = "gemini"
        model = "gemini-pro"
        apiKey = "`${GOOGLE_API_KEY}"
      }
    )
    tabAutocompleteModel = @{
      title = "Qwen Coder"
      provider = "ollama"
      model = "qwen2.5-coder"
    }
    embeddingsProvider = @{
      provider = "ollama"
      model = "nomic-embed-text"
    }
    allowAnonymousTelemetry = $false
  }
  
  $config | ConvertTo-Json -Depth 10 | Set-Content $continueConfig
  Write-Host "  Continue configured with 10 models" -ForegroundColor Green
}

# SUMMARY
Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "VS Code Extensions: $($extensions.Count)" -ForegroundColor Yellow
Write-Host "Ollama Models: $($models.Count)" -ForegroundColor Yellow
Write-Host "Python Packages: $($packages.Count)" -ForegroundColor Yellow
Write-Host "Continue Models: 10" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "`nRun with -Apply to install everything:" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\install-all-models.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`nAll AI models and agents installed!" -ForegroundColor Green
  Write-Host "Restart VS Code to activate" -ForegroundColor Yellow
}
