# Security Baseline

This script applies light security controls when possible.

## Run
```powershell
powershell -ExecutionPolicy Bypass -File scripts\security-baseline.ps1
```

## What It Does
- Ensures Windows Firewall is enabled
- Ensures Defender real-time protection is enabled
- Enables PUA protection (if supported)

## Notes
Some settings require Administrator privileges.
