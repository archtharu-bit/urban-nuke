# Architecture

## Design Goals
- Report-only by default
- Clear, auditable outputs
- Minimal dependencies (built-in PowerShell cmdlets)

## Data Flow
1. A script runs a scan (e.g., `windows-update-scan.ps1`).
2. Output is written to `reports/` as Markdown.
3. `run-all.ps1` aggregates report sources into `latest-collection.md`.
4. `analyze-collection.ps1` generates a short actionable summary.

## Safety Boundaries
- Scripts avoid destructive actions unless explicit flags are provided.
- Cleanup or configuration changes are isolated and documented.

## Conventions
- Reports are Markdown for easy viewing and sharing.
- Each report includes a header with metadata and timestamps.
- Scripts prefer deterministic output and clear labeling.
