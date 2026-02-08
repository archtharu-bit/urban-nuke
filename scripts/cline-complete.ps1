param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "=== CLINE AUTO-COMPLETE PROJECT ===" -ForegroundColor Cyan
Write-Host "This will complete all remaining project tasks`n" -ForegroundColor Yellow

# Ensure all script paths resolve from repo root, not the current working directory.
# This matters when any sub-task is launched elevated (PowerShell often starts in System32).
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')

function Resolve-TaskScriptPath {
  param(
    [Parameter(Mandatory)]
    [string]$RelativePath
  )

  $direct = Join-Path $repoRoot $RelativePath
  if (Test-Path -Path $direct) { return $direct }

  # If scripts were restructured (scripts\core, scripts\security, ...), fall back
  # to searching by file name within the scripts directory.
  $leaf = Split-Path -Path $RelativePath -Leaf
  $scriptsDir = Join-Path $repoRoot 'scripts'
  if (Test-Path -Path $scriptsDir) {
    $found = Get-ChildItem -Path $scriptsDir -Recurse -File -Filter $leaf -ErrorAction SilentlyContinue |
      Select-Object -First 1
    if ($found) { return $found.FullName }
  }

  return $direct
}

function Normalize-Args {
  param(
    [Parameter()]
    $Value
  )

  if ($null -eq $Value) { return @() }

  # String is IEnumerable, so handle explicitly.
  if ($Value -is [string]) {
    if ([string]::IsNullOrWhiteSpace($Value)) { return @() }
    return @($Value)
  }

  if ($Value -is [System.Collections.IEnumerable]) {
    return @($Value)
  }

  return @($Value)
}

if (-not $Apply) {
  Write-Host "DRY-RUN MODE - Review tasks below`n" -ForegroundColor Yellow
}

$tasks = @(
  @{
    Name = "1. System Optimization"
    Script = "scripts\super-optimizer.ps1"
    Args = @("-Apply")
    Admin = $true
    Time = "15-20 min"
  },
  @{
    Name = "2. Clean Old Drivers"
    Script = $null
    Command = "Remove-Item -Path 'C:\Users\VVIP_44\Downloads\LiveUpdate' -Recurse -Force -ErrorAction SilentlyContinue"
    Admin = $false
    Time = "1 min"
  },
  @{
    Name = "3. Generate Final Report"
    Script = "scripts\run-all.ps1"
    Args = @()
    Admin = $false
    Time = "2 min"
  },
  @{
    Name = "4. Run Self-Test"
    Script = "scripts\self-test.ps1"
    Args = @()
    Admin = $false
    Time = "1 min"
  },
  @{
    Name = "5. Folder Restructure"
    Script = "scripts\restructure-folders.ps1"
    Args = @("-Apply")
    Admin = $false
    Time = "1 min"
  }
)

$allOk = $true
foreach ($task in $tasks) {
  Write-Host "`n[$($task.Name)]" -ForegroundColor Green
  Write-Host "  Time: $($task.Time)" -ForegroundColor Gray
  Write-Host "  Admin: $($task.Admin)" -ForegroundColor Gray
  
  if ($Apply) {
    try {
      if ($task.Script) {
        $scriptPath = Resolve-TaskScriptPath -RelativePath $task.Script
        $scriptArgs = Normalize-Args -Value $task.Args
        if ($task.Admin) {
          Write-Host "  Running with admin rights..." -ForegroundColor Yellow
          $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath) + $scriptArgs
          Start-Process powershell -Verb RunAs -ArgumentList $argList -Wait
        } else {
          & $scriptPath @scriptArgs
        }
      } elseif ($task.Command) {
        Invoke-Expression $task.Command
      }
      Write-Host "  COMPLETED" -ForegroundColor Green
    } catch {
      $allOk = $false
      Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
    }
  } else {
    if ($task.Script) {
      $argsList = Normalize-Args -Value $task.Args
      $argsText = if ($argsList.Count -gt 0) { $argsList -join ' ' } else { '' }
      Write-Host "  Will execute: $($task.Script) $argsText" -ForegroundColor Gray
    } elseif ($task.Command) {
      Write-Host "  Will execute: $($task.Command)" -ForegroundColor Gray
    }
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total estimated time: 20-25 minutes" -ForegroundColor Yellow

if ($Apply) {
  if ($allOk) {
    Write-Host "`nAll tasks completed!" -ForegroundColor Green
  } else {
    Write-Host "`nCompleted with failures (see above)." -ForegroundColor Yellow
  }
  Write-Host "Next steps:" -ForegroundColor Yellow
  Write-Host "  1. Get Anthropic API key from https://console.anthropic.com" -ForegroundColor White
  Write-Host "  2. Add to .env file: ANTHROPIC_API_KEY=sk-ant-..." -ForegroundColor White
  Write-Host "  3. Restart computer: shutdown /r /t 30" -ForegroundColor White
} else {
  Write-Host "`nRun with -Apply to execute all tasks" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\cline-complete.ps1 -Apply" -ForegroundColor White
}
