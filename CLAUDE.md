# Bootstrap Rule

## Global Config 로드 순서

### 1. 환경 감지

| 환경 | 판별 기준 | 로드할 Global |
|---|---|---|
| Mac Mini CLI | `~/.claude/CLAUDE.md` 존재 + `LM_STUDIO_URL` 또는 `/Users/mpm4` path | `CLAUDE-global.md` (Mac 전용) |
| Web Claude Code | claude.ai/code, 로컬 파일시스템 없음 | `CLAUDE-global-web.md` (from dotfiles repo) |
| Codespaces / 다른 PC | `/Users/mpm4` 없음, `~/.claude/CLAUDE.md` 없음 | `CLAUDE-global-web.md` |

### 2. CLAUDE-global.md 로드 (Mac Mini)

IF CLAUDE-global.md NOT EXISTS:
  1. vault 파일 존재 시:
     ```
     cp ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MPM4/vault/CLAUDE-global.md .
     ```
  2. vault 없을 시 — dotfiles repo에서 fetch:
     ```bash
     curl -sL https://raw.githubusercontent.com/mpm4/dotfiles/main/claude/CLAUDE-global-mac.md > CLAUDE-global.md
     ```
  3. 위도 실패 시 (Notion MCP):
     → notion-fetch: https://www.notion.so/CLAUDE-SYSTEM-PROMPT-32edb41215d281c484d0d6c6231b0cc8

### 3. CLAUDE-global-web.md 로드 (Web / Codespaces)

IF CLAUDE-global-web.md NOT EXISTS:
  ```bash
  curl -sL https://raw.githubusercontent.com/mpm4/dotfiles/main/claude/CLAUDE-global-web.md > CLAUDE-global-web.md
  ```

---

## Apply Rules

| Environment     | Global                                                          | Project         |
|-----------------|-----------------------------------------------------------------|-----------------|
| Web Claude Code | `CLAUDE-global-web.md` (dotfiles repo)                         | + `CLAUDE-sub.md` |
| Mac Mini CLI    | `CLAUDE-global.md` + `~/.claude/CLAUDE.md` (3-tier 전용)       | + `CLAUDE-sub.md` |
| Codespaces      | `CLAUDE-global-web.md` (dotfiles repo)                         | + `CLAUDE-sub.md` |

---

## dotfiles Repo

```
https://github.com/mpm4/dotfiles
├── claude/
│   ├── CLAUDE-global-web.md   # Web/Codespaces 전용 규칙
│   ├── CLAUDE-global-mac.md   # Mac Mini 전용 규칙 (vault 백업)
│   └── logs/                  # 세션 로그 (선택)
└── scripts/
    ├── gemini-ask.sh           # Tier 2: Gemini API wrapper
    └── setup-mcp.sh            # Optional MCP setup (Mac Desktop only)
```

---

## Vault (Mac Mini only)

```
~/Library/Mobile Documents/iCloud~md~obsidian/Documents/MPM4/vault/
```
