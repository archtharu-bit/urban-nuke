param(
  [Parameter()]
  [string]$OutDir = 'reports',

  [Parameter()]
  [string]$CollectionPath = '',

  # Overwrite a stable summary file (does not create duplicates).
  [Parameter()]
  [switch]$WriteSummaryFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BlockLines {
  param(
    [Parameter()]
    [AllowNull()]
    [AllowEmptyCollection()]
    [string[]]$Lines = @(),
    [Parameter(Mandatory)]
    [string]$Prefix
  )

  $begin = "<!-- BEGIN:${Prefix} -->"
  $end = "<!-- END:${Prefix} -->"

  $beginIndex = -1
  $endIndex = -1

  if (-not $Lines -or $Lines.Count -eq 0) { return @() }

  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq $begin) { $beginIndex = $i; break }
  }
  if ($beginIndex -lt 0) { return @() }
  for ($i = $beginIndex + 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq $end) { $endIndex = $i; break }
  }
  if ($endIndex -lt 0) { return @() }
  if ($endIndex -le $beginIndex + 1) { return @() }
  return @($Lines[($beginIndex + 1)..($endIndex - 1)])
}

function Get-SectionLines {
  param(
    [Parameter()]
    [AllowNull()]
    [AllowEmptyCollection()]
    [string[]]$Lines = @(),
    [Parameter(Mandatory)]
    [string]$Title
  )

  # Collection embeds reports with demoted headings. Sections are typically "### {Title}".
  if (-not $Lines -or $Lines.Count -eq 0) { return @() }

  $header = "### $Title"
  $start = -1
  for ($i = 0; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i].Trim() -eq $header) { $start = $i; break }
  }
  if ($start -lt 0) { return @() }

  $end = $Lines.Count
  for ($i = $start + 1; $i -lt $Lines.Count; $i++) {
    if ($Lines[$i] -match '^###\s+') { $end = $i; break }
  }
  if ($end -le $start + 1) { return @() }
  return @($Lines[($start + 1)..($end - 1)])
}

function Get-LineValue {
  param(
    [Parameter()]
    [AllowNull()]
    [AllowEmptyCollection()]
    [string[]]$Lines = @(),
    [Parameter(Mandatory)]
    [string]$StartsWith
  )

  if (-not $Lines -or $Lines.Count -eq 0) { return $null }
  $match = $Lines | Where-Object { $_.TrimStart() -like ($StartsWith + '*') } | Select-Object -First 1
  if (-not $match) { return $null }
  return ($match.Trim() -replace [regex]::Escape($StartsWith), '').Trim()
}

function Find-LinesMatching {
  param(
    [Parameter()]
    [AllowNull()]
    [AllowEmptyCollection()]
    [string[]]$Lines = @(),
    [Parameter(Mandatory)]
    [string]$Regex,
    [Parameter()]
    [int]$Max = 50
  )

  if (-not $Lines -or $Lines.Count -eq 0) { return @() }
  return @(
    $Lines | Where-Object { $_ -match $Regex } | Select-Object -First $Max
  )
}

if ([string]::IsNullOrWhiteSpace($CollectionPath)) {
  $CollectionPath = Join-Path $OutDir 'latest-collection.md'
}

if (-not (Test-Path -LiteralPath $CollectionPath)) {
  throw "Collection report not found: $CollectionPath (run scripts\\run-all.ps1 first)"
}

$lines = @(
  Get-Content -LiteralPath $CollectionPath -ErrorAction Stop
)

if ($lines.Count -eq 0) {
  throw "Collection report is empty: $CollectionPath"
}

$summary = New-Object System.Collections.Generic.List[string]
$summary.Add('# Urban Nuke - Summary')
$summary.Add(('Generated: {0}' -f (Get-Date)))
$summary.Add(('Source: {0}' -f $CollectionPath))

$reportBlock = @(Get-BlockLines -Lines $lines -Prefix 'report')
$securityBlock = @(Get-BlockLines -Lines $lines -Prefix 'security')
$stabilityBlock = @(Get-BlockLines -Lines $lines -Prefix 'stability-scan')
$updateBlock = @(Get-BlockLines -Lines $lines -Prefix 'windows-update-scan')
$defenderBlock = @(Get-BlockLines -Lines $lines -Prefix 'defender-scan')

if ($reportBlock.Count -eq 0 -or $stabilityBlock.Count -eq 0) {
  $summary.Add('')
  $summary.Add('## Parser status')
  $summary.Add('- Could not find one or more embedded report blocks. Re-run: scripts\\run-all.ps1')
}

# Basic system (from report block)
$osSection = Get-SectionLines -Lines $reportBlock -Title 'OS'
$cpuSection = Get-SectionLines -Lines $reportBlock -Title 'CPU'
$memSection = Get-SectionLines -Lines $reportBlock -Title 'Memory'

$caption = Get-LineValue -Lines $osSection -StartsWith '- Caption:'
$build = Get-LineValue -Lines $osSection -StartsWith '- Build:'
$cpuName = Get-LineValue -Lines $cpuSection -StartsWith '- Name:'
$ramTotal = Get-LineValue -Lines $memSection -StartsWith '- Total:'

$summary.Add('')
$summary.Add('## Snapshot')
if ($caption) { $summary.Add("- OS: $caption") }
if ($build) { $summary.Add("- Build: $build") }
if ($cpuName) { $summary.Add("- CPU: $cpuName") }
if ($ramTotal) { $summary.Add("- Memory: $ramTotal") }

# Storage: from stability-scan Storage section
$storageSection = Get-SectionLines -Lines $stabilityBlock -Title 'Storage'
$storage = @(Find-LinesMatching -Lines $storageSection -Regex '^- [A-Z]:\s+\d+(\.\d+)?\s+GB free /' -Max 10)
if ($storage.Count -gt 0) {
  $summary.Add('')
  $summary.Add('## Storage (free space)')
  foreach ($l in $storage) { $summary.Add($l) }
}

# GPU evidence: from stability-scan GPU section
$gpuSection = Get-SectionLines -Lines $stabilityBlock -Title 'GPU'
$gpuNames = @(Find-LinesMatching -Lines $gpuSection -Regex '^\s*- Name: .+' -Max 5)
$gpuDriverVersions = @(Find-LinesMatching -Lines $gpuSection -Regex '^\s*- Driver Version: .+' -Max 10)
$gpuDriverDates = @(Find-LinesMatching -Lines $gpuSection -Regex '^\s*- Driver Date: .+' -Max 10)

$summary.Add('')
$summary.Add('## GPU / Driver evidence')
if ($gpuNames.Count -gt 0) {
  foreach ($l in $gpuNames) { $summary.Add([string]$l) }
} else {
  $summary.Add('- GPU name not detected in report')
}
if ($gpuDriverVersions.Count -gt 0) {
  foreach ($l in $gpuDriverVersions) { $summary.Add([string]$l) }
}
if ($gpuDriverDates.Count -gt 0) {
  foreach ($l in $gpuDriverDates) { $summary.Add([string]$l) }
}

$pendingStart = ($updateBlock | Select-String -SimpleMatch '### Pending Updates' -ErrorAction SilentlyContinue | Select-Object -First 1)
if ($pendingStart) {
  $summary.Add('')
  $summary.Add('## Windows Update (pending)')
  $pendingSection = Get-SectionLines -Lines $updateBlock -Title 'Pending Updates'
  $pending = @(
    $pendingSection | Where-Object { $_ -match '^\s*- ' } | Select-Object -First 15
  )
  if ($pending.Count -eq 0) { $summary.Add('- No pending updates detected (or parsing failed).') }
  foreach ($l in $pending) { $summary.Add([string]$l) }
}

# Defender highlights: prefer defender-scan output; fall back to security report.
$defenderStatus = Get-SectionLines -Lines $defenderBlock -Title 'Defender Status'
if ($defenderStatus.Count -eq 0) {
  $defenderStatus = Get-SectionLines -Lines $securityBlock -Title 'Windows Defender'
}
$defender = @(Find-LinesMatching -Lines $defenderStatus -Regex '^- (AM Service Enabled|Real-Time Protection|Antivirus Enabled|Signature Updated|Full Scan Age \(days\)|Quick Scan Age \(days\)):' -Max 30)
$summary.Add('')
$summary.Add('## Microsoft Defender')
if ($defender.Count -gt 0) {
  foreach ($l in $defender) { $summary.Add($l) }
} else {
  $summary.Add('- Defender status lines not found (try running PowerShell as Administrator and re-run run-all).')
}

# Stability: last 7 days error signals from stability scan section
$eventSection = Get-SectionLines -Lines $stabilityBlock -Title 'System Events (Last 7 days, Critical/Error)'
$events = @(Find-LinesMatching -Lines $eventSection -Regex '^\s*- \d{1,2}/\d{1,2}/\d{4}.*\[(Critical|Error)\]' -Max 15)
$summary.Add('')
$summary.Add('## Stability signals (System log)')
if ($events.Count -gt 0) {
  foreach ($l in $events) { $summary.Add($l) }
} else {
  $summary.Add('- No Critical/Error events found in the report section, or parsing failed.')
}

$outText = ($summary -join "`r`n")
Write-Host $outText

if ($WriteSummaryFile) {
  $path = Join-Path $OutDir 'latest-summary.md'
  Set-Content -LiteralPath $path -Value $outText -Encoding UTF8
  Write-Host "`nSummary file written: $path"
}
