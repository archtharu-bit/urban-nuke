# AI Agents & Models - Quick Start Guide

## 🚀 One-Command Installation

### Windows (PowerShell)
Copy and paste this entire block:
```powershell
code --install-extension GitHub.copilot
code --install-extension GitHub.copilot-chat
code --install-extension Anthropic.claude-3
code --install-extension saoudrizwan.claude-dev
code --install-extension Continue.continue
code --install-extension Codeium.windsurf
code --install-extension AWS.codewhisperer
code --install-extension TabNine.tabnine-vscode
code --install-extension supermaven.supermaven
```

### macOS/Linux (Bash)
```bash
for ext in GitHub.copilot GitHub.copilot-chat Anthropic.claude-3 saoudrizwan.claude-dev Continue.continue Codeium.windsurf AWS.codewhisperer TabNine.tabnine-vscode supermaven.supermaven; do
  code --install-extension $ext
done
```

---

## 📊 Quick Model Selector

### "What AI should I use right now?"

**I need to code FAST** ➜ **Supermaven** or **Windsurf**
- Instant suggestions, minimal setup
- Free tier available
- Best for flow state

**I need SMART suggestions** ➜ **Claude 3 Sonnet** or **Copilot**
- Better reasoning, good balance
- Works with Continue
- Include context for best results

**I need the BEST reasoning** ➜ **Claude 3 Opus** or **GPT-4**
- Complex problems, architecture decisions
- Slower but higher quality
- Use for critical code

**I need AUTONOMOUS workflows** ➜ **Cline**
- Multi-file refactoring
- Project scaffolding
- Can run commands automatically

**I need LOCAL/PRIVATE** ➜ **Ollama** (Mistral/Code Llama)
- Zero cloud transmission
- No API keys needed
- Full data privacy

**I'm using AWS** ➜ **CodeWhisperer**
- AWS-specific code generation
- Free tier for developers
- Security scanning built-in

**I need ENTERPRISE features** ➜ **Tabnine Enterprise**
- SOC2, HIPAA compliant
- Team learning
- Advanced policy controls

---

## ⚙️ Model Quick Reference

| Model | Speed | Cost | Privacy | Best For |
|-------|-------|------|---------|----------|
| **Supermaven** | Fastest | Free | Good | Flow coding |
| **Windsurf** | Very Fast | Free | Good | Rapid dev |
| **Copilot** | Very Fast | $20/mo | Fair | Inline suggestions |
| **Claude Haiku** | Fast | $0.25/M | Good | Quick fixes |
| **Claude Sonnet** | Fast | $3/M | Good | General use |
| **Claude Opus** | Medium | $15/M | Good | Complex tasks |
| **GPT-4** | Medium | $0.03/1K | Fair | Advanced reasoning |
| **Code Llama** | Medium | Free | Excellent | Local private |
| **Mistral** | Fast | Free | Excellent | Local private |
| **CodeWhisperer** | Fast | $19/mo | Fair | AWS projects |
| **Tabnine** | Fast | $20/mo | Excellent | Enterprise |
| **Cline** | Medium | Free | Good | Autonomous tasks |

---

## 🎯 Popular Combinations

### Lean Setup ($0/month)
```
Copilot (free) + Ollama (Mistral local)
Best for: Cost-conscious, privacy-first
```

### Productive Setup ($30/month)
```
Copilot + Claude Sonnet (via Continue)
Best for: Individuals, general development
```

### Professional Setup ($60+/month)
```
Copilot + Claude Opus + GPT-4 API + CodeWhisperer
Best for: Studios, critical projects, AWS
```

### Enterprise Setup ($100+/month)
```
Tabnine Enterprise + CodeWhisperer + Claude Pro + Cline
Best for: Teams, compliance, scalability
```

---

## 🎮 Day 1 Setup (30 minutes)

### Step 1: Core AI (5 min)
```powershell
code --install-extension GitHub.copilot
code --install-extension Anthropic.claude-3
code --install-extension Continue.continue
```
✅ Restart VS Code

### Step 2: Fast Suggestions (5 min)
```powershell
code --install-extension supermaven.supermaven
code --install-extension Codeium.windsurf
```
✅ Both have free tiers, no config needed

### Step 3: Automation (5 min)
```powershell
code --install-extension saoudrizwan.claude-dev
```
✅ Great for project scaffolding

### Step 4: Auth Setup (15 min)
1. **GitHub Copilot**: VS Code prompts automatically
2. **Claude**: Create API key at https://console.anthropic.com
3. **Continue**: Add API keys in extension settings
4. **Windsurf** & **Supermaven**: Automatic (they handle auth)

---

## 💡 Pro Tips

### Save Money
- Use **free tiers first** (Copilot free tier limit: 60/hr)
- Use **Code Llama via Ollama** for local coding (free)
- Use **Claude Haiku** for simple tasks (cheapest)
- Batch expensive API calls

### Max Speed
- Use **Supermaven** or **Windsurf** for inline (0-100ms)
- Use **local Ollama** to avoid network lat ency
- Keep context small for faster responses
- Pre-select model instead of using defaults

### Best Quality
- Use **Claude 3 Opus** for reasoning
- Add code context to prompts
- Break complex problems into steps
- Ask for explanations, not just code

### Stay Private
- Use **Ollama** with no internet required
- Use **Tabnine** privacy mode
- Use **Continue** with local models
- Never paste secrets in prompts

### Avoid Costs
- Don't use GPT-4 for everything (expensive)
- Use Copilot for suggestions (included)
- Cache prompts when possible
- Monitor API usage weekly

---

## 🔗 Keyboard Shortcuts

### GitHub Copilot
- `Ctrl+I` → Inline code suggestion
- `Ctrl+K Ctrl+/` → Open copilot chat
- `Tab` → Accept suggestion
- `Esc` → Reject suggestion

### Continue
- `Ctrl+Shift+C` → Open command palette
- `/cmd` → Slash commands in chat
- `@context` → Add file context
- `Cmd+Shift+Space` (Mac) → Inline complete

### Windsurf/Supermaven
- `Tab` → Accept suggestion
- `Esc` → Reject suggestion
- Editor preference in file settings

---

## 🆘 Troubleshooting

| Issue | Fix |
|-------|-----|
| Extension won't install | Restart VS Code, check internet |
| "Unauthorized" errors | Verify API keys in settings |
| Suggestions not appearing | Check extension is enabled |
| Very slow responses | Try faster model (Haiku/local) |
| High costs | Switch to free tier/Ollama |
| Can't auth with Claude | Create key at console.anthropic.com |
| "Rate limit exceeded" | Wait 1 minute, upgrade plan |

---

## 📚 Learning Resources

**30-Second Intros**
- [GitHub Copilot](https://github.com/copilot/video)
- [Claude Prompt Guide](https://docs.anthropic.com/en/docs/build-a-chatbot)
- [Continue.dev Video](https://youtu.be)

**In-Depth Guides**
- [Claude Best Practices](https://docs.anthropic.com//guides/prompt-engineering)
- [Continue Setup Guide](https://continue.dev/docs)
- [Cline Workflows](https://github.com/saoudrizwan/claude-dev)

**Community**
- GitHub Copilot Discussions
- Claude Discord Community
- Continue GitHub Issues

---

## 🎓 Using Multiple Models Effectively

### Strategy 1: Tiered Approach
```
Draft: Supermaven/Windsurf (fast, free)
Review: Claude (good reasoning)
Polish: GPT-4 (best quality)
```

### Strategy 2: Task-Specific
```
Boilerplate: Copilot
Architecture: Claude Opus
AWS code: CodeWhisperer
Local: Ollama
```

### Strategy 3: Speed vs Quality
```
Under 30sec needed: Supermaven
Standard response: Copilot/Haiku
Complex problem: Sonnet/Opus
Critical decision: GPT-4 + manual review
```

---

## ✅ Next Steps

1. **Install extensions** (use commands above)
2. **Set up auth** (API keys, GitHub login)
3. **Try first prompt** - Ask "explain my code structure"
4. **Iterate** - Find best model for your workflow
5. **Optimize costs** - Disable unused models
6. **Share setup** - Help team discover best practices

---

**Ready to code smarter? Start with 30-second installation above!**

Last Updated: February 7, 2026
