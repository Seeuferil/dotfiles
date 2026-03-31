# Bootstrap Rule

IF CLAUDE-global.md NOT EXISTS:
  fetch https://www.notion.so/CLAUDE-SYSTEM-PROMPT-32edb41215d281c484d0d6c6231b0cc8
  → create CLAUDE-global.md

# Apply Rules

| Environment     | Global                                               | Project         |
|-----------------|------------------------------------------------------|-----------------|
| Web Claude Code | CLAUDE-global.md                                     | + CLAUDE-sub.md |
| Mac Mini CLI    | CLAUDE-global.md + ~/.claude/CLAUDE.md (3-tier 전용) | + CLAUDE-sub.md |


