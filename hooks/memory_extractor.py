# -*- coding: utf-8 -*-
"""
Three-Layer Memory System - Memory Extractor

Extracts knowledge from conversations and saves to:
- Layer 1: items.json (structured facts with lifecycle)
- Layer 2: daily notes (what happened today)

Designed as a PostToolUse hook. Called after tool executions
to capture knowledge from the current session.

Zero dependencies — pure Python stdlib.
"""

import json
import os
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


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


def extract_topics(text: str) -> List[str]:
    """Extract topic keywords from conversation text.

    Override this function or set MEMORY_TOPICS env var to customize.
    Default: detects common programming/tool keywords.
    """
    custom_topics = os.environ.get("MEMORY_TOPICS", "")
    keywords_map: Dict[str, str] = {}

    if custom_topics:
        for pair in custom_topics.split(","):
            if ":" in pair:
                keyword, topic = pair.split(":", 1)
                keywords_map[keyword.strip().lower()] = topic.strip()

    # Default topic detection
    default_map = {
        "react": "react", "vue": "vue", "angular": "angular",
        "next": "nextjs", "nuxt": "nuxtjs",
        "python": "python", "django": "django", "flask": "flask",
        "fastapi": "fastapi", "typescript": "typescript",
        "docker": "docker", "kubernetes": "kubernetes",
        "postgres": "postgres", "redis": "redis", "mongodb": "mongodb",
        "api": "api-design", "auth": "authentication",
        "test": "testing", "deploy": "deployment",
        "ci/cd": "cicd", "pipeline": "cicd",
        "debug": "debugging", "performance": "performance",
        "security": "security", "refactor": "refactoring",
    }
    keywords_map.update(default_map)

    text_lower = text.lower()
    found = []
    for keyword, topic in keywords_map.items():
        if keyword in text_lower and topic not in found:
            found.append(topic)

    return found if found else ["general"]


def generate_fact_id() -> str:
    """Generate a unique fact ID based on timestamp."""
    return f"fact-{datetime.now().strftime('%Y%m%d%H%M%S')}"


def save_to_items_json(
    memory_dir: Path,
    topic: str,
    fact: str,
    metadata: Optional[Dict] = None
) -> Path:
    """Save a fact to the topic's items.json with lifecycle management.

    Args:
        memory_dir: Base memory directory
        topic: Topic folder name (e.g., "python", "api-design")
        fact: The knowledge fact to store
        metadata: Optional extra fields (category, source, etc.)

    Returns:
        Path to the updated items.json
    """
    items_dir = memory_dir / "areas" / "topics" / topic
    items_dir.mkdir(parents=True, exist_ok=True)
    items_file = items_dir / "items.json"

    items: List[Dict] = []
    if items_file.exists():
        try:
            with open(items_file, "r", encoding="utf-8") as f:
                items = json.load(f)
        except (json.JSONDecodeError, IOError):
            items = []

    fact_data = {
        "id": generate_fact_id(),
        "fact": fact,
        "timestamp": datetime.now().strftime("%Y-%m-%d"),
        "status": "active",
    }

    if metadata:
        fact_data.update(metadata)

    # Dedup: skip if identical fact already exists
    existing_facts = {item.get("fact", "") for item in items}
    if fact not in existing_facts:
        items.append(fact_data)

        with open(items_file, "w", encoding="utf-8") as f:
            json.dump(items, f, ensure_ascii=False, indent=2)

    return items_file


def update_daily_note(
    memory_dir: Path,
    summary: str,
    topics: Optional[List[str]] = None
) -> Path:
    """Append an entry to today's daily note.

    Args:
        memory_dir: Base memory directory
        summary: Summary text of what happened
        topics: Optional list of related topics

    Returns:
        Path to the updated daily note
    """
    today = datetime.now().strftime("%Y-%m-%d")
    notes_dir = memory_dir / "memory"
    notes_dir.mkdir(parents=True, exist_ok=True)
    note_file = notes_dir / f"{today}.md"

    if note_file.exists():
        content = note_file.read_text(encoding="utf-8")
    else:
        content = f"# {today}\n\n"

    now_time = datetime.now().strftime("%H:%M")
    entry = f"\n## {now_time}\n{summary}\n"
    if topics:
        entry += f"Topics: {', '.join(topics)}\n"

    content += entry
    note_file.write_text(content, encoding="utf-8")

    return note_file


def _extract_fact_from_text(text: str) -> str:
    """Extract meaningful content from raw text or JSON input.

    Tries to parse JSON and extract useful fields like 'output', 'result',
    'message', or 'content'. Falls back to plain text truncation.

    Args:
        text: Raw input text (may be JSON or plain text)

    Returns:
        Cleaned fact string, max 200 chars
    """
    # Try JSON parsing first
    try:
        data = json.loads(text)
        if isinstance(data, dict):
            # Look for meaningful content fields
            for key in ("output", "result", "message", "content", "fact", "summary"):
                val = data.get(key)
                if val and isinstance(val, str):
                    return val[:200].strip()
            # If no known field, try first string value
            for val in data.values():
                if isinstance(val, str) and len(val) > 10:
                    return val[:200].strip()
    except (json.JSONDecodeError, TypeError, ValueError):
        pass

    # Plain text: strip and truncate
    return text[:200].strip()


def extract_and_save(
    conversation_text: str = "",
    fact: str = "",
    topic: str = "",
    metadata: Optional[Dict] = None
) -> Dict:
    """Extract knowledge from conversation and save to memory.

    Can be called with explicit fact/topic, or will auto-detect from text.

    Args:
        conversation_text: Raw conversation text for auto-detection
        fact: Explicit fact to save (overrides auto-detection)
        topic: Explicit topic (overrides auto-detection)
        metadata: Extra metadata to attach to the fact

    Returns:
        Dict with success status and details
    """
    memory_dir = _get_memory_dir()

    if not fact and conversation_text:
        fact = _extract_fact_from_text(conversation_text)

    if not topic:
        topics = extract_topics(conversation_text or fact)
        topic = topics[0] if topics else "general"

    topics_found = extract_topics(conversation_text or fact)

    results = {"success": True, "topic": topic, "fact": fact}

    # Save to Layer 1: Knowledge graph
    try:
        items_file = save_to_items_json(memory_dir, topic, fact, metadata)
        results["layer1"] = f"Updated: {items_file.name}"
    except Exception as e:
        results["layer1_error"] = str(e)

    # Save to Layer 2: Daily note
    try:
        note_file = update_daily_note(memory_dir, fact, topics_found)
        results["layer2"] = f"Updated: {note_file.name}"
    except Exception as e:
        results["layer2_error"] = str(e)

    return results


def main():
    """Entry point for PostToolUse hook.

    Reads tool output from stdin (if available) and extracts knowledge.
    """
    input_text = ""
    if not sys.stdin.isatty():
        try:
            input_text = sys.stdin.read()
        except Exception:
            pass

    if input_text:
        result = extract_and_save(conversation_text=input_text)
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(json.dumps({"message": "No input to extract from."}, ensure_ascii=False))


if __name__ == "__main__":
    main()
