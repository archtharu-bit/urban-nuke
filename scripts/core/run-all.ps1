param(
  [Parameter()]
  [string]$OutDir = "reports",

  # Default: generate ONE combined collection report (prevents report spam/duplicates).
  [Parameter()]
  [ValidateSet('collection','individual')]
  [string]$Mode = 'collection',

  # If -Mode collection, keep the intermediate per-step reports (stored temporarily).
  [Parameter()]
  [switch]$KeepIndividualReports,

  # Opt-in: allow scripts that can change system configuration (SSH setup, security baseline).
  [Parameter()]
  [switch]$IncludeApplyActions
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

if ($Mode -eq 'collection') {
  Write-Host "==> Run All (collection mode)"
  # Call directly to avoid external argument conversion quirks for switch parameters.
  & (Join-Path $scriptRoot "report-collection.ps1") -OutDir $OutDir -KeepIndividualReports:$KeepIndividualReports
  Write-Host "All automation complete. Check reports folder."
  exit 0
}

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
if ($IncludeApplyActions) {
  Invoke-Step 'SSH: setup (APPLY ACTION)' {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "ssh-setup.ps1") -OutDir $OutDir
  }
  Invoke-Step 'Security: baseline (APPLY ACTION)' {
    & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "security-baseline.ps1") -OutDir $OutDir
  }
} else {
  Write-Host "==> Skipping apply actions (SSH setup, security baseline). Use -IncludeApplyActions to enable."
}
Invoke-Step 'Duplicates: scan' {
  & powershell -ExecutionPolicy Bypass -File (Join-Path $scriptRoot "duplicate-scan.ps1") -OutDir $OutDir
}

Write-Host "All automation complete. Check reports folder."
