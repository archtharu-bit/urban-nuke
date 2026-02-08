# Defender Scan

## Run
```powershell
powershell -ExecutionPolicy Bypass -File scripts\defender-scan.ps1
```

## Options
- `-QuickScan` start a quick scan
- `-FullScan` start a full scan
- `-OfflineScan` schedule an offline scan

## Notes
Full or offline scans may take time and require a reboot.
