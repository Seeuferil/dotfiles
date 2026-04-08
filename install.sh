#!/usr/bin/env bash
# install.sh — dotfiles bootstrap for Claude Code environments
# Usage:
#   bash install.sh [--web | --mac | --codespace]  # bootstrap
#   bash install.sh --sync                          # sync Bootstrap Rule to all projects
# Auto-detects environment if no flag given.
#
# 설계 의도: Bootstrap Rule은 각 프로젝트 CLAUDE.md에 복사본으로 존재해야 합니다.
# Web/Codespaces에서 프로젝트를 직접 열 때 CLDWork/CLAUDE.md가 로드되지 않으므로
# 각 프로젝트가 독립적으로 Bootstrap을 실행해야 합니다.
# 수정은 claude/BOOTSTRAP.md만 하고, --sync로 전파하세요.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SCRIPTS_DIR="$CLAUDE_DIR/scripts"

detect_env() {
  if [[ -f "$HOME/.claude/CLAUDE.md" ]] && [[ "$(uname)" == "Darwin" ]]; then
    echo "mac"
  elif [[ -n "${CODESPACES:-}" ]] || [[ -n "${GITHUB_CODESPACE_TOKEN:-}" ]]; then
    echo "codespace"
  else
    echo "web"
  fi
}

ARG="${1:-}"

# --sync: Bootstrap Rule을 모든 프로젝트에 전파
if [[ "$ARG" == "--sync" ]]; then
  BOOTSTRAP_SRC="$DOTFILES_DIR/claude/BOOTSTRAP.md"
  BOOTSTRAP_CONTENT="$(cat "$BOOTSTRAP_SRC")"
  PROJECTS_DIR="$HOME/Documents/CLDWork/Git"
  PROJECTS=(MaxTrans USum GemsWriter LightHarness subway-tracker autotrade)

  echo "[sync] Bootstrap Rule → all projects"
  for proj in "${PROJECTS[@]}"; do
    TARGET="$PROJECTS_DIR/$proj/CLAUDE.md"
    if [[ ! -f "$TARGET" ]]; then
      echo "[sync] SKIP $proj — CLAUDE.md 없음"
      continue
    fi
    # 프로젝트 고유 줄(@CLAUDE-global.md, @CLAUDE-sub.md 등) 추출
    # Bootstrap Rule 외부에 있는 @ 참조 줄만 보존
    PROJECT_LINES=$(grep "^@" "$TARGET" | grep -v "^@\.claude/lhw")
    # subway-tracker는 맨 앞 @.claude/lhw/CLAUDE.md 보존
    HEAD=""
    if [[ "$proj" == "subway-tracker" ]]; then
      HEAD="@.claude/lhw/CLAUDE.md"$'\n\n'
    fi
    printf '%s%s\n\n%s\n' "$HEAD" "$BOOTSTRAP_CONTENT" "$PROJECT_LINES" > "$TARGET"
    echo "[sync] $proj/CLAUDE.md ✅"
  done
  # CLDWork/CLAUDE.md도 동기화
  CLWORK_TARGET="$HOME/Documents/CLDWork/CLAUDE.md"
  printf '%s\n' "$BOOTSTRAP_CONTENT" > "$CLWORK_TARGET"
  echo "[sync] CLDWork/CLAUDE.md ✅"
  echo ""
  echo "Sync complete. 각 프로젝트에서 git commit 필요."
  exit 0
fi

ENV="${ARG:-$(detect_env)}"
ENV="${ENV#--}"  # strip leading --

echo "[install] Environment: $ENV"

# Ensure directories exist
mkdir -p "$SCRIPTS_DIR"
mkdir -p "$CLAUDE_DIR/harness_templates"

# Install gemini-ask.sh (Tier 2, works everywhere)
cp "$DOTFILES_DIR/scripts/gemini-ask.sh" "$SCRIPTS_DIR/gemini-ask.sh"
chmod +x "$SCRIPTS_DIR/gemini-ask.sh"
echo "[install] gemini-ask.sh → $SCRIPTS_DIR"

# Install setup-mcp.sh (Mac Desktop only, but install for reference)
if [[ -f "$DOTFILES_DIR/scripts/setup-mcp.sh" ]]; then
  cp "$DOTFILES_DIR/scripts/setup-mcp.sh" "$SCRIPTS_DIR/setup-mcp.sh"
  chmod +x "$SCRIPTS_DIR/setup-mcp.sh"
  echo "[install] setup-mcp.sh → $SCRIPTS_DIR (run manually if needed)"
fi

# Install CLAUDE-global config based on environment
case "$ENV" in
  mac)
    echo "[install] Mac: using vault or dotfiles for CLAUDE-global.md"
    VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/MPM4/vault/CLAUDE-global.md"
    CLWORK="$HOME/Documents/CLDWork"
    if [[ -f "$VAULT" ]]; then
      cp "$VAULT" "$CLWORK/CLAUDE-global.md"
      echo "[install] Copied from Obsidian vault"
    elif [[ -f "$DOTFILES_DIR/claude/CLAUDE-global-mac.md" ]]; then
      cp "$DOTFILES_DIR/claude/CLAUDE-global-mac.md" "$CLWORK/CLAUDE-global.md"
      echo "[install] Copied from dotfiles"
    fi
    ;;
  web|codespace)
    echo "[install] Web/Codespace: installing CLAUDE-global-web.md"
    # Copy to project root if we're in one, otherwise to $HOME
    TARGET="${PWD}/CLAUDE-global-web.md"
    cp "$DOTFILES_DIR/claude/CLAUDE-global-web.md" "$TARGET"
    echo "[install] $TARGET"
    ;;
esac

echo ""
echo "Setup complete."
echo ""
echo "Required environment variables:"
echo "  GEMINI_API_KEY  — for Tier 2 (Gemini API)"
echo ""
if [[ "$ENV" == "mac" ]]; then
  echo "Tier 3 (local LLM) status:"
  if claude mcp list 2>/dev/null | grep -q "local_llm"; then
    echo "  ✅ local_llm MCP server registered"
  else
    echo "  ⚠️  local_llm MCP not found — run: claude mcp add"
  fi
  echo ""
fi
echo "Optional:"
echo "  ~/.claude/scripts/setup-mcp.sh --list  # MCP servers (Mac Desktop only)"
