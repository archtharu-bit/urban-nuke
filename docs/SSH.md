# SSH Setup

## Quick Setup
```powershell
powershell -ExecutionPolicy Bypass -File scripts\ssh-setup.ps1
```

## VS Code $EDITOR Integration
When connected through VS Code Remote SSH, set $EDITOR so terminal commands (like `git commit`) open VS Code.

PowerShell (Windows):
```powershell
if ($env:VSCODE_INJECTION -eq "1") {
    $env:EDITOR = "code --wait"  # or 'code-insiders'
}
```

macOS / Linux (bash/zsh):
```bash
if [ "$VSCODE_INJECTION" = "1" ]; then
    export EDITOR="code --wait" # or 'code-insiders'
fi
```

## Key-based Authentication Quick Start
- SSH public key authentication uses a local private key and a public key registered on the SSH host.
- Check for an existing key at `~/.ssh/id_ed25519.pub` (macOS/Linux) or `C:\Users\your-user\.ssh\id_ed25519.pub` on Windows.
- If missing, create a key pair and add the public key to the host’s `authorized_keys`.
