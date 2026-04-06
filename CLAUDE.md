# Global Rules

## 환경 감지

| 환경 | 판별 기준 | 추가 로드 |
|---|---|---|
| Mac Mini CLI | `~/.claude/CLAUDE.md` 존재 | Tier 3, LiveStatus |
| Web Claude Code | 로컬 파일시스템 없음 | 없음 (이 파일만) |
| Codespaces | `CODESPACES` 환경변수 | 없음 (이 파일만) |

Mac Mini는 이 파일 로드 후 `~/.claude/CLAUDE.md`를 추가 적용.

---

## LLM 라우팅 (하네스 전용)

`/harness`, `/harness-run`, `/harness-check` 실행 시에만 적용.
일반 대화·코딩은 Claude(Tier 1)가 직접 처리.

| Tier | Tool | 용도 | 환경 |
|---|---|---|---|
| 1 | Claude (Sonnet) | 계획·조율·코드 작성·판단 | 모든 환경 |
| 2 | Gemini | 대형 코드베이스 전체 분석 | 모든 환경 |
| 3 | LM Studio | 단순 반복 태스크 | Mac Mini 전용 |

### Tier 2 → Gemini

```
Agent(subagent_type="gemini-analyzer", prompt="...")
```

Codespaces에서 직접 호출 시:
```bash
~/.claude/scripts/gemini-ask.sh "프롬프트"
```
(GEMINI_API_KEY 필요 — GitHub Codespaces Secrets에 설정)

### Tier 3 → Mac Mini 전용

Web/Codespaces에서 Tier 3 불가 → Tier 1(Claude)이 직접 처리.

---

## 하네스 패턴

Plan-Do-Review — 모든 환경에서 동작:

- **scout**: `Explore` subagent — 코드 분석 → spec JSON 생성
- **patcher**: Claude(Tier 1) — spec 기반 구현
- **verifier**: `Explore` + Bash — 검증

하네스 템플릿: 프로젝트 `.claude/harness_templates/` 또는 `~/.claude/harness_templates/`

---

## 커밋 메시지

- First line: `type: short summary` (max 72 chars, English)
- Type: `feat` / `fix` / `chore` / `refactor` / `docs`
- Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com> 포함
- Mac Mini: `gen-commit-msg.sh`(Tier 3) 우선, 실패 시 Claude 직접 작성

---

## 토큰 절약

1. 대용량 XML/JSON 응답 → 파일 저장 후 경로만 참조
2. 500줄 이상 파일 전체 분석 → Gemini 오프로드
3. scout가 요약 spec JSON 생성 → patcher는 spec만 읽음
4. `cat` 대신 `Read` 도구 사용

---

## MCP

Mac Desktop 전용. Web Claude Code / Codespaces 미지원.

설정 필요 시: `~/.claude/scripts/setup-mcp.sh --list`
