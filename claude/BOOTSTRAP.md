<!-- BEGIN:design-notes
## Design Intent (read before modifying)

This file is the single source of truth for the Bootstrap Rule.

### Structure
- Bootstrap Rule must exist as a COPY in each project's CLAUDE.md.
  Reason: When opening a project directly in Web Claude Code / Codespaces,
  CLDWork/CLAUDE.md is not loaded. Each project must bootstrap independently
  to load the correct environment-specific global rules.

- "This is duplication, let's remove it" breaks this intent.
  Instead, modify this file and propagate with `bash install.sh --sync`.

### Environment Branching
- Mac Mini CLI  → CLAUDE-global.md (copied from vault or dotfiles)
- Web/Codespaces → CLAUDE-global-web.md (fetched via curl from dotfiles)

The two global files have different content (e.g., Tier 3 local LLM presence).
Removing environment detection logic causes Web to load Mac-only rules,
or causes nothing to load at all.

### How to Modify
1. Edit this file (BOOTSTRAP.md) only
2. Run `bash install.sh --sync` to propagate to all projects
3. Commit each project
END:design-notes -->

## Global Config Load Order

### 1. Detect Environment

| Environment | Detection Criteria | Global to Load |
|---|---|---|
| Mac Mini CLI | `~/.claude/CLAUDE.md` exists + `/Users/mpm4` path | `CLAUDE-global.md` (Mac only) |
| Web Claude Code | claude.ai/code, no local filesystem | `CLAUDE-global-web.md` (from dotfiles repo) |
| Codespaces / other PC | No `/Users/mpm4`, no `~/.claude/CLAUDE.md` | `CLAUDE-global-web.md` |

### 2. Load CLAUDE-global.md (Mac Mini)

IF CLAUDE-global.md NOT EXISTS:
  1. If vault file exists:
     ```
     cp ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MPM4/vault/CLAUDE-global.md .
     ```
  2. If no vault — fetch from dotfiles repo:
     ```bash
     curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-mac.md > CLAUDE-global.md
     ```
  3. If both fail (Notion MCP):
     → notion-fetch: https://www.notion.so/CLAUDE-SYSTEM-PROMPT-32edb41215d281c484d0d6c6231b0cc8

### 3. Load CLAUDE-global-web.md (Web / Codespaces)

IF CLAUDE-global-web.md NOT EXISTS:
  ```bash
  curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-web.md > CLAUDE-global-web.md
  ```

---

## Apply Rules

| Environment     | Global                                                             | Project           |
|-----------------|--------------------------------------------------------------------|-------------------|
| Web Claude Code | `CLAUDE-global-web.md` (dotfiles repo)                            | + `CLAUDE-sub.md` |
| Mac Mini CLI    | `CLAUDE-global.md` + `~/.claude/CLAUDE.md` (3-tier routing only)  | + `CLAUDE-sub.md` |
| Codespaces      | `CLAUDE-global-web.md` (dotfiles repo)                            | + `CLAUDE-sub.md` |

---

## dotfiles Repo

```
https://github.com/Seeuferil/dotfiles
├── claude/
│   ├── BOOTSTRAP.md           # ← this file. Single source for Bootstrap Rule.
│   ├── CLAUDE-global-web.md   # Web/Codespaces rules
│   ├── CLAUDE-global-mac.md   # Mac Mini rules (vault backup)
│   └── logs/                  # session logs (optional)
└── scripts/
    ├── gemini-ask.sh           # Tier 2: Gemini API wrapper
    └── setup-mcp.sh            # MCP setup (Mac Desktop only)
```

---

## Vault (Mac Mini only)

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/MPM4/vault/
```
