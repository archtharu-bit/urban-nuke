param(
  [Parameter()]
  [string]$OutDir = "reports",

  # Opt-in destructive actions.
  [Parameter()]
  [switch]$CleanTemp,

  [Parameter()]
  [switch]$EmptyRecycleBin
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'cleanup-scan' -OutDir $OutDir

Add-ReportHeader -Path $reportPath -Title 'Cleanup Scan' -Meta @{
  CleanTemp = [bool]$CleanTemp
  EmptyRecycleBin = [bool]$EmptyRecycleBin
}

function Get-FolderSizeBytes([string]$Path) {
  if (-not (Test-Path -Path $Path)) { return 0 }
  $sum = 0
  Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $sum += $_.Length
  }
  return $sum
}

$tempPaths = @(
  $env:TEMP,
  $env:TMP,
  "C:\\Windows\\Temp"
) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique

$tempLines = @()
foreach ($p in $tempPaths) {
  $size = Safe-Get -Label "TempSize:$p" { Get-FolderSizeBytes -Path $p }
  if ($size -is [string]) {
    $tempLines += "- ${p}: $size"
  } else {
    $tempLines += ("- {0}: {1} GB" -f $p, ([math]::Round(($size / 1GB), 2)))
  }
}
Add-Section -Path $reportPath -Title 'Temp Folders (size estimate)' -Lines $tempLines

$startup = Safe-Get -Label 'StartupApps' { Get-CimInstance Win32_StartupCommand | Select-Object Name, Command, Location, User }
if ($startup -is [string]) {
  Add-Section -Path $reportPath -Title 'Startup Apps' -Lines @("- $startup")
} else {
  $lines = @()
  foreach ($s in @($startup)) {
    $lines += "- $($s.Name) ($($s.User))"
    $lines += "  - Location: $($s.Location)"
    $lines += "  - Command: $($s.Command)"
  }
  Add-Section -Path $reportPath -Title 'Startup Apps' -Lines (Limit-Lines -Lines $lines -MaxLines 80)
}

if ($CleanTemp) {
  foreach ($p in $tempPaths) {
    try {
      if (Test-Path -Path $p) {
        Get-ChildItem -Path $p -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
      }
      Add-Section -Path $reportPath -Title "Temp Cleanup" -Lines @("- Cleaned: $p")
    } catch {
      Add-Section -Path $reportPath -Title "Temp Cleanup" -Lines @("- Failed: $p : $($_.Exception.Message)")
    }
  }
} else {
  Add-Section -Path $reportPath -Title 'Temp Cleanup' -Lines @(
    '- Not executed (run with -CleanTemp to delete temp contents).'
  )
}

if ($EmptyRecycleBin) {
  try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Add-Section -Path $reportPath -Title 'Recycle Bin' -Lines @('- Emptied recycle bin.')
  } catch {
    Add-Section -Path $reportPath -Title 'Recycle Bin' -Lines @(
      "- Failed: $($_.Exception.Message)"
    )
  }
} else {
  Add-Section -Path $reportPath -Title 'Recycle Bin' -Lines @('- Not executed (run with -EmptyRecycleBin to empty).')
}

Add-Section -Path $reportPath -Title 'Notes' -Lines @(
  '- Avoid “registry cleaners”. Focus on updates, startup apps, and keeping disk free.',
  '- For AI/graphics work, keep enough free space for caches (CUDA, model weights, Adobe caches, etc.).'
)

Write-Host "Report created: $reportPath"
