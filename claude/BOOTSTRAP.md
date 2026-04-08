# Bootstrap Rule
<!--
## 설계 의도 (수정 전 반드시 읽을 것)

이 파일이 단일 진실 소스(source of truth)입니다.

### 구조 원칙
- Bootstrap Rule은 각 프로젝트 CLAUDE.md에 **복사본**으로 존재해야 합니다.
  이유: Web Claude Code / Codespaces에서 프로젝트를 직접 열 때
       CLDWork/CLAUDE.md가 로드되지 않으므로, 각 프로젝트가 독립적으로
       Bootstrap을 실행해야 환경에 맞는 global 규칙을 가져올 수 있습니다.

- "중복이니까 제거하자"는 판단은 이 의도를 깨뜨립니다.
  제거 대신 이 파일을 수정하고 `bash install.sh --sync`로 전파하세요.

### 환경별 분기
- Mac Mini CLI  → CLAUDE-global.md (vault 또는 dotfiles에서 복사)
- Web/Codespaces → CLAUDE-global-web.md (dotfiles repo에서 curl)

두 global 파일은 내용이 다릅니다 (Tier 3 로컬 LLM 유무 등).
환경 감지 로직을 제거하면 Web에서 Mac 전용 규칙이 로드되거나
아무것도 로드되지 않는 문제가 발생합니다.

### 수정 방법
1. 이 파일(BOOTSTRAP.md)만 수정
2. `bash install.sh --sync` 실행 → 모든 프로젝트에 전파
3. 각 프로젝트 git commit
-->

## Global Config 로드 순서

### 1. 환경 감지

| 환경 | 판별 기준 | 로드할 Global |
|---|---|---|
| Mac Mini CLI | `~/.claude/CLAUDE.md` 존재 + `/Users/mpm4` path | `CLAUDE-global.md` (Mac 전용) |
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
     curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-mac.md > CLAUDE-global.md
     ```
  3. 위도 실패 시 (Notion MCP):
     → notion-fetch: https://www.notion.so/CLAUDE-SYSTEM-PROMPT-32edb41215d281c484d0d6c6231b0cc8

### 3. CLAUDE-global-web.md 로드 (Web / Codespaces)

IF CLAUDE-global-web.md NOT EXISTS:
  ```bash
  curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-web.md > CLAUDE-global-web.md
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
https://github.com/Seeuferil/dotfiles
├── claude/
│   ├── BOOTSTRAP.md           # ← 이 파일. Bootstrap Rule 단일 소스
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
