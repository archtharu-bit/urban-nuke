# Cline (Autonomous Agent) Setup & Safe Defaults

This repo is intentionally **operations-focused** (PowerShell scripts that inspect or change parts of your Windows system). When using **Cline** (extension: `saoudrizwan.claude-dev`), prefer *read-only* and *report-only* workflows unless you explicitly choose to apply changes.

## What’s configured in this repo

### 1) `.clineignore`
This repo includes a `.clineignore` to keep Cline from reading/editing:
- `reports/` (generated outputs)
- `.env` (secrets)
- `.git/`, `.vscode/`, `.devcontainer/` (tooling state)
- common caches and large binaries

If you want Cline to propose changes to `.vscode/` tasks/settings, temporarily remove `.vscode/` from `.clineignore`.

### 2) VS Code excludes for `reports/`
Workspace settings exclude `reports/` from explorer/search/watchers to reduce noise and improve performance.

## Recommended Cline extension settings (manual)

These are **not committed** (they live in your local VS Code user settings):

- Disable / avoid “auto-approve” for commands and file writes.
- Prefer “Ask before running commands”.
- Keep model context windows moderate (this repo has lots of docs).

## Safe workflow for this repo

1. **Start with read-only**: ask Cline to inspect scripts/docs first.
2. **Make atomic edits**: one script/doc at a time.
3. **Never run destructive scripts implicitly**:
   - `scripts/cleanup-scan.ps1` is designed to be safe by default, but still review options.
   - avoid “apply”, “remove”, “delete”, “uninstall” style commands unless you requested them.
4. **Prefer generating reports** (writes only to `reports/`, which is git-ignored).

## Prompt template (copy/paste)

**Goal:**
**Scope:** (docs/scripts only? which files?)
**Constraints:** (no destructive ops, no network, no touching `.env`, do not read `reports/`)
**Output:** (patch, checklist, or command to run)

## Common Cline tasks here

- Add a new scan script in `scripts/` that only collects info and writes a markdown report.
- Refactor scripts to share helpers from `scripts/_lib.ps1`.
- Update `docs/` to match the current scripts and tasks.
