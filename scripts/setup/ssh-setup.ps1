param(
  [Parameter()]
  [string]$OutDir = "reports"
)

. "$PSScriptRoot\_lib.ps1"

Ensure-Dir $OutDir
$reportPath = New-ReportPath -Prefix "ssh-setup" -OutDir $OutDir
Add-ReportHeader -Path $reportPath -Title "SSH Setup" -Meta @{"User"=$env:USERNAME; "Host"=$env:COMPUTERNAME}

$sshDir = Join-Path $env:USERPROFILE ".ssh"
Ensure-Dir $sshDir
Add-Section -Path $reportPath -Title "SSH Directory" -Lines @("- Path: $sshDir")

$keyPath = Join-Path $sshDir "id_ed25519"
$pubPath = "$keyPath.pub"
if (-not (Test-Path $keyPath)) {
  $result = Invoke-External -FilePath "ssh-keygen" -Arguments @("-t","ed25519","-f","`"$keyPath`"","-N","`"`"")
  Add-Section -Path $reportPath -Title "Key Generation" -Lines @(
    "- Generated new ed25519 keypair",
    "- ExitCode: $($result.ExitCode)",
    "- Stderr: $($result.Stderr)"
  )
} else {
  Add-Section -Path $reportPath -Title "Key Generation" -Lines @("- Existing keypair found")
}

$authorized = Join-Path $sshDir "authorized_keys"
if (Test-Path $pubPath) {
  $pub = Get-Content -Path $pubPath -Raw
  if (-not (Test-Path $authorized)) {
    Set-Content -Path $authorized -Value $pub
    Add-Section -Path $reportPath -Title "authorized_keys" -Lines @("- Created and added public key")
  } else {
    $current = Get-Content -Path $authorized -Raw
    if ($current -notmatch [regex]::Escape($pub.Trim())) {
      Add-Content -Path $authorized -Value $pub
      Add-Section -Path $reportPath -Title "authorized_keys" -Lines @("- Added public key")
    } else {
      Add-Section -Path $reportPath -Title "authorized_keys" -Lines @("- Public key already present")
    }
  }
}

$sshConfig = Join-Path $sshDir "config"
$entry = @(
  "Host local",
  "  HostName localhost",
  "  User $env:USERNAME",
  "  Port 22"
) -join "`r`n"
if (-not (Test-Path $sshConfig)) {
  Set-Content -Path $sshConfig -Value $entry
  Add-Section -Path $reportPath -Title "SSH Config" -Lines @("- Created local host entry")
} else {
  $conf = Get-Content -Path $sshConfig -Raw
  if ($conf -notmatch "Host local") {
    Add-Content -Path $sshConfig -Value ("`r`n" + $entry)
    Add-Section -Path $reportPath -Title "SSH Config" -Lines @("- Added local host entry")
  } else {
    Add-Section -Path $reportPath -Title "SSH Config" -Lines @("- Local host entry exists")
  }
}

# Try to install OpenSSH server (requires admin)
try {
  $cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
  Add-Section -Path $reportPath -Title "OpenSSH Server Capability" -Lines @(
    "- Name: $($cap.Name)",
    "- State: $($cap.State)"
  )
} catch {
  Add-Section -Path $reportPath -Title "OpenSSH Server Capability" -Lines @(
    "- Not checked (requires admin): $($_.Exception.Message)"
  )
}

try {
  $sshd = Get-Service -Name sshd -ErrorAction Stop
  Add-Section -Path $reportPath -Title "sshd Service" -Lines @(
    "- Status: $($sshd.Status)"
  )
} catch {
  Add-Section -Path $reportPath -Title "sshd Service" -Lines @(
    "- Not installed or not available"
  )
}

try {
  $fw = Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction Stop
  Add-Section -Path $reportPath -Title "Firewall Rule" -Lines @(
    "- Rule: $($fw.Name)",
    "- Enabled: $($fw.Enabled)"
  )
} catch {
  Add-Section -Path $reportPath -Title "Firewall Rule" -Lines @(
    "- Rule not found"
  )
}

Write-Host "Report created: $reportPath"
