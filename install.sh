#!/usr/bin/env bash
# install.sh — dotfiles bootstrap for Claude Code environments
# Usage: bash install.sh [--web | --mac | --codespace]
# Auto-detects environment if no flag given.

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

ENV="${1:-$(detect_env)}"
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
if [[ "$ENV" == "mac" ]]; then
  echo "  LM_STUDIO_URL   — for Tier 3 (default: http://localhost:1234)"
fi
echo ""
echo "Optional:"
echo "  ~/.claude/scripts/setup-mcp.sh --list  # MCP servers (Mac Desktop only)"
