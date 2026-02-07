# Project Status

Use this checklist to keep the project structured and verified.

## Structure
- `.devcontainer/` present
- `docs/` present
- `scripts/` present
- `reports/` ignored in `.gitignore`

## Remote Setup
- WSL installed and reachable
- Docker Desktop installed (for Dev Containers)
- SSH hosts configured in `%USERPROFILE%\.ssh\config`
- GitHub/Microsoft sign-in for Codespaces and Tunnels

## Verification
Run:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\health-check.ps1
```
