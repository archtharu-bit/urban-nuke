param(
  [Parameter()]
  [string]$OutDir = "reports"
)

. "$PSScriptRoot\_lib.ps1"

Ensure-Dir $OutDir
$reportPath = New-ReportPath -Prefix "security-baseline" -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title "Security Baseline" -Meta @{"User"=$env:USERNAME; "Host"=$env:COMPUTERNAME}

# Firewall
try {
  Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction Stop
  Add-Section -Path $reportPath -Title "Firewall" -Lines @("- Enabled for all profiles")
} catch {
  Add-Section -Path $reportPath -Title "Firewall" -Lines @("- Not applied: $($_.Exception.Message)")
}

# Defender baseline
try {
  Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
  Add-Section -Path $reportPath -Title "Defender" -Lines @("- Real-time protection enabled")
} catch {
  Add-Section -Path $reportPath -Title "Defender" -Lines @("- Not applied: $($_.Exception.Message)")
}

try {
  Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
  Add-Section -Path $reportPath -Title "PUA Protection" -Lines @("- Enabled")
} catch {
  Add-Section -Path $reportPath -Title "PUA Protection" -Lines @("- Not applied: $($_.Exception.Message)")
}

Write-Host "Report created: $reportPath"
