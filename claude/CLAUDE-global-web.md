# Global Rules — Web Claude Code / Codespaces

> **Environment**: Web Claude Code (claude.ai/code) or GitHub Codespaces
> **Fork source**: CLAUDE-global.md (Mac Mini CLI version)
> **Key differences**: No LM Studio, No MCP, Gemini via API only

---

## Behavior

| Rule | Description |
|------|-------------|
| Ask First | At session start, ask what to do. Do NOT auto-start analysis or implementation. |
| Plan Approval | Output plan and wait for approval. **Never write code without explicit approval.** |
| No Stalling | If blocked, STOP immediately and replan. Do not push through. |
| Verify Before Done | Never mark complete without passing the verification routine below. |
| Full Scope | Before any change, list all affected files. Handle them together. |
| Self-Improvement | After a correction, identify the pattern and root cause. |
| Task Plan | Before starting work, write a checklist-style plan. Check off as you go. |

---

## Verification Routine (Verify Before Done)

Before marking any task complete, **must** confirm actual execution results. Syntax checks and code review are NOT verification.

| Environment | Verification Method |
|-------------|-------------------|
| GitHub Actions | `gh workflow run` → `gh run watch` → check logs for actual behavior |
| Railway / Server | Deploy → `curl` or logs to confirm response/behavior |
| Vercel / Frontend | Deploy → browser check: golden path + edge cases |
| CLI Script | Actually run it, check stdout/stderr |
| API Changes | Send real request, confirm response |
| Cron / Schedule | Dry-run or manual trigger, confirm 1 execution |

**else/fallback/error paths are also verification targets.** Never complete after checking only the happy path.

---

## Code Principles

| Principle | Description |
|-----------|-------------|
| Simplicity First | Minimum code, minimum blast radius. |
| No Laziness | Find root cause. No temporary patches. |
| No New Patterns | Check existing patterns and helpers before adding new ones. |
| Elegance Check | For non-obvious changes, do one pass asking "is there a cleaner way?" |

---

## LLM Routing (harness only)

Applies only when running `/harness`, `/harness-run`, `/harness-check`.
Normal conversation and coding → Claude handles directly.

| Tier | Tool | Purpose | Web |
|---|---|---|---|
| 1 | Claude (Sonnet) | Planning, orchestration, code, judgment | ✅ default |
| 2 | Gemini API | Large codebase full analysis | ✅ via curl/script |
| 3 | LM Studio | Simple repetitive tasks | ❌ Mac Mini only |

### Tier 2 → Gemini API

In Web Claude Code, call directly from Bash instead of `gemini-analyzer` subagent:

```bash
# Requires GEMINI_API_KEY env var
~/.claude/scripts/gemini-ask.sh "content to analyze"
echo "prompt" | ~/.claude/scripts/gemini-ask.sh --flash
```

Or via subagent:
```
Agent(subagent_type="gemini-analyzer", prompt="...")
```

### Tier 3 → Falls back to Claude

Tier 3 not available in Web → Claude (Tier 1) handles directly.
Commit messages also written directly by Claude.

---

## Commit Messages

Web/Codespace: Claude writes directly using these rules:

- First line: `type: short summary` (max 72 chars, English)
- Types: `feat` / `fix` / `chore` / `refactor` / `docs`
- Always include Co-Authored-By line

---

## MCP

Not supported in Web Claude Code.

- If MCP setup is needed, refer to `~/.claude/scripts/setup-mcp.sh` (Mac Desktop only)
- Design all work to function without MCP in Web environments

---

## Harness Pattern (works in Web)

Plan-Do-Review works in Web:
- scout: `local-explorer` or `Explore` subagent
- patcher: Claude direct (Tier 1)
- verifier: `Explore` + Bash

Harness templates: `~/.claude/harness_templates/` (local) or fetch from dotfiles repo.

---

## Token Efficiency

1. **Prevent context pollution**: Save large XML/JSON responses to file, reference path only
2. **Gemini offload**: Files over 500 lines (full analysis) → Gemini API
3. **Harness separation**: Scout generates summarized spec JSON → patcher reads spec only
4. **Use Read tool**: Prefer `Read` over `cat` (better context efficiency)

---

## Notes Storage

GitHub dotfiles repo as single source of truth:

```bash
# fetch latest global rules
curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-web.md
```

Obsidian vault (local) ↔ dotfiles repo (remote) sync: Mac Mini only.

---

## LiveStatus

`~/.claude/livestatus.md` — auto-updated on Mac Mini.
In Web: provide current work context manually at session start.

---

## Lessons Learned (Private)

`~/.claude/lessons.md` — fetched from `Seeuferil/claude-private` repo.
Reusable principles applied across all projects.

Auto-fetch if missing at session start:
```bash
[ ! -f ~/.claude/lessons.md ] && \
  curl -sf -H "Authorization: token ${GITHUB_TOKEN:-$(gh auth token 2>/dev/null)}" \
    -H "Accept: application/vnd.github.v3.raw" \
    "https://api.github.com/repos/Seeuferil/claude-private/contents/claude/lessons.md" \
    > ~/.claude/lessons.md 2>/dev/null || true
```

Web Claude Code: `GITHUB_TOKEN` environment variable required.
