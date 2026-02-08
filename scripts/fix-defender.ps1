param([switch]$Apply)

Write-Host "=== FIX DEFENDER REAL-TIME PROTECTION ===" -ForegroundColor Cyan

$defender = Get-MpComputerStatus

Write-Host "`nCurrent Status:" -ForegroundColor Yellow
Write-Host "  Real-time Protection: $($defender.RealTimeProtectionEnabled)" -ForegroundColor $(if($defender.RealTimeProtectionEnabled){'Green'}else{'Red'})
Write-Host "  Tamper Protection: $($defender.IsTamperProtected)" -ForegroundColor Gray

if (-not $defender.RealTimeProtectionEnabled) {
  if ($Apply) {
    Write-Host "`nEnabling Defender..." -ForegroundColor Yellow
    
    # Enable real-time protection
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
    
    # Start services
    Start-Service -Name WinDefend -ErrorAction SilentlyContinue
    Start-Service -Name WdNisSvc -ErrorAction SilentlyContinue
    
    # Update signatures
    Update-MpSignature -ErrorAction SilentlyContinue
    
    Start-Sleep -Seconds 2
    
    $newStatus = Get-MpComputerStatus
    Write-Host "`nNew Status:" -ForegroundColor Green
    Write-Host "  Real-time Protection: $($newStatus.RealTimeProtectionEnabled)" -ForegroundColor $(if($newStatus.RealTimeProtectionEnabled){'Green'}else{'Red'})
    
    if ($newStatus.RealTimeProtectionEnabled) {
      Write-Host "`nDEFENDER ENABLED!" -ForegroundColor Green
    } else {
      Write-Host "`nFAILED - Tamper Protection may be blocking" -ForegroundColor Red
      Write-Host "Manually enable: Windows Security -> Virus & threat protection -> Manage settings" -ForegroundColor Yellow
    }
  } else {
    Write-Host "`nRun with -Apply to enable Defender" -ForegroundColor Red
  }
} else {
  Write-Host "`nDefender is already enabled!" -ForegroundColor Green
}
