#!/bin/bash
# dotfiles/setup.sh
# GitHub Codespaces 시작 시 자동 실행

set -e

echo "🔧 Jay dotfiles 설치 중..."

# ~/.claude 디렉토리 생성
mkdir -p ~/.claude

# 글로벌 CLAUDE.md 복사
cp "$(dirname "$0")/CLAUDE.md" ~/.claude/CLAUDE.md

echo "✅ ~/.claude/CLAUDE.md 설치 완료"
