# Duplicate Scan

## Run
```powershell
powershell -ExecutionPolicy Bypass -File scripts\duplicate-scan.ps1
```

## Options
- `-Path` directory to scan (default: Downloads)
- `-MinFileSizeBytes` minimum size (default: 1 MB)
- `-MaxTotalBytesToHash` hash budget (default: 10 GB)
- `-Include` filter patterns (optional)

## Notes
This script only reports duplicates; it never deletes files.
