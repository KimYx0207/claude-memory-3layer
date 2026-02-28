# 🧠 Three-Layer Memory System for Claude Code

> Give Claude Code a real memory — structured, git-trackable, and token-efficient.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-v2.1%2B-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)

Claude Code forgets everything between sessions. The official `CLAUDE.md` requires manual maintenance. The official auto-memory (v2.1.59+) solves **knowledge discovery** brilliantly — Claude uses AI to decide what's worth remembering.

**But discovery is only half the problem.** The other half — lifecycle management, git tracking, team sharing, precise token control — is what this Skill handles.

**This is not a replacement for official auto-memory. It's the management layer that official auto-memory doesn't have.**

---

## Official Auto-Memory + Three-Layer: Better Together

Official auto-memory is great at **discovering** knowledge (AI-powered, zero config).
Three-Layer Memory is great at **managing** knowledge (structured, git-trackable, lifecycle-aware).

Use both. They coexist without conflict.

| Dimension | Official v2.1.59 | Three-Layer Memory | Best for |
|-----------|-------------------|-------------------|----------|
| Knowledge discovery | AI semantic understanding | Keyword matching (rules) | Official wins |
| Install cost | Zero config | One command | Official wins |
| Storage | Single MEMORY.md | 3 layers (JSON + MD + MD) | Three-Layer more flexible |
| Git tracking | ❌ `~/.claude/projects/` (hidden) | ✅ `.claude/memory/` (in project) | Three-Layer only |
| Lifecycle | Write-only, grows forever | `status` field (active/superseded) | Three-Layer only |
| Token control | Truncate at 200 lines (unknown tokens) | ~1500 tokens (configurable) | Three-Layer more predictable |
| Team sharing | ❌ Local only | ✅ Via git | Three-Layer only |
| Knowledge cleanup | ❌ None | ✅ Auto-suggest via `/memory-review` | Three-Layer only |

---

## Quick Start

### One-Line Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.ps1 | iex
```

### Manual Install

```bash
git clone https://github.com/laojin-ai/claude-memory-3layer.git
cd claude-memory-3layer
./install.sh   # or .\install.ps1 on Windows
```

### What Gets Installed

```
your-project/
└── .claude/
    ├── hooks/
    │   ├── memory_loader.py      # SessionStart hook
    │   ├── memory_extractor.py   # PostToolUse hook
    │   ├── session_state.py      # State management
    │   └── pre_compact.py        # PreCompact hook
    ├── memory/
    │   ├── MEMORY.md             # Layer 3: tacit knowledge
    │   ├── memory/               # Layer 2: daily notes
    │   └── areas/topics/         # Layer 1: knowledge graph
    ├── commands/
    │   ├── memory-review.md      # /memory-review command
    │   └── memory-status.md      # /memory-status command
    └── settings.json             # Hook registration
```

---

## How It Works

### Three Layers, Three Purposes

```
┌─────────────────────────────────────────────────┐
│              Session Start                       │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │ Layer 1   │  │ Layer 2   │  │ Layer 3       │  │
│  │ JSON      │  │ Markdown  │  │ Markdown      │  │
│  │           │  │           │  │               │  │
│  │ Knowledge │  │ Daily     │  │ Tacit         │  │
│  │ Graph     │  │ Notes     │  │ Knowledge     │  │
│  │           │  │           │  │               │  │
│  │ Last 10   │  │ Last 3    │  │ Full file     │  │
│  │ active    │  │ days      │  │               │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│        │              │              │           │
│        └──────────────┴──────────────┘           │
│                       │                          │
│              ~1500 tokens total                   │
│              (<1% of 200K context)               │
└─────────────────────────────────────────────────┘
```

### Layer 1: Knowledge Graph (JSON)

Structured facts with lifecycle management.

```json
{
  "id": "fact-20260227143022",
  "fact": "Use pnpm instead of npm for this project",
  "timestamp": "2026-02-27",
  "status": "active"
}
```

- Stored in `.claude/memory/areas/topics/<topic>/items.json`
- Each fact has a `status` field: `active` or `superseded`
- Only `active` items are loaded at session start
- Auto-extracted by PostToolUse hook

### Layer 2: Daily Notes (Markdown)

What happened today — auto-appended, never edited.

```markdown
# 2026-02-27

## 14:30
Refactored auth module to use JWT instead of sessions
Topics: authentication, refactoring

## 16:45
Fixed N+1 query in user list endpoint
Topics: performance, postgres
```

- Stored in `.claude/memory/memory/YYYY-MM-DD.md`
- Last 3 days loaded at session start
- Provides temporal context ("what was I doing yesterday?")

### Layer 3: Tacit Knowledge (Markdown)

Hard-won experience that can't be auto-extracted.

```markdown
## Architecture Decisions
- Chose FastAPI over Flask for async support

## Gotchas & Pitfalls
- Redis connection pool must be closed explicitly on shutdown
- Never use `datetime.now()` in tests, always mock it

## Tool Preferences
- Use ruff instead of flake8+black
```

- Stored in `.claude/memory/MEMORY.md`
- Manually maintained (similar to official CLAUDE.md)
- Full file loaded at session start

---

## Hook Registration

The installer auto-registers hooks in `.claude/settings.json`. If you need to add them manually:

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

---

## Commands

### `/memory-review`

Periodic knowledge hygiene — find patterns worth promoting, and outdated entries worth cleaning up.

- Scans all 3 layers for recurring patterns (high-frequency, trending, decaying)
- Suggests promoting patterns to `CLAUDE.md` as permanent rules
- Suggests marking outdated entries as `superseded`
- Both "add" and "remove" — keeps your knowledge base lean

### `/memory-status`

Show memory system statistics — item counts, date ranges, token estimates.

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MEMORY_DIR` | `.claude/memory/` | Override memory directory path |
| `MEMORY_MAX_ITEMS` | `10` | Max active items loaded per topic |
| `MEMORY_DAILY_DAYS` | `3` | Days of daily notes to load |
| `MEMORY_TOPICS` | (auto-detect) | Custom topic mapping (`key:topic,key:topic`) |

### Custom Topics

Set `MEMORY_TOPICS` to define custom keyword-to-topic mappings:

```bash
export MEMORY_TOPICS="fastapi:backend,react:frontend,stripe:payments"
```

---

## Lifecycle Management

The key feature official auto-memory doesn't have: **knowledge can expire**.

```
Active ──────── Used normally, loaded at session start
   │
   ▼
Superseded ──── Outdated, NOT loaded, kept for reference
```

To mark a fact as outdated, change its `status` in `items.json`:

```json
{
  "id": "fact-20260101",
  "fact": "Use Flask for the API server",
  "status": "superseded"
}
```

Or use `/memory-review` to auto-detect and clean up outdated entries.

---

## Compatibility

- **Claude Code**: v2.1.0+ (hooks support required)
- **Python**: 3.8+ (stdlib only, zero dependencies)
- **OS**: macOS, Linux, Windows
- **Coexists with**: Official auto-memory (v2.1.59+), CLAUDE.md

---

## Project Structure

```
claude-memory-3layer/
├── SKILL.md              # Claude Code Skill manifest
├── README.md             # This file
├── LICENSE               # MIT
├── install.sh            # Unix/macOS installer
├── install.ps1           # Windows installer
├── hooks/
│   ├── memory_loader.py  # SessionStart: load 3 layers
│   ├── memory_extractor.py # PostToolUse: extract knowledge
│   ├── session_state.py  # Session lifecycle state
│   └── pre_compact.py    # PreCompact: save before compression
├── commands/
│   ├── memory-review.md  # /memory-review command
│   └── memory-status.md  # /memory-status command
├── templates/
│   ├── MEMORY.md         # Layer 3 template
│   └── items.json        # Layer 1 template
└── docs/
    ├── quickstart.md     # Getting started guide
    ├── architecture.md   # System architecture deep-dive
    └── vs-official.md    # Detailed comparison with official
```

---

## Contributing

Issues and PRs welcome. Please:

1. Keep zero-dependency policy (Python stdlib only)
2. Test on macOS + Windows
3. Follow existing code style

---

## License

MIT — use it however you want.

---

## Author

**LaojinAI** (老金) — Building tools for Claude Code power users.

WeChat: Search "老金AI笔记" for tutorials and deep-dives.
