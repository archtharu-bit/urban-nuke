# AI Usage Policy

Use AI to assist with diagnostics, documentation, and planning. Do not paste secrets, private keys, or full system logs that contain serial numbers or account identifiers.

## Safe AI Workflow
- Redact user names, account IDs, serial numbers, and IPs.
- Share only minimal data needed to solve the problem.
- Prefer summaries over raw logs.
- Keep AI output as suggestions, not commands to run blindly.

## Prompt Template
- Goal:
- Environment:
- What already tried:
- Constraints:
- Desired output format:

## Security Guardrails
- Never upload full vulnerability scans to public tools.
- Do not paste password manager exports or browser data.
- Review AI-suggested commands before running.

## Repo Agent Notes
- This repo includes a `.clineignore` to prevent agents from touching `reports/`, `.env`, and tool state.
- See `docs/CLINE.md` for safe defaults when using the Cline extension.
