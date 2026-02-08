# SSH Setup

## Quick Setup
```powershell
powershell -ExecutionPolicy Bypass -File scripts\ssh-setup.ps1
```

## Notes
- Creates an ed25519 keypair if missing.
- Adds public key to `authorized_keys`.
- Adds a `Host local` entry for localhost.
- Reports whether OpenSSH Server is installed and running.
