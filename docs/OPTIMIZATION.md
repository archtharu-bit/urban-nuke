# Optimization Checklist

These items focus on performance and stability. Apply gradually and re-check with reports.

## Baseline
- Capture a baseline report: `scripts/urban-nuke.ps1 report`.
- Record boot time and idle CPU/RAM in this file.

## Windows Performance
- Disable unneeded startup apps.
- Keep storage at least 15 percent free.
- Use Balanced or High Performance power plan depending on battery vs speed.
- Update GPU and chipset drivers from the OEM.
- Keep Windows Update current.

## Storage Health
- Verify SSD health and firmware.
- TRIM enabled on SSDs.
- Avoid constant full-disk usage; keep workspace partitioned if needed.

## Thermal Stability
- Check fan behavior and clean vents.
- Use a cooling pad for long sessions if needed.
- Monitor sustained temps under load.

## Network Stability
- Update Wi-Fi drivers.
- Disable unused adapters.
- Prefer 5 GHz or wired connection for stability.

## Notes
- Changes applied:
- 2026-02-08: Baseline report created (`reports/report-20260208-101747.md`).
- 2026-02-08: Windows Update scan report created (`reports/windows-update-scan-20260208-101815.md`).
- 2026-02-08: Stability scan report created (`reports/stability-scan-20260208-101901.md`).
- 2026-02-08: Verified TRIM enabled (NTFS/ReFS DisableDeleteNotify = 0).
- 2026-02-08: Verified active power plan: Ultimate Performance.
- 2026-02-08: Verified SSD health: Healthy/OK.
- 2026-02-08: Startup apps inventoried (see latest self-test report).
- Measured improvements:
- Pending (no tuning changes applied yet).
- Rollback plan:
- Re-enable any disabled startup apps in Task Manager > Startup Apps.
- Revert power plan using `powercfg /setactive <GUID>`.
