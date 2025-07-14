---
allowed-tools: all
description: Enhanced branch management with naming conventions and workflow automation
---

# Advanced Git Branch Management

Sophisticated branch operations with naming conventions, lifecycle management, and team collaboration features.

**Usage:** `/git/branch $ARGUMENTS`

## 🚨 BRANCH DISCIPLINE MATTERS 🚨

**Branches are not just pointers - they're communication tools!**

When you run `/git/branch`, the system will:

1. **ENFORCE** - Naming conventions and standards
2. **AUTOMATE** - Common branch workflows
3. **PROTECT** - Critical branches from accidents
4. **TRACK** - Branch lifecycle and health

## Branch Naming Conventions

**Standard Format:**
```
<type>/<ticket>-<description>
```

**Types:**
- `feature/` - New features
- `bugfix/` - Bug fixes (non-urgent)
- `hotfix/` - Urgent production fixes
- `release/` - Release preparation
- `chore/` - Maintenance tasks
- `experiment/` - Experimental work
- `refactor/` - Code refactoring

**Examples:**
- `feature/JIRA-123-add-user-authentication`
- `bugfix/GH-456-fix-memory-leak`
- `hotfix/PROD-789-critical-security-patch`
- `release/v2.1.0`

## Smart Branch Creation

**Step 1: Interactive Branch Creation**
```bash
# Analyze context and suggest branch name
current_ticket=$(git log -1 --pretty=%B | grep -oE '[A-Z]+-[0-9]+' | head -1)
current_files=$(git diff --name-only | head -5)

echo "📋 Branch Creation Assistant"
echo "============================"
echo "Recent changes in: $current_files"
echo "Detected ticket: $current_ticket"

# Prompt for branch type
echo "Select branch type:"
echo "1) feature"
echo "2) bugfix"
echo "3) hotfix"
echo "4) chore"
echo "5) refactor"
read -p "Choice (1-5): " branch_type

# Generate branch name
case $branch_type in
    1) prefix="feature/" ;;
    2) prefix="bugfix/" ;;
    3) prefix="hotfix/" ;;
    4) prefix="chore/" ;;
    5) prefix="refactor/" ;;
esac

# Create branch
read -p "Enter description (kebab-case): " description
branch_name="${prefix}${current_ticket}-${description}"
git checkout -b "$branch_name"
```

**Step 2: Branch Templates**
```bash
# Create branch with template commits
create_feature_branch() {
    branch_name=$1
    git checkout -b "$branch_name"
    
    # Add template files if needed
    if [[ "$branch_name" == feature/* ]]; then
        echo "# Feature: ${branch_name#feature/}" > FEATURE.md
        echo "## Acceptance Criteria" >> FEATURE.md
        echo "- [ ] " >> FEATURE.md
        git add FEATURE.md
        git commit -m "chore: add feature documentation template"
    fi
}
```

## Branch Lifecycle Management

**1. Branch Health Check**
```bash
# Check branch age and activity
check_branch_health() {
    branch=$1
    
    # Age check
    created_date=$(git log --format=%ci "$branch" | tail -1)
    age_days=$(( ($(date +%s) - $(date -d "$created_date" +%s)) / 86400 ))
    
    # Activity check
    last_commit=$(git log -1 --format=%cr "$branch")
    commit_count=$(git rev-list --count "$branch" ^main)
    
    # Divergence check
    behind=$(git rev-list --count "$branch"..main)
    ahead=$(git rev-list --count main.."$branch")
    
    echo "🏥 Branch Health Report: $branch"
    echo "================================"
    echo "📅 Age: $age_days days"
    echo "🕐 Last commit: $last_commit"
    echo "📊 Commits: $commit_count"
    echo "⬆️  Ahead of main: $ahead"
    echo "⬇️  Behind main: $behind"
    
    # Recommendations
    if [ "$age_days" -gt 30 ]; then
        echo "⚠️  WARNING: Branch is over 30 days old. Consider merging or closing."
    fi
    
    if [ "$behind" -gt 50 ]; then
        echo "⚠️  WARNING: Branch is $behind commits behind main. Rebase recommended."
    fi
}
```

**2. Branch Cleanup**
```bash
# Smart branch cleanup
cleanup_branches() {
    echo "🧹 Branch Cleanup Analysis"
    echo "========================="
    
    # Find merged branches
    echo -e "\n✅ Merged branches (safe to delete):"
    git branch --merged main | grep -v -E "(main|master|develop)" | while read branch; do
        last_commit=$(git log -1 --format=%cr "$branch")
        echo "  - $branch (last commit: $last_commit)"
    done
    
    # Find stale branches
    echo -e "\n📅 Stale branches (no activity in 30+ days):"
    git for-each-ref --format='%(refname:short) %(committerdate:relative)' refs/heads/ | \
        awk '$2 ~ /months|years/ {print "  - " $1 " (last activity: " $2 " " $3 " ago)"}' 
    
    # Find orphaned branches
    echo -e "\n👻 Orphaned branches (author no longer active):"
    # Implementation depends on team structure
    
    # Interactive cleanup
    read -p "Delete all merged branches? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        git branch --merged main | grep -v -E "(main|master|develop)" | xargs -n 1 git branch -d
    fi
}
```

## Advanced Branch Operations

**1. Branch Comparison**
```bash
# Compare branches comprehensively
compare_branches() {
    branch1=$1
    branch2=$2
    
    echo "🔍 Comparing $branch1 vs $branch2"
    echo "=================================="
    
    # File differences
    echo -e "\n📁 File changes:"
    git diff --stat "$branch1".."$branch2"
    
    # Commit differences
    echo -e "\n📝 Unique commits in $branch2:"
    git log --oneline "$branch1".."$branch2" | head -10
    
    # Conflict preview
    echo -e "\n⚠️  Potential conflicts:"
    git merge-tree $(git merge-base "$branch1" "$branch2") "$branch1" "$branch2" | \
        grep -E "^<<<<<<< " | wc -l | xargs echo "Conflict sections:"
}
```

**2. Branch Sync Strategies**
```bash
# Keep feature branch updated
sync_with_main() {
    current_branch=$(git branch --show-current)
    
    echo "🔄 Syncing $current_branch with main"
    
    # Stash any work
    git stash push -m "sync-stash-$(date +%s)"
    
    # Update main
    git checkout main
    git pull origin main
    
    # Rebase or merge
    git checkout "$current_branch"
    
    read -p "Rebase (r) or Merge (m)? " strategy
    if [[ "$strategy" == "r" ]]; then
        git rebase main
    else
        git merge main --no-ff -m "Merge main into $current_branch"
    fi
    
    # Restore work
    git stash pop
}
```

**3. Branch Protection**
```bash
# Local branch protection
protect_branch() {
    branch=$1
    
    # Add to protected list
    git config --add branch."$branch".protected true
    
    # Create pre-commit hook
    cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
current_branch=$(git branch --show-current)
protected=$(git config --get branch."$current_branch".protected)

if [[ "$protected" == "true" ]]; then
    echo "🛑 ERROR: Direct commits to protected branch '$current_branch' are not allowed!"
    echo "Please create a feature branch instead."
    exit 1
fi
EOF
    chmod +x .git/hooks/pre-commit
}
```

## Branch Workflows

**1. Feature Branch Workflow**
```bash
# Complete feature workflow
feature_workflow() {
    # 1. Create feature branch
    git checkout -b feature/TICKET-description
    
    # 2. Work on feature
    # ... make changes ...
    
    # 3. Keep updated
    git fetch origin
    git rebase origin/main
    
    # 4. Push for review
    git push -u origin feature/TICKET-description
    
    # 5. Create PR
    gh pr create --title "TICKET: Description" --body "..."
    
    # 6. After approval, squash merge
    git checkout main
    git pull origin main
    git merge --squash feature/TICKET-description
    git commit -m "feat(scope): add feature description"
    
    # 7. Cleanup
    git branch -d feature/TICKET-description
    git push origin --delete feature/TICKET-description
}
```

**2. Hotfix Workflow**
```bash
# Emergency hotfix workflow
hotfix_workflow() {
    # 1. Create from production
    git checkout production
    git pull origin production
    git checkout -b hotfix/INCIDENT-description
    
    # 2. Fix issue
    # ... make changes ...
    
    # 3. Test thoroughly
    make test
    
    # 4. Merge to production
    git checkout production
    git merge --no-ff hotfix/INCIDENT-description
    git tag -a "hotfix-$(date +%Y%m%d-%H%M%S)" -m "Hotfix: description"
    git push origin production --tags
    
    # 5. Backport to main
    git checkout main
    git cherry-pick -x $(git merge-base production hotfix/INCIDENT-description)..hotfix/INCIDENT-description
    git push origin main
}
```

## Branch Analytics

**Generate branch reports:**
```bash
# Branch activity report
generate_branch_report() {
    echo "📊 Branch Analytics Report"
    echo "========================="
    echo "Generated: $(date)"
    echo ""
    
    # Active branches
    echo "🌳 Active Branches: $(git branch -r | wc -l)"
    
    # Branch age distribution
    echo -e "\n📅 Branch Age Distribution:"
    echo "< 7 days:    $(git for-each-ref --format='%(committerdate:unix)' refs/heads/ | awk -v week=$(date -d '7 days ago' +%s) '$1 > week' | wc -l)"
    echo "7-30 days:   $(git for-each-ref --format='%(committerdate:unix)' refs/heads/ | awk -v week=$(date -d '7 days ago' +%s) -v month=$(date -d '30 days ago' +%s) '$1 <= week && $1 > month' | wc -l)"
    echo "> 30 days:   $(git for-each-ref --format='%(committerdate:unix)' refs/heads/ | awk -v month=$(date -d '30 days ago' +%s) '$1 <= month' | wc -l)"
    
    # Top contributors
    echo -e "\n👥 Top Branch Creators:"
    git for-each-ref --format='%(authorname)' refs/heads/ | sort | uniq -c | sort -rn | head -5
    
    # Branch types
    echo -e "\n📁 Branch Types:"
    echo "Features: $(git branch -r | grep -c 'feature/')"
    echo "Bugfixes: $(git branch -r | grep -c 'bugfix/')"
    echo "Hotfixes: $(git branch -r | grep -c 'hotfix/')"
}
```

## Best Practices

1. **Branch Early, Branch Often**
   - Create branches for any non-trivial change
   - Keep branches focused on single concerns

2. **Descriptive Names**
   - Include ticket numbers
   - Use clear, searchable descriptions

3. **Regular Maintenance**
   - Delete merged branches promptly
   - Rebase long-running branches regularly

4. **Communication**
   - Use branch names to communicate intent
   - Update branch descriptions in PR

## Summary

Advanced branch management provides:
- ✅ Consistent naming conventions
- ✅ Automated workflow support
- ✅ Branch health monitoring
- ✅ Protection against common mistakes
- ✅ Team collaboration features
- ✅ Comprehensive analytics

Remember: **Branches are cheap. Confusion is expensive!**