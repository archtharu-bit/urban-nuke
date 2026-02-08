param(
  [Parameter()]
  [string]$LogPath = "defender-repair-admin.log"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

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

function Log-Section([string]$Title) {
  Write-Log ""
  Write-Log ("=== {0} ===" -f $Title)
}

$mpCmdRun = 'C:\Program Files\Windows Defender\MpCmdRun.exe'

"=== Defender Repair (Admin) ===" | Out-File -FilePath $LogPath -Encoding UTF8
Write-Log ("Time: {0}" -f (Get-Date))
Write-Log ("User: {0}" -f (whoami))

Log-Section 'Pre: services'
Get-Service -Name WinDefend, WdNisSvc, SecurityHealthService -ErrorAction SilentlyContinue |
  Format-Table Name, Status, StartType -Auto | Out-String | Write-Log

Log-Section 'Pre: Mp status'
try {
  Get-MpComputerStatus |
    Format-List AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IsTamperProtected,AntivirusSignatureLastUpdated |
    Out-String | Write-Log
} catch {
  Write-Log ("Get-MpComputerStatus failed: {0}" -f $_.Exception.Message)
}

Log-Section 'Step 1: Stop services (best-effort)'
foreach ($svc in @('WdNisSvc','WinDefend')) {
  try {
    Stop-Service -Name $svc -Force -ErrorAction Stop
    Write-Log ("Stopped: {0}" -f $svc)
  } catch {
    Write-Log ("Stop-Service {0} failed: {1}" -f $svc, $_.Exception.Message)
  }
}

Log-Section 'Step 2: Remove definitions (ALL)'
if (Test-Path -LiteralPath $mpCmdRun) {
  try {
    & $mpCmdRun -RemoveDefinitions -All 2>&1 | Out-String | Write-Log
  } catch {
    Write-Log ("MpCmdRun -RemoveDefinitions failed: {0}" -f $_.Exception.Message)
  }
} else {
  Write-Log ("MpCmdRun not found: {0}" -f $mpCmdRun)
}

Log-Section 'Step 3: Signature update (MMPC)'
try {
  & $mpCmdRun -SignatureUpdate -MMPC 2>&1 | Out-String | Write-Log
} catch {
  Write-Log ("MpCmdRun -SignatureUpdate failed: {0}" -f $_.Exception.Message)
}

Log-Section 'Step 4: Start drivers + services'
try { sc.exe start WdFilter 2>&1 | Out-String | Write-Log } catch { }
try { sc.exe start WdNisDrv 2>&1 | Out-String | Write-Log } catch { }
try { sc.exe start WinDefend 2>&1 | Out-String | Write-Log } catch { }
try { sc.exe start WdNisSvc 2>&1 | Out-String | Write-Log } catch { }

Log-Section 'Step 5: Set Defender preferences'
try {
  Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
  Write-Log 'Set-MpPreference DisableRealtimeMonitoring=false OK'
} catch {
  Write-Log ("Set-MpPreference realtime failed: {0}" -f $_.Exception.Message)
}

try {
  Set-MpPreference -PUAProtection Enabled -ErrorAction Stop
  Write-Log 'Set-MpPreference PUAProtection=Enabled OK'
} catch {
  Write-Log ("Set-MpPreference PUA failed: {0}" -f $_.Exception.Message)
}

Log-Section 'Post: services'
Get-Service -Name WinDefend, WdNisSvc, SecurityHealthService -ErrorAction SilentlyContinue |
  Format-Table Name, Status, StartType -Auto | Out-String | Write-Log

Log-Section 'Post: Mp status'
try {
  Get-MpComputerStatus |
    Format-List AMServiceEnabled,AntivirusEnabled,RealTimeProtectionEnabled,IsTamperProtected,AntivirusSignatureLastUpdated |
    Out-String | Write-Log
} catch {
  Write-Log ("Get-MpComputerStatus failed: {0}" -f $_.Exception.Message)
}

Write-Log ""
Write-Log 'DONE'
