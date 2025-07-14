---
description: Git hook integration for automatic backup state transitions
---

# Git Hook Backup Triggers

Integration system that connects git hook events to backup state transitions using the existing git hook infrastructure.

## Git Hook Integration Scripts

```bash
# Source the coordinator and shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/../coordinator.md"
source "$HOME/.claude/commands/git/_shared/utils.md"

# Post-commit hook trigger
trigger_post_commit_backup_transition() {
    local commit_hash=$(git rev-parse HEAD)
    local commit_message=$(git log -1 --pretty=%B)
    local branch=$(git branch --show-current)
    
    log_info "Git post-commit trigger activated"
    log_info "Commit: $commit_hash on branch: $branch"
    
    # Find backups created around this commit time
    local commit_timestamp=$(git log -1 --format=%ct)
    local backup_candidates=$(find_recent_backups "$commit_timestamp" 300) # 5 minutes window
    
    for backup_id in $backup_candidates; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        
        # Check if backup is in CREATED state
        if [[ -f "$backup_dir/.state" ]] && [[ "$(cat "$backup_dir/.state")" == "CREATED" ]]; then
            log_info "Transitioning backup $backup_id from CREATED to PENDING"
            
            # Coordinate transition through central system
            if coordinate_backup_transition "$backup_id" "PENDING" "GIT_HOOK" "post-commit: $commit_hash"; then
                # Update backup with commit information
                update_backup_commit_info "$backup_id" "$commit_hash" "$commit_message" "$branch"
                
                # Set up merge tracking
                setup_merge_tracking "$backup_id" "$commit_hash"
                
                log_success "Backup $backup_id transitioned to PENDING state"
            else
                log_error "Failed to transition backup $backup_id to PENDING state"
            fi
        fi
    done
    
    # Cleanup orphaned backups (created but no associated commit)
    cleanup_orphaned_backups "$commit_timestamp"
}

# Post-merge hook trigger
trigger_post_merge_backup_transition() {
    local merge_commit=$(git rev-parse HEAD)
    local merged_branch=${1:-"unknown"}
    
    log_info "Git post-merge trigger activated"
    log_info "Merge commit: $merge_commit, merged branch: $merged_branch"
    
    # Find backups in PENDING state that might be related to this merge
    local pending_backups=$(find_pending_backups_for_merge "$merge_commit")
    
    for backup_id in $pending_backups; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        
        # Verify backup is actually related to merged changes
        if verify_backup_merge_relationship "$backup_id" "$merge_commit"; then
            log_info "Transitioning backup $backup_id from PENDING to CONFIRMED"
            
            # Calculate merge confidence score
            local merge_confidence=$(calculate_merge_confidence "$backup_id" "$merge_commit")
            
            if coordinate_backup_transition "$backup_id" "CONFIRMED" "GIT_HOOK" "post-merge: $merge_commit"; then
                # Update backup with merge information
                update_backup_merge_info "$backup_id" "$merge_commit" "$merged_branch" "$merge_confidence"
                
                # Schedule future cleanup evaluation
                schedule_cleanup_evaluation "$backup_id" "$MERGE_CONFIRMED_CLEANUP_DELAY"
                
                log_success "Backup $backup_id confirmed via merge (confidence: $merge_confidence)"
            else
                log_error "Failed to confirm backup $backup_id after merge"
            fi
        else
            log_warning "Backup $backup_id not related to current merge, keeping in PENDING state"
        fi
    done
}

# Pre-push hook trigger
trigger_pre_push_backup_evaluation() {
    local remote_name=$1
    local remote_url=$2
    
    log_info "Git pre-push trigger activated"
    log_info "Pushing to remote: $remote_name ($remote_url)"
    
    # Evaluate confirmed backups for cleanup eligibility
    while read -r local_ref local_sha remote_ref remote_sha; do
        local branch=$(echo "$remote_ref" | sed 's/refs\/heads\///')
        
        log_info "Evaluating backups for branch: $branch"
        
        # Find confirmed backups related to commits being pushed
        local confirmed_backups=$(find_confirmed_backups_for_push "$local_sha" "$remote_sha" "$branch")
        
        for backup_id in $confirmed_backups; do
            # Check if backup meets cleanup criteria
            local cleanup_confidence=$(calculate_cleanup_confidence "$backup_id")
            local push_confidence=$(calculate_push_confidence "$backup_id" "$branch" "$remote_name")
            
            # Combine confidences for final cleanup decision
            local combined_confidence=$(echo "scale=2; ($cleanup_confidence + $push_confidence) / 2" | bc -l)
            
            log_info "Backup $backup_id cleanup confidence: $combined_confidence"
            
            # Transition to CLEANABLE if confidence is high enough
            if (( $(echo "$combined_confidence >= $PUSH_CLEANUP_THRESHOLD" | bc -l) )); then
                log_info "Transitioning backup $backup_id to CLEANABLE state"
                
                if coordinate_backup_transition "$backup_id" "CLEANABLE" "GIT_HOOK" "pre-push: successful push to $remote_name"; then
                    update_backup_push_info "$backup_id" "$branch" "$remote_name" "$combined_confidence"
                    log_success "Backup $backup_id marked as cleanable (confidence: $combined_confidence)"
                else
                    log_error "Failed to mark backup $backup_id as cleanable"
                fi
            else
                log_info "Backup $backup_id not eligible for cleanup yet (confidence: $combined_confidence < $PUSH_CLEANUP_THRESHOLD)"
            fi
        done
    done
}

# Helper functions for git hook integration

# Find backups created around a specific timestamp
find_recent_backups() {
    local target_timestamp=$1
    local window_seconds=$2
    
    local start_time=$((target_timestamp - window_seconds))
    local end_time=$((target_timestamp + window_seconds))
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.created_at" ]] && continue
        
        local created_timestamp=$(cat "$backup_dir/.created_at")
        
        if (( created_timestamp >= start_time && created_timestamp <= end_time )); then
            echo "$backup_id"
        fi
    done
}

# Update backup with commit information
update_backup_commit_info() {
    local backup_id=$1
    local commit_hash=$2
    local commit_message=$3
    local branch=$4
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local commit_info_file="$backup_dir/.commit_info"
    
    cat > "$commit_info_file" << EOF
{
    "commit_hash": "$commit_hash",
    "commit_message": $(echo "$commit_message" | jq -R .),
    "branch": "$branch",
    "committed_at": "$(date -Iseconds)",
    "author": "$(git log -1 --format=%an)",
    "email": "$(git log -1 --format=%ae)"
}
EOF
}

# Setup merge tracking for a backup
setup_merge_tracking() {
    local backup_id=$1
    local commit_hash=$2
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local tracking_file="$backup_dir/.merge_tracking"
    
    echo "$commit_hash" > "$tracking_file"
    echo "$(date +%s)" >> "$tracking_file"
    
    # Set up automatic timeout for merge tracking
    echo "$backup_id" >> "/tmp/pending_merges_$(date +%Y%m%d)"
}

# Find pending backups for a merge
find_pending_backups_for_merge() {
    local merge_commit=$1
    
    # Get the commits involved in this merge
    local merged_commits=$(git log --oneline --merges -1 --pretty=format:"%P" "$merge_commit" | tr ' ' '\n')
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "PENDING" ]] && continue
        
        # Check if backup has commit tracking
        if [[ -f "$backup_dir/.commit_info" ]]; then
            local backup_commit=$(jq -r '.commit_hash' "$backup_dir/.commit_info" 2>/dev/null)
            
            # Check if backup commit is part of the merge
            echo "$merged_commits" | while read -r commit; do
                if [[ "$backup_commit" == "$commit" ]] || git merge-base --is-ancestor "$backup_commit" "$commit" 2>/dev/null; then
                    echo "$backup_id"
                    break
                fi
            done
        fi
    done | sort -u
}

# Verify backup-merge relationship
verify_backup_merge_relationship() {
    local backup_id=$1
    local merge_commit=$2
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    # Check if backup has commit information
    if [[ ! -f "$backup_dir/.commit_info" ]]; then
        return 1
    fi
    
    local backup_commit=$(jq -r '.commit_hash' "$backup_dir/.commit_info" 2>/dev/null)
    
    # Verify the backup commit is an ancestor of the merge commit
    if git merge-base --is-ancestor "$backup_commit" "$merge_commit" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Calculate merge confidence
calculate_merge_confidence() {
    local backup_id=$1
    local merge_commit=$2
    
    local confidence=0.5  # Base confidence
    
    # Check if merge was clean (no conflicts)
    if ! git log -1 --format=%B "$merge_commit" | grep -i "conflict\|resolve" >/dev/null; then
        confidence=$(echo "scale=2; $confidence + 0.3" | bc -l)
    fi
    
    # Check if tests pass after merge
    if check_post_merge_tests "$merge_commit"; then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Check backup age (newer = higher confidence)
    local backup_age=$(get_backup_age_days "$backup_id")
    if (( backup_age <= 7 )); then
        confidence=$(echo "scale=2; $confidence + 0.1" | bc -l)
    fi
    
    # Ensure confidence stays within bounds
    if (( $(echo "$confidence > 1.0" | bc -l) )); then
        confidence=1.0
    elif (( $(echo "$confidence < 0.0" | bc -l) )); then
        confidence=0.0
    fi
    
    echo "$confidence"
}

# Update backup with merge information
update_backup_merge_info() {
    local backup_id=$1
    local merge_commit=$2
    local merged_branch=$3
    local confidence=$4
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local merge_info_file="$backup_dir/.merge_info"
    
    cat > "$merge_info_file" << EOF
{
    "merge_commit": "$merge_commit",
    "merged_branch": "$merged_branch",
    "merged_at": "$(date -Iseconds)",
    "confidence": $confidence,
    "merge_author": "$(git log -1 --format=%an "$merge_commit")",
    "merge_message": $(git log -1 --format=%B "$merge_commit" | jq -R .)
}
EOF
}

# Find confirmed backups for a push
find_confirmed_backups_for_push() {
    local local_sha=$1
    local remote_sha=$2
    local branch=$3
    
    # Get commits being pushed
    local pushed_commits
    if [[ "$remote_sha" == "0000000000000000000000000000000000000000" ]]; then
        # New branch
        pushed_commits=$(git rev-list "$local_sha" --max-count=100)
    else
        # Existing branch
        pushed_commits=$(git rev-list "$remote_sha..$local_sha")
    fi
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CONFIRMED" ]] && continue
        
        # Check if backup is related to pushed commits
        if [[ -f "$backup_dir/.commit_info" ]]; then
            local backup_commit=$(jq -r '.commit_hash' "$backup_dir/.commit_info" 2>/dev/null)
            
            echo "$pushed_commits" | while read -r commit; do
                if [[ "$backup_commit" == "$commit" ]]; then
                    echo "$backup_id"
                    break
                fi
            done
        fi
    done | sort -u
}

# Calculate push confidence
calculate_push_confidence() {
    local backup_id=$1
    local branch=$2
    local remote_name=$3
    
    local confidence=0.5  # Base confidence
    
    # Higher confidence for main/master branches
    if [[ "$branch" =~ ^(main|master|production)$ ]]; then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Higher confidence for origin remote
    if [[ "$remote_name" == "origin" ]]; then
        confidence=$(echo "scale=2; $confidence + 0.1" | bc -l)
    fi
    
    # Check if backup has been confirmed for a while
    local backup_dir="$BACKUP_ROOT/$backup_id"
    if [[ -f "$backup_dir/.confirmed_at" ]]; then
        local confirmed_timestamp=$(cat "$backup_dir/.confirmed_at")
        local age_hours=$(( ($(date +%s) - confirmed_timestamp) / 3600 ))
        
        if (( age_hours >= 24 )); then
            confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
        elif (( age_hours >= 6 )); then
            confidence=$(echo "scale=2; $confidence + 0.1" | bc -l)
        fi
    fi
    
    # Ensure confidence stays within bounds
    if (( $(echo "$confidence > 1.0" | bc -l) )); then
        confidence=1.0
    elif (( $(echo "$confidence < 0.0" | bc -l) )); then
        confidence=0.0
    fi
    
    echo "$confidence"
}

# Update backup with push information
update_backup_push_info() {
    local backup_id=$1
    local branch=$2
    local remote_name=$3
    local confidence=$4
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local push_info_file="$backup_dir/.push_info"
    
    cat > "$push_info_file" << EOF
{
    "branch": "$branch",
    "remote_name": "$remote_name",
    "pushed_at": "$(date -Iseconds)",
    "push_confidence": $confidence,
    "push_author": "$(git config user.name)",
    "push_email": "$(git config user.email)"
}
EOF
}

# Check if tests pass after merge
check_post_merge_tests() {
    local merge_commit=$1
    
    # Checkout the merge commit temporarily
    local original_head=$(git rev-parse HEAD)
    
    if git checkout "$merge_commit" --quiet 2>/dev/null; then
        local test_result=1
        
        # Run quick tests if available
        if [[ -f "Makefile" ]] && grep -q "test-quick:" Makefile; then
            make test-quick >/dev/null 2>&1 && test_result=0
        elif [[ -f "package.json" ]] && grep -q '"test:quick"' package.json; then
            npm run test:quick >/dev/null 2>&1 && test_result=0
        fi
        
        # Return to original head
        git checkout "$original_head" --quiet 2>/dev/null
        
        return $test_result
    else
        return 1
    fi
}

# Cleanup orphaned backups
cleanup_orphaned_backups() {
    local commit_timestamp=$1
    local cutoff_time=$((commit_timestamp - 3600))  # 1 hour before commit
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CREATED" ]] && continue
        
        # Check if backup is old enough and has no commit association
        if [[ -f "$backup_dir/.created_at" ]]; then
            local created_timestamp=$(cat "$backup_dir/.created_at")
            
            if (( created_timestamp < cutoff_time )) && [[ ! -f "$backup_dir/.commit_info" ]]; then
                log_warning "Cleaning up orphaned backup: $backup_id"
                
                # Transition to deleted state
                coordinate_backup_transition "$backup_id" "DELETED" "GIT_HOOK" "orphaned backup cleanup"
            fi
        fi
    done
}

# Install git hooks for backup triggers
install_backup_git_hooks() {
    local hooks_dir=".git/hooks"
    
    if [[ ! -d "$hooks_dir" ]]; then
        log_error "Not in a git repository or hooks directory not found"
        return 1
    fi
    
    log_info "Installing backup trigger git hooks"
    
    # Install post-commit hook
    cat >> "$hooks_dir/post-commit" << 'EOF'

# Backup trigger integration
if [[ -f "$HOME/.claude/commands/backup-trigger-system/git-hooks.md" ]]; then
    source "$HOME/.claude/commands/backup-trigger-system/git-hooks.md"
    trigger_post_commit_backup_transition
fi
EOF
    
    # Install post-merge hook
    cat >> "$hooks_dir/post-merge" << 'EOF'

# Backup trigger integration
if [[ -f "$HOME/.claude/commands/backup-trigger-system/git-hooks.md" ]]; then
    source "$HOME/.claude/commands/backup-trigger-system/git-hooks.md"
    trigger_post_merge_backup_transition
fi
EOF
    
    # Install pre-push hook
    cat >> "$hooks_dir/pre-push" << 'EOF'

# Backup trigger integration
if [[ -f "$HOME/.claude/commands/backup-trigger-system/git-hooks.md" ]]; then
    source "$HOME/.claude/commands/backup-trigger-system/git-hooks.md"
    
    # Read push information and trigger evaluation
    while read local_ref local_sha remote_ref remote_sha; do
        trigger_pre_push_backup_evaluation "$1" "$2" <<< "$local_ref $local_sha $remote_ref $remote_sha"
    done
fi
EOF
    
    # Make hooks executable
    chmod +x "$hooks_dir/post-commit" "$hooks_dir/post-merge" "$hooks_dir/pre-push"
    
    log_success "Backup trigger git hooks installed successfully"
}

# Test git hook integration
test_git_hook_integration() {
    log_info "Testing git hook backup trigger integration"
    
    # Test hook installation
    if [[ ! -f ".git/hooks/post-commit" ]] || ! grep -q "backup trigger" ".git/hooks/post-commit"; then
        log_error "Post-commit hook not properly installed"
        return 1
    fi
    
    # Test configuration
    if [[ -z "$BACKUP_ROOT" ]] || [[ ! -d "$BACKUP_ROOT" ]]; then
        log_error "Backup root directory not configured or missing"
        return 1
    fi
    
    # Test coordinator availability
    if ! command -v coordinate_backup_transition >/dev/null 2>&1; then
        log_error "Backup coordinator functions not available"
        return 1
    fi
    
    log_success "Git hook integration test passed"
    return 0
}

# Main function for direct execution
main() {
    local action=${1:-"install"}
    
    case "$action" in
        "install")
            install_backup_git_hooks
            ;;
        "test")
            test_git_hook_integration
            ;;
        "post-commit")
            trigger_post_commit_backup_transition
            ;;
        "post-merge")
            trigger_post_merge_backup_transition "$2"
            ;;
        "pre-push")
            trigger_pre_push_backup_evaluation "$2" "$3"
            ;;
        *)
            echo "Usage: $0 {install|test|post-commit|post-merge|pre-push}"
            exit 1
            ;;
    esac
}

# Export functions for hook usage
export -f trigger_post_commit_backup_transition
export -f trigger_post_merge_backup_transition
export -f trigger_pre_push_backup_evaluation

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi