param(
  [Parameter()]
  [string]$LogPath = "defender-repair-admin.log"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$cwd = (Get-Location).Path
$scriptPath = Join-Path $cwd 'scripts\\defender-repair-admin.ps1'
$logFullPath = if ([System.IO.Path]::IsPathRooted($LogPath)) { $LogPath } else { Join-Path $cwd $LogPath }

$pwsh51 = Join-Path $env:WINDIR 'System32\\WindowsPowerShell\\v1.0\\powershell.exe'
$cmd = "& '$scriptPath' -LogPath '$logFullPath'"

Write-Host "Requesting elevation (UAC)..."
Write-Host "Script: $scriptPath"
Write-Host "Log:    $logFullPath"

try {
  Start-Process -FilePath $pwsh51 -Verb RunAs -Wait -ArgumentList @(
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-Command',
    $cmd
  )
} catch {
  Write-Host "ELEVATION_FAILED: $($_.Exception.Message)"
}

if (Test-Path -LiteralPath $logFullPath) {
  Write-Host "\n=== Log (tail) ==="
  Get-Content -LiteralPath $logFullPath -Tail 160
} else {
  Write-Host "LOG_NOT_CREATED"
}
