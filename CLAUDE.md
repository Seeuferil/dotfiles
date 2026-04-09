# Global Rules

## Environment Detection

| Environment | Detection Criteria | Additional Load |
|---|---|---|
| Mac Mini CLI | `~/.claude/CLAUDE.md` exists | Tier 3, LiveStatus |
| Web Claude Code | No local filesystem | None (this file only) |
| Codespaces | `CODESPACES` env var present | None (this file only) |

Mac Mini: load this file first, then apply `~/.claude/CLAUDE.md` on top.

---

## LLM Routing (harness only)

Applies only when running `/harness`, `/harness-run`, `/harness-check`.
For normal conversation and coding, Claude (Tier 1) handles directly.

| Tier | Tool | Purpose | Environment |
|---|---|---|---|
| 1 | Claude (Sonnet) | Planning, orchestration, code, judgment | All |
| 2 | Gemini | Large codebase full analysis | All |
| 3 | LM Studio | Simple repetitive tasks | Mac Mini only |

### Tier 2 → Gemini

```
Agent(subagent_type="gemini-analyzer", prompt="...")
```

Direct call in Codespaces:
```bash
~/.claude/scripts/gemini-ask.sh "prompt"
```
(Requires `GEMINI_API_KEY` — set in GitHub Codespaces Secrets)

### Tier 3 → Mac Mini only

Web/Codespaces cannot use Tier 3 → Claude (Tier 1) handles directly.

---

## Harness Pattern

Plan-Do-Review — works in all environments:

- **scout**: `Explore` subagent — analyze code → produce spec JSON
- **patcher**: Claude (Tier 1) — implement from spec
- **verifier**: `Explore` + Bash — validate

Harness templates: project `.claude/harness_templates/` or `~/.claude/harness_templates/`

---

## Commit Messages

- First line: `type: short summary` (max 72 chars, English)
- Types: `feat` / `fix` / `chore` / `refactor` / `docs`
- Always include: `Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>`
- Mac Mini: prefer `gen-commit-msg.sh` (Tier 3); fall back to Claude if it fails

---

## Token Efficiency

1. Large XML/JSON responses → save to file, reference path only
2. Files over 500 lines (full analysis) → offload to Gemini
3. Scout produces summarized spec JSON → patcher reads spec only
4. Use `Read` tool instead of `cat`

---

## MCP

Mac Desktop only. Not supported in Web Claude Code or Codespaces.

To configure: `~/.claude/scripts/setup-mcp.sh --list`
