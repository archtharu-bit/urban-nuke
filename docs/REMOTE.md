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
After install, ensure the Docker Desktop service is running (requires admin):
```
Start-Service com.docker.service
```
After install, open VS Code and run:
- `Dev Containers: Add Dev Container Configuration Files`
- `Dev Containers: Reopen in Container`

### Dev Containers Tips (Docker Desktop on Windows)
- Prefer Docker Desktop's WSL 2 back-end on Windows 10 (2004+). It shares containers between Windows and WSL and is less susceptible to file sharing issues.
- Ensure you are using Linux containers. The Dev Containers extension supports Linux containers only; switch by right-clicking the Docker taskbar item and selecting `Switch to Linux Containers...`.
- Make sure your firewall allows Docker to set up a shared drive.

### File Sharing (Docker Desktop)
The Dev Containers extension can only mount your source code if the folder/drive is shared with Docker. If you open a dev container from a non-shared location, the container starts but the workspace is empty. This step is not required with Docker Desktop's WSL 2 engine.
Windows steps:
1. Right-click the Docker taskbar item and select `Settings`.
2. Go to `Resources` > `File Sharing` and check the drive(s) where your source code is located.
3. If your firewall blocks the sharing action, follow Docker's KB article.

### Copilot Instructions in Dev Containers
You can provide environment-specific guidance to Copilot for your dev container:
- Add `github.copilot.chat.codeGeneration.instructions` directly in `devcontainer.json`.
- Or use `copilot-instructions.md` as you would locally.

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
