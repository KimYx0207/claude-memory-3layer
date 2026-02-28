# System Architecture

## Overview

The Three-Layer Memory System is built on two core mechanisms:

1. **Hooks** — Claude Code lifecycle events that trigger memory operations
2. **Layered Storage** — Three specialized storage formats for different knowledge types

```
┌──────────────────────────────────────────────────────────────┐
│                    Claude Code Session                        │
│                                                              │
│  SessionStart ──→ memory_loader.py ──→ Load 3 layers         │
│       │                                    │                  │
│       ▼                                    ▼                  │
│  [Context injected with ~1500 tokens of memory]              │
│                                                              │
│  ... working ...                                             │
│                                                              │
│  PostToolUse ──→ memory_extractor.py ──→ Save to L1 + L2     │
│       │                                                      │
│  PreCompact ──→ pre_compact.py ──→ Save session state        │
│       │                                                      │
│  SessionEnd ──→ (state persisted for next session)           │
└──────────────────────────────────────────────────────────────┘
```

## Storage Architecture

### Layer 1: Knowledge Graph (JSON)

**Purpose**: Structured, filterable, lifecycle-managed facts.

**Location**: `.claude/memory/areas/topics/<topic>/items.json`

**Schema**:
```json
[
  {
    "id": "fact-20260227143022",
    "fact": "Use connection pooling for PostgreSQL (max 20 connections)",
    "timestamp": "2026-02-27",
    "status": "active",
    "category": "database",
    "source": "debugging session"
  }
]
```

**Key design decisions**:
- **JSON over Markdown**: Enables programmatic filtering by `status`, `timestamp`, `category`
- **Topic folders**: Natural partitioning prevents single-file bloat
- **Status field**: Only `active` items are loaded; `superseded` items stay for reference
- **Last 10 active**: Configurable via `MEMORY_MAX_ITEMS` env var

**Why not a database?** Zero dependencies. JSON files are human-readable, git-diffable, and require no runtime. SQLite would add complexity for minimal benefit at this scale.

### Layer 2: Daily Notes (Markdown)

**Purpose**: Temporal context — what happened and when.

**Location**: `.claude/memory/memory/YYYY-MM-DD.md`

**Format**:
```markdown
# 2026-02-27

## 14:30
Refactored auth module to use JWT
Topics: authentication, refactoring

## 16:45
Fixed N+1 query in user list
Topics: performance, postgres
```

**Key design decisions**:
- **One file per day**: Natural time-based partitioning
- **Append-only**: Never edit, only add new entries
- **Last 3 days**: Configurable via `MEMORY_DAILY_DAYS` env var
- **Human-readable timestamps**: Easy to scan visually

### Layer 3: Tacit Knowledge (Markdown)

**Purpose**: Hard-won insights that can't be auto-extracted.

**Location**: `.claude/memory/MEMORY.md`

**Key design decisions**:
- **Manually maintained**: Like a personal wiki
- **Full file loaded**: No truncation (keep it concise)
- **Similar to CLAUDE.md**: But for learned knowledge, not rules

## Hook Architecture

### SessionStart Hook (`memory_loader.py`)

```
Trigger: Every new Claude Code session
Action:  Load all 3 layers into session context
Output:  JSON { "message": "<memory context>", "continue": true }
Budget:  ~1500 tokens (configurable)
```

**Loading order**: Layer 3 → Layer 2 → Layer 1

Why this order? Layer 3 (tacit knowledge) is most stable and important. Layer 1 (recent facts) is most volatile and may be less relevant.

### PostToolUse Hook (`memory_extractor.py`)

```
Trigger: After tool executions
Action:  Extract knowledge from conversation
Output:  Save to Layer 1 (items.json) + Layer 2 (daily note)
```

**Topic detection**: Scans text for keywords and maps to topic folders. Default keywords cover common programming domains. Customizable via `MEMORY_TOPICS` env var.

**Deduplication**: Checks existing facts before inserting. Identical facts are skipped.

### PreCompact Hook (`pre_compact.py`)

```
Trigger: Before context window compression
Action:  Save current session state to disk
Output:  JSON { "message": "<status>", "continue": true }
```

**Why this matters**: When Claude Code compresses context, information can be lost. This hook ensures session state survives compression.

## Token Budget Analysis

The system is designed to stay under ~1500 tokens at session start (single topic):

| Component | Estimated Tokens |
|-----------|-----------------|
| Layer 3 (MEMORY.md, typical) | ~300 |
| Layer 2 (3 days × ~3 entries) | ~400 |
| Layer 1 (10 facts per topic × ~15 words) | ~600 |
| Headers and formatting | ~100 |
| **Total (single topic)** | **~1400** |

Multiple topics scale linearly. Configure via `MEMORY_MAX_ITEMS` env var.

This is <1% of Claude's 200K context window. Official auto-memory's token consumption varies depending on MEMORY.md content density and Skill metadata injection. Three-Layer's budget is fixed and configurable.

## Comparison with Official Auto-Memory

See [vs-official.md](./vs-official.md) for a detailed comparison.

## Directory Structure

```
.claude/
├── hooks/                          # Lifecycle hooks
│   ├── memory_loader.py            # SessionStart
│   ├── memory_extractor.py         # PostToolUse
│   ├── session_state.py            # State management
│   └── pre_compact.py              # PreCompact
├── memory/                         # Memory storage
│   ├── MEMORY.md                   # Layer 3
│   ├── memory/                     # Layer 2
│   │   ├── 2026-02-25.md
│   │   ├── 2026-02-26.md
│   │   └── 2026-02-27.md
│   └── areas/                      # Layer 1
│       └── topics/
│           ├── general/items.json
│           ├── python/items.json
│           ├── postgres/items.json
│           └── deployment/items.json
├── commands/                       # User commands
│   ├── memory-review.md
│   └── memory-status.md
├── data/                           # Runtime state (gitignored)
│   └── session_state.json
└── settings.json                   # Hook registration
```
