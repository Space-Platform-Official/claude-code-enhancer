---
description: User command interface for manual backup trigger control
---

# User-Initiated Backup Triggers

Interactive command interface that allows users to manually control backup state transitions with safety checks and confirmation prompts.

## User Command Interface

```bash
# Source the coordinator and shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/../coordinator.md"

# Main user command interface
backup_user_command() {
    local command=$1
    shift
    
    case "$command" in
        "list"|"ls")
            list_backups "$@"
            ;;
        "status"|"st")
            show_backup_status "$@"
            ;;
        "confirm"|"cf")
            confirm_backup "$@"
            ;;
        "cleanup"|"clean")
            cleanup_backup "$@"
            ;;
        "archive"|"arc")
            archive_backup "$@"
            ;;
        "delete"|"rm")
            delete_backup "$@"
            ;;
        "restore"|"rs")
            restore_backup "$@"
            ;;
        "force-cleanup"|"fclean")
            force_cleanup_backups "$@"
            ;;
        "emergency-cleanup"|"emergency")
            emergency_cleanup_interface "$@"
            ;;
        "monitor"|"mon")
            show_monitoring_dashboard
            ;;
        "config"|"cfg")
            configure_backup_system "$@"
            ;;
        "help"|"h")
            show_user_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_user_help
            return 1
            ;;
    esac
}

# List backups with filtering and sorting
list_backups() {
    local filter_state=${1:-"all"}
    local sort_by=${2:-"date"}
    local limit=${3:-20}
    
    echo "=== Backup Listing ==="
    echo "Filter: $filter_state | Sort: $sort_by | Limit: $limit"
    echo ""
    
    # Header
    printf "%-20s %-12s %-10s %-15s %-20s\n" "BACKUP ID" "STATE" "SIZE" "AGE" "LAST ACTIVITY"
    printf "%-20s %-12s %-10s %-15s %-20s\n" "────────────────────" "──────────" "────────" "─────────────" "──────────────────"
    
    # Find and display backups
    local backup_list=$(find_backups_for_listing "$filter_state" "$sort_by" "$limit")
    
    if [[ -z "$backup_list" ]]; then
        echo "No backups found matching filter: $filter_state"
        return 0
    fi
    
    echo "$backup_list" | while IFS='|' read -r backup_id state size age last_activity; do
        # Color coding for states
        local state_color=""
        case "$state" in
            "CREATED") state_color="\033[0;33m" ;;      # Yellow
            "PENDING") state_color="\033[0;34m" ;;      # Blue
            "CONFIRMED") state_color="\033[0;32m" ;;    # Green
            "CLEANABLE") state_color="\033[0;35m" ;;    # Magenta
            "ARCHIVED") state_color="\033[0;36m" ;;     # Cyan
            "DELETED") state_color="\033[0;31m" ;;      # Red
        esac
        
        printf "%-20s ${state_color}%-12s\033[0m %-10s %-15s %-20s\n" \
               "$backup_id" "$state" "$size" "$age" "$last_activity"
    done
    
    echo ""
    echo "Commands: status <id> | confirm <id> | cleanup <id> | delete <id>"
}

# Show detailed backup status
show_backup_status() {
    local backup_id=$1
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup status <backup_id>"
        return 1
    fi
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_id"
        return 1
    fi
    
    echo "=== Backup Status: $backup_id ==="
    echo ""
    
    # Basic information
    local state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
    local size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
    local created_at=$(get_backup_timestamp "$backup_id" "created")
    local age_days=$(get_backup_age_days "$backup_id")
    
    echo "State: $state"
    echo "Size: $size"
    echo "Created: $(date -d "@$created_at" 2>/dev/null || date -r "$created_at" 2>/dev/null)"
    echo "Age: $age_days days"
    echo ""
    
    # State-specific information
    show_state_specific_info "$backup_id" "$state"
    
    # Confidence scores
    echo "=== Confidence Scores ==="
    local cleanup_confidence=$(calculate_cleanup_confidence "$backup_id")
    echo "Cleanup Confidence: $cleanup_confidence"
    
    if [[ "$state" == "CONFIRMED" ]]; then
        local archive_confidence=$(calculate_archive_confidence "$backup_id")
        echo "Archive Confidence: $archive_confidence"
    fi
    
    if [[ "$state" =~ ^(CLEANABLE|ARCHIVED)$ ]]; then
        local delete_confidence=$(calculate_delete_confidence "$backup_id")
        echo "Delete Confidence: $delete_confidence"
    fi
    
    echo ""
    
    # Available actions
    show_available_actions "$backup_id" "$state"
}

# Show state-specific information
show_state_specific_info() {
    local backup_id=$1
    local state=$2
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    case "$state" in
        "CREATED")
            echo "=== Created State Info ==="
            if [[ -f "$backup_dir/.created_at" ]]; then
                echo "Created: $(date -d "@$(cat "$backup_dir/.created_at")" 2>/dev/null)"
            fi
            echo "Waiting for git commit to transition to PENDING"
            ;;
            
        "PENDING")
            echo "=== Pending State Info ==="
            if [[ -f "$backup_dir/.pending_since" ]]; then
                echo "Pending since: $(date -d "@$(cat "$backup_dir/.pending_since")" 2>/dev/null)"
            fi
            if [[ -f "$backup_dir/.commit_info" ]]; then
                echo "Associated commit: $(jq -r '.commit_hash' "$backup_dir/.commit_info" 2>/dev/null)"
                echo "Branch: $(jq -r '.branch' "$backup_dir/.commit_info" 2>/dev/null)"
            fi
            echo "Waiting for merge to transition to CONFIRMED"
            ;;
            
        "CONFIRMED")
            echo "=== Confirmed State Info ==="
            if [[ -f "$backup_dir/.confirmed_at" ]]; then
                echo "Confirmed: $(date -d "@$(cat "$backup_dir/.confirmed_at")" 2>/dev/null)"
            fi
            if [[ -f "$backup_dir/.merge_info" ]]; then
                echo "Merge commit: $(jq -r '.merge_commit' "$backup_dir/.merge_info" 2>/dev/null)"
                echo "Merge confidence: $(jq -r '.confidence' "$backup_dir/.merge_info" 2>/dev/null)"
            fi
            ;;
            
        "CLEANABLE")
            echo "=== Cleanable State Info ==="
            if [[ -f "$backup_dir/.cleanable_since" ]]; then
                echo "Cleanable since: $(date -d "@$(cat "$backup_dir/.cleanable_since")" 2>/dev/null)"
            fi
            if [[ -f "$backup_dir/.cleanup_confidence" ]]; then
                echo "Cleanup confidence: $(cat "$backup_dir/.cleanup_confidence")"
            fi
            ;;
            
        "ARCHIVED")
            echo "=== Archived State Info ==="
            local archive_file=$(find "$ARCHIVE_ROOT" -name "${backup_id}.tar.gz")
            if [[ -f "$archive_file" ]]; then
                echo "Archive location: $archive_file"
                echo "Archive size: $(du -sh "$archive_file" | cut -f1)"
                echo "Archived: $(date -d "@$(stat -c %Y "$archive_file")" 2>/dev/null)"
            fi
            ;;
    esac
    
    echo ""
}

# Show available actions for a backup
show_available_actions() {
    local backup_id=$1
    local state=$2
    
    echo "=== Available Actions ==="
    
    case "$state" in
        "CREATED")
            echo "- confirm: Manually transition to PENDING"
            echo "- delete: Remove backup (with confirmation)"
            ;;
        "PENDING")
            echo "- confirm: Manually transition to CONFIRMED"
            echo "- cleanup: Transition to CLEANABLE"
            echo "- delete: Remove backup (with confirmation)"
            ;;
        "CONFIRMED")
            echo "- cleanup: Transition to CLEANABLE"
            echo "- archive: Move to archive storage"
            echo "- delete: Remove backup (with confirmation)"
            ;;
        "CLEANABLE")
            echo "- archive: Move to archive storage"
            echo "- delete: Remove backup permanently"
            ;;
        "ARCHIVED")
            echo "- restore: Restore from archive"
            echo "- delete: Remove archive permanently"
            ;;
    esac
    
    echo ""
    echo "Commands:"
    echo "  backup confirm $backup_id"
    echo "  backup cleanup $backup_id"
    echo "  backup archive $backup_id"
    echo "  backup delete $backup_id"
}

# Confirm backup (manual state transition)
confirm_backup() {
    local backup_id=$1
    local force=${2:-false}
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup confirm <backup_id> [--force]"
        return 1
    fi
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_id"
        return 1
    fi
    
    local current_state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
    
    echo "=== Backup Confirmation ==="
    echo "Backup ID: $backup_id"
    echo "Current State: $current_state"
    echo ""
    
    local target_state=""
    case "$current_state" in
        "CREATED")
            target_state="PENDING"
            echo "This will transition the backup from CREATED to PENDING state."
            echo "Normally this happens automatically after a git commit."
            ;;
        "PENDING")
            target_state="CONFIRMED"
            echo "This will transition the backup from PENDING to CONFIRMED state."
            echo "Normally this happens automatically after a git merge."
            ;;
        *)
            log_error "Cannot confirm backup in $current_state state"
            return 1
            ;;
    esac
    
    echo ""
    
    if [[ "$force" != "true" ]]; then
        read -p "Proceed with confirmation? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Confirmation cancelled"
            return 0
        fi
    fi
    
    log_info "Confirming backup: $backup_id ($current_state → $target_state)"
    
    if coordinate_backup_transition "$backup_id" "$target_state" "USER" "manual confirmation"; then
        log_success "Backup $backup_id confirmed successfully"
        
        # Show updated status
        echo ""
        show_backup_status "$backup_id"
    else
        log_error "Failed to confirm backup: $backup_id"
        return 1
    fi
}

# Cleanup backup (transition to cleanable)
cleanup_backup() {
    local backup_id=$1
    local force=${2:-false}
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup cleanup <backup_id> [--force]"
        return 1
    fi
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_id"
        return 1
    fi
    
    local current_state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
    
    # Validate state transition
    if [[ ! "$current_state" =~ ^(PENDING|CONFIRMED)$ ]]; then
        log_error "Cannot cleanup backup in $current_state state"
        return 1
    fi
    
    echo "=== Backup Cleanup ==="
    echo "Backup ID: $backup_id"
    echo "Current State: $current_state"
    echo "Size: $(du -sh "$backup_dir" | cut -f1)"
    echo ""
    
    # Calculate and show confidence
    local cleanup_confidence=$(calculate_cleanup_confidence "$backup_id")
    echo "Cleanup Confidence: $cleanup_confidence"
    
    if (( $(echo "$cleanup_confidence < 0.7" | bc -l) )); then
        echo "⚠️  WARNING: Low cleanup confidence detected!"
        echo "This backup may still be valuable or in active use."
    fi
    
    echo ""
    echo "This will transition the backup to CLEANABLE state."
    echo "The backup will become eligible for automatic deletion based on policies."
    echo ""
    
    if [[ "$force" != "true" ]]; then
        read -p "Proceed with cleanup? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Cleanup cancelled"
            return 0
        fi
    fi
    
    log_info "Cleaning up backup: $backup_id"
    
    if coordinate_backup_transition "$backup_id" "CLEANABLE" "USER" "manual cleanup"; then
        log_success "Backup $backup_id transitioned to CLEANABLE"
        
        # Show updated status
        echo ""
        show_backup_status "$backup_id"
    else
        log_error "Failed to cleanup backup: $backup_id"
        return 1
    fi
}

# Archive backup
archive_backup() {
    local backup_id=$1
    local force=${2:-false}
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup archive <backup_id> [--force]"
        return 1
    fi
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup not found: $backup_id"
        return 1
    fi
    
    local current_state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
    
    # Validate state transition
    if [[ ! "$current_state" =~ ^(CONFIRMED|CLEANABLE)$ ]]; then
        log_error "Cannot archive backup in $current_state state"
        return 1
    fi
    
    echo "=== Backup Archive ==="
    echo "Backup ID: $backup_id"
    echo "Current State: $current_state"
    echo "Size: $(du -sh "$backup_dir" | cut -f1)"
    echo ""
    
    # Calculate archive confidence
    local archive_confidence=$(calculate_archive_confidence "$backup_id")
    echo "Archive Confidence: $archive_confidence"
    
    # Estimate compression
    local original_size_kb=$(du -sk "$backup_dir" | cut -f1)
    local estimated_compressed_kb=$((original_size_kb * 30 / 100))  # Estimate 30% compression
    
    echo "Estimated archive size: $((estimated_compressed_kb / 1024))MB (compressed)"
    echo "Archive location: $ARCHIVE_ROOT/$(date +%Y/%m)/${backup_id}.tar.gz"
    echo ""
    
    if [[ "$force" != "true" ]]; then
        read -p "Proceed with archiving? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Archiving cancelled"
            return 0
        fi
    fi
    
    log_info "Archiving backup: $backup_id"
    
    if coordinate_backup_transition "$backup_id" "ARCHIVED" "USER" "manual archive"; then
        log_success "Backup $backup_id archived successfully"
        
        # Show archive information
        local archive_file="$ARCHIVE_ROOT/$(date +%Y/%m)/${backup_id}.tar.gz"
        if [[ -f "$archive_file" ]]; then
            echo ""
            echo "Archive created: $archive_file"
            echo "Archive size: $(du -sh "$archive_file" | cut -f1)"
        fi
    else
        log_error "Failed to archive backup: $backup_id"
        return 1
    fi
}

# Delete backup with safety checks
delete_backup() {
    local backup_id=$1
    local force=${2:-false}
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup delete <backup_id> [--force]"
        return 1
    fi
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local archive_file="$ARCHIVE_ROOT"/*/"${backup_id}.tar.gz"
    
    # Check if backup exists in any form
    local backup_exists=false
    local is_archived=false
    
    if [[ -d "$backup_dir" ]]; then
        backup_exists=true
    elif [[ -f $archive_file ]]; then
        backup_exists=true
        is_archived=true
        backup_dir=$(dirname $archive_file)
    fi
    
    if [[ "$backup_exists" != "true" ]]; then
        log_error "Backup not found: $backup_id"
        return 1
    fi
    
    echo "=== Backup Deletion ==="
    echo "Backup ID: $backup_id"
    
    if [[ "$is_archived" == "true" ]]; then
        echo "Type: Archived backup"
        echo "Archive file: $archive_file"
        echo "Archive size: $(du -sh $archive_file | cut -f1)"
        local current_state="ARCHIVED"
    else
        local current_state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
        echo "Current State: $current_state"
        echo "Size: $(du -sh "$backup_dir" | cut -f1)"
    fi
    
    echo ""
    
    # Safety checks
    local delete_confidence
    if [[ "$is_archived" == "true" ]]; then
        delete_confidence=$(calculate_archived_delete_confidence "$backup_id" 0)
    else
        delete_confidence=$(calculate_delete_confidence "$backup_id")
    fi
    
    echo "Delete Confidence: $delete_confidence"
    
    # Warning for low confidence
    if (( $(echo "$delete_confidence < 0.8" | bc -l) )); then
        echo ""
        echo "⚠️  WARNING: Low delete confidence!"
        echo "This backup may still be valuable or recently accessed."
        
        if [[ "$current_state" =~ ^(CREATED|PENDING|CONFIRMED)$ ]]; then
            echo "Consider archiving instead of deleting."
        fi
    fi
    
    # Extra warning for non-cleanable states
    if [[ "$current_state" =~ ^(CREATED|PENDING|CONFIRMED)$ ]]; then
        echo ""
        echo "🚨 CAUTION: Deleting backup in $current_state state!"
        echo "This backup has not gone through normal cleanup evaluation."
    fi
    
    echo ""
    echo "⚠️  This action is PERMANENT and cannot be undone!"
    echo ""
    
    if [[ "$force" != "true" ]]; then
        read -p "Are you sure you want to delete this backup? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Deletion cancelled"
            return 0
        fi
        
        # Double confirmation for valuable backups
        if (( $(echo "$delete_confidence < 0.8" | bc -l) )); then
            echo ""
            echo "Double confirmation required for low confidence deletion."
            read -p "Type 'DELETE' to confirm: " confirm_text
            
            if [[ "$confirm_text" != "DELETE" ]]; then
                log_info "Deletion cancelled - confirmation text mismatch"
                return 0
            fi
        fi
    fi
    
    log_warning "Deleting backup: $backup_id"
    
    if [[ "$is_archived" == "true" ]]; then
        # Delete archived backup
        if delete_archived_backup "$backup_id" "$archive_file" "manual deletion"; then
            log_success "Archived backup $backup_id deleted successfully"
        else
            log_error "Failed to delete archived backup: $backup_id"
            return 1
        fi
    else
        # Delete regular backup
        if coordinate_backup_transition "$backup_id" "DELETED" "USER" "manual deletion" "true"; then
            log_success "Backup $backup_id deleted successfully"
        else
            log_error "Failed to delete backup: $backup_id"
            return 1
        fi
    fi
}

# Restore backup from archive
restore_backup() {
    local backup_id=$1
    local restore_path=${2:-"$BACKUP_ROOT/$backup_id"}
    
    if [[ -z "$backup_id" ]]; then
        log_error "Backup ID required"
        echo "Usage: backup restore <backup_id> [restore_path]"
        return 1
    fi
    
    # Find archive file
    local archive_file=$(find "$ARCHIVE_ROOT" -name "${backup_id}.tar.gz")
    
    if [[ ! -f "$archive_file" ]]; then
        log_error "Archive not found for backup: $backup_id"
        return 1
    fi
    
    echo "=== Backup Restoration ==="
    echo "Backup ID: $backup_id"
    echo "Archive file: $archive_file"
    echo "Archive size: $(du -sh "$archive_file" | cut -f1)"
    echo "Restore path: $restore_path"
    echo ""
    
    # Check if restore path already exists
    if [[ -e "$restore_path" ]]; then
        echo "⚠️  WARNING: Restore path already exists!"
        echo "Existing content will be overwritten."
        echo ""
        
        read -p "Proceed with restore? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Restoration cancelled"
            return 0
        fi
    fi
    
    log_info "Restoring backup: $backup_id"
    
    # Create restore directory
    mkdir -p "$(dirname "$restore_path")"
    
    # Extract archive
    if tar -xzf "$archive_file" -C "$(dirname "$restore_path")"; then
        # Update state to CONFIRMED (restored backups are considered confirmed)
        echo "CONFIRMED" > "$restore_path/.state"
        echo "$(date +%s)" > "$restore_path/.restored_at"
        echo "Restored from archive: $archive_file" > "$restore_path/.restore_info"
        
        log_success "Backup $backup_id restored successfully to: $restore_path"
        
        echo ""
        echo "Restore completed:"
        echo "  Size: $(du -sh "$restore_path" | cut -f1)"
        echo "  Files: $(find "$restore_path" -type f | wc -l)"
        echo "  State: CONFIRMED"
    else
        log_error "Failed to restore backup: $backup_id"
        return 1
    fi
}

# Force cleanup multiple backups
force_cleanup_backups() {
    local cleanup_level=${1:-"moderate"}
    local max_count=${2:-10}
    
    echo "=== Force Cleanup Interface ==="
    echo "Cleanup Level: $cleanup_level"
    echo "Maximum Count: $max_count"
    echo ""
    
    # Find candidates
    local candidates=$(find_cleanup_candidates "$cleanup_level" "$max_count")
    
    if [[ -z "$candidates" ]]; then
        log_info "No cleanup candidates found for level: $cleanup_level"
        return 0
    fi
    
    echo "Cleanup candidates:"
    echo ""
    printf "%-20s %-12s %-10s %-12s %-10s\n" "BACKUP ID" "STATE" "SIZE" "CONFIDENCE" "AGE"
    printf "%-20s %-12s %-10s %-12s %-10s\n" "────────────────────" "──────────" "────────" "──────────" "────────"
    
    local total_size=0
    
    for backup_id in $candidates; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        local state=$(cat "$backup_dir/.state" 2>/dev/null)
        local size_kb=$(du -sk "$backup_dir" 2>/dev/null | cut -f1)
        local size_mb=$((size_kb / 1024))
        local confidence=$(calculate_cleanup_confidence "$backup_id")
        local age_days=$(get_backup_age_days "$backup_id")
        
        printf "%-20s %-12s %-10s %-12s %-10s\n" \
               "$backup_id" "$state" "${size_mb}MB" "$confidence" "${age_days}d"
        
        total_size=$((total_size + size_mb))
    done
    
    echo ""
    echo "Total size to be freed: ${total_size}MB"
    echo ""
    echo "⚠️  WARNING: This will permanently delete the selected backups!"
    echo ""
    
    read -p "Proceed with force cleanup? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Force cleanup cancelled"
        return 0
    fi
    
    # Execute cleanup
    local cleaned_count=0
    local freed_size=0
    
    for backup_id in $candidates; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        local size_kb=$(du -sk "$backup_dir" 2>/dev/null | cut -f1)
        
        log_info "Force cleaning backup: $backup_id"
        
        if coordinate_backup_transition "$backup_id" "DELETED" "USER" "force cleanup: $cleanup_level" "true"; then
            ((cleaned_count++))
            freed_size=$((freed_size + size_kb / 1024))
            log_success "Backup $backup_id deleted"
        else
            log_error "Failed to delete backup: $backup_id"
        fi
    done
    
    echo ""
    log_success "Force cleanup completed: $cleaned_count backups deleted, ${freed_size}MB freed"
}

# Emergency cleanup interface
emergency_cleanup_interface() {
    echo "=== EMERGENCY CLEANUP INTERFACE ==="
    echo ""
    echo "🚨 This is an emergency cleanup tool for critical disk space situations."
    echo "Use with extreme caution as it may delete valuable backups!"
    echo ""
    
    # Show current disk usage
    local backup_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    local archive_usage=$(get_disk_usage_percentage "$ARCHIVE_ROOT")
    
    echo "Current disk usage:"
    echo "  Backup directory: ${backup_usage}%"
    echo "  Archive directory: ${archive_usage}%"
    echo ""
    
    if (( $(echo "$backup_usage < 85" | bc -l) )); then
        echo "ℹ️  Disk usage is not in emergency range (< 85%)."
        echo "Consider using regular cleanup commands instead."
        echo ""
        
        read -p "Continue with emergency cleanup anyway? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Emergency cleanup cancelled"
            return 0
        fi
    fi
    
    echo "Emergency cleanup options:"
    echo "  1. Conservative cleanup (high confidence only)"
    echo "  2. Aggressive cleanup (medium confidence and older)"
    echo "  3. Nuclear cleanup (all backups older than 1 hour)"
    echo "  4. Custom cleanup (specify criteria)"
    echo ""
    
    read -p "Select option (1-4): " -n 1 -r option
    echo
    
    case "$option" in
        1)
            emergency_cleanup_conservative
            ;;
        2)
            emergency_cleanup_aggressive
            ;;
        3)
            emergency_cleanup_nuclear
            ;;
        4)
            emergency_cleanup_custom
            ;;
        *)
            log_error "Invalid option selected"
            return 1
            ;;
    esac
}

# Emergency cleanup implementations
emergency_cleanup_conservative() {
    log_warning "Starting conservative emergency cleanup"
    
    local candidates=$(find_cleanup_candidates "gentle" 20)
    execute_emergency_cleanup_batch "$candidates" "emergency conservative cleanup"
}

emergency_cleanup_aggressive() {
    log_warning "Starting aggressive emergency cleanup"
    
    local candidates=$(find_cleanup_candidates "aggressive" 50)
    execute_emergency_cleanup_batch "$candidates" "emergency aggressive cleanup"
}

emergency_cleanup_nuclear() {
    echo ""
    echo "🚨 NUCLEAR CLEANUP WARNING 🚨"
    echo "This will delete ALL backups older than 1 hour!"
    echo "This action cannot be undone!"
    echo ""
    
    read -p "Type 'NUCLEAR' to confirm: " confirm_text
    
    if [[ "$confirm_text" != "NUCLEAR" ]]; then
        log_info "Nuclear cleanup cancelled"
        return 0
    fi
    
    log_error "Starting NUCLEAR emergency cleanup"
    
    local candidates=$(find_cleanup_candidates "nuclear" -1)
    execute_emergency_cleanup_batch "$candidates" "emergency nuclear cleanup"
}

emergency_cleanup_custom() {
    echo "Custom emergency cleanup configuration:"
    echo ""
    
    read -p "Minimum age in hours: " min_age_hours
    read -p "Maximum backups to clean: " max_backups
    read -p "Minimum confidence (0.0-1.0): " min_confidence
    
    echo ""
    echo "Custom cleanup criteria:"
    echo "  Minimum age: ${min_age_hours} hours"
    echo "  Maximum count: ${max_backups}"
    echo "  Minimum confidence: ${min_confidence}"
    echo ""
    
    read -p "Proceed with custom cleanup? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Custom cleanup cancelled"
        return 0
    fi
    
    # Find candidates based on custom criteria
    local candidates=$(find_custom_cleanup_candidates "$min_age_hours" "$max_backups" "$min_confidence")
    execute_emergency_cleanup_batch "$candidates" "emergency custom cleanup"
}

# Find backups for listing
find_backups_for_listing() {
    local filter_state=$1
    local sort_by=$2
    local limit=$3
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        
        local state=$(cat "$backup_dir/.state")
        
        # Apply state filter
        if [[ "$filter_state" != "all" ]] && [[ "$state" != "$filter_state" ]]; then
            continue
        fi
        
        # Get additional information
        local size=$(du -sh "$backup_dir" | cut -f1)
        local age_days=$(get_backup_age_days "$backup_id")
        local last_activity="N/A"
        
        # Get last activity timestamp
        if [[ -f "$backup_dir/.confirmed_at" ]]; then
            last_activity="$(date -d "@$(cat "$backup_dir/.confirmed_at")" +%m/%d 2>/dev/null)"
        elif [[ -f "$backup_dir/.pending_since" ]]; then
            last_activity="$(date -d "@$(cat "$backup_dir/.pending_since")" +%m/%d 2>/dev/null)"
        fi
        
        # Create sortable output
        local sort_key=""
        case "$sort_by" in
            "date")
                sort_key=$(stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir" 2>/dev/null)
                ;;
            "size")
                sort_key=$(du -sk "$backup_dir" | cut -f1)
                ;;
            "state")
                sort_key="$state"
                ;;
            "name")
                sort_key="$backup_id"
                ;;
        esac
        
        echo "${sort_key}|${backup_id}|${state}|${size}|${age_days}d|${last_activity}"
        
    done | sort -t'|' -k1,1nr | head -n "$limit" | cut -d'|' -f2-
}

# Show monitoring dashboard
show_monitoring_dashboard() {
    echo "=== Backup System Monitoring Dashboard ==="
    echo ""
    
    # System status
    echo "=== System Status ==="
    local backup_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    local archive_usage=$(get_disk_usage_percentage "$ARCHIVE_ROOT")
    
    echo "Backup Disk Usage: ${backup_usage}%"
    echo "Archive Disk Usage: ${archive_usage}%"
    
    # State counts
    echo ""
    echo "=== Backup State Distribution ==="
    for state in CREATED PENDING CONFIRMED CLEANABLE ARCHIVED; do
        local count=$(find "$BACKUP_ROOT" -name ".state" -exec grep -l "$state" {} \; 2>/dev/null | wc -l)
        printf "%-12s: %3d backups\n" "$state" "$count"
    done
    
    # Recent activity
    echo ""
    echo "=== Recent Activity ==="
    if [[ -f "$BACKUP_CONFIG_DIR/metrics/transitions.log" ]]; then
        echo "Last 5 transitions:"
        tail -5 "$BACKUP_CONFIG_DIR/metrics/transitions.log" | while IFS='|' read -r timestamp backup_id from_state to_state trigger_type result duration; do
            echo "  $(date -d "$timestamp" +%m/%d\ %H:%M 2>/dev/null): $backup_id ($from_state→$to_state) via $trigger_type"
        done
    else
        echo "No recent activity recorded"
    fi
    
    echo ""
    echo "=== Quick Actions ==="
    echo "  backup list                     - List all backups"
    echo "  backup cleanup                  - Interactive cleanup"
    echo "  backup force-cleanup moderate   - Force cleanup medium confidence"
    echo "  backup emergency               - Emergency cleanup interface"
}

# Configure backup system
configure_backup_system() {
    local setting=$1
    local value=$2
    
    echo "=== Backup System Configuration ==="
    
    if [[ -z "$setting" ]]; then
        # Show current configuration
        echo ""
        echo "Current configuration:"
        
        if [[ -f "$BACKUP_CONFIG_DIR/config.sh" ]]; then
            grep -E "^[A-Z_]+=.*" "$BACKUP_CONFIG_DIR/config.sh" | head -20
        else
            echo "No configuration file found"
        fi
        
        echo ""
        echo "Usage: backup config <setting> <value>"
        echo "Example: backup config DISK_WARNING_THRESHOLD 80"
        return 0
    fi
    
    if [[ -z "$value" ]]; then
        log_error "Value required for setting: $setting"
        return 1
    fi
    
    # Update configuration
    local config_file="$BACKUP_CONFIG_DIR/config.sh"
    mkdir -p "$(dirname "$config_file")"
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        echo "# Backup system configuration" > "$config_file"
    fi
    
    # Update or add setting
    if grep -q "^${setting}=" "$config_file"; then
        sed -i "s/^${setting}=.*/${setting}=${value}/" "$config_file"
        echo "Updated: $setting = $value"
    else
        echo "${setting}=${value}" >> "$config_file"
        echo "Added: $setting = $value"
    fi
    
    log_success "Configuration updated. Restart daemons for changes to take effect."
}

# Show user help
show_user_help() {
    cat << 'EOF'
=== Backup User Commands ===

Basic Commands:
  list [state] [sort] [limit]     - List backups (default: all, date, 20)
  status <id>                     - Show detailed backup status
  confirm <id>                    - Manually confirm backup state transition
  cleanup <id>                    - Transition backup to cleanable state
  archive <id>                    - Archive backup to compressed storage
  delete <id>                     - Delete backup permanently
  restore <id> [path]             - Restore backup from archive

Batch Operations:
  force-cleanup [level] [count]   - Force cleanup multiple backups
  emergency                       - Emergency cleanup interface

Monitoring:
  monitor                         - Show monitoring dashboard
  config [setting] [value]        - View/update configuration

State Filters (for list command):
  all, created, pending, confirmed, cleanable, archived

Sort Options (for list command):
  date, size, state, name

Cleanup Levels:
  gentle, moderate, aggressive, nuclear

Examples:
  backup list cleanable size 10   - List 10 largest cleanable backups
  backup status backup_20241201    - Show detailed status
  backup cleanup backup_20241201   - Mark backup for cleanup
  backup force-cleanup moderate 5  - Force cleanup 5 moderate confidence backups

Safety Features:
- Confidence scoring prevents accidental deletion
- Interactive confirmations for destructive operations
- State validation ensures proper transitions
- Emergency cleanup with multiple safety levels

EOF
}

# Main function for direct execution
main() {
    local command=${1:-"help"}
    shift
    
    backup_user_command "$command" "$@"
}

# Export functions for external usage
export -f backup_user_command
export -f list_backups
export -f show_backup_status
export -f confirm_backup
export -f cleanup_backup
export -f delete_backup

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi