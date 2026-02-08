# Cleanup Scan

## Run
```powershell
powershell -ExecutionPolicy Bypass -File scripts\cleanup-scan.ps1
```

## Options
- `-CleanTemp` removes contents of temp folders
- `-EmptyRecycleBin` clears recycle bin

## Notes
This script is safe by default and only deletes when explicitly requested.
