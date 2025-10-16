# AI Configuration for {{PROJECT_NAME}}

> Central configuration file for all AI assistants working on this project

## 📁 Project Structure

This project uses a unified `.ai/` folder to configure all AI tools (Claude Code, Cursor, Windsurf, GitHub Copilot, etc.).

```
.ai/
├── AGENTS.md              # This file - main configuration
├── context/               # Project knowledge and guidelines
│   ├── node/             # Node.js/JavaScript specific context
│   ├── typescript/       # TypeScript specific context
│   ├── go/               # Go specific context
│   ├── ruby/             # Ruby specific context
│   └── vue/              # Vue.js specific context
├── commands/             # Custom slash commands
├── agents/               # Specialized agents
└── avatars/              # AI behavior profiles
```

## 🎯 How to Use This Configuration

### For AI Models

When working on this codebase, you should:

1. **Read this file first** - It contains the main project directives
2. **Check context folders** - Language/framework-specific guidelines are in `.ai/context/<language>/`
3. **Look for local documentation** - Each module may have:
   - `README.md` - Module overview and usage
   - `AGENTS.md` or `CLAUDE.md` - AI-specific directives for that module

**Example**: When working in a Node.js module:
- Read `.ai/context/node/` for Node.js best practices
- Check the module's `README.md` for module-specific context
- Check for `AGENTS.md` in the module folder for additional AI directives

### IDE-Specific Symlinks

Each IDE tool creates symlinks to this file with their preferred naming:
- **Claude Code**: `.claude/CLAUDE.md` → `.ai/AGENTS.md`
- **Cursor**: `.cursor/rules/main.mdc` → `.ai/AGENTS.md`
- **Windsurf**: `.windsurf/rules/main.md` → `.ai/AGENTS.md`
- **GitHub Copilot**: `.github/copilot-instructions.md` → `.ai/AGENTS.md`

This keeps the configuration tool-agnostic while supporting all IDEs.

## 📚 Context Organization

### Global Context

All cross-cutting concerns and project-wide guidelines should be documented in `.ai/context/` or this file.

### Language-Specific Context

Language or framework-specific guidelines go in their respective folders:
- `.ai/context/node/` - Node.js/JavaScript patterns, npm scripts, package.json conventions
- `.ai/context/typescript/` - TypeScript configuration, types, strict mode rules
- `.ai/context/go/` - Go idioms, project structure, error handling
- `.ai/context/ruby/` - Ruby conventions, gems, Rails patterns
- `.ai/context/vue/` - Vue.js components, composition API, routing

### Module-Specific Context

For module or feature-specific directives, create an `AGENTS.md` (or `README.md`) in that module's folder:

```
src/
├── auth/
│   ├── AGENTS.md          # Authentication-specific AI directives
│   └── ...
└── billing/
    ├── AGENTS.md          # Billing-specific AI directives
    └── ...
```

## 🎯 Project Information

**Project**: {{PROJECT_NAME}}
**Description**: {{PROJECT_DESC}}
**Tech Stack**: {{FRAMEWORK}}

## 💡 Development Guidelines

[Add your project-specific guidelines here]

### Code Style
- Follow language-specific conventions in `.ai/context/<language>/`
- Use consistent formatting (Prettier/ESLint/etc.)
- Write self-documenting code with clear names

### Testing
- Write tests for all business logic
- Maintain high coverage for critical paths
- Test edge cases and error handling

### Documentation
- Update README.md when adding features
- Document complex algorithms in comments
- Keep AGENTS.md files up to date

## 🔧 Commands Available

Custom slash commands are available in `.ai/commands/`. Check that folder for available automation.

## 👥 AI Agents

Specialized agents are configured in `.ai/agents/` for complex tasks like codebase exploration, deep search, etc.

---

**Note for AI Models**: This configuration is version-controlled. Always respect the guidelines defined here and in the context folders.
