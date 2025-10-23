#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository information
REPO_URL="https://github.com/betagouv/ai-cli"

echo -e "${BLUE}"
echo "🔄 AI CLI - Update"
echo "==================${NC}"
echo ""

# Check if .ai/config.jsonc exists
if [ ! -f ".ai/config.jsonc" ]; then
    echo -e "${RED}❌ No .ai/config.jsonc found in current directory${NC}"
    echo "   Run install.sh first to initialize the project"
    exit 1
fi

# Check if git working directory is clean
if [ -d ".git" ]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${RED}❌ Git working directory is not clean${NC}"
        echo -e "${YELLOW}   Please commit or stash your changes before updating${NC}"
        echo ""
        echo "Uncommitted changes:"
        git status --short
        exit 1
    fi
    echo -e "${GREEN}✓ Git working directory is clean${NC}"
    echo ""
fi

# Read configuration
echo "Reading configuration..."

# Strip comments from JSONC (lines starting with // and /* */ blocks)
CONFIG_JSON=$(grep -v '^\s*//' .ai/config.jsonc | sed 's|//.*||g')

if command -v jq &> /dev/null; then
    # Use jq to parse the config
    PLUGINS=($(echo "$CONFIG_JSON" | jq -r '.plugins[]' 2>/dev/null))
else
    # Fallback: simple grep/sed parsing
    PLUGINS=($(echo "$CONFIG_JSON" | grep -o '"plugins":\s*\[.*\]' | sed 's/.*\[//' | sed 's/\].*//' | tr ',' '\n' | tr -d ' "' | grep -v '^$'))
fi

echo -e "${GREEN}✓ Configuration loaded${NC}"
echo "  Plugins: ${PLUGINS[*]}"
echo ""

# Download latest version
echo -e "${BLUE}📥 Downloading latest version...${NC}"

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo -e "${RED}❌ Failed to download latest version${NC}"
    exit 1
}

echo -e "${GREEN}✓ Downloaded${NC}"
echo ""

# Update plugins
echo -e "${BLUE}📦 Updating plugins...${NC}"

for plugin in "${PLUGINS[@]}"; do
    echo "  Updating: $plugin"

    # Copy commands
    if [ -d "$TEMP_DIR/templates/plugins/$plugin/commands" ]; then
        mkdir -p .ai/commands
        cp -r "$TEMP_DIR/templates/plugins/$plugin/commands"/* .ai/commands/ 2>/dev/null || true
    fi

    # Copy agents
    if [ -d "$TEMP_DIR/templates/plugins/$plugin/agents" ]; then
        mkdir -p .ai/agents
        cp -r "$TEMP_DIR/templates/plugins/$plugin/agents"/* .ai/agents/ 2>/dev/null || true
    fi

    # Copy context
    if [ -d "$TEMP_DIR/templates/plugins/$plugin/context" ]; then
        mkdir -p .ai/context
        # For lang-* plugins, copy the context folder with the plugin name
        if [[ "$plugin" == lang-* ]]; then
            lang_name="${plugin#lang-}"
            mkdir -p ".ai/context/$lang_name"
            cp -r "$TEMP_DIR/templates/plugins/$plugin/context"/* ".ai/context/$lang_name/" 2>/dev/null || true
        else
            cp -r "$TEMP_DIR/templates/plugins/$plugin/context"/* .ai/context/ 2>/dev/null || true
        fi
    fi
done

echo -e "${GREEN}✓ Plugins updated${NC}"
echo ""

# Update base .ai templates
echo -e "${BLUE}📝 Updating base templates...${NC}"

# Update AGENTS.md if it hasn't been customized
if [ -f "$TEMP_DIR/templates/.ai/AGENTS.md" ]; then
    cp "$TEMP_DIR/templates/.ai/AGENTS.md" .ai/ 2>/dev/null || true
fi

# Update scripts
if [ -d "$TEMP_DIR/templates/.ai/scripts" ]; then
    mkdir -p .ai/scripts
    cp -r "$TEMP_DIR/templates/.ai/scripts"/* .ai/scripts/ 2>/dev/null || true
fi

# Update CLI
if [ -f "$TEMP_DIR/templates/.ai/cli" ]; then
    cp "$TEMP_DIR/templates/.ai/cli" .ai/cli
    chmod +x .ai/cli
fi

echo -e "${GREEN}✓ Base templates updated${NC}"
echo ""

echo -e "${GREEN}✅ Update completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review changes with: git diff"
echo "  2. If IDE configuration was updated, run: .ai/cli configure"
echo "  3. Commit if everything works: git add . && git commit -m 'chore: update ai-cli'"
echo ""
