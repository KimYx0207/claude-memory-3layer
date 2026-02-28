# Three-Layer Memory System for Claude Code

<div align="center">

![GitHub stars](https://img.shields.io/github/stars/KimYx0207/claude-memory-3layer?style=social)
![GitHub forks](https://img.shields.io/github/forks/KimYx0207/claude-memory-3layer?style=social)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Claude Code](https://img.shields.io/badge/Claude_Code-v2.1%2B-blueviolet.svg)
![Python](https://img.shields.io/badge/Python-3.8%2B-green.svg)
![Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen.svg)

**Give Claude Code a real memory — structured, git-trackable, and token-efficient.**

</div>

> :brain: **The management layer that official auto-memory doesn't have**

> :zap: One-command install | Zero dependencies | ~1500 tokens budget

> :handshake: Coexists with official auto-memory (v2.1.59+) — they complement each other

> :link: **GitHub**: [https://github.com/KimYx0207/claude-memory-3layer](https://github.com/KimYx0207/claude-memory-3layer)

> [Chinese Version / 中文版本](README_CN.md)

---

## :telephone_receiver: Contact

<div align="center">
  <img src="images/二维码基础款.png" alt="Contact" width="600"/>
  <p><strong>Get more AI tips and technical support</strong></p>
  <p>
    :globe_with_meridians: <a href="https://www.aiking.dev/">aiking.dev</a> | :bird: <a href="https://x.com/KimYx0207">@KimYx0207</a> | WeChat Official Account: <strong>老金带你玩AI</strong>
  </p>
</div>

### :coffee: Buy Me a Coffee

<div align="center">
  <p><strong>If this project helped you, consider supporting it!</strong></p>
  <table align="center">
    <tr>
      <td align="center">
        <img src="images/微信.jpg" alt="WeChat Pay" width="300"/>
        <br/>
        <strong>WeChat Pay</strong>
      </td>
      <td align="center">
        <img src="images/支付宝.jpg" alt="Alipay" width="300"/>
        <br/>
        <strong>Alipay</strong>
      </td>
    </tr>
  </table>
</div>

---

## :book: Why This Exists

Claude Code forgets everything between sessions. Anthropic provides two solutions:

- **CLAUDE.md** — manual rules file, you write and maintain it
- **Auto-memory (v2.1.59+)** — AI-powered, Claude decides what to remember

Official auto-memory solves **knowledge discovery** brilliantly. But discovery is only half the problem.

**The other half — lifecycle management, git tracking, team sharing, precise token control — is what this project handles.**

This is not a replacement. It's the management layer that official auto-memory doesn't have. Use both together.

### :dna: Official + Three-Layer: Better Together

| Dimension | Official v2.1.59 | Three-Layer Memory | Best for |
|-----------|-------------------|-------------------|----------|
| Knowledge discovery | AI semantic understanding | Keyword matching (rules) | Official wins |
| Install cost | Zero config | One command | Official wins |
| Storage format | Markdown (flat text + topic files) | 3 layers (JSON + MD + MD) | Three-Layer more flexible |
| Git tracking | :x: `~/.claude/projects/` (hidden) | :white_check_mark: `.claude/memory/` (in project) | Three-Layer only |
| Lifecycle | Write-only, grows forever | `status` field (active/superseded) | Three-Layer only |
| Token control | Truncate at 200 lines (unknown tokens) | ~1500 tokens per topic (configurable) | Three-Layer more predictable |
| Team sharing | :x: Local only | :white_check_mark: Via git | Three-Layer only |
| Knowledge cleanup | :x: None | :white_check_mark: Auto-suggest via `/memory-review` | Three-Layer only |

---

## :sparkles: Core Features

- :brain: **Three-Layer Architecture** — Knowledge Graph (JSON) + Daily Notes (MD) + Tacit Knowledge (MD)
- :recycle: **Lifecycle Management** — Facts can expire (`active` → `superseded`), keeps knowledge lean
- :git: **Git-Trackable** — All memory lives in `.claude/memory/`, commit and share with your team
- :dart: **Token-Efficient** — ~1500 tokens per topic (<1% of 200K context), fully configurable
- :package: **Zero Dependencies** — Pure Python stdlib, no pip install needed
- :electric_plug: **Hook-Powered** — SessionStart / PostToolUse / PreCompact lifecycle hooks
- :broom: **Smart Cleanup** — `/memory-review` finds outdated entries and suggests cleanup
- :handshake: **Coexists with Official** — Works alongside auto-memory and CLAUDE.md

---

## :rocket: Quick Start

### One-Line Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.sh | bash

# Windows PowerShell
irm https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.ps1 | iex
```

### Manual Install

```bash
git clone https://github.com/KimYx0207/claude-memory-3layer.git
cd claude-memory-3layer
./install.sh   # or .\install.ps1 on Windows
```

### What Gets Installed

```
your-project/
└── .claude/
    ├── hooks/
    │   ├── memory_loader.py      # SessionStart: load 3 layers
    │   ├── memory_extractor.py   # PostToolUse: extract knowledge
    │   ├── session_state.py      # State management
    │   └── pre_compact.py        # PreCompact: save before compression
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

## :gear: How It Works

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
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
│  (State auto-persisted via PreCompact for next session)      │
└─────────────────────────────────────────────────────────────┘
```

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
│  │ per topic │  │           │  │               │  │
│  └──────────┘  └──────────┘  └──────────────┘  │
│        │              │              │           │
│        └──────────────┴──────────────┘           │
│                       │                          │
│         ~1500 tokens per topic                   │
│         (<1% of 200K context)                    │
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

## :wrench: Hook Registration

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

## :hammer_and_wrench: Commands

### `/memory-review`

Periodic knowledge hygiene — find patterns worth promoting, and outdated entries worth cleaning up.

- Scans all 3 layers for recurring patterns (high-frequency, trending, decaying)
- Suggests promoting patterns to `CLAUDE.md` as permanent rules
- Suggests marking outdated entries as `superseded`
- Both "add" and "remove" — keeps your knowledge base lean

### `/memory-status`

Show memory system statistics — item counts, date ranges, token estimates.

---

## :control_knobs: Configuration

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

## :recycle: Lifecycle Management

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

## :chart_with_upwards_trend: Token Budget Analysis

The system is designed to stay under ~1500 tokens at session start (single topic):

| Component | Estimated Tokens |
|-----------|-----------------|
| Layer 3 (MEMORY.md, typical) | ~300 |
| Layer 2 (3 days x ~3 entries) | ~400 |
| Layer 1 (10 facts per topic x ~15 words) | ~600 |
| Headers and formatting | ~100 |
| **Total (single topic)** | **~1400** |

Multiple topics scale linearly. Configure via `MEMORY_MAX_ITEMS` env var.

This is <1% of Claude's 200K context window.

---

## :white_check_mark: Compatibility

- **Claude Code**: v2.1.0+ (hooks support required)
- **Python**: 3.8+ (stdlib only, zero dependencies)
- **OS**: macOS, Linux, Windows
- **Coexists with**: Official auto-memory (v2.1.59+), CLAUDE.md

---

## :file_folder: Project Structure

```
claude-memory-3layer/
├── SKILL.md              # Claude Code Skill manifest
├── README.md             # English documentation
├── README_CN.md          # Chinese documentation
├── LICENSE               # MIT
├── install.sh            # Unix/macOS installer
├── install.ps1           # Windows installer
├── images/               # Images and QR codes
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

## :bar_chart: Project Statistics

| Metric | Value |
|--------|-------|
| **Hook Scripts** | 3 (SessionStart, PostToolUse, PreCompact) + 1 utility (session_state) |
| **Memory Layers** | 3 (Knowledge Graph + Daily Notes + Tacit Knowledge) |
| **Commands** | 2 (`/memory-review`, `/memory-status`) |
| **Dependencies** | 0 (pure Python stdlib) |
| **Token Budget** | ~1500 per topic (configurable) |
| **Python Version** | 3.8+ |
| **Claude Code Version** | v2.1.0+ (tested on v2.1.59) |

---

## :busts_in_silhouette: Target Users

- :white_check_mark: **Claude Code power users** — Want structured, persistent memory across sessions
- :white_check_mark: **Team developers** — Need git-trackable, shared knowledge base
- :white_check_mark: **Token-conscious users** — Want precise control over context window usage
- :white_check_mark: **Multi-project developers** — Need per-project knowledge management
- :white_check_mark: **DIY enthusiasts** — Want full control over what Claude remembers

---

## :handshake: Contributing

Issues and PRs welcome! Please:

1. Keep zero-dependency policy (Python stdlib only)
2. Test on macOS + Windows
3. Follow existing code style

---

## :page_facing_up: License

This project is licensed under the [MIT License](LICENSE).

---

## :pray: Acknowledgments

- [Anthropic](https://www.anthropic.com/) for building Claude Code
- The Claude Code community for feedback and ideas
- Everyone who contributed to the official auto-memory discussion

---

## :bust_in_silhouette: Author

**KimYx0207** (老金 / LaojinAI) — Building tools for Claude Code power users.

<div align="center">
  <p>
    :globe_with_meridians: <a href="https://www.aiking.dev/">aiking.dev</a> | :bird: <a href="https://x.com/KimYx0207">@KimYx0207</a> | WeChat: <strong>老金带你玩AI</strong>
  </p>
</div>

---

## :memo: Changelog

### v1.0.0 (2026-02-27) — Initial Release

- Three-layer memory architecture (Knowledge Graph + Daily Notes + Tacit Knowledge)
- 3 lifecycle hooks (SessionStart, PostToolUse, PreCompact) + 1 utility module (session_state)
- One-command installer for macOS/Linux/Windows
- `/memory-review` and `/memory-status` commands
- Complementary design with official auto-memory (v2.1.59+)
- Zero dependencies (pure Python stdlib)
- Full documentation (quickstart, architecture, comparison)
