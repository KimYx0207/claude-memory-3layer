# -*- coding: utf-8 -*-
"""
Three-Layer Memory System - PreCompact Hook

Saves critical session state before context compression.
Prevents knowledge loss when conversation gets too long.

Zero dependencies — pure Python stdlib.
"""

import json
from datetime import datetime
from pathlib import Path

# Import from local session_state module
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from session_state import load_state, save_state


def main():
    """Save current state before context compression."""
    current_state = load_state()

    current_state["compact_saved_at"] = datetime.now().isoformat()
    current_state["compact_count"] = current_state.get("compact_count", 0) + 1

    save_state(current_state)

    result = {
        "message": f"[Memory] State saved before compression (#{current_state['compact_count']})",
        "continue": True,
    }

    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
