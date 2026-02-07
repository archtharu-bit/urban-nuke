# VS Code Maintenance

This file documents VS Code settings, extensions, and update/scan steps.

## Update Extensions
```powershell
code --update-extensions
```

## Scan (Extensions and Versions)
```powershell
powershell -ExecutionPolicy Bypass -File scripts\vscode-scan.ps1
```

## Notes
- Keep extensions lean; disable unused ones to reduce attack surface.
- Prefer official marketplace extensions.

## Keybindings
Workspace keybindings live in `.vscode/keybindings.json`.
- `Ctrl+Alt+O` runs `Urban Nuke: Report`
