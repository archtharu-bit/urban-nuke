# Urban Nuke

A Windows PowerShell operations toolkit for upgrades, performance tuning, security hardening, and repeatable audit reports. The goal is to keep a clear baseline, document changes, and produce verifiable reports you can share (with sensitive data removed).

## Why This Project
- Build a reliable baseline before and after changes
- Catch drift in security and system health early
- Make upgrades and maintenance traceable and reversible
- Turn messy system tasks into clean, repeatable workflows

## Quick Start (Windows PowerShell)
```powershell
# Create a baseline report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 report

# Create a security-focused report
powershell -ExecutionPolicy Bypass -File scripts\urban-nuke.ps1 security
```
Reports are written to `reports\`.

## Core Workflow
Generate a single combined report file (overwrites each run):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\run-all.ps1
# output: reports\latest-collection.md
```
Generate a short actionable summary:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\analyze-collection.ps1 -WriteSummaryFile
# output: reports\latest-summary.md
```
Prune old duplicates (dry-run by default):
```powershell
powershell -ExecutionPolicy Bypass -File scripts\reports-prune.ps1 -KeepPerPrefix 2
# then actually delete:
powershell -ExecutionPolicy Bypass -File scripts\reports-prune.ps1 -KeepPerPrefix 2 -Apply
```

## Features
- Report-only defaults for safe execution
- Modular scans for security, stability, Windows Update, and cleanup
- Single-file report collection and summary generation
- Self-test that validates scripts, environment, and report freshness
- Clear documentation and repeatable checklists

## Safety Model
- Report-only by default: no deletions or system changes unless you opt in
- Destructive actions require explicit flags (e.g., `-Apply`, `-CleanTemp`)
- Designed to be reversible with documentation of applied changes

## Reports
Common report types:
- `report-*.md`: baseline system report
- `security-*.md`: security-oriented baseline
- `stability-scan-*.md`: stability + readiness checks
- `windows-update-scan-*.md`: update status
- `cleanup-scan-*.md`: temp usage and optional cleanup

## Scripts (Key)
- `scripts/urban-nuke.ps1`: report generator and basic security checks
- `scripts/run-all.ps1`: generate a single combined report
- `scripts/analyze-collection.ps1`: produce a short actionable summary
- `scripts/self-test.ps1`: environment + script sanity checks
- `scripts/apply-now.ps1`: opt-in configuration changes
- `scripts/windows-update-scan.ps1`: update status
- `scripts/cleanup-scan.ps1`: temp cleanup (opt-in)
- `scripts/duplicate-scan.ps1`: duplicate detection (report-only)

## Repo Layout
- `AGENTS.md` - VS Code AI customization (instructions, prompts, agents, skills)
- `docs/ARCHITECTURE.md` - How reports and scripts fit together
- `docs/ROADMAP.md` - Planned improvements
- `docs/SESSION_SUMMARY.md` - Full log of recent updates
- `docs/UPGRADES.md` - Track hardware and major software upgrades
- `docs/OPTIMIZATION.md` - Performance tuning checklist and decisions
- `docs/SECURITY.md` - Hardening guidance and threat model
- `docs/AI.md` - Safe AI usage policy and prompt template
- `docs/CLINE.md` - Cline setup and safe defaults
- `docs/CLI.md` - CLI usage and report formats
- `docs/VSCODE.md` - VS Code update and scan guidance
- `docs/MYSQL.md` - MySQL performance tuning guide
- `docs/REMOTE.md` - Remote Explorer setup for WSL/SSH/Containers/Tunnels
- `docs/INDEX.md` - Repo structure overview
- `docs/AWS.md` - AWS CLI setup and verification
- `docs/REDHAT.md` - Red Hat Java extension setup
- `docs/LOCAL.md` - Local tooling checks
- `docs/STATUS.md` - Project status checklist and verification
- `docs/REMOTE-STATUS.md` - Current remote setup status
- `docs/SSH.md` - SSH setup and local host configuration
- `docs/CURSOR.md` - Cursor install and configuration
- `docs/SECURITY-BASELINE.md` - Lightweight security baseline script
- `docs/CLEANUP.md` - Cleanup scan and safe temp options
- `docs/DEFENDER.md` - Defender scan options
- `docs/DUPLICATES.md` - Duplicate file scan usage
- `docs/STABILITY.md` - Stability and driver scan
- `docs/WINDOWS-UPDATE.md` - Windows Update scan
- `scripts/` - PowerShell scripts
- `reports/` - Generated reports (ignored by git)
- `src/` - Reserved for future app code

## Next Steps
1. Run a baseline report and keep it.
2. Fill in `docs/UPGRADES.md` with your current hardware.
3. Apply hardening steps gradually and re-run reports after each change.

## License
Private use unless you decide otherwise.
