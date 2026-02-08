param(
  [Parameter()]
  [string]$OutDir = 'reports',

  # Keep this many newest reports per prefix (e.g., keep 3 newest report-*.md).
  [Parameter()]
  [int]$KeepPerPrefix = 3,

  # Default is SAFE: dry-run only. Use -Apply to actually delete files.
  [Parameter()]
  [switch]$Apply
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir

$reportPath = New-ReportPath -Prefix 'reports-prune' -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title 'Reports Prune (Retention)' -Meta @{
  KeepPerPrefix = $KeepPerPrefix
  Apply = [bool]$Apply
}

$all = Get-ChildItem -Path $OutDir -File -Filter '*.md' -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -ne 'latest-collection.md' }

# Group by prefix based on: prefix-YYYYMMDD-HHMMSS.md
$tagged = foreach ($f in @($all)) {
  $m = [regex]::Match($f.Name, '^(?<prefix>.+?)-\d{8}-\d{6}\.md$')
  $prefix = if ($m.Success) { $m.Groups['prefix'].Value } else { '_other' }
  [pscustomobject]@{
    Prefix = $prefix
    File = $f
  }
}

$groups = $tagged | Group-Object -Property Prefix

$toDelete = @()
foreach ($g in ($groups | Sort-Object Name)) {
  $prefix = $g.Name
  # Ensure $items is always an array (Sort-Object can output a scalar when only 1 item exists)
  $items = @(
    $g.Group | ForEach-Object { $_.File } | Sort-Object LastWriteTime -Descending
  )

  if ($items.Count -le $KeepPerPrefix) {
    Add-Section -Path $reportPath -Title "Prefix: $prefix" -Lines @(
      "- Files: $($items.Count)",
      "- Action: none (<= KeepPerPrefix)"
    )
    continue
  }

  $deleteItems = @(
    $items | Select-Object -Skip $KeepPerPrefix
  )
  $toDelete += $deleteItems

  Add-Section -Path $reportPath -Title "Prefix: $prefix" -Lines @(
    "- Files: $($items.Count)",
    "- Keeping newest: $KeepPerPrefix",
    "- Candidates to delete: $($deleteItems.Count)"
  )
}

Add-Section -Path $reportPath -Title 'Deletion Plan' -Lines (Limit-Lines -Lines (
  @($toDelete | Sort-Object FullName | ForEach-Object { "- $($_.FullName)" })
) -MaxLines 200)

if ($Apply) {
  $deleted = 0
  foreach ($f in @($toDelete)) {
    try {
      Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
      $deleted++
    } catch {
      # keep going
    }
  }
  Add-Section -Path $reportPath -Title 'Apply' -Lines @(
    "- Deleted: $deleted files"
  )
} else {
  Add-Section -Path $reportPath -Title 'Apply' -Lines @(
    '- Dry-run only (no files deleted).',
    '- Re-run with -Apply to delete the candidates above.'
  )
}

Write-Host "Report created: $reportPath"
