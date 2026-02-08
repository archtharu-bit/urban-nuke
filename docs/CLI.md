# CLI Usage

The CLI is a PowerShell script that produces system and security reports.

## Commands
- `report` - General system baseline report.
- `security` - Security-focused report with Defender and firewall status.
- `hardware` - Hardware inventory report.
- `network` - Network adapter and profile status.

## Additional Scripts
- `scripts/stability-scan.ps1` - AI/graphics readiness + stability signals (GPU driver evidence, recent system errors, disk free, etc.).
- `scripts/windows-update-scan.ps1` - Pending Windows Updates + recent update history (scan only).
- `scripts/defender-scan.ps1` - Defender status and optional scans (opt-in).
- `scripts/cleanup-scan.ps1` - Temp/startup scan and optional cleanup (opt-in).
- `scripts/duplicate-scan.ps1` - Duplicate file detection (hash-based; never deletes).

## Examples
```powershell
powershell -ExecutionPolicy Bypass -File scripts\\run-all.ps1
# output: reports\\latest-collection.md (one file)

powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 security
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 hardware

powershell -ExecutionPolicy Bypass -File scripts\\stability-scan.ps1
powershell -ExecutionPolicy Bypass -File scripts\\windows-update-scan.ps1
powershell -ExecutionPolicy Bypass -File scripts\\defender-scan.ps1
powershell -ExecutionPolicy Bypass -File scripts\\defender-scan.ps1 -QuickScan
powershell -ExecutionPolicy Bypass -File scripts\\cleanup-scan.ps1
powershell -ExecutionPolicy Bypass -File scripts\\cleanup-scan.ps1 -CleanTemp -EmptyRecycleBin
powershell -ExecutionPolicy Bypass -File scripts\\duplicate-scan.ps1 -Path "$env:USERPROFILE\\Downloads"
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 network

powershell -ExecutionPolicy Bypass -File scripts\\reports-prune.ps1 -KeepPerPrefix 3
powershell -ExecutionPolicy Bypass -File scripts\\reports-prune.ps1 -KeepPerPrefix 3 -Apply

powershell -ExecutionPolicy Bypass -File scripts\\analyze-collection.ps1 -WriteSummaryFile
powershell -ExecutionPolicy Bypass -File scripts\\self-test.ps1
```

## Output
- Reports are saved to `reports\` as Markdown.
- Each run includes a timestamp.

## Notes
If a command requires admin permissions, the report will note missing sections instead of failing.

## VS Code Tasks
You can also run the reports via VS Code Tasks:
- `Urban Nuke: Report`
- `Urban Nuke: Security Report`
- `Urban Nuke: Hardware Report`
- `Urban Nuke: Network Report`
- `VS Code: Scan Extensions`
- `Urban Nuke: Run All`
- `AWS CLI: Check`
- `Red Hat Java: Check`
- `Local Tools: Check`
- `SSH: Setup`
- `Security: Baseline`
- `Cleanup: Scan`
- `Defender: Scan`
- `Duplicates: Scan`
- `Stability: Scan`
- `Windows Update: Scan`
