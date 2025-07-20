---
description: Git integration utilities for milestone execution and progress tracking
---

# Milestone Git Integration

Comprehensive Git integration for milestone execution with branch management, commit tracking, and repository state validation.

## Branch Management for Milestones

```bash
# Create milestone branch
create_milestone_branch() {
    local milestone_id=$1
    local base_branch=${2:-"main"}
    local branch_name="milestone/$milestone_id"
    
    echo "Creating milestone branch: $branch_name"
    
    # Ensure we're on the base branch and up to date
    git checkout "$base_branch"
    git pull origin "$base_branch"
    
    # Create and switch to milestone branch
    git checkout -b "$branch_name"
    git push --set-upstream origin "$branch_name"
    
    # Log the branch creation
    log_milestone_event "$milestone_id" "branch_created" "{\"branch\": \"$branch_name\", \"base\": \"$base_branch\"}"
    
    echo "Milestone branch created and pushed: $branch_name"
}

# Switch to milestone branch
switch_to_milestone_branch() {
    local milestone_id=$1
    local branch_name="milestone/$milestone_id"
    
    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        git checkout "$branch_name"
    # Check if branch exists remotely
    elif git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        git checkout -b "$branch_name" "origin/$branch_name"
    else
        echo "ERROR: Milestone branch not found: $branch_name"
        echo "Create it first with: create_milestone_branch $milestone_id"
        return 1
    fi
    
    echo "Switched to milestone branch: $branch_name"
}

# Validate milestone branch state
validate_milestone_branch() {
    local milestone_id=$1
    local expected_branch="milestone/$milestone_id"
    local current_branch=$(git branch --show-current)
    local errors=0
    
    echo "=== Milestone Branch Validation ==="
    
    # Check if on correct branch
    if [ "$current_branch" != "$expected_branch" ]; then
        echo "WARNING: Not on milestone branch"
        echo "  Expected: $expected_branch"
        echo "  Current:  $current_branch"
        ((errors++))
    fi
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "WARNING: Uncommitted changes detected"
        git status --short
    fi
    
    # Check if branch is up to date with remote
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse "origin/$expected_branch" 2>/dev/null)
    
    if [ -n "$remote_commit" ] && [ "$local_commit" != "$remote_commit" ]; then
        echo "WARNING: Branch is not synchronized with remote"
        local ahead=$(git rev-list --count "origin/$expected_branch..HEAD" 2>/dev/null || echo "0")
        local behind=$(git rev-list --count "HEAD..origin/$expected_branch" 2>/dev/null || echo "0")
        echo "  Ahead: $ahead commits, Behind: $behind commits"
    fi
    
    if [ $errors -eq 0 ]; then
        echo "✅ Milestone branch state is valid"
    else
        echo "⚠️  Found $errors branch validation warnings"
    fi
    
    return $errors
}
```

## Commit Tracking and Progress

```bash
# Create milestone commit
create_milestone_commit() {
    local milestone_id=$1
    local task_id=$2
    local commit_message=$3
    local commit_type=${4:-"feat"}
    
    # Validate we're on the right branch
    validate_milestone_branch "$milestone_id"
    
    # Stage changes
    git add .
    
    # Check for changes
    if [ -z "$(git diff --cached)" ]; then
        echo "No changes to commit"
        return 0
    fi
    
    # Create conventional commit message
    local full_message="$commit_type(milestone-$milestone_id): $commit_message

Task: $task_id
Milestone: $milestone_id

Generated with Claude Code milestone execution"
    
    # Commit with message
    git commit -m "$full_message"
    
    # Log the commit
    local commit_hash=$(git rev-parse HEAD)
    log_milestone_event "$milestone_id" "task_committed" "{\"task\": \"$task_id\", \"commit\": \"$commit_hash\", \"type\": \"$commit_type\"}"
    
    echo "Milestone commit created: $commit_hash"
}

# Track milestone progress through commits
track_milestone_commits() {
    local milestone_id=$1
    local branch_name="milestone/$milestone_id"
    
    echo "=== Milestone Commit History ==="
    
    # Get commits for this milestone
    git log --oneline --grep="milestone-$milestone_id" --grep="Milestone: $milestone_id" --all
    
    # Count progress
    local total_commits=$(git log --oneline --grep="milestone-$milestone_id" --all | wc -l)
    local today_commits=$(git log --oneline --since="today" --grep="milestone-$milestone_id" --all | wc -l)
    
    echo ""
    echo "Total commits: $total_commits"
    echo "Today's commits: $today_commits"
    
    # Update progress in milestone file
    if [ -f ".milestones/active/$milestone_id.yaml" ]; then
        yq e ".progress.commits_count = $total_commits" -i ".milestones/active/$milestone_id.yaml"
        yq e ".progress.last_commit_date = \"$(date -u +%Y-%m-%d)\"" -i ".milestones/active/$milestone_id.yaml"
    fi
}

# Generate milestone diff summary
generate_milestone_diff() {
    local milestone_id=$1
    local base_branch=${2:-"main"}
    local branch_name="milestone/$milestone_id"
    
    echo "=== Milestone Changes Summary ==="
    
    # Switch to milestone branch
    git checkout "$branch_name" 2>/dev/null
    
    # Generate diff stats
    echo "Files changed:"
    git diff --name-status "$base_branch"
    
    echo ""
    echo "Code statistics:"
    git diff --stat "$base_branch"
    
    echo ""
    echo "Line changes by type:"
    git diff --numstat "$base_branch" | awk '{add+=$1; del+=$2} END {printf "Added: %d lines\nDeleted: %d lines\nNet: %+d lines\n", add, del, add-del}'
}
```

## Repository State Management

```bash
# Save repository state
save_repository_state() {
    local milestone_id=$1
    local state_file=".milestones/logs/repo-state-$(date +%Y%m%d-%H%M%S).json"
    
    mkdir -p ".milestones/logs"
    
    cat > "$state_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "milestone_id": "$milestone_id",
  "repository": {
    "working_directory": "$(pwd)",
    "git_root": "$(git rev-parse --show-toplevel)",
    "current_branch": "$(git branch --show-current)",
    "head_commit": "$(git rev-parse HEAD)",
    "remote_url": "$(git remote get-url origin 2>/dev/null || echo 'none')"
  },
  "status": {
    "clean": $([ -z "$(git status --porcelain)" ] && echo "true" || echo "false"),
    "ahead": $(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0"),
    "behind": $(git rev-list --count "HEAD..@{u}" 2>/dev/null || echo "0"),
    "staged_files": $(git diff --cached --name-only | wc -l),
    "modified_files": $(git diff --name-only | wc -l),
    "untracked_files": $(git ls-files --others --exclude-standard | wc -l)
  },
  "stash": {
    "count": $(git stash list | wc -l),
    "latest": "$(git stash list -1 --pretty=format:'%gd: %s' 2>/dev/null || echo 'none')"
  }
}
EOF
    
    echo "Repository state saved: $state_file"
}

# Restore repository state
restore_repository_state() {
    local state_file=$1
    
    if [ ! -f "$state_file" ]; then
        echo "ERROR: State file not found: $state_file"
        return 1
    fi
    
    local working_dir=$(jq -r '.repository.working_directory' "$state_file")
    local branch=$(jq -r '.repository.current_branch' "$state_file")
    local commit=$(jq -r '.repository.head_commit' "$state_file")
    
    echo "Restoring repository state from: $state_file"
    
    # Change directory
    if [ "$working_dir" != "$(pwd)" ]; then
        echo "Changing to working directory: $working_dir"
        cd "$working_dir"
    fi
    
    # Switch branch
    if [ "$(git branch --show-current)" != "$branch" ]; then
        echo "Switching to branch: $branch"
        git checkout "$branch"
    fi
    
    # Check if we're at the right commit
    if [ "$(git rev-parse HEAD)" != "$commit" ]; then
        echo "WARNING: Head commit differs from saved state"
        echo "  Saved: $commit"
        echo "  Current: $(git rev-parse HEAD)"
    fi
    
    echo "Repository state restored"
}

# Sync milestone with remote
sync_milestone_branch() {
    local milestone_id=$1
    local branch_name="milestone/$milestone_id"
    
    echo "Syncing milestone branch with remote..."
    
    # Fetch latest changes
    git fetch origin
    
    # Check if remote branch exists
    if git show-ref --verify --quiet "refs/remotes/origin/$branch_name"; then
        # Pull changes from remote
        git pull origin "$branch_name"
        echo "Pulled latest changes from remote"
    else
        # Push branch to remote
        git push --set-upstream origin "$branch_name"
        echo "Pushed milestone branch to remote"
    fi
    
    # Log sync event
    log_milestone_event "$milestone_id" "branch_synced" "{\"branch\": \"$branch_name\", \"remote\": \"origin\"}"
}
```

## Conflict Resolution

```bash
# Handle merge conflicts during milestone execution
handle_milestone_conflicts() {
    local milestone_id=$1
    local base_branch=${2:-"main"}
    
    echo "=== Handling Milestone Merge Conflicts ==="
    
    # Check for conflicts
    if [ -n "$(git status --porcelain | grep '^UU\|^AA\|^DD')" ]; then
        echo "Merge conflicts detected:"
        git status --short | grep '^UU\|^AA\|^DD'
        
        echo ""
        echo "Conflict resolution options:"
        echo "1. Resolve manually and continue"
        echo "2. Abort merge and retry"
        echo "3. Accept incoming changes"
        echo "4. Accept current changes"
        
        read -p "Choose option [1-4]: " choice
        
        case "$choice" in
            1)
                echo "Open your editor to resolve conflicts manually"
                echo "After resolving, run: git add . && git commit"
                ;;
            2)
                git merge --abort
                echo "Merge aborted. Try again after reviewing changes."
                ;;
            3)
                git checkout --theirs .
                git add .
                echo "Accepted incoming changes"
                ;;
            4)
                git checkout --ours .
                git add .
                echo "Accepted current changes"
                ;;
            *)
                echo "Invalid option. Please resolve conflicts manually."
                ;;
        esac
        
        # Log conflict event
        log_milestone_event "$milestone_id" "conflict_detected" "{\"base_branch\": \"$base_branch\", \"resolution_method\": \"$choice\"}"
    else
        echo "No merge conflicts detected"
    fi
}

# Create milestone pull request
create_milestone_pr() {
    local milestone_id=$1
    local base_branch=${2:-"main"}
    local branch_name="milestone/$milestone_id"
    
    # Ensure branch is up to date
    sync_milestone_branch "$milestone_id"
    
    # Get milestone details
    local milestone_title=$(yq e '.title' ".milestones/active/$milestone_id.yaml" 2>/dev/null || echo "Milestone $milestone_id")
    local milestone_description=$(yq e '.description' ".milestones/active/$milestone_id.yaml" 2>/dev/null || echo "")
    
    # Generate PR description
    local pr_body="## Milestone: $milestone_title

$milestone_description

### Changes Summary
$(generate_milestone_diff "$milestone_id" "$base_branch")

### Completed Tasks
$(yq e '.tasks[] | select(.status == "completed") | "- " + .title' ".milestones/active/$milestone_id.yaml" 2>/dev/null)

### Test Results
- [ ] All tests pass
- [ ] Code review completed
- [ ] Documentation updated

Generated with Claude Code milestone execution"
    
    # Create PR using gh CLI
    if command -v gh &> /dev/null; then
        gh pr create \
            --title "Milestone: $milestone_title" \
            --body "$pr_body" \
            --base "$base_branch" \
            --head "$branch_name"
        
        echo "Pull request created for milestone: $milestone_id"
        
        # Log PR creation
        log_milestone_event "$milestone_id" "pr_created" "{\"base_branch\": \"$base_branch\", \"pr_branch\": \"$branch_name\"}"
    else
        echo "GitHub CLI (gh) not available. Create PR manually:"
        echo "  Base: $base_branch"
        echo "  Head: $branch_name"
        echo "  Title: Milestone: $milestone_title"
    fi
}
```

This Git integration system provides comprehensive repository management for milestone execution with proper branch handling, commit tracking, and conflict resolution.