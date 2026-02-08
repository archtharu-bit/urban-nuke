param([switch]$Apply)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Continue'

Write-Host "=== ORGANIZE ENTIRE LAPTOP ===" -ForegroundColor Cyan

$locations = @{
  "Downloads" = @{
    Path = "$env:USERPROFILE\Downloads"
    Rules = @{
      "Documents" = @("*.pdf", "*.doc", "*.docx", "*.txt", "*.xlsx", "*.pptx")
      "Images" = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.svg")
      "Videos" = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv")
      "Music" = @("*.mp3", "*.wav", "*.flac", "*.m4a")
      "Archives" = @("*.zip", "*.rar", "*.7z", "*.tar", "*.gz")
      "Installers" = @("*.exe", "*.msi")
      "Code" = @("*.py", "*.js", "*.html", "*.css", "*.json")
    }
  }
  "Desktop" = @{
    Path = "$env:USERPROFILE\Desktop"
    Rules = @{
      "Shortcuts" = @("*.lnk")
    }
  }
  "Documents" = @{
    Path = "$env:USERPROFILE\Documents"
    Rules = @{}
  }
}

$stats = @{
  Moved = 0
  Skipped = 0
  Errors = 0
}

function Organize-Folder {
  param($BasePath, $Rules)
  
  foreach ($category in $Rules.Keys) {
    $targetFolder = Join-Path $BasePath $category
    
    if (-not (Test-Path $targetFolder)) {
      if ($Apply) {
        New-Item -Path $targetFolder -ItemType Directory -Force | Out-Null
      }
    }
    
    foreach ($pattern in $Rules[$category]) {
      $files = Get-ChildItem -Path $BasePath -Filter $pattern -File -ErrorAction SilentlyContinue |
        Where-Object { $_.DirectoryName -eq $BasePath }
      
      foreach ($file in $files) {
        Write-Host "[MOVE] $($file.Name) -> $category\" -ForegroundColor Yellow
        
        if ($Apply) {
          try {
            Move-Item -Path $file.FullName -Destination $targetFolder -Force
            $stats.Moved++
          } catch {
            Write-Host "  ERROR: $($_.Exception.Message)" -ForegroundColor Red
            $stats.Errors++
          }
        }
      }
    }
  }
}

# Clean temp files
Write-Host "`n[CLEAN TEMP]" -ForegroundColor Green
$tempPaths = @("$env:TEMP", "$env:WINDIR\Temp")
$tempSize = 0

foreach ($path in $tempPaths) {
  if (Test-Path $path) {
    $size = (Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | 
      Measure-Object -Property Length -Sum).Sum / 1GB
    $tempSize += $size
    
    if ($Apply) {
      Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue |
        Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    }
  }
}
Write-Host "  Temp files: $([math]::Round($tempSize, 2)) GB" -ForegroundColor Gray

# Organize each location
foreach ($location in $locations.Keys) {
  Write-Host "`n[$location]" -ForegroundColor Green
  $config = $locations[$location]
  
  if (Test-Path $config.Path) {
    Organize-Folder -BasePath $config.Path -Rules $config.Rules
  }
}

# Clean recycle bin
Write-Host "`n[RECYCLE BIN]" -ForegroundColor Green
if ($Apply) {
  Clear-RecycleBin -Force -ErrorAction SilentlyContinue
  Write-Host "  Emptied" -ForegroundColor Gray
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Files moved: $($stats.Moved)" -ForegroundColor Yellow
Write-Host "Temp cleaned: $([math]::Round($tempSize, 2)) GB" -ForegroundColor Yellow
Write-Host "Errors: $($stats.Errors)" -ForegroundColor $(if($stats.Errors -gt 0){'Red'}else{'Green'})

if (-not $Apply) {
  Write-Host "`nRun with -Apply to organize laptop" -ForegroundColor Red
  Write-Host "  powershell -ExecutionPolicy Bypass -File scripts\organize-laptop.ps1 -Apply" -ForegroundColor White
} else {
  Write-Host "`nLaptop organized!" -ForegroundColor Green
}
