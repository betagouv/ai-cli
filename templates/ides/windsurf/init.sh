#!/bin/bash
set -e

# ==============================================================================
# Windsurf IDE Configuration Setup
# ==============================================================================
#
# Windsurf uses (Wave 8+):
#   - .windsurf/rules/*.md             Markdown files with AI rules
#   - .windsurfrules                   Legacy format (still supported)
#
# Windsurf reads all .md files in .windsurf/rules/ with configurable modes:
#   - Always On: Rule always applied
#   - Manual: Activate with @mention
#   - Model Decision: AI decides when to apply
#
# Character limits:
#   - Individual file: 6,000 characters
#   - Total combined: 12,000 characters
#
# We use SYMLINKS so any changes to .ai/ are immediately available.
#
# ==============================================================================

echo "🔧 Setting up Windsurf configuration..."

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

# Backup existing .windsurf folder if it exists
if [ -d ".windsurf" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR=".windsurf.backup_${TIMESTAMP}"

    echo -e "${YELLOW}⚠️  Existing .windsurf folder found. Backing up...${NC}"
    cp -r .windsurf "$BACKUP_DIR"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"

    # Copy any custom files from .windsurf/rules to .ai (preserve user customizations)
    echo "📦 Preserving custom files..."

    # Copy custom rules (non-symlink .md files)
    if [ -d ".windsurf/rules" ]; then
        find .windsurf/rules -type f ! -type l -name "*.md" 2>/dev/null | while read file; do
            filename=$(basename "$file")
            if [ "$filename" != "main.md" ]; then
                # Copy to .ai/commands/
                cp "$file" ".ai/commands/$filename"
                echo -e "${GREEN}✓${NC} Copied custom rule: $filename"
            fi
        done
    fi

    # Remove old .windsurf folder
    rm -rf .windsurf
    echo -e "${GREEN}✓${NC} Old .windsurf folder removed"
fi

# Backup and remove legacy .windsurfrules if it exists and is not a symlink
if [ -f ".windsurfrules" ] && [ ! -L ".windsurfrules" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    cp .windsurfrules ".windsurfrules.backup_${TIMESTAMP}"
    echo -e "${GREEN}✓${NC} Backed up legacy .windsurfrules"
    rm -f .windsurfrules
fi

# Create .windsurf directory structure
mkdir -p .windsurf/rules

echo "📋 Creating Windsurf configuration..."

# Symlink main rules file
if [ -f ".ai/AGENTS.md" ]; then
    ln -sf ../../.ai/AGENTS.md .windsurf/rules/main.md
    echo -e "${GREEN}✓${NC} Linked .windsurf/rules/main.md → .ai/AGENTS.md"

    # Also create legacy .windsurfrules for compatibility
    ln -sf .ai/AGENTS.md .windsurfrules
    echo -e "${GREEN}✓${NC} Linked .windsurfrules → .ai/AGENTS.md (legacy)"
fi

# Symlink context folder
if [ -d ".ai/context" ]; then
    ln -sf ../../.ai/context .windsurf/rules/context
    echo -e "${GREEN}✓${NC} Linked .windsurf/rules/context/ → .ai/context/"
fi

echo ""
echo -e "${BLUE}✅ Windsurf setup complete!${NC}"
echo ""
echo "Structure created:"
echo "  .windsurf/rules/main.md          → .ai/AGENTS.md"
echo "  .windsurf/rules/context/         → .ai/context/"
echo "  .windsurfrules                   → .ai/AGENTS.md (legacy)"
echo ""
echo "✨ Dynamic updates: Changes to .ai/ are immediately available!"
echo ""
echo "⚠️  Note: Watch character limits (6K per file, 12K total)"
echo ""
echo "In Windsurf, rules are auto-applied based on mode (Always On/Manual/Model Decision)"
