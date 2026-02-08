# CLI Usage

The CLI is a PowerShell script that produces system and security reports.

## Commands
- `report` - General system baseline report.
- `security` - Security-focused report with Defender and firewall status.
- `hardware` - Hardware inventory report.
- `network` - Network adapter and profile status.

## Examples
```powershell
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 security
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 hardware
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 network
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
