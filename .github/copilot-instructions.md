# Copilot Instructions

## Project Context
- Repo is a Windows PowerShell toolkit for audits and system reports.
- Main scripts live in `scripts/`; docs in `docs/`.
- Generated output lives in `reports/` and must not be edited.

## Coding Rules
- Follow existing style and structure.
- Prefer small, reviewable changes.
- Add brief comments only where logic is non-obvious.
- Do not add new dependencies without asking.

## Safety
- Do not include secrets or system-identifying data.
- Never modify `.env` or `reports/`.
- Avoid destructive commands unless explicitly requested.
