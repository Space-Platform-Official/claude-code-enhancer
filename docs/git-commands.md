# 🔀 Git Commands Documentation

> Comprehensive version control workflows and automation

---

## 📝 `/git/commit` - Smart Commit Creation

### Overview
Creates well-structured commits with automatic staging, message generation, and hook integration.

### Usage
```bash
claude git commit                        # Interactive commit
claude git commit -m "fix: auth issue"   # Direct commit
claude git commit --amend               # Amend last commit
```

### Commit Workflow
1. **Analyze changes** - `git status` and `git diff`
2. **Stage files** - Intelligent file selection
3. **Generate message** - Following conventional commits
4. **Validate** - Pre-commit hooks
5. **Create commit** - With co-author attribution

### Commit Message Format
```
type(scope): subject

body (optional)

footer (optional)

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
```

### Conventional Commit Types
| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat(auth): add OAuth support` |
| `fix` | Bug fix | `fix(api): resolve timeout issue` |
| `docs` | Documentation | `docs(readme): update installation` |
| `refactor` | Code refactoring | `refactor(utils): simplify logic` |
| `test` | Test changes | `test(auth): add unit tests` |
| `chore` | Maintenance | `chore(deps): update packages` |

---

## 🚀 `/git/pr` - Pull Request Management

### Overview
Automated pull request creation with comprehensive description generation and GitHub CLI integration.

### Usage
```bash
claude git pr                    # Create PR from current branch
claude git pr --draft           # Create draft PR
claude git pr --base main       # Specify base branch
claude git pr --reviewers user1,user2  # Request reviews
```

### PR Creation Workflow
1. **Analyze changes** - All commits since base branch
2. **Generate summary** - Comprehensive change description
3. **Create PR** - Using GitHub CLI (`gh`)
4. **Link issues** - Auto-link related issues
5. **Request reviews** - Based on CODEOWNERS

### PR Description Template
```markdown
## Summary
- Brief description of changes
- Key features implemented
- Problems solved

## Changes
- Detailed change list
- File modifications
- Dependencies updated

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)
[Screenshots or recordings]

🤖 Generated with Claude Code
```

### GitHub CLI Integration
```bash
# Behind the scenes uses:
gh pr create \
  --title "feat: implement user authentication" \
  --body "$(generated_description)" \
  --base main \
  --reviewer teammate1,teammate2
```

---

## 🌿 `/git/branch` - Branch Operations

### Overview
Intelligent branch management with naming conventions and cleanup utilities.

### Usage
```bash
claude git branch feature/new-auth  # Create feature branch
claude git branch --list           # List branches with info
claude git branch --cleanup        # Remove merged branches
claude git branch --switch develop # Switch branches safely
```

### Branch Naming Conventions
| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/description` | `feature/user-profile` |
| Bugfix | `bugfix/issue-number` | `bugfix/AUTH-123` |
| Hotfix | `hotfix/description` | `hotfix/critical-security` |
| Release | `release/version` | `release/v2.1.0` |

### Branch Operations
```bash
# Create and switch
git checkout -b feature/new-feature

# Safe switching (stash if needed)
git stash save "WIP: current work"
git checkout target-branch

# Cleanup merged branches
git branch --merged | grep -v main | xargs git branch -d
```

---

## 📤 `/git/push` - Smart Push Operations

### Overview
Intelligent push operations with safety checks and hook validation.

### Usage
```bash
claude git push                  # Push current branch
claude git push --force-lease    # Safe force push
claude git push --all           # Push all branches
claude git push --tags          # Push tags
```

### Push Safety Features
1. **Pre-push validation** - Run tests and checks
2. **Branch protection** - Prevent main branch push
3. **Force push safety** - Use `--force-with-lease`
4. **Hook integration** - Quality gates
5. **Upstream tracking** - Auto-set upstream

### Safety Checks
```yaml
pre_push_checks:
  - lint_validation
  - test_execution
  - security_scan
  - branch_protection
  
protected_branches:
  - main
  - master
  - production
  - release/*
```

---

## 📊 `/git/status` - Enhanced Status

### Overview
Comprehensive repository status with actionable insights.

### Usage
```bash
claude git status              # Enhanced status view
claude git status --detailed   # Include file changes
claude git status --conflicts  # Focus on conflicts
```

### Status Information
- **Branch info** - Current branch, upstream, divergence
- **Working tree** - Modified, staged, untracked files
- **Stash status** - Number of stashes
- **Commit info** - Last commit, ahead/behind
- **Suggestions** - Next recommended actions

### Enhanced Output
```
Branch: feature/new-auth (2 ahead, 1 behind origin/main)
Status: Working tree has changes

Staged (3):
  M src/auth/login.ts
  A src/auth/oauth.ts
  D src/auth/legacy.ts

Modified (2):
  M README.md
  M package.json

Untracked (1):
  ? .env.local

Suggestions:
  - Stage remaining changes: git add .
  - Commit staged changes: git commit
  - Pull latest from main: git pull origin main
```

---

## 🔄 Git Workflows

### `/git/workflows/feature` - Feature Development

#### Overview
Complete feature branch workflow from creation to merge.

#### Usage
```bash
claude git workflows feature "user-authentication"
```

#### Workflow Steps
1. **Create feature branch** from main/develop
2. **Set up tracking** and push rules
3. **Regular commits** with conventional format
4. **Keep updated** with base branch
5. **Create PR** when ready
6. **Handle reviews** and updates
7. **Merge** after approval

#### Example Flow
```bash
# Automated workflow:
git checkout -b feature/user-authentication
git push -u origin feature/user-authentication
# ... development work ...
git add .
git commit -m "feat(auth): implement login"
git pull origin main --rebase
gh pr create --title "Feature: User Authentication"
```

---

### `/git/workflows/hotfix` - Emergency Fixes

#### Overview
Rapid hotfix deployment for production issues.

#### Usage
```bash
claude git workflows hotfix "critical-security-fix"
```

#### Hotfix Process
1. **Branch from production** tag/branch
2. **Implement fix** with minimal changes
3. **Emergency testing** suite
4. **Fast-track review** process
5. **Deploy to production**
6. **Backport to develop** branch

#### Safety Measures
- Minimal change scope
- Automated rollback ready
- Production monitoring
- Incident documentation

---

### `/git/workflows/release` - Release Management

#### Overview
Structured release workflow with versioning and tagging.

#### Usage
```bash
claude git workflows release "v2.1.0"
```

#### Release Process
1. **Create release branch** from develop
2. **Version bump** in package files
3. **Generate changelog** from commits
4. **Final testing** and fixes
5. **Merge to main** and tag
6. **Back-merge** to develop
7. **Create GitHub release**

#### Semantic Versioning
```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: New features (backward compatible)
PATCH: Bug fixes
```

---

### `/git/workflows/sync` - Branch Synchronization

#### Overview
Keep branches synchronized with upstream changes.

#### Usage
```bash
claude git workflows sync          # Sync current branch
claude git workflows sync --all    # Sync all local branches
```

#### Sync Strategies
1. **Rebase** (default) - Clean linear history
2. **Merge** - Preserve branch history
3. **Cherry-pick** - Selective sync

#### Conflict Resolution
```bash
# Automated conflict resolution flow:
1. Attempt automatic merge
2. If conflicts, create conflict markers
3. Provide resolution suggestions
4. Validate after resolution
5. Continue sync process
```

---

## 🔧 Shared Git Utilities

### Configuration Management
**Location**: `templates/commands/git/_shared/config.md`

```yaml
git_config:
  user:
    name: "Developer Name"
    email: "dev@example.com"
  core:
    editor: "vim"
    autocrlf: "input"
  pull:
    rebase: true
  push:
    default: "current"
```

### Hook Integration
**Location**: `templates/commands/git/_shared/hooks.md`

```bash
# Available hooks:
pre-commit    # Format, lint, test
commit-msg    # Message validation
pre-push      # Full validation suite
post-merge    # Dependency updates
```

### Security Policies
**Location**: `templates/commands/git/_shared/security.md`

```yaml
security:
  secrets_scanning: enabled
  signed_commits: recommended
  protected_branches:
    - main
    - release/*
  force_push: prohibited
```

### PR Utilities
**Location**: `templates/commands/git/_shared/pr-utils.md`

- PR template generation
- Review request automation
- Label management
- Milestone assignment
- Issue linking

---

## 📋 Common Git Workflows

### Feature Development Flow
```bash
# 1. Start feature
claude git workflows feature "new-feature"

# 2. Regular commits
claude git commit -m "feat: add functionality"

# 3. Stay synchronized
claude git workflows sync

# 4. Create PR
claude git pr

# 5. Address reviews
claude git commit -m "fix: address review comments"
claude git push

# 6. Merge (automated via GitHub)
```

### Bug Fix Flow
```bash
# 1. Create bugfix branch
claude git branch bugfix/ISSUE-123

# 2. Fix and test
# ... make changes ...
claude test unit

# 3. Commit fix
claude git commit -m "fix: resolve issue #123"

# 4. Push and create PR
claude git push
claude git pr
```

### Release Flow
```bash
# 1. Start release
claude git workflows release "v2.0.0"

# 2. Final preparations
# - Version bumps
# - Changelog updates
# - Final testing

# 3. Complete release
# Automated merge to main
# Tag creation
# GitHub release
```

---

## 🛡️ Best Practices

### Commit Guidelines
1. **Atomic commits** - One logical change per commit
2. **Meaningful messages** - Clear and descriptive
3. **Conventional format** - Consistent type(scope) format
4. **Sign commits** - GPG signing when possible

### Branch Management
1. **Short-lived branches** - Merge frequently
2. **Descriptive names** - Clear purpose indication
3. **Regular cleanup** - Delete merged branches
4. **Protected main** - Never commit directly

### PR Best Practices
1. **Small PRs** - Easier to review
2. **Clear descriptions** - Context and changes
3. **Link issues** - Traceability
4. **Request reviews** - Appropriate reviewers
5. **Address feedback** - Respond to all comments

### Conflict Prevention
1. **Frequent syncs** - Pull regularly
2. **Communication** - Coordinate with team
3. **Small changes** - Reduce conflict surface
4. **Early integration** - Merge often

---

## 🚨 Troubleshooting

### Common Issues

#### Merge Conflicts
```bash
# Let Claude help resolve
claude git workflows sync
# Provides conflict resolution assistance
```

#### Detached HEAD
```bash
# Recover work
git branch recovery-branch
git checkout recovery-branch
```

#### Accidental Force Push
```bash
# Recover using reflog
git reflog
git reset --hard HEAD@{n}
```

#### Large File Issues
```bash
# Use Git LFS
git lfs track "*.psd"
git add .gitattributes
```

---

*Documentation generated from templates/commands/git/*