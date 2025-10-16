# AI CLI - Single Source of Truth for AI Assistant Configurations

> Unified AI configuration management across IDEs - because your team shouldn't maintain duplicate configs

## 🎯 The Problem

Modern development teams face a configuration nightmare when using AI assistants:

**Different IDEs, Different Configs** 🤯
- Your team uses Claude Code, Cursor, Windsurf, or other AI tools
- Each tool requires its own configuration format
- You end up duplicating commands, agents, and guidelines across tools
- Changes need to be manually synced everywhere
- No single source of truth = configuration drift

**Existing Solutions Fall Short:**
- **[github/spec-kit](https://github.com/github/spec-kit)**: Copies commands to each IDE, creating duplication
- **[Melvynx/aiblueprint](https://github.com/Melvynx/aiblueprint)**: Great inspiration (thank you [@Melvynx](https://github.com/Melvynx)!), but still requires per-IDE management

## ✨ The Solution

**AI CLI provides a single `.ai/` folder as your source of truth**, automatically syncing to any IDE your team uses.

### Key Benefits

- ✅ **Write once, use everywhere** - One configuration, all IDEs
- ✅ **Git-friendly** - Commit only `.ai/`, IDE configs are generated
- ✅ **Team synchronization** - Everyone gets the same guidelines
- ✅ **Dynamic updates** - Add a file to `.ai/`, it appears in your IDE instantly
- ✅ **Backup protection** - Existing configurations are preserved in `.tmp/`
- ✅ **Works everywhere** - Any bash system (macOS, Linux, WSL)

## 📦 Installation

### One-Command Setup

```bash
curl -fsSL https://raw.githubusercontent.com/betagouv/ai-cli/main/install.sh | bash
```

**What happens during installation:**

1. **Discovers your project**
   - Prompts for project name, description, and framework
   - Asks which contexts you need (Node, TypeScript, Go, Ruby, Vue)

2. **Creates `.ai/` structure**
   - Sets up `AGENTS.md` (main configuration)
   - Creates `context/`, `commands/`, `agents/`, `avatars/` folders
   - Copies selected context templates

3. **Asks which IDEs you use**
   - Claude Code
   - Cursor
   - (More coming soon - contributions welcome!)

4. **Runs IDE setup**
   - Backs up any existing configuration to `.tmp/`
   - Preserves your custom files (copies them to `.ai/`)
   - Creates symlinks or generated files for your IDE

5. **Updates `.gitignore`**
   - Ignores generated IDE folders
   - Ignores `.tmp/` backup folder

### Result

```
your-project/
├── .ai/                          # ✅ Commit this (source of truth)
│   ├── AGENTS.md                 # Main config file
│   ├── context/                  # Project knowledge
│   ├── commands/                 # Custom slash commands
│   ├── agents/                   # Specialized agents
│   └── avatars/                  # AI behavior profiles
│
├── .claude/                      # ❌ Generated (gitignored)
│   ├── CLAUDE.md → .ai/AGENTS.md
│   ├── commands/ → .ai/commands/
│   └── ...
│
├── .cursor/                      # ❌ Generated (gitignored)
│   └── rules/
│       ├── main.mdc → .ai/AGENTS.md
│       └── context/ → .ai/context/
│
└── .tmp/                         # ❌ Your old configs (safe backup)
    └── claude.backup_20251016_143022/
```

## 🚀 Quick Start

### 1. Install

```bash
curl -fsSL https://raw.githubusercontent.com/betagouv/ai-cli/main/install.sh | bash
```

### 2. Initialize Context Files

If you already have documentation scattered across `README.md`, `CLAUDE.md`, or `AGENTS.md` files:

```bash
/ai-cli-init
```

This command:
- Finds all documentation in your codebase
- Extracts relevant sections
- Organizes them into `.ai/context/` files
- **Preserves original text exactly** (no AI rewriting)
- **Removes extracted content** from original files to avoid duplicates
- Leaves breadcrumb comments showing where content moved
- **Keeps human-facing sections** in README.md (Installation, Usage, etc.)
- **If no documentation found**: Suggests using `/explore-codebase` to generate from code

### 3. Commit Your Configuration

```bash
git add .ai/
git commit -m "feat: add AI configuration"
git push
```

### 4. Team Members Pull and Sync

```bash
git pull
# IDE configs update automatically via symlinks!
# Or re-run init if needed:
bash templates/ides/claude/init.sh
```

## 📁 Architecture

```
.ai/                              # Your single source of truth
├── AGENTS.md                     # Main configuration file
│
├── context/                      # Project knowledge base
│   ├── ARCHITECTURE.md           # System design, tech stack
│   ├── OVERVIEW.md               # Project description, features
│   ├── TESTING.md                # Testing strategy
│   ├── DATABASE.md               # Schema, queries, migrations
│   ├── GIT-WORKFLOW.md           # Branching, commits, PRs
│   │
│   ├── node/                     # Node.js specific
│   │   ├── CODE-STYLE.md         # JavaScript/Node standards
│   │   ├── DEPENDENCIES.md       # npm, package management
│   │   ├── PERFORMANCE.md        # Optimization patterns
│   │   └── TESTING.md            # Node test frameworks
│   │
│   ├── typescript/               # TypeScript specific
│   │   └── CODE-STYLE.md
│   │
│   ├── go/                       # Go specific
│   │   └── CODE-STYLE.md
│   │
│   └── vue/                      # Vue specific
│       └── CODE-STYLE.md
│
├── commands/                     # Custom slash commands
│   └── ai-cli-init.md            # /ai-cli-init command
│
├── agents/                       # Specialized agents
│   └── .gitkeep
│
└── avatars/                      # AI behavior profiles
    └── .gitkeep
```

## 🛠️ Available Commands

Once installed, you have access to custom slash commands in Claude Code:

### `/ai-cli-init`

**Purpose**: Initialize `.ai/context/` files from existing documentation

**What it does**:
1. Scans your codebase for `README.md`, `CLAUDE.md`, `AGENTS.md` (excluding `.ai/` folder)
2. Identifies sections like "Architecture", "Testing", "Coding Guidelines", etc.
3. Maps them to appropriate context files (e.g., "Coding Guidelines" → `CODING-STYLE.md`)
4. **Preserves original text exactly** - no AI rewriting or improvements
5. Adds source comments to track where content came from
6. **Removes extracted sections** from original files to avoid duplicates
7. Leaves breadcrumb comments (e.g., `<!-- Moved to .ai/context/ARCHITECTURE.md -->`)
8. **Keeps human-facing sections** in README.md (Installation, Usage, License, etc.)
9. **If no documentation found**: Suggests using `/explore-codebase` to generate from code analysis

**Usage**:
```bash
# In Claude Code
/ai-cli-init

# If no documentation exists, follow up with:
/explore-codebase
```

**Example output**:
```
✓ Processed Files:
  - README.md (3 sections extracted, 3 sections removed)
  - .claude/CLAUDE.md (5 sections extracted, 5 sections removed)

✓ Updated Context Files:
  - ARCHITECTURE.md (2 sections added)
  - CODING-STYLE.md (1 section added)
  - OVERVIEW.md (3 sections added)

✓ Cleaned Original Files:
  - README.md (removed "Architecture", "Testing", "Code Style")
  - .claude/CLAUDE.md (removed "System Design", "Guidelines", etc.)
  - Breadcrumb comments added to show new locations

# Or if no documentation:
⚠️ No documentation files found.
💡 Run /explore-codebase to generate documentation from your codebase.
```

## 🔧 How It Works

### For Claude Code (Symlinks)

```bash
bash templates/ides/claude/init.sh
```

**Creates symlinks**:
- `.claude/CLAUDE.md` → `.ai/AGENTS.md`
- `.claude/commands/` → `.ai/commands/`
- `.claude/agents/` → `.ai/agents/`
- `.claude/output-styles/` → `.ai/avatars/`

**Why symlinks?**
- ✅ **Dynamic**: Add a file to `.ai/commands/`, it appears instantly in Claude
- ✅ **No sync needed**: Changes to `.ai/` are immediately available
- ✅ **Git-friendly**: Only commit `.ai/`, symlinks are regenerated

### For Cursor (Symlinks)

```bash
bash templates/ides/cursor/init.sh
```

**Creates symlinks**:
- `.cursor/rules/main.mdc` → `.ai/AGENTS.md`
- `.cursor/rules/context/` → `.ai/context/`

**Reference in Cursor**:
- `@.cursor/rules/main.mdc`
- `@.cursor/rules/context/architecture.md`

## 🔄 Daily Workflow

### Adding a Command

```bash
# 1. Create command file
cat > .ai/commands/deploy.md << 'EOF'
---
description: Deploy application to production
---

You are a deployment specialist...
EOF

# 2. Already available in Claude Code!
# Just use: /deploy

# 3. Commit
git add .ai/commands/deploy.md
git commit -m "feat: add deploy command"
```

### Updating Guidelines

```bash
# 1. Edit source of truth
vim .ai/context/node/CODE-STYLE.md

# 2. Changes are instantly available (symlinks)
# For Cursor, re-run if needed:
bash templates/ides/cursor/init.sh

# 3. Commit
git add .ai/context/node/CODE-STYLE.md
git commit -m "docs: update Node.js code style"
```

### Pulling Team Changes

```bash
git pull

# Claude: Nothing to do (symlinks update automatically)
# Cursor: Re-run init if context changed
bash templates/ides/cursor/init.sh
```

## 🎯 IDE Support

| IDE | Status | Configuration |
|-----|--------|---------------|
| **Claude Code** | ✅ Full | `.claude/` (symlinks) |
| **Cursor** | ✅ Full | `.cursor/rules/` (symlinks) |
| **Others** | 🔜 Coming | [Contribute!](templates/ides/CONTRIBUTE.md) |

## 🤝 Contributing

Want to add support for your favorite IDE?

See **[templates/ides/CONTRIBUTE.md](templates/ides/CONTRIBUTE.md)** for a step-by-step guide on adding IDE support.

**Quick summary**:
1. Create `templates/ides/your-ide/init.sh`
2. Follow the function-based pattern (see `claude/init.sh`)
3. Preserve user customizations
4. Create symlinks or generate config files
5. Test thoroughly

## 🙏 Acknowledgments

This project was heavily inspired by [@Melvynx](https://github.com/Melvynx)'s excellent [aiblueprint](https://github.com/Melvynx/aiblueprint). Thank you for paving the way!

## 📄 License

MIT

## 💬 Support

- **Issues**: [GitHub Issues](https://github.com/betagouv/ai-cli/issues)
- **Discussions**: [GitHub Discussions](https://github.com/betagouv/ai-cli/discussions)

---

**Made with ❤️ for developers tired of config duplication**
