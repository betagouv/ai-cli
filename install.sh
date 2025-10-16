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
RAW_URL="https://raw.githubusercontent.com/betagouv/ai-cli/main"

echo -e "${BLUE}"
echo "🤖 Beta.gouv.fr AI Configuration Setup"
echo "=======================================${NC}"
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

# Check if .ai directory already exists
if [ -d ".ai" ]; then
    echo -e "${YELLOW}⚠️  .ai folder already exists${NC}"
    read -p "Do you want to overwrite existing files? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
fi

# Project information
echo -e "${BLUE}Project Information${NC}"
read -p "Project name [$(basename "$PWD")]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$(basename "$PWD")}

read -p "Project description: " PROJECT_DESC

echo ""
echo -e "${BLUE}📝 Downloading templates...${NC}"
echo ""

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
    echo "Fetching available contexts and tools..."
    git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
        echo -e "${RED}❌ Failed to download templates${NC}"
        exit 1
    }
fi

# Cleanup temp directory only if we created it
if [ "$CLEANUP_TEMP" = true ]; then
    trap "rm -rf $TEMP_DIR" EXIT
fi

# Select contexts (frameworks/languages)
echo ""
echo -e "${BLUE}Which contexts do you want to include?${NC}"
echo -e "${YELLOW}(You can select multiple by answering Y to each)${NC}"
echo ""

SELECTED_CONTEXTS=()
CONTEXT_DIR="$TEMP_DIR/templates/.ai/context"

if [ -d "$CONTEXT_DIR" ]; then
    # Loop through each context folder
    for context_path in "$CONTEXT_DIR"/*; do
        if [ -d "$context_path" ]; then
            context_name=$(basename "$context_path")

            # Capitalize first letter for display (portable way)
            first_char=$(echo "$context_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
            rest_chars=$(echo "$context_name" | cut -c2-)
            context_display="${first_char}${rest_chars}"

            read -p "Include ${context_display} context? (Y/n): " -n 1 -r RESPONSE
            echo
            if [[ ! $RESPONSE =~ ^[Nn]$ ]]; then
                SELECTED_CONTEXTS+=("$context_name")
            fi
        fi
    done
fi

# Set FRAMEWORK for placeholder replacement (use first selected or "Other")
if [ ${#SELECTED_CONTEXTS[@]} -gt 0 ]; then
    # Capitalize first context for display
    first_char=$(echo "${SELECTED_CONTEXTS[0]}" | cut -c1 | tr '[:lower:]' '[:upper:]')
    rest_chars=$(echo "${SELECTED_CONTEXTS[0]}" | cut -c2-)
    FRAMEWORK="${first_char}${rest_chars}"

    # Add remaining contexts if any
    if [ ${#SELECTED_CONTEXTS[@]} -gt 1 ]; then
        for i in "${SELECTED_CONTEXTS[@]:1}"; do
            first_char=$(echo "$i" | cut -c1 | tr '[:lower:]' '[:upper:]')
            rest_chars=$(echo "$i" | cut -c2-)
            FRAMEWORK="$FRAMEWORK, ${first_char}${rest_chars}"
        done
    fi
else
    FRAMEWORK="Other"
fi

echo ""
echo -e "${BLUE}Which AI tools will your team use?${NC}"
echo ""

# AI Tools selection - dynamically discover available IDEs
TOOLS=()
IDE_DIR="$TEMP_DIR/templates/ides"

if [ -d "$IDE_DIR" ]; then
    # Loop through each IDE folder
    for ide_path in "$IDE_DIR"/*; do
        if [ -d "$ide_path" ]; then
            ide_name=$(basename "$ide_path")

            # Capitalize first letter for display (portable way)
            first_char=$(echo "$ide_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
            rest_chars=$(echo "$ide_name" | cut -c2-)
            ide_display="${first_char}${rest_chars}"

            # Special case for copilot
            if [ "$ide_name" = "copilot" ]; then
                ide_display="GitHub Copilot"
            fi

            read -p "Install ${ide_display} configuration? (Y/n): " -n 1 -r RESPONSE
            echo
            if [[ ! $RESPONSE =~ ^[Nn]$ ]]; then
                TOOLS+=("$ide_name")
            fi
        fi
    done
else
    echo -e "${RED}❌ No IDE templates found${NC}"
    exit 1
fi

if [ ${#TOOLS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No tools selected. Exiting.${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}📝 Creating AI configuration structure...${NC}"
echo ""

# Copy .ai folder structure (excluding context folder)
echo "Creating .ai structure..."
cp -r "$TEMP_DIR/templates/.ai" .

# Remove all context folders, we'll copy only selected ones
rm -rf .ai/context/*

# Copy only selected context folders
if [ ${#SELECTED_CONTEXTS[@]} -gt 0 ]; then
    echo "Installing selected contexts: ${SELECTED_CONTEXTS[*]}"
    for context in "${SELECTED_CONTEXTS[@]}"; do
        if [ -d "$TEMP_DIR/templates/.ai/context/$context" ]; then
            cp -r "$TEMP_DIR/templates/.ai/context/$context" .ai/context/
            echo -e "${GREEN}✓${NC} Added $context context"
        fi
    done
else
    echo -e "${YELLOW}⚠️  No contexts selected${NC}"
fi

# Replace placeholders in all .ai files
echo "Customizing templates with your project info..."

# Function to replace placeholders
replace_placeholders() {
    local file="$1"
    if [ -f "$file" ]; then
        sed -i.bak \
            -e "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" \
            -e "s/{{PROJECT_DESC}}/${PROJECT_DESC:-Description à ajouter}/g" \
            -e "s/{{FRAMEWORK}}/$FRAMEWORK/g" \
            "$file"
        rm -f "${file}.bak"
    fi
}

# Replace in all markdown files in .ai/
find .ai -name "*.md" -type f | while read file; do
    replace_placeholders "$file"
done

echo -e "${GREEN}✓ Created .ai structure${NC}"

# Run init scripts for selected tools
echo ""
echo -e "${BLUE}🔄 Configuring selected tools...${NC}"
echo ""

for tool in "${TOOLS[@]}"; do
    INIT_SCRIPT="$TEMP_DIR/templates/ides/$tool/init.sh"
    if [ -f "$INIT_SCRIPT" ]; then
        echo -e "${BLUE}Setting up $tool...${NC}"
        bash "$INIT_SCRIPT" || {
            echo -e "${YELLOW}⚠️  $tool setup failed${NC}"
        }
        echo ""

        # Append IDE .gitignore to project .gitignore if it exists
        IDE_GITIGNORE="$TEMP_DIR/templates/ides/$tool/.gitignore"
        if [ -f "$IDE_GITIGNORE" ]; then
            echo "Updating project .gitignore for $tool..."

            # Create .gitignore if it doesn't exist
            touch .gitignore

            # Check if we already have this IDE's gitignore section
            IDE_MARKER="# ${tool} - Auto-generated symlinks"
            if ! grep -q "$IDE_MARKER" .gitignore; then
                # Add a separator and marker
                echo "" >> .gitignore
                echo "# =============================================================================" >> .gitignore
                echo "$IDE_MARKER" >> .gitignore
                echo "# Generated from templates/ides/$tool/.gitignore" >> .gitignore
                echo "# =============================================================================" >> .gitignore

                # Append the gitignore content directly (paths already include directory)
                while IFS= read -r line; do
                    # Skip empty lines and comments from template
                    if [[ -n "$line" ]] && [[ ! "$line" =~ ^# ]]; then
                        echo "$line" >> .gitignore
                    fi
                done < "$IDE_GITIGNORE"

                echo -e "${GREEN}✓${NC} Updated .gitignore for $tool"
            fi
        fi
    fi
done

echo ""
echo -e "${GREEN}✅ AI configuration initialized successfully!${NC}"
echo ""
echo -e "${BLUE}Selected contexts:${NC} ${SELECTED_CONTEXTS[*]:-None}"
echo -e "${BLUE}Selected tools:${NC} ${TOOLS[*]}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review and customize files in .ai/ folder"
echo "  2. To reconfigure: bash templates/ides/<tool>/init.sh"
echo "  3. Commit .ai/ folder to git"
echo "  4. Open your AI tool and test"
echo ""
