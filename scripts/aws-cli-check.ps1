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
$reportPath = New-ReportPath 'aws-cli-check' $OutDir

Add-Content -Path $reportPath -Value "# AWS CLI Check"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))

$awsRoot = "C:\Program Files\Amazon\AWSCLIV2"
$awsExe = Join-Path $awsRoot "aws.exe"

if (Test-Path $awsExe) {
  $userPath = [Environment]::GetEnvironmentVariable("Path","User")
  if ($userPath -notlike "*${awsRoot}*") {
    $newPath = if ([string]::IsNullOrWhiteSpace($userPath)) { $awsRoot } else { "$userPath;$awsRoot" }
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Add-Content -Path $reportPath -Value "- Added AWS CLI to user PATH"
  }
  $env:Path = "$env:Path;$awsRoot"
  $version = & $awsExe --version
  Add-Content -Path $reportPath -Value ("- Version: {0}" -f $version)
} else {
  Add-Content -Path $reportPath -Value "- AWS CLI not found at default path"
}

Write-Host "Report created: $reportPath"
