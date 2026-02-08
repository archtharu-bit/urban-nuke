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

Ensure-Dir $OutDir

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Invoke-Step([string]$Name, [scriptblock]$Block) {
  Write-Host ("==> {0}" -f $Name)
  try {
    $global:LASTEXITCODE = 0
    & $Block
    if ($global:LASTEXITCODE -ne 0) {
      throw "Step exited with code $global:LASTEXITCODE"
    }
    Write-Host ("[OK] {0}" -f $Name)
  } catch {
    Write-Host ("[FAIL] {0}: {1}" -f $Name, $_.Exception.Message)
  }
}

Invoke-Step 'Urban Nuke: report' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") -Action report -OutDir $OutDir
}
Invoke-Step 'Urban Nuke: security' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") -Action security -OutDir $OutDir
}
Invoke-Step 'Urban Nuke: hardware' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") -Action hardware -OutDir $OutDir
}
Invoke-Step 'Urban Nuke: network' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "urban-nuke.ps1") -Action network -OutDir $OutDir
}
Invoke-Step 'VS Code: scan' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "vscode-scan.ps1") -OutDir $OutDir
}
Invoke-Step 'Stability: AI/graphics readiness scan' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "stability-scan.ps1") -OutDir $OutDir
}
Invoke-Step 'Windows Update: scan (pending + history)' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "windows-update-scan.ps1") -OutDir $OutDir
}
Invoke-Step 'Defender: status (no scan)' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "defender-scan.ps1") -OutDir $OutDir
}
Invoke-Step 'Cleanup: scan (no deletions)' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "cleanup-scan.ps1") -OutDir $OutDir
}
Invoke-Step 'Remote: check' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "remote-check.ps1") -OutDir $OutDir
}
Invoke-Step 'MySQL: propose tuning (no apply)' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "mysql-tune.ps1") -OutDir $OutDir
}
Invoke-Step 'AWS CLI: check' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "aws-cli-check.ps1") -OutDir $OutDir
}
Invoke-Step 'Red Hat Java: check' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "redhat-check.ps1") -OutDir $OutDir
}
Invoke-Step 'Local Tools: check' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "local-check.ps1") -OutDir $OutDir
}
Invoke-Step 'SSH: setup' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "ssh-setup.ps1") -OutDir $OutDir
}
Invoke-Step 'Security: baseline' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "security-baseline.ps1") -OutDir $OutDir
}
Invoke-Step 'Duplicates: scan' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "duplicate-scan.ps1") -OutDir $OutDir
}

Write-Host "All automation complete. Check reports folder."
