param(
  [Parameter()]
  [string]$OutDir = "reports"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'windows-update-scan' -OutDir $OutDir

Add-ReportHeader -Path $reportPath -Title 'Windows Update Scan'

function Format-Update([object]$Update) {
  $kb = $null
  try {
    $kb = ($Update.KBArticleIDs | Select-Object -First 1)
  } catch {
    $kb = $null
  }

  $cats = @()
  try {
    foreach ($c in @($Update.Categories)) {
      $cats += $c.Name
    }
  } catch {
    $cats = @()
  }

  $category = if ($cats.Count -gt 0) { $cats -join ', ' } else { 'Uncategorized' }
  $kbText = if ([string]::IsNullOrWhiteSpace($kb)) { '' } else { "KB$kb " }
  return "- ${kbText}$($Update.Title) [$category]"
}

try {
  $session = New-Object -ComObject Microsoft.Update.Session
  $searcher = $session.CreateUpdateSearcher()
  $historyCount = $searcher.GetTotalHistoryCount()
  $history = $searcher.QueryHistory(0, [Math]::Min($historyCount, 30))

  $historyLines = @()
  foreach ($h in @($history)) {
    $result = switch ($h.ResultCode) {
      2 { 'Succeeded' }
      3 { 'SucceededWithErrors' }
      4 { 'Failed' }
      5 { 'Aborted' }
      default { "Code$($h.ResultCode)" }
    }
    $historyLines += "- $($h.Date): [$result] $($h.Title)"
  }
  if ($historyLines.Count -eq 0) {
    $historyLines = @('- No update history entries found via COM API.')
  }

  Add-Section -Path $reportPath -Title 'Recent Update History (last 30 entries)' -Lines (Limit-Lines -Lines $historyLines -MaxLines 40)

  $criteria = "IsInstalled=0 and IsHidden=0"
  $result = $searcher.Search($criteria)
  $updates = $result.Updates

  $pendingLines = @()
  for ($i = 0; $i -lt $updates.Count; $i++) {
    $u = $updates.Item($i)
    $pendingLines += (Format-Update -Update $u)
  }

  if ($pendingLines.Count -eq 0) {
    $pendingLines = @('- No pending updates found.')
  }

  Add-Section -Path $reportPath -Title 'Pending Updates' -Lines (Limit-Lines -Lines $pendingLines -MaxLines 80)
} catch {
  Add-Section -Path $reportPath -Title 'Status' -Lines @(
    "- Windows Update COM scan failed: $($_.Exception.Message)",
    "- If this persists, run PowerShell as Administrator and ensure Windows Update service is enabled."
  )
}

Add-Section -Path $reportPath -Title 'Notes' -Lines @(
  '- This report only *detects* pending updates; it does not install anything.',
  '- For driver updates, prefer your laptop OEM tools first, then GPU vendor tools if needed.'
)

Write-Host "Report created: $reportPath"
