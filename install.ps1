# ============================================================
# Three-Layer Memory System — Windows Installer (PowerShell)
# One-line install:
#   irm https://raw.githubusercontent.com/KimYx0207/claude-memory-3layer/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "  Three-Layer Memory System for Claude Code" -ForegroundColor Cyan
Write-Host "  v1.0.0 - by LaojinAI" -ForegroundColor DarkCyan
Write-Host ""

# Check Python availability
$PythonCmd = ""
if (Get-Command python3 -ErrorAction SilentlyContinue) {
    $PythonCmd = "python3"
} elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $PythonCmd = "python"
} else {
    Write-Host "  [X] Python not found. Please install Python 3.8+ first." -ForegroundColor Red
    exit 1
}
$pyVersion = & $PythonCmd --version 2>&1
Write-Host "  [OK] Python found: $PythonCmd ($pyVersion)" -ForegroundColor Green

# Detect project root
$ProjectRoot = ""
try {
    $gitRoot = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0 -and $gitRoot) {
        $ProjectRoot = $gitRoot.Trim()
        Write-Host "  [OK] Git repo: $ProjectRoot" -ForegroundColor Green
    }
} catch {}

if (-not $ProjectRoot) {
    $ProjectRoot = Get-Location
    Write-Host "  [!] No git repo, using: $ProjectRoot" -ForegroundColor Yellow
}

$ClaudeDir = Join-Path $ProjectRoot ".claude"
$MemoryDir = Join-Path $ClaudeDir "memory"
$HooksDir = Join-Path $ClaudeDir "hooks"
$CommandsDir = Join-Path $ClaudeDir "commands"
$DataDir = Join-Path $ClaudeDir "data"

# Determine source
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Get-Location }
$LocalSource = Join-Path $ScriptDir "hooks" "memory_loader.py"
$SourceDir = ""

if (Test-Path $LocalSource) {
    $SourceDir = $ScriptDir
    Write-Host "  [OK] Installing from local: $SourceDir" -ForegroundColor Green
} else {
    $SourceDir = Join-Path $env:TEMP "claude-memory-3layer"
    Write-Host "  [..] Downloading from GitHub..." -ForegroundColor Blue
    if (Test-Path $SourceDir) { Remove-Item $SourceDir -Recurse -Force }
    git clone --depth 1 https://github.com/KimYx0207/claude-memory-3layer.git $SourceDir 2>$null
    if (-not (Test-Path (Join-Path $SourceDir "hooks" "memory_loader.py"))) {
        Write-Host "  [X] Download failed. Check network." -ForegroundColor Red
        exit 1
    }
}

# Create directories
Write-Host ""
Write-Host "  Creating directories..." -ForegroundColor Blue
$dirs = @(
    (Join-Path $MemoryDir "memory"),
    (Join-Path $MemoryDir "areas" "topics" "general"),
    $HooksDir,
    $CommandsDir,
    $DataDir
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
Write-Host "  [OK] Directories created" -ForegroundColor Green

# Copy hooks
Write-Host ""
Write-Host "  Installing hooks..." -ForegroundColor Blue
$hookFiles = @("memory_loader.py", "memory_extractor.py", "session_state.py", "pre_compact.py")
foreach ($f in $hookFiles) {
    Copy-Item (Join-Path $SourceDir "hooks" $f) (Join-Path $HooksDir $f) -Force
    Write-Host "  [OK] $f" -ForegroundColor Green
}

# Copy commands
Write-Host ""
Write-Host "  Installing commands..." -ForegroundColor Blue
$cmdFiles = @("memory-review.md", "memory-status.md")
foreach ($f in $cmdFiles) {
    Copy-Item (Join-Path $SourceDir "commands" $f) (Join-Path $CommandsDir $f) -Force
    Write-Host "  [OK] $f" -ForegroundColor Green
}

# Copy templates (skip if exist)
Write-Host ""
Write-Host "  Setting up templates..." -ForegroundColor Blue
$memoryMd = Join-Path $MemoryDir "MEMORY.md"
if (-not (Test-Path $memoryMd)) {
    Copy-Item (Join-Path $SourceDir "templates" "MEMORY.md") $memoryMd
    Write-Host "  [OK] MEMORY.md template" -ForegroundColor Green
} else {
    Write-Host "  [->] MEMORY.md exists, skipping" -ForegroundColor Yellow
}

$itemsJson = Join-Path $MemoryDir "areas" "topics" "general" "items.json"
if (-not (Test-Path $itemsJson)) {
    Copy-Item (Join-Path $SourceDir "templates" "items.json") $itemsJson
    Write-Host "  [OK] items.json template" -ForegroundColor Green
} else {
    Write-Host "  [->] items.json exists, skipping" -ForegroundColor Yellow
}

# Register hooks
Write-Host ""
Write-Host "  Registering hooks..." -ForegroundColor Blue
$settingsFile = Join-Path $ClaudeDir "settings.json"
if (-not (Test-Path $settingsFile)) {
    $settings = @"
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$PythonCmd .claude/hooks/memory_loader.py"
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
            "command": "$PythonCmd .claude/hooks/memory_extractor.py"
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
            "command": "$PythonCmd .claude/hooks/pre_compact.py"
          }
        ]
      }
    ]
  }
}
"@
    Set-Content -Path $settingsFile -Value $settings -Encoding UTF8
    Write-Host "  [OK] settings.json created with hooks" -ForegroundColor Green
} else {
    Write-Host "  [!] settings.json exists. Add hooks manually:" -ForegroundColor Yellow
    Write-Host "    SessionStart → $PythonCmd .claude/hooks/memory_loader.py"
    Write-Host "    PostToolUse  → $PythonCmd .claude/hooks/memory_extractor.py"
    Write-Host "    PreCompact   → $PythonCmd .claude/hooks/pre_compact.py"
}

# Cleanup
if ($SourceDir -ne $ScriptDir -and (Test-Path $SourceDir)) {
    Remove-Item $SourceDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "  Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Memory:   .claude/memory/" -ForegroundColor Cyan
Write-Host "  Hooks:    .claude/hooks/" -ForegroundColor Cyan
Write-Host "  Commands: /memory-review, /memory-status" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Start a new Claude Code session to test!" -ForegroundColor White
Write-Host ""
