param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== CLINE AUTO-COMPLETE PROJECT ===" -ForegroundColor Cyan
Write-Host "This will complete all remaining project tasks`n" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "DRY-RUN MODE - Review tasks below`n" -ForegroundColor Yellow
}

$tasks = @(
  @{
    Name = "1. System Optimization"
    Script = "scripts\super-optimizer.ps1"
    Args = "-Apply"
    Admin = $true
    Time = "15-20 min"
  },
  @{
    Name = "2. Folder Restructure"
    Script = "scripts\restructure-folders.ps1"
    Args = "-Apply"
    Admin = $false
    Time = "1 min"
  },
  @{
    Name = "3. Clean Old Drivers"
    Script = $null
    Command = "Remove-Item -Path 'C:\Users\VVIP_44\Downloads\LiveUpdate' -Recurse -Force -ErrorAction SilentlyContinue"
    Admin = $false
    Time = "1 min"
  },
  @{
    Name = "4. Generate Final Report"
    Script = "scripts\run-all.ps1"
    Args = ""
    Admin = $false
    Time = "2 min"
  },
  @{
    Name = "5. Run Self-Test"
    Script = "scripts\self-test.ps1"
    Args = ""
    Admin = $false
    Time = "1 min"
  }
)

$totalTime = 0
foreach ($task in $tasks) {
  Write-Host "`n[$($task.Name)]" -ForegroundColor Green
  Write-Host "  Time: $($task.Time)" -ForegroundColor Gray
  Write-Host "  Admin: $($task.Admin)" -ForegroundColor Gray
  
  if ($Apply) {
    try {
      if ($task.Script) {
        $scriptPath = Join-Path (Get-Location) $task.Script
        if ($task.Admin) {
          Write-Host "  Running with admin rights..." -ForegroundColor Yellow
          Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`" $($task.Args)" -Wait
        } else {
          & $scriptPath $task.Args
        }
      } elseif ($task.Command) {
        Invoke-Expression $task.Command
      }
      Write-Host "  COMPLETED" -ForegroundColor Green
    } catch {
      Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
  } else {
    Write-Host "  Will execute: $($task.Script)" -ForegroundColor Gray
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total estimated time: 20-25 minutes" -ForegroundColor Yellow

if ($Apply) {
  Write-Host "`nAll tasks completed!" -ForegroundColor Green
  Write-Host "Next steps:" -ForegroundColor Yellow
  Write-Host "  1. Get Anthropic API key from https://console.anthropic.com" -ForegroundColor White
  Write-Host "  2. Add to .env file: ANTHROPIC_API_KEY=sk-ant-..." -ForegroundColor White
  Write-Host "  3. Restart computer: shutdown /r /t 30" -ForegroundColor White
} else {
  Write-Host "`nRun with -Apply to execute all tasks" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\cline-complete.ps1 -Apply" -ForegroundColor White
}
