# Git Workflow

> Git conventions and workflow for {{PROJECT_NAME}}

## 🌿 Branching Strategy

### Branch Naming

```bash
# Feature branches
feature/user-authentication
feature/payment-integration
feature/dashboard-redesign

# Bug fixes
fix/login-redirect-issue
fix/memory-leak-in-parser

# Hotfixes (critical production bugs)
hotfix/security-patch
hotfix/payment-failure

# Chores (maintenance, refactoring)
chore/update-dependencies
chore/refactor-auth-service

# Documentation
docs/api-documentation
docs/setup-instructions
```

### Branch Patterns

```
<type>/<short-description>

Types:
- feature/  : New feature or enhancement
- fix/      : Bug fix
- hotfix/   : Critical production fix
- chore/    : Maintenance, refactoring, dependencies
- docs/     : Documentation only
- test/     : Adding or updating tests
- perf/     : Performance improvement
- style/    : Code style/formatting (no logic change)
```

### Main Branches

```
main (or master)
├── Production-ready code
├── Protected branch
└── Requires PR reviews

develop (if using Git Flow)
├── Integration branch
├── Latest development changes
└── Merged to main for releases
```

## 💬 Commit Messages

### Conventional Commits Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

```
feat:     New feature
fix:      Bug fix
docs:     Documentation changes
style:    Code style (formatting, semicolons, etc.)
refactor: Code change that neither fixes bug nor adds feature
perf:     Performance improvement
test:     Adding or updating tests
chore:    Maintenance (dependencies, build, etc.)
ci:       CI/CD changes
revert:   Revert previous commit
```

### Examples

```bash
# ✅ Good commit messages
feat(auth): add password reset functionality

fix(api): handle null response in user endpoint

docs(readme): update installation instructions

chore(deps): upgrade react to v19

perf(dashboard): optimize data fetching with caching

# With body
feat(payment): integrate Stripe payment gateway

- Add Stripe SDK configuration
- Create payment intent endpoint
- Implement webhook handler
- Add error handling for failed payments

Closes #123

# Breaking change
feat(api)!: change user endpoint response format

BREAKING CHANGE: The user endpoint now returns camelCase
instead of snake_case field names.

# Multiple files
fix: resolve authentication issues

- Fix JWT token validation
- Update session timeout logic
- Add missing error messages

# ❌ Bad commit messages
"fixed stuff"
"WIP"
"Update file.ts"
"changes"
"asdf"
```

### Commit Message Rules

1. **Use imperative mood**: "add feature" not "added feature"
2. **Capitalize first letter**: "Add feature" not "add feature"
3. **No period at end**: "Add feature" not "Add feature."
4. **Limit subject to 50 characters**
5. **Wrap body at 72 characters**
6. **Reference issues**: "Closes #123", "Fixes #456"

## 🔄 Workflow

### Starting New Work

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/user-authentication

# 3. Make changes and commit
git add .
git commit -m "feat(auth): add login form component"

# 4. Push to remote
git push -u origin feature/user-authentication
```

### Daily Work

```bash
# 1. Pull latest from main (stay up to date)
git checkout main
git pull origin main

# 2. Rebase your feature branch
git checkout feature/user-authentication
git rebase main

# 3. Continue working
git add .
git commit -m "feat(auth): add form validation"

# 4. Push (force if rebased)
git push origin feature/user-authentication --force-with-lease
```

### Before Creating PR

```bash
# 1. Ensure branch is up to date
git checkout main
git pull origin main
git checkout feature/user-authentication
git rebase main

# 2. Run tests
npm test

# 3. Run linter
npm run lint

# 4. Review your changes
git diff main

# 5. Push final changes
git push origin feature/user-authentication --force-with-lease
```

## 🔀 Pull Requests

### PR Title

Follow conventional commit format:

```
feat(auth): add user authentication system
fix(api): resolve null pointer in user service
docs: update API documentation
chore: upgrade dependencies to latest versions
```

### PR Description Template

```markdown
## Summary

Brief description of changes and why they were made.

## Changes

- Added X feature
- Fixed Y bug
- Updated Z component

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Manually tested locally

## Screenshots (if applicable)

Before:
[Screenshot or video]

After:
[Screenshot or video]

## Related Issues

Closes #123
Relates to #456

## Checklist

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests passing
```

### PR Best Practices

**Keep PRs Small**
- Aim for <400 lines of code
- One feature/fix per PR
- Split large changes into multiple PRs

**Self-Review First**
- Review your own PR before requesting review
- Check for console.logs, debugger statements
- Verify tests are passing
- Check for code style issues

**Meaningful Titles & Descriptions**
- Explain the "why", not just the "what"
- Add context for reviewers
- Include screenshots for UI changes

## 👀 Code Review

### As a Reviewer

**What to Check**
- [ ] Code correctness and logic
- [ ] Edge cases and error handling
- [ ] Performance implications
- [ ] Security vulnerabilities
- [ ] Test coverage
- [ ] Code style and readability
- [ ] Documentation completeness

**Review Comments**
```
# ✅ Good comments
"Consider using memoization here for better performance. Example: ..."

"This could fail if user is null. We should add a check."

"Great solution! One suggestion: we could simplify this with..."

# ❌ Bad comments
"This is wrong"
"Change this"
"I don't like this"
```

**Review Feedback Types**
- **Blocking**: Must be addressed before merge
- **Non-blocking**: Suggestions for improvement
- **Question**: Seeking clarification
- **Nit**: Minor style/preference (non-blocking)

### As the PR Author

**Responding to Feedback**
- Thank reviewers for their time
- Address all comments (even if you disagree)
- Push commits addressing feedback
- Reply when done: "✅ Fixed in abc123"
- Don't take feedback personally

**Handling Disagreements**
- Explain your reasoning politely
- Provide examples or documentation
- Be open to alternatives
- Escalate to team lead if needed

## 🔧 Git Commands Reference

### Common Operations

```bash
# Create branch
git checkout -b feature/new-feature

# Stage changes
git add <file>              # Stage specific file
git add .                   # Stage all changes
git add -p                  # Stage changes interactively

# Commit
git commit -m "message"
git commit --amend          # Amend last commit
git commit --no-verify      # Skip pre-commit hooks (use carefully!)

# Push
git push origin <branch>
git push --force-with-lease # Safe force push (checks remote)

# Pull/Update
git pull origin main
git pull --rebase origin main

# Branch management
git branch                  # List local branches
git branch -d feature/old   # Delete local branch
git branch -D feature/old   # Force delete
git push origin --delete feature/old  # Delete remote branch

# Stash (temporary save)
git stash                   # Save changes temporarily
git stash pop               # Apply and remove from stash
git stash list              # List all stashes
git stash apply stash@{0}   # Apply specific stash
```

### Advanced Operations

```bash
# Interactive rebase (clean up commits)
git rebase -i HEAD~3        # Rebase last 3 commits

# Cherry-pick (apply specific commit)
git cherry-pick <commit-hash>

# Reset
git reset HEAD~1            # Undo last commit (keep changes)
git reset --hard HEAD~1     # Undo last commit (discard changes)
git reset --soft HEAD~1     # Undo last commit (keep staged)

# Reflog (recover lost commits)
git reflog
git reset --hard <commit-hash>

# Squash commits
git rebase -i HEAD~3
# Then mark commits as 'squash' or 'fixup'

# Revert (create new commit that undoes changes)
git revert <commit-hash>
```

## ⚠️ Common Issues

### Merge Conflicts

```bash
# 1. Pull latest changes
git pull origin main

# 2. Resolve conflicts in files
#    - Edit files marked with <<<<<<< ======= >>>>>>>
#    - Remove conflict markers
#    - Keep the correct code

# 3. Mark as resolved
git add <resolved-file>

# 4. Complete merge
git commit

# 5. Push
git push origin feature/your-branch
```

### Accidentally Committed to Wrong Branch

```bash
# 1. Find the commit hash
git log

# 2. Create correct branch
git checkout main
git checkout -b feature/correct-branch

# 3. Cherry-pick the commit
git cherry-pick <commit-hash>

# 4. Go back to wrong branch and reset
git checkout wrong-branch
git reset --hard HEAD~1

# 5. Push correct branch
git push origin feature/correct-branch
```

### Need to Undo Last Commit

```bash
# Keep changes, undo commit
git reset --soft HEAD~1

# Discard changes and commit
git reset --hard HEAD~1

# Create revert commit (safe for shared branches)
git revert HEAD
```

## 🚫 Git Anti-Patterns

### Avoid

```bash
# ❌ Don't commit to main directly
git checkout main
git commit -m "quick fix"  # Create a branch instead!

# ❌ Don't force push to shared branches
git push --force origin main  # Very dangerous!

# ❌ Don't commit sensitive data
git add .env  # Use .gitignore!

# ❌ Don't commit large binary files
git add video.mp4  # Use Git LFS

# ❌ Don't use meaningless commit messages
git commit -m "stuff"
git commit -m "wip"
git commit -m "asdf"

# ❌ Don't commit commented code
// const oldCode = () => {
//   // ...
// }
// Just delete it! It's in git history.
```

## 🔐 Security

### Before Committing

```bash
# ✅ Check what you're committing
git diff --staged

# ✅ Use .gitignore for sensitive files
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "secrets.json" >> .gitignore

# ✅ Use pre-commit hooks
# Install: https://pre-commit.com/
pre-commit install
```

### If You Commit Secrets

```bash
# 1. Immediately rotate the exposed secrets

# 2. Remove from git history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/secret" \
  --prune-empty --tag-name-filter cat -- --all

# 3. Or use BFG Repo-Cleaner
bfg --delete-files secret.key

# 4. Force push (inform team!)
git push origin --force --all

# 5. Consider the secret compromised, rotate it
```

## 📊 Git Configuration

### Recommended Config

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Better diff algorithm
git config --global diff.algorithm histogram

# Reuse recorded conflict resolutions
git config --global rerere.enabled true

# Auto-correct typos
git config --global help.autocorrect 20

# Show more context in diffs
git config --global diff.context 5

# Color output
git config --global color.ui auto

# Prune on fetch
git config --global fetch.prune true

# Default push behavior
git config --global push.default current
```

### Aliases

```bash
# Useful shortcuts
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --graph --oneline --all'
```

## 📚 Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Git Book](https://git-scm.com/book/en/v2)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)

---

**Review frequency**: Update when team workflow changes
