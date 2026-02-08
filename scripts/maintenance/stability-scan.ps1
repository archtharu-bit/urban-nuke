param(
  [Parameter()]
  [string]$OutDir = "reports",

  # Warn if a driver appears older than this threshold.
  [Parameter()]
  [int]$MaxDriverAgeDays = 180
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '_lib.ps1')

Ensure-Dir -Path $OutDir
$reportPath = New-ReportPath -Prefix 'stability-scan' -OutDir $OutDir

Add-ReportHeader -Path $reportPath -Title 'Stability + AI/Graphics Readiness Scan'

$os = Safe-Get -Label 'OS' { Get-CimInstance Win32_OperatingSystem }
$cpu = Safe-Get -Label 'CPU' { Get-CimInstance Win32_Processor }
$gpu = Safe-Get -Label 'GPU' { Get-CimInstance Win32_VideoController }
$bios = Safe-Get -Label 'BIOS' { Get-CimInstance Win32_BIOS }

if ($os -isnot [string]) {
  $uptime = (Get-Date) - $os.LastBootUpTime
  Add-Section -Path $reportPath -Title 'OS' -Lines @(
    "- Caption: $($os.Caption)",
    "- Version: $($os.Version)",
    "- Build: $($os.BuildNumber)",
    ("- Uptime: {0:dd\:hh\:mm}" -f $uptime)
  )
} else {
  Add-Section -Path $reportPath -Title 'OS' -Lines @("- $os")
}

if ($cpu -isnot [string]) {
  Add-Section -Path $reportPath -Title 'CPU' -Lines @(
    "- Name: $($cpu.Name)",
    "- Cores: $($cpu.NumberOfCores)",
    "- Logical: $($cpu.NumberOfLogicalProcessors)",
    "- Max Clock: $($cpu.MaxClockSpeed) MHz"
  )
} else {
  Add-Section -Path $reportPath -Title 'CPU' -Lines @("- $cpu")
}

$ramSticks = Safe-Get -Label 'RAM' { Get-CimInstance Win32_PhysicalMemory }
if ($ramSticks -is [string]) {
  Add-Section -Path $reportPath -Title 'Memory' -Lines @("- $ramSticks")
} else {
  $totalRamBytes = 0
  foreach ($stick in @($ramSticks)) {
    $totalRamBytes += [int64]$stick.Capacity
  }
  $totalRamGb = [math]::Round($totalRamBytes / 1GB, 2)
  Add-Section -Path $reportPath -Title 'Memory' -Lines @(
    "- Total: $totalRamGb GB",
    "- Modules: $(@($ramSticks).Count)"
  )
}

if ($gpu -isnot [string]) {
  $gpuLines = @()
  foreach ($g in @($gpu)) {
    $gpuLines += "- Name: $($g.Name)"
    $gpuLines += "  - Driver Version: $($g.DriverVersion)"
    $gpuLines += "  - Driver Date: $($g.DriverDate)"
    $gpuLines += "  - Video Processor: $($g.VideoProcessor)"
  }
  Add-Section -Path $reportPath -Title 'GPU' -Lines $gpuLines
} else {
  Add-Section -Path $reportPath -Title 'GPU' -Lines @("- $gpu")
}

if ($bios -isnot [string]) {
  Add-Section -Path $reportPath -Title 'BIOS' -Lines @(
    "- Manufacturer: $($bios.Manufacturer)",
    "- Version: $($bios.SMBIOSBIOSVersion)",
    "- ReleaseDate: $($bios.ReleaseDate)"
  )
} else {
  Add-Section -Path $reportPath -Title 'BIOS' -Lines @("- $bios")
}

Add-Section -Path $reportPath -Title 'Power Plan' -Lines (Limit-Lines -Lines (Safe-Get -Label 'powercfg' { (powercfg /getactivescheme) 2>&1 }) -MaxLines 20)

$disks = Safe-Get -Label 'LogicalDisks' { Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" }
if ($disks -is [string]) {
  Add-Section -Path $reportPath -Title 'Storage' -Lines @("- $disks")
} else {
  $diskLines = @()
  foreach ($d in @($disks)) {
    $sizeGb = if ($d.Size) { [math]::Round($d.Size / 1GB, 2) } else { 0 }
    $freeGb = if ($d.FreeSpace) { [math]::Round($d.FreeSpace / 1GB, 2) } else { 0 }
    $pctFree = if ($d.Size -and $d.Size -gt 0) { [math]::Round(($d.FreeSpace / $d.Size) * 100, 2) } else { 0 }
    $diskLines += "- $($d.DeviceID): $freeGb GB free / $sizeGb GB total ($pctFree% free)"
  }
  Add-Section -Path $reportPath -Title 'Storage' -Lines $diskLines
}

# Driver age snapshot (cannot confirm online newest versions; this is local evidence only)
$maxAge = (Get-Date).AddDays(-1 * $MaxDriverAgeDays)
$displayDrivers = Safe-Get -Label 'DisplayDrivers' {
  Get-CimInstance Win32_PnPSignedDriver | Where-Object { $_.DeviceClass -eq 'DISPLAY' }
}

if ($displayDrivers -is [string]) {
  Add-Section -Path $reportPath -Title 'Display Drivers' -Lines @("- $displayDrivers")
} else {
  $driverLines = @()
  foreach ($d in @($displayDrivers) | Sort-Object DriverDate -Descending) {
    $driverDate = $null
    try { $driverDate = [datetime]$d.DriverDate } catch { $driverDate = $null }
    $ageFlag = if ($driverDate -and $driverDate -lt $maxAge) { ' [OLD?]' } else { '' }
    $driverLines += "- $($d.DeviceName): $($d.DriverVersion) ($($d.DriverProviderName)) - $($d.DriverDate)$ageFlag"
  }
  Add-Section -Path $reportPath -Title 'Display Drivers' -Lines (Limit-Lines -Lines $driverLines -MaxLines 50)
}

# NVIDIA tooling / CUDA indicators
$nvidiaSmiCandidates = @(
  "nvidia-smi",
  "C:\\Program Files\\NVIDIA Corporation\\NVSMI\\nvidia-smi.exe"
)

$nvidiaSmiFound = $null
foreach ($c in $nvidiaSmiCandidates) {
  try {
    if ($c -eq 'nvidia-smi') {
      $cmd = Get-Command nvidia-smi -ErrorAction Stop
      $nvidiaSmiFound = $cmd.Source
      break
    }
    if (Test-Path -Path $c) {
      $nvidiaSmiFound = $c
      break
    }
  } catch {
    # ignore
  }
}

if ($null -ne $nvidiaSmiFound) {
  $nv = Safe-Get -Label 'nvidia-smi' { & $nvidiaSmiFound 2>&1 }
  Add-Section -Path $reportPath -Title 'NVIDIA (nvidia-smi)' -Lines (Limit-Lines -Lines @($nv) -MaxLines 40)
} else {
  Add-Section -Path $reportPath -Title 'NVIDIA (nvidia-smi)' -Lines @('- nvidia-smi not found (OK if using AMD/Intel GPU)')
}

$cudaRoot = "C:\\Program Files\\NVIDIA GPU Computing Toolkit\\CUDA"
if (Test-Path -Path $cudaRoot) {
  $cudaDirs = Get-ChildItem -Path $cudaRoot -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
  Add-Section -Path $reportPath -Title 'CUDA Toolkit' -Lines @(
    "- CUDA root found: $cudaRoot",
    ("- Versions: {0}" -f ($cudaDirs -join ', '))
  )
} else {
  Add-Section -Path $reportPath -Title 'CUDA Toolkit' -Lines @('- CUDA root not detected')
}

# Recent critical system events (stability)
$start = (Get-Date).AddDays(-7)
$events = Safe-Get -Label 'SystemEvents' {
  Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1,2; StartTime = $start } -ErrorAction Stop |
    Select-Object -First 50 TimeCreated, Id, ProviderName, LevelDisplayName, Message
}

if ($events -is [string]) {
  Add-Section -Path $reportPath -Title 'System Events (Last 7 days, Critical/Error)' -Lines @("- $events")
} else {
  $eventLines = @()
  foreach ($e in @($events)) {
    $msg = ($e.Message -replace "\r\n|\n|\r", ' ')
    if ($msg.Length -gt 240) { $msg = $msg.Substring(0, 240) + '…' }
    $eventLines += ("- {0} [{1}] {2}/{3}: {4}" -f $e.TimeCreated, $e.LevelDisplayName, $e.ProviderName, $e.Id, $msg)
  }
  if ($eventLines.Count -eq 0) {
    $eventLines = @('- No Critical/Error events in System log for the last 7 days (good sign).')
  }
  Add-Section -Path $reportPath -Title 'System Events (Last 7 days, Critical/Error)' -Lines $eventLines
}

Add-Section -Path $reportPath -Title 'Recommendations' -Lines @(
  "- If GPU driver is flagged [OLD?], update from OEM/NVIDIA/AMD/Intel (prefer OEM for laptops).",
  "- For AI/graphics stability: keep BIOS + chipset + GPU drivers aligned; avoid mixing OEM and generic installers unless needed.",
  "- If System events show display driver resets (e.g., nvlddmkm), prioritize GPU driver + thermals.",
  "- Keep at least 15% free disk space on your OS drive for smooth caching and swap."
)

Write-Host "Report created: $reportPath"
