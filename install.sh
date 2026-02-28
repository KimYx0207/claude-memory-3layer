#!/bin/bash
# ============================================================
# Three-Layer Memory System — Installer
# One-line install:
#   curl -fsSL https://raw.githubusercontent.com/laojin-ai/claude-memory-3layer/main/install.sh | bash
# ============================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════╗"
echo "║  Three-Layer Memory System for Claude Code   ║"
echo "║  v1.0.0 — by LaojinAI                       ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"

# Check Python availability
PYTHON_CMD=""
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}✗${NC} Python not found. Please install Python 3.8+ first."
    exit 1
fi
echo -e "${GREEN}✓${NC} Python found: ${PYTHON_CMD} ($(${PYTHON_CMD} --version 2>&1))"

# Detect project root
PROJECT_ROOT=""
if git rev-parse --show-toplevel &>/dev/null; then
    PROJECT_ROOT=$(git rev-parse --show-toplevel)
    echo -e "${GREEN}✓${NC} Git repo detected: ${PROJECT_ROOT}"
else
    PROJECT_ROOT=$(pwd)
    echo -e "${YELLOW}⚠${NC} No git repo found, using current directory: ${PROJECT_ROOT}"
fi

CLAUDE_DIR="${PROJECT_ROOT}/.claude"
MEMORY_DIR="${CLAUDE_DIR}/memory"
HOOKS_DIR="${CLAUDE_DIR}/hooks"
COMMANDS_DIR="${CLAUDE_DIR}/commands"
DATA_DIR="${CLAUDE_DIR}/data"

# Check for existing installation
if [ -f "${HOOKS_DIR}/memory_loader.py" ]; then
    echo -e "${YELLOW}⚠${NC} Existing memory_loader.py detected!"
    if [ -t 0 ]; then
        read -p "  Overwrite? (y/N): " -n 1 -r
        echo
    else
        read -p "  Overwrite? (y/N): " -n 1 -r < /dev/tty
        echo
    fi
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}✗${NC} Installation cancelled."
        exit 1
    fi
fi

# Determine source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/hooks/memory_loader.py" ]; then
    SOURCE_DIR="${SCRIPT_DIR}"
    echo -e "${GREEN}✓${NC} Installing from local: ${SOURCE_DIR}"
else
    # Download from GitHub
    SOURCE_DIR=$(mktemp -d)
    echo -e "${BLUE}↓${NC} Downloading from GitHub..."
    if command -v git &>/dev/null; then
        git clone --depth 1 https://github.com/laojin-ai/claude-memory-3layer.git "${SOURCE_DIR}" 2>/dev/null
    else
        echo -e "${RED}✗${NC} git not found. Please install git first."
        exit 1
    fi
fi

# Create directories
echo -e "\n${BLUE}Creating directories...${NC}"
mkdir -p "${MEMORY_DIR}/memory"
mkdir -p "${MEMORY_DIR}/areas/topics/general"
mkdir -p "${HOOKS_DIR}"
mkdir -p "${COMMANDS_DIR}"
mkdir -p "${DATA_DIR}"

echo -e "  ${GREEN}✓${NC} ${MEMORY_DIR}/"
echo -e "  ${GREEN}✓${NC} ${HOOKS_DIR}/"
echo -e "  ${GREEN}✓${NC} ${COMMANDS_DIR}/"

# Copy hooks
echo -e "\n${BLUE}Installing hooks...${NC}"
cp "${SOURCE_DIR}/hooks/memory_loader.py" "${HOOKS_DIR}/memory_loader.py"
cp "${SOURCE_DIR}/hooks/memory_extractor.py" "${HOOKS_DIR}/memory_extractor.py"
cp "${SOURCE_DIR}/hooks/session_state.py" "${HOOKS_DIR}/session_state.py"
cp "${SOURCE_DIR}/hooks/pre_compact.py" "${HOOKS_DIR}/pre_compact.py"
echo -e "  ${GREEN}✓${NC} memory_loader.py (SessionStart)"
echo -e "  ${GREEN}✓${NC} memory_extractor.py (PostToolUse)"
echo -e "  ${GREEN}✓${NC} session_state.py (State management)"
echo -e "  ${GREEN}✓${NC} pre_compact.py (PreCompact)"

# Copy commands
echo -e "\n${BLUE}Installing commands...${NC}"
cp "${SOURCE_DIR}/commands/memory-review.md" "${COMMANDS_DIR}/memory-review.md"
cp "${SOURCE_DIR}/commands/memory-status.md" "${COMMANDS_DIR}/memory-status.md"
echo -e "  ${GREEN}✓${NC} /memory-review"
echo -e "  ${GREEN}✓${NC} /memory-status"

# Copy templates (only if files don't exist)
echo -e "\n${BLUE}Setting up templates...${NC}"
if [ ! -f "${MEMORY_DIR}/MEMORY.md" ]; then
    cp "${SOURCE_DIR}/templates/MEMORY.md" "${MEMORY_DIR}/MEMORY.md"
    echo -e "  ${GREEN}✓${NC} MEMORY.md (Layer 3 template)"
else
    echo -e "  ${YELLOW}→${NC} MEMORY.md already exists, skipping"
fi

if [ ! -f "${MEMORY_DIR}/areas/topics/general/items.json" ]; then
    cp "${SOURCE_DIR}/templates/items.json" "${MEMORY_DIR}/areas/topics/general/items.json"
    echo -e "  ${GREEN}✓${NC} items.json (Layer 1 template)"
else
    echo -e "  ${YELLOW}→${NC} items.json already exists, skipping"
fi

# Register hooks in settings.json
echo -e "\n${BLUE}Registering hooks...${NC}"

SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
if [ -f "${SETTINGS_FILE}" ]; then
    echo -e "  ${YELLOW}⚠${NC} settings.json already exists."
    echo -e "  ${YELLOW}→${NC} Please manually add hooks to your settings.json:"
else
    # Create minimal settings.json with hooks registered
    cat > "${SETTINGS_FILE}" << SETTINGS_EOF
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "${PYTHON_CMD} .claude/hooks/memory_loader.py"
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
            "command": "${PYTHON_CMD} .claude/hooks/memory_extractor.py"
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
            "command": "${PYTHON_CMD} .claude/hooks/pre_compact.py"
          }
        ]
      }
    ]
  }
}
SETTINGS_EOF
    echo -e "  ${GREEN}✓${NC} Created settings.json with hooks registered"
fi

echo -e "\n${BLUE}Hook registration format (for manual setup):${NC}"
cat << HOOKINFO

  Add to .claude/settings.json → "hooks":

  "SessionStart": [{
    "matcher": "",
    "hooks": [{"type": "command", "command": "${PYTHON_CMD} .claude/hooks/memory_loader.py"}]
  }],
  "PostToolUse": [{
    "matcher": "",
    "hooks": [{"type": "command", "command": "${PYTHON_CMD} .claude/hooks/memory_extractor.py"}]
  }],
  "PreCompact": [{
    "matcher": "",
    "hooks": [{"type": "command", "command": "${PYTHON_CMD} .claude/hooks/pre_compact.py"}]
  }]

HOOKINFO

# Update .gitignore
echo -e "${BLUE}Updating .gitignore...${NC}"
GITIGNORE="${PROJECT_ROOT}/.gitignore"
if [ -f "${GITIGNORE}" ]; then
    if ! grep -q "session_state.json" "${GITIGNORE}" 2>/dev/null; then
        echo -e "\n# Three-Layer Memory (keep memory, ignore state)" >> "${GITIGNORE}"
        echo ".claude/data/session_state.json" >> "${GITIGNORE}"
        echo -e "  ${GREEN}✓${NC} Added session_state.json to .gitignore"
    fi
else
    echo -e "# Three-Layer Memory (keep memory, ignore state)" > "${GITIGNORE}"
    echo ".claude/data/session_state.json" >> "${GITIGNORE}"
    echo -e "  ${GREEN}✓${NC} Created .gitignore"
fi

# Cleanup temp dir
if [ "${SOURCE_DIR}" != "${SCRIPT_DIR}" ]; then
    rm -rf "${SOURCE_DIR}"
fi

# Done
echo -e "\n${GREEN}"
echo "╔══════════════════════════════════════════════╗"
echo "║  ✅ Installation complete!                    ║"
echo "╠══════════════════════════════════════════════╣"
echo "║                                              ║"
echo "║  Memory dir: .claude/memory/                 ║"
echo "║  Hooks:      .claude/hooks/                  ║"
echo "║  Commands:   /memory-review, /memory-status  ║"
echo "║                                              ║"
echo "║  Start a new Claude Code session to test!    ║"
echo "║  You should see 'Memory System Loaded'       ║"
echo "║                                              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${NC}"
