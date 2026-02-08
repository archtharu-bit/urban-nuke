# AI Customization (VS Code)

Use this guide to customize AI behavior in VS Code for this repo. VS Code supports custom instructions, prompt files, custom agents, agent skills, MCP servers and tools, and language model selection.

## Custom Instructions
Custom instructions define common guidelines and rules that automatically influence AI responses.
- Always-on instructions: create `.github/copilot-instructions.md` to establish common coding standards and project context.
- File-based instructions: use `*.instructions.md` to apply targeted rules by file path or description.

## Prompt Files
Prompt files (slash commands) are standalone Markdown files you invoke in chat. Each prompt file includes task-specific context and guidance for a workflow.

## Custom Agents
Custom agents are defined in Markdown files that describe their behavior, capabilities, tools, and model preferences. Use them for specialized roles and workflows, or as subagents in larger flows.

## Agent Skills
Agent Skills package reusable capabilities as folders with instructions, scripts, and resources. Skills load on-demand and follow an open standard.

## MCP and Tools
MCP provides a gateway to external services and specialized tools, extending AI beyond code and the terminal.

## Suggested Setup for This Repo
- Start with always-on `.github/copilot-instructions.md` to cover high-level project rules.
- Add file-based `*.instructions.md` for specific areas or technologies as needed.
- Create prompt files for repeatable tasks like documentation updates or review checklists.
