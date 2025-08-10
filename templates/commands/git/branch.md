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

## Remote Branch Operations

**1. Remote Branch Discovery**
```bash
# Discover and track remote branches
discover_remote_branches() {
    echo "🔍 Discovering Remote Branches"
    echo "=============================="
    
    # Fetch all remote branch information
    git fetch --all --prune
    
    # List all remote branches
    echo -e "\n📡 Remote branches:"
    git branch -r --format='%(refname:short) %(committerdate:relative) %(authorname)' | 
        column -t -s' '
    
    # Find untracked remote branches
    echo -e "\n🆕 Untracked remote branches:"
    git branch -r | grep -v '\->' | while read remote; do
        branch="${remote#origin/}"
        if ! git show-ref --verify --quiet refs/heads/"$branch"; then
            echo "  - $remote"
        fi
    done
    
    # Offer to track branches
    read -p "Track a remote branch? (y/n): " track
    if [[ "$track" == "y" ]]; then
        read -p "Enter remote branch name (without origin/): " branch_name
        git checkout -b "$branch_name" "origin/$branch_name"
    fi
}

# Clone specific remote branch
clone_remote_branch() {
    branch=$1
    repo_url=$2
    
    echo "📥 Cloning specific branch: $branch"
    git clone -b "$branch" --single-branch "$repo_url"
}
```

**2. Remote Branch Synchronization**
```bash
# Sync local branch with remote
sync_with_remote() {
    current_branch=$(git branch --show-current)
    
    echo "🔄 Syncing $current_branch with remote"
    echo "====================================="
    
    # Check if branch exists on remote
    if ! git ls-remote --heads origin "$current_branch" | grep -q "$current_branch"; then
        echo "⚠️  Branch doesn't exist on remote"
        read -p "Push branch to remote? (y/n): " push_branch
        if [[ "$push_branch" == "y" ]]; then
            git push -u origin "$current_branch"
        fi
        return
    fi
    
    # Fetch latest remote changes
    git fetch origin "$current_branch"
    
    # Check divergence
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$current_branch")
    merge_base=$(git merge-base HEAD "origin/$current_branch")
    
    if [ "$local_commit" = "$remote_commit" ]; then
        echo "✅ Branch is up to date with remote"
    elif [ "$local_commit" = "$merge_base" ]; then
        echo "⬇️  Branch is behind remote"
        read -p "Pull changes? (y/n): " pull
        if [[ "$pull" == "y" ]]; then
            git pull --rebase origin "$current_branch"
        fi
    elif [ "$remote_commit" = "$merge_base" ]; then
        echo "⬆️  Branch is ahead of remote"
        read -p "Push changes? (y/n): " push
        if [[ "$push" == "y" ]]; then
            git push origin "$current_branch"
        fi
    else
        echo "🔀 Branch has diverged from remote"
        echo "Options:"
        echo "  1) Rebase onto remote"
        echo "  2) Merge remote changes"
        echo "  3) Force push (dangerous)"
        read -p "Choice (1-3): " choice
        case $choice in
            1) git pull --rebase origin "$current_branch" ;;
            2) git pull --no-rebase origin "$current_branch" ;;
            3) 
                echo "⚠️  WARNING: This will overwrite remote!"
                read -p "Are you SURE? (type 'yes'): " confirm
                if [[ "$confirm" == "yes" ]]; then
                    git push --force-with-lease origin "$current_branch"
                fi
                ;;
        esac
    fi
}
```

## Branch Lifecycle Management

**1. Branch Health Check (Enhanced with Remote)**
```bash
# Check branch age and activity including remote status
check_branch_health() {
    branch=$1
    
    # Age check
    created_date=$(git log --format=%ci "$branch" | tail -1)
    age_days=$(( ($(date +%s) - $(date -d "$created_date" +%s)) / 86400 ))
    
    # Activity check
    last_commit=$(git log -1 --format=%cr "$branch")
    commit_count=$(git rev-list --count "$branch" ^main)
    
    # Divergence check with local main
    behind=$(git rev-list --count "$branch"..main)
    ahead=$(git rev-list --count main.."$branch")
    
    # Remote status check
    if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        remote_behind=$(git rev-list --count "$branch".."origin/$branch" 2>/dev/null || echo "N/A")
        remote_ahead=$(git rev-list --count "origin/$branch".."$branch" 2>/dev/null || echo "N/A")
        remote_status="✅ Tracked"
    else
        remote_behind="N/A"
        remote_ahead="N/A"
        remote_status="❌ Not on remote"
    fi
    
    echo "🏥 Branch Health Report: $branch"
    echo "================================"
    echo "📅 Age: $age_days days"
    echo "🕐 Last commit: $last_commit"
    echo "📊 Commits: $commit_count"
    echo ""
    echo "Local Status:"
    echo "  ⬆️  Ahead of main: $ahead"
    echo "  ⬇️  Behind main: $behind"
    echo ""
    echo "Remote Status: $remote_status"
    if [[ "$remote_status" == "✅ Tracked" ]]; then
        echo "  ⬆️  Ahead of remote: $remote_ahead"
        echo "  ⬇️  Behind remote: $remote_behind"
    fi
    
    # Recommendations
    if [ "$age_days" -gt 30 ]; then
        echo "⚠️  WARNING: Branch is over 30 days old. Consider merging or closing."
    fi
    
    if [ "$behind" -gt 50 ]; then
        echo "⚠️  WARNING: Branch is $behind commits behind main. Rebase recommended."
    fi
    
    if [[ "$remote_behind" != "N/A" ]] && [ "$remote_behind" -gt 0 ]; then
        echo "⚠️  WARNING: Branch is behind remote. Pull recommended."
    fi
}
```

**2. Branch Cleanup (Local and Remote)**
```bash
# Smart branch cleanup with remote awareness
cleanup_branches() {
    echo "🧹 Branch Cleanup Analysis"
    echo "========================="
    
    # Find merged branches (local)
    echo -e "\n✅ Merged branches (safe to delete):"
    git branch --merged main | grep -v -E "(main|master|develop)" | while read branch; do
        last_commit=$(git log -1 --format=%cr "$branch")
        echo "  - $branch (last commit: $last_commit)"
    done
    
    # Find merged remote branches
    echo -e "\n✅ Merged remote branches:"
    git branch -r --merged origin/main | grep -v -E "(main|master|develop|HEAD)" | while read branch; do
        echo "  - $branch"
    done
    
    # Find stale branches
    echo -e "\n📅 Stale branches (no activity in 30+ days):"
    git for-each-ref --format='%(refname:short) %(committerdate:relative)' refs/heads/ | \
        awk '$2 ~ /months|years/ {print "  - " $1 " (last activity: " $2 " " $3 " ago)"}' 
    
    # Find orphaned remote tracking branches
    echo -e "\n👻 Orphaned remote tracking branches:"
    git remote prune origin --dry-run
    
    # Interactive cleanup
    echo -e "\n🔧 Cleanup Options:"
    echo "1) Delete merged local branches"
    echo "2) Delete merged remote branches"
    echo "3) Prune orphaned remote tracking branches"
    echo "4) Full cleanup (all of the above)"
    echo "5) Cancel"
    
    read -p "Choice (1-5): " cleanup_choice
    
    case $cleanup_choice in
        1)
            git branch --merged main | grep -v -E "(main|master|develop)" | xargs -n 1 git branch -d
            echo "✅ Merged local branches deleted"
            ;;
        2)
            git branch -r --merged origin/main | grep -v -E "(main|master|develop|HEAD)" | \
                sed 's/origin\///' | xargs -n 1 git push origin --delete
            echo "✅ Merged remote branches deleted"
            ;;
        3)
            git remote prune origin
            echo "✅ Orphaned remote tracking branches pruned"
            ;;
        4)
            # Full cleanup
            git branch --merged main | grep -v -E "(main|master|develop)" | xargs -n 1 git branch -d
            git branch -r --merged origin/main | grep -v -E "(main|master|develop|HEAD)" | \
                sed 's/origin\///' | xargs -n 1 git push origin --delete 2>/dev/null || true
            git remote prune origin
            echo "✅ Full cleanup completed"
            ;;
        5)
            echo "Cleanup cancelled"
            ;;
    esac
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

## Remote Management

**1. Multiple Remote Configuration**
```bash
# Setup multiple remotes
setup_multiple_remotes() {
    echo "🌐 Configuring Multiple Remotes"
    echo "================================"
    
    # Show current remotes
    echo "Current remotes:"
    git remote -v
    
    echo -e "\n🔧 Remote Setup Options:"
    echo "1) Add upstream (original repository for forks)"
    echo "2) Add backup remote"
    echo "3) Add team member's fork"
    echo "4) Configure push URLs"
    echo "5) Remove a remote"
    
    read -p "Choice (1-5): " remote_choice
    
    case $remote_choice in
        1)
            read -p "Enter upstream repository URL: " upstream_url
            git remote add upstream "$upstream_url"
            git fetch upstream
            echo "✅ Upstream remote added"
            ;;
        2)
            read -p "Enter backup repository URL: " backup_url
            git remote add backup "$backup_url"
            echo "✅ Backup remote added"
            ;;
        3)
            read -p "Enter team member's name: " member_name
            read -p "Enter repository URL: " member_url
            git remote add "$member_name" "$member_url"
            git fetch "$member_name"
            echo "✅ Team member remote added: $member_name"
            ;;
        4)
            read -p "Remote name to configure: " remote_name
            read -p "New push URL: " push_url
            git remote set-url --push "$remote_name" "$push_url"
            echo "✅ Push URL configured for $remote_name"
            ;;
        5)
            git remote
            read -p "Remote name to remove: " remote_to_remove
            git remote remove "$remote_to_remove"
            echo "✅ Remote $remote_to_remove removed"
            ;;
    esac
}

# Fetch from all remotes
fetch_all_remotes() {
    echo "📥 Fetching from all remotes..."
    git fetch --all --prune --tags
    
    # Show summary
    echo -e "\n📊 Remote Summary:"
    for remote in $(git remote); do
        echo -e "\n$remote:"
        git ls-remote --heads "$remote" | wc -l | xargs echo "  Branches:"
        git ls-remote --tags "$remote" | wc -l | xargs echo "  Tags:"
    done
}
```

**2. Pull Operations with Strategy**
```bash
# Smart pull with conflict handling
smart_pull() {
    current_branch=$(git branch --show-current)
    
    echo "📥 Smart Pull Operation"
    echo "======================"
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo "⚠️  Uncommitted changes detected"
        echo "1) Stash and pull"
        echo "2) Commit and pull"
        echo "3) Cancel"
        read -p "Choice (1-3): " pull_choice
        
        case $pull_choice in
            1)
                git stash push -m "pull-stash-$(date +%s)"
                ;;
            2)
                git add -A
                git commit -m "WIP: Save work before pull"
                ;;
            3)
                echo "Pull cancelled"
                return
                ;;
        esac
    fi
    
    # Choose pull strategy
    echo -e "\n📋 Pull Strategy:"
    echo "1) Rebase (keep linear history)"
    echo "2) Merge (preserve branch topology)"
    echo "3) Fast-forward only (safest)"
    read -p "Choice (1-3): " strategy
    
    case $strategy in
        1)
            git pull --rebase origin "$current_branch"
            if [ $? -ne 0 ]; then
                echo "⚠️  Rebase conflicts detected!"
                echo "Resolve conflicts, then run: git rebase --continue"
            fi
            ;;
        2)
            git pull --no-rebase origin "$current_branch"
            if [ $? -ne 0 ]; then
                echo "⚠️  Merge conflicts detected!"
                echo "Resolve conflicts, then run: git commit"
            fi
            ;;
        3)
            git pull --ff-only origin "$current_branch"
            if [ $? -ne 0 ]; then
                echo "⚠️  Cannot fast-forward. Manual intervention required."
            fi
            ;;
    esac
    
    # Restore stashed changes if any
    if git stash list | grep -q "pull-stash"; then
        echo "Restoring stashed changes..."
        git stash pop
    fi
}
```

## Branch Workflows

**1. Feature Branch Workflow (Enhanced)**
```bash
# Complete feature workflow with remote operations
feature_workflow() {
    # 1. Sync with remote first
    git fetch origin main
    git checkout main
    git pull origin main
    
    # 2. Create feature branch
    read -p "Enter ticket number: " ticket
    read -p "Enter feature description: " description
    branch_name="feature/$ticket-$description"
    git checkout -b "$branch_name"
    
    # 3. Work on feature
    echo "🔨 Working on feature branch: $branch_name"
    echo "Remember to commit frequently!"
    
    # 4. Keep updated with main
    echo -e "\n🔄 Sync strategy:"
    echo "Run periodically: git fetch origin && git rebase origin/main"
    
    # 5. Push for review
    git push -u origin "$branch_name"
    
    # 6. Create PR
    if command -v gh &> /dev/null; then
        gh pr create --title "$ticket: $description" \
                     --body "## Description\n\n## Changes\n\n## Testing"
    else
        echo "Visit: https://github.com/.../compare/$branch_name"
    fi
    
    # 7. After approval, merge
    echo -e "\n📋 Merge Options:"
    echo "1) Squash and merge (clean history)"
    echo "2) Rebase and merge (linear history)"
    echo "3) Create merge commit (preserve history)"
    read -p "Choice (1-3): " merge_choice
    
    git checkout main
    git pull origin main
    
    case $merge_choice in
        1)
            git merge --squash "$branch_name"
            git commit -m "feat($ticket): $description"
            ;;
        2)
            git rebase "$branch_name"
            ;;
        3)
            git merge --no-ff "$branch_name" -m "Merge feature/$ticket"
            ;;
    esac
    
    git push origin main
    
    # 8. Cleanup
    git branch -d "$branch_name"
    git push origin --delete "$branch_name"
    echo "✅ Feature workflow completed!"
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