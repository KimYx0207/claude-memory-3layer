# Three-Layer Memory + Official Auto-Memory (v2.1.59)

A detailed guide for Claude Code users on how these two systems complement each other.

## TL;DR

- **Official auto-memory**: AI-powered knowledge **discovery**. Zero-config, automatic. Unbeatable at deciding what's worth remembering.
- **Three-Layer Memory**: Structured knowledge **management**. Git-trackable, lifecycle-aware, token-predictable.
- **Best approach**: Use both. Official discovers, Three-Layer manages. They coexist without conflict.

---

## The Two Halves of a Memory System

A complete memory system needs two capabilities:

1. **Discovery** — figuring out what's worth remembering
2. **Management** — organizing, expiring, sharing, and controlling what's remembered

Official auto-memory excels at #1. Three-Layer Memory excels at #2. Neither does both well alone.

```
Official Auto-Memory          Three-Layer Memory
┌─────────────────┐          ┌─────────────────┐
│  DISCOVERY       │          │  MANAGEMENT      │
│                  │          │                  │
│  AI semantic     │          │  Structured JSON │
│  understanding   │          │  Lifecycle mgmt  │
│  Zero config     │          │  Git tracking    │
│  Auto-organize   │          │  Team sharing    │
│  Topic files     │          │  Token control   │
└────────┬─────────┘          └────────┬─────────┘
         │                             │
         └──────────┬──────────────────┘
                    │
            Complete Memory System
```

---

## 1. Knowledge Discovery: Official Wins

### Official
Claude uses AI semantic understanding to decide what's worth remembering. It reads the conversation, evaluates importance, and summarizes intelligently. No configuration needed.

### Three-Layer
Uses keyword matching (`if "postgres" in text.lower()`) to detect topics. The extraction logic is rule-based, not AI-powered. The quality gap is significant.

**Verdict**: Official is far superior at discovery. This is not a contest — AI understanding vs keyword matching is a different league entirely.

**But**: Discovery is only half the job. What happens *after* knowledge is recorded?

---

## 2. Knowledge Management: Three-Layer Wins

### Official
Claude writes to MEMORY.md. Content only grows. No mechanism to mark knowledge as outdated. Past 200 lines, content stops being loaded. No way to filter, query, or expire entries programmatically.

### Three-Layer
Every fact in `items.json` has a `status` field:
- `active` → loaded at session start
- `superseded` → kept for reference, not loaded

The `/memory-review` command scans all three layers for:
- **High-frequency**: Patterns that appear 3+ times → promote to rules
- **Trend**: Patterns concentrated in recent days → highlight
- **Decay**: Previously active patterns that disappeared → suggest cleanup

**Verdict**: Three-Layer provides the lifecycle management that official auto-memory lacks. Knowledge that expires needs a mechanism to expire.

---

## 3. Storage Architecture: Different Strengths

### Official
One file: `~/.claude/projects/<project>/memory/MEMORY.md` + topic files.

Simple, flat, human-readable. Claude auto-creates topic files (debugging.md, api-conventions.md) as needed. No schema to learn.

### Three-Layer
```
Layer 1 (JSON)  → Structured facts, filterable by status/topic
Layer 2 (MD)    → Daily timeline, append-only
Layer 3 (MD)    → Curated tacit knowledge
```

Each layer serves a different purpose. JSON enables programmatic filtering. Daily notes provide temporal context. Tacit knowledge captures the un-automatable.

**Verdict**: Official is simpler. Three-Layer is more powerful. Choose based on your needs.

---

## 4. Token Control: Predictable vs Variable

### Official
Loads first 200 lines of MEMORY.md. Token count depends entirely on content density. Combined with Skill metadata injection, actual consumption can be significant.

GitHub Issue #29178 reported: 8% of Max x5 quota consumed in 18 minutes of light conversation.

### Three-Layer
Budget: ~1500 tokens (configurable).
- Layer 1: Last 10 active items (~600 tokens)
- Layer 2: Last 3 days (~400 tokens)
- Layer 3: Full MEMORY.md (~300 tokens, kept concise)

Total: <1% of 200K context window.

**Verdict**: Three-Layer gives you a predictable, configurable token budget. Official's consumption varies.

---

## 5. Git Tracking & Team Sharing: Three-Layer Only

### Official
Files stored in `~/.claude/projects/<project-hash>/memory/`. Personal, local, invisible to git. Cannot be reviewed in PRs, synced across devices, or shared with teammates.

### Three-Layer
Files stored in `.claude/memory/` within the project directory. Naturally git-trackable, PR-reviewable, cross-device syncable, team-shareable.

**Verdict**: This is Three-Layer's unique and irreplaceable advantage. Official auto-memory cannot do this by design — it treats memory as personal. Three-Layer treats memory as a project asset.

---

## 6. Installation Cost: Official Wins

### Official
Upgrade to v2.1.59+. Done. Zero configuration.

### Three-Layer
```bash
curl -fsSL https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.sh | bash
```
One command. But still one more step than zero.

**Verdict**: Can't beat zero config. Official wins here, hands down.

---

## Summary Table

| Dimension | Official v2.1.59 | Three-Layer Memory | Best at |
|-----------|-------------------|-------------------|---------|
| Knowledge discovery | AI-powered (smart) | Keyword matching (rules) | Official |
| Setup | Zero config | One command | Official |
| Storage | Single MD + topic files | 3 specialized layers | Three-Layer |
| Format | Unstructured text | JSON + Markdown | Three-Layer |
| Lifecycle | Write-only | Active / Superseded | Three-Layer |
| Token budget | ~unknown (200 lines) | ~1500 (configurable) | Three-Layer |
| Git tracking | ❌ | ✅ | Three-Layer |
| Team sharing | ❌ | ✅ | Three-Layer |
| Cross-device | ❌ | ✅ (via git) | Three-Layer |
| Cleanup | ❌ | ✅ (/memory-review) | Three-Layer |
| Dependencies | None | Python 3.8+ stdlib | Official |

---

## Recommended Setup

**Use both:**

```
Official Auto-Memory (AI discovers knowledge)
       ↓ automatically writes to MEMORY.md
Your daily workflow (zero config, just use it)
       ↓
Three-Layer Memory (structured management)
       ↓ manually or semi-automatically curate
items.json (expirable, trackable, shareable)
```

1. **Official auto-memory** handles knowledge discovery — build commands, project structure, coding style, debugging patterns. Let Claude's AI figure out what matters.

2. **Three-Layer Memory** handles knowledge management — structured facts that need lifecycle control, git tracking for team sharing, precise token budgets, and periodic cleanup.

They don't conflict. Official writes to `~/.claude/projects/`. Three-Layer writes to `.claude/memory/`. Both load at session start independently.

**One discovers. One manages. Together, they're complete.**
