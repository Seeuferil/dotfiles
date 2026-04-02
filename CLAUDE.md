# Bootstrap Rule

IF CLAUDE-global.md NOT EXISTS:
  1. vault 파일 존재 시:
     cp ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/MPM4/vault/CLAUDE-global.md .
  2. vault 파일 없을 시 (Notion MCP로 fetch):
     → notion-fetch: https://www.notion.so/CLAUDE-SYSTEM-PROMPT-32edb41215d281c484d0d6c6231b0cc8
     → 내용을 CLAUDE-global.md로 저장

# Apply Rules

| Environment     | Global                                               | Project         |
|-----------------|------------------------------------------------------|-----------------|
| Web Claude Code | CLAUDE-global.md                                     | + CLAUDE-sub.md |
| Mac Mini CLI    | CLAUDE-global.md + ~/.claude/CLAUDE.md (3-tier 전용) | + CLAUDE-sub.md |

# Vault

~/Library/Mobile Documents/iCloud~md~obsidian/Documents/MPM4/vault/
