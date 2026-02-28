# -*- coding: utf-8 -*-
"""
Three-Layer Memory System - Session State Manager

Manages session lifecycle state (start/compact/end).
Stores state in .claude/data/session_state.json.

Zero dependencies — pure Python stdlib.
"""

import json
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Dict, List


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


def _get_state_file() -> Path:
    """Get session state file path."""
    root = _detect_project_root()
    return root / ".claude" / "data" / "session_state.json"


def ensure_data_dir() -> None:
    """Ensure data directory exists."""
    state_file = _get_state_file()
    state_file.parent.mkdir(parents=True, exist_ok=True)


def load_state() -> Dict:
    """Load the last saved session state."""
    state_file = _get_state_file()
    ensure_data_dir()
    if state_file.exists():
        try:
            with open(state_file, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError):
            return {}
    return {}


def save_state(state: Dict) -> None:
    """Save current session state."""
    state_file = _get_state_file()
    ensure_data_dir()
    state["last_updated"] = datetime.now().isoformat()
    with open(state_file, "w", encoding="utf-8") as f:
        json.dump(state, f, ensure_ascii=False, indent=2)


def get_working_context() -> str:
    """Get working context summary for session resume prompt."""
    state = load_state()
    if not state:
        return ""

    lines = ["[STATE] Last session:"]

    if state.get("last_task"):
        lines.append(f"- Task: {state['last_task']}")

    if state.get("working_files"):
        files = state["working_files"][:5]
        lines.append(f"- Files: {', '.join(files)}")

    if state.get("notes"):
        notes = state["notes"]
        if isinstance(notes, list):
            for n in notes[-3:]:
                lines.append(f"- Note: {n}")
        else:
            lines.append(f"- Notes: {notes}")

    if state.get("last_updated"):
        lines.append(f"- Updated: {state['last_updated']}")

    return "\n".join(lines) if len(lines) > 1 else ""


def update_working_files(files: List[str]) -> None:
    """Update the working files list (deduped, max 20)."""
    state = load_state()
    existing = state.get("working_files", [])
    combined = list(dict.fromkeys(files + existing))[:20]
    state["working_files"] = combined
    save_state(state)


def set_current_task(task: str) -> None:
    """Set the current task description."""
    state = load_state()
    state["last_task"] = task
    save_state(state)


def add_note(note: str) -> None:
    """Add a note to session state (keeps last 10)."""
    state = load_state()
    notes = state.get("notes", [])
    if isinstance(notes, str):
        notes = [notes] if notes else []
    notes.append(note)
    state["notes"] = notes[-10:]
    save_state(state)
