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
echo "🤖 AI CLI - Simple AI Configuration Setup"
echo "==========================================${NC}"
echo ""

# Check dependencies
check_dependency() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ Error: $1 is not installed${NC}"
        echo "Please install $1 and try again"
        exit 1
    fi
}

echo "Checking dependencies..."
check_dependency "curl"
check_dependency "git"
echo -e "${GREEN}✓ All dependencies found${NC}"
echo ""

# Check if git working directory is clean
if [ -d ".git" ]; then
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        echo -e "${RED}❌ Git working directory is not clean${NC}"
        echo -e "${YELLOW}   Please commit or stash your changes before running install${NC}"
        echo ""
        echo "Uncommitted changes:"
        git status --short
        exit 1
    fi
    echo -e "${GREEN}✓ Git working directory is clean${NC}"
    echo ""
fi

# Check if .ai directory already exists
if [ -d ".ai" ]; then
    echo -e "${YELLOW}⚠️  .ai folder already exists${NC}"
    read -p "Do you want to overwrite existing files? (y/N): " -n 1 -r </dev/tty
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

# Check if we're running from within the repository (for local development/testing)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANUP_TEMP=false

if [ -d "$SCRIPT_DIR/templates/ides" ]; then
    echo "Using local templates (development mode)..."
    TEMP_DIR="$SCRIPT_DIR"
else
    # Create temporary directory and clone repository
    TEMP_DIR=$(mktemp -d)
    CLEANUP_TEMP=true

    # Clone repository to temp directory
    echo "Fetching templates..."
    git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
        echo -e "${RED}❌ Failed to download templates${NC}"
        exit 1
    }
fi

# Cleanup temp directory only if we created it
if [ "$CLEANUP_TEMP" = true ]; then
    trap "rm -rf $TEMP_DIR" EXIT
fi

# Project information
echo -e "${BLUE}Project Information${NC}"
read -p "Project name [$(basename "$PWD")]: " PROJECT_NAME </dev/tty
PROJECT_NAME=${PROJECT_NAME:-$(basename "$PWD")}

# Select IDE(s)
echo ""
echo -e "${BLUE}Which IDE(s) do you use?${NC}"
echo "  1) Claude Code"
echo "  2) Cursor"
echo ""
echo -e "${YELLOW}Enter your choice(s) (e.g., '1' or '1 2' or '2 1'):${NC}"
read -p "Your choice: " -r IDE_CHOICES </dev/tty
echo ""

# Parse IDE choices
IDES=()
for choice in $IDE_CHOICES; do
    case $choice in
        1)
            IDES+=("claude")
            ;;
        2)
            IDES+=("cursor")
            ;;
        *)
            echo -e "${RED}❌ Invalid choice: $choice${NC}"
            exit 1
            ;;
    esac
done

# Check if at least one IDE was selected
if [ ${#IDES[@]} -eq 0 ]; then
    echo -e "${RED}❌ No IDE selected${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}📝 Creating AI configuration structure...${NC}"
echo ""

# Copy .ai folder structure
echo "Creating .ai structure..."
cp -r "$TEMP_DIR/templates/.ai" .

# Replace placeholders in all .ai files
echo "Customizing templates with your project info..."

# Function to replace placeholders
replace_placeholders() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -i.bak \
            -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            -e "s/{{FRAMEWORK}}/Core/g" \
            "$file"
        rm -f "${file}.bak"
    fi
}

# Replace in all markdown files in .ai/
find .ai -name "*.md" -type f | while read file; do
    replace_placeholders "$file"
done

echo -e "${GREEN}✓ Created .ai structure${NC}"

# Install core plugin (always installed)
echo ""
echo -e "${BLUE}📦 Installing core plugin...${NC}"

if [ -d "$TEMP_DIR/templates/plugins/core/commands" ]; then
    mkdir -p .ai/commands
    cp -r "$TEMP_DIR/templates/plugins/core/commands"/* .ai/commands/ 2>/dev/null || true
fi

if [ -d "$TEMP_DIR/templates/plugins/core/agents" ]; then
    mkdir -p .ai/agents
    cp -r "$TEMP_DIR/templates/plugins/core/agents"/* .ai/agents/ 2>/dev/null || true
fi

echo -e "${GREEN}✓ Core plugin installed${NC}"

# Run IDE setup for each selected IDE
echo ""
echo -e "${BLUE}🔄 Configuring IDE(s)...${NC}"
echo ""

for IDE in "${IDES[@]}"; do
    # Get IDE display name
    case $IDE in
        claude)
            IDE_NAME="Claude Code"
            ;;
        cursor)
            IDE_NAME="Cursor"
            ;;
    esac

    echo -e "${BLUE}Setting up $IDE_NAME...${NC}"

    INIT_SCRIPT="$TEMP_DIR/templates/ides/$IDE/init.sh"
    if [ -f "$INIT_SCRIPT" ]; then
        bash "$INIT_SCRIPT" || {
            echo -e "${YELLOW}⚠️  $IDE_NAME setup failed${NC}"
        }

        # Append IDE .gitignore to project .gitignore if it exists
        IDE_GITIGNORE="$TEMP_DIR/templates/ides/$IDE/.gitignore"
        if [ -f "$IDE_GITIGNORE" ]; then
            # Create .gitignore if it doesn't exist
            touch .gitignore

            # Check if we already have this IDE's gitignore section
            IDE_MARKER="# ${IDE} - Auto-generated symlinks"
            if ! grep -q "$IDE_MARKER" .gitignore; then
                # Add a separator and marker
                echo "" >> .gitignore
                echo "# =============================================================================" >> .gitignore
                echo "$IDE_MARKER" >> .gitignore
                echo "# ⚠️  Auto-generated by ai-cli - Do not edit manually" >> .gitignore
                echo "# =============================================================================" >> .gitignore

                # Append the gitignore content directly
                while IFS= read -r line; do
                    # Skip empty lines and comments from template
                    if [[ -n "$line" ]] && [[ ! "$line" =~ ^# ]]; then
                        echo "$line" >> .gitignore
                    fi
                done < "$IDE_GITIGNORE"

                echo -e "${GREEN}✓${NC} Updated .gitignore for $IDE_NAME"
            fi
        fi

        echo ""
    fi
done

# Create .ai-cli.json
echo -e "${BLUE}📝 Creating .ai-cli.json...${NC}"

# Build IDEs array for JSON
IDES_JSON="["
for i in "${!IDES[@]}"; do
    if [ $i -eq 0 ]; then
        IDES_JSON+="\"${IDES[$i]}\""
    else
        IDES_JSON+=", \"${IDES[$i]}\""
    fi
done
IDES_JSON+="]"

cat > .ai-cli.json << EOF
{
  "version": "1.0.0",
  "ides": $IDES_JSON,
  "plugins": ["core"]
}
EOF

echo -e "${GREEN}✓ Created .ai-cli.json${NC}"

# Add .ai-cli.json to .gitignore
if ! grep -q "^\.ai-cli\.json" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# AI CLI configuration (user-specific)" >> .gitignore
    echo ".ai-cli.json" >> .gitignore
    echo -e "${GREEN}✓ Added .ai-cli.json to .gitignore${NC}"
fi

echo ""
echo -e "${GREEN}✅ AI configuration initialized successfully!${NC}"
echo ""
echo -e "${BLUE}IDE(s):${NC} ${IDES[*]}"
echo -e "${BLUE}Plugins:${NC} core"
echo ""

# Show next steps
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review files in .ai/ folder"
echo "  2. Run: /ai-cli-init to initialize context files"
echo "  3. Commit .ai/ to git (but not .ai-cli.json)"
echo ""
echo -e "${BLUE}Add more plugins:${NC}"
echo "  Run: .ai/bin/ai-cli plugins list"
echo "  Then: .ai/bin/ai-cli plugins add <plugin-name>"
echo ""
echo -e "${BLUE}Update later:${NC}"
echo "  Run: .ai/bin/ai-cli update"
echo ""
