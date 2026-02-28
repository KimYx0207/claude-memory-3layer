# Three-Layer Memory System for Claude Code

A cross-session memory system that automatically extracts, stores, and loads knowledge across Claude Code sessions.

## Metadata

```yaml
name: claude-memory-3layer
version: 1.0.0
description: Three-layer memory system — knowledge graph + daily notes + tacit knowledge
author: LaojinAI
license: MIT
min_claude_code_version: 2.1.0
context: fork
```

## Trigger Words

- memory system
- three layer memory
- 三层记忆
- cross session memory
- 跨会话记忆

## What It Does

### The Problem
Claude Code forgets everything between sessions. Official CLAUDE.md requires manual maintenance. Official auto-memory (v2.1.59+) brilliantly solves knowledge discovery, but lacks lifecycle management, git tracking, and team sharing.

### The Solution
A management layer that complements official auto-memory. Three specialized memory layers, each serving a different purpose:

| Layer | Format | Purpose | Auto-loaded |
|-------|--------|---------|-------------|
| Layer 1 | JSON | Knowledge graph with lifecycle management | ✅ Last 10 active |
| Layer 2 | Markdown | Daily notes (what happened today) | ✅ Last 3 days |
| Layer 3 | Markdown | Tacit knowledge (hard-won experience) | ✅ Full file |

### Key Features
- **Zero dependencies** — Pure Python stdlib, works everywhere
- **Auto-extract** — PostToolUse hook captures knowledge automatically
- **Auto-load** — SessionStart hook injects context seamlessly
- **Lifecycle management** — `status` field (active/superseded) keeps knowledge fresh
- **Git-trackable** — All files in project directory, not hidden in `~/.claude/`
- **Token-efficient** — ~1500 tokens budget, <1% of 200K context window
- **Compatible** — Works alongside official auto-memory (v2.1.59+)

## Installation

```bash
# One-line install (Unix/macOS)
curl -fsSL https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.ps1 | iex

# Manual install
git clone https://github.com/laojin-ai/claude-memory-3layer.git
cd claude-memory-3layer && ./install.sh
```

## Commands

| Command | Description |
|---------|-------------|
| `/memory-review` | Review recent memories, extract patterns, suggest permanent rules |
| `/memory-status` | Show memory system status and statistics |

## File Structure

```
.claude/
├── hooks/
│   ├── memory_loader.py      # SessionStart: load three layers
│   ├── memory_extractor.py   # PostToolUse: extract knowledge
│   ├── session_state.py      # Session lifecycle management
│   └── pre_compact.py        # PreCompact: save before compression
├── memory/
│   ├── MEMORY.md             # Layer 3: tacit knowledge
│   ├── memory/               # Layer 2: daily notes
│   │   └── YYYY-MM-DD.md
│   └── areas/                # Layer 1: knowledge graph
│       └── topics/
│           └── <topic>/
│               └── items.json
└── commands/
    └── memory-review.md      # /memory-review command
```
