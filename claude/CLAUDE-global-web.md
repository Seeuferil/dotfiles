# CLAUDE-global-web.md
> ⚠️ Top priority. Overrides all other CLAUDE.md on conflict.
> Environment: Web Claude Code / Codespaces. No LM Studio, No MCP, Gemini via API only.

Polite language. Date/time needed → no guessing, run `date '+%F(%a) %T'` first.

---

## §1 Workflow [TOP PRIORITY]

| # | Rule | Definition |
|---|------|-----------|
| 1 | Ask First | At session start, ask what to do. No auto-start. |
| 2 | Plan Approval | Output plan, wait for approval. **Never write code without explicit approval.** |
| 3 | No Stalling | Blocked → STOP, replan. No pushing through. |
| 4 | Verify | §1-V verification routine must pass before marking complete. **No exceptions.** |
| 5 | Full Scope | List all affected files before changes. Handle together. |
| 6 | Self-Improve | After correction, identify pattern and root cause. |
| 7 | Task Plan | Write checklist plan before work. Check off as you go. |

### §1-V Verification Routine

Syntax check / code review ≠ verification. **Actual execution results** required.

| Environment | Method |
|-------------|--------|
| GH Actions | `gh workflow run` → `gh run watch` → check logs |
| Railway/Server | Deploy → curl or logs |
| Vercel/FE | Deploy → browser golden + edge cases |
| CLI | Run it → stdout/stderr |
| API | Real request → confirm response |
| cron | Dry-run or manual trigger 1x |

**else/fallback/error paths are verification targets. Happy path only → not complete.**

---

## §2 Code

Min code, min blast radius | Root cause only (no temp patches) | Existing patterns first | Non-obvious change → "better way?" 1x

- `grep` all → fix at once. No file-by-file discovery
- Config change → enumerate all affected cases first
- Package add → delete lock, regenerate, commit
- 3x guess-fix fails → switch approach, write repro script first

---

## §3 Debugging

**API error → never blame server. Check own config first:**
1. env vars match (railway variables vs local)
2. Token validity (DB cache, expiry, secret match)
3. Parameters (official spec comparison)
4. All 3 clear → then suspect server

"App works + API fails" → 100% my problem. User-confirmed facts → trust, find my bug first.

| Symptom | Response |
|---------|----------|
| stdout hang | File log (`buffering=1`). Don't trust print |
| bg process hang | `< /dev/null` stdin block + file log |
| hang location unknown | 10-step file log → after last log = hang point |
| UTC date mismatch | `datetime.now(KST)` required. DB: KST param, no `CURRENT_DATE` |

---

## §4 Deploy

Pre-deploy checklist → single commit:
Node version | Build (client+server) | Healthcheck path | Static file resolve | All env vars | Peer deps | PORT binding | Lock file

**Vercel:**
- Verify: `vercel ls` Age vs push time. Age > gap → auto-deploy not linked
- CLI: `vercel --prod` only. `vercel deploy --prod` → error
- No project split: same app pages in separate projects/repos forbidden
- No UI→bot direct call: cross-region 6s+ → bot→DB write, UI→DB read
- Next.js 16: `middleware.ts` → `proxy.ts`, export `proxy`

---

## §5 ML/Python

- DataLoader: `num_workers=0` (fork hang)
- Model save: `.tmp` → `os.replace()` atomic write
- Pre-train: `np.isnan(X).any()` required
- MPS large tensor: CPU fallback or warmup small batch

---

## §6 Operations

**Tokens**: Keywords, tables, code only. No prose. No duplication. Long session → new session.
**Task**: `tasks/todo.md` checklist | `tasks/lessons.md` patterns
**Subagent**: Large scan → Explore | Independent → parallel
**LLM Routing**: Tier 1 Claude (default) | Tier 2 Gemini API (`gemini-ask.sh`) | Tier 3 N/A in web
**DB/API**: db:push batch 1x | no n+1 | prompt ≤200 lines

### Commit Messages

`type: short summary` (≤72 chars, English). Types: feat/fix/chore/refactor/docs. Include Co-Authored-By.

### Session

Start `/rsm` | End `/rsm log`
Handoff: `Lib/resume-log/<repo>/resume-log-NNNN.md`

### Lessons Learned

→ `~/.claude/lessons.md` (project-specific only. General rules integrated in §2~§5)
