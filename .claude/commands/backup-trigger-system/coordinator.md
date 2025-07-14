---
description: Central coordination system for backup state transitions with atomic operations
---

# Backup State Transition Coordinator

The central coordination system that manages all backup state transitions with atomic operations, conflict resolution, and rollback capabilities.

## Core State Machine

```bash
# Backup state definitions
declare -A BACKUP_STATES=(
    ["CREATED"]="Initial backup created, awaiting git activity"
    ["PENDING"]="Backup confirmed by commit, awaiting merge/integration"
    ["CONFIRMED"]="Backup validated by successful merge"
    ["CLEANABLE"]="Backup eligible for cleanup based on policies"
    ["ARCHIVED"]="Backup moved to long-term storage"
    ["DELETED"]="Backup permanently removed"
)

# Valid state transitions
declare -A VALID_TRANSITIONS=(
    ["CREATED"]="PENDING CLEANABLE DELETED"
    ["PENDING"]="CONFIRMED CLEANABLE DELETED"
    ["CONFIRMED"]="CLEANABLE ARCHIVED DELETED"
    ["CLEANABLE"]="ARCHIVED DELETED"
    ["ARCHIVED"]="DELETED"
    ["DELETED"]=""
)

# State transition coordinator
coordinate_backup_transition() {
    local backup_id=$1
    local target_state=$2
    local trigger_type=$3
    local reason=$4
    local force=${5:-false}
    
    local lock_file="/tmp/backup_transition_${backup_id}.lock"
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local state_file="$backup_dir/.state"
    
    # Acquire exclusive lock
    exec 200>"$lock_file"
    if ! flock -n 200; then
        log_error "Another transition is in progress for backup: $backup_id"
        return 1
    fi
    
    # Load current state
    local current_state="UNKNOWN"
    if [[ -f "$state_file" ]]; then
        current_state=$(cat "$state_file")
    fi
    
    log_info "Coordinating transition: $backup_id ($current_state → $target_state) via $trigger_type"
    
    # Validate transition
    if ! validate_state_transition "$current_state" "$target_state" "$force"; then
        log_error "Invalid state transition: $current_state → $target_state"
        return 1
    fi
    
    # Check for conflicts with other triggers
    if ! check_transition_conflicts "$backup_id" "$target_state" "$trigger_type"; then
        log_warning "Transition conflict detected, deferring to higher priority trigger"
        return 2
    fi
    
    # Create transition checkpoint
    local checkpoint_id=$(create_transition_checkpoint "$backup_id" "$current_state")
    
    # Execute atomic transition
    if execute_atomic_transition "$backup_id" "$current_state" "$target_state" "$trigger_type" "$reason"; then
        log_success "Backup $backup_id transitioned to $target_state"
        cleanup_transition_checkpoint "$checkpoint_id"
        record_transition_metrics "$backup_id" "$current_state" "$target_state" "$trigger_type" "success"
        return 0
    else
        log_error "Transition failed, rolling back..."
        rollback_from_checkpoint "$checkpoint_id"
        record_transition_metrics "$backup_id" "$current_state" "$target_state" "$trigger_type" "failure"
        return 1
    fi
}

# Validate state transition rules
validate_state_transition() {
    local current_state=$1
    local target_state=$2
    local force=$3
    
    # Check if states exist
    if [[ -z "${BACKUP_STATES[$current_state]:-}" ]]; then
        log_error "Unknown current state: $current_state"
        return 1
    fi
    
    if [[ -z "${BACKUP_STATES[$target_state]:-}" ]]; then
        log_error "Unknown target state: $target_state"
        return 1
    fi
    
    # Allow force transitions for emergency situations
    if [[ "$force" == "true" ]]; then
        log_warning "Force transition enabled, bypassing validation"
        return 0
    fi
    
    # Check if transition is valid
    local valid_targets="${VALID_TRANSITIONS[$current_state]:-}"
    if [[ " $valid_targets " =~ " $target_state " ]]; then
        return 0
    else
        log_error "Invalid transition: $current_state → $target_state"
        log_info "Valid transitions from $current_state: $valid_targets"
        return 1
    fi
}

# Check for conflicts between different trigger types
check_transition_conflicts() {
    local backup_id=$1
    local target_state=$2
    local trigger_type=$3
    
    local conflicts_file="/tmp/backup_conflicts_${backup_id}"
    
    # Define trigger priorities (higher number = higher priority)
    declare -A TRIGGER_PRIORITIES=(
        ["USER"]="100"
        ["DISK_SPACE"]="90"
        ["GIT_HOOK"]="80"
        ["TIME_BASED"]="70"
    )
    
    local current_priority=${TRIGGER_PRIORITIES[$trigger_type]:-0}
    
    # Check for active conflicts
    if [[ -f "$conflicts_file" ]]; then
        while IFS='|' read -r existing_trigger existing_state existing_priority timestamp; do
            # Check if conflict is still active (within 5 minutes)
            local current_time=$(date +%s)
            if (( current_time - timestamp < 300 )); then
                if (( existing_priority > current_priority )); then
                    log_warning "Higher priority trigger ($existing_trigger) is active"
                    return 1
                fi
            fi
        done < "$conflicts_file"
    fi
    
    # Register this trigger attempt
    echo "${trigger_type}|${target_state}|${current_priority}|$(date +%s)" >> "$conflicts_file"
    
    # Clean up old conflict records
    local temp_file=$(mktemp)
    local cutoff_time=$(($(date +%s) - 300))
    while IFS='|' read -r trigger state priority timestamp; do
        if (( timestamp >= cutoff_time )); then
            echo "${trigger}|${state}|${priority}|${timestamp}" >> "$temp_file"
        fi
    done < "$conflicts_file" 2>/dev/null || true
    mv "$temp_file" "$conflicts_file"
    
    return 0
}

# Create checkpoint for atomic rollback
create_transition_checkpoint() {
    local backup_id=$1
    local current_state=$2
    
    local checkpoint_id="checkpoint_${backup_id}_$(date +%s%N)"
    local checkpoint_dir="/tmp/backup_checkpoints/$checkpoint_id"
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    mkdir -p "$checkpoint_dir"
    
    # Save current state and metadata
    echo "$current_state" > "$checkpoint_dir/state"
    echo "$backup_id" > "$checkpoint_dir/backup_id"
    echo "$(date +%s)" > "$checkpoint_dir/timestamp"
    
    # Copy critical backup metadata
    if [[ -d "$backup_dir" ]]; then
        cp -r "$backup_dir/.metadata" "$checkpoint_dir/" 2>/dev/null || true
        cp "$backup_dir/.state" "$checkpoint_dir/state_file" 2>/dev/null || true
    fi
    
    echo "$checkpoint_id"
}

# Execute atomic state transition
execute_atomic_transition() {
    local backup_id=$1
    local current_state=$2
    local target_state=$3
    local trigger_type=$4
    local reason=$5
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local state_file="$backup_dir/.state"
    local metadata_file="$backup_dir/.metadata"
    
    # Ensure backup directory exists
    if [[ ! -d "$backup_dir" ]]; then
        log_error "Backup directory not found: $backup_dir"
        return 1
    fi
    
    # Execute state-specific transition logic
    case "$target_state" in
        "PENDING")
            execute_pending_transition "$backup_id" "$trigger_type" "$reason"
            ;;
        "CONFIRMED")
            execute_confirmed_transition "$backup_id" "$trigger_type" "$reason"
            ;;
        "CLEANABLE")
            execute_cleanable_transition "$backup_id" "$trigger_type" "$reason"
            ;;
        "ARCHIVED")
            execute_archived_transition "$backup_id" "$trigger_type" "$reason"
            ;;
        "DELETED")
            execute_deleted_transition "$backup_id" "$trigger_type" "$reason"
            ;;
        *)
            log_error "Unknown target state: $target_state"
            return 1
            ;;
    esac
    
    local transition_result=$?
    
    if [[ $transition_result -eq 0 ]]; then
        # Update state file atomically
        echo "$target_state" > "${state_file}.tmp"
        mv "${state_file}.tmp" "$state_file"
        
        # Update metadata
        update_backup_metadata "$backup_id" "$target_state" "$trigger_type" "$reason"
        
        # Trigger state-specific hooks
        execute_state_hooks "$backup_id" "$target_state" "$trigger_type"
        
        return 0
    else
        log_error "State transition logic failed for $target_state"
        return 1
    fi
}

# State-specific transition implementations
execute_pending_transition() {
    local backup_id=$1
    local trigger_type=$2
    local reason=$3
    
    log_info "Transitioning $backup_id to PENDING state"
    
    # Mark backup as pending git integration
    local backup_dir="$BACKUP_ROOT/$backup_id"
    echo "$(date +%s)" > "$backup_dir/.pending_since"
    echo "$reason" > "$backup_dir/.pending_reason"
    
    # Schedule automatic cleanup if not confirmed within policy time
    schedule_automatic_cleanup "$backup_id" "$PENDING_TIMEOUT"
    
    return 0
}

execute_confirmed_transition() {
    local backup_id=$1
    local trigger_type=$2
    local reason=$3
    
    log_info "Transitioning $backup_id to CONFIRMED state"
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    echo "$(date +%s)" > "$backup_dir/.confirmed_at"
    echo "$reason" > "$backup_dir/.confirmation_reason"
    
    # Remove pending cleanup schedules
    cancel_automatic_cleanup "$backup_id"
    
    # Update backup confidence score
    update_backup_confidence "$backup_id" "merge_confirmed"
    
    return 0
}

execute_cleanable_transition() {
    local backup_id=$1
    local trigger_type=$2
    local reason=$3
    
    log_info "Transitioning $backup_id to CLEANABLE state"
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    # Calculate cleanup confidence score
    local confidence_score=$(calculate_cleanup_confidence "$backup_id")
    echo "$confidence_score" > "$backup_dir/.cleanup_confidence"
    
    # Set cleanup eligibility timestamp
    echo "$(date +%s)" > "$backup_dir/.cleanable_since"
    echo "$reason" > "$backup_dir/.cleanable_reason"
    
    # Schedule cleanup based on confidence and policies
    if (( $(echo "$confidence_score >= 0.85" | bc -l) )); then
        schedule_automatic_cleanup "$backup_id" "$HIGH_CONFIDENCE_CLEANUP_DELAY"
    else
        log_info "Backup $backup_id marked cleanable but requires manual confirmation (confidence: $confidence_score)"
    fi
    
    return 0
}

execute_archived_transition() {
    local backup_id=$1
    local trigger_type=$2
    local reason=$3
    
    log_info "Transitioning $backup_id to ARCHIVED state"
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local archive_dir="$ARCHIVE_ROOT/$(date +%Y/%m)"
    
    # Create archive directory
    mkdir -p "$archive_dir"
    
    # Move backup to archive with compression
    if tar -czf "$archive_dir/${backup_id}.tar.gz" -C "$BACKUP_ROOT" "$backup_id"; then
        # Verify archive integrity
        if tar -tzf "$archive_dir/${backup_id}.tar.gz" >/dev/null 2>&1; then
            # Remove original backup
            rm -rf "$backup_dir"
            
            # Create archive metadata
            create_archive_metadata "$backup_id" "$archive_dir" "$reason"
            
            log_success "Backup $backup_id archived successfully"
            return 0
        else
            log_error "Archive verification failed for $backup_id"
            rm -f "$archive_dir/${backup_id}.tar.gz"
            return 1
        fi
    else
        log_error "Failed to create archive for $backup_id"
        return 1
    fi
}

execute_deleted_transition() {
    local backup_id=$1
    local trigger_type=$2
    local reason=$3
    
    log_info "Transitioning $backup_id to DELETED state"
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    # Verify backup is in cleanable state or force deletion is authorized
    if [[ "$trigger_type" != "USER" ]] && [[ ! -f "$backup_dir/.cleanable_since" ]]; then
        log_error "Cannot delete backup not in CLEANABLE state without user authorization"
        return 1
    fi
    
    # Create deletion record before removing
    create_deletion_record "$backup_id" "$reason" "$trigger_type"
    
    # Secure deletion
    if [[ -d "$backup_dir" ]]; then
        # Overwrite sensitive files before deletion
        find "$backup_dir" -type f -name "*.key" -o -name "*.secret" -o -name "*.token" | while read -r file; do
            shred -vfz -n 3 "$file" 2>/dev/null || rm -f "$file"
        done
        
        # Remove backup directory
        rm -rf "$backup_dir"
        
        log_success "Backup $backup_id deleted successfully"
        return 0
    else
        log_warning "Backup directory already removed: $backup_dir"
        return 0
    fi
}

# Rollback from checkpoint
rollback_from_checkpoint() {
    local checkpoint_id=$1
    local checkpoint_dir="/tmp/backup_checkpoints/$checkpoint_id"
    
    if [[ ! -d "$checkpoint_dir" ]]; then
        log_error "Checkpoint not found: $checkpoint_id"
        return 1
    fi
    
    local backup_id=$(cat "$checkpoint_dir/backup_id")
    local original_state=$(cat "$checkpoint_dir/state")
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    log_info "Rolling back backup $backup_id to state: $original_state"
    
    # Restore original state
    echo "$original_state" > "$backup_dir/.state"
    
    # Restore metadata if available
    if [[ -d "$checkpoint_dir/.metadata" ]]; then
        cp -r "$checkpoint_dir/.metadata" "$backup_dir/"
    fi
    
    if [[ -f "$checkpoint_dir/state_file" ]]; then
        cp "$checkpoint_dir/state_file" "$backup_dir/.state"
    fi
    
    log_success "Rollback completed for backup: $backup_id"
    
    # Cleanup checkpoint
    rm -rf "$checkpoint_dir"
}

# Cleanup checkpoint after successful transition
cleanup_transition_checkpoint() {
    local checkpoint_id=$1
    local checkpoint_dir="/tmp/backup_checkpoints/$checkpoint_id"
    
    if [[ -d "$checkpoint_dir" ]]; then
        rm -rf "$checkpoint_dir"
    fi
}

# Update backup metadata
update_backup_metadata() {
    local backup_id=$1
    local new_state=$2
    local trigger_type=$3
    local reason=$4
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    local metadata_file="$backup_dir/.metadata"
    
    # Create metadata if it doesn't exist
    if [[ ! -f "$metadata_file" ]]; then
        cat > "$metadata_file" << EOF
{
    "backup_id": "$backup_id",
    "created_at": "$(date -Iseconds)",
    "transitions": []
}
EOF
    fi
    
    # Add transition record
    local transition_record="{
        \"timestamp\": \"$(date -Iseconds)\",
        \"from_state\": \"$(get_previous_state "$backup_id")\",
        \"to_state\": \"$new_state\",
        \"trigger_type\": \"$trigger_type\",
        \"reason\": \"$reason\",
        \"coordinator_version\": \"1.0\"
    }"
    
    # Update metadata using jq if available, otherwise append
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        jq --argjson transition "$transition_record" '.transitions += [$transition]' "$metadata_file" > "$temp_file"
        mv "$temp_file" "$metadata_file"
    else
        # Fallback: append to simple log format
        echo "$(date -Iseconds)|$new_state|$trigger_type|$reason" >> "$backup_dir/.transition_log"
    fi
}

# Execute state-specific hooks
execute_state_hooks() {
    local backup_id=$1
    local new_state=$2
    local trigger_type=$3
    
    local hooks_dir="$BACKUP_CONFIG_DIR/hooks"
    
    # Execute global state hooks
    if [[ -f "$hooks_dir/on_${new_state,,}.sh" ]]; then
        log_info "Executing state hook: on_${new_state,,}.sh"
        bash "$hooks_dir/on_${new_state,,}.sh" "$backup_id" "$trigger_type" || true
    fi
    
    # Execute trigger-specific hooks
    local trigger_hook="$hooks_dir/on_${trigger_type,,}_trigger.sh"
    if [[ -f "$trigger_hook" ]]; then
        log_info "Executing trigger hook: on_${trigger_type,,}_trigger.sh"
        bash "$trigger_hook" "$backup_id" "$new_state" || true
    fi
}

# Calculate cleanup confidence based on multiple factors
calculate_cleanup_confidence() {
    local backup_id=$1
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    local confidence=0.5  # Base confidence
    
    # Age factor (older = higher confidence)
    local age_days=$(get_backup_age_days "$backup_id")
    local age_factor=$(echo "scale=2; $age_days / 30.0" | bc -l)
    if (( $(echo "$age_factor > 1.0" | bc -l) )); then
        age_factor=1.0
    fi
    confidence=$(echo "scale=2; $confidence + ($age_factor * 0.3)" | bc -l)
    
    # Git integration factor
    if [[ -f "$backup_dir/.confirmed_at" ]]; then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Size factor (larger = lower confidence for safety)
    local size_mb=$(du -sm "$backup_dir" 2>/dev/null | cut -f1)
    if (( size_mb > 100 )); then
        confidence=$(echo "scale=2; $confidence - 0.1" | bc -l)
    fi
    
    # Usage factor (check for recent access)
    local last_access=$(find "$backup_dir" -type f -atime -7 | wc -l)
    if (( last_access > 0 )); then
        confidence=$(echo "scale=2; $confidence - 0.2" | bc -l)
    fi
    
    # Ensure confidence stays within bounds
    if (( $(echo "$confidence > 1.0" | bc -l) )); then
        confidence=1.0
    elif (( $(echo "$confidence < 0.0" | bc -l) )); then
        confidence=0.0
    fi
    
    echo "$confidence"
}

# Record transition metrics for monitoring
record_transition_metrics() {
    local backup_id=$1
    local from_state=$2
    local to_state=$3
    local trigger_type=$4
    local result=$5
    
    local metrics_file="$BACKUP_CONFIG_DIR/metrics/transitions.log"
    mkdir -p "$(dirname "$metrics_file")"
    
    local timestamp=$(date -Iseconds)
    local duration=${TRANSITION_START_TIME:+$(($(date +%s) - TRANSITION_START_TIME))}
    
    echo "${timestamp}|${backup_id}|${from_state}|${to_state}|${trigger_type}|${result}|${duration:-0}" >> "$metrics_file"
}

# Get backup age in days
get_backup_age_days() {
    local backup_id=$1
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    if [[ -f "$backup_dir/.created_at" ]]; then
        local created_timestamp=$(cat "$backup_dir/.created_at")
        local current_timestamp=$(date +%s)
        local age_seconds=$((current_timestamp - created_timestamp))
        echo $((age_seconds / 86400))
    else
        # Fallback to directory modification time
        local mtime=$(stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir" 2>/dev/null)
        local current_timestamp=$(date +%s)
        local age_seconds=$((current_timestamp - mtime))
        echo $((age_seconds / 86400))
    fi
}

# Coordination system status and monitoring
get_coordinator_status() {
    echo "=== Backup State Transition Coordinator Status ==="
    echo "Coordinator Version: 1.0"
    echo "Active Transitions: $(find /tmp -name "backup_transition_*.lock" 2>/dev/null | wc -l)"
    echo "Active Conflicts: $(find /tmp -name "backup_conflicts_*" 2>/dev/null | wc -l)"
    echo "Pending Checkpoints: $(find /tmp/backup_checkpoints -type d 2>/dev/null | wc -l)"
    echo ""
    
    echo "=== Recent Transition Metrics ==="
    if [[ -f "$BACKUP_CONFIG_DIR/metrics/transitions.log" ]]; then
        tail -10 "$BACKUP_CONFIG_DIR/metrics/transitions.log" | while IFS='|' read -r timestamp backup_id from_state to_state trigger_type result duration; do
            echo "$timestamp: $backup_id ($from_state→$to_state) via $trigger_type - $result (${duration}s)"
        done
    else
        echo "No metrics available"
    fi
}

# Initialize coordinator system
init_coordinator() {
    log_info "Initializing Backup State Transition Coordinator"
    
    # Create required directories
    mkdir -p "$BACKUP_ROOT"
    mkdir -p "$ARCHIVE_ROOT"
    mkdir -p "$BACKUP_CONFIG_DIR/hooks"
    mkdir -p "$BACKUP_CONFIG_DIR/metrics"
    mkdir -p "/tmp/backup_checkpoints"
    
    # Set permissions
    chmod 755 "$BACKUP_ROOT" "$ARCHIVE_ROOT"
    chmod 700 "/tmp/backup_checkpoints"
    
    # Clean up stale locks and conflicts
    find /tmp -name "backup_transition_*.lock" -mtime +1 -delete 2>/dev/null || true
    find /tmp -name "backup_conflicts_*" -mtime +1 -delete 2>/dev/null || true
    
    log_success "Coordinator initialization complete"
}

# Main coordinator entry point
main() {
    local action=${1:-"status"}
    
    case "$action" in
        "transition")
            coordinate_backup_transition "$2" "$3" "$4" "$5" "$6"
            ;;
        "status")
            get_coordinator_status
            ;;
        "init")
            init_coordinator
            ;;
        *)
            echo "Usage: $0 {transition|status|init}"
            echo "  transition <backup_id> <target_state> <trigger_type> <reason> [force]"
            echo "  status"
            echo "  init"
            exit 1
            ;;
    esac
}

# Source shared utilities
if [[ -f "$BACKUP_CONFIG_DIR/shared/utils.sh" ]]; then
    source "$BACKUP_CONFIG_DIR/shared/utils.sh"
fi

# Load configuration
if [[ -f "$BACKUP_CONFIG_DIR/config.sh" ]]; then
    source "$BACKUP_CONFIG_DIR/config.sh"
fi

# Export functions for use by other trigger components
export -f coordinate_backup_transition
export -f validate_state_transition
export -f calculate_cleanup_confidence
export -f record_transition_metrics

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi