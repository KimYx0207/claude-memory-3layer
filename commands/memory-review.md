---
name: memory-review
description: "\U0001F9E0 Memory Review - Review recent memories, extract patterns, suggest permanent rules"
version: 1.0.0
---

# Memory Review

Review the three-layer memory system, find recurring patterns, and suggest promoting them to permanent rules in CLAUDE.md.

**Language**: Auto-detect the user's input language and output the entire report in that same language. If the user speaks Chinese, output in Chinese. If English, output in English.

## Steps

### Step 1: Scan All Three Layers

1. **Layer 1 Knowledge Graph**
   - Read all `items.json` files under `.claude/memory/areas/topics/`
   - Count active records per topic
   - Find highest-frequency patterns (tools, frameworks, conventions)

2. **Layer 2 Daily Notes**
   - Read daily notes from `.claude/memory/memory/` (last 7 days)
   - Extract recurring work patterns

3. **Layer 3 Tacit Knowledge**
   - Read `.claude/memory/MEMORY.md`
   - Check for missing important experiences

### Step 2: Pattern Recognition

Analyze scan results and identify three types of patterns:

**High-frequency patterns** (appeared 3+ times)
- Repeatedly used tool/command combinations
- Recurring coding style preferences
- Repeatedly corrected errors of the same type

**Trend patterns** (concentrated recently)
- Recently adopted new tools or libraries
- Recently focused work areas
- Recently preferred approaches

**Decay patterns** (previously active, now absent)
- Suggest changing status to `superseded`
- Clean up outdated knowledge entries

### Step 3: Output Report

Format:

```markdown
## Memory Review Report

**Scan range**: [date range]
**Total records**: [count]
**Active records**: [count]

### High-Frequency Patterns

| Pattern | Occurrences | Suggested Action |
|---------|-------------|-----------------|
| [description] | [count] | Promote to rule / Keep as-is |

### Suggested Permanent Rules

1. **[Rule description]**
   Source: [which records support this conclusion]
   Write to: CLAUDE.md / MEMORY.md

### Suggested Cleanup

1. **[Entry description]**
   Reason: [why it's outdated]
   Action: Change status to `superseded`
```

### Step 4: Confirm & Execute

After listing all suggestions, wait for user confirmation:
- On confirm: automatically write rules to the target file
- On confirm: automatically mark outdated entries as `superseded`
- User can selectively accept or reject each suggestion

## What Makes This Different

This command scans all 3 memory layers (not just a single file) and performs three-dimensional analysis:

| Dimension | What it does |
|-----------|-------------|
| Data source | All 3 layers scanned (knowledge graph + daily notes + tacit knowledge) |
| Analysis | High-frequency + Trend + Decay (3D pattern recognition) |
| Output | CLAUDE.md or MEMORY.md (your choice) |
| Cleanup | Auto-suggest outdated entries for `superseded` marking |
