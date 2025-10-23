# Claude CLI Shell Setup Guide

This guide helps you set up convenient shell aliases for Claude CLI with safe permission handling.

## Quick Setup

### 1. Add Aliases to Your Shell Configuration

**For Zsh (macOS default):**
```bash
echo 'alias cc="claude --dangerously-skip-permissions"' >> ~/.zshrc
echo 'alias ccc="claude --dangerously-skip-permissions -c"' >> ~/.zshrc
source ~/.zshrc
```

**For Bash:**
```bash
echo 'alias cc="claude --dangerously-skip-permissions"' >> ~/.bashrc
echo 'alias ccc="claude --dangerously-skip-permissions -c"' >> ~/.bashrc
source ~/.bashrc
```

### 2. Verify Installation

```bash
# Test the aliases
cc --version
```

## Alias Reference

| Alias | Full Command | Description |
|-------|--------------|-------------|
| `cc` | `claude --dangerously-skip-permissions` | Start Claude CLI without permission prompts |
| `ccc` | `claude --dangerously-skip-permissions -c` | Continue previous Claude conversation without prompts |

## Understanding `--dangerously-skip-permissions`

### Why the Name Sounds Scary

The flag is named `--dangerously-skip-permissions` to ensure users understand they're bypassing Claude's built-in permission system. However, when properly configured, it's perfectly safe.

### How agnostic-ai Makes It Safe

When you use agnostic-ai's Claude configuration, your `.claude/settings.json` includes a **PreToolsBash hook** that provides an additional safety layer:

#### 1. PreToolsBash Hook Protection

```json
{
  "hooks": {
    "preToolsBash": {
      "command": "pre-tools-bash-hook.sh",
      "description": "Validates bash commands before execution"
    }
  }
}
```

#### 2. What PreToolsBash Does

**Before ANY bash command executes**, PreToolsBash:

✅ **Analyzes the command** for potential risks
✅ **Blocks destructive operations** (force push, rm -rf, etc.)
✅ **Prompts for confirmation** on sensitive operations
✅ **Logs command history** for auditing
✅ **Allows safe operations** to pass through instantly

#### 3. Protection Examples

**Dangerous commands that will be blocked/confirmed:**
```bash
rm -rf /                          # ❌ Blocked
git push --force main            # ⚠️  Confirmation required
docker system prune --all        # ⚠️  Confirmation required
npm run build:production         # ⚠️  Confirmation may be required
```

**Safe commands that pass through instantly:**
```bash
git status                       # ✅ Instant
npm install                      # ✅ Instant
ls -la                          # ✅ Instant
cat package.json                # ✅ Instant
```

### The Safety Stack

```
┌─────────────────────────────────────┐
│ Your Command via cc                  │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Claude CLI (no permission prompts)   │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ PreToolsBash Hook                    │
│ • Analyzes command safety            │
│ • Blocks/confirms dangerous ops      │
│ • Logs for audit                     │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Command Execution                    │
└─────────────────────────────────────┘
```

## Benefits

### Speed
- No repetitive permission prompts for safe operations
- Faster workflow and development cycle
- Less interruption during coding sessions

### Safety
- PreToolsBash hook provides granular control
- Destructive operations still require confirmation
- Command logging for security auditing
- Better than default permission prompts (more intelligent)

### Control
- You configure what's safe vs. dangerous
- Per-project or global PreToolsBash rules
- Easy to customize for your team's needs

## Advanced Configuration

### Customizing PreToolsBash Rules

You can customize what commands require confirmation by modifying the PreToolsBash hook script:

```bash
# Edit the hook script
nano .ai/scripts/claude/pre-tools-bash-hook.sh
```

### Per-Project Safety Rules

Create project-specific safety rules in `.claude/settings.json`:

```json
{
  "hooks": {
    "preToolsBash": {
      "command": "pre-tools-bash-hook.sh",
      "allowlist": ["npm run dev", "npm test"],
      "blocklist": ["rm -rf", "git push --force"]
    }
  }
}
```

### Team-Wide Aliases

For teams, document these aliases in your project's onboarding:

```markdown
# Developer Setup

1. Install Claude CLI
2. Add shell aliases:
   ```bash
   alias cc="claude --dangerously-skip-permissions"
   alias ccc="claude --dangerously-skip-permissions -c"
   ```
3. Clone the repo and run `.ai/cli configure`
```

## Troubleshooting

### Alias Not Found

**Problem:** `cc: command not found`

**Solution:**
```bash
# Check if alias is loaded
alias cc

# If empty, reload shell config
source ~/.zshrc  # or ~/.bashrc
```

### PreToolsBash Not Working

**Problem:** Commands execute without safety checks

**Solution:**
```bash
# Verify settings.json has the hook
cat .claude/settings.json | grep preToolsBash

# Check hook script exists
ls -la .ai/scripts/claude/pre-tools-bash-hook.sh

# Re-run Claude setup
.ai/cli configure
```

### Permission Issues

**Problem:** PreToolsBash script not executable

**Solution:**
```bash
chmod +x .ai/scripts/claude/pre-tools-bash-hook.sh
```

## Best Practices

1. **Always use aliases** (`cc`/`ccc`) instead of full commands
2. **Review PreToolsBash logs** periodically for security auditing
3. **Customize safety rules** for your project's specific needs
4. **Document team conventions** in your project README
5. **Update PreToolsBash rules** as your project evolves

## Comparison: With vs. Without Aliases

### Without Aliases (Traditional)

```bash
$ claude
🤖 Starting Claude CLI...
⚠️  About to run: npm install
   Allow? (y/n): y
⚠️  About to run: git status
   Allow? (y/n): y
⚠️  About to run: cat package.json
   Allow? (y/n): y
```

### With Aliases (Fast & Safe)

```bash
$ cc
🤖 Starting Claude CLI...
✓ npm install           # Instant (PreToolsBash approved)
✓ git status            # Instant (PreToolsBash approved)
✓ cat package.json      # Instant (PreToolsBash approved)

⚠️  git push --force
   ⛔ Dangerous operation! Confirm? (y/n):
```

## Related Documentation

- [Claude Settings Reference](./settings.json)
- [PreToolsBash Hook Implementation](./scripts/pre-tools-bash-hook.readme.md)
- [IDE Setup Guide](../CONTRIBUTE.md)
- [Main README](../../../README.md)

## Questions?

If you have questions or suggestions for this guide:
- Open an issue: https://github.com/betagouv/agnostic-ai/issues
- Join discussions: https://github.com/betagouv/agnostic-ai/discussions
- Mattermost: https://mattermost.incubateur.net/betagouv/channels/domaine-dev-ai-workflows
