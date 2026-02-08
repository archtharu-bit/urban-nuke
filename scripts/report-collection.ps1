param(
  [Parameter()]
  [string]$OutDir = "reports",

  # If set, keep intermediate per-step reports in the OutDir.
  # Default: keep ONLY the combined collection report.
  [Parameter()]
  [switch]$KeepIndividualReports,

  # If set, also keep an archived, timestamped copy alongside latest-collection.md.
  # Default: OFF to avoid creating many similar files.
  [Parameter()]
  [switch]$Archive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir

$collectionPath = Join-Path $OutDir 'latest-collection.md'
if (Test-Path -LiteralPath $collectionPath) {
  Remove-Item -LiteralPath $collectionPath -Force -ErrorAction SilentlyContinue
}

Add-ReportHeader -Path $collectionPath -Title 'Urban Nuke - Collected Report' -Meta @{
  KeepIndividualReports = [bool]$KeepIndividualReports
  Archive = [bool]$Archive
}

$tmpDir = Join-Path $OutDir ("_tmp-collection-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Ensure-Dir -Path $tmpDir

function Convert-HeadingLevels([string]$Content) {
  # Demote all markdown headings by 1 level (e.g. # -> ##, ## -> ###) so each embedded report
  # fits cleanly under the collection document.
  $result = $Content
  for ($i = 6; $i -ge 1; $i--) {
    $old = ("#" * $i) + " "
    $new = ("#" * ($i + 1)) + " "
    $pattern = "(?m)^" + [regex]::Escape($old)
    $result = $result -replace $pattern, $new
  }
  return $result
}

function Append-EmbeddedReport {
  param(
    [Parameter(Mandatory)]
    [string]$Title,
    [Parameter(Mandatory)]
    [string]$Prefix,
    [Parameter(Mandatory)]
    [scriptblock]$Run
  )

  Add-Section -Path $collectionPath -Title $Title -Lines @(
    "- Prefix: $Prefix",
    "- Status: running"
  )

  try {
    & $Run

    $latest = Get-ChildItem -Path $tmpDir -File -Filter ("{0}-*.md" -f $Prefix) -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 1

    if (-not $latest) {
      Add-Section -Path $collectionPath -Title "$Title (error)" -Lines @(
        "- Could not find an output report matching: ${Prefix}-*.md"
      )
      return
    }

    $raw = Get-Content -Path $latest.FullName -Raw -ErrorAction Stop
    $embedded = Convert-HeadingLevels -Content $raw

    Add-Content -Path $collectionPath -Value "`n---`n"
    Add-Content -Path $collectionPath -Value ("<!-- BEGIN:{0} -->" -f $Prefix)
    Add-Content -Path $collectionPath -Value $embedded
    Add-Content -Path $collectionPath -Value ("<!-- END:{0} -->" -f $Prefix)
  } catch {
    Add-Section -Path $collectionPath -Title "$Title (failed)" -Lines @(
      "- Error: $($_.Exception.Message)"
    )
  }
}

Append-EmbeddedReport -Title 'Health Check' -Prefix 'health-check' -Run {
  & (Join-Path $PSScriptRoot 'health-check.ps1') -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Baseline Report' -Prefix 'report' -Run {
  & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action report -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Security Report' -Prefix 'security' -Run {
  & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action security -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Hardware Report' -Prefix 'hardware' -Run {
  & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action hardware -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Network Report' -Prefix 'network' -Run {
  & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action network -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Stability + AI/Graphics Readiness Scan' -Prefix 'stability-scan' -Run {
  & (Join-Path $PSScriptRoot 'stability-scan.ps1') -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Windows Update Scan' -Prefix 'windows-update-scan' -Run {
  & (Join-Path $PSScriptRoot 'windows-update-scan.ps1') -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Microsoft Defender Scan (status by default)' -Prefix 'defender-scan' -Run {
  & (Join-Path $PSScriptRoot 'defender-scan.ps1') -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Cleanup Scan (no deletions unless opted-in)' -Prefix 'cleanup-scan' -Run {
  & (Join-Path $PSScriptRoot 'cleanup-scan.ps1') -OutDir $tmpDir
}

Append-EmbeddedReport -Title 'Duplicate File Scan' -Prefix 'duplicate-scan' -Run {
  & (Join-Path $PSScriptRoot 'duplicate-scan.ps1') -OutDir $tmpDir
}

if ($Archive) {
  $archivedPath = New-ReportPath -Prefix 'collection' -OutDir $OutDir
  Copy-Item -Path $collectionPath -Destination $archivedPath -Force
  Add-Section -Path $collectionPath -Title 'Archive' -Lines @(
    "- Archived copy: $archivedPath"
  )
}

if ($KeepIndividualReports) {
  Get-ChildItem -Path $tmpDir -File -Filter '*.md' | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination (Join-Path $OutDir $_.Name) -Force
  }
}

# Cleanup the temp directory to avoid report spam.
try {
  Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction Stop
} catch {
  # Not fatal.
}

Write-Host "Collection report created: $collectionPath"
Write-Host "(This overwrites latest-collection.md each run to avoid duplicates.)"
