# Global Rules — Web Claude Code / Codespaces

> **Environment**: Web Claude Code (claude.ai/code) or GitHub Codespaces
> **Fork source**: CLAUDE-global.md (Mac Mini CLI version)
> **Key differences**: No LM Studio, No MCP, Gemini via API only

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

## 노트 / 설정 저장소

GitHub dotfiles repo를 단일 소스로 사용:

```bash
# fetch latest global rules
curl -sL https://raw.githubusercontent.com/mpm4/dotfiles/main/claude/CLAUDE-global-web.md

# update via gh cli (if available)
gh api repos/mpm4/dotfiles/contents/claude/logs/session.md
```

Obsidian vault (로컬) ↔ dotfiles repo (remote) 동기화는 Mac Mini에서만 수행.

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
