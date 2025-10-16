#!/bin/bash
set -e

# ==============================================================================
# Claude Code Configuration Setup
# ==============================================================================
#
# Claude Code uses:
#   - .claude/CLAUDE.md                Main configuration file
#   - .claude/commands/                Custom slash commands (supports nested folders)
#   - .claude/agents/                  Specialized agents
#   - .claude/output-styles/                 AI behavior profiles (personas)
#
# All of these use SYMLINKS for dynamic updates - no manual sync needed!
#
# ==============================================================================

echo "🔧 Setting up Claude Code configuration..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if .ai exists
if [ ! -d ".ai" ]; then
    echo -e "${YELLOW}⚠️  .ai folder not found. Run this from project root.${NC}"
    exit 1
fi

# Backup existing .claude folder if it exists
if [ -d ".claude" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR=".claude.backup_${TIMESTAMP}"

    echo -e "${YELLOW}⚠️  Existing .claude folder found. Backing up...${NC}"
    cp -r .claude "$BACKUP_DIR"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"

    # Copy any custom files from .claude to .ai (preserve user customizations)
    echo "📦 Preserving your custom files..."

    # Copy custom commands (if commands is a regular directory, not a symlink)
    if [ -d ".claude/commands" ] && [ ! -L ".claude/commands" ]; then
        find .claude/commands -type f -name "*.md" 2>/dev/null | while read file; do
            relative_path="${file#.claude/commands/}"
            target_dir=".ai/commands/$(dirname "$relative_path")"
            mkdir -p "$target_dir"
            cp "$file" "$target_dir/"
            echo -e "${GREEN}✓${NC} Copied custom command: $relative_path"
        done
    fi

    # Copy custom agents (if agents is a regular directory, not a symlink)
    if [ -d ".claude/agents" ] && [ ! -L ".claude/agents" ]; then
        find .claude/agents -type f -name "*.md" 2>/dev/null | while read file; do
            cp "$file" .ai/agents/
            echo -e "${GREEN}✓${NC} Copied custom agent: $(basename "$file")"
        done
    fi

    # Copy custom avatars (if avatars is a regular directory, not a symlink)
    if [ -d ".claude/output-styles" ] && [ ! -L ".claude/output-styles" ]; then
        find .claude/output-styles -type f -name "*.md" 2>/dev/null | while read file; do
            cp "$file" .ai/avatars/
            echo -e "${GREEN}✓${NC} Copied custom avatar: $(basename "$file")"
        done
    fi

    # Remove old .claude folder
    rm -rf .claude
    echo -e "${GREEN}✓${NC} Old .claude folder removed"
fi

# Create .claude directory structure
mkdir -p .claude

echo "📋 Setting up Claude Code symlinks..."

# Symlink CLAUDE.md (main config)
if [ -f ".ai/AGENTS.md" ]; then
    ln -sf ../.ai/AGENTS.md .claude/CLAUDE.md
    echo -e "${GREEN}✓${NC} Linked .claude/CLAUDE.md → .ai/AGENTS.md"
fi

# Symlink commands folder
if [ -d ".ai/commands" ]; then
    ln -sf ../.ai/commands .claude/commands
    echo -e "${GREEN}✓${NC} Linked .claude/commands/ → .ai/commands/"
fi

# Symlink agents folder
if [ -d ".ai/agents" ]; then
    ln -sf ../.ai/agents .claude/agents
    echo -e "${GREEN}✓${NC} Linked .claude/agents/ → .ai/agents/"
fi

# Symlink avatars folder
if [ -d ".ai/avatars" ]; then
    ln -sf ../.ai/avatars .claude/output-styles
    echo -e "${GREEN}✓${NC} Linked .claude/output-styles/ → .ai/avatars/"
fi

# Copy settings.json if it exists in templates
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/settings.json" ]; then
    cp "$SCRIPT_DIR/settings.json" .claude/settings.json
    echo -e "${GREEN}✓${NC} Copied settings.json → .claude/settings.json"
fi

echo ""
echo -e "${BLUE}✅ Claude Code setup complete!${NC}"
echo ""
echo "Structure created:"
echo "  .claude/CLAUDE.md                → .ai/AGENTS.md"
echo "  .claude/commands/                → .ai/commands/"
echo "  .claude/agents/                  → .ai/agents/"
echo "  .claude/output-styles/           → .ai/avatars/"
echo "  .claude/settings.json            (copied from templates)"
echo ""
echo "✨ Dynamic updates: Add files to .ai/ and they appear automatically in .claude/!"
echo ""
echo "Reference context with:"
echo "  @.ai/context/architecture.md"
