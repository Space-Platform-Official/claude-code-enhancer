---
allowed-tools: all
description: Git push with safety checks and branch protection awareness
---

# Safe Git Push Command

Execute git push operations with comprehensive safety checks, branch protection awareness, and CI/CD integration.

**Usage:** `/git/push $ARGUMENTS`

## 🚨 CRITICAL PUSH SAFEGUARDS 🚨

**NEVER push without validation!**

When you run `/git/push`, the system will:

1. **VERIFY** - Check branch protection rules
2. **VALIDATE** - Ensure all tests pass locally
3. **PROTECT** - Prevent force pushes to protected branches
4. **TRACK** - Monitor push results and CI status

## Pre-Push Validation

**Step 1: Branch Analysis**
```bash
# Get current branch
current_branch=$(git branch --show-current)

# Check if branch exists on remote
git ls-remote --heads origin "$current_branch"

# Compare with remote
git fetch origin
git status -sb

# Check for divergence
ahead=$(git rev-list --count origin/"$current_branch"..HEAD 2>/dev/null || echo 0)
behind=$(git rev-list --count HEAD..origin/"$current_branch" 2>/dev/null || echo 0)

if [ "$behind" -gt 0 ]; then
    echo "⚠️  WARNING: Branch is $behind commits behind remote!"
    echo "Consider: git pull --rebase origin $current_branch"
fi
```

**Step 2: Protection Rules**
```bash
# Protected branches check
protected_branches=("main" "master" "develop" "production")

for branch in "${protected_branches[@]}"; do
    if [[ "$current_branch" == "$branch" ]]; then
        echo "🛑 ERROR: Direct pushes to $branch are not allowed!"
        echo "Please create a pull request instead."
        exit 1
    fi
done

# Check for force push attempt
if [[ "$*" == *"--force"* ]] || [[ "$*" == *"-f"* ]]; then
    echo "⚠️  WARNING: Force push detected!"
    echo "This can rewrite history and affect other developers."
    read -p "Are you SURE you want to force push? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
        echo "Force push cancelled."
        exit 1
    fi
fi
```

**Step 3: Quality Gates**
```bash
# Run all quality checks
echo "🔍 Running pre-push quality checks..."

# 1. Lint check
if command -v make &> /dev/null && [ -f Makefile ]; then
    make lint || { echo "❌ Linting failed! Fix issues before pushing."; exit 1; }
fi

# 2. Test check
if command -v make &> /dev/null && [ -f Makefile ]; then
    make test || { echo "❌ Tests failed! Fix failing tests before pushing."; exit 1; }
fi

# 3. Build check
if command -v make &> /dev/null && [ -f Makefile ]; then
    make build || { echo "❌ Build failed! Fix build errors before pushing."; exit 1; }
fi

# 4. Security scan
echo "🔒 Checking for secrets..."
git diff origin/"$current_branch"..HEAD | grep -E "(password|secret|key|token|api_key)" -i && {
    echo "❌ Potential secrets detected! Review and remove sensitive data."
    exit 1
}
```

## Smart Push Strategies

**1. Feature Branch Push**
```bash
# First push of a new branch
if ! git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
    echo "📤 Pushing new branch to remote..."
    git push -u origin "$current_branch"
    
    # Offer to create PR
    echo "✅ Branch pushed! Would you like to create a pull request?"
    echo "Visit: https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/compare/$current_branch"
else
    # Subsequent pushes
    git push origin "$current_branch"
fi
```

**2. Safe Force Push**
```bash
# Use force-with-lease instead of force
git push --force-with-lease origin "$current_branch"

# This prevents overwriting changes you haven't seen
```

**3. Atomic Push with Tags**
```bash
# Push commits and tags together
git push --follow-tags origin "$current_branch"

# Or push specific tag with commit
git push origin "$current_branch" "v$VERSION"
```

## CI/CD Integration

**Monitor CI Status:**
```bash
# Check CI status of previous commit
commit_sha=$(git rev-parse HEAD)

# GitHub Actions example
gh run list --commit "$commit_sha" --limit 1

# Or use hub/gh to check status
gh pr checks

# Wait for CI to complete
echo "⏳ Waiting for CI checks..."
gh run watch
```

**Push Triggers:**
```bash
# Add CI skip if needed
if [[ "$1" == "--skip-ci" ]]; then
    git commit --amend -m "$(git log -1 --pretty=%B) [skip ci]"
fi

# Trigger specific workflows
if [[ "$1" == "--deploy" ]]; then
    git tag -a "deploy-$(date +%Y%m%d-%H%M%S)" -m "Deploy trigger"
    git push origin --tags
fi
```

## Advanced Push Scenarios

**1. Push to Multiple Remotes**
```bash
# Push to all configured remotes
for remote in $(git remote); do
    echo "Pushing to $remote..."
    git push "$remote" "$current_branch"
done
```

**2. Selective File Push**
```bash
# Create a temporary branch with only specific changes
git checkout -b temp-push
git reset --soft origin/main
git add <specific-files>
git commit -m "Selective push"
git push origin temp-push
```

**3. Push with Rebase**
```bash
# Ensure linear history
git pull --rebase origin "$current_branch"
git push origin "$current_branch"
```

## Error Recovery

**Common Issues and Solutions:**

1. **Rejected Push (non-fast-forward)**
   ```bash
   # Option 1: Rebase
   git pull --rebase origin "$current_branch"
   git push origin "$current_branch"
   
   # Option 2: Merge
   git pull origin "$current_branch"
   git push origin "$current_branch"
   ```

2. **Large File Rejection**
   ```bash
   # Find large files
   git rev-list --objects --all | \
     git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
     awk '/^blob/ {print substr($0,6)}' | \
     sort --numeric-sort --key=2 | \
     tail -10
   
   # Remove from history
   git filter-branch --tree-filter 'rm -f path/to/large/file' HEAD
   ```

3. **Accidental Push to Wrong Branch**
   ```bash
   # Revert the push
   git push origin +"$PREVIOUS_SHA":"$current_branch"
   
   # Or delete and recreate
   git push origin --delete "$current_branch"
   git push origin "$correct_branch":"$current_branch"
   ```

## Push Hooks

**Pre-push Hook Example:**
```bash
#!/bin/bash
# .git/hooks/pre-push

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ "$current_branch" = "$protected_branch" ]; then
    echo "Direct push to $protected_branch branch is not allowed"
    exit 1
fi

# Run tests
make test || exit 1
```

## Best Practices

1. **Always pull before push**
   ```bash
   git pull --rebase origin "$current_branch"
   git push origin "$current_branch"
   ```

2. **Use meaningful branch names**
   - `feature/add-user-auth`
   - `bugfix/fix-login-error`
   - `hotfix/security-patch`

3. **Push early and often**
   - Backup your work
   - Enable collaboration
   - Trigger CI early

4. **Review before pushing**
   ```bash
   # Check what you're about to push
   git log origin/"$current_branch"..HEAD --oneline
   git diff origin/"$current_branch"..HEAD --stat
   ```

## Push Metrics

**Track push statistics:**
```bash
# Recent pushes
git reflog show origin/"$current_branch" --date=relative

# Push frequency
git for-each-ref --format='%(refname:short) %(committerdate:relative)' refs/remotes/origin

# Who pushed what
git for-each-ref --format='%(committerdate) %09 %(authorname) %09 %(refname)' | sort -k5 | awk '{print $9" "$10" "$11" "$5}'
```

## Integration with PR Workflows

**Auto-create PR after push:**
```bash
# Using GitHub CLI
if command -v gh &> /dev/null; then
    gh pr create --title "$(git log -1 --pretty=%s)" --body "$(git log -1 --pretty=%b)"
fi

# Using hub
if command -v hub &> /dev/null; then
    hub pull-request
fi
```

## Summary

The safe push command ensures:
- ✅ Branch protection rules are respected
- ✅ All tests pass before pushing
- ✅ No accidental force pushes to protected branches
- ✅ CI/CD integration is maintained
- ✅ Collaborative workflows are preserved
- ✅ History remains clean and traceable

Remember: **Push responsibly. Your teammates will thank you!**