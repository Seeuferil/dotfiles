#!/bin/bash
# dotfiles/setup.sh
# GitHub Codespaces 시작 시 자동 실행 + 로컬 설치

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔧 Jay dotfiles 설치 중..."

# ~/.claude 디렉토리 생성
mkdir -p ~/.claude/scripts

# 글로벌 CLAUDE.md 복사
cp "$DOTFILES_DIR/CLAUDE.md" ~/.claude/CLAUDE.md
echo "✅ ~/.claude/CLAUDE.md 설치 완료"

# 환경 감지
if [[ -f "$HOME/.claude/CLAUDE.md" ]] && [[ "$(uname)" == "Darwin" ]] && [[ -d "/Users/mpm4" ]]; then
  ENV="mac"
elif [[ -n "${CODESPACES:-}" ]] || [[ -n "${GITHUB_CODESPACE_TOKEN:-}" ]]; then
  ENV="codespace"
else
  ENV="web"
fi

echo "🌐 환경: $ENV"

# gemini-ask.sh 설치 (Tier 2, 모든 환경)
if [[ -f "$DOTFILES_DIR/scripts/gemini-ask.sh" ]]; then
  cp "$DOTFILES_DIR/scripts/gemini-ask.sh" ~/.claude/scripts/gemini-ask.sh
  chmod +x ~/.claude/scripts/gemini-ask.sh
  echo "✅ gemini-ask.sh 설치 완료"
fi

# CLAUDE-global-web.md 설치 (Web/Codespace)
if [[ "$ENV" != "mac" ]]; then
  if [[ -f "$DOTFILES_DIR/claude/CLAUDE-global-web.md" ]]; then
    cp "$DOTFILES_DIR/claude/CLAUDE-global-web.md" ~/.claude/CLAUDE-global-web.md
    echo "✅ CLAUDE-global-web.md 설치 완료"
  fi
fi

echo ""
echo "설치 완료!"
if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "⚠️  GEMINI_API_KEY 미설정 — Tier 2(Gemini) 사용 불가"
  echo "   Codespaces: Settings → Secrets → GEMINI_API_KEY"
fi
