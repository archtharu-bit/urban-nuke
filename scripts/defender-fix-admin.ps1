param(
  [Parameter()]
  [string]$LogPath = "defender-fix-admin.log"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-AdminToken {
  $current = [Security.Principal.WindowsIdentity]::GetCurrent()
  $principal = New-Object Security.Principal.WindowsPrincipal($current)
  return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Write-Log {
  param(
    [Parameter(ValueFromPipeline = $true)]
    [AllowNull()]
    [string]$Text
  )

  process {
    if ($null -eq $Text) { return }
    $Text | Out-File -FilePath $LogPath -Append -Encoding UTF8
  }
}

"=== Defender Fix (Admin) ===" | Out-File -FilePath $LogPath -Encoding UTF8
Write-Log ("Time: {0}" -f (Get-Date))
Write-Log ("User: {0}" -f (whoami))
Write-Log ("IsAdminToken: {0}" -f (Test-AdminToken))

Write-Log ""
Write-Log "--- Pre: Services ---"
try {
  Get-Service -Name WinDefend, WdNisSvc, SecurityHealthService -ErrorAction Stop |
    Format-Table Name, Status, StartType -Auto | Out-String | Write-Log
} catch {
  Write-Log ("Get-Service failed: {0}" -f $_.Exception.Message)
}

Write-Log ""
Write-Log "--- Pre: Service security (sdshow) ---"
try {
  cmd.exe /c "sc sdshow WinDefend" | Out-String | Write-Log
  cmd.exe /c "sc sdshow WdNisSvc" | Out-String | Write-Log
} catch {
  Write-Log ("sdshow failed: {0}" -f $_.Exception.Message)
}

Write-Log ""
Write-Log "--- Apply: set service start ---"
try {
  Set-Service -Name WinDefend -StartupType Automatic -ErrorAction Stop
  Set-Service -Name WdNisSvc -StartupType Automatic -ErrorAction Stop
  Write-Log "Set-Service OK"
} catch {
  Write-Log ("Set-Service failed: {0}" -f $_.Exception.Message)
}

try {
  Start-Service -Name WinDefend -ErrorAction Stop
  Write-Log "Start-Service WinDefend OK"
} catch {
  Write-Log ("Start-Service WinDefend failed: {0}" -f $_.Exception.Message)
  try { cmd.exe /c "sc start WinDefend" | Out-String | Write-Log } catch { }
}

try {
  Start-Service -Name WdNisSvc -ErrorAction Stop
  Write-Log "Start-Service WdNisSvc OK"
} catch {
  Write-Log ("Start-Service WdNisSvc failed: {0}" -f $_.Exception.Message)
  try { cmd.exe /c "sc start WdNisSvc" | Out-String | Write-Log } catch { }
}

Write-Log ""
Write-Log "--- Apply: Defender preferences ---"
try {
  Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
  Write-Log "Set-MpPreference DisableRealtimeMonitoring=false OK"
} catch {
  Write-Log ("Set-MpPreference realtime failed: {0}" -f $_.Exception.Message)
}

try {
  Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
  Write-Log "Set-MpPreference PUAProtection=Enabled OK"
} catch {
  Write-Log ("Set-MpPreference PUA failed: {0}" -f $_.Exception.Message)
}

Write-Log ""
Write-Log "--- Post: MpComputerStatus (selected) ---"
try {
  Get-MpComputerStatus |
    Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled, IsTamperProtected, AntivirusSignatureLastUpdated |
    Format-List | Out-String | Write-Log
} catch {
  Write-Log ("Get-MpComputerStatus failed: {0}" -f $_.Exception.Message)
}

Write-Log ""
Write-Log "DONE"
