#!/bin/bash
set -e

# ==============================================================================
# Cursor IDE Configuration Setup
# ==============================================================================
#
# Cursor uses:
#   - .cursor/rules/*.mdc              Markdown files with AI rules
#   - .cursor/rules/main.mdc           Main configuration (required)
#
# Cursor reads ALL .mdc files in .cursor/rules/ and can reference them with @
#
# We use SYMLINKS so any changes to .ai/ are immediately available.
#
# ==============================================================================

echo "🔧 Setting up Cursor configuration..."

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

# Backup existing .cursor folder if it exists
if [ -d ".cursor" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_DIR=".cursor.backup_${TIMESTAMP}"

    echo -e "${YELLOW}⚠️  Existing .cursor folder found. Backing up...${NC}"
    cp -r .cursor "$BACKUP_DIR"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"

    # Copy any custom files from .cursor/rules to .ai (preserve user customizations)
    echo "📦 Preserving custom files..."

    # Copy custom rules (non-symlink .mdc files)
    if [ -d ".cursor/rules" ]; then
        find .cursor/rules -type f ! -type l -name "*.mdc" 2>/dev/null | while read file; do
            filename=$(basename "$file")
            if [ "$filename" != "main.mdc" ]; then
                # Copy to .ai/commands/ as .md files
                cp "$file" ".ai/commands/${filename%.mdc}.md"
                echo -e "${GREEN}✓${NC} Copied custom rule: $filename"
            fi
        done
    fi

    # Remove old .cursor folder
    rm -rf .cursor
    echo -e "${GREEN}✓${NC} Old .cursor folder removed"
fi

# Create .cursor directory structure
mkdir -p .cursor/rules

echo "📋 Creating Cursor configuration..."

# Symlink main.mdc (main config)
if [ -f ".ai/AGENTS.md" ]; then
    ln -sf ../../.ai/AGENTS.md .cursor/rules/main.mdc
    echo -e "${GREEN}✓${NC} Linked .cursor/rules/main.mdc → .ai/AGENTS.md"
fi

# Symlink context folder
if [ -d ".ai/context" ]; then
    ln -sf ../../.ai/context .cursor/rules/context
    echo -e "${GREEN}✓${NC} Linked .cursor/rules/context/ → .ai/context/"
    echo -e "       ${BLUE}→ Reference with @.cursor/rules/context/architecture.md${NC}"
fi

echo ""
echo -e "${BLUE}✅ Cursor setup complete!${NC}"
echo ""
echo "Structure created:"
echo "  .cursor/rules/main.mdc           → .ai/AGENTS.md"
echo "  .cursor/rules/context/           → .ai/context/"
echo ""
echo "✨ Dynamic updates: Changes to .ai/ are immediately available!"
echo ""
echo "In Cursor, reference with:"
echo "  @.cursor/rules/main.mdc"
echo "  @.cursor/rules/context/architecture.md"
