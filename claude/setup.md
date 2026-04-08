# Web Claude Code — Setup
<!-- dotfiles/claude/setup.md (public) -->
<!-- 새 대화에서 "dotfiles/setup.md 읽어와" 명령 시 이 파일을 WebFetch로 로드 -->

## 실행 절차

새 대화 시작 후 아래 순서로 환경 초기화:

### 1. Notion에서 GITHUB_TOKEN 읽기

Notion MCP로 아래 페이지 fetch:
- Page ID: `33cdb41215d281ad93d2f53c50adf051`
- 또는 URL: https://www.notion.so/33cdb41215d281ad93d2f53c50adf051

`GITHUB_TOKEN` 값을 읽어 이후 단계에 사용.

### 2. claude-private에서 project-instructions.md fetch

```
URL: https://api.github.com/repos/Seeuferil/claude-private/contents/claude/project-instructions.md
Header: Authorization: token {GITHUB_TOKEN}
Header: Accept: application/vnd.github.v3.raw
```

### 3. project-instructions.md의 모든 규칙 적용

### 4. lessons.md fetch 및 적용

```
URL: https://api.github.com/repos/Seeuferil/claude-private/contents/claude/lessons.md
Header: Authorization: token {GITHUB_TOKEN}
Header: Accept: application/vnd.github.v3.raw
```

### 5. 완료 메시지 출력

```
✅ 환경 로드 완료
- project-instructions.md 적용
- lessons.md 적용
```
