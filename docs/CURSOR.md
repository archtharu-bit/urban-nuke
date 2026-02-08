# Cursor Setup

## Install
- Download Cursor from `cursor.com/download` (macOS, Windows, Linux).
- Run the installer and open Cursor.
- For specific versions, use `cursor.com/downloads`.

## First-Time Setup
On first launch, Cursor walks you through a quick setup:
- Choose keyboard shortcuts
- Pick a theme
- Set terminal preferences

You can rerun onboarding via the Command Palette: `Cursor: Start Onboarding`.

## Configure AI Behavior (Rules)
Rules provide persistent, system-level instructions for Agent and Inline Edit.
- Project rules live in `.cursor/rules`, are version-controlled, and scoped to your codebase.
- User rules are global to your Cursor environment.
- `.cursorrules` is legacy but still supported.

Rule files are written in `.mdc` and can be set to `Always`, `Auto Attached`, `Agent Requested`, or `Manual`.

## Configure Codebase Indexing
Cursor indexes your codebase by computing embeddings for each file. Indexing starts automatically when you open a project and updates incrementally.
- Check status at `Cursor Settings` > `Indexing & Docs`.
- Indexing respects ignore files like `.gitignore` and `.cursorignore`.
- You can configure which files to ignore and view the list of indexed files in `Cursor Settings`.
