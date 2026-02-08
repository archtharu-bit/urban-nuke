param(
  [Parameter(Mandatory=$true)]
  [string]$ErrorMessage,
  
  [string]$FilePath = "",
  
  [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== AUTO BUG FIX WITH OLLAMA ===" -ForegroundColor Cyan

# Check if Ollama is running
try {
  $ollamaStatus = Invoke-RestMethod -Uri "http://localhost:11434/api/tags" -Method Get -ErrorAction Stop
  Write-Host "Ollama is running" -ForegroundColor Green
} catch {
  Write-Host "Starting Ollama..." -ForegroundColor Yellow
  Start-Process "ollama" -ArgumentList "serve" -WindowStyle Hidden
  Start-Sleep -Seconds 3
}

# Prepare the prompt
$prompt = @"
You are a debugging expert. Analyze this error and provide a fix.

Error: $ErrorMessage

$(if ($FilePath -and (Test-Path $FilePath)) {
  "File: $FilePath`n`nCode:`n" + (Get-Content $FilePath -Raw)
})

Provide:
1. Root cause
2. Fix (code only, no explanation)
3. Prevention tip

Be concise.
"@

Write-Host "`nAnalyzing error with Mistral..." -ForegroundColor Yellow

# Call Ollama API
$body = @{
  model = "mistral"
  prompt = $prompt
  stream = $false
} | ConvertTo-Json

try {
  $response = Invoke-RestMethod -Uri "http://localhost:11434/api/generate" -Method Post -Body $body -ContentType "application/json"
  
  Write-Host "`n=== ANALYSIS ===" -ForegroundColor Cyan
  Write-Host $response.response -ForegroundColor White
  
  if ($Apply -and $FilePath -and (Test-Path $FilePath)) {
    Write-Host "`nApplying fix..." -ForegroundColor Yellow
    # Extract code block from response
    if ($response.response -match '```[\w]*\n([\s\S]*?)\n```') {
      $fixedCode = $matches[1]
      Set-Content -Path $FilePath -Value $fixedCode
      Write-Host "Fix applied to $FilePath" -ForegroundColor Green
    }
  }
  
} catch {
  Write-Host "Ollama API error: $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Fallback: Check error manually" -ForegroundColor Yellow
}
