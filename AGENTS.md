# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**agnostic-ai** is a unified AI configuration system that enables developers to write configuration once in a `.ai/` folder and use it across multiple AI coding tools (Claude Code, Cursor, etc.). It solves configuration duplication and drift when teams use different AI assistants.

**Core Innovation:** Single source of truth (`.ai/`) with modular plugins and symlink-based IDE integration for instant updates across all tools.

## Development Commands

### Installation & Setup
```bash
# Install in a project (production)
curl -fsSL https://raw.githubusercontent.com/betagouv/agnostic-ai/main/install.sh | bash

# Test installation locally (development mode)
bash install.sh

# Configure IDE symlinks
.ai/cli configure

# Migrate existing documentation
.ai/cli migrate
```

### Plugin Management
```bash
# List available plugins
.ai/cli plugins list

# Install a plugin
.ai/cli plugins add <plugin-name>

# Update core + all installed plugins
.ai/cli update
```

### Testing IDE Integration
```bash
# Test Claude Code setup
bash templates/ides/claude/init.sh

# Test Cursor setup
bash templates/ides/cursor/init.sh
```

### Local Development
```bash
# The CLI auto-detects development mode when run from the repo
# It uses local templates/ instead of downloading from GitHub
```

## Architecture

### Directory Structure Philosophy

```
.ai/                          # Source of truth (committed to git)
├── AGENTS.md                 # Main AI configuration
├── config.jsonc              # Installed plugins (JSONC = JSON + comments)
├── cli                       # Plugin manager (bash script)
├── commands/                 # Slash commands organized by plugin
│   ├── core/                 # Core plugin (always installed)
│   └── <plugin>/             # Other plugins
├── agents/                   # Specialized AI agents by plugin
├── context/                  # Project knowledge and guidelines
├── avatars/                  # AI behavior profiles
├── media/                    # Audio notifications
└── scripts/                  # Validation and utilities

.claude/                      # Generated (gitignored)
├── CLAUDE.md → ../.ai/AGENTS.md
├── commands/ → ../.ai/commands/
├── agents/ → ../.ai/agents/
├── context/ → ../.ai/context/
├── output-styles/ → ../.ai/avatars/
└── settings.json             # Copied from templates

.cursor/                      # Generated (gitignored)
├── rules/main.mdc → ../../.ai/AGENTS.md
├── rules/<files> → ../../.ai/context/<files>
├── commands/ → ../.ai/commands/
└── agents/ → ../.ai/agents/

templates/                    # Source templates (development)
├── .ai/                      # Base structure + templates
├── ides/                     # IDE integration scripts
│   ├── claude/
│   │   ├── init.sh           # Setup script
│   │   ├── settings.json     # Claude configuration
│   │   └── scripts/          # Claude-specific utilities
│   ├── cursor/
│   │   └── init.sh
│   └── CONTRIBUTE.md         # Guide for adding IDEs
└── plugins/                  # Available plugins
    ├── core/                 # Always installed
    ├── git/
    ├── github/
    ├── code-quality/
    ├── image-manipulation/
    └── lang-*/               # Language-specific plugins
```

### Key Architectural Decisions

**1. Symlink Strategy**
- `.claude/` and `.cursor/` folders contain symlinks pointing to `.ai/`
- Changes to `.ai/` instantly reflect in all configured IDEs
- Symlinks are gitignored; only `.ai/` is committed
- Each developer can use different IDEs with the same configuration

**2. Plugin System**
- Modular: Install only needed plugins
- Structure: `templates/plugins/<name>/{commands,agents,context}/`
- Installed plugins listed in `.ai/config.jsonc` (committed)
- Updates pull latest plugin versions from repository

**3. Configuration Format**
- JSONC (JSON with Comments) for `.ai/config.jsonc`
- Enables team documentation within config files
- Parsed with `jq` if available, regex fallback otherwise

**4. Template Variables**
- `{{PROJECT_NAME}}` - Replaced during installation
- `{{FRAMEWORK}}` - Tech stack identifier
- Applied via `sed` during `install.sh`

### CLI Implementation (`.ai/cli`)

**Core Functions:**
- `get_plugins_dir()` - Detects development vs production mode
- `get_installed_plugins()` - Parses JSONC config
- `list_plugins()` - Shows available/installed plugins
- `add_plugin()` - Installs plugin and updates config
- `configure()` - IDE setup wizard
- `update()` - Downloads and runs update script

**Development Mode Detection:**
```bash
# If templates/plugins exists locally, use it
# Otherwise, clone from GitHub to temp directory
```

### IDE Integration Patterns

**Claude Code:**
- Directory-level symlinks for entire folders
- Copies `settings.json` (contains hooks, permissions)
- Preserves user customizations during reinstall

**Cursor:**
- Symlinks individual `.mdc` files in `rules/` directory
- Requires `main.mdc` as primary configuration
- Different path depth requires `../../` for symlinks

**Adding New IDEs:**
1. Create `templates/ides/<ide-name>/`
2. Write `init.sh` following standard pattern:
   - `check_prerequisites()`
   - `backup_existing_config()`
   - `preserve_user_customizations()`
   - `cleanup_old_config()`
   - `create_directory_structure()`
   - `create_symlinks()`
   - `copy_static_files()`
   - `print_summary()`
3. Test with `.ai/cli configure`

## Security Features

### Command Validation System

**Location:** `.ai/scripts/validate-command.mjs` (627 lines)

**Purpose:** Intercepts bash commands via PreToolUse hook in Claude Code settings

**Key Protections:**
- Blocks critical commands: `dd`, `mkfs`, `shred`, `format`
- Validates `rm -rf` against safe path list
- Checks for dangerous patterns (fork bombs, etc.)
- Handles command chaining (`&&`, `;`, `||`)
- Logs all security events
- Shows confirmation prompt for risky commands

**Safe Paths for `rm -rf`:**
- `/tmp/`, `/var/tmp/`
- Current working directory
- User-specific paths
- Relative paths within project

**Always Blocked:**
- System directories: `/etc`, `/usr`, `/bin`, `/sys`, `/proc`, `/boot`
- Privilege escalation: `sudo`, `su`, `passwd`
- Network tools: `nc`, `nmap`, `telnet`
- System services: `systemctl`, `kill`, `mount`

**Why `--dangerously-skip-permissions` is Safe:**
The PreToolUse hook with validator provides more intelligent protection than blanket permission prompts. See `templates/ides/claude/SHELL-SETUP.md` for details.

## Critical Workflows

### Installation Workflow

1. Checks dependencies (`curl`, `git`)
2. Verifies git working directory is clean
3. Clones templates from GitHub (or uses local)
4. Prompts for project name
5. Creates `.ai/` structure from templates
6. Installs core plugin (always included)
7. Creates `.ai/config.jsonc` with plugin list
8. Runs `.ai/cli configure` for IDE setup
9. Updates `.gitignore` with IDE-specific entries

### Plugin Installation

```bash
.ai/cli plugins add lang-node
```

**Process:**
1. Validates plugin exists in `templates/plugins/`
2. Copies plugin folders to `.ai/<type>/<plugin>/`
3. Updates `.ai/config.jsonc` with new plugin
4. Files immediately available via symlinks (no restart needed)

### Update Workflow

```bash
.ai/cli update
```

**Process:**
1. Checks git working directory is clean
2. Reads installed plugins from `.ai/config.jsonc`
3. Downloads latest `update.sh` script
4. Re-installs all plugins from latest templates
5. Updates base templates and CLI
6. Preserves custom files (non-plugin files in `.ai/`)

**Important:** Custom files should be at `.ai/` root level, not in plugin folders (plugins get overwritten on update)

### Migration Workflow

```bash
.ai/cli migrate              # Terminal: shows instructions
/core:migrate                # IDE: performs migration
```

**Critical Rule - ZERO TEXT MODIFICATION:**
- Copy content character-by-character
- No typo fixes, no grammar improvements
- No rewording or clarifications
- "You are a MOVER, not an EDITOR"

**Process:**
1. Finds documentation (README.md, CLAUDE.md, *.mdc)
2. Renames `.template.md` files to `.md`
3. Extracts content sections matching context topics
4. Copies content EXACTLY to `.ai/context/` files
5. Removes extracted content from originals
6. Adds breadcrumb comments showing new locations
7. Renames CLAUDE.md to AGENTS.md
8. Reports what was moved

## Plugin System

### Available Plugins

| Plugin | Purpose | Contents |
|--------|---------|----------|
| `core` | Essential functionality | 7 commands, 5 agents, templates |
| `git` | Git commit automation | 1 command, 1 context |
| `github` | GitHub PR/issue workflows | 3 commands |
| `code-quality` | Code analysis/optimization | 5 commands |
| `image-manipulation` | Image processing | 1 command |
| `lang-node` | Node.js support | 1 command, 4 context files |
| `lang-typescript` | TypeScript support | Context files |
| `lang-go` | Go support | Context files |
| `lang-ruby` | Ruby support | Context files |
| `lang-vue` | Vue.js support | Context files |

### Core Plugin Commands

- `migrate.md` - Migrate documentation to `.ai/context/`
- `command-create.md` - Create new slash commands
- `agent-create.md` - Create specialized agents
- `avatar-create.md` - Create AI behavior profiles
- `context-cleanup.md` - Optimize context files
- `deep-search.md` - Deep codebase research
- `feature-create.md` - EPCT methodology implementation

### Core Plugin Agents

- `explore-codebase.md` - Find relevant code patterns
- `fast-coder.md` - Quick implementations
- `prompt-engineering.md` - Improve prompts/agents
- `deep-search.md` - Research agent
- `websearch.md` - Web research agent

### Creating a New Plugin

```bash
# 1. Create plugin structure
mkdir -p templates/plugins/my-plugin/{commands,agents,context}

# 2. Add markdown files
# commands/*.md - Slash commands
# agents/*.md - Specialized agents
# context/*.md - Documentation

# 3. Install it
.ai/cli plugins add my-plugin

# 4. Commit to templates/ for sharing
git add templates/plugins/my-plugin/
git commit -m "feat: add my-plugin"
```

**Plugin File Format (commands):**
```markdown
---
description: What this command does
allowed-tools: Tool1, Tool2
argument-hint: <arg1> <arg2>
---

Command instructions for AI...
```

## Configuration Files

### `.ai/config.jsonc`

```jsonc
{
  // Unified AI Configuration
  // This file is committed to git and shared across the team

  "version": "1.0.0",

  // Installed plugins
  "plugins": ["core", "lang-node", "github"]
}
```

**Key Points:**
- JSONC format allows comments
- Committed to git
- Shared across team
- Updated by `.ai/cli plugins add`
- Parsed with `jq` or regex fallback

### `.ai/AGENTS.md`

Main configuration file that all IDEs read. Contains:
- Project structure explanation
- How to use the configuration
- Context organization strategy
- Development guidelines
- Links to context files

**Template Variables:**
- `{{PROJECT_NAME}}` - Project name
- `{{PROJECT_DESC}}` - Project description
- `{{FRAMEWORK}}` - Technology stack

### `.claude/settings.json`

Claude Code configuration including:
- Permission allowlist for safe commands
- PreToolUse hook with command validator
- Stop/Notification hooks with audio feedback
- Custom status line script
- Always thinking enabled

## Important Patterns

### JSONC Parsing

Since config contains comments, use two-step parsing:

```bash
# 1. Strip comments
config_json=$(grep -v '^\s*//' .ai/config.jsonc | sed 's|//.*||g')

# 2. Parse with jq (or fallback regex)
if command -v jq &> /dev/null; then
    plugins=$(echo "$config_json" | jq -r '.plugins[]')
else
    # Regex fallback
    plugins=$(echo "$config_json" | grep -o '"plugins":\s*\[.*\]' | ...)
fi
```

### Symlink Creation

**Claude Code (same depth):**
```bash
ln -sf ../.ai/commands .claude/commands
```

**Cursor (different depth):**
```bash
ln -sf ../../.ai/AGENTS.md .cursor/rules/main.mdc
```

### Development Mode Detection

```bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -d "$SCRIPT_DIR/templates/plugins" ]; then
    # Development mode - use local templates
    PLUGINS_DIR="$SCRIPT_DIR/templates/plugins"
else
    # Production mode - download from GitHub
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 --quiet "$REPO_URL" "$TEMP_DIR"
    PLUGINS_DIR="$TEMP_DIR/templates/plugins"
fi
```

### Preserving User Customizations

During IDE reconfiguration:
```bash
# Copy non-symlink files from .claude/ to .ai/
find .claude/commands -type f ! -type l -name "*.md" | while read file; do
    cp "$file" ".ai/commands/"
done
```

## EPCT Methodology

Used by `/core:feature-create` command:

1. **EXPLORE**: Use agents to search codebase and web for context
2. **PLAN**: Create detailed strategy, ask user to clarify ambiguities
3. **CODE**: Follow existing patterns, stay within scope
4. **TEST**: Run relevant tests, fix failures before completing

## Git Workflow

### What Gets Committed

**✅ Commit:**
- `.ai/` folder (entire directory)
- `.ai/config.jsonc` (team configuration)
- Custom files in `.ai/` root (not in plugin folders)

**❌ Gitignore:**
- `.claude/` folder (generated symlinks)
- `.cursor/` folder (generated symlinks)
- IDE-specific files

### Team Collaboration

**New team member setup:**
```bash
git clone <repo>
cd <repo>
.ai/cli configure  # Choose your IDE
# Configuration already in .ai/, plugins auto-available
```

**Benefits:**
- Configuration in git (`.ai/config.jsonc`)
- Each developer picks their IDE
- Plugins auto-available
- No manual sync needed

## Code Quality Standards

### When Modifying Core Files

- **install.sh**: Ensure git status checks before destructive operations
- **update.sh**: Preserve custom files (non-plugin files)
- **.ai/cli**: Maintain fallback parsing for systems without `jq`
- **init.sh scripts**: Always backup before cleanup

### When Creating Plugins

- Use clear, descriptive command names
- Include comprehensive agent instructions
- Add context files for domain knowledge
- Test installation/removal cycle
- Document in plugin README if complex

### When Adding IDE Support

- Follow pattern in `templates/ides/CONTRIBUTE.md`
- Implement all standard functions in init.sh
- Test with both fresh install and update scenarios
- Handle edge cases (existing config, partial installs)
- Update main README with IDE status

## File Locations Reference

- **CLI**: `.ai/cli` (bash script, ~465 lines)
- **Validator**: `.ai/scripts/validate-command.mjs` (Node.js, ~627 lines)
- **Install**: `install.sh` (bash, ~199 lines)
- **Update**: `update.sh` (bash, ~138 lines)
- **Claude Init**: `templates/ides/claude/init.sh`
- **Cursor Init**: `templates/ides/cursor/init.sh`
- **Shell Setup Guide**: `templates/ides/claude/SHELL-SETUP.md`
- **IDE Contribution Guide**: `templates/ides/CONTRIBUTE.md`

## Recommended Aliases

Add to `~/.zshrc` or `~/.bashrc`:

```bash
alias cc="claude --dangerously-skip-permissions"
alias ccc="claude --dangerously-skip-permissions -c"
```

See `templates/ides/claude/SHELL-SETUP.md` for detailed explanation of why this is safe with PreToolUse hooks.
