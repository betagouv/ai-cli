# AI CLI - Plugin-Based AI Configuration

> **🚀 Ultra-Simple Setup** - One command, choose your IDE, and you're ready to code with AI!

> Unified AI configuration with modular plugins - install only what you need

## 🎯 The Problem

Modern development teams face a configuration nightmare when using AI assistants:

**Different IDEs, Different Configs** 🤯
- Your team uses Claude Code, Cursor, Windsurf, or other AI tools
- Each tool requires its own configuration format
- You end up duplicating commands, agents, and guidelines across tools
- Changes need to be manually synced everywhere
- No single source of truth = configuration drift

## ✨ The Solution

**AI CLI provides a single `.ai/` folder as your source of truth**, with a **modular plugin system** to install only what you need.

### Key Benefits

- ✅ **Ultra-fast setup** - One question: which IDE?
- ✅ **Modular plugins** - Install only what you need
- ✅ **Write once, use everywhere** - One configuration, all IDEs
- ✅ **Git-friendly** - Commit only `.ai/`, configs are generated
- ✅ **Easy updates** - `ai-cli update` to get latest
- ✅ **Team synchronization** - Everyone gets the same setup
- ✅ **Works everywhere** - Any bash system (macOS, Linux, WSL)

## 📦 Installation

### One-Command Setup

```bash
curl -fsSL https://raw.githubusercontent.com/betagouv/ai-cli/main/install.sh | bash
```

**What happens:**

1. **Creates `.ai/` structure**
   - Sets up `AGENTS.md` (main configuration)
   - Creates `context/`, `commands/`, `agents/`, `avatars/` folders

2. **Installs core plugin automatically**
   - Essential commands: `/ai-cli-init`, `/command-create`, `/agent-create`, etc.
   - Essential agents: `explore-codebase`, `prompt-engineering`, `fast-coder`

3. **Creates `.ai/config.jsonc`** (committed to git)
   - Stores installed plugins
   - Shared across the team with JSONC format (supports comments)

4. **Asks which IDE(s) you want to configure**
   - Claude Code
   - Cursor
   - You can select multiple (e.g., "1 2" for both)
   - Creates symlinks for each selected IDE
   - Updates `.gitignore` automatically

### Result

```
your-project/
├── .ai/                          # ✅ Commit this (source of truth)
│   ├── AGENTS.md                 # Main config file
│   ├── config.jsonc              # ✅ Configuration (committed, supports comments)
│   ├── cli                       # Plugin manager CLI
│   ├── context/                  # Project knowledge
│   ├── commands/                 # Slash commands (from plugins)
│   ├── agents/                   # Specialized agents (from plugins)
│   └── avatars/                  # AI behavior profiles
│
├── .claude/                      # ❌ Generated (gitignored)
│   └── [symlinks to .ai/]
│
└── .cursor/                      # ❌ Generated (gitignored)
    └── [symlinks to .ai/]
```

## 🔌 Plugin System

### Available Plugins

```bash
# List all available plugins
.ai/cli plugins list

# Output:
#   ✓ core (installed)
#     github
#     code-quality
#     git
#     image-manipulation
#     lang-node
#     lang-typescript
#     lang-go
#     lang-ruby
#     lang-vue
```

### Plugin Overview

| Plugin | Description | Contains |
|--------|-------------|----------|
| **core** | Essential commands & agents | `/ai-cli-init`, `/command-create`, `/agent-create`, `/deep-search`, `fast-coder`, `explore-codebase` |
| **github** | GitHub workflow automation | `/code-issue-process`, `/code-pr-create`, `/code-pr-process-comments` |
| **code-quality** | Code analysis & optimization | `/code-analyse`, `/code-ci`, `/code-clean`, `/code-explain`, `/code-optimize` |
| **git** | Git commit automation | `/code-commit` |
| **image-manipulation** | Image processing | `/image2md` |
| **lang-node** | Node.js context & tools | Node.js code style, dependencies, performance, testing, `/code-fix` |
| **lang-typescript** | TypeScript context | TypeScript code style and best practices |
| **lang-go** | Go context | Go code style and idioms |
| **lang-ruby** | Ruby context | Ruby code style and conventions |
| **lang-vue** | Vue.js context | Vue.js patterns and best practices |

### Install Plugins

```bash
# Install a plugin
.ai/cli plugins add lang-node

# Install multiple plugins
.ai/cli plugins add lang-typescript
.ai/cli plugins add github
.ai/cli plugins add code-quality

# Plugins are added to .ai/ and listed in .ai/config.jsonc
```

### Update

```bash
# Update ai-cli and all installed plugins
.ai/cli update

# Checks git status first (must be clean)
# Downloads latest version
# Re-installs your plugins
# Updates IDE configuration
```

## 🚀 Quick Start

### 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/betagouv/ai-cli/main/install.sh | bash
```

### 2. Add Plugins (Optional)

```bash
# See what's available
.ai/cli plugins list

# Install language support
.ai/cli plugins add lang-node
.ai/cli plugins add lang-typescript

# Install GitHub integration
.ai/cli plugins add github
```

### 3. Initialize Context Files

```bash
# In Claude Code or Cursor
/ai-cli-init
```

This command:
- Finds all documentation in your codebase
- Extracts relevant sections
- Organizes them into `.ai/context/` files
- Removes extracted content from original files

### 4. Commit Your Configuration

```bash
git add .ai/
git commit -m "feat: add AI configuration"
git push
```

**Note:** `.ai/config.jsonc` is committed and shared across the team!

## 📁 Architecture

```
.ai/                              # Your single source of truth
├── AGENTS.md                     # Main configuration file
│
├── context/                      # Project knowledge base
│   ├── ARCHITECTURE.md           # System design, tech stack
│   ├── OVERVIEW.md               # Project description
│   ├── TESTING.md                # Testing strategy
│   ├── DATABASE.md               # Schema, queries
│   ├── GIT-WORKFLOW.md           # Branching, commits, PRs
│   │
│   └── node/                     # From lang-node plugin
│       ├── CODE-STYLE.md
│       ├── DEPENDENCIES.md
│       ├── PERFORMANCE.md
│       └── TESTING.md
│
├── commands/                     # From plugins
│   ├── ai-cli-init.md            # core
│   ├── command-create.md         # core
│   ├── agent-create.md           # core
│   ├── code-pr-create.md         # github
│   └── code-commit.md            # git
│
├── agents/                       # From plugins
│   ├── fast-coder.md             # core (fast edits)
│   ├── explore-codebase.md       # core
│   └── prompt-engineering.md     # core
│
└── avatars/                      # AI behavior profiles
    └── .gitkeep
```

## 🛠️ CLI Commands

### IDE Configuration

```bash
# Configure IDE symlinks (can run multiple times to add more IDEs)
.ai/cli configure
```

### Plugin Management

```bash
# List available plugins
.ai/cli plugins list

# Install a plugin
.ai/cli plugins add <plugin-name>

# Examples
.ai/cli plugins add lang-node
.ai/cli plugins add github
.ai/cli plugins add code-quality
```

### Update

```bash
# Update ai-cli and installed plugins
.ai/cli update
```

### Help

```bash
# Show help
.ai/cli help
```

## 📚 Core Plugin Commands

Once installed, you have access to these commands:

### `/ai-cli-init`

Initialize `.ai/context/` files from existing documentation

### `/command-create`

Create a new slash command

### `/agent-create`

Create a new specialized agent

### `/context-cleanup`

Optimize and clean up context files

### `/deep-search`

Perform deep research on a topic

### `/avatar-create`

Create a new AI personality/output style

### `/feature-create`

Scaffold a new feature with EPCT methodology

## 🔄 Daily Workflow

### Adding a Plugin

```bash
# Discover available plugins
.ai/cli plugins list

# Install what you need
.ai/cli plugins add code-quality

# Commands appear instantly in your IDE
/code-analyse
```

### Updating

```bash
# Get latest updates
.ai/cli update

# Your installed plugins are automatically updated
```

### Team Synchronization

```bash
# Pull changes
git pull

# Configuration is in .ai/config.jsonc - shared across the team
# If new plugins were added, they'll be automatically available

# Configure your IDE locally (each dev chooses their own IDE)
.ai/cli configure
```

**Note:** IDE configuration is local (gitignored) - each developer can use different IDEs!

## 🎯 IDE Support

| IDE | Status | Configuration |
|-----|--------|---------------|
| **Claude Code** | ✅ Full | `.claude/` (symlinks) |
| **Cursor** | ✅ Full | `.cursor/` (symlinks) |
| **Others** | 🔜 Coming | [Contribute!](templates/ides/CONTRIBUTE.md) |

## 🤝 Contributing

Want to add support for your favorite IDE or create a plugin?

See **[templates/ides/CONTRIBUTE.md](templates/ides/CONTRIBUTE.md)** for IDE integration guide.

For plugins, just create a folder in `templates/plugins/` with your plugin name and structure:

```
templates/plugins/my-plugin/
├── commands/
│   └── my-command.md
├── agents/
│   └── my-agent.md
└── context/
    └── MY-CONTEXT.md
```

## 📚 Getting Started with AI Development

To get the most out of this project and AI-assisted development, we recommend getting proper training in AI development practices.

**We recommend [Melvynx's AI Blueprint training](https://aiblueprint.dev/?ref=aJmHMnVnfaK)** to understand how to best work with AI assistants.

## 🙏 Acknowledgments

This project was heavily inspired by [@Melvynx](https://github.com/Melvynx)'s excellent [aiblueprint](https://github.com/Melvynx/aiblueprint). Thank you!

## 📄 License

MIT

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/betagouv/ai-cli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/betagouv/ai-cli/discussions)
- **Mattermost**: [Beta Gouv AI Channel](https://mattermost.incubateur.net/betagouv/channels/domaine-dev-ai-workflows)

---

**Made with ❤️ for developers who want simple, modular AI configuration**
