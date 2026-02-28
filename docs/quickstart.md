# Quick Start Guide

## Prerequisites

- Python 3.8+
- Claude Code v2.1.0+ (hooks support)
- A git repository (recommended but not required)

## Installation

### Option 1: One-Line Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.ps1 | iex
```

### Option 2: Manual Install

```bash
# Clone the repo
git clone https://github.com/KimYx0207/claude-memory-3layer.git
cd claude-memory-3layer

# Run installer
./install.sh        # macOS/Linux
.\install.ps1       # Windows
```

### Option 3: Copy Files Manually

If you prefer full control, copy these files into your project:

```
# Hooks (required)
hooks/memory_loader.py   → .claude/hooks/memory_loader.py
hooks/memory_extractor.py → .claude/hooks/memory_extractor.py
hooks/session_state.py   → .claude/hooks/session_state.py
hooks/pre_compact.py     → .claude/hooks/pre_compact.py

# Commands (optional but recommended)
commands/memory-review.md → .claude/commands/memory-review.md
commands/memory-status.md → .claude/commands/memory-status.md

# Templates (create empty structure)
templates/MEMORY.md      → .claude/memory/MEMORY.md
templates/items.json     → .claude/memory/areas/topics/general/items.json
```

Then register hooks in `.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/memory_loader.py"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/memory_extractor.py"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python .claude/hooks/pre_compact.py"
          }
        ]
      }
    ]
  }
}
```

## Verify Installation

1. Start a new Claude Code session
2. You should see `Memory System Loaded (3-Layer)` in the output
3. Run `/memory-status` to check system status

## First Steps

### Tell Claude to Remember Something

Just say it naturally:

> "Remember that we use pnpm instead of npm in this project"

Claude will save this to Layer 1 (knowledge graph) automatically.

### Check What's Been Remembered

Run `/memory-status` to see statistics, or look directly at the files:

```bash
# Layer 1: Knowledge graph
cat .claude/memory/areas/topics/general/items.json

# Layer 2: Today's notes
cat .claude/memory/memory/$(date +%Y-%m-%d).md

# Layer 3: Tacit knowledge
cat .claude/memory/MEMORY.md
```

### Review and Clean Up

Run `/memory-review` periodically (weekly recommended) to:
- Find recurring patterns worth promoting to permanent rules
- Identify outdated knowledge entries to mark as `superseded`
- Keep the memory system lean and relevant

## Customization

### Change Token Budget

```bash
# Load more items per topic (default: 10)
export MEMORY_MAX_ITEMS=20

# Load more days of notes (default: 3)
export MEMORY_DAILY_DAYS=7
```

### Custom Topic Detection

```bash
# Map keywords to topic folders
export MEMORY_TOPICS="stripe:payments,twilio:messaging,s3:storage"
```

### Override Memory Directory

```bash
# Use a different directory
export MEMORY_DIR=/path/to/shared/memory
```

## Troubleshooting

### Memory not loading at session start

1. Check hook registration: `cat .claude/settings.json`
2. Test the loader: `python .claude/hooks/memory_loader.py`
3. Verify directory exists: `ls .claude/memory/`

### Python not found

The installer uses `python` command. If your system uses `python3`:

```json
{
  "command": "python3 .claude/hooks/memory_loader.py"
}
```

### Encoding issues on Windows

The hooks handle UTF-8 encoding automatically. If you see garbled text, ensure your terminal supports UTF-8:

```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```
