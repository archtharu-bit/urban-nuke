# Remote Development Setup

This guide completes Remote Explorer options in VS Code.

## Why the Menu Looks the Same
Remote Explorer always shows the same base menu. It changes only when:
- You add SSH hosts (they appear under "SSH Targets")
- Docker is installed (Dev Containers can actually run)
- You sign in (Codespaces and Tunnels show available items)

## 1) WSL
WSL is installed. Use:
- Command Palette: `Remote-WSL: New Window`
- Or `Remote Explorer` -> Connect to WSL

## 2) SSH Hosts (Remote Explorer)
Remote SSH needs host entries. Create or edit:
`%USERPROFILE%\.ssh\config`

Template:
```
Host my-server
  HostName 192.168.1.10
  User your-user
  IdentityFile C:\Users\VVIP_44\.ssh\id_ed25519
```

## 3) Dev Containers
Requires Docker Desktop. Install:
```
winget install -e --id Docker.DockerDesktop
```
After install, open VS Code and run:
- `Dev Containers: Add Dev Container Configuration Files`
- `Dev Containers: Reopen in Container`

## 4) Tunnels
Requires sign-in to Microsoft/GitHub.
- Command Palette: `Remote Tunnels: Turn on`

## 5) GitHub Codespaces
Requires GitHub sign-in in VS Code.
- Command Palette: `Codespaces: Create New Codespace`

## 6) Remote Repository
- Command Palette: `Remote Repositories: Open Repository`

## Checklist
- Install Docker Desktop
- Create SSH config host entries
- Sign in to GitHub + Microsoft accounts in VS Code
- Run the commands above from the Command Palette

## Reports
Run a readiness scan:
```
powershell -ExecutionPolicy Bypass -File scripts\remote-check.ps1
```
