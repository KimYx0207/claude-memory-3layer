---
name: memory-status
description: "\U0001F4CA Memory Status - Show memory system statistics"
version: 1.0.0
---

# Memory Status

Show current memory system status and statistics.

**Language**: Auto-detect the user's input language and output the entire report in that same language. If the user speaks Chinese, output in Chinese. If English, output in English.

## Steps

### Step 1: Check Directory Structure

Verify that `.claude/memory/` exists and has the expected structure:

```
.claude/memory/
├── MEMORY.md          # Layer 3
├── memory/            # Layer 2
│   └── *.md
└── areas/             # Layer 1
    └── topics/
        └── */items.json
```

### Step 2: Collect Statistics

1. **Layer 1 Stats**
   - Count total topics (folders under `areas/topics/`)
   - Count total items across all `items.json`
   - Count active vs superseded items
   - Find newest and oldest entries

2. **Layer 2 Stats**
   - Count total daily notes
   - Find date range covered
   - Count entries in recent notes

3. **Layer 3 Stats**
   - Check if MEMORY.md exists
   - Count lines/sections

### Step 3: Output Summary

```markdown
## Memory System Status

| Layer | Status | Details |
|-------|--------|---------|
| Layer 1 (Knowledge) | [count] topics, [count] active items | Newest: [date] |
| Layer 2 (Notes) | [count] daily notes | Range: [start] ~ [end] |
| Layer 3 (Tacit) | [lines] lines | Last modified: [date] |

**Token estimate**: ~[number] tokens at session start
**Storage**: [size] on disk
```
