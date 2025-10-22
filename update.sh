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

# Check if .ai-cli.json exists
if [ ! -f ".ai-cli.json" ]; then
    echo -e "${RED}❌ No .ai-cli.json found in current directory${NC}"
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

if command -v jq &> /dev/null; then
    # Try new format with ides array first, fallback to old ide field
    IDES=($(jq -r '.ides[]? // .ide?' .ai-cli.json 2>/dev/null | grep -v "null"))
    PLUGINS=($(jq -r '.plugins[]' .ai-cli.json))
else
    # Fallback: simple grep/sed parsing
    # Try ides array first
    IDES=($(grep -o '"ides":\s*\[.*\]' .ai-cli.json 2>/dev/null | sed 's/.*\[//' | sed 's/\].*//' | tr ',' '\n' | tr -d ' "' | grep -v '^$'))
    # If empty, try old ide field
    if [ ${#IDES[@]} -eq 0 ]; then
        IDE_SINGLE=$(grep -o '"ide":\s*"[^"]*"' .ai-cli.json | sed 's/.*"ide":\s*"\([^"]*\)".*/\1/')
        [ -n "$IDE_SINGLE" ] && IDES=("$IDE_SINGLE")
    fi
    PLUGINS=($(grep -o '"plugins":\s*\[.*\]' .ai-cli.json | sed 's/.*\[//' | sed 's/\].*//' | tr ',' '\n' | tr -d ' "' | grep -v '^$'))
fi

echo -e "${GREEN}✓ Configuration loaded${NC}"
echo "  IDE(s): ${IDES[*]}"
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

# Update IDE configuration
echo -e "${BLUE}🔄 Updating IDE configuration...${NC}"

for IDE in "${IDES[@]}"; do
    echo "  Updating: $IDE"
    INIT_SCRIPT="$TEMP_DIR/templates/ides/$IDE/init.sh"
    if [ -f "$INIT_SCRIPT" ]; then
        bash "$INIT_SCRIPT" || {
            echo -e "${YELLOW}⚠️  $IDE setup failed${NC}"
        }
    else
        echo -e "${YELLOW}⚠️  $IDE init script not found${NC}"
    fi
done

echo -e "${GREEN}✓ IDE configuration updated${NC}"
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

echo -e "${GREEN}✓ Base templates updated${NC}"
echo ""

echo -e "${GREEN}✅ Update completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review changes with: git diff"
echo "  2. Test your IDE configuration"
echo "  3. Commit if everything works: git add . && git commit -m 'chore: update ai-cli'"
echo ""
