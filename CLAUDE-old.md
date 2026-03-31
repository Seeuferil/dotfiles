# Global Rules — Jay

## 세션 시작 시 항상
1. `tasks/lessons.md` 있으면 읽기
2. `tasks/todo.md` 있으면 확인
3. 프로젝트 루트 `CLAUDE.md` 있으면 읽기

## 코어 원칙
- **Simplicity First**: 모든 변경은 최대한 단순하게, 최소 코드 임팩트
- **No Laziness**: 근본 원인 찾기, 임시 패치 금지, 시니어 개발자 기준
- **Minimal Impact**: 필요한 것만 수정, 새 버그 유입 금지

## 작업 관리 (Task Management)
1. **Plan First**: 비자명한 작업(3단계 이상 또는 아키텍처 결정) → 즉시 plan mode 진입
2. **todo.md 작성**: `tasks/todo.md`에 체크 가능한 항목으로 계획 작성
3. **진행 추적**: 항목 완료 시 바로 체크
4. **결과 문서화**: 완료 후 `tasks/todo.md`에 review 섹션 추가
5. **중단 후 재계획**: 예상 밖 상황 발생 시 즉시 STOP → 재계획

## Subagent 전략
- 메인 컨텍스트 오염 방지를 위해 subagent 적극 활용
- 리서치, 탐색, 병렬 분석은 subagent에 위임
- 복잡한 문제 = subagent로 더 많은 컴퓨팅 투입
- subagent 1개 = 태스크 1개 (집중 실행)

## Self-Improvement Loop
- 사용자 교정 발생 시 → 즉시 `tasks/lessons.md` 업데이트
- 같은 실수 방지 규칙 작성
- 세션 시작 시 관련 프로젝트 lessons 리뷰

## 검증 원칙 (Verification Before Done)
- 완료 표시 전 반드시 작동 증명
- "Staff engineer가 승인할 수준인가?" 자문
- 테스트 실행, 로그 확인, 동작 시연
- 소스 grep은 검증 아님 — 실제 실행 경로 확인 필요

## 우아함 요구 (Demand Elegance)
- 비자명한 변경 시: "더 우아한 방법이 있는가?" 자문
- 해킹처럼 느껴지면: "모든 것을 알고 있는 지금, 우아한 해결책 구현"
- 단순 명백한 수정은 skip — 과도한 엔지니어링 금지

## 자율 버그 수정
- 버그 리포트 받으면 바로 수정, 핸드홀딩 요청 금지
- 로그/에러/실패 테스트 → 직접 해결
- 같은 에러 2번 이상 = 근본 원인 미해결, 증상 패치 금지

## Config/Code 검증 (모든 프로젝트 필수)
- 코드에서 읽는 env var ↔ 배포 config 선언 교차 검증
- 눈으로 확인 금지 — 스크립트로 자동 검증
- Python: `grep -r "os.getenv" --include="*.py"` 후 Railway/GitHub Actions env와 대조
- Node.js: `grep -r "process.env" --include="*.js"` 후 workflow `env:` 블록과 대조

## 배포 환경
- Railway: Python 서비스 (CWriter/USum)
- GitHub Actions: Node.js 스케줄 작업 (GemWriter)
- Vercel: Next.js 프로젝트

---

## 프로젝트별 핵심 컨텍스트

### CWriter (AI 콘텐츠 생성 & Notion 아카이브)
- 위치: Railway, `python main.py`, Socket Mode
- 트리거: `#포스팅 <주제>` / `#포스팅이미지 <주제>`
- 에이전트: POne(오케스트레이터) → WrOne(작가) ‖ DsOne(디자이너, 이미지 모드)
- LLM: `ANTHROPIC_API_KEY` 있으면 Claude Sonnet, 없으면 Gemini 폴백
- 이미지: Gemini Imagen 3 → gemini-2.0-flash-exp 폴백
- Notion DB ID: `7c564375bcc048e2b03b34d2f6f222ff`
- Notion 토큰 형식: `ntn_xxxxxxx` (secret_ 아님)
- 주요 채널: `#ceo-room` / `#dev-silo` / `#design-silo`
- env var 목록: `SLACK_BOT_TOKEN`, `SLACK_APP_TOKEN`, `SLACK_SIGNING_SECRET`,
  `ANTHROPIC_API_KEY`, `GEMINI_API_KEY`, `NOTION_API_KEY`,
  `NOTION_DATABASE_ID`, `CHANNEL_CEO_ROOM`, `CHANNEL_DESIGN_SILO`,
  `CHANNEL_DEV_SILO`, `LLM_PROVIDER`

### GemWriter (자동 기사 생성 & Slack 포스팅)
- 위치: GitHub Actions 스케줄 실행
- 기사 생성 수: `trends.length` 동적 사용 (하드코딩 금지)
- Notion DB ID: `eeeaa141-83e3-40c4-aeba-f934210cb8cd`
- Notion 토큰 형식: `ntn_xxxxxxx` (secret_ 아님)
- GitHub Actions secrets → workflow `env:` 블록에 명시적 선언 필수

### USum (Slack 봇)
- 위치: Railway, Socket Mode
- `/price` 슬래시 커맨드: POne(haiku, 검색) → DsOne(sonnet, 분석) 멀티에이전트
- Railway healthcheck: `/health` 엔드포인트 200 응답 필수

---

## lessons (공통 패턴)
- Notion 토큰은 항상 `ntn_` 형식 (`secret_` 아님)
- Railway env var는 대시보드에서 직접 등록 필요
- GitHub Actions secrets는 workflow `env:` 블록에 명시 필요 (자동 주입 안 됨)
- Gemini 429 → `Retry-After` 헤더 값만큼 대기 후 재시도
- Socket Mode 앱은 Railway healthcheck `/health` 200 필수
