Set objFSO = CreateObject("Scripting.FileSystemObject")
Set objShell = CreateObject("WScript.Shell")

' Define paths
desktopPath = objShell.SpecialFolders("Desktop")
projectPath = "C:\Users\VVIP_44\Downloads\CodebaseProject"

' Create shortcut for API Server
CreateShortcut desktopPath & "\🚀 Start API Server.lnk", _
    desktopPath & "\Start-API-Server.bat", _
    projectPath, _
    "Start the Express API server on port 3000"

' Create shortcut for Dev Mode
CreateShortcut desktopPath & "\⚡ Dev Mode (Hot-reload).lnk", _
    desktopPath & "\Dev-Mode.bat", _
    projectPath, _
    "Start API and CLI with hot-reload for development"

' Create shortcut for CLI
CreateShortcut desktopPath & "\💻 Run CLI.lnk", _
    desktopPath & "\Run-CLI.bat", _
    projectPath, _
    "Execute CLI commands"

' Create shortcut for Tests
CreateShortcut desktopPath & "\✓ Run Tests.lnk", _
    desktopPath & "\Run-Tests.bat", _
    projectPath, _
    "Execute the full test suite"

' Create shortcut for Health Check
CreateShortcut desktopPath & "\🏥 Check Health.lnk", _
    desktopPath & "\Check-Health.bat", _
    projectPath, _
    "Verify API server is running"

' Create shortcut for VS Code
CreateShortcut desktopPath & "\📝 Open in VS Code.lnk", _
    desktopPath & "\Open-Project.bat", _
    projectPath, _
    "Open project in Visual Studio Code"

' Create shortcut for Control Center
CreateShortcut desktopPath & "\🎮 Control Center.lnk", _
    desktopPath & "\Control-Center.bat", _
    projectPath, _
    "Central control panel for all app operations"

WScript.Echo "Shortcuts created successfully!"

Sub CreateShortcut(shortcutPath, targetPath, workingDir, description)
    Set objLinkFile = objShell.CreateShortCut(shortcutPath)
    objLinkFile.TargetPath = targetPath
    objLinkFile.WorkingDirectory = workingDir
    objLinkFile.Description = description
    objLinkFile.WindowStyle = 1
    objLinkFile.Save
End Sub
