param(
  [Parameter()]
  [string]$OutDir = "reports",

  # Default: status only.
  [Parameter()]
  [switch]$QuickScan,

  # Full scan can take a long time.
  [Parameter()]
  [switch]$FullScan,

  # Offline scan requires reboot. Windows will prompt and schedule it.
  [Parameter()]
  [switch]$OfflineScan
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'defender-scan' -OutDir $OutDir

Add-ReportHeader -Path $reportPath -Title 'Microsoft Defender Scan' -Meta @{
  QuickScan = [bool]$QuickScan
  FullScan = [bool]$FullScan
  OfflineScan = [bool]$OfflineScan
}

$status = Safe-Get -Label 'Get-MpComputerStatus' { Get-MpComputerStatus }
if ($status -is [string]) {
  Add-Section -Path $reportPath -Title 'Defender Status' -Lines @("- $status")
} else {
  Add-Section -Path $reportPath -Title 'Defender Status' -Lines @(
    "- AM Service Enabled: $($status.AMServiceEnabled)",
    "- Real-Time Protection: $($status.RealTimeProtectionEnabled)",
    "- Antivirus Enabled: $($status.AntivirusEnabled)",
    "- Signature Updated: $($status.AntivirusSignatureLastUpdated)",
    "- Full Scan Age (days): $($status.FullScanAge)",
    "- Quick Scan Age (days): $($status.QuickScanAge)"
  )
}

if ($OfflineScan) {
  try {
    Start-MpWDOScan -ErrorAction Stop
    Add-Section -Path $reportPath -Title 'Offline Scan' -Lines @(
      '- Offline scan scheduled. Your PC will need to reboot to complete it.'
    )
  } catch {
    Add-Section -Path $reportPath -Title 'Offline Scan' -Lines @(
      "- Failed to schedule offline scan: $($_.Exception.Message)"
    )
  }
}

if ($FullScan) {
  try {
    Start-MpScan -ScanType FullScan -ErrorAction Stop
    Add-Section -Path $reportPath -Title 'Full Scan' -Lines @('- Full scan started.')
  } catch {
    Add-Section -Path $reportPath -Title 'Full Scan' -Lines @(
      "- Failed to start full scan: $($_.Exception.Message)"
    )
  }
} elseif ($QuickScan) {
  try {
    Start-MpScan -ScanType QuickScan -ErrorAction Stop
    Add-Section -Path $reportPath -Title 'Quick Scan' -Lines @('- Quick scan started.')
  } catch {
    Add-Section -Path $reportPath -Title 'Quick Scan' -Lines @(
      "- Failed to start quick scan: $($_.Exception.Message)"
    )
  }
} else {
  Add-Section -Path $reportPath -Title 'Scan' -Lines @(
    '- No scan started (status only). Use -QuickScan, -FullScan, or -OfflineScan.'
  )
}

Write-Host "Report created: $reportPath"
