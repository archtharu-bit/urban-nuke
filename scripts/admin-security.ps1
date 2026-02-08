. "$PSScriptRoot\_lib.ps1"

param(
  [Parameter()]
  [string]$OutDir = "reports"
)

Ensure-Dir $OutDir
$reportPath = New-ReportPath -Prefix "admin-security" -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title "Admin Security" -Meta @{"User"=$env:USERNAME; "Host"=$env:COMPUTERNAME}

function Add-Result([string]$Title, [string]$Message) {
  Add-Section -Path $reportPath -Title $Title -Lines @($Message)
}

# OpenSSH Server install/start
try {
  $cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
  if ($cap.State -ne 'Installed') {
    Add-WindowsCapability -Online -Name $cap.Name | Out-Null
    Add-Result "OpenSSH Server" "- Installed"
  } else {
    Add-Result "OpenSSH Server" "- Already installed"
  }

  Start-Service sshd
  Set-Service -Name sshd -StartupType Automatic
  Add-Result "sshd Service" "- Running and set to Automatic"
} catch {
  Add-Result "OpenSSH Server" "- Failed: $($_.Exception.Message)"
}

# Firewall rule
try {
  if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -DisplayName "OpenSSH Server (sshd)" -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
    Add-Result "Firewall" "- OpenSSH inbound rule created"
  } else {
    Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled True | Out-Null
    Add-Result "Firewall" "- OpenSSH inbound rule enabled"
  }
} catch {
  Add-Result "Firewall" "- Failed: $($_.Exception.Message)"
}

# Defender
try {
  Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
  Add-Result "Defender" "- Real-time protection enabled"
} catch {
  Add-Result "Defender" "- Failed: $($_.Exception.Message)"
}

try {
  Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
  Add-Result "PUA Protection" "- Enabled"
} catch {
  Add-Result "PUA Protection" "- Failed: $($_.Exception.Message)"
}

Write-Host "Report created: $reportPath"
