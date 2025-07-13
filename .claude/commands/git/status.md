---
allowed-tools: all
description: Rich git status with actionable insights and workflow recommendations
---

# Intelligent Git Status Command

Enhanced git status that provides actionable insights, workflow recommendations, and comprehensive repository health information.

**Usage:** `/git/status $ARGUMENTS`

## 🚨 MORE THAN JUST STATUS - IT'S INTELLIGENCE! 🚨

**Your repository has a story to tell. Let's hear it!**

When you run `/git/status`, you'll receive:

1. **INSIGHTS** - Not just what changed, but what it means
2. **RECOMMENDATIONS** - Next steps based on current state
3. **WARNINGS** - Potential issues before they become problems
4. **CONTEXT** - How your work relates to the team

## Comprehensive Status Analysis

**Core Status Information:**
```bash
# Enhanced status display
show_rich_status() {
    echo "📊 Repository Intelligence Report"
    echo "================================="
    echo "📅 Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "🏢 Repository: $(basename $(git rev-parse --show-toplevel))"
    echo "🌿 Branch: $(git branch --show-current)"
    echo ""
    
    # Working tree status
    echo "🗂️  Working Tree Status:"
    echo "----------------------"
    
    # Staged changes
    staged_count=$(git diff --cached --name-only | wc -l)
    if [ "$staged_count" -gt 0 ]; then
        echo "✅ Staged Changes ($staged_count files):"
        git diff --cached --stat | head -10
        
        # Analyze staged changes
        if git diff --cached | grep -q "TODO\|FIXME\|XXX"; then
            echo "  ⚠️  Warning: TODOs detected in staged changes"
        fi
    else
        echo "📭 No staged changes"
    fi
    
    echo ""
    
    # Unstaged changes
    unstaged_count=$(git diff --name-only | wc -l)
    if [ "$unstaged_count" -gt 0 ]; then
        echo "📝 Unstaged Changes ($unstaged_count files):"
        git diff --stat | head -10
    else
        echo "✨ No unstaged changes"
    fi
    
    echo ""
    
    # Untracked files
    untracked_count=$(git ls-files --others --exclude-standard | wc -l)
    if [ "$untracked_count" -gt 0 ]; then
        echo "🆕 Untracked Files ($untracked_count):"
        git ls-files --others --exclude-standard | head -10
        
        # Check for potentially important untracked files
        if git ls-files --others --exclude-standard | grep -E "\.(env|key|pem|crt)$"; then
            echo "  🔐 Warning: Potentially sensitive untracked files detected!"
        fi
    fi
}
```

## Branch Intelligence

**Branch Context and Health:**
```bash
# Analyze branch relationships
analyze_branch_status() {
    current_branch=$(git branch --show-current)
    
    echo -e "\n🌳 Branch Intelligence:"
    echo "---------------------"
    
    # Upstream tracking
    upstream=$(git rev-parse --abbrev-ref "$current_branch"@{upstream} 2>/dev/null)
    if [ -n "$upstream" ]; then
        echo "📡 Tracking: $upstream"
        
        # Sync status
        ahead=$(git rev-list --count "$upstream".."$current_branch")
        behind=$(git rev-list --count "$current_branch".."$upstream")
        
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            echo "✅ Fully synchronized with $upstream"
        else
            [ "$ahead" -gt 0 ] && echo "⬆️  Ahead by $ahead commits"
            [ "$behind" -gt 0 ] && echo "⬇️  Behind by $behind commits"
            
            # Recommendations
            if [ "$behind" -gt 10 ]; then
                echo "  💡 Recommendation: Consider rebasing to get latest changes"
            fi
            if [ "$ahead" -gt 5 ] && [ "$behind" -eq 0 ]; then
                echo "  💡 Recommendation: Ready to push! Use: git push"
            fi
        fi
    else
        echo "🔗 No upstream branch set"
        echo "  💡 Recommendation: Set upstream with: git push -u origin $current_branch"
    fi
    
    # Branch age
    first_commit_date=$(git log --reverse --format=%ci "$current_branch" | head -1)
    if [ -n "$first_commit_date" ]; then
        age_days=$(( ($(date +%s) - $(date -d "$first_commit_date" +%s)) / 86400 ))
        echo "📅 Branch age: $age_days days"
        
        if [ "$age_days" -gt 30 ]; then
            echo "  ⚠️  Warning: Long-lived branch. Consider merging or rebasing."
        fi
    fi
}
```

## Commit Analysis

**Recent Activity and Patterns:**
```bash
# Analyze commit patterns
analyze_commits() {
    echo -e "\n📈 Commit Intelligence:"
    echo "---------------------"
    
    # Recent commits
    echo "🕐 Recent Commits:"
    git log --oneline -5 --graph --decorate
    
    # Commit frequency
    echo -e "\n📊 Commit Frequency (last 7 days):"
    git log --since="7 days ago" --format=%cd --date=format:%Y-%m-%d | sort | uniq -c | sort -k2
    
    # Uncommitted work time
    if [ -n "$(git status --porcelain)" ]; then
        last_commit_time=$(git log -1 --format=%ct)
        current_time=$(date +%s)
        uncommitted_hours=$(( (current_time - last_commit_time) / 3600 ))
        
        if [ "$uncommitted_hours" -gt 8 ]; then
            echo -e "\n⏰ Warning: $uncommitted_hours hours of uncommitted work"
            echo "  💡 Recommendation: Consider making a WIP commit"
        fi
    fi
}
```

## File Analysis

**Smart File Insights:**
```bash
# Analyze file changes
analyze_files() {
    echo -e "\n📁 File Intelligence:"
    echo "-------------------"
    
    # Large file detection
    large_files=$(git ls-files -z | xargs -0 -n1 -I{} sh -c 'test -f "{}" && stat -f%z "{}" 2>/dev/null || stat -c%s "{}" 2>/dev/null' | paste -d' ' <(git ls-files) - | awk '$2 > 10485760 {print $1 " (" int($2/1048576) "MB)"}')
    if [ -n "$large_files" ]; then
        echo "🏋️  Large files detected:"
        echo "$large_files"
        echo "  💡 Consider using Git LFS for these files"
    fi
    
    # File type distribution
    echo -e "\n📊 Changed File Types:"
    git diff --name-only HEAD | grep -E '\.[a-zA-Z0-9]+$' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5
    
    # Potentially problematic files
    echo -e "\n⚠️  Attention Required:"
    
    # Merge conflicts
    if git ls-files -u | grep -q .; then
        echo "❌ Merge conflicts detected in:"
        git diff --name-only --diff-filter=U
    fi
    
    # Binary files
    binary_files=$(git diff --numstat | awk '$1 == "-" && $2 == "-" {print $3}')
    if [ -n "$binary_files" ]; then
        echo "🔧 Binary files changed:"
        echo "$binary_files"
    fi
}
```

## Workflow Recommendations

**Smart Next Steps:**
```bash
# Provide intelligent recommendations
provide_recommendations() {
    echo -e "\n💡 Recommended Actions:"
    echo "----------------------"
    
    # Analyze current state
    has_staged=$(git diff --cached --quiet; echo $?)
    has_unstaged=$(git diff --quiet; echo $?)
    has_untracked=$(git ls-files --others --exclude-standard | grep -q .; echo $?)
    branch=$(git branch --show-current)
    
    # Priority 1: Conflicts
    if git ls-files -u | grep -q .; then
        echo "1. 🚨 Resolve merge conflicts first!"
        echo "   - Edit conflicted files"
        echo "   - Stage resolved files: git add <file>"
        echo "   - Complete merge: git commit"
        return
    fi
    
    # Priority 2: Incomplete staging
    if [ "$has_staged" -eq 1 ] && [ "$has_unstaged" -eq 1 ]; then
        echo "1. 📋 You have both staged and unstaged changes"
        echo "   - Review unstaged: git diff"
        echo "   - Stage additional: git add -p"
        echo "   - Or commit staged: git commit"
    fi
    
    # Priority 3: Ready to commit
    if [ "$has_staged" -eq 1 ] && [ "$has_unstaged" -eq 0 ]; then
        echo "1. ✅ Ready to commit!"
        echo "   - Commit changes: git commit -m \"type(scope): description\""
        echo "   - Or amend previous: git commit --amend"
    fi
    
    # Priority 4: Nothing staged
    if [ "$has_staged" -eq 0 ] && [ "$has_unstaged" -eq 1 ]; then
        echo "1. 📝 You have unstaged changes"
        echo "   - Review changes: git diff"
        echo "   - Stage all: git add -A"
        echo "   - Stage selective: git add -p"
    fi
    
    # Priority 5: Untracked files
    if [ "$has_untracked" -eq 0 ]; then
        echo "2. 🆕 You have untracked files"
        echo "   - Review files: git status -u"
        echo "   - Add to git: git add <file>"
        echo "   - Or update .gitignore"
    fi
    
    # Priority 6: Clean state
    if [ "$has_staged" -eq 0 ] && [ "$has_unstaged" -eq 0 ] && [ "$has_untracked" -eq 1 ]; then
        echo "1. ✨ Working directory clean!"
        
        # Check if ahead of upstream
        ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        if [ "$ahead" -gt 0 ]; then
            echo "   - Push changes: git push"
        else
            echo "   - Start new work: git checkout -b feature/new-feature"
            echo "   - Or pull latest: git pull"
        fi
    fi
}
```

## Repository Health Check

**Comprehensive Health Metrics:**
```bash
# Full repository health assessment
check_repo_health() {
    echo -e "\n🏥 Repository Health Check:"
    echo "--------------------------"
    
    # Size analysis
    repo_size=$(du -sh .git | cut -f1)
    echo "💾 Repository size: $repo_size"
    
    # Stash status
    stash_count=$(git stash list | wc -l)
    if [ "$stash_count" -gt 0 ]; then
        echo "📦 Stashed changes: $stash_count"
        if [ "$stash_count" -gt 5 ]; then
            echo "  ⚠️  Consider reviewing old stashes"
        fi
    fi
    
    # Hook status
    echo -e "\n🎣 Git Hooks:"
    for hook in pre-commit post-commit pre-push; do
        if [ -f ".git/hooks/$hook" ]; then
            echo "  ✅ $hook installed"
        else
            echo "  ❌ $hook not found"
        fi
    done
    
    # Worktree status
    worktree_count=$(git worktree list | wc -l)
    if [ "$worktree_count" -gt 1 ]; then
        echo -e "\n🌲 Multiple worktrees detected: $worktree_count"
        git worktree list
    fi
    
    # Submodule status
    if [ -f .gitmodules ]; then
        echo -e "\n📦 Submodules:"
        git submodule status
    fi
}
```

## Integration Status

**CI/CD and Team Sync:**
```bash
# Check integration status
check_integration_status() {
    echo -e "\n🔌 Integration Status:"
    echo "--------------------"
    
    # CI status (if gh is available)
    if command -v gh &> /dev/null; then
        echo "🏗️  CI Status:"
        gh run list --limit 3 --branch $(git branch --show-current) 2>/dev/null || echo "  No recent CI runs"
    fi
    
    # PR status
    if command -v gh &> /dev/null; then
        pr_status=$(gh pr status 2>/dev/null)
        if [ -n "$pr_status" ]; then
            echo -e "\n🔀 Pull Request Status:"
            echo "$pr_status"
        fi
    fi
    
    # Team activity
    echo -e "\n👥 Recent Team Activity:"
    git log --all --format='%h %an %cr %s' --since='24 hours ago' | head -5
}
```

## Quick Actions Menu

**Interactive Quick Actions:**
```bash
# Provide quick action menu
show_quick_actions() {
    echo -e "\n⚡ Quick Actions:"
    echo "----------------"
    echo "1) Stage all changes"
    echo "2) Commit with message"
    echo "3) Push to remote"
    echo "4) Pull latest changes"
    echo "5) Stash changes"
    echo "6) Create new branch"
    echo "7) View diff"
    echo "8) Run tests"
    echo "9) Show more details"
    echo "0) Exit"
    
    read -p "Choose action (0-9): " action
    
    case $action in
        1) git add -A ;;
        2) read -p "Commit message: " msg && git commit -m "$msg" ;;
        3) git push ;;
        4) git pull ;;
        5) git stash push -m "Quick stash $(date +%s)" ;;
        6) read -p "Branch name: " branch && git checkout -b "$branch" ;;
        7) git diff ;;
        8) make test || npm test || cargo test ;;
        9) git status -v ;;
        0) exit 0 ;;
    esac
}
```

## Summary Dashboard

**Complete Status Overview:**
```bash
# Main status command
git_status_enhanced() {
    clear
    echo "🎯 Git Status Intelligence Dashboard"
    echo "==================================="
    
    # Run all analyses
    show_rich_status
    analyze_branch_status
    analyze_commits
    analyze_files
    check_repo_health
    check_integration_status
    provide_recommendations
    
    # Summary
    echo -e "\n📋 Summary:"
    echo "---------"
    echo "✅ Ready to commit: $([ $(git diff --cached --quiet; echo $?) -eq 1 ] && echo "Yes" || echo "No")"
    echo "✅ Working tree clean: $([ -z "$(git status --porcelain)" ] && echo "Yes" || echo "No")"
    echo "✅ Up to date: $([ $(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0) -eq 0 ] && echo "Yes" || echo "No")"
    
    # Optional interactive menu
    echo -e "\nPress 'a' for actions menu, or any other key to exit..."
    read -n 1 -t 5 key
    if [[ "$key" == "a" ]]; then
        show_quick_actions
    fi
}

# Execute the enhanced status
git_status_enhanced
```

## Summary

The intelligent git status provides:
- ✅ Comprehensive repository analysis
- ✅ Actionable recommendations
- ✅ Workflow optimization tips
- ✅ Health and performance metrics
- ✅ Team collaboration insights
- ✅ Quick action shortcuts

Remember: **Status isn't just information - it's intelligence for better decisions!**