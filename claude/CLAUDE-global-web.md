# Global Rules — Web Claude Code / Codespaces

> **Environment**: Web Claude Code (claude.ai/code) or GitHub Codespaces
> **Fork source**: vault/CLAUDE-global.md (Mac Mini CLI version)
> **Key differences**: No LM Studio, No MCP, Gemini via API only

<!-- IMPORTANT — agents loading this file:
  This file is the public LANDING version of global rules. Real implementation details
  (full skill definitions, scripts, hooks, lessons.md, settings) live in:

    claude-private/vault-mirror/  ← private GitHub mirror, gh auth required
      ├── skills/    (full SKILL.md for each command)
      ├── scripts/   (rsml/gsync/vault_sync/inventory etc.)
      ├── hooks/     (SessionStart, UserPromptSubmit hooks)
      ├── system/    (CLAUDE.md, lessons.md, livestatus.md, settings.json,
      │              architecture.md, vault-sync.md, vault-structure.md, etc.)
      └── projects/CLAUDE-sub/ (per-project sub-rules)

  Fetch flow (web/codespaces):
    gh repo clone Seeuferil/claude-private /tmp/claude-private -- --depth 1
    Then read from /tmp/claude-private/vault-mirror/

  Frequently-forgotten critical rules (always apply, even if not in main body):
  - vault is single source of truth. Don't edit mirror or dotfiles directly — they're regenerated.
  - Plan before coding. No code changes without explicit user approval (§-1 Core Rule #1).
  - Verify with actual execution, not syntax check (§1-V Verification Routine).
  - All ~/.claude rules/configs/skills/scripts/hooks must mirror to vault. Sync runs in /rsml -full.
  - Secrets (.credentials.json, *.env) are NEVER mirrored. Stored in *.env-vault separately.
-->

---

## Four Principles

| 원칙 | 정의 | 구현 위치 |
|---|---|---|
| 1. Think Before Coding | 가정·혼란 명시. 트레이드오프 제시. 막히면 stop+질문 | (직접 적용) |
| 2. Simplicity First | 최소 코드. 사변적 추상화·미사용 에러처리 금지 | Code Rules |
| 3. Surgical Changes | 요청 외 코드·주석·포맷 손대지 않음. 변경한 줄은 요청에 직결 | Code Rules |
| 4. Goal-Driven Execution | 검증 가능한 성공조건 정의. 통과까지 루프 | Harness Pattern (verifier) |

---

## LLM 라우팅 (하네스 전용)

하네스(`/harness`, `/harness-run`, `/harness-check`) 실행 시에만 적용.
일반 대화·코딩은 Claude가 직접 처리.

| Tier | Tool | 용도 | Web 환경 |
|---|---|---|---|
| 1 | Claude (Sonnet) | 계획·조율·코드 작성·판단 | ✅ 기본 |
| 2 | Gemini API | 대형 코드베이스 전체 분석 | ✅ curl/script |
| 3 | LM Studio | 단순 반복 태스크 | ❌ Mac Mini 전용 |

### Tier 2 → Gemini API

Web Claude Code에서는 `gemini-analyzer` subagent 대신 Bash에서 직접 호출:

```bash
# GEMINI_API_KEY 환경변수 필요
~/.claude/scripts/gemini-ask.sh "분석할 내용"
echo "프롬프트" | ~/.claude/scripts/gemini-ask.sh --flash
```

또는 subagent로:
```
Agent(subagent_type="gemini-analyzer", prompt="...")
```

### Tier 3 → Fallback to Claude

Web 환경에서 Tier 3 불가 → Tier 1(Claude)이 직접 처리.
커밋 메시지도 Claude가 직접 작성.

---

## 커밋 메시지

Mac Mini에서는 Tier 3 스크립트 우선.
Web/Codespace에서는 Claude가 직접 작성 (아래 규칙 적용):

- First line: `type: short summary` (max 72 chars, English)
- Type: `feat` / `fix` / `chore` / `refactor` / `docs`
- Co-Authored-By 라인 포함

---

## MCP

Web Claude Code는 MCP를 지원하지 않음.

- MCP 설정이 필요하면 `~/.claude/scripts/setup-mcp.sh` 참조 (Mac Desktop 전용)
- Web 환경에서는 MCP 없이 작업 설계할 것

---

## 하네스 패턴 (Web 환경 적용 가능)

Plan-Do-Review 패턴은 Web 환경에서도 동작:
- scout: `local-explorer` or `Explore` subagent
- patcher: Claude 직접 (Tier 1)
- verifier: `Explore` + Bash

하네스 템플릿: `~/.claude/harness_templates/` (로컬) 또는 dotfiles repo에서 fetch.

---

## Vault-Mirror (Web/Codespace용 프로젝트 지식베이스)

Mac Mini의 Obsidian vault를 대체하는 **read-only snapshot**. `claude-private` repo 안에 미러됨.

### Bootstrap

```bash
# 세션 시작 시 자동 fetch (gh auth 필요)
MIRROR=/tmp/claude-private/vault-mirror
if [ ! -d "$MIRROR" ]; then
  gh repo clone Seeuferil/claude-private /tmp/claude-private -- --depth 1
fi
```

### 사용법

프로젝트 구조·스택·인프라 조회 시 **vault-mirror 먼저** 읽고, 파일 탐색은 그 다음:

```
$MIRROR/index.yaml                  ← L0 quick lookup (~200 tokens)
$MIRROR/infra-map.md                ← GitHub × Railway × Vercel 연결맵
$MIRROR/projects/claude-projects.md ← 전 프로젝트 현황 테이블
$MIRROR/projects/*-summary.md       ← 프로젝트별 compact 요약
$MIRROR/system/*-summary.md         ← 시스템 문서 요약
```

### 규칙

- **Read-only**: Web에서 mirror 파일 수정 금지. Mac 복귀 후 vault에서 수정.
- **Vault-first**: 프로젝트 정보가 필요하면 index.yaml → summary → 실제 파일 탐색 순서.
- **Sync**: Mac `/rsml` 실행 시 자동 갱신. `index.yaml` 헤더의 `Updated:` 날짜로 최신성 확인.

---

## 노트 / 설정 저장소

GitHub dotfiles repo를 단일 소스로 사용:

```bash
# fetch latest global rules
curl -sL https://raw.githubusercontent.com/Seeuferil/dotfiles/main/claude/CLAUDE-global-web.md
```

Obsidian vault (로컬) ↔ vault-mirror (claude-private) 동기화는 Mac Mini에서만 수행.

---

## 코드 규칙

- **모듈 작업 전 docstring 필독**: 파일 수정 전 반드시 module-level docstring 먼저 읽을 것. 운영 규칙·계정 구분·금지 패턴이 거기 명기됨.
- 최소코드·최소영향 | 근본원인만 | 기존패턴 우선
- `grep` 전체 → 한 번에 처리. 파일별 개별 수정 금지
- 추측 수정 3회 실패 → 접근법 전환

---

## 토큰 절약 규칙

1. **컨텍스트 오염 방지**: 대용량 XML/JSON 응답은 파일에 저장 후 경로만 참조
2. **Gemini 오프로드**: 500줄 이상 파일 전체 분석 → Gemini API
3. **하네스 분리**: scout가 요약된 spec JSON 생성 → patcher는 spec만 읽음
4. **Read 도구 우선**: Bash cat 대신 Read 사용 (컨텍스트 효율 높음)

---

## LiveStatus

`~/.claude/livestatus.md` — Mac Mini에서 자동 갱신.
Web 환경에서는 세션 시작 시 수동으로 현재 작업 컨텍스트 제공.

---

## Lessons Learned (Private)

`~/.claude/lessons.md` — `Seeuferil/claude-private` repo에서 fetch.
모든 프로젝트에 적용되는 재사용 가능한 원칙.

세션 시작 시 파일이 없으면 fetch:
```bash
[ ! -f ~/.claude/lessons.md ] && \
  curl -sf -H "Authorization: token ${GITHUB_TOKEN:-$(gh auth token 2>/dev/null)}" \
    -H "Accept: application/vnd.github.v3.raw" \
    "https://api.github.com/repos/Seeuferil/claude-private/contents/claude/lessons.md" \
    > ~/.claude/lessons.md 2>/dev/null || true
```

Web Claude Code: `GITHUB_TOKEN` 환경변수 설정 필요.
