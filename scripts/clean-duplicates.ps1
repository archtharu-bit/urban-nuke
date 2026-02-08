param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== AGGRESSIVE DUPLICATE CLEANER ===" -ForegroundColor Cyan

$scanPaths = @(
  "$env:USERPROFILE\Downloads",
  "$env:USERPROFILE\Documents", 
  "$env:USERPROFILE\Desktop",
  "$env:USERPROFILE\Pictures",
  "$env:USERPROFILE\Videos",
  "$env:USERPROFILE\Music",
  "C:\Temp",
  "$env:USERPROFILE\AppData\Local\Temp"
)

function Get-FileHash256 {
  param($Path)
  try {
    return (Get-FileHash -Path $Path -Algorithm SHA256 -ErrorAction Stop).Hash
  } catch {
    return $null
  }
}

$allFiles = @()
$totalSize = 0
$dupeCount = 0

Write-Host "`nScanning for duplicates..." -ForegroundColor Yellow

foreach ($path in $scanPaths) {
  if (Test-Path $path) {
    Write-Host "  Scanning: $path"
    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Length -gt 1KB }
    $allFiles += $files
  }
}

Write-Host "`nFound $($allFiles.Count) files, calculating hashes..." -ForegroundColor Yellow

$hashGroups = $allFiles | Group-Object -Property Length | Where-Object { $_.Count -gt 1 }

foreach ($group in $hashGroups) {
  $files = $group.Group
  $hashes = @{}
  
  foreach ($file in $files) {
    $hash = Get-FileHash256 -Path $file.FullName
    if ($hash) {
      if ($hashes.ContainsKey($hash)) {
        $hashes[$hash] += @($file)
      } else {
        $hashes[$hash] = @($file)
      }
    }
  }
  
  foreach ($hash in $hashes.Keys) {
    $dupes = $hashes[$hash]
    if ($dupes.Count -gt 1) {
      $keep = $dupes | Sort-Object LastWriteTime -Descending | Select-Object -First 1
      $remove = $dupes | Where-Object { $_.FullName -ne $keep.FullName }
      
      foreach ($file in $remove) {
        $dupeCount++
        $size = $file.Length / 1MB
        $totalSize += $size
        
        Write-Host "`n[DUPLICATE $dupeCount]" -ForegroundColor Red
        Write-Host "  Keep:   $($keep.FullName)" -ForegroundColor Green
        Write-Host "  Remove: $($file.FullName) [$([math]::Round($size, 2)) MB]" -ForegroundColor Red
        
        if ($Apply) {
          try {
            Remove-Item -Path $file.FullName -Force -ErrorAction Stop
            Write-Host "  DELETED" -ForegroundColor Yellow
          } catch {
            Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
          }
        }
      }
    }
  }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Duplicates found: $dupeCount" -ForegroundColor Yellow
Write-Host "Space to free: $([math]::Round($totalSize, 2)) MB" -ForegroundColor Yellow

if (-not $Apply) {
  Write-Host "`nRun with -Apply to delete duplicates" -ForegroundColor Red
} else {
  Write-Host "`nDuplicates cleaned!" -ForegroundColor Green
}
