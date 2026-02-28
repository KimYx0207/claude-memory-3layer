# -*- coding: utf-8 -*-
"""
Three-Layer Memory System - Memory Loader

Loads three layers of memory at session start:
- Layer 1: Knowledge graph (JSON, topic-based, status-filtered)
- Layer 2: Daily notes (Markdown, last 3 days)
- Layer 3: Tacit knowledge (Markdown, full file)

Zero dependencies — pure Python stdlib.
"""

import json
import os
import subprocess
from datetime import datetime, timedelta
from pathlib import Path


def _detect_project_root() -> Path:
    """Detect project root via git, fall back to cwd."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5
        )
        if result.returncode == 0:
            return Path(result.stdout.strip())
    except (subprocess.SubprocessError, FileNotFoundError):
        pass
    return Path.cwd()


def _get_memory_dir() -> Path:
    """Get memory directory path. Supports env override."""
    if os.environ.get("MEMORY_DIR"):
        return Path(os.environ["MEMORY_DIR"])
    return _detect_project_root() / ".claude" / "memory"


# Token budget config
MAX_ACTIVE_ITEMS = int(os.environ.get("MEMORY_MAX_ITEMS", "10"))
MAX_DAILY_NOTES_DAYS = int(os.environ.get("MEMORY_DAILY_DAYS", "3"))


def load_layer3_memory(memory_dir: Path) -> str:
    """Load Layer 3: Tacit knowledge (MEMORY.md)."""
    memory_file = memory_dir / "MEMORY.md"
    if memory_file.exists():
        content = memory_file.read_text(encoding="utf-8").strip()
        if content:
            return f"\n## Layer 3: Tacit Knowledge\n{content}\n"
    return ""


def load_layer2_daily_notes(memory_dir: Path) -> str:
    """Load Layer 2: Recent daily notes (last N days)."""
    notes_dir = memory_dir / "memory"
    if not notes_dir.exists():
        return ""

    parts = []
    for i in range(MAX_DAILY_NOTES_DAYS):
        date_str = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
        note_file = notes_dir / f"{date_str}.md"
        if note_file.exists():
            content = note_file.read_text(encoding="utf-8").strip()
            if content:
                parts.append(f"### {date_str}\n{content}")

    if parts:
        return "\n## Layer 2: Recent Notes\n\n" + "\n\n".join(parts) + "\n"
    return ""


def load_layer1_knowledge_graph(memory_dir: Path) -> str:
    """Load Layer 1: Knowledge graph (last N active items per topic)."""
    topics_dir = memory_dir / "areas" / "topics"
    if not topics_dir.exists():
        return ""

    parts = []
    for topic_folder in sorted(topics_dir.iterdir()):
        if not topic_folder.is_dir():
            continue

        items_file = topic_folder / "items.json"
        if not items_file.exists():
            continue

        try:
            with open(items_file, "r", encoding="utf-8") as f:
                items = json.load(f)
        except (json.JSONDecodeError, IOError):
            continue

        active_items = [i for i in items if i.get("status") == "active"]
        active_items.sort(key=lambda x: x.get("timestamp", ""), reverse=False)
        recent = active_items[-MAX_ACTIVE_ITEMS:]

        if recent:
            topic_name = topic_folder.name
            lines = [f"#### {topic_name} ({len(recent)} items)"]
            for item in recent:
                fact = item.get("fact", "unknown")
                lines.append(f"- {fact}")
            parts.append("\n".join(lines))

    if parts:
        return "\n## Layer 1: Knowledge Graph\n\n" + "\n\n".join(parts) + "\n"
    return ""


def load_memory_context() -> str:
    """Load complete three-layer memory context.

    Returns formatted string ready for injection into session context.
    Token budget: ~1500 tokens (10 items + 3 days notes + MEMORY.md).
    """
    memory_dir = _get_memory_dir()

    if not memory_dir.exists():
        return ""

    context_parts = []

    layer3 = load_layer3_memory(memory_dir)
    if layer3:
        context_parts.append(layer3)

    layer2 = load_layer2_daily_notes(memory_dir)
    if layer2:
        context_parts.append(layer2)

    layer1 = load_layer1_knowledge_graph(memory_dir)
    if layer1:
        context_parts.append(layer1)

    if context_parts:
        header = "\n" + "=" * 50 + "\n"
        header += "Memory System Loaded (3-Layer)"
        header += "\n" + "=" * 50
        return header + "\n".join(context_parts)

    return ""


def main():
    """Entry point for SessionStart hook."""
    context = load_memory_context()
    if context:
        result = {"message": context, "continue": True}
    else:
        result = {"message": "[Memory] No memories found.", "continue": True}

    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
