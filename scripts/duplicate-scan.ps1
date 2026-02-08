param(
  [Parameter()]
  [string]$Path = "$env:USERPROFILE\\Downloads",

  [Parameter()]
  [string]$OutDir = "reports",

  # Limit the scan to reduce runtime. Default: 10 GB.
  [Parameter()]
[long]$MaxTotalBytesToHash = 10737418240,

  # Optional file patterns; if omitted, all files are considered.
  [Parameter()]
  [string[]]$Include = @(),

  [Parameter()]
[int]$MinFileSizeBytes = 1048576
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'duplicate-scan' -OutDir $OutDir

Add-ReportHeader -Path $reportPath -Title 'Duplicate File Scan' -Meta @{
  Path = $Path
  MinFileSizeBytes = $MinFileSizeBytes
  MaxTotalBytesToHash = $MaxTotalBytesToHash
}

if (-not (Test-Path -Path $Path)) {
  Add-Section -Path $reportPath -Title 'Status' -Lines @("- Path not found: $Path")
  Write-Host "Report created: $reportPath"
  exit 1
}

$files = @()
if ($Include.Count -gt 0) {
  foreach ($pattern in $Include) {
    $files += Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue -Filter $pattern
  }
  $files = $files | Sort-Object FullName -Unique
} else {
  $files = Get-ChildItem -Path $Path -File -Recurse -Force -ErrorAction SilentlyContinue
}

$files = $files | Where-Object { $_.Length -ge $MinFileSizeBytes } | Sort-Object Length -Descending

$totalBytesCandidate = ($files | Measure-Object Length -Sum).Sum
Add-Section -Path $reportPath -Title 'Scope' -Lines @(
  "- Files (>= $MinFileSizeBytes bytes): $($files.Count)",
  ("- Total candidate size: {0} GB" -f ([math]::Round(($totalBytesCandidate / 1GB), 2))),
  ("- Hash budget: {0} GB" -f ([math]::Round(($MaxTotalBytesToHash / 1GB), 2)))
)

$hashedBytes = 0
$hashToFiles = @{}

foreach ($f in $files) {
  if ($hashedBytes + $f.Length -gt $MaxTotalBytesToHash) {
    break
  }

  try {
    $h = (Get-FileHash -Path $f.FullName -Algorithm SHA256).Hash
    if (-not $hashToFiles.ContainsKey($h)) {
      $hashToFiles[$h] = New-Object System.Collections.Generic.List[string]
    }
    $hashToFiles[$h].Add($f.FullName)
    $hashedBytes += $f.Length
  } catch {
    # ignore hashing errors; record minimal info
  }
}

$dupGroups = @()
foreach ($k in $hashToFiles.Keys) {
  $group = $hashToFiles[$k]
  if ($group.Count -gt 1) {
    $dupGroups += [pscustomobject]@{ Hash = $k; Files = $group }
  }
}

$summaryLines = @(
  ("- Hashed size: {0} GB" -f ([math]::Round(($hashedBytes / 1GB), 2))),
  "- Duplicate groups: $($dupGroups.Count)"
)

Add-Section -Path $reportPath -Title 'Summary' -Lines $summaryLines

if ($dupGroups.Count -eq 0) {
  Add-Section -Path $reportPath -Title 'Duplicates' -Lines @('- No duplicates found within the hashing budget.')
} else {
  $lines = @()
  foreach ($g in $dupGroups | Select-Object -First 50) {
    $lines += "- Hash: $($g.Hash)"
    foreach ($p in $g.Files) {
      $lines += "  - $p"
    }
  }
  if ($dupGroups.Count -gt 50) {
    $lines += "- (truncated; showing first 50 groups)"
  }
  Add-Section -Path $reportPath -Title 'Duplicates' -Lines $lines
}

Add-Section -Path $reportPath -Title 'Notes' -Lines @(
  '- This script never deletes files. Use the report to manually remove duplicates.',
  '- Increase -MaxTotalBytesToHash for larger scans, but it will take longer.'
)

Write-Host "Report created: $reportPath"
