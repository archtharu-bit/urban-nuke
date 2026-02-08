param(
  [Parameter()]
  [string]$OutLogPath = 'defender-fix-system.log',

  [Parameter()]
  [string]$TaskName = 'UrbanNuke-DefenderFix-System',

  [Parameter()]
  [int]$WaitSeconds = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cwd = (Get-Location).Path
$fixScript = Join-Path $cwd 'scripts\defender-fix-admin.ps1'
if (-not (Test-Path -LiteralPath $fixScript)) {
  throw "Missing script: $fixScript"
}

$logPath = if ([System.IO.Path]::IsPathRooted($OutLogPath)) { $OutLogPath } else { Join-Path $cwd $OutLogPath }
$taskCommand = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$fixScript`" -LogPath `"$logPath`""

# schtasks /Create requires a start time. Use +1 minute to always be valid, then run immediately.
$startTime = (Get-Date).AddMinutes(1).ToString('HH:mm')

Write-Host "Creating SYSTEM scheduled task: $TaskName"
cmd.exe /c "schtasks /Create /F /TN \"$TaskName\" /SC ONCE /ST $startTime /RU SYSTEM /RL HIGHEST /TR \"$taskCommand\"" | Out-Null

try {
  Write-Host "Running task..."
  cmd.exe /c "schtasks /Run /TN \"$TaskName\"" | Out-Null
  Start-Sleep -Seconds $WaitSeconds

  Write-Host "Task status:"
  $q = cmd.exe /c "schtasks /Query /TN \"$TaskName\" /V /FO LIST" 2>&1
  $q | Select-String -Pattern 'Status|Last Run Time|Last Result' | ForEach-Object { $_.Line }

  if (Test-Path -LiteralPath $logPath) {
    Write-Host "\n=== Log (tail) ==="
    Get-Content -LiteralPath $logPath -Tail 120
  } else {
    Write-Host "LOG_NOT_CREATED"
  }
} finally {
  # Cleanup task to avoid leaving scheduled tasks behind.
  try {
    cmd.exe /c "schtasks /Delete /F /TN \"$TaskName\"" | Out-Null
  } catch {
    # Not fatal
  }
}
