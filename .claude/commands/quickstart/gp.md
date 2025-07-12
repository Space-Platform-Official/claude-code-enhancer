---
allowed-tools: all
description: Quick git push with comprehensive safety checks and branch protection
---

# Quick Git Push (gp)

Fast access to safe git push with comprehensive validation, branch protection, and CI/CD integration.

**Usage:** `/quickstart/gp $ARGUMENTS`

## Quick Command Reference

This is a convenient alias to the full git push command:
```
/quickstart/gp  →  /git/push
```

## What You Get

🚀 **Safe Push Process:**
- Branch protection rule enforcement
- Pre-push quality validation
- Force push safety checks
- CI/CD integration monitoring
- Automatic PR creation offers
- Push result tracking

## Arguments Support

All arguments are passed through to the full command:
```bash
/quickstart/gp                      # Standard push
/quickstart/gp --force-with-lease   # Safe force push
/quickstart/gp origin feature-branch # Push to specific remote/branch
/quickstart/gp --help               # Show detailed help
```

## Safety First

🛡️ **Critical Safeguards:**
```
🛑 ERROR: Direct pushes to main are not allowed!
Please create a pull request instead.

⚠️  WARNING: Force push detected!
This can rewrite history and affect other developers.
Are you SURE you want to force push? (yes/no):

❌ Tests failed! Fix failing tests before pushing.
❌ Linting failed! Fix issues before pushing.
```

## Pre-Push Validation

✅ **Quality Gates:**
1. **Branch Analysis** - Check for divergence with remote
2. **Protection Rules** - Enforce branch policies
3. **Quality Checks** - Run lints, tests, builds
4. **Security Scan** - Detect potential secrets
5. **CI Status** - Verify previous build status

## Smart Push Strategies

🧠 **Intelligent Handling:**

**New Branch:**
```
📤 Pushing new branch to remote...
✅ Branch pushed! Would you like to create a pull request?
Visit: https://github.com/user/repo/compare/feature-branch
```

**Existing Branch:**
```
🔍 Running pre-push quality checks...
✅ All quality gates passed
📤 Pushing to origin/feature-branch...
✅ Push successful!
```

**Diverged Branch:**
```
⚠️  WARNING: Branch is 3 commits behind remote!
Consider: git pull --rebase origin feature-branch
```

## CI/CD Integration

📊 **Automated Monitoring:**
- Check status of previous commits
- Wait for CI completion
- Monitor build results
- Track deployment triggers

```bash
⏳ Waiting for CI checks...
✅ All checks passed
🚀 Ready for deployment
```

## Advanced Features

**Multi-Remote Push:**
```bash
# Push to all configured remotes
/quickstart/gp --all-remotes
```

**Atomic Operations:**
```bash
# Push commits and tags together
/quickstart/gp --follow-tags
```

**Safe Force Push:**
```bash
# Use force-with-lease instead of force
/quickstart/gp --force-with-lease
```

## Error Recovery

Common scenarios and solutions:

**1. Rejected Push (non-fast-forward):**
```bash
# Option 1: Rebase and retry
git pull --rebase origin feature-branch
/quickstart/gp

# Option 2: Merge and retry  
git pull origin feature-branch
/quickstart/gp
```

**2. Large File Rejection:**
```bash
# Identify large files and remove from history
git filter-branch --tree-filter 'rm -f path/to/large/file' HEAD
```

**3. Accidental Wrong Branch:**
```bash
# Revert the push
git push origin +previous-sha:branch-name
```

## Team Collaboration

👥 **Workflow Integration:**
- Automatic PR creation suggestions
- Team activity notifications
- Branch sync recommendations
- Merge conflict prevention

## Push Metrics

📈 **Track Your Progress:**
```bash
# Recent push activity
📊 Push Statistics:
- Last push: 2 hours ago
- Push frequency: 3 pushes/day  
- Branch age: 5 days
- Commits ahead: 2
```

## Best Practices

1. **Always pull before push**
2. **Use meaningful branch names**
3. **Push early and often**
4. **Review before pushing**

## Example Workflow

```bash
# Check status first
/quickstart/gs

# Make your changes and commit
/quickstart/gc "feat: add new feature"

# Push safely
/quickstart/gp

# Output:
🔍 Running pre-push quality checks...
✅ Linting passed
✅ Tests passed  
✅ No sensitive data detected
📤 Pushing to origin/feature/new-feature...
✅ Push successful!
🔗 Create PR: https://github.com/user/repo/compare/feature/new-feature
```

## Related Quick Commands

- `/quickstart/gs` - Check status before pushing
- `/quickstart/gc` - Commit changes before pushing
- `/quickstart/gf` - Full feature workflow with push

## Integration Benefits

- **Branch Protection** - Enforce team policies
- **Quality Assurance** - Maintain code standards
- **CI/CD** - Trigger automated workflows
- **Collaboration** - Streamline team development

## Full Documentation

For complete details and advanced features, see:
- `/git/push` - Full git push command
- `/git/workflows/` - Complete workflow documentation
- `/git/_shared/` - Shared utilities and security

---

**Remember:** Push responsibly. Your teammates will thank you!