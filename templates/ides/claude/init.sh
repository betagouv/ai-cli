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
#   - .claude/output-styles/           AI behavior profiles (personas)
#
# All of these use SYMLINKS for dynamic updates - no manual sync needed!
#
# ==============================================================================

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Global variables
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR=".tmp/claude.backup_${TIMESTAMP}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    if [ ! -d ".claude" ]; then
        return 0
    fi

    echo -e "${YELLOW}⚠️  Existing .claude folder found. Backing up...${NC}"
    mkdir -p .tmp
    cp -r .claude "$BACKUP_DIR"
    echo -e "${GREEN}✓${NC} Backup created at $BACKUP_DIR"
}

preserve_user_customizations() {
    if [ ! -d ".claude" ]; then
        return 0
    fi

    echo "📦 Preserving your custom files..."

    # Ensure .ai directories exist
    mkdir -p .ai/commands .ai/agents .ai/avatars

    # List known mapped folders
    known_folders=(commands agents output-styles)

    # Handle known folders and also copy any other custom folders
    for folder in .claude/*; do
        [ -d "$folder" ] || continue
        folder_name="$(basename "$folder")"

        # Determine .ai target dir
        target_dir=""
        if [[ "$folder_name" == "commands" ]]; then
            target_dir=".ai/commands"
            # Only copy if it's not a symlink
            if [ ! -L "$folder" ]; then
                find "$folder" -type f -name "*.md" 2>/dev/null | while read file; do
                    relative_path="${file#$folder/}"
                    dest_dir="$target_dir/$(dirname "$relative_path")"
                    mkdir -p "$dest_dir"
                    cp "$file" "$dest_dir/"
                    echo -e "${GREEN}✓${NC} Copied custom command: $relative_path"
                done
            fi
            continue
        elif [[ "$folder_name" == "agents" ]]; then
            target_dir=".ai/agents"
            if [ ! -L "$folder" ]; then
                find "$folder" -type f -name "*.md" 2>/dev/null | while read file; do
                    cp "$file" "$target_dir/"
                    echo -e "${GREEN}✓${NC} Copied custom agent: $(basename "$file")"
                done
            fi
            continue
        elif [[ "$folder_name" == "output-styles" ]]; then
            target_dir=".ai/avatars"
            if [ ! -L "$folder" ]; then
                find "$folder" -type f -name "*.md" 2>/dev/null | while read file; do
                    cp "$file" "$target_dir/"
                    echo -e "${GREEN}✓${NC} Copied custom avatar: $(basename "$file")"
                done
            fi
            continue
        else
            # For any other folder, copy its full tree to .ai/<folder_name>, but skip symlinks
            if [ ! -L "$folder" ]; then
                mkdir -p ".ai/${folder_name}"
                cp -R "$folder/." ".ai/${folder_name}/"
                echo -e "${GREEN}✓${NC} Copied custom folder: $folder_name → .ai/${folder_name}/"
            fi
        fi
    done
}

cleanup_old_config() {
    if [ ! -d ".claude" ]; then
        return 0
    fi

    rm -rf .claude
    echo -e "${GREEN}✓${NC} Old .claude folder removed"
}

create_directory_structure() {
    mkdir -p .claude
}

create_symlinks() {
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
}

copy_static_files() {
    # Copy settings.json if it exists in templates
    if [ -f "$SCRIPT_DIR/settings.json" ]; then
        cp "$SCRIPT_DIR/settings.json" .claude/settings.json
        echo -e "${GREEN}✓${NC} Copied settings.json → .claude/settings.json"
    fi
}

print_summary() {
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
    echo ""
    if [ -d ".tmp" ]; then
        echo -e "${BLUE}📦 Backup files are stored in .tmp/${NC}"
    fi
}

# ==============================================================================
# Main execution
# ==============================================================================

main() {
    echo "🔧 Setting up Claude Code configuration..."

    check_prerequisites
    backup_existing_config
    preserve_user_customizations
    cleanup_old_config
    create_directory_structure
    create_symlinks
    copy_static_files
    print_summary
}

main
