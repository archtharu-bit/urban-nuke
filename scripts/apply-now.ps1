param(
  [Parameter()]
  [string]$OutDir = 'reports',

  # Default is SAFE: report-only. Use -Apply to actually change settings.
  [Parameter()]
  [switch]$Apply,

  # Power plan to switch to (best-effort). 'ultimate' may not exist on all systems.
  [Parameter()]
  [ValidateSet('balanced', 'high', 'ultimate', 'none')]
  [string]$PowerPlan = 'none',

  # Optional: start a Defender scan after enabling settings.
  [Parameter()]
  [ValidateSet('none', 'quick', 'full')]
  [string]$DefenderScan = 'none'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

function Test-Admin {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-ActivePowerScheme {
  try {
    $raw = (powercfg /getactivescheme) 2>&1
    return ($raw | Out-String).Trim()
  } catch {
    return "[Unavailable] powercfg: $($_.Exception.Message)"
  }
}

function Set-PowerPlan {
  param(
    [Parameter(Mandatory)]
    [ValidateSet('balanced', 'high', 'ultimate')]
    [string]$Plan
  )

  # Common scheme GUIDs
  $guidBalanced = '381b4222-f694-41f0-9685-ff5bb260df2e'
  $guidHigh = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
  $guidUltimate = 'e9a42b02-d5df-448d-aa00-03f14749eb61'

  switch ($Plan) {
    'balanced' { powercfg /setactive $guidBalanced | Out-Null }
    'high' { powercfg /setactive $guidHigh | Out-Null }
    'ultimate' {
      # Ensure ultimate exists; if missing, try to create it.
      $list = (powercfg /list) 2>&1 | Out-String
      if ($list -notmatch $guidUltimate) {
        powercfg -duplicatescheme $guidUltimate | Out-Null
      }
      powercfg /setactive $guidUltimate | Out-Null
    }
  }
}

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'apply-now' -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title 'Apply Now (Opt-in Configuration Changes)' -Meta @{
  Apply = [bool]$Apply
  PowerPlan = $PowerPlan
  DefenderScan = $DefenderScan
  IsAdmin = [bool](Test-Admin)
}

Add-Section -Path $reportPath -Title 'Pre-check: Active Power Plan' -Lines @(
  (Get-ActivePowerScheme)
)

$av = Safe-Get -Label 'AntivirusProduct' { Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct | Select-Object displayName, pathToSignedProductExe }
if ($av -is [string]) {
  Add-Section -Path $reportPath -Title 'Detected Antivirus Products' -Lines @("- $av")
} else {
  $avLines = @()
  foreach ($p in @($av)) {
    $avLines += "- $($p.displayName)"
    $avLines += "  - Exe: $($p.pathToSignedProductExe)"
  }
  if ($avLines.Count -eq 0) { $avLines = @('- None detected via SecurityCenter2.') }
  Add-Section -Path $reportPath -Title 'Detected Antivirus Products' -Lines $avLines
}

$defStatus = Safe-Get -Label 'Get-MpComputerStatus' { Get-MpComputerStatus }
if ($defStatus -is [string]) {
  Add-Section -Path $reportPath -Title 'Defender (pre)' -Lines @("- $defStatus")
} else {
  Add-Section -Path $reportPath -Title 'Defender (pre)' -Lines @(
    "- AM Service Enabled: $($defStatus.AMServiceEnabled)",
    "- Real-Time Protection: $($defStatus.RealTimeProtectionEnabled)",
    "- Antivirus Enabled: $($defStatus.AntivirusEnabled)",
    "- Signature Updated: $($defStatus.AntivirusSignatureLastUpdated)"
  )
}

if (-not $Apply) {
  Add-Section -Path $reportPath -Title 'Apply' -Lines @(
    '- Not executed (report-only).',
    '- Re-run this script as Administrator with -Apply to change settings.'
  )
  Write-Host "Report created: $reportPath"
  exit 0
}

if (-not (Test-Admin)) {
  Add-Section -Path $reportPath -Title 'Apply' -Lines @(
    '- Refused: not running as Administrator.',
    '- Re-run PowerShell as Administrator and try again.'
  )
  Write-Host "Report created: $reportPath"
  exit 1
}

# Apply security baseline (firewall + defender preferences)
try {
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction Stop
  Add-Section -Path $reportPath -Title 'Firewall' -Lines @('- Enabled for all profiles')
} catch {
  Add-Section -Path $reportPath -Title 'Firewall' -Lines @("- Failed: $($_.Exception.Message)")
}

try {
  Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
  Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
  Add-Section -Path $reportPath -Title 'Defender settings' -Lines @(
    '- Real-time protection: requested ON',
    '- PUA protection: requested ON'
  )
} catch {
  Add-Section -Path $reportPath -Title 'Defender settings' -Lines @("- Failed: $($_.Exception.Message)")
}

if ($PowerPlan -ne 'none') {
  try {
    Set-PowerPlan -Plan $PowerPlan
    Add-Section -Path $reportPath -Title 'Power plan' -Lines @(
      "- Set active plan: $PowerPlan",
      (Get-ActivePowerScheme)
    )
  } catch {
    Add-Section -Path $reportPath -Title 'Power plan' -Lines @("- Failed: $($_.Exception.Message)")
  }
}

if ($DefenderScan -ne 'none') {
  try {
    if ($DefenderScan -eq 'quick') { Start-MpScan -ScanType QuickScan -ErrorAction Stop }
    if ($DefenderScan -eq 'full') { Start-MpScan -ScanType FullScan -ErrorAction Stop }
    Add-Section -Path $reportPath -Title 'Defender scan' -Lines @("- Started: $DefenderScan")
  } catch {
    Add-Section -Path $reportPath -Title 'Defender scan' -Lines @("- Failed: $($_.Exception.Message)")
  }
}

$defAfter = Safe-Get -Label 'Get-MpComputerStatus (after)' { Get-MpComputerStatus }
if ($defAfter -is [string]) {
  Add-Section -Path $reportPath -Title 'Defender (after)' -Lines @("- $defAfter")
} else {
  Add-Section -Path $reportPath -Title 'Defender (after)' -Lines @(
    "- AM Service Enabled: $($defAfter.AMServiceEnabled)",
    "- Real-Time Protection: $($defAfter.RealTimeProtectionEnabled)",
    "- Antivirus Enabled: $($defAfter.AntivirusEnabled)",
    "- Signature Updated: $($defAfter.AntivirusSignatureLastUpdated)"
  )
}

Write-Host "Report created: $reportPath"
