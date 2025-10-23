# Architecture Documentation

> Software architecture documentation for agnostic-ai

## 🎯 Introduction and Goals

### Business Context

<!-- Describe the business problem this software solves -->

**What**: {{PROJECT_DESC}}

**Why**: [Why does this software exist? What business value does it provide?]

**For whom**: [Target users, stakeholders]

### Quality Goals

<!-- Top 3-5 quality attributes in order of priority -->

1. **[Quality Goal 1]**: [e.g., Performance - Response time < 200ms]
2. **[Quality Goal 2]**: [e.g., Security - GDPR compliance]
3. **[Quality Goal 3]**: [e.g., Maintainability - Easy to onboard new developers]

## 📐 Constraints

### Technical Constraints

- **Framework/Language**: Core
- **Deployment**: [Cloud provider, hosting environment]
- **Databases**: [PostgreSQL, MongoDB, Redis, etc.]
- **External APIs**: [Third-party services]

### Organizational Constraints

- **Team size**: [Number of developers]
- **Timeline**: [Project deadlines]
- **Budget**: [Infrastructure costs]

## 🌍 System Context

### External Interfaces

<!-- What external systems does this software interact with? -->

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
┌──────▼──────────┐      ┌──────────────┐
│  agnostic-ai │◄────►│  External API │
└──────┬──────────┘      └──────────────┘
       │
┌──────▼──────┐
│  Database   │
└─────────────┘
```

### Users and Roles

- **[Role 1]**: [Permissions, use cases]
- **[Role 2]**: [Permissions, use cases]

## 🏗️ Solution Strategy

### Architecture Pattern

[e.g., Monolithic, Microservices, Serverless, Modular monolith]

### Technology Decisions

| Decision | Rationale |
|----------|-----------|
| Core | [Why this framework?] |
| [Database] | [Why this database?] |
| [Hosting] | [Why this hosting?] |

### Key Design Decisions

<!-- Link to ADRs (Architecture Decision Records) if you use them -->

- **[Decision 1]**: [Brief explanation or link to ADR]
- **[Decision 2]**: [Brief explanation or link to ADR]

## 🧱 Building Block View

### High-Level Structure

```
project/
├── src/
│   ├── [module1]/          # [Description]
│   ├── [module2]/          # [Description]
│   ├── components/         # Shared UI components
│   ├── utils/              # Utility functions
│   └── config/             # Configuration
├── tests/
└── docs/
```

### Module Organization

#### Module: [Module Name]

**Purpose**: [What does this module do?]

**Dependencies**: [What does it depend on?]

**Public API**: [What does it expose?]

**Location**: `src/[module-name]/`

## ⚡ Runtime View

### Key Scenarios

#### Scenario: [User Action]

```
User → Frontend → API → Service → Database
  │        │        │       │         │
  │────────┼────────┼───────┼─────────┤
  │        │        │       │         │
  │        │        │       │         │
  └────────┴────────┴───────┴─────────┘
```

**Steps**:
1. User initiates [action]
2. Frontend validates and sends request
3. API authenticates and authorizes
4. Service processes business logic
5. Database persists changes
6. Response flows back to user

## 🚀 Deployment View

### Infrastructure

[Describe hosting, CI/CD, monitoring]

```
┌─────────────────┐
│   CDN/Edge      │
└────────┬────────┘
         │
┌────────▼────────┐
│  Load Balancer  │
└────────┬────────┘
         │
    ┌────┴────┐
┌───▼──┐  ┌───▼──┐
│ App1 │  │ App2 │
└───┬──┘  └───┬──┘
    └────┬────┘
    ┌────▼────┐
    │   DB    │
    └─────────┘
```

### Environments

- **Development**: [Description]
- **Staging**: [Description]
- **Production**: [Description]

## 🔧 Cross-Cutting Concepts

### Authentication & Authorization

[How users are authenticated and authorized]

### Error Handling

[How errors are handled, logged, and reported to users]

### Logging & Monitoring

[What is logged, where, and how to access logs]

### Performance

[Caching strategy, optimization techniques]

### Security

[Security measures, see also: SECURITY.md]

## 🎨 Design Decisions

### Architectural Decision Records (ADRs)

[If using ADRs, link to them here or list key decisions]

**Example**:
- **ADR-001**: [Use PostgreSQL for main database]
- **ADR-002**: [Adopt module-based architecture]

## 📊 Quality Requirements

### Performance

- **Response time**: < 200ms for 95th percentile
- **Throughput**: [Requests per second]
- **Availability**: 99.9% uptime

### Security

- **Authentication**: JWT with refresh tokens
- **Data encryption**: At rest and in transit
- **Compliance**: GDPR, [other regulations]

### Maintainability

- **Test coverage**: > 80%
- **Code review**: Required for all changes
- **Documentation**: Keep up to date with code

## ⚠️ Risks and Technical Debt

### Current Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| [Risk 1] | High/Med/Low | [How to mitigate] |
| [Risk 2] | High/Med/Low | [How to mitigate] |

### Known Technical Debt

- **[Debt Item 1]**: [Description, priority]
- **[Debt Item 2]**: [Description, priority]

## 📚 Glossary

| Term | Definition |
|------|------------|
| [Term 1] | [Definition] |
| [Term 2] | [Definition] |

---

## 📝 Maintenance

**Last updated**: [Date]
**Maintained by**: [Team/Person]
**Review frequency**: [Quarterly, when architecture changes]

## 🔗 Related Documentation

- [README.md](../../README.md) - Project overview and setup
- [SECURITY.md](./SECURITY.md) - Security guidelines
- [TESTING.md](./TESTING.md) - Testing strategy
- Module-specific docs: Check `AGENTS.md` in each module folder

<!-- Source: CLAUDE.md -->

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

<!-- Source: README.md -->

## 📁 Architecture

```
.ai/                              # Your single source of truth
├── AGENTS.md                     # Main configuration file
├── config.jsonc                  # Plugin configuration
├── cli                           # Plugin manager
│
├── commands/                     # Commands (plugins + custom)
│   ├── core/                     # Core plugin
│   │   ├── migrate.md
│   │   ├── command-create.md
│   │   └── agent-create.md
│   ├── github/                   # GitHub plugin
│   │   ├── code-pr-create.md
│   │   └── code-issue-process.md
│   ├── git/                      # Git plugin
│   │   └── code-commit.md
│   └── my-custom-cmd.md          # Custom command
│
├── agents/                       # Agents (plugins + custom)
│   ├── core/                     # Core plugin
│   │   ├── fast-coder.md
│   │   ├── explore-codebase.md
│   │   └── prompt-engineering.md
│   ├── github/                   # GitHub plugin
│   │   └── issue-processor.md
│   └── my-custom-agent.md        # Custom agent
│
├── context/                      # Context (plugins + custom)
│   ├── core/                     # Core plugin
│   │   └── STANDARDS.md
│   ├── lang-node/                # Node.js plugin
│   │   ├── CODE-STYLE.md
│   │   ├── DEPENDENCIES.md
│   │   └── PERFORMANCE.md
│   └── MY-CUSTOM-DOCS.md         # Custom context
│
└── avatars/                      # AI behavior profiles
    ├── .gitkeep
    └── my-avatar.md              # Custom avatar
```
