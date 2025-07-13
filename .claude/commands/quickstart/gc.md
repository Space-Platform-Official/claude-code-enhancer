---
allowed-tools: all
description: Quick git commit with smart validation and conventional commit formatting
---

# Quick Git Commit (gc)

Fast access to intelligent git commit with automatic validation, conventional formatting, and safety checks.

**Usage:** `/quickstart/gc $ARGUMENTS`

## Quick Command Reference

This is a convenient alias to the full git commit command:
```
/quickstart/gc  →  /git/commit
```

## What You Get

🚀 **Smart Commit Process:**
- Automatic pre-commit validation
- Conventional commit message formatting
- Safety checks and quality gates
- Merge conflict detection
- Sensitive data protection
- Atomic commit recommendations

## Arguments Support

All arguments are passed through to the full command:
```bash
/quickstart/gc "feat: add user auth"    # Direct commit message
/quickstart/gc --amend                  # Amend last commit
/quickstart/gc --interactive            # Interactive commit building
/quickstart/gc --help                   # Show detailed help
```

## Automatic Validation

✅ **Before Every Commit:**
- Branch protection (prevents commits to main/master)
- Large file detection (>100MB warning)
- Merge conflict marker detection
- TODO/FIXME comment warnings
- Pre-commit hook execution
- Linting and test validation

## Conventional Commit Format

Messages are automatically formatted as:
```
<type>(<scope>): <subject>

<body>

<footer>
```

**Common Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `refactor` - Code restructuring
- `test` - Adding tests
- `chore` - Maintenance tasks

## Example Usage

```bash
# Quick feature commit
/quickstart/gc "feat(auth): add login validation"

# Bug fix with details
/quickstart/gc "fix(api): resolve user session timeout

- Increase session duration to 24 hours
- Add automatic renewal mechanism
- Update session cleanup job

Fixes: #123"

# Documentation update
/quickstart/gc "docs: update API authentication guide"
```

## Safety Features

🛡️ **Built-in Protection:**
```
ERROR: Direct commits to main are not allowed!
Create a feature branch first: git checkout -b feature/your-feature

WARNING: Found 2 TODO comments in staged changes
Consider addressing these before committing

ERROR: Merge conflict markers detected!
Resolve all conflicts before committing
```

## Quality Gates

Before committing, the system validates:
1. **Code Quality** - Linting passes
2. **Tests** - All tests pass  
3. **Security** - No sensitive data
4. **Standards** - Follows project conventions
5. **Conflicts** - No unresolved merge conflicts

## Interactive Mode

For complex commits, the command offers:
- File-by-file review (`git add -i`)
- Hunk-level staging (`git add -p`)
- Commit template usage
- Message editing assistance

## Error Recovery

If commit fails:
```bash
# Identify the issue
.git/hooks/pre-commit

# Fix issues and retry with same message
git commit -c ORIG_HEAD

# Or amend existing commit
/quickstart/gc --amend
```

## Smart Features

🧠 **Intelligent Assistance:**
- Automatic issue linking from branch names
- Commit message templates
- Change analysis and categorization
- Breaking change detection
- Co-author attribution

## Integration Benefits

- **CI/CD Triggers** - Semantic versioning support
- **Issue Tracking** - Automatic ticket linking
- **Code Review** - Clear, reviewable commits
- **Release Notes** - Auto-generated from commit messages

## Related Quick Commands

- `/quickstart/gs` - Check status before committing
- `/quickstart/gp` - Push commits safely
- `/quickstart/gf` - Full feature workflow

## Best Practices

1. **One logical change per commit**
2. **Write for your future self**
3. **Test before committing**
4. **Review before pushing**

## Full Documentation

For complete details and advanced features, see:
- `/git/commit` - Full git commit command
- `/git/_shared/` - Shared utilities and standards

---

**Remember:** Good commits tell a story. Make yours worth reading!