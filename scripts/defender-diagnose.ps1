param(
  [Parameter()]
  [string]$OutDir = 'reports'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

function Test-Admin {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'defender-diagnose' -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title 'Defender Diagnose (Why is Defender OFF?)' -Meta @{
  IsAdmin = [bool](Test-Admin)
}

$av = Safe-Get -Label 'SecurityCenter2 AntivirusProduct' {
  Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct |
    Select-Object displayName, pathToSignedProductExe, productState
}

if ($av -is [string]) {
  Add-Section -Path $reportPath -Title 'Detected Antivirus Products (SecurityCenter2)' -Lines @("- $av")
} else {
  $lines = @()
  foreach ($p in @($av)) {
    $lines += "- $($p.displayName)"
    $lines += "  - Exe: $($p.pathToSignedProductExe)"
    $lines += "  - productState: $($p.productState)"
  }
  if ($lines.Count -eq 0) { $lines = @('- None detected via SecurityCenter2.') }
  Add-Section -Path $reportPath -Title 'Detected Antivirus Products (SecurityCenter2)' -Lines $lines
}

$services = Safe-Get -Label 'Defender services' {
  Get-Service -Name WinDefend, WdNisSvc, SecurityHealthService -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType
}

if ($services -is [string]) {
  Add-Section -Path $reportPath -Title 'Services' -Lines @("- $services")
} else {
  $svcLines = @()
  foreach ($s in @($services)) {
    $svcLines += "- $($s.Name): $($s.Status) (StartType=$($s.StartType))"
  }
  Add-Section -Path $reportPath -Title 'Services' -Lines $svcLines
}

$status = Safe-Get -Label 'Get-MpComputerStatus' { Get-MpComputerStatus }
if ($status -is [string]) {
  Add-Section -Path $reportPath -Title 'Get-MpComputerStatus' -Lines @("- $status")
} else {
  Add-Section -Path $reportPath -Title 'Get-MpComputerStatus' -Lines @(
    "- AMServiceEnabled: $($status.AMServiceEnabled)",
    "- AntivirusEnabled: $($status.AntivirusEnabled)",
    "- RealTimeProtectionEnabled: $($status.RealTimeProtectionEnabled)",
    "- IsTamperProtected: $($status.IsTamperProtected)",
    "- AntivirusSignatureLastUpdated: $($status.AntivirusSignatureLastUpdated)",
    "- FullScanAge: $($status.FullScanAge)",
    "- QuickScanAge: $($status.QuickScanAge)"
  )
}

$pref = Safe-Get -Label 'Get-MpPreference' { Get-MpPreference }
if ($pref -is [string]) {
  Add-Section -Path $reportPath -Title 'Get-MpPreference' -Lines @("- $pref")
} else {
  Add-Section -Path $reportPath -Title 'Get-MpPreference (selected)' -Lines @(
    "- DisableRealtimeMonitoring: $($pref.DisableRealtimeMonitoring)",
    "- PUAProtection: $($pref.PUAProtection)",
    "- DisableIOAVProtection: $($pref.DisableIOAVProtection)",
    "- DisableBehaviorMonitoring: $($pref.DisableBehaviorMonitoring)",
    "- DisableBlockAtFirstSeen: $($pref.DisableBlockAtFirstSeen)",
    "- SignatureDisableUpdateOnStartupWithoutEngine: $($pref.SignatureDisableUpdateOnStartupWithoutEngine)"
  )
}

$policyPaths = @(
  'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender',
  'HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection'
)

$policyLines = @()
foreach ($pp in $policyPaths) {
  try {
    if (Test-Path -LiteralPath $pp) {
      $props = Get-ItemProperty -LiteralPath $pp
      $policyLines += "- Path: $pp"
      foreach ($name in @('DisableAntiSpyware','DisableAntiVirus','DisableRealtimeMonitoring','DisableBehaviorMonitoring','DisableOnAccessProtection','DisableScanOnRealtimeEnable')) {
        if ($null -ne $props.$name) {
          $policyLines += "  - $name = $($props.$name)"
        }
      }
    } else {
      $policyLines += "- Path: $pp (not present)"
    }
  } catch {
    $policyLines += "- Path: $pp (error: $($_.Exception.Message))"
  }
}
Add-Section -Path $reportPath -Title 'Group Policy / Registry hints' -Lines $policyLines

Add-Section -Path $reportPath -Title 'Interpretation (what to do)' -Lines @(
  '- If a 3rd-party antivirus is listed above, it often disables Defender. Decide which AV you want and uninstall the other.',
  '- If IsTamperProtected=True, Defender changes may be blocked. In Windows Security -> Virus & threat protection settings, temporarily turn off Tamper Protection, apply changes, then turn it back on.',
  '- If registry policy values like DisableAntiSpyware/DisableRealtimeMonitoring are set, a policy is disabling Defender. That must be removed/changed (often requires admin + Windows Pro/Enterprise policy editor).',
  '- After fixing the root cause, re-run: scripts\\apply-now.ps1 -Apply -DefenderScan quick'
)

Write-Host "Report created: $reportPath"
