param(
  [Parameter()]
  [string]$OutDir = "reports"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Ensure-Dir([string]$Path) {
  if (-not (Test-Path -Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function New-ReportPath([string]$Prefix, [string]$OutDir) {
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  return Join-Path $OutDir ("{0}-{1}.md" -f $Prefix, $timestamp)
}

Ensure-Dir $OutDir
$reportPath = New-ReportPath 'local-check' $OutDir

Add-Content -Path $reportPath -Value "# Local Tools Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

$tools = @(
  @{ Name = "git"; Cmd = "git --version" },
  @{ Name = "node"; Cmd = "node --version" },
  @{ Name = "python"; Cmd = "python --version" },
  @{ Name = "powershell"; Cmd = "$PSVersionTable.PSVersion" }
)

foreach ($t in $tools) {
  try {
    if ($t.Name -eq "powershell") {
      Add-Content -Path $reportPath -Value ("- powershell: {0}" -f $t.Cmd)
    } else {
      $out = Invoke-Expression $t.Cmd
      Add-Content -Path $reportPath -Value ("- {0}: {1}" -f $t.Name, $out)
    }
  } catch {
    Add-Content -Path $reportPath -Value ("- {0}: not found" -f $t.Name)
  }
}

Write-Host "Report created: $reportPath"
