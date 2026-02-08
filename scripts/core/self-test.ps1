param(
  [Parameter()]
  [string]$OutDir = 'reports'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'self-test' -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title 'Self Test (Scripts Smoke Test)'

$tmpDir = Join-Path $OutDir ("_tmp-selftest-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
Ensure-Dir -Path $tmpDir

function Add-Result {
  param(
    [Parameter(Mandatory)]
    [string]$Name,
    [Parameter(Mandatory)]
    [bool]$Ok,
    [Parameter()]
    [string]$Details = ''
  )

  $status = if ($Ok) { 'OK' } else { 'FAIL' }
  $lines = @("- Status: $status")
  if (-not [string]::IsNullOrWhiteSpace($Details)) { $lines += "- Details: $Details" }
  Add-Section -Path $reportPath -Title $Name -Lines $lines
}

function Add-CheckLine {
  param(
    [Parameter(Mandatory)]
    [ref]$Lines,
    [Parameter(Mandatory)]
    [ref]$Ok,
    [Parameter(Mandatory)]
    [string]$Label,
    [Parameter(Mandatory)]
    [bool]$Pass,
    [Parameter()]
    [string]$Details = ''
  )

  $status = if ($Pass) { 'OK' } else { 'FAIL' }
  $line = if ([string]::IsNullOrWhiteSpace($Details)) {
    "- $($Label): $status"
  } else {
    "- $($Label): $status ($Details)"
  }
  $Lines.Value += $line
  if (-not $Pass) { $Ok.Value = $false }
}

function Expect-Report {
  param(
    [Parameter(Mandatory)]
    [string]$Prefix,
    [Parameter(Mandatory)]
    [scriptblock]$Run
  )

  try {
    & $Run
    $found = Get-ChildItem -Path $tmpDir -File -Filter ("{0}-*.md" -f $Prefix) -ErrorAction SilentlyContinue |
      Sort-Object LastWriteTime -Descending |
      Select-Object -First 1
    if ($found) {
      Add-Result -Name $Prefix -Ok $true -Details $found.Name
      return $true
    }
    Add-Result -Name $Prefix -Ok $false -Details 'No output file found'
    return $false
  } catch {
    Add-Result -Name $Prefix -Ok $false -Details $_.Exception.Message
    return $false
  }
}

# Report-only smoke tests (no deletions, no config changes)
$ok = $true
$ok = (Expect-Report -Prefix 'report' -Run { & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action report -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'security' -Run { & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action security -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'hardware' -Run { & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action hardware -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'network' -Run { & (Join-Path $PSScriptRoot 'urban-nuke.ps1') -Action network -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'stability-scan' -Run { & (Join-Path $PSScriptRoot 'stability-scan.ps1') -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'windows-update-scan' -Run { & (Join-Path $PSScriptRoot 'windows-update-scan.ps1') -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'defender-scan' -Run { & (Join-Path $PSScriptRoot 'defender-scan.ps1') -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'cleanup-scan' -Run { & (Join-Path $PSScriptRoot 'cleanup-scan.ps1') -OutDir $tmpDir }) -and $ok
$ok = (Expect-Report -Prefix 'duplicate-scan' -Run { & (Join-Path $PSScriptRoot 'duplicate-scan.ps1') -OutDir $tmpDir -MinFileSizeBytes 1048576 }) -and $ok

# Environment checks (SSH, Docker, VS Code/Copilot, Cursor)
$envOk = $true
$envLines = @()

$sshCmd = Get-Command -Name ssh -ErrorAction SilentlyContinue
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'SSH client available' -Pass ([bool]$sshCmd)

$sshDir = Join-Path $env:USERPROFILE '.ssh'
$sshConfig = Join-Path $sshDir 'config'
$ed25519 = Join-Path $sshDir 'id_ed25519'
$ed25519Pub = "$ed25519.pub"
$rsa = Join-Path $sshDir 'id_rsa'
$rsaPub = "$rsa.pub"
$keyOk = (Test-Path $ed25519) -or (Test-Path $rsa)
$pubOk = (Test-Path $ed25519Pub) -or (Test-Path $rsaPub)
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'SSH private key present' -Pass $keyOk
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'SSH public key present' -Pass $pubOk
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'SSH config present' -Pass (Test-Path $sshConfig)

$dockerCmd = Get-Command -Name docker -ErrorAction SilentlyContinue
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Docker CLI available' -Pass ([bool]$dockerCmd)
if ($dockerCmd) {
  try {
    docker info | Out-Null
    Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Docker daemon reachable' -Pass $true
  } catch {
    Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Docker daemon reachable' -Pass $false -Details $_.Exception.Message
  }
}

$copilotFile = Join-Path $PSScriptRoot '..\.github\copilot-instructions.md'
$devcontainerFile = Join-Path $PSScriptRoot '..\.devcontainer\devcontainer.json'
$cursorRule = Join-Path $PSScriptRoot '..\.cursor\rules\project.mdc'
$vscodeSettings = Join-Path $PSScriptRoot '..\.vscode\settings.json'

Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Copilot instructions file' -Pass (Test-Path $copilotFile)
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'VS Code settings file' -Pass (Test-Path $vscodeSettings)
Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Cursor rules file' -Pass (Test-Path $cursorRule)

if (Test-Path $devcontainerFile) {
  try {
    $devcontainer = Get-Content $devcontainerFile -Raw | ConvertFrom-Json
    $instructions = $devcontainer.customizations.vscode.settings.'github.copilot.chat.codeGeneration.instructions'
    $hasInstructions = $instructions -and $instructions.Count -gt 0
    Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Devcontainer Copilot instructions' -Pass $hasInstructions
  } catch {
    Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Devcontainer Copilot instructions' -Pass $false -Details $_.Exception.Message
  }
} else {
  Add-CheckLine -Lines ([ref]$envLines) -Ok ([ref]$envOk) -Label 'Devcontainer config present' -Pass $false
}

Add-Section -Path $reportPath -Title 'Environment Checks' -Lines $envLines

# Script sanity checks (parse, non-empty)
$sanityOk = $true
$sanityLines = @()
$scriptFiles = @(
  'self-test.ps1',
  'urban-nuke.ps1',
  'stability-scan.ps1',
  'windows-update-scan.ps1',
  'defender-scan.ps1',
  'cleanup-scan.ps1',
  'duplicate-scan.ps1',
  'run-all.ps1',
  'report-collection.ps1',
  'analyze-collection.ps1',
  'reports-prune.ps1'
) | ForEach-Object { Join-Path $PSScriptRoot $_ }

foreach ($script in $scriptFiles) {
  if (-not (Test-Path $script)) {
    Add-CheckLine -Lines ([ref]$sanityLines) -Ok ([ref]$sanityOk) -Label (Split-Path $script -Leaf) -Pass $false -Details 'Missing file'
    continue
  }
  $content = Get-Content $script -Raw
  if ([string]::IsNullOrWhiteSpace($content)) {
    Add-CheckLine -Lines ([ref]$sanityLines) -Ok ([ref]$sanityOk) -Label (Split-Path $script -Leaf) -Pass $false -Details 'Empty file'
    continue
  }
  $tokens = $null
  $errors = $null
  [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$tokens, [ref]$errors) | Out-Null
  if ($errors -and $errors.Count -gt 0) {
    Add-CheckLine -Lines ([ref]$sanityLines) -Ok ([ref]$sanityOk) -Label (Split-Path $script -Leaf) -Pass $false -Details $errors[0].Message
  } else {
    Add-CheckLine -Lines ([ref]$sanityLines) -Ok ([ref]$sanityOk) -Label (Split-Path $script -Leaf) -Pass $true
  }
}

Add-Section -Path $reportPath -Title 'Script Sanity' -Lines $sanityLines

# Report verification (existing reports)
$reportOk = $true
$reportLines = @()
$existingReports = Get-ChildItem -Path $OutDir -File -Filter '*.md' -ErrorAction SilentlyContinue
$hasReports = $existingReports -and $existingReports.Count -gt 0
Add-CheckLine -Lines ([ref]$reportLines) -Ok ([ref]$reportOk) -Label 'Reports present' -Pass $hasReports
if ($hasReports) {
  $latest = $existingReports | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  $ageDays = [math]::Round(((Get-Date) - $latest.LastWriteTime).TotalDays, 1)
  $recentOk = $ageDays -le 7
  Add-CheckLine -Lines ([ref]$reportLines) -Ok ([ref]$reportOk) -Label 'Latest report age <= 7 days' -Pass $recentOk -Details ("{0} days ({1})" -f $ageDays, $latest.Name)
}
Add-Section -Path $reportPath -Title 'Report Verification' -Lines $reportLines

$ok = $ok -and $envOk -and $sanityOk -and $reportOk

Add-Section -Path $reportPath -Title 'Summary' -Lines @(
  ("- Overall: {0}" -f $(if ($ok) { 'OK' } else { 'FAIL' })),
  "- Temp output directory: $tmpDir"
)

try {
  Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction Stop
} catch {
  # Not fatal
}

Write-Host "Self-test report created: $reportPath"
