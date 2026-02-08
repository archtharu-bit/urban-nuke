=========================================
  MODERN APP - Desktop Shortcuts
=========================================

Click on any .bat file to run it:

1. Start-API-Server.bat
   - Runs: npm start
   - Starts the Express API server on port 3000
   - Location: http://localhost:3000

2. Dev-Mode.bat
   - Runs: npm run dev
   - Starts API + CLI with hot-reload
   - Best for development/testing

3. Run-CLI.bat
   - Runs: node dist/cli/index.js
   - Execute CLI commands
   - You can pass arguments like: Run-CLI.bat --help

4. Run-Tests.bat
   - Runs: npm test -- --run
   - Executes the full test suite

5. Check-Health.bat
   - Tests API server connectivity
   - Confirms server is running

6. Open-Project.bat
   - Opens the project in VS Code
   - For code editing

PROJECT LOCATION:
C:\Users\VVIP_44\Downloads\CodebaseProject

QUICK START:
1. Double-click "Dev-Mode.bat" to start
2. Wait for terminals to open (~5 seconds)
3. API will be available at http://localhost:3000
4. CLI ready to use in the second terminal

BUILD INFO:
- TypeScript compiled ✓
- CLI bundled with esbuild ✓
- Ready to deploy ✓

API Endpoints: See .github/copilot-instructions.md
CLI Commands: See src/cli/index.ts
