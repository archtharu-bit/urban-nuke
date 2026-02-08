param(
  [Parameter(Position=0)]
  [ValidateSet('report','security','hardware','network')]
  [string]$Action = 'report',

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

function Safe-Get([string]$Label, [scriptblock]$Block) {
  try {
    return & $Block
  } catch {
    return "[Unavailable] ${Label}: $($_.Exception.Message)"
  }
}

function As-Array($Value) {
  if ($null -eq $Value) { return @() }
  if ($Value -is [string]) { return @($Value) }
  return @($Value)
}

function New-ReportPath([string]$Prefix, [string]$OutDir) {
  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  return Join-Path $OutDir ("{0}-{1}.md" -f $Prefix, $timestamp)
}

function Write-Section([string]$Path, [string]$Title, [string[]]$Lines) {
  Add-Content -Path $Path -Value "`n## $Title`n"
  foreach ($line in $Lines) {
    Add-Content -Path $Path -Value $line
  }
}

Ensure-Dir $OutDir

$reportPath = New-ReportPath $Action $OutDir
Add-Content -Path $reportPath -Value "# Urban Nuke Report"
Add-Content -Path $reportPath -Value ("Generated: {0}" -f (Get-Date))
Add-Content -Path $reportPath -Value ("Action: {0}" -f $Action)

if ($Action -in @('report','hardware')) {
  $os = Safe-Get 'OS' { Get-CimInstance Win32_OperatingSystem }
  $cpu = Safe-Get 'CPU' { Get-CimInstance Win32_Processor }
  $ram = Safe-Get 'RAM' { Get-CimInstance Win32_PhysicalMemory }
  $gpu = Safe-Get 'GPU' { Get-CimInstance Win32_VideoController }
  $bios = Safe-Get 'BIOS' { Get-CimInstance Win32_BIOS }

  Write-Section $reportPath 'OS' @(
    "- Caption: $($os.Caption)",
    "- Version: $($os.Version)",
    "- Build: $($os.BuildNumber)",
    "- Install Date: $($os.InstallDate)"
  )

  Write-Section $reportPath 'CPU' @(
    "- Name: $($cpu.Name)",
    "- Cores: $($cpu.NumberOfCores)",
    "- Logical Processors: $($cpu.NumberOfLogicalProcessors)"
  )

  $totalRamBytes = 0
  foreach ($stick in @($ram)) {
    $totalRamBytes += [int64]$stick.Capacity
  }
  $totalRamGb = [math]::Round($totalRamBytes / 1GB, 2)

  Write-Section $reportPath 'Memory' @(
    "- Total: $totalRamGb GB",
    "- Modules: $(@($ram).Count)"
  )

  Write-Section $reportPath 'GPU' @(
    "- Name: $($gpu.Name)",
    "- Driver Version: $($gpu.DriverVersion)"
  )

  Write-Section $reportPath 'BIOS' @(
    "- Manufacturer: $($bios.Manufacturer)",
    "- Version: $($bios.SMBIOSBIOSVersion)",
    "- Release Date: $($bios.ReleaseDate)"
  )

  $disks = Safe-Get 'Disks' { Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" }
  $diskLines = @()
  foreach ($d in (As-Array $disks)) {
    if ($d -is [string]) {
      $diskLines += "- $d"
    } else {
      $sizeGb = [math]::Round($d.Size / 1GB, 2)
      $freeGb = [math]::Round($d.FreeSpace / 1GB, 2)
      $diskLines += "- $($d.DeviceID): $freeGb GB free / $sizeGb GB total"
    }
  }
  Write-Section $reportPath 'Storage' $diskLines
}

if ($Action -in @('report','network')) {
  $adapters = Safe-Get 'Network Adapters' { Get-NetAdapter }
  $profiles = Safe-Get 'Network Profiles' { Get-NetConnectionProfile }

  $adapterLines = @()
  foreach ($a in (As-Array $adapters)) {
    if ($a -is [string]) {
      $adapterLines += "- $a"
    } else {
      $adapterLines += "- $($a.Name): $($a.Status) ($($a.LinkSpeed))"
    }
  }
  Write-Section $reportPath 'Network Adapters' $adapterLines

  $profileLines = @()
  foreach ($p in (As-Array $profiles)) {
    if ($p -is [string]) {
      $profileLines += "- $p"
    } else {
      $profileLines += "- $($p.Name): $($p.NetworkCategory)"
    }
  }
  Write-Section $reportPath 'Network Profiles' $profileLines
}

if ($Action -in @('report','security')) {
  $defender = Safe-Get 'Defender' { Get-MpComputerStatus }
  $firewall = Safe-Get 'Firewall' { Get-NetFirewallProfile }
  $bitlocker = Safe-Get 'BitLocker' { Get-BitLockerVolume }

  if ($defender -is [string]) {
    Write-Section $reportPath 'Windows Defender' @("- $defender")
  } else {
    Write-Section $reportPath 'Windows Defender' @(
      "- AM Service Enabled: $($defender.AMServiceEnabled)",
      "- Real-Time Protection: $($defender.RealTimeProtectionEnabled)",
      "- Signature Updated: $($defender.AntivirusSignatureLastUpdated)"
    )
  }

  $fwLines = @()
  foreach ($f in (As-Array $firewall)) {
    if ($f -is [string]) {
      $fwLines += "- $f"
    } else {
      $fwLines += "- $($f.Name): Enabled=$($f.Enabled)"
    }
  }
  Write-Section $reportPath 'Firewall' $fwLines

  $blLines = @()
  foreach ($b in (As-Array $bitlocker)) {
    if ($b -is [string]) {
      $blLines += "- $b"
    } else {
      $blLines += "- $($b.MountPoint): $($b.ProtectionStatus)"
    }
  }
  Write-Section $reportPath 'BitLocker' $blLines

  Write-Section $reportPath 'Notes' @(
    "- If sections show unavailable, run PowerShell as Administrator and try again.",
    "- Keep this report private if it contains environment details."
  )
}

Write-Section $reportPath 'Summary' @(
  "- Report path: $reportPath",
  "- Action: $Action"
)

Write-Host "Report created: $reportPath"
