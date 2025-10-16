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

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Global variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=".tmp/cursor.backup_${TIMESTAMP}"

# ==============================================================================
# Functions
# ==============================================================================

check_prerequisites() {
    if [ ! -d ".ai" ]; then
        echo -e "${YELLOW}⚠️  .ai folder not found. Run this from project root.${NC}"
        exit 1
    fi
}

backup_existing_config() {
    if [ ! -d ".cursor" ]; then
        return 0
    fi

    echo -e "${YELLOW}⚠️  Existing .cursor folder found. Backing up...${NC}"
    mkdir -p .tmp
    cp -r .cursor "$BACKUP_DIR"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"
}

preserve_user_customizations() {
    if [ ! -d ".cursor" ]; then
        return 0
    fi

    echo "📦 Preserving custom files..."

    # Ensure .ai directories exist
    mkdir -p .ai/context

    # Copy custom rules (non-symlink .mdc files)
    if [ -d ".cursor/rules" ]; then
        find .cursor/rules -type f ! -type l -name "*.mdc" 2>/dev/null | while read file; do
            filename=$(basename "$file")
            if [ "$filename" != "main.mdc" ]; then
                # Copy to .ai/context/ preserving .mdc extension
                cp "$file" ".ai/context/${filename}"
                echo -e "${GREEN}✓${NC} Copied custom rule: $filename → .ai/context/"
            fi
        done

        # Also check for nested directories with .md files
        find .cursor/rules -type f ! -type l -name "*.md" 2>/dev/null | while read file; do
            relative_path="${file#.cursor/rules/}"
            # Skip if it's a symlink
            if [ ! -L "$file" ]; then
                target_dir=".ai/context/$(dirname "$relative_path")"
                mkdir -p "$target_dir"
                cp "$file" "$target_dir/"
                echo -e "${GREEN}✓${NC} Copied custom file: $relative_path → .ai/context/"
            fi
        done
    fi

    # Copy any non-standard directories/files from .cursor/ to .ai/
    echo "📦 Preserving non-standard directories..."
    for item in .cursor/*; do
        if [ ! -e "$item" ]; then
            continue
        fi

        item_name=$(basename "$item")

        # Skip the known 'rules' directory (already handled above)
        if [ "$item_name" = "rules" ]; then
            continue
        fi

        # Copy unknown items to .ai/
        if [ -d "$item" ] && [ ! -L "$item" ]; then
            cp -r "$item" ".ai/$item_name"
            echo -e "${GREEN}✓${NC} Copied custom directory: $item_name/"
        elif [ -f "$item" ]; then
            cp "$item" ".ai/$item_name"
            echo -e "${GREEN}✓${NC} Copied custom file: $item_name"
        fi
    done
}

cleanup_old_config() {
    if [ ! -d ".cursor" ]; then
        return 0
    fi

    rm -rf .cursor
    echo -e "${GREEN}✓${NC} Old .cursor folder removed"
}

create_directory_structure() {
    mkdir -p .cursor/rules
}

create_symlinks() {
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
}

print_summary() {
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
    echo ""
    if [ -d ".tmp" ]; then
        echo -e "${BLUE}📦 Backup files are stored in .tmp/${NC}"
    fi
}

# ==============================================================================
# Main execution
# ==============================================================================

main() {
    echo "🔧 Setting up Cursor configuration..."

    check_prerequisites
    backup_existing_config
    preserve_user_customizations
    cleanup_old_config
    create_directory_structure
    create_symlinks
    print_summary
}

main
