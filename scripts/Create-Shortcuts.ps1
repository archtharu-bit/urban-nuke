$DesktopPath = [Environment]::GetFolderPath("Desktop")
$ProjectPath = "C:\Users\VVIP_44\Downloads\CodebaseProject"
$WshShell = New-Object -ComObject WScript.Shell

# Create shortcuts with emojis in names
$shortcuts = @(
    @{"Name" = "🚀 Start API Server"; "Target" = "$DesktopPath\Start-API-Server.bat"; "Desc" = "Start the Express API server on port 3000"},
    @{"Name" = "⚡ Dev Mode"; "Target" = "$DesktopPath\Dev-Mode.bat"; "Desc" = "Start API and CLI with hot-reload"},
    @{"Name" = "💻 Run CLI"; "Target" = "$DesktopPath\Run-CLI.bat"; "Desc" = "Execute CLI commands"},
    @{"Name" = "✓ Run Tests"; "Target" = "$DesktopPath\Run-Tests.bat"; "Desc" = "Execute the full test suite"},
    @{"Name" = "🏥 Check Health"; "Target" = "$DesktopPath\Check-Health.bat"; "Desc" = "Verify API server is running"},
    @{"Name" = "📝 Open VS Code"; "Target" = "$DesktopPath\Open-Project.bat"; "Desc" = "Open project in Visual Studio Code"},
    @{"Name" = "🎮 Control Center"; "Target" = "$DesktopPath\Control-Center.bat"; "Desc" = "Central control panel for all operations"}
)

foreach ($shortcut in $shortcuts) {
    $ShortcutPath = "$DesktopPath\$($shortcut['Name']).lnk"
    $Link = $WshShell.CreateShortcut($ShortcutPath)
    $Link.TargetPath = $shortcut['Target']
    $Link.WorkingDirectory = $ProjectPath
    $Link.Description = $shortcut['Desc']
    $Link.WindowStyle = 1
    $Link.Save()
    Write-Host "✓ Created: $($shortcut['Name'])"
}

Write-Host "`n✅ All shortcuts created successfully!"
Write-Host "Check your desktop for the new icons."
