# Urban Nuke

A personal laptop operations project for upgrades, performance tuning, security hardening, and a CLI audit toolkit. This repo is designed to document what changed on your machine and to generate repeatable, verifiable reports.

## Goals
- Track upgrades and configuration changes in one place.
- Produce repeatable system/security reports you can share (with sensitive data removed).
- Reduce attack surface and harden the system against malware and opportunistic targeting.
- Keep a clear, auditable baseline before and after changes.

## Quick Start (Windows PowerShell)
```powershell
# Create a baseline report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 report

# Create a security-focused report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 security
```
Reports are written to `reports\`.

## Repo Layout
- `docs/UPGRADES.md` - Track hardware and major software upgrades.
- `docs/OPTIMIZATION.md` - Performance tuning checklist and decisions.
- `docs/SECURITY.md` - Hardening guidance and threat model.
- `docs/AI.md` - Safe AI usage policy and prompt template.
- `docs/CLI.md` - CLI usage and report formats.
- `scripts/urban-nuke.ps1` - Report generator and basic security checks.
- `reports/` - Generated reports (ignored by git).

## Security Reality Check
No system can be made perfectly safe. The goal here is to reduce attack surface, keep software patched, and detect issues early. The included guidance is defensive and reversible.

## Next Steps
1. Run a baseline report and keep it.
2. Fill in `docs/UPGRADES.md` with your current hardware.
3. Apply hardening steps gradually and re-run reports after each change.

## License
Private use unless you decide otherwise.
