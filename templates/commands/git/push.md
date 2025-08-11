---
allowed-tools: all
description: Git push with safety checks and branch protection awareness
---

# Git Push, Pull & Fetch Operations

Comprehensive remote operations including push, pull, and fetch with safety checks, conflict resolution, and CI/CD integration.

**Usage:** `/git/push $ARGUMENTS` or `/git/pull` or `/git/fetch`

## 🚨 REMOTE OPERATIONS SAFEGUARDS 🚨

**NEVER sync without validation!**

This command handles:

1. **PUSH** - Upload local changes with safety checks
2. **PULL** - Download and merge remote changes
3. **FETCH** - Update remote tracking without merging
4. **SYNC** - Bidirectional synchronization

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

**Step 2: Protection Rules with Smart Branch Creation**
```bash
# Protected branches check with auto-branch creation
protected_branches=("main" "master" "develop" "production")

for branch in "${protected_branches[@]}"; do
    if [[ "$current_branch" == "$branch" ]]; then
        echo "🛡️ Protected branch detected: $branch"
        echo "📝 Creating feature branch for safe push..."
        
        # Extract meaningful branch name from latest commit
        commit_msg=$(git log -1 --pretty=%s)
        # Extract type and description (e.g., "feat: add auth" -> "feature/add-auth")
        branch_type=$(echo "$commit_msg" | grep -oE '^(feat|fix|chore|docs|style|refactor|test):' | tr -d ':')
        branch_desc=$(echo "$commit_msg" | sed 's/^[^:]*: //' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')
        
        # Map commit types to branch prefixes
        case "$branch_type" in
            feat) branch_prefix="feature" ;;
            fix) branch_prefix="bugfix" ;;
            docs) branch_prefix="docs" ;;
            chore|style|refactor) branch_prefix="refactor" ;;
            test) branch_prefix="test" ;;
            *) branch_prefix="feature" ;;
        esac
        
        # Create unique branch name
        new_branch="${branch_prefix}/${branch_desc}"
        
        # Add timestamp if branch already exists
        if git show-ref --verify --quiet "refs/heads/$new_branch"; then
            timestamp=$(date +%Y%m%d-%H%M%S)
            new_branch="${new_branch}-${timestamp}"
        fi
        
        echo "🌿 Creating and switching to: $new_branch"
        git checkout -b "$new_branch"
        
        echo "📤 Pushing to new branch..."
        if git push -u origin "$new_branch"; then
            echo "✅ Successfully pushed to $new_branch"
            echo ""
            echo "🎯 Next steps:"
            echo "1️⃣  Create PR: gh pr create --base $branch"
            echo "2️⃣  Or visit: $(git remote get-url origin | sed 's/\.git$//' | sed 's/git@github.com:/https:\/\/github.com\//')/compare/$branch...$new_branch"
            echo ""
            echo "💡 Quick PR creation command:"
            echo "   gh pr create --title \"$commit_msg\" --body \"Auto-created from protected branch push\""
            exit 0
        else
            echo "❌ Failed to push new branch"
            exit 1
        fi
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

### 🎯 Auto-Branch Creation for Protected Branches

When pushing to a protected branch (main/master/develop/production), the system automatically:

1. **Detects protection** and prevents direct push
2. **Creates feature branch** based on your latest commit message
3. **Pushes to new branch** with upstream tracking
4. **Provides PR commands** ready to execute

**Branch Naming Convention:**
- `feat: add auth` → `feature/add-auth`
- `fix: login bug` → `bugfix/login-bug`
- `docs: update readme` → `docs/update-readme`
- `refactor: clean code` → `refactor/clean-code`

**Example Workflow:**
```bash
# You're on main with committed changes
git push
# System detects main is protected
# → Creates feature/your-changes
# → Pushes to origin/feature/your-changes
# → Provides: gh pr create --base main
```

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

## Pull Operations

**Safe Pull with Strategy Selection:**
```bash
# Intelligent pull operation
safe_pull() {
    current_branch=$(git branch --show-current)
    
    echo "📥 Safe Pull Operation"
    echo "====================="
    
    # Pre-pull checks
    echo "🔍 Pre-pull validation..."
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Uncommitted changes detected!"
        echo "Options:"
        echo "  1) Stash changes and pull"
        echo "  2) Commit changes and pull"
        echo "  3) Cancel pull"
        read -p "Choice (1-3): " choice
        
        case $choice in
            1)
                stash_name="pull-$(date +%s)"
                git stash push -m "$stash_name"
                echo "💾 Stashed as: $stash_name"
                ;;
            2)
                git add -A
                git commit -m "WIP: Save work before pull"
                ;;
            3)
                echo "Pull cancelled"
                return 1
                ;;
        esac
    fi
    
    # Fetch first to see what's coming
    echo "🔄 Fetching remote changes..."
    git fetch origin "$current_branch"
    
    # Analyze incoming changes
    incoming=$(git rev-list --count HEAD.."origin/$current_branch")
    if [ "$incoming" -eq 0 ]; then
        echo "✅ Already up to date!"
        return 0
    fi
    
    echo "📦 Incoming: $incoming commit(s)"
    echo "Preview of changes:"
    git log --oneline HEAD.."origin/$current_branch" | head -5
    
    # Choose merge strategy
    echo -e "\n🎯 Pull Strategy:"
    echo "  1) Rebase (recommended - linear history)"
    echo "  2) Merge (preserve branch points)"
    echo "  3) Fast-forward only (safest)"
    read -p "Strategy (1-3): " strategy
    
    case $strategy in
        1)
            echo "🔄 Rebasing..."
            if git pull --rebase origin "$current_branch"; then
                echo "✅ Rebase successful!"
            else
                echo "⚠️  Rebase conflicts detected!"
                echo "Resolve conflicts, then run:"
                echo "  git add <resolved-files>"
                echo "  git rebase --continue"
            fi
            ;;
        2)
            echo "🔄 Merging..."
            if git pull --no-rebase origin "$current_branch"; then
                echo "✅ Merge successful!"
            else
                echo "⚠️  Merge conflicts detected!"
                echo "Resolve conflicts, then run:"
                echo "  git add <resolved-files>"
                echo "  git commit"
            fi
            ;;
        3)
            echo "🔄 Fast-forward only..."
            if git pull --ff-only origin "$current_branch"; then
                echo "✅ Fast-forward successful!"
            else
                echo "⚠️  Cannot fast-forward (branches diverged)"
                echo "Choose rebase or merge strategy instead"
            fi
            ;;
    esac
    
    # Restore stash if exists
    if git stash list | grep -q "pull-"; then
        echo "🔄 Restoring stashed changes..."
        if git stash pop; then
            echo "✅ Stash restored successfully!"
        else
            echo "⚠️  Stash conflicts! Resolve manually."
        fi
    fi
}

# Pull from specific remote/branch
pull_from() {
    remote=${1:-origin}
    branch=${2:-$(git branch --show-current)}
    
    echo "📥 Pulling from $remote/$branch"
    git pull "$remote" "$branch"
}
```

## Fetch Operations

**Smart Fetch with Options:**
```bash
# Comprehensive fetch operation
smart_fetch() {
    echo "🔄 Smart Fetch Operation"
    echo "======================"
    
    echo "Fetch Options:"
    echo "  1) Fetch from origin (default remote)"
    echo "  2) Fetch from all remotes"
    echo "  3) Fetch specific branch"
    echo "  4) Fetch with tags"
    echo "  5) Fetch and prune deleted branches"
    read -p "Choice (1-5): " fetch_choice
    
    case $fetch_choice in
        1)
            echo "📡 Fetching from origin..."
            git fetch origin
            ;;
        2)
            echo "🌐 Fetching from all remotes..."
            git fetch --all
            
            # Show summary
            echo -e "\n📊 Fetch Summary:"
            for remote in $(git remote); do
                echo "  $remote: $(git ls-remote --heads $remote | wc -l) branches"
            done
            ;;
        3)
            read -p "Enter branch name: " branch_name
            echo "🎯 Fetching specific branch: $branch_name"
            git fetch origin "$branch_name"
            ;;
        4)
            echo "🏷️  Fetching with tags..."
            git fetch --tags origin
            echo "Tags fetched: $(git tag | wc -l)"
            ;;
        5)
            echo "✂️  Fetching and pruning..."
            git fetch --prune origin
            echo "✅ Deleted remote branches pruned"
            ;;
    esac
    
    # Show what changed
    echo -e "\n🔍 Post-fetch Analysis:"
    current_branch=$(git branch --show-current)
    
    if git rev-parse --verify "origin/$current_branch" &>/dev/null; then
        behind=$(git rev-list --count HEAD.."origin/$current_branch")
        if [ "$behind" -gt 0 ]; then
            echo "⚠️  Current branch is $behind commit(s) behind origin"
            echo "   Run 'git pull' to update"
        else
            echo "✅ Current branch is up to date"
        fi
    fi
    
    # Check for new remote branches
    new_branches=$(git branch -r | grep -v '\->' | while read remote; do
        branch="${remote#origin/}"
        if ! git show-ref --verify --quiet refs/heads/"$branch"; then
            echo "  - $remote (new)"
        fi
    done)
    
    if [ -n "$new_branches" ]; then
        echo -e "\n🆕 New remote branches available:"
        echo "$new_branches"
    fi
}

# Fetch and compare
fetch_and_compare() {
    branch=${1:-$(git branch --show-current)}
    
    echo "🔍 Fetching and comparing $branch..."
    git fetch origin "$branch"
    
    echo -e "\n📊 Comparison with origin/$branch:"
    echo "Local commits not in remote:"
    git log --oneline "origin/$branch"..HEAD
    
    echo -e "\nRemote commits not in local:"
    git log --oneline HEAD.."origin/$branch"
}
```

## Clone Operations

**Smart Clone with Options:**
```bash
# Enhanced clone operation
smart_clone() {
    repo_url=$1
    
    if [ -z "$repo_url" ]; then
        read -p "Enter repository URL: " repo_url
    fi
    
    echo "📦 Smart Clone Operation"
    echo "======================"
    
    echo "Clone Options:"
    echo "  1) Standard clone (full history)"
    echo "  2) Shallow clone (last 100 commits)"
    echo "  3) Single branch clone"
    echo "  4) Mirror clone (bare repository)"
    echo "  5) Clone with submodules"
    read -p "Choice (1-5): " clone_choice
    
    repo_name=$(basename "$repo_url" .git)
    
    case $clone_choice in
        1)
            echo "📥 Standard clone..."
            git clone "$repo_url"
            ;;
        2)
            echo "⚡ Shallow clone..."
            git clone --depth 100 "$repo_url"
            echo "💡 To get full history later: git fetch --unshallow"
            ;;
        3)
            read -p "Enter branch name: " branch_name
            echo "🎯 Single branch clone: $branch_name"
            git clone -b "$branch_name" --single-branch "$repo_url"
            ;;
        4)
            echo "🪞 Mirror clone..."
            git clone --mirror "$repo_url" "${repo_name}.git"
            echo "💡 This is a bare repository for backup/mirror purposes"
            ;;
        5)
            echo "📦 Clone with submodules..."
            git clone --recurse-submodules "$repo_url"
            ;;
    esac
    
    # Post-clone setup
    if [ -d "$repo_name" ]; then
        cd "$repo_name"
        
        echo -e "\n🎆 Post-clone setup:"
        
        # Setup upstream for forks
        if echo "$repo_url" | grep -q "github.com"; then
            read -p "Is this a fork? (y/n): " is_fork
            if [[ "$is_fork" == "y" ]]; then
                read -p "Enter upstream URL: " upstream_url
                git remote add upstream "$upstream_url"
                git fetch upstream
                echo "✅ Upstream configured"
            fi
        fi
        
        # Show repository info
        echo -e "\n📊 Repository Info:"
        echo "  Branches: $(git branch -r | wc -l)"
        echo "  Tags: $(git tag | wc -l)"
        echo "  Remotes: $(git remote | tr '\n' ' ')"
        echo "  Size: $(du -sh .git | cut -f1)"
    fi
}
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