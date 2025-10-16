#!/bin/bash
set -e

# ==============================================================================
# GitHub Copilot Configuration Setup
# ==============================================================================
#
# GitHub Copilot uses:
#   - .github/copilot-instructions.md  Main instruction file
#
# Copilot reads this single file for project-specific instructions.
# Additional context can be provided in .github/copilot/ folder (unofficial).
#
# We use SYMLINKS so any changes to .ai/ are immediately available.
#
# ==============================================================================

echo "🔧 Setting up GitHub Copilot configuration..."

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

# Backup existing copilot-instructions.md if it exists and is not a symlink
if [ -f ".github/copilot-instructions.md" ] && [ ! -L ".github/copilot-instructions.md" ]; then
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE=".github/copilot-instructions.md.backup_${TIMESTAMP}"

    echo -e "${YELLOW}⚠️  Existing copilot-instructions.md found. Backing up...${NC}"
    cp .github/copilot-instructions.md "$BACKUP_FILE"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_FILE"

    # Copy existing instructions to .ai/AGENTS.md if it doesn't exist
    if [ ! -f ".ai/AGENTS.md" ]; then
        cp .github/copilot-instructions.md .ai/AGENTS.md
        echo -e "${GREEN}✓${NC} Copied existing instructions to .ai/AGENTS.md"
    fi

    rm -f .github/copilot-instructions.md
    echo -e "${GREEN}✓${NC} Old copilot-instructions.md removed"
fi

# Backup existing .github/copilot folder if it contains non-symlink files
if [ -d ".github/copilot" ]; then
    # Check if there are any regular files (not symlinks)
    if find .github/copilot -type f ! -type l | grep -q .; then
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        BACKUP_DIR=".github/copilot.backup_${TIMESTAMP}"

        echo -e "${YELLOW}⚠️  Existing .github/copilot/ files found. Backing up...${NC}"
        mkdir -p "$BACKUP_DIR"
        find .github/copilot -type f ! -type l -exec cp {} "$BACKUP_DIR/" \;
        echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"
    fi

    # Remove the copilot folder to recreate it
    rm -rf .github/copilot
fi

# Create .github directory
mkdir -p .github/copilot

echo "📋 Creating GitHub Copilot configuration..."

# Symlink copilot-instructions.md (main config)
if [ -f ".ai/AGENTS.md" ]; then
    ln -sf ../.ai/AGENTS.md .github/copilot-instructions.md
    echo -e "${GREEN}✓${NC} Linked .github/copilot-instructions.md → .ai/AGENTS.md"
fi

# Symlink context folder (unofficial but useful for referencing)
if [ -d ".ai/context" ]; then
    ln -sf ../../.ai/context .github/copilot/context
    echo -e "${GREEN}✓${NC} Linked .github/copilot/context/ → .ai/context/"
fi

echo ""
echo -e "${BLUE}✅ GitHub Copilot setup complete!${NC}"
echo ""
echo "Structure created:"
echo "  .github/copilot-instructions.md  → .ai/AGENTS.md"
echo "  .github/copilot/context/         → .ai/context/ (for reference)"
echo ""
echo "✨ Dynamic updates: Changes to .ai/ are immediately available!"
echo ""
echo "Note: Copilot primarily reads copilot-instructions.md"
echo "      Additional files in .github/copilot/ are for manual reference"
