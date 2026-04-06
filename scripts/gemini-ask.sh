#!/usr/bin/env bash
# gemini-ask.sh — Tier 2: Gemini API wrapper (works everywhere)
# Usage: gemini-ask.sh "prompt"
#        echo "prompt" | gemini-ask.sh
#        gemini-ask.sh --flash "prompt"

set -euo pipefail

GEMINI_API_URL="https://generativelanguage.googleapis.com/v1beta/models"
MODEL="${GEMINI_MODEL:-gemini-2.5-pro-preview-05-06}"
KEY="${GEMINI_API_KEY:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model|-m) MODEL="$2"; shift 2 ;;
    --flash) MODEL="gemini-2.0-flash"; shift ;;
    --pro) MODEL="gemini-2.5-pro-preview-05-06"; shift ;;
    *) break ;;
  esac
done

if [[ $# -gt 0 ]]; then
  PROMPT="$*"
elif ! [ -t 0 ]; then
  PROMPT="$(cat)"
else
  echo "Usage: gemini-ask.sh \"prompt\"" >&2; exit 1
fi

if [[ -z "$KEY" ]]; then
  echo "[gemini-ask] ERROR: GEMINI_API_KEY not set" >&2; exit 1
fi

ESCAPED=$(printf '%s' "$PROMPT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')

RESPONSE=$(curl -sf \
  "${GEMINI_API_URL}/${MODEL}:generateContent?key=${KEY}" \
  -H "Content-Type: application/json" \
  -d "{\"contents\":[{\"parts\":[{\"text\":${ESCAPED}}]}]}")

echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
try:
    print(data['candidates'][0]['content']['parts'][0]['text'], end='')
except (KeyError, IndexError):
    print('[gemini-ask] Unexpected response:', json.dumps(data)[:500], file=sys.stderr)
    sys.exit(1)
"
