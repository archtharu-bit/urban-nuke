Set-StrictMode -Version Latest

function Ensure-Dir {
  param(
    [Parameter(Mandatory)]
    [string]$Path
  )

  if (-not (Test-Path -Path $Path)) {
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
  }
}

function New-ReportPath {
  param(
    [Parameter(Mandatory)]
    [string]$Prefix,
    [Parameter(Mandatory)]
    [string]$OutDir
  )

  $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  return Join-Path $OutDir ("{0}-{1}.md" -f $Prefix, $timestamp)
}

function Add-ReportHeader {
  param(
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$Title,
    [Parameter()]
    [hashtable]$Meta = @{}
  )

  Add-Content -Path $Path -Value ("# {0}" -f $Title)
  Add-Content -Path $Path -Value ("Generated: {0}" -f (Get-Date))
  foreach ($key in $Meta.Keys) {
    Add-Content -Path $Path -Value ("{0}: {1}" -f $key, $Meta[$key])
  }
}

function Add-Section {
  param(
    [Parameter(Mandatory)]
    [string]$Path,
    [Parameter(Mandatory)]
    [string]$Title,
    [Parameter()]
    [string[]]$Lines = @()
  )

  Add-Content -Path $Path -Value "`n## $Title`n"
  foreach ($line in $Lines) {
    Add-Content -Path $Path -Value $line
  }
}

function Limit-Lines {
  param(
    [Parameter()]
    [string[]]$Lines = @(),
    [Parameter()]
    [int]$MaxLines = 80
  )

  if ($Lines.Count -le $MaxLines) {
    return $Lines
  }

  $head = $Lines[0..($MaxLines - 1)]
  return @(
    $head + "... (truncated, showing first $MaxLines lines of $($Lines.Count))"
  )
}

function Safe-Get {
  param(
    [Parameter(Mandatory)]
    [string]$Label,
    [Parameter(Mandatory)]
    [scriptblock]$Block
  )

  try {
    return & $Block
  } catch {
    return "[Unavailable] ${Label}: $($_.Exception.Message)"
  }
}

function Invoke-External {
  param(
    [Parameter(Mandatory)]
    [string]$FilePath,
    [Parameter()]
    [string[]]$Arguments = @()
  )

  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $FilePath
  $psi.Arguments = ($Arguments -join ' ')
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError = $true
  $psi.UseShellExecute = $false
  $psi.CreateNoWindow = $true

  $proc = New-Object System.Diagnostics.Process
  $proc.StartInfo = $psi
  $null = $proc.Start()
  $stdout = $proc.StandardOutput.ReadToEnd()
  $stderr = $proc.StandardError.ReadToEnd()
  $proc.WaitForExit()

  return [pscustomobject]@{
    ExitCode = $proc.ExitCode
    Stdout = $stdout
    Stderr = $stderr
  }
}
