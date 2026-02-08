param(
  [Parameter()]
  [string]$OutDir = "reports",

  # If set, add AWSCLIV2 install folder to the *User* PATH.
  # Default is safe/no-change.
  [Parameter()]
  [switch]$SetPath
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
$reportPath = New-ReportPath 'aws-cli-check' $OutDir

Add-Content -Path $reportPath -Value "# AWS CLI Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

$awsRoot = "C:\Program Files\Amazon\AWSCLIV2"
$awsExe = Join-Path $awsRoot "aws.exe"

if (Test-Path $awsExe) {
  $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $pathHasAws = ($userPath -like "*${awsRoot}*")
  Add-Content -Path $reportPath -Value ("- Install found: {0}" -f $awsExe)
  Add-Content -Path $reportPath -Value ("- In user PATH: {0}" -f $pathHasAws)

  if ($SetPath) {
    if (-not $pathHasAws) {
      $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $awsRoot } else { "$userPath;$awsRoot" }
      [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
      Add-Content -Path $reportPath -Value "- Action: added AWS CLI install dir to user PATH"
    } else {
      Add-Content -Path $reportPath -Value "- Action: no change (already in user PATH)"
    }
  } else {
    Add-Content -Path $reportPath -Value "- Action: no change (run with -SetPath to modify user PATH)"
  }

  # Use direct path so version check doesn't depend on PATH.
  $version = & $awsExe --version
  Add-Content -Path $reportPath -Value ("- Version: {0}" -f $version)
} else {
  Add-Content -Path $reportPath -Value "- AWS CLI not found at default path"
}

Write-Host "Report created: $reportPath"
