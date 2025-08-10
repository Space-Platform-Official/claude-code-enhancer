---
allowed-tools: all
description: Repository synchronization and maintenance workflow for team collaboration
---

# Repository Synchronization & Maintenance

Comprehensive workflow for keeping repositories synchronized, maintaining code quality, and ensuring smooth team collaboration across distributed development environments.

**Usage:** `/git/workflows/sync $ARGUMENTS`

## 🔄 CONTINUOUS SYNCHRONIZATION 🔄

**Synchronization is the heartbeat of collaborative development!**

This workflow manages:

1. **SYNC** - Multi-repository and branch synchronization
2. **MAINTENANCE** - Code quality and repository health
3. **CLEANUP** - Automated cleanup and optimization
4. **MONITORING** - Health checks and performance tracking
5. **RECOVERY** - Conflict resolution and error recovery

## Synchronization Overview

```
origin/main ──○──○──○──○──○──○── (canonical source)
              ↓  ↓  ↓  ↓  ↓  ↓
local/main ───○──○──○──○──○──○── (synchronized)
              ↑        ↑
         feature/123  feature/456
```

## Phase 1: Repository Synchronization

**Multi-Level Sync Strategy:**
```bash
comprehensive_sync() {
    echo "🔄 COMPREHENSIVE SYNCHRONIZATION"
    echo "==============================="
    
    # Initialize sync session
    init_sync_session
    
    # Level 1: Remote synchronization
    sync_with_remotes
    
    # Level 2: Branch synchronization
    sync_local_branches
    
    # Level 3: Fork synchronization (if applicable)
    sync_fork_with_upstream
    
    # Level 4: Dependency synchronization
    sync_dependencies
    
    # Level 5: Configuration synchronization
    sync_configurations
    
    # Level 6: Submodule synchronization
    sync_submodules
    
    # Generate sync report
    generate_sync_report
    
    echo "✅ Comprehensive synchronization completed"
}

# Enhanced remote synchronization
sync_with_remotes() {
    echo -e "\n🌐 Synchronizing with Remote Repositories"
    echo "========================================"
    
    # Fetch from all remotes
    echo "📡 Fetching from all remotes..."
    git fetch --all --prune --tags
    
    # Check each remote
    for remote in $(git remote); do
        echo -e "\n🔍 Checking remote: $remote"
        
        # Test connectivity
        if ! git ls-remote "$remote" HEAD &>/dev/null; then
            echo "  ❌ Cannot connect to $remote"
            continue
        fi
        
        echo "  ✅ Connected to $remote"
        
        # Get remote info
        remote_url=$(git remote get-url "$remote")
        echo "  🔗 URL: $remote_url"
        
        # Count branches and tags
        remote_branches=$(git ls-remote --heads "$remote" | wc -l)
        remote_tags=$(git ls-remote --tags "$remote" | wc -l)
        echo "  🌿 Branches: $remote_branches"
        echo "  🏷️  Tags: $remote_tags"
        
        # Check for new branches
        new_branches=$(git branch -r | grep "^  $remote/" | while read branch; do
            local_branch="${branch#  $remote/}"
            if ! git show-ref --verify --quiet "refs/heads/$local_branch"; then
                echo "    🆕 New branch: $branch"
            fi
        done)
        
        if [ -n "$new_branches" ]; then
            echo "$new_branches"
        fi
    done
    
    # Update remote tracking branches
    echo -e "\n🔄 Updating remote tracking branches..."
    git remote update
    
    echo "✅ Remote synchronization completed"
}

# Fork synchronization with upstream
sync_fork_with_upstream() {
    if ! git remote | grep -q upstream; then
        echo -e "\nℹ️  No upstream remote configured (not a fork)"
        return
    fi
    
    echo -e "\n🎆 Synchronizing Fork with Upstream"
    echo "==================================="
    
    # Fetch upstream changes
    echo "📥 Fetching upstream changes..."
    git fetch upstream
    
    # Check main branch sync status
    local_main="main"
    upstream_main="upstream/main"
    
    if ! git rev-parse --verify "$local_main" &>/dev/null; then
        local_main="master"
        upstream_main="upstream/master"
    fi
    
    # Calculate divergence
    behind=$(git rev-list --count "$local_main".."$upstream_main" 2>/dev/null || echo 0)
    ahead=$(git rev-list --count "$upstream_main".."$local_main" 2>/dev/null || echo 0)
    
    echo "📊 Fork Status:"
    echo "  ⬆️  Ahead of upstream: $ahead commits"
    echo "  ⬇️  Behind upstream: $behind commits"
    
    if [ "$behind" -gt 0 ]; then
        echo -e "\n⚠️  Fork is behind upstream!"
        read -p "Sync with upstream? (y/n): " sync_upstream
        
        if [[ "$sync_upstream" == "y" ]]; then
            current_branch=$(git branch --show-current)
            
            # Switch to main branch
            git checkout "$local_main"
            
            # Merge or rebase
            echo "Sync strategy:"
            echo "  1) Merge upstream (preserve fork history)"
            echo "  2) Rebase onto upstream (linear history)"
            read -p "Choice (1-2): " strategy
            
            case $strategy in
                1)
                    git merge "$upstream_main" -m "Merge upstream changes"
                    ;;
                2)
                    git rebase "$upstream_main"
                    ;;
            esac
            
            # Push to origin
            echo "🚀 Pushing updated main to origin..."
            git push origin "$local_main"
            
            # Return to original branch
            git checkout "$current_branch"
            
            echo "✅ Fork synchronized with upstream"
        fi
    else
        echo "✅ Fork is up to date with upstream"
    fi
}

# Submodule synchronization
sync_submodules() {
    if [ ! -f .gitmodules ]; then
        return
    fi
    
    echo -e "\n📦 Synchronizing Submodules"
    echo "=========================="
    
    # Initialize submodules if needed
    if [ ! -d .git/modules ]; then
        echo "🆕 Initializing submodules..."
        git submodule init
    fi
    
    # Update all submodules
    echo "🔄 Updating submodules..."
    git submodule update --remote --recursive
    
    # Check submodule status
    echo -e "\n📊 Submodule Status:"
    git submodule status --recursive
    
    # Check for uncommitted changes in submodules
    if git status --porcelain | grep -q "^.M"; then
        echo "⚠️  Submodules have uncommitted changes"
    else
        echo "✅ All submodules clean"
    fi
}

init_sync_session() {
    echo "🚀 Initializing Sync Session"
    echo "============================"
    
    # Create sync tracking
    sync_id="sync-$(date +%Y%m%d-%H%M%S)"
    
    cat > .sync_session << EOF
SYNC_ID=$sync_id
START_TIME=$(date +%s)
INITIAL_BRANCH=$(git branch --show-current)
INITIAL_COMMIT=$(git rev-parse HEAD)
STATUS=ACTIVE
CONFLICTS_RESOLVED=0
BRANCHES_SYNCED=0
REMOTES_SYNCED=0
EOF
    
    echo "📋 Sync session: $sync_id"
    echo "🌿 Current branch: $(git branch --show-current)"
    echo "📍 Current commit: $(git rev-parse --short HEAD)"
    
    # Pre-sync validation
    pre_sync_validation
}

pre_sync_validation() {
    echo "🔍 Pre-Sync Validation"
    echo "======================"
    
    # Check working directory status
    if ! is_repo_clean; then
        echo "⚠️  Working directory not clean"
        echo "Uncommitted changes detected:"
        git status --porcelain
        
        read -p "Stash changes and continue? (y/n): " stash_changes
        if [[ "$stash_changes" == "y" ]]; then
            stash_ref="sync-stash-$(date +%s)"
            git stash push -m "$stash_ref"
            echo "💾 Changes stashed: $stash_ref"
            echo "STASHED_CHANGES=$stash_ref" >> .sync_session
        else
            echo "❌ Sync cancelled. Commit or stash changes first."
            exit 1
        fi
    fi
    
    # Check repository integrity
    check_repo_integrity
    
    # Check network connectivity
    check_network_connectivity
    
    echo "✅ Pre-sync validation completed"
}

check_repo_integrity() {
    echo "🔍 Checking Repository Integrity"
    
    # Check for corruption
    if ! git fsck --no-dangling 2>/dev/null; then
        echo "⚠️ Repository integrity issues detected"
        echo "Consider running: git gc --aggressive"
    fi
    
    # Check disk space
    available_space=$(df . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt 1048576 ]; then  # Less than 1GB
        echo "⚠️ Low disk space: $(df -h . | awk 'NR==2 {print $4}') available"
    fi
    
    echo "✅ Repository integrity check completed"
}

check_network_connectivity() {
    echo "🌐 Checking Network Connectivity"
    
    # Test connection to all remotes
    all_connected=true
    
    for remote in $(git remote); do
        remote_url=$(git remote get-url "$remote")
        echo -n "  Testing $remote: "
        
        # Test with git ls-remote (more reliable than ping)
        if git ls-remote "$remote" HEAD &>/dev/null; then
            echo "✅ Connected"
        else
            echo "❌ Failed"
            all_connected=false
        fi
    done
    
    if [ "$all_connected" = false ]; then
        echo "⚠️  Some remotes are unreachable"
        read -p "Continue with available remotes? (y/n): " continue_sync
        if [[ "$continue_sync" != "y" ]]; then
            echo "❌ Cannot reach GitLab"
            exit 1
        fi
    fi
    
    # Test git connectivity
    if ! git ls-remote origin HEAD &>/dev/null; then
        echo "❌ Cannot connect to remote repository"
        exit 1
    fi
    
    echo "✅ Network connectivity verified"
}

sync_with_remotes() {
    echo "🌍 REMOTE SYNCHRONIZATION"
    echo "========================"
    
    # Discover all remotes
    remotes=($(git remote))
    
    echo "📡 Found ${#remotes[@]} remote(s): ${remotes[*]}"
    
    for remote in "${remotes[@]}"; do
        sync_remote "$remote"
    done
    
    # Update sync statistics
    sed -i.bak "s/REMOTES_SYNCED=0/REMOTES_SYNCED=${#remotes[@]}/" .sync_session
    rm -f .sync_session.bak
}

sync_remote() {
    local remote=$1
    
    echo "🔄 Syncing remote: $remote"
    echo "=========================="
    
    # Get remote info
    remote_url=$(git remote get-url "$remote")
    echo "📍 URL: $remote_url"
    
    # Fetch with progress
    echo "📥 Fetching from $remote..."
    if git fetch "$remote" --prune --progress; then
        echo "✅ Successfully fetched from $remote"
        
        # Show fetch statistics
        show_fetch_statistics "$remote"
    else
        echo "❌ Failed to fetch from $remote"
        echo "🔧 Attempting recovery..."
        recover_fetch_failure "$remote"
    fi
    
    # Sync tags
    sync_remote_tags "$remote"
}

show_fetch_statistics() {
    local remote=$1
    
    echo "📊 Fetch Statistics for $remote:"
    
    # Count new commits
    new_commits=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "0")
    echo "  📝 New commits available: $new_commits"
    
    # Show new branches
    new_branches=$(git branch -r --format='%(refname:short)' | grep "^$remote/" | wc -l)
    echo "  🌿 Remote branches: $new_branches"
    
    # Show new tags
    new_tags=$(git tag -l | wc -l)
    echo "  🏷️  Tags: $new_tags"
}

recover_fetch_failure() {
    local remote=$1
    
    echo "🔧 Recovering from fetch failure for $remote"
    
    # Check if remote is reachable
    if ! git ls-remote "$remote" HEAD &>/dev/null; then
        echo "❌ Remote $remote is not reachable"
        echo "Possible causes:"
        echo "- Network connectivity issues"
        echo "- Authentication problems"
        echo "- Remote repository moved/deleted"
        return 1
    fi
    
    # Try alternative fetch strategies
    echo "🔄 Trying alternative fetch strategies..."
    
    # Strategy 1: Shallow fetch
    if git fetch "$remote" --depth=1; then
        echo "✅ Shallow fetch successful"
        return 0
    fi
    
    # Strategy 2: Fetch specific branch
    default_branch=$(git symbolic-ref refs/remotes/"$remote"/HEAD 2>/dev/null | sed "s@^refs/remotes/$remote/@@")
    if [ -n "$default_branch" ] && git fetch "$remote" "$default_branch"; then
        echo "✅ Default branch fetch successful"
        return 0
    fi
    
    echo "❌ All fetch strategies failed for $remote"
    return 1
}

sync_remote_tags() {
    local remote=$1
    
    echo "🏷️ Syncing tags from $remote"
    
    # Fetch tags
    git fetch "$remote" --tags
    
    # Show tag summary
    local_tags=$(git tag -l | wc -l)
    echo "  📊 Total tags: $local_tags"
    
    # Check for lightweight vs annotated tags
    annotated_tags=$(git for-each-ref --format='%(objecttype) %(refname:short)' refs/tags | grep -c "tag " || echo "0")
    lightweight_tags=$((local_tags - annotated_tags))
    
    echo "  📋 Annotated tags: $annotated_tags"
    echo "  📄 Lightweight tags: $lightweight_tags"
}

sync_local_branches() {
    echo "🌿 LOCAL BRANCH SYNCHRONIZATION"
    echo "==============================="
    
    current_branch=$(git branch --show-current)
    
    # Get all local branches
    local_branches=($(git branch --format='%(refname:short)'))
    
    echo "🌳 Found ${#local_branches[@]} local branch(es)"
    
    # Sync each branch
    for branch in "${local_branches[@]}"; do
        sync_local_branch "$branch" "$current_branch"
    done
    
    # Return to original branch
    git checkout "$current_branch"
    
    # Update sync statistics
    sed -i.bak "s/BRANCHES_SYNCED=0/BRANCHES_SYNCED=${#local_branches[@]}/" .sync_session
    rm -f .sync_session.bak
}

sync_local_branch() {
    local branch=$1
    local original_branch=$2
    
    echo ""
    echo "🔄 Syncing branch: $branch"
    echo "=========================="
    
    # Check if branch has upstream
    upstream=$(git rev-parse --abbrev-ref "$branch"@{upstream} 2>/dev/null)
    
    if [ -z "$upstream" ]; then
        echo "📍 No upstream configured for $branch"
        offer_upstream_setup "$branch"
        return
    fi
    
    echo "📡 Upstream: $upstream"
    
    # Switch to branch
    git checkout "$branch" 2>/dev/null || {
        echo "❌ Failed to checkout $branch"
        return 1
    }
    
    # Get divergence info
    ahead=$(git rev-list --count "$upstream".."$branch" 2>/dev/null || echo "0")
    behind=$(git rev-list --count "$branch".."$upstream" 2>/dev/null || echo "0")
    
    echo "📊 Branch status: $ahead ahead, $behind behind"
    
    # Sync strategy based on divergence
    if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
        echo "✅ Branch is up to date"
    elif [ "$ahead" -eq 0 ] && [ "$behind" -gt 0 ]; then
        echo "📥 Fast-forward update available"
        fast_forward_branch "$branch" "$upstream"
    elif [ "$ahead" -gt 0 ] && [ "$behind" -eq 0 ]; then
        echo "📤 Local changes not pushed"
        offer_push_option "$branch"
    else
        echo "🔀 Branch has diverged"
        handle_diverged_branch "$branch" "$upstream" "$ahead" "$behind"
    fi
}

offer_upstream_setup() {
    local branch=$1
    
    echo "🔧 Setup upstream for $branch?"
    echo "Available remotes:"
    git remote -v | grep fetch
    
    read -p "Set upstream? (remote/branch or 'skip'): " upstream_choice
    
    if [[ "$upstream_choice" != "skip" ]] && [[ "$upstream_choice" =~ ^[^/]+/[^/]+$ ]]; then
        git branch --set-upstream-to="$upstream_choice" "$branch"
        echo "✅ Upstream set to: $upstream_choice"
        
        # Retry sync
        sync_local_branch "$branch" "$(git branch --show-current)"
    else
        echo "⏭️ Skipping upstream setup for $branch"
    fi
}

fast_forward_branch() {
    local branch=$1
    local upstream=$2
    
    echo "⏩ Fast-forwarding $branch"
    
    if git merge --ff-only "$upstream"; then
        echo "✅ Fast-forward successful"
        
        # Show update summary
        show_branch_update_summary "$branch"
    else
        echo "❌ Fast-forward failed"
        echo "Branch may have local changes"
    fi
}

offer_push_option() {
    local branch=$1
    
    echo "📤 Push local changes to upstream?"
    read -p "Push $branch? (y/n): " push_choice
    
    if [[ "$push_choice" == "y" ]]; then
        echo "🚀 Pushing $branch..."
        if git push; then
            echo "✅ Push successful"
        else
            echo "❌ Push failed"
            echo "May need to pull and merge first"
        fi
    else
        echo "⏭️ Skipping push for $branch"
    fi
}

handle_diverged_branch() {
    local branch=$1
    local upstream=$2
    local ahead=$3
    local behind=$4
    
    echo "🔀 Branch $branch has diverged ($ahead ahead, $behind behind)"
    echo ""
    echo "Sync options:"
    echo "1. Merge upstream changes"
    echo "2. Rebase onto upstream"
    echo "3. Skip this branch"
    echo "4. Interactive resolution"
    
    read -p "Choose sync strategy (1-4): " sync_strategy
    
    case $sync_strategy in
        1) merge_upstream_changes "$branch" "$upstream" ;;
        2) rebase_onto_upstream "$branch" "$upstream" ;;
        3) echo "⏭️ Skipping $branch" ;;
        4) interactive_divergence_resolution "$branch" "$upstream" ;;
        *) echo "❌ Invalid choice, skipping $branch" ;;
    esac
}

merge_upstream_changes() {
    local branch=$1
    local upstream=$2
    
    echo "🔀 Merging upstream changes into $branch"
    
    if git merge "$upstream" --no-ff -m "Sync: merge upstream changes into $branch"; then
        echo "✅ Merge successful"
        show_branch_update_summary "$branch"
        
        # Increment conflict resolution counter
        sed -i.bak 's/CONFLICTS_RESOLVED=\([0-9]*\)/CONFLICTS_RESOLVED=\1/' .sync_session
        rm -f .sync_session.bak
    else
        echo "❌ Merge conflicts detected"
        handle_merge_conflicts "$branch" "$upstream"
    fi
}

rebase_onto_upstream() {
    local branch=$1
    local upstream=$2
    
    echo "📈 Rebasing $branch onto $upstream"
    
    if git rebase "$upstream"; then
        echo "✅ Rebase successful"
        show_branch_update_summary "$branch"
    else
        echo "❌ Rebase conflicts detected"
        handle_rebase_conflicts "$branch" "$upstream"
    fi
}

interactive_divergence_resolution() {
    local branch=$1
    local upstream=$2
    
    echo "🔧 Interactive Divergence Resolution"
    echo "==================================="
    echo ""
    echo "Branch: $branch"
    echo "Upstream: $upstream"
    echo ""
    echo "Recent local commits:"
    git log --oneline "$upstream".."$branch" | head -5
    echo ""
    echo "Recent upstream commits:"
    git log --oneline "$branch".."$upstream" | head -5
    echo ""
    
    echo "Resolution options:"
    echo "1. Cherry-pick specific commits"
    echo "2. Create merge commit"
    echo "3. Reset to upstream (lose local changes)"
    echo "4. Manual resolution"
    
    read -p "Choose resolution (1-4): " resolution_choice
    
    case $resolution_choice in
        1) cherry_pick_resolution "$branch" "$upstream" ;;
        2) merge_upstream_changes "$branch" "$upstream" ;;
        3) reset_to_upstream "$branch" "$upstream" ;;
        4) manual_resolution_guidance "$branch" "$upstream" ;;
        *) echo "❌ Invalid choice" ;;
    esac
}

cherry_pick_resolution() {
    local branch=$1
    local upstream=$2
    
    echo "🍒 Cherry-pick Resolution"
    echo "========================"
    
    echo "Commits to potentially cherry-pick:"
    git log --oneline "$upstream".."$branch" --reverse
    
    echo ""
    read -p "Enter commit hashes to cherry-pick (space-separated): " commits_to_pick
    
    if [ -n "$commits_to_pick" ]; then
        # Reset to upstream first
        git reset --hard "$upstream"
        
        # Cherry-pick selected commits
        for commit in $commits_to_pick; do
            echo "🍒 Cherry-picking $commit"
            if ! git cherry-pick "$commit"; then
                echo "❌ Cherry-pick conflict on $commit"
                echo "Resolve conflicts and continue with: git cherry-pick --continue"
                return 1
            fi
        done
        
        echo "✅ Cherry-pick resolution completed"
    else
        echo "ℹ️ No commits selected for cherry-pick"
    fi
}

reset_to_upstream() {
    local branch=$1
    local upstream=$2
    
    echo "⚠️ DESTRUCTIVE OPERATION WARNING"
    echo "This will PERMANENTLY DELETE local changes on $branch"
    echo ""
    
    read -p "Type 'RESET' to confirm: " reset_confirm
    
    if [[ "$reset_confirm" == "RESET" ]]; then
        # Create backup tag first
        backup_tag="backup-$branch-$(date +%Y%m%d-%H%M%S)"
        git tag "$backup_tag" "$branch"
        echo "💾 Backup created: $backup_tag"
        
        # Reset to upstream
        git reset --hard "$upstream"
        echo "✅ Branch reset to upstream"
        echo "💾 Recovery command: git reset --hard $backup_tag"
    else
        echo "❌ Reset cancelled"
    fi
}

manual_resolution_guidance() {
    local branch=$1
    local upstream=$2
    
    echo "📚 Manual Resolution Guidance"
    echo "============================="
    echo ""
    echo "To manually resolve the divergence:"
    echo ""
    echo "1. Analyze the differences:"
    echo "   git log --oneline --graph $upstream...$branch"
    echo ""
    echo "2. For merge approach:"
    echo "   git merge $upstream"
    echo ""
    echo "3. For rebase approach:"
    echo "   git rebase $upstream"
    echo ""
    echo "4. For specific commits:"
    echo "   git cherry-pick <commit-hash>"
    echo ""
    echo "5. To see file differences:"
    echo "   git diff $upstream...$branch"
    echo ""
    
    read -p "Continue with next branch? (y/n): " continue_sync
    if [[ "$continue_sync" != "y" ]]; then
        echo "❌ Sync stopped for manual resolution"
        exit 1
    fi
}

handle_merge_conflicts() {
    local branch=$1
    local upstream=$2
    
    echo "⚠️ MERGE CONFLICTS DETECTED"
    echo "==========================="
    echo ""
    
    # Show conflicted files
    conflicted_files=($(git diff --name-only --diff-filter=U))
    echo "📄 Conflicted files:"
    for file in "${conflicted_files[@]}"; do
        echo "  - $file"
    done
    
    echo ""
    echo "Conflict resolution options:"
    echo "1. Open merge tool"
    echo "2. Manual resolution guidance"
    echo "3. Abort merge"
    echo "4. Auto-resolve (use ours/theirs)"
    
    read -p "Choose option (1-4): " conflict_option
    
    case $conflict_option in
        1) 
            if command -v git-mergetool &> /dev/null; then
                git mergetool
                finalize_merge_resolution "$branch"
            else
                echo "❌ No merge tool configured"
                manual_conflict_guidance
            fi
            ;;
        2) manual_conflict_guidance ;;
        3) 
            git merge --abort
            echo "❌ Merge aborted"
            ;;
        4) auto_resolve_conflicts ;;
        *) echo "❌ Invalid option" ;;
    esac
}

manual_conflict_guidance() {
    echo "📚 Manual Conflict Resolution"
    echo "============================="
    echo ""
    echo "To resolve conflicts manually:"
    echo ""
    echo "1. Edit conflicted files and resolve markers:"
    echo "   <<<<<<< HEAD"
    echo "   (your changes)"
    echo "   ======="
    echo "   (upstream changes)"
    echo "   >>>>>>> branch-name"
    echo ""
    echo "2. Stage resolved files:"
    echo "   git add <resolved-file>"
    echo ""
    echo "3. Complete the merge:"
    echo "   git commit"
    echo ""
    echo "4. Continue sync process"
    echo ""
    
    read -p "Press Enter when conflicts are resolved..." wait_for_resolution
    
    # Check if conflicts are resolved
    if git diff --name-only --diff-filter=U | grep -q .; then
        echo "❌ Conflicts still exist"
        return 1
    else
        finalize_merge_resolution "$branch"
    fi
}

auto_resolve_conflicts() {
    echo "🤖 Auto-resolve Conflicts"
    echo "========================"
    echo ""
    echo "Auto-resolution strategies:"
    echo "1. Use ours (keep local changes)"
    echo "2. Use theirs (accept upstream changes)"
    echo "3. Cancel auto-resolution"
    
    read -p "Choose strategy (1-3): " auto_strategy
    
    case $auto_strategy in
        1)
            git checkout --ours .
            git add .
            echo "✅ Using local changes (ours)"
            finalize_merge_resolution "$branch"
            ;;
        2)
            git checkout --theirs .
            git add .
            echo "✅ Using upstream changes (theirs)"
            finalize_merge_resolution "$branch"
            ;;
        3)
            echo "❌ Auto-resolution cancelled"
            ;;
        *)
            echo "❌ Invalid strategy"
            ;;
    esac
}

finalize_merge_resolution() {
    local branch=$1
    
    # Complete the merge
    if git commit --no-edit; then
        echo "✅ Merge completed successfully"
        
        # Update conflict resolution counter
        conflicts_resolved=$(grep CONFLICTS_RESOLVED= .sync_session | cut -d= -f2)
        new_count=$((conflicts_resolved + 1))
        sed -i.bak "s/CONFLICTS_RESOLVED=$conflicts_resolved/CONFLICTS_RESOLVED=$new_count/" .sync_session
        rm -f .sync_session.bak
        
        show_branch_update_summary "$branch"
    else
        echo "❌ Failed to complete merge"
    fi
}

handle_rebase_conflicts() {
    local branch=$1
    local upstream=$2
    
    echo "⚠️ REBASE CONFLICTS DETECTED"
    echo "============================"
    echo ""
    
    echo "Rebase conflict resolution:"
    echo "1. Resolve conflicts manually"
    echo "2. Skip this commit"
    echo "3. Abort rebase"
    
    read -p "Choose option (1-3): " rebase_option
    
    case $rebase_option in
        1)
            echo "📝 Resolve conflicts in your editor, then:"
            echo "   git add <resolved-files>"
            echo "   git rebase --continue"
            read -p "Press Enter when resolved..." wait_rebase
            ;;
        2)
            git rebase --skip
            echo "⏭️ Commit skipped"
            ;;
        3)
            git rebase --abort
            echo "❌ Rebase aborted"
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
}

show_branch_update_summary() {
    local branch=$1
    
    echo "📊 Update Summary for $branch:"
    echo "=============================="
    
    # Show commit count changes
    total_commits=$(git rev-list --count HEAD)
    echo "  📝 Total commits: $total_commits"
    
    # Show recent activity
    echo "  🕐 Recent commits:"
    git log --oneline -3 | sed 's/^/    /'
    
    # Show file statistics
    files_changed=$(git diff --name-only HEAD~1..HEAD 2>/dev/null | wc -l)
    echo "  📄 Files changed in last commit: $files_changed"
}

sync_dependencies() {
    echo "📦 DEPENDENCY SYNCHRONIZATION"
    echo "============================="
    
    # Package managers to check
    package_managers=(
        "package.json:npm"
        "requirements.txt:pip"
        "Cargo.toml:cargo"
        "go.mod:go"
        "Gemfile:bundle"
        "composer.json:composer"
        "pom.xml:maven"
        "build.gradle:gradle"
    )
    
    dependencies_updated=false
    
    for pm in "${package_managers[@]}"; do
        file="${pm%:*}"
        manager="${pm#*:}"
        
        if [ -f "$file" ]; then
            sync_package_manager "$file" "$manager"
            dependencies_updated=true
        fi
    done
    
    if [ "$dependencies_updated" = false ]; then
        echo "ℹ️ No package managers detected"
    fi
}

sync_package_manager() {
    local file=$1
    local manager=$2
    
    echo ""
    echo "📦 Syncing $manager dependencies"
    echo "==============================="
    
    case $manager in
        npm)
            sync_npm_dependencies
            ;;
        pip)
            sync_pip_dependencies
            ;;
        cargo)
            sync_cargo_dependencies
            ;;
        go)
            sync_go_dependencies
            ;;
        bundle)
            sync_bundle_dependencies
            ;;
        composer)
            sync_composer_dependencies
            ;;
        maven)
            sync_maven_dependencies
            ;;
        gradle)
            sync_gradle_dependencies
            ;;
        *)
            echo "ℹ️ Unsupported package manager: $manager"
            ;;
    esac
}

sync_npm_dependencies() {
    echo "📦 NPM Dependencies"
    
    # Check for package-lock.json changes
    if git diff --name-only HEAD~1..HEAD | grep -q "package-lock.json"; then
        echo "🔄 package-lock.json changed, updating dependencies..."
        if npm install; then
            echo "✅ NPM dependencies updated"
        else
            echo "❌ NPM dependency update failed"
        fi
    else
        echo "ℹ️ No package-lock.json changes detected"
    fi
    
    # Check for outdated packages
    echo "🔍 Checking for outdated packages..."
    if command -v npm &> /dev/null; then
        outdated_count=$(npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
        echo "📊 Outdated packages: $outdated_count"
        
        if [ "$outdated_count" -gt 0 ]; then
            echo "⚠️ Consider updating outdated packages"
            echo "Run: npm outdated"
        fi
    fi
}

sync_pip_dependencies() {
    echo "🐍 Python Dependencies"
    
    # Check for requirements.txt changes
    if git diff --name-only HEAD~1..HEAD | grep -q "requirements.txt"; then
        echo "🔄 requirements.txt changed, updating dependencies..."
        if pip install -r requirements.txt; then
            echo "✅ Python dependencies updated"
        else
            echo "❌ Python dependency update failed"
        fi
    else
        echo "ℹ️ No requirements.txt changes detected"
    fi
    
    # Check for outdated packages
    if command -v pip &> /dev/null; then
        echo "🔍 Checking for outdated packages..."
        outdated=$(pip list --outdated --format=json 2>/dev/null | jq length 2>/dev/null || echo 0)
        echo "📊 Outdated packages: $outdated"
    fi
}

sync_cargo_dependencies() {
    echo "🦀 Rust Dependencies"
    
    # Check for Cargo.lock changes
    if git diff --name-only HEAD~1..HEAD | grep -q "Cargo.lock"; then
        echo "🔄 Cargo.lock changed, updating dependencies..."
        if cargo build; then
            echo "✅ Cargo dependencies updated"
        else
            echo "❌ Cargo dependency update failed"
        fi
    else
        echo "ℹ️ No Cargo.lock changes detected"
    fi
    
    # Check for outdated packages
    if command -v cargo &> /dev/null; then
        echo "🔍 Checking for outdated packages..."
        if command -v cargo-outdated &> /dev/null; then
            cargo outdated
        else
            echo "ℹ️ Install cargo-outdated for dependency analysis"
        fi
    fi
}

sync_go_dependencies() {
    echo "🐹 Go Dependencies"
    
    # Check for go.sum changes
    if git diff --name-only HEAD~1..HEAD | grep -q "go.sum"; then
        echo "🔄 go.sum changed, updating dependencies..."
        if go mod download; then
            echo "✅ Go dependencies updated"
        else
            echo "❌ Go dependency update failed"
        fi
    else
        echo "ℹ️ No go.sum changes detected"
    fi
    
    # Check for tidiness
    if go mod tidy; then
        echo "✅ Go modules are tidy"
    else
        echo "❌ Go mod tidy failed"
    fi
}

sync_bundle_dependencies() {
    echo "💎 Ruby Dependencies"
    
    # Check for Gemfile.lock changes
    if git diff --name-only HEAD~1..HEAD | grep -q "Gemfile.lock"; then
        echo "🔄 Gemfile.lock changed, updating dependencies..."
        if bundle install; then
            echo "✅ Ruby dependencies updated"
        else
            echo "❌ Ruby dependency update failed"
        fi
    else
        echo "ℹ️ No Gemfile.lock changes detected"
    fi
    
    # Check for outdated gems
    if command -v bundle &> /dev/null; then
        echo "🔍 Checking for outdated gems..."
        bundle outdated
    fi
}

sync_composer_dependencies() {
    echo "🐘 PHP Dependencies"
    
    # Check for composer.lock changes
    if git diff --name-only HEAD~1..HEAD | grep -q "composer.lock"; then
        echo "🔄 composer.lock changed, updating dependencies..."
        if composer install; then
            echo "✅ PHP dependencies updated"
        else
            echo "❌ PHP dependency update failed"
        fi
    else
        echo "ℹ️ No composer.lock changes detected"
    fi
    
    # Check for outdated packages
    if command -v composer &> /dev/null; then
        echo "🔍 Checking for outdated packages..."
        composer outdated
    fi
}

sync_maven_dependencies() {
    echo "☕ Maven Dependencies"
    
    # Check for pom.xml changes
    if git diff --name-only HEAD~1..HEAD | grep -q "pom.xml"; then
        echo "🔄 pom.xml changed, updating dependencies..."
        if mvn dependency:resolve; then
            echo "✅ Maven dependencies updated"
        else
            echo "❌ Maven dependency update failed"
        fi
    else
        echo "ℹ️ No pom.xml changes detected"
    fi
}

sync_gradle_dependencies() {
    echo "🐘 Gradle Dependencies"
    
    # Check for build.gradle changes
    if git diff --name-only HEAD~1..HEAD | grep -q "build.gradle"; then
        echo "🔄 build.gradle changed, updating dependencies..."
        if ./gradlew dependencies; then
            echo "✅ Gradle dependencies updated"
        else
            echo "❌ Gradle dependency update failed"
        fi
    else
        echo "ℹ️ No build.gradle changes detected"
    fi
}

sync_configurations() {
    echo "⚙️ CONFIGURATION SYNCHRONIZATION"
    echo "==============================="
    
    # Configuration files to sync
    config_files=(
        ".gitignore"
        ".gitattributes"
        ".editorconfig"
        ".prettierrc"
        ".eslintrc"
        "tsconfig.json"
        "jest.config.js"
        "webpack.config.js"
        "docker-compose.yml"
        "Dockerfile"
        ".env.example"
    )
    
    configs_updated=false
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            sync_configuration_file "$config_file"
            configs_updated=true
        fi
    done
    
    if [ "$configs_updated" = false ]; then
        echo "ℹ️ No configuration files to sync"
    fi
    
    # Sync IDE configurations
    sync_ide_configurations
    
    # Sync CI/CD configurations
    sync_cicd_configurations
}

sync_configuration_file() {
    local config_file=$1
    
    echo "⚙️ Checking $config_file"
    
    # Check if file changed recently
    if git diff --name-only HEAD~1..HEAD | grep -q "^$config_file$"; then
        echo "🔄 $config_file was updated"
        
        # Validate configuration if possible
        validate_configuration_file "$config_file"
    else
        echo "✅ $config_file is up to date"
    fi
}

validate_configuration_file() {
    local config_file=$1
    
    case "$config_file" in
        "package.json")
            if command -v jq &> /dev/null; then
                if jq . "$config_file" >/dev/null 2>&1; then
                    echo "✅ $config_file is valid JSON"
                else
                    echo "❌ $config_file has JSON syntax errors"
                fi
            fi
            ;;
        "tsconfig.json"|"jest.config.js")
            if command -v jq &> /dev/null && [[ "$config_file" == *.json ]]; then
                if jq . "$config_file" >/dev/null 2>&1; then
                    echo "✅ $config_file is valid JSON"
                else
                    echo "❌ $config_file has JSON syntax errors"
                fi
            fi
            ;;
        "docker-compose.yml")
            if command -v docker-compose &> /dev/null; then
                if docker-compose config >/dev/null 2>&1; then
                    echo "✅ $config_file is valid"
                else
                    echo "❌ $config_file has YAML syntax errors"
                fi
            fi
            ;;
        *)
            echo "ℹ️ No validation available for $config_file"
            ;;
    esac
}

sync_ide_configurations() {
    echo "💻 IDE Configuration Sync"
    echo "========================"
    
    # VS Code settings
    if [ -d ".vscode" ]; then
        echo "🔄 VS Code configurations found"
        
        vscode_files=(".vscode/settings.json" ".vscode/launch.json" ".vscode/tasks.json")
        for vscode_file in "${vscode_files[@]}"; do
            if [ -f "$vscode_file" ]; then
                if git diff --name-only HEAD~1..HEAD | grep -q "^$vscode_file$"; then
                    echo "📝 $vscode_file updated"
                    
                    # Validate JSON
                    if command -v jq &> /dev/null; then
                        if jq . "$vscode_file" >/dev/null 2>&1; then
                            echo "✅ $vscode_file is valid"
                        else
                            echo "❌ $vscode_file has JSON errors"
                        fi
                    fi
                fi
            fi
        done
    fi
    
    # IntelliJ/WebStorm settings
    if [ -d ".idea" ]; then
        echo "💡 IntelliJ IDEA configurations found"
        echo "ℹ️ IDE-specific settings detected (not validated)"
    fi
}

sync_cicd_configurations() {
    echo "🤖 CI/CD Configuration Sync"
    echo "=========================="
    
    cicd_dirs=(".github/workflows" ".gitlab-ci.yml" "azure-pipelines.yml" "Jenkinsfile" ".circleci")
    
    for cicd_item in "${cicd_dirs[@]}"; do
        if [ -e "$cicd_item" ]; then
            echo "🔄 CI/CD configuration found: $cicd_item"
            
            if git diff --name-only HEAD~1..HEAD | grep -q "$cicd_item"; then
                echo "📝 $cicd_item updated"
                
                # Validate YAML files
                if [[ "$cicd_item" == *.yml ]] || [[ "$cicd_item" == *.yaml ]]; then
                    validate_yaml_file "$cicd_item"
                fi
            fi
        fi
    done
}

validate_yaml_file() {
    local yaml_file=$1
    
    if command -v yamllint &> /dev/null; then
        if yamllint "$yaml_file" >/dev/null 2>&1; then
            echo "✅ $yaml_file is valid YAML"
        else
            echo "❌ $yaml_file has YAML syntax errors"
        fi
    elif command -v python &> /dev/null; then
        if python -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
            echo "✅ $yaml_file is valid YAML"
        else
            echo "❌ $yaml_file has YAML syntax errors"
        fi
    else
        echo "ℹ️ No YAML validator available for $yaml_file"
    fi
}

generate_sync_report() {
    echo "📊 GENERATING SYNC REPORT"
    echo "========================="
    
    source .sync_session
    
    end_time=$(date +%s)
    duration=$((end_time - START_TIME))
    
    # Create comprehensive sync report
    cat > "sync-report-$SYNC_ID.md" << EOF
# Synchronization Report - $SYNC_ID

**Started:** $(date -d "@$START_TIME" '+%Y-%m-%d %H:%M:%S')
**Completed:** $(date -d "@$end_time" '+%Y-%m-%d %H:%M:%S')
**Duration:** $(($duration / 60))m $(($duration % 60))s
**Initial Branch:** $INITIAL_BRANCH

## Summary

### Statistics
- **Remotes Synced:** $REMOTES_SYNCED
- **Branches Synced:** $BRANCHES_SYNCED
- **Conflicts Resolved:** $CONFLICTS_RESOLVED
- **Status:** $(grep STATUS= .sync_session | cut -d= -f2)

### Repository State
- **Current Branch:** $(git branch --show-current)
- **Current Commit:** $(git rev-parse --short HEAD)
- **Working Directory:** $(if is_repo_clean; then echo "Clean"; else echo "Modified"; fi)

## Remote Synchronization

$(git remote -v | while read remote url direction; do
    if [[ "$direction" == "(fetch)" ]]; then
        echo "### $remote"
        echo "- **URL:** $url"
        echo "- **Status:** ✅ Synchronized"
        echo "- **Last Fetch:** $(date)"
        echo ""
    fi
done)

## Branch Status

$(git branch --format='%(refname:short)' | while read branch; do
    upstream=$(git rev-parse --abbrev-ref "$branch"@{upstream} 2>/dev/null || echo "No upstream")
    if [[ "$upstream" != "No upstream" ]]; then
        ahead=$(git rev-list --count "$upstream".."$branch" 2>/dev/null || echo "0")
        behind=$(git rev-list --count "$branch".."$upstream" 2>/dev/null || echo "0")
        echo "### $branch"
        echo "- **Upstream:** $upstream"
        echo "- **Status:** $ahead ahead, $behind behind"
        if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
            echo "- **Sync Status:** ✅ Up to date"
        elif [ "$ahead" -gt 0 ] || [ "$behind" -gt 0 ]; then
            echo "- **Sync Status:** ⚠️ Needs attention"
        fi
        echo ""
    fi
done)

## Dependency Status

$(if [ -f package.json ]; then
    echo "### NPM Dependencies"
    echo "- **package.json:** $(if [ -f package.json ]; then echo "Present"; else echo "Missing"; fi)"
    echo "- **package-lock.json:** $(if [ -f package-lock.json ]; then echo "Present"; else echo "Missing"; fi)"
    if command -v npm &> /dev/null; then
        outdated=$(npm outdated --json 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
        echo "- **Outdated packages:** $outdated"
    fi
    echo ""
fi)

$(if [ -f requirements.txt ]; then
    echo "### Python Dependencies"
    echo "- **requirements.txt:** Present"
    if command -v pip &> /dev/null; then
        outdated=$(pip list --outdated --format=json 2>/dev/null | jq length 2>/dev/null || echo 0)
        echo "- **Outdated packages:** $outdated"
    fi
    echo ""
fi)

## Configuration Files

$(for config in .gitignore .editorconfig package.json tsconfig.json; do
    if [ -f "$config" ]; then
        echo "- **$config:** ✅ Present"
    fi
done)

## Issues Detected

$(if [ "$CONFLICTS_RESOLVED" -gt 0 ]; then
    echo "- ⚠️ $CONFLICTS_RESOLVED conflict(s) were resolved during sync"
else
    echo "- ✅ No conflicts detected"
fi)

$(if ! is_repo_clean; then
    echo "- ⚠️ Working directory has uncommitted changes"
else
    echo "- ✅ Working directory is clean"
fi)

## Recommendations

$(if [ "$CONFLICTS_RESOLVED" -gt 0 ]; then
    echo "- Review resolved conflicts for correctness"
fi)

$(if ! is_repo_clean; then
    echo "- Commit or stash uncommitted changes"
fi)

$(git branch --format='%(refname:short)' | while read branch; do
    upstream=$(git rev-parse --abbrev-ref "$branch"@{upstream} 2>/dev/null || echo "")
    if [ -n "$upstream" ]; then
        ahead=$(git rev-list --count "$upstream".."$branch" 2>/dev/null || echo "0")
        behind=$(git rev-list --count "$branch".."$upstream" 2>/dev/null || echo "0")
        if [ "$ahead" -gt 0 ]; then
            echo "- Push local changes in $branch to upstream"
        fi
        if [ "$behind" -gt 0 ]; then
            echo "- Pull upstream changes for $branch"
        fi
    fi
done)

## Next Sync

Recommended sync frequency: Every 1-2 days for active development

Run: \`/git/workflows/sync\`

---
**Generated by:** Claude Code Sync Workflow
**Report ID:** $SYNC_ID
EOF
    
    echo "📋 Sync report generated: sync-report-$SYNC_ID.md"
    
    # Show summary
    show_sync_summary "$SYNC_ID" "$duration"
}

show_sync_summary() {
    local sync_id=$1
    local duration=$2
    
    source .sync_session
    
    echo ""
    echo "📊 SYNC SUMMARY"
    echo "==============="
    echo "Session: $sync_id"
    echo "Duration: $(($duration / 60))m $(($duration % 60))s"
    echo "Remotes: $REMOTES_SYNCED synced"
    echo "Branches: $BRANCHES_SYNCED processed"
    echo "Conflicts: $CONFLICTS_RESOLVED resolved"
    echo ""
    
    if [ "$CONFLICTS_RESOLVED" -eq 0 ] && is_repo_clean; then
        echo "✅ SYNC COMPLETED SUCCESSFULLY"
        echo "Repository is fully synchronized and clean"
    elif [ "$CONFLICTS_RESOLVED" -gt 0 ]; then
        echo "⚠️ SYNC COMPLETED WITH CONFLICTS"
        echo "Review resolved conflicts for accuracy"
    else
        echo "✅ SYNC COMPLETED"
        echo "Minor issues may require attention"
    fi
    
    # Restore stashed changes if any
    if grep -q "STASHED_CHANGES=" .sync_session; then
        stash_ref=$(grep "STASHED_CHANGES=" .sync_session | cut -d= -f2)
        echo ""
        read -p "Restore stashed changes ($stash_ref)? (y/n): " restore_stash
        if [[ "$restore_stash" == "y" ]]; then
            if git stash pop; then
                echo "✅ Stashed changes restored"
            else
                echo "❌ Failed to restore stashed changes"
                echo "Manual restoration may be needed: git stash list"
            fi
        fi
    fi
    
    # Cleanup sync session
    rm -f .sync_session
}
```

## Phase 2: Repository Maintenance

**Automated Maintenance Tasks:**
```bash
repository_maintenance() {
    echo "🛠️ REPOSITORY MAINTENANCE"
    echo "========================="
    
    # Initialize maintenance session
    init_maintenance_session
    
    # Cleanup operations
    perform_repository_cleanup
    
    # Optimization tasks
    optimize_repository
    
    # Health checks
    perform_health_checks
    
    # Security maintenance
    security_maintenance
    
    # Generate maintenance report
    generate_maintenance_report
}

init_maintenance_session() {
    echo "🔧 Initializing Maintenance Session"
    echo "==================================="
    
    maintenance_id="maint-$(date +%Y%m%d-%H%M%S)"
    
    cat > .maintenance_session << EOF
MAINTENANCE_ID=$maintenance_id
START_TIME=$(date +%s)
INITIAL_REPO_SIZE=$(du -sh . | cut -f1)
INITIAL_OBJECT_COUNT=$(git count-objects -v | grep "count" | awk '{print $2}')
STATUS=ACTIVE
CLEANUP_PERFORMED=false
OPTIMIZATION_PERFORMED=false
ISSUES_FOUND=0
EOF
    
    echo "🔧 Maintenance session: $maintenance_id"
    echo "📊 Initial repository size: $(du -sh . | cut -f1)"
    echo "📦 Initial object count: $(git count-objects -v | grep "count" | awk '{print $2}')"
}

perform_repository_cleanup() {
    echo ""
    echo "🧹 REPOSITORY CLEANUP"
    echo "===================="
    
    # Clean up merged branches
    cleanup_merged_branches
    
    # Remove stale remote branches
    cleanup_stale_remote_branches
    
    # Clean up tags
    cleanup_old_tags
    
    # Remove untracked files
    cleanup_untracked_files
    
    # Clean up Git internal files
    cleanup_git_internals
    
    # Update maintenance status
    sed -i.bak 's/CLEANUP_PERFORMED=false/CLEANUP_PERFORMED=true/' .maintenance_session
    rm -f .maintenance_session.bak
}

cleanup_merged_branches() {
    echo "🌿 Cleaning up merged branches"
    echo "=============================="
    
    # Find merged branches (excluding main/master/develop)
    merged_branches=($(git branch --merged main | grep -v -E "(main|master|develop|\*)" | tr -d ' '))
    
    if [ ${#merged_branches[@]} -eq 0 ]; then
        echo "✅ No merged branches to clean up"
        return
    fi
    
    echo "📋 Found ${#merged_branches[@]} merged branch(es):"
    for branch in "${merged_branches[@]}"; do
        last_commit=$(git log -1 --format=%cr "$branch")
        echo "  - $branch (last commit: $last_commit)"
    done
    
    echo ""
    read -p "Delete these merged branches? (y/n): " delete_merged
    
    if [[ "$delete_merged" == "y" ]]; then
        for branch in "${merged_branches[@]}"; do
            echo "🗑️ Deleting branch: $branch"
            git branch -d "$branch"
        done
        echo "✅ Merged branches cleaned up"
    else
        echo "⏭️ Skipping merged branch cleanup"
    fi
}

cleanup_stale_remote_branches() {
    echo ""
    echo "📡 Cleaning up stale remote branches"
    echo "==================================="
    
    # Prune remote branches
    echo "🔄 Pruning remote branches..."
    git remote prune origin
    
    # Find stale remote tracking branches
    stale_remotes=($(git for-each-ref --format='%(refname:short) %(upstream:track)' refs/heads | grep '\[gone\]' | awk '{print $1}'))
    
    if [ ${#stale_remotes[@]} -eq 0 ]; then
        echo "✅ No stale remote tracking branches found"
        return
    fi
    
    echo "📋 Found ${#stale_remotes[@]} stale remote tracking branch(es):"
    for branch in "${stale_remotes[@]}"; do
        echo "  - $branch"
    done
    
    echo ""
    read -p "Delete these stale tracking branches? (y/n): " delete_stale
    
    if [[ "$delete_stale" == "y" ]]; then
        for branch in "${stale_remotes[@]}"; do
            echo "🗑️ Deleting stale branch: $branch"
            git branch -D "$branch"
        done
        echo "✅ Stale remote tracking branches cleaned up"
    else
        echo "⏭️ Skipping stale branch cleanup"
    fi
}

cleanup_old_tags() {
    echo ""
    echo "🏷️ Tag cleanup analysis"
    echo "======================="
    
    total_tags=$(git tag -l | wc -l)
    echo "📊 Total tags: $total_tags"
    
    if [ "$total_tags" -gt 100 ]; then
        echo "⚠️ Large number of tags detected"
        echo ""
        echo "Tag categories:"
        echo "- Version tags: $(git tag -l | grep -E '^v[0-9]+\.' | wc -l)"
        echo "- Release tags: $(git tag -l | grep -i release | wc -l)"
        echo "- Backup tags: $(git tag -l | grep -i backup | wc -l)"
        echo "- Other tags: $(git tag -l | grep -v -E '^v[0-9]+\.|release|backup' | wc -l)"
        
        echo ""
        read -p "Review and clean up old tags? (y/n): " cleanup_tags
        
        if [[ "$cleanup_tags" == "y" ]]; then
            interactive_tag_cleanup
        fi
    else
        echo "✅ Tag count is reasonable ($total_tags)"
    fi
}

interactive_tag_cleanup() {
    echo "🏷️ Interactive Tag Cleanup"
    echo "=========================="
    
    echo "Tag cleanup options:"
    echo "1. Remove backup tags older than 30 days"
    echo "2. Remove development/test tags"
    echo "3. Custom tag pattern removal"
    echo "4. Skip tag cleanup"
    
    read -p "Choose option (1-4): " tag_option
    
    case $tag_option in
        1) cleanup_old_backup_tags ;;
        2) cleanup_dev_tags ;;
        3) custom_tag_cleanup ;;
        4) echo "⏭️ Skipping tag cleanup" ;;
        *) echo "❌ Invalid option" ;;
    esac
}

cleanup_old_backup_tags() {
    echo "🗑️ Cleaning up old backup tags"
    
    # Find backup tags older than 30 days
    cutoff_date=$(date -d "30 days ago" +%s)
    
    git for-each-ref --format='%(refname:short) %(creatordate:unix)' refs/tags | \
    while read tag_name tag_date; do
        if [[ "$tag_name" =~ backup ]] && [ "$tag_date" -lt "$cutoff_date" ]; then
            echo "🗑️ Deleting old backup tag: $tag_name"
            git tag -d "$tag_name"
        fi
    done
    
    echo "✅ Old backup tags cleaned up"
}

cleanup_dev_tags() {
    echo "🗑️ Cleaning up development tags"
    
    dev_patterns=("dev-" "test-" "tmp-" "debug-" "experimental-")
    
    for pattern in "${dev_patterns[@]}"; do
        dev_tags=($(git tag -l | grep "^$pattern"))
        
        if [ ${#dev_tags[@]} -gt 0 ]; then
            echo "Found ${#dev_tags[@]} tags matching '$pattern':"
            for tag in "${dev_tags[@]}"; do
                echo "  - $tag"
            done
            
            read -p "Delete '$pattern' tags? (y/n): " delete_dev_tags
            if [[ "$delete_dev_tags" == "y" ]]; then
                for tag in "${dev_tags[@]}"; do
                    git tag -d "$tag"
                done
                echo "✅ Deleted '$pattern' tags"
            fi
        fi
    done
}

custom_tag_cleanup() {
    echo "🔧 Custom Tag Cleanup"
    echo "===================="
    
    read -p "Enter tag pattern to delete (e.g., 'test-*'): " pattern
    
    if [ -n "$pattern" ]; then
        matching_tags=($(git tag -l | grep "$pattern"))
        
        if [ ${#matching_tags[@]} -gt 0 ]; then
            echo "Found ${#matching_tags[@]} matching tags:"
            for tag in "${matching_tags[@]}"; do
                echo "  - $tag"
            done
            
            read -p "Delete these tags? (y/n): " delete_custom
            if [[ "$delete_custom" == "y" ]]; then
                for tag in "${matching_tags[@]}"; do
                    git tag -d "$tag"
                done
                echo "✅ Custom tags deleted"
            fi
        else
            echo "ℹ️ No tags match pattern: $pattern"
        fi
    fi
}

cleanup_untracked_files() {
    echo ""
    echo "📄 Untracked files cleanup"
    echo "========================="
    
    # Check for untracked files
    untracked_files=($(git ls-files --others --exclude-standard))
    
    if [ ${#untracked_files[@]} -eq 0 ]; then
        echo "✅ No untracked files found"
        return
    fi
    
    echo "📋 Found ${#untracked_files[@]} untracked file(s):"
    for file in "${untracked_files[@]}"; do
        file_size=$(du -h "$file" 2>/dev/null | cut -f1)
        echo "  - $file ($file_size)"
    done | head -20
    
    if [ ${#untracked_files[@]} -gt 20 ]; then
        echo "  ... and $((${#untracked_files[@]} - 20)) more files"
    fi
    
    echo ""
    echo "Cleanup options:"
    echo "1. Review and add to .gitignore"
    echo "2. Delete untracked files"
    echo "3. Skip cleanup"
    
    read -p "Choose option (1-3): " untracked_option
    
    case $untracked_option in
        1) review_gitignore_additions ;;
        2) delete_untracked_files ;;
        3) echo "⏭️ Skipping untracked file cleanup" ;;
        *) echo "❌ Invalid option" ;;
    esac
}

review_gitignore_additions() {
    echo "📝 Reviewing .gitignore additions"
    
    # Common patterns to suggest
    common_patterns=(
        "*.log"
        "*.tmp"
        "*.cache"
        ".DS_Store"
        "Thumbs.db"
        "node_modules/"
        ".env"
        "dist/"
        "build/"
        "*.swp"
        "*.swo"
    )
    
    echo "Common patterns to add to .gitignore:"
    for pattern in "${common_patterns[@]}"; do
        if git ls-files --others --exclude-standard | grep -q "${pattern//\*/.*}"; then
            echo "  - $pattern"
        fi
    done
    
    read -p "Add suggested patterns to .gitignore? (y/n): " add_patterns
    if [[ "$add_patterns" == "y" ]]; then
        for pattern in "${common_patterns[@]}"; do
            if git ls-files --others --exclude-standard | grep -q "${pattern//\*/.*}"; then
                echo "$pattern" >> .gitignore
            fi
        done
        
        # Sort and deduplicate .gitignore
        sort .gitignore | uniq > .gitignore.tmp
        mv .gitignore.tmp .gitignore
        
        echo "✅ .gitignore updated"
    fi
}

delete_untracked_files() {
    echo "🗑️ Deleting untracked files"
    echo "=========================="
    
    echo "⚠️ WARNING: This will permanently delete untracked files!"
    read -p "Type 'DELETE' to confirm: " delete_confirm
    
    if [[ "$delete_confirm" == "DELETE" ]]; then
        # Show what will be deleted
        git clean -n
        
        read -p "Proceed with deletion? (y/n): " proceed_delete
        if [[ "$proceed_delete" == "y" ]]; then
            git clean -f
            echo "✅ Untracked files deleted"
        else
            echo "❌ Deletion cancelled"
        fi
    else
        echo "❌ Deletion cancelled"
    fi
}

cleanup_git_internals() {
    echo ""
    echo "🔧 Git internals cleanup"
    echo "======================="
    
    # Run git garbage collection
    echo "🗑️ Running garbage collection..."
    git gc --auto
    
    # Show repository size before and after
    current_size=$(du -sh . | cut -f1)
    echo "📊 Current repository size: $current_size"
    
    # Clean up reflog if it's large
    reflog_size=$(git reflog --all | wc -l)
    if [ "$reflog_size" -gt 1000 ]; then
        echo "📋 Large reflog detected ($reflog_size entries)"
        read -p "Clean up old reflog entries? (y/n): " clean_reflog
        
        if [[ "$clean_reflog" == "y" ]]; then
            # Expire reflog entries older than 30 days
            git reflog expire --expire=30.days --all
            git gc --prune=30.days
            echo "✅ Reflog cleaned up"
        fi
    fi
    
    echo "✅ Git internals cleanup completed"
}

optimize_repository() {
    echo ""
    echo "⚡ REPOSITORY OPTIMIZATION"
    echo "========================="
    
    # Git configuration optimization
    optimize_git_config
    
    # Repository structure optimization
    optimize_repository_structure
    
    # Performance optimization
    optimize_performance
    
    # Update maintenance status
    sed -i.bak 's/OPTIMIZATION_PERFORMED=false/OPTIMIZATION_PERFORMED=true/' .maintenance_session
    rm -f .maintenance_session.bak
}

optimize_git_config() {
    echo "⚙️ Git Configuration Optimization"
    echo "================================="
    
    # Recommended Git configurations
    optimizations=(
        "core.preloadindex:true:Preload index for faster operations"
        "core.fscache:true:Enable filesystem cache (Windows)"
        "gc.auto:256:Automatic garbage collection threshold"
        "pack.useBitmaps:true:Use bitmap index for faster operations"
        "pack.writeBitmaps:true:Write bitmap index"
        "repack.useDeltaBaseOffset:true:Use delta base offset for smaller packs"
        "feature.manyFiles:true:Optimize for repositories with many files"
    )
    
    echo "Checking Git configuration optimizations..."
    
    for optimization in "${optimizations[@]}"; do
        IFS=':' read -r config_key config_value description <<< "$optimization"
        
        current_value=$(git config --global "$config_key" 2>/dev/null || echo "unset")
        
        if [[ "$current_value" != "$config_value" ]]; then
            echo "📝 $config_key: $current_value → $config_value ($description)"
            read -p "Apply this optimization? (y/n): " apply_opt
            
            if [[ "$apply_opt" == "y" ]]; then
                git config --global "$config_key" "$config_value"
                echo "✅ Applied: $config_key = $config_value"
            fi
        else
            echo "✅ $config_key: already optimized ($config_value)"
        fi
    done
}

optimize_repository_structure() {
    echo ""
    echo "🏗️ Repository Structure Optimization"
    echo "===================================="
    
    # Check for large files
    check_large_files
    
    # Optimize pack files
    optimize_pack_files
    
    # Check repository health
    check_repository_health
}

check_large_files() {
    echo "📦 Checking for large files"
    echo "=========================="
    
    # Find large files in repository history
    large_files=$(git rev-list --objects --all | \
        git cat-file --batch-check='%(objecttype) %(objectname) %(objectsize) %(rest)' | \
        awk '/^blob/ {print substr($0,6)}' | \
        sort --numeric-sort --key=2 | \
        tail -10)
    
    if [ -n "$large_files" ]; then
        echo "📊 Largest files in repository history:"
        echo "$large_files" | while read size hash path; do
            size_mb=$(echo "scale=2; $size / 1048576" | bc)
            echo "  - $path: ${size_mb}MB"
        done
        
        echo ""
        echo "Consider using Git LFS for large files"
        echo "See: https://git-lfs.github.io/"
    else
        echo "✅ No unusually large files detected"
    fi
}

optimize_pack_files() {
    echo ""
    echo "📦 Optimizing pack files"
    echo "======================="
    
    # Get pack file information
    pack_count=$(find .git/objects/pack -name "*.pack" | wc -l)
    echo "📊 Current pack files: $pack_count"
    
    if [ "$pack_count" -gt 10 ]; then
        echo "⚠️ Large number of pack files detected"
        read -p "Repack repository for better performance? (y/n): " repack_repo
        
        if [[ "$repack_repo" == "y" ]]; then
            echo "🔄 Repacking repository..."
            git repack -a -d --depth=50 --window=50
            echo "✅ Repository repacked"
            
            new_pack_count=$(find .git/objects/pack -name "*.pack" | wc -l)
            echo "📊 Pack files after optimization: $new_pack_count"
        fi
    else
        echo "✅ Pack file count is reasonable"
    fi
}

check_repository_health() {
    echo ""
    echo "🏥 Repository Health Check"
    echo "========================="
    
    # Check repository integrity
    echo "🔍 Checking repository integrity..."
    if git fsck --full; then
        echo "✅ Repository integrity check passed"
    else
        echo "❌ Repository integrity issues detected"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + 1))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    fi
    
    # Check for duplicate objects
    echo ""
    echo "🔍 Checking for duplicate objects..."
    duplicate_count=$(git count-objects -v | grep "duplicate" | awk '{print $2}')
    if [ "$duplicate_count" -gt 0 ]; then
        echo "⚠️ Found $duplicate_count duplicate objects"
        echo "Consider running: git gc --aggressive"
    else
        echo "✅ No duplicate objects found"
    fi
}

optimize_performance() {
    echo ""
    echo "⚡ Performance Optimization"
    echo "=========================="
    
    # Enable commit-graph
    enable_commit_graph
    
    # Optimize index operations
    optimize_index_operations
    
    # Set up useful aliases
    setup_useful_aliases
}

enable_commit_graph() {
    echo "📊 Enabling commit-graph"
    echo "======================="
    
    if git config core.commitGraph 2>/dev/null | grep -q "true"; then
        echo "✅ Commit-graph already enabled"
    else
        git config core.commitGraph true
        git commit-graph write --reachable --changed-paths
        echo "✅ Commit-graph enabled and generated"
    fi
}

optimize_index_operations() {
    echo ""
    echo "📇 Optimizing index operations"
    echo "============================="
    
    # Enable split index for large repositories
    if [ "$(git ls-files | wc -l)" -gt 1000 ]; then
        if ! git config core.splitIndex 2>/dev/null | grep -q "true"; then
            read -p "Enable split index for faster operations? (y/n): " enable_split
            if [[ "$enable_split" == "y" ]]; then
                git config core.splitIndex true
                echo "✅ Split index enabled"
            fi
        else
            echo "✅ Split index already enabled"
        fi
    fi
    
    # Update index
    git update-index --refresh >/dev/null 2>&1 || true
    echo "✅ Index refreshed"
}

setup_useful_aliases() {
    echo ""
    echo "🔧 Setting up useful Git aliases"
    echo "==============================="
    
    aliases=(
        "st:status --short:Short status"
        "co:checkout:Checkout shorthand"
        "br:branch:Branch shorthand"
        "ci:commit:Commit shorthand"
        "lg:log --oneline --graph --decorate:Pretty log"
        "unstage:reset HEAD --:Unstage files"
        "last:log -1 HEAD:Show last commit"
        "visual:!gitk:Visual Git interface"
    )
    
    echo "Checking useful Git aliases..."
    
    for alias_def in "${aliases[@]}"; do
        IFS=':' read -r alias_name alias_command description <<< "$alias_def"
        
        current_alias=$(git config --global "alias.$alias_name" 2>/dev/null || echo "unset")
        
        if [[ "$current_alias" == "unset" ]]; then
            echo "📝 $alias_name: $description"
            read -p "Set up alias '$alias_name'? (y/n): " setup_alias
            
            if [[ "$setup_alias" == "y" ]]; then
                git config --global "alias.$alias_name" "$alias_command"
                echo "✅ Alias set: git $alias_name"
            fi
        else
            echo "✅ $alias_name: already configured"
        fi
    done
}

perform_health_checks() {
    echo ""
    echo "🏥 HEALTH CHECKS"
    echo "================"
    
    # File system health
    check_filesystem_health
    
    # Git configuration health
    check_git_configuration_health
    
    # Workflow health
    check_workflow_health
    
    # Security health
    check_security_health
}

check_filesystem_health() {
    echo "💾 File System Health"
    echo "===================="
    
    # Check disk space
    available_space=$(df . | awk 'NR==2 {print $4}')
    available_space_mb=$((available_space / 1024))
    
    echo "📊 Available disk space: ${available_space_mb}MB"
    
    if [ "$available_space_mb" -lt 1024 ]; then
        echo "⚠️ Low disk space warning"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + 1))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    else
        echo "✅ Sufficient disk space available"
    fi
    
    # Check file permissions
    if [ -w ".git" ]; then
        echo "✅ Git directory is writable"
    else
        echo "❌ Git directory is not writable"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + 1))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    fi
}

check_git_configuration_health() {
    echo ""
    echo "⚙️ Git Configuration Health"
    echo "=========================="
    
    # Essential Git configurations
    essential_configs=(
        "user.name"
        "user.email"
        "core.editor"
        "init.defaultBranch"
    )
    
    config_issues=0
    
    for config in "${essential_configs[@]}"; do
        value=$(git config --global "$config" 2>/dev/null || echo "unset")
        
        if [[ "$value" == "unset" ]]; then
            echo "⚠️ $config: not set"
            config_issues=$((config_issues + 1))
        else
            echo "✅ $config: $value"
        fi
    done
    
    if [ "$config_issues" -gt 0 ]; then
        echo "⚠️ $config_issues configuration issue(s) detected"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + config_issues))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    else
        echo "✅ All essential configurations are set"
    fi
}

check_workflow_health() {
    echo ""
    echo "🔄 Workflow Health"
    echo "=================="
    
    # Check for common workflow files
    workflow_files=(
        ".gitignore:Git ignore rules"
        "README.md:Project documentation"
        ".editorconfig:Editor configuration"
        "package.json:Node.js project file"
        "requirements.txt:Python dependencies"
        "Cargo.toml:Rust project file"
        "go.mod:Go module file"
    )
    
    workflow_score=0
    total_applicable=0
    
    for workflow_file in "${workflow_files[@]}"; do
        IFS=':' read -r filename description <<< "$workflow_file"
        
        # Check if file is applicable to this project
        case "$filename" in
            "package.json")
                if find . -name "*.js" -o -name "*.ts" | head -1 | grep -q .; then
                    total_applicable=$((total_applicable + 1))
                    if [ -f "$filename" ]; then
                        echo "✅ $filename: $description"
                        workflow_score=$((workflow_score + 1))
                    else
                        echo "⚠️ $filename: missing ($description)"
                    fi
                fi
                ;;
            "requirements.txt")
                if find . -name "*.py" | head -1 | grep -q .; then
                    total_applicable=$((total_applicable + 1))
                    if [ -f "$filename" ]; then
                        echo "✅ $filename: $description"
                        workflow_score=$((workflow_score + 1))
                    else
                        echo "⚠️ $filename: missing ($description)"
                    fi
                fi
                ;;
            "Cargo.toml")
                if find . -name "*.rs" | head -1 | grep -q .; then
                    total_applicable=$((total_applicable + 1))
                    if [ -f "$filename" ]; then
                        echo "✅ $filename: $description"
                        workflow_score=$((workflow_score + 1))
                    else
                        echo "⚠️ $filename: missing ($description)"
                    fi
                fi
                ;;
            "go.mod")
                if find . -name "*.go" | head -1 | grep -q .; then
                    total_applicable=$((total_applicable + 1))
                    if [ -f "$filename" ]; then
                        echo "✅ $filename: $description"
                        workflow_score=$((workflow_score + 1))
                    else
                        echo "⚠️ $filename: missing ($description)"
                    fi
                fi
                ;;
            *)
                total_applicable=$((total_applicable + 1))
                if [ -f "$filename" ]; then
                    echo "✅ $filename: $description"
                    workflow_score=$((workflow_score + 1))
                else
                    echo "⚠️ $filename: missing ($description)"
                fi
                ;;
        esac
    done
    
    if [ "$total_applicable" -gt 0 ]; then
        workflow_percentage=$((workflow_score * 100 / total_applicable))
        echo ""
        echo "📊 Workflow health: $workflow_percentage% ($workflow_score/$total_applicable)"
        
        if [ "$workflow_percentage" -lt 70 ]; then
            echo "⚠️ Consider improving project workflow setup"
        fi
    else
        echo "ℹ️ No specific workflow requirements detected"
    fi
}

check_security_health() {
    echo ""
    echo "🔒 Security Health"
    echo "=================="
    
    # Check for sensitive files that shouldn't be tracked
    sensitive_patterns=(
        "*.key"
        "*.pem"
        "*.p12"
        "*.pfx"
        ".env"
        "id_rsa"
        "id_dsa"
        "config.json"
        "secrets.json"
        "*.secret"
    )
    
    security_issues=0
    
    echo "🔍 Checking for sensitive files in repository..."
    
    for pattern in "${sensitive_patterns[@]}"; do
        if git ls-files | grep -q "$pattern"; then
            echo "⚠️ Potentially sensitive files found matching: $pattern"
            git ls-files | grep "$pattern" | sed 's/^/    /'
            security_issues=$((security_issues + 1))
        fi
    done
    
    if [ "$security_issues" -eq 0 ]; then
        echo "✅ No obvious sensitive files detected in repository"
    else
        echo "⚠️ $security_issues potential security issue(s) detected"
        echo "Consider adding sensitive files to .gitignore"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + security_issues))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    fi
}

security_maintenance() {
    echo ""
    echo "🔒 SECURITY MAINTENANCE"
    echo "======================"
    
    # Check commit signatures
    check_commit_signatures
    
    # Audit dependencies
    audit_dependencies
    
    # Check for secrets in history
    check_secrets_in_history
    
    # Update security configurations
    update_security_configurations
}

check_commit_signatures() {
    echo "✍️ Commit Signature Check"
    echo "========================"
    
    # Check if GPG signing is enabled
    signing_key=$(git config user.signingkey 2>/dev/null || echo "unset")
    commit_signing=$(git config commit.gpgsign 2>/dev/null || echo "false")
    
    echo "📝 Commit signing configuration:"
    echo "  - Signing key: $signing_key"
    echo "  - Auto-sign commits: $commit_signing"
    
    if [[ "$signing_key" == "unset" ]] || [[ "$commit_signing" == "false" ]]; then
        echo "ℹ️ Commit signing is not fully configured"
        echo "Consider enabling GPG commit signing for better security"
        
        read -p "Set up commit signing? (y/n): " setup_signing
        if [[ "$setup_signing" == "y" ]]; then
            echo "📚 Commit signing setup guide:"
            echo "1. Generate GPG key: gpg --gen-key"
            echo "2. List keys: gpg --list-secret-keys --keyid-format LONG"
            echo "3. Set signing key: git config --global user.signingkey [KEY_ID]"
            echo "4. Enable auto-signing: git config --global commit.gpgsign true"
        fi
    else
        echo "✅ Commit signing is configured"
    fi
}

audit_dependencies() {
    echo ""
    echo "📦 Dependency Security Audit"
    echo "============================"
    
    # Check different package managers for vulnerabilities
    audit_performed=false
    
    if [ -f "package.json" ]; then
        echo "🔍 Auditing NPM dependencies..."
        if npm audit --audit-level=moderate; then
            echo "✅ NPM audit passed"
        else
            echo "⚠️ NPM vulnerabilities detected"
            echo "Run: npm audit fix"
        fi
        audit_performed=true
    fi
    
    if [ -f "requirements.txt" ]; then
        echo "🔍 Checking Python dependencies..."
        if command -v safety &> /dev/null; then
            if safety check; then
                echo "✅ Python dependencies are safe"
            else
                echo "⚠️ Python vulnerabilities detected"
            fi
        else
            echo "ℹ️ Install 'safety' for Python dependency auditing"
        fi
        audit_performed=true
    fi
    
    if [ -f "Cargo.toml" ]; then
        echo "🔍 Checking Rust dependencies..."
        if command -v cargo-audit &> /dev/null; then
            if cargo audit; then
                echo "✅ Rust dependencies are safe"
            else
                echo "⚠️ Rust vulnerabilities detected"
            fi
        else
            echo "ℹ️ Install 'cargo-audit' for Rust dependency auditing"
        fi
        audit_performed=true
    fi
    
    if [ "$audit_performed" = false ]; then
        echo "ℹ️ No supported package managers found for auditing"
    fi
}

check_secrets_in_history() {
    echo ""
    echo "🕵️ Checking for secrets in Git history"
    echo "======================================"
    
    # Common secret patterns
    secret_patterns=(
        "password\s*=\s*['\"][^'\"]+['\"]"
        "api_key\s*=\s*['\"][^'\"]+['\"]"
        "secret\s*=\s*['\"][^'\"]+['\"]"
        "token\s*=\s*['\"][^'\"]+['\"]"
        "apikey\s*=\s*['\"][^'\"]+['\"]"
        "private_key"
        "-----BEGIN.*PRIVATE KEY-----"
    )
    
    secrets_found=0
    
    echo "🔍 Scanning repository history for potential secrets..."
    
    for pattern in "${secret_patterns[@]}"; do
        if git log --all -p | grep -i -E "$pattern" >/dev/null 2>&1; then
            echo "⚠️ Potential secret pattern found: $pattern"
            secrets_found=$((secrets_found + 1))
        fi
    done
    
    if [ "$secrets_found" -eq 0 ]; then
        echo "✅ No obvious secrets detected in repository history"
    else
        echo "⚠️ $secrets_found potential secret pattern(s) detected"
        echo "Consider using tools like 'git-secrets' or 'truffleHog' for detailed analysis"
        
        # Update issues counter
        issues_found=$(grep ISSUES_FOUND= .maintenance_session | cut -d= -f2)
        new_count=$((issues_found + secrets_found))
        sed -i.bak "s/ISSUES_FOUND=$issues_found/ISSUES_FOUND=$new_count/" .maintenance_session
        rm -f .maintenance_session.bak
    fi
}

update_security_configurations() {
    echo ""
    echo "🔧 Security Configuration Updates"
    echo "================================="
    
    # Security-focused Git configurations
    security_configs=(
        "transfer.fsckObjects:true:Enable object checking during transfer"
        "fetch.fsckObjects:true:Enable object checking during fetch"
        "receive.fsckObjects:true:Enable object checking during receive"
    )
    
    echo "Checking security configurations..."
    
    for config_def in "${security_configs[@]}"; do
        IFS=':' read -r config_key config_value description <<< "$config_def"
        
        current_value=$(git config "$config_key" 2>/dev/null || echo "unset")
        
        if [[ "$current_value" != "$config_value" ]]; then
            echo "📝 $config_key: $description"
            read -p "Apply security setting? (y/n): " apply_security
            
            if [[ "$apply_security" == "y" ]]; then
                git config --global "$config_key" "$config_value"
                echo "✅ Applied: $config_key = $config_value"
            fi
        else
            echo "✅ $config_key: already configured securely"
        fi
    done
}

generate_maintenance_report() {
    echo ""
    echo "📊 GENERATING MAINTENANCE REPORT"
    echo "==============================="
    
    source .maintenance_session
    
    end_time=$(date +%s)
    duration=$((end_time - START_TIME))
    final_repo_size=$(du -sh . | cut -f1)
    final_object_count=$(git count-objects -v | grep "count" | awk '{print $2}')
    
    # Create comprehensive maintenance report
    cat > "maintenance-report-$MAINTENANCE_ID.md" << EOF
# Repository Maintenance Report - $MAINTENANCE_ID

**Started:** $(date -d "@$START_TIME" '+%Y-%m-%d %H:%M:%S')
**Completed:** $(date -d "@$end_time" '+%Y-%m-%d %H:%M:%S')
**Duration:** $(($duration / 60))m $(($duration % 60))s

## Summary

### Repository Metrics
- **Initial Size:** $INITIAL_REPO_SIZE
- **Final Size:** $final_repo_size
- **Initial Objects:** $INITIAL_OBJECT_COUNT
- **Final Objects:** $final_object_count
- **Issues Found:** $ISSUES_FOUND

### Tasks Performed
- **Cleanup:** $(if [ "$CLEANUP_PERFORMED" = "true" ]; then echo "✅ Completed"; else echo "❌ Skipped"; fi)
- **Optimization:** $(if [ "$OPTIMIZATION_PERFORMED" = "true" ]; then echo "✅ Completed"; else echo "❌ Skipped"; fi)
- **Health Checks:** ✅ Completed
- **Security Audit:** ✅ Completed

## Detailed Results

### Repository Cleanup
$(if [ "$CLEANUP_PERFORMED" = "true" ]; then
    echo "- Merged branches cleaned up"
    echo "- Stale remote branches removed"
    echo "- Untracked files processed"
    echo "- Git internals optimized"
else
    echo "- Cleanup was skipped"
fi)

### Optimization Results
$(if [ "$OPTIMIZATION_PERFORMED" = "true" ]; then
    echo "- Git configuration optimized"
    echo "- Repository structure improved"
    echo "- Performance enhancements applied"
    echo "- Useful aliases configured"
else
    echo "- Optimization was skipped"
fi)

### Health Check Results
- File system health: $(if [ "$ISSUES_FOUND" -eq 0 ]; then echo "✅ Good"; else echo "⚠️ Issues detected"; fi)
- Git configuration: Reviewed
- Workflow setup: Analyzed
- Security posture: Audited

### Issues Detected
$(if [ "$ISSUES_FOUND" -eq 0 ]; then
    echo "✅ No issues detected"
else
    echo "⚠️ $ISSUES_FOUND issue(s) found and reported"
    echo "Review the maintenance session for details"
fi)

## Recommendations

### Immediate Actions
$(if [ "$ISSUES_FOUND" -gt 0 ]; then
    echo "- Address the $ISSUES_FOUND issue(s) identified during maintenance"
else
    echo "- No immediate actions required"
fi)

### Regular Maintenance
- Run repository maintenance every 1-2 weeks
- Monitor repository size and performance
- Keep dependencies updated and secure
- Review and update .gitignore regularly

### Performance Tips
- Use shallow clones for CI/CD when possible
- Consider Git LFS for large files
- Keep number of open branches reasonable
- Regular garbage collection and repacking

### Security Best Practices
- Enable commit signing for important repositories
- Regular dependency security audits
- Avoid committing sensitive information
- Use proper .gitignore patterns

## Next Maintenance
Recommended next maintenance: $(date -d "+2 weeks" '+%Y-%m-%d')

Run: \`/git/workflows/sync --maintenance\`

---
**Generated by:** Claude Code Sync Workflow
**Report ID:** $MAINTENANCE_ID
**Repository:** $(git remote get-url origin 2>/dev/null || echo "Local repository")
EOF
    
    echo "📋 Maintenance report generated: maintenance-report-$MAINTENANCE_ID.md"
    
    # Show maintenance summary
    show_maintenance_summary "$MAINTENANCE_ID" "$duration"
}

show_maintenance_summary() {
    local maintenance_id=$1
    local duration=$2
    
    source .maintenance_session
    
    echo ""
    echo "📊 MAINTENANCE SUMMARY"
    echo "====================="
    echo "Session: $maintenance_id"
    echo "Duration: $(($duration / 60))m $(($duration % 60))s"
    echo "Repository size: $INITIAL_REPO_SIZE → $(du -sh . | cut -f1)"
    echo "Objects: $INITIAL_OBJECT_COUNT → $(git count-objects -v | grep "count" | awk '{print $2}')"
    echo "Issues found: $ISSUES_FOUND"
    echo ""
    
    if [ "$ISSUES_FOUND" -eq 0 ]; then
        echo "✅ MAINTENANCE COMPLETED SUCCESSFULLY"
        echo "Repository is healthy and optimized"
    else
        echo "⚠️ MAINTENANCE COMPLETED WITH ISSUES"
        echo "Review the maintenance report for details"
    fi
    
    echo ""
    echo "🔄 Next maintenance recommended in 2 weeks"
    echo "📋 Full report: maintenance-report-$MAINTENANCE_ID.md"
    
    # Cleanup maintenance session
    rm -f .maintenance_session
}
```

## Advanced Synchronization Features

**Multi-Repository Sync:**
```bash
multi_repo_sync() {
    echo "🔄 MULTI-REPOSITORY SYNCHRONIZATION"
    echo "==================================="
    
    # Discover related repositories
    discover_related_repos
    
    # Sync multiple repositories
    sync_repository_group
    
    # Cross-repository consistency checks
    cross_repo_consistency_check
    
    # Generate multi-repo report
    generate_multi_repo_report
}

discover_related_repos() {
    echo "🔍 Discovering Related Repositories"
    echo "=================================="
    
    # Look for configuration files that might reference other repos
    related_configs=(
        ".gitmodules"
        "package.json"
        "go.mod"
        "requirements.txt"
        "docker-compose.yml"
    )
    
    related_repos=()
    
    for config_file in "${related_configs[@]}"; do
        if [ -f "$config_file" ]; then
            case "$config_file" in
                ".gitmodules")
                    echo "📦 Git submodules detected"
                    git submodule status
                    ;;
                "package.json")
                    if command -v jq &> /dev/null; then
                        deps=$(jq -r '.dependencies // {} | to_entries[] | select(.value | startswith("git+")) | .value' "$config_file" 2>/dev/null)
                        if [ -n "$deps" ]; then
                            echo "📦 Git dependencies in package.json:"
                            echo "$deps"
                        fi
                    fi
                    ;;
                *)
                    echo "ℹ️ Found $config_file (may contain repository references)"
                    ;;
            esac
        fi
    done
}

sync_repository_group() {
    echo ""
    echo "👥 Repository Group Synchronization"
    echo "================================="
    
    # Sync git submodules if present
    if [ -f ".gitmodules" ]; then
        echo "🔄 Syncing Git submodules..."
        git submodule update --init --recursive
        git submodule foreach git pull origin main
        echo "✅ Submodules synchronized"
    fi
    
    # TODO: Add support for custom repository groups
    echo "ℹ️ Multi-repository sync completed"
}

cross_repo_consistency_check() {
    echo ""
    echo "🔍 Cross-Repository Consistency Check"
    echo "====================================="
    
    # Check for version consistency across repositories
    if [ -f "package.json" ]; then
        echo "📦 Checking Node.js version consistency..."
        node_version=$(node --version 2>/dev/null || echo "not installed")
        echo "Node.js version: $node_version"
        
        if [ -f ".nvmrc" ]; then
            nvmrc_version=$(cat .nvmrc)
            echo ".nvmrc specifies: $nvmrc_version"
            
            if [[ "$node_version" != *"$nvmrc_version"* ]]; then
                echo "⚠️ Node.js version mismatch"
            fi
        fi
    fi
    
    echo "✅ Consistency check completed"
}

generate_multi_repo_report() {
    echo ""
    echo "📊 Multi-Repository Report"
    echo "========================="
    
    # Generate summary of all related repositories
    echo "Related repositories and their sync status:"
    
    if [ -f ".gitmodules" ]; then
        git submodule status | while read status path commit; do
            echo "  - $path: $status"
        done
    fi
    
    echo "✅ Multi-repository sync completed"
}
```

## Best Practices Summary

1. **Regular Synchronization**
   - Sync at least daily during active development
   - Use automated sync in CI/CD pipelines
   - Monitor sync health and performance

2. **Conflict Prevention**
   - Keep branches up to date with main
   - Use small, focused commits
   - Communicate changes with team

3. **Repository Health**
   - Regular maintenance and cleanup
   - Monitor repository size and performance
   - Keep dependencies updated

4. **Team Collaboration**
   - Consistent branching strategies
   - Clear communication channels
   - Shared sync and maintenance practices

## Workflow Summary

The sync workflow ensures:
- ✅ Comprehensive repository synchronization across all levels
- ✅ Automated conflict detection and resolution guidance
- ✅ Regular maintenance and optimization procedures
- ✅ Health monitoring and issue detection
- ✅ Security auditing and vulnerability checking
- ✅ Performance optimization and best practices

Remember: **Synchronization is not just about code - it's about keeping the entire development ecosystem healthy and productive!**