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

# Project information
echo -e "${BLUE}Project Information${NC}"
read -p "Project name [$(basename "$PWD")]: " PROJECT_NAME </dev/tty
PROJECT_NAME=${PROJECT_NAME:-$(basename "$PWD")}

read -p "Project description: " PROJECT_DESC </dev/tty

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

# Multi-select function using simple prompt
multi_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected_items=()

    # Display to terminal, not captured by command substitution
    echo -e "${BLUE}${prompt}${NC}" >&2
    echo -e "${YELLOW}Enter space-separated numbers (e.g., '1 3 5'), or 'all' for everything${NC}" >&2
    echo "" >&2

    # Display options with numbers
    for i in "${!options[@]}"; do
        echo "  $((i+1)). ${options[$i]}" >&2
    done

    echo "" >&2
    read -p "Your selection: " -r selection </dev/tty

    # Handle 'all' selection
    if [[ "$selection" == "all" ]]; then
        selected_items=("${options[@]}")
    else
        # Process space-separated numbers
        for choice_num in $selection; do
            # Check if the choice number is valid
            if [[ "$choice_num" =~ ^[0-9]+$ ]] && (( choice_num > 0 && choice_num <= ${#options[@]} )); then
                selected_items+=("${options[choice_num - 1]}")
            elif [[ "$choice_num" =~ ^[0-9]+$ ]]; then
                echo "Invalid selection: $choice_num" >&2
            fi
        done

        # Remove duplicates
        if [ ${#selected_items[@]} -gt 0 ]; then
            selected_items=($(printf '%s\n' "${selected_items[@]}" | sort -u))
        fi
    fi

    # Only output the result to stdout (captured by command substitution)
    echo "${selected_items[@]}"
}

# Select contexts (frameworks/languages)
echo ""
SELECTED_CONTEXTS=()
CONTEXT_DIR="$TEMP_DIR/templates/.ai/context"

if [ -d "$CONTEXT_DIR" ]; then
    # Collect all context folders
    available_contexts=()
    context_displays=()

    for context_path in "$CONTEXT_DIR"/*; do
        if [ -d "$context_path" ]; then
            context_name=$(basename "$context_path")

            # Capitalize first letter for display
            first_char=$(echo "$context_name" | cut -c1 | tr '[:lower:]' '[:upper:]')
            rest_chars=$(echo "$context_name" | cut -c2-)
            context_display="${first_char}${rest_chars}"

            available_contexts+=("$context_name")
            context_displays+=("$context_display")
        fi
    done

    # Show multi-select menu
    if [ ${#available_contexts[@]} -gt 0 ]; then
        selected_displays=($(multi_select "Which contexts do you want to include?" "${context_displays[@]}"))

        # Map display names back to folder names
        for display in "${selected_displays[@]}"; do
            display_lower=$(echo "$display" | tr '[:upper:]' '[:lower:]')
            SELECTED_CONTEXTS+=("$display_lower")
        done
    fi
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

# AI Tools selection - dynamically discover available IDEs
echo ""
TOOLS=()
IDE_DIR="$TEMP_DIR/templates/ides"

if [ -d "$IDE_DIR" ]; then
    # Collect all IDE folders
    available_ides=()
    ide_displays=()

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

            available_ides+=("$ide_name")
            ide_displays+=("$ide_display")
        fi
    done

    # Show multi-select menu
    if [ ${#available_ides[@]} -gt 0 ]; then
        selected_displays=($(multi_select "Which AI tools will you use?" "${ide_displays[@]}"))

        # Map display names back to folder names
        for display in "${selected_displays[@]}"; do
            # Find the corresponding folder name
            for i in "${!ide_displays[@]}"; do
                if [[ "${ide_displays[$i]}" == "$display" ]]; then
                    TOOLS+=("${available_ides[$i]}")
                    break
                fi
            done
        done
    fi
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
echo "  1. Review files in .ai/ folder and commit to git"
echo "  2. Launch /ai-cli-init to initialize context files"
echo "  3. Open your AI tool and test"
echo ""
