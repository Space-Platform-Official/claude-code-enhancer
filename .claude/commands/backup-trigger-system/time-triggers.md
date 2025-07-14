---
description: Time-based trigger daemon with configurable retention policies
---

# Time-Based Backup Triggers

Daemon system that monitors backup ages and automatically triggers state transitions based on configurable time-based retention policies.

## Time Trigger Daemon

```bash
# Source the coordinator and shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/../coordinator.md"

# Time-based trigger daemon
start_time_trigger_daemon() {
    local daemon_name="backup-time-trigger"
    local pid_file="/var/run/${daemon_name}.pid"
    local log_file="/var/log/${daemon_name}.log"
    local config_file="$BACKUP_CONFIG_DIR/time-policies.conf"
    
    # Check if daemon is already running
    if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        log_error "Time trigger daemon is already running (PID: $(cat "$pid_file"))"
        return 1
    fi
    
    log_info "Starting time-based backup trigger daemon"
    
    # Daemonize the process
    {
        # Main daemon loop
        while true; do
            # Load current configuration
            load_time_policies "$config_file"
            
            # Process each time-based policy
            process_time_policies
            
            # Sleep based on check interval
            sleep "${TIME_CHECK_INTERVAL:-300}"  # Default 5 minutes
            
        done
    } &
    
    local daemon_pid=$!
    echo "$daemon_pid" > "$pid_file"
    
    log_success "Time trigger daemon started (PID: $daemon_pid)"
    
    # Setup signal handlers for graceful shutdown
    trap "stop_time_trigger_daemon" TERM INT
    
    # Wait for daemon process if running in foreground
    if [[ "${1:-}" == "--foreground" ]]; then
        wait "$daemon_pid"
    fi
}

# Stop time trigger daemon
stop_time_trigger_daemon() {
    local daemon_name="backup-time-trigger"
    local pid_file="/var/run/${daemon_name}.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping time trigger daemon (PID: $pid)"
            kill -TERM "$pid"
            
            # Wait for graceful shutdown
            local timeout=30
            while kill -0 "$pid" 2>/dev/null && (( timeout > 0 )); do
                sleep 1
                ((timeout--))
            done
            
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                log_warning "Force killing daemon (PID: $pid)"
                kill -KILL "$pid"
            fi
            
            rm -f "$pid_file"
            log_success "Time trigger daemon stopped"
        else
            log_warning "Daemon PID file exists but process not running"
            rm -f "$pid_file"
        fi
    else
        log_info "Time trigger daemon is not running"
    fi
}

# Load time-based policies
load_time_policies() {
    local config_file=$1
    
    # Default policies if config file doesn't exist
    if [[ ! -f "$config_file" ]]; then
        create_default_time_policies "$config_file"
    fi
    
    # Source the configuration
    source "$config_file"
    
    log_debug "Loaded time policies from: $config_file"
}

# Create default time policies
create_default_time_policies() {
    local config_file=$1
    
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << 'EOF'
# Time-based backup retention policies
# Format: POLICY_NAME_TIMEOUT=seconds

# Backup state transition timeouts
CREATED_TO_PENDING_TIMEOUT=1800        # 30 minutes
PENDING_TO_CLEANUP_TIMEOUT=259200      # 3 days
CONFIRMED_TO_CLEANUP_TIMEOUT=604800    # 7 days
CLEANABLE_TO_ARCHIVED_TIMEOUT=86400    # 1 day
ARCHIVED_TO_DELETED_TIMEOUT=2592000    # 30 days

# Emergency cleanup timeouts (disk space pressure)
EMERGENCY_CREATED_TIMEOUT=600          # 10 minutes
EMERGENCY_PENDING_TIMEOUT=3600         # 1 hour
EMERGENCY_CONFIRMED_TIMEOUT=86400      # 1 day

# Policy-specific configurations
POLICY_IMMEDIATE_CLEANUP=true
POLICY_CONSERVATIVE_CLEANUP=false
POLICY_ARCHIVE_ENABLED=true
POLICY_EMERGENCY_CLEANUP_THRESHOLD=0.9  # 90% disk usage

# Check intervals
TIME_CHECK_INTERVAL=300                # 5 minutes
POLICY_EVALUATION_INTERVAL=900         # 15 minutes
DISK_CHECK_INTERVAL=60                 # 1 minute

# Confidence thresholds for automatic actions
AUTO_CLEANUP_CONFIDENCE=0.8
AUTO_ARCHIVE_CONFIDENCE=0.9
AUTO_DELETE_CONFIDENCE=0.95
EOF
    
    log_info "Created default time policies: $config_file"
}

# Process all time-based policies
process_time_policies() {
    local current_time=$(date +%s)
    
    log_debug "Processing time-based policies at $(date)"
    
    # Process each backup state
    process_created_timeouts "$current_time"
    process_pending_timeouts "$current_time"
    process_confirmed_timeouts "$current_time"
    process_cleanable_timeouts "$current_time"
    process_archived_timeouts "$current_time"
    
    # Update policy metrics
    update_time_policy_metrics "$current_time"
}

# Process CREATED state timeouts
process_created_timeouts() {
    local current_time=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CREATED" ]] && continue
        
        local created_at=$(get_backup_timestamp "$backup_id" "created")
        local age_seconds=$((current_time - created_at))
        
        # Check for normal timeout
        if (( age_seconds >= CREATED_TO_PENDING_TIMEOUT )); then
            log_info "Backup $backup_id has been in CREATED state for ${age_seconds}s (timeout: ${CREATED_TO_PENDING_TIMEOUT}s)"
            
            # Check if this is an orphaned backup
            if ! has_git_activity_since "$backup_id" "$created_at"; then
                log_warning "No git activity for backup $backup_id, marking for cleanup"
                
                # Calculate confidence for cleanup
                local cleanup_confidence=$(calculate_created_cleanup_confidence "$backup_id" "$age_seconds")
                
                if (( $(echo "$cleanup_confidence >= $AUTO_CLEANUP_CONFIDENCE" | bc -l) )); then
                    coordinate_backup_transition "$backup_id" "CLEANABLE" "TIME_BASED" "created timeout: ${age_seconds}s, no git activity"
                else
                    log_info "Backup $backup_id requires manual review (confidence: $cleanup_confidence)"
                    flag_for_manual_review "$backup_id" "created_timeout" "$cleanup_confidence"
                fi
            fi
        fi
        
        # Check for emergency timeout
        if [[ "$POLICY_EMERGENCY_CLEANUP" == "true" ]] && (( age_seconds >= EMERGENCY_CREATED_TIMEOUT )); then
            local disk_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            
            if (( $(echo "$disk_usage >= $POLICY_EMERGENCY_CLEANUP_THRESHOLD" | bc -l) )); then
                log_warning "Emergency cleanup for backup $backup_id (disk usage: ${disk_usage}%)"
                coordinate_backup_transition "$backup_id" "DELETED" "TIME_BASED" "emergency created timeout: disk space pressure"
            fi
        fi
    done
}

# Process PENDING state timeouts
process_pending_timeouts() {
    local current_time=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "PENDING" ]] && continue
        
        local pending_since=$(get_backup_timestamp "$backup_id" "pending")
        local age_seconds=$((current_time - pending_since))
        
        # Check for normal timeout
        if (( age_seconds >= PENDING_TO_CLEANUP_TIMEOUT )); then
            log_info "Backup $backup_id has been in PENDING state for ${age_seconds}s"
            
            # Check if merge is still possible/expected
            if ! is_merge_still_expected "$backup_id"; then
                log_info "No merge expected for backup $backup_id, evaluating for cleanup"
                
                local cleanup_confidence=$(calculate_pending_cleanup_confidence "$backup_id" "$age_seconds")
                
                if (( $(echo "$cleanup_confidence >= $AUTO_CLEANUP_CONFIDENCE" | bc -l) )); then
                    coordinate_backup_transition "$backup_id" "CLEANABLE" "TIME_BASED" "pending timeout: ${age_seconds}s, no merge expected"
                else
                    flag_for_manual_review "$backup_id" "pending_timeout" "$cleanup_confidence"
                fi
            else
                log_info "Merge still expected for backup $backup_id, extending timeout"
                extend_pending_timeout "$backup_id" "$current_time"
            fi
        fi
        
        # Check for emergency timeout
        if [[ "$POLICY_EMERGENCY_CLEANUP" == "true" ]] && (( age_seconds >= EMERGENCY_PENDING_TIMEOUT )); then
            local disk_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            
            if (( $(echo "$disk_usage >= $POLICY_EMERGENCY_CLEANUP_THRESHOLD" | bc -l) )); then
                log_warning "Emergency cleanup for backup $backup_id (disk usage: ${disk_usage}%)"
                coordinate_backup_transition "$backup_id" "CLEANABLE" "TIME_BASED" "emergency pending timeout: disk space pressure"
            fi
        fi
    done
}

# Process CONFIRMED state timeouts
process_confirmed_timeouts() {
    local current_time=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CONFIRMED" ]] && continue
        
        local confirmed_at=$(get_backup_timestamp "$backup_id" "confirmed")
        local age_seconds=$((current_time - confirmed_at))
        
        # Check for normal timeout
        if (( age_seconds >= CONFIRMED_TO_CLEANUP_TIMEOUT )); then
            log_info "Backup $backup_id has been CONFIRMED for ${age_seconds}s"
            
            # Check if backup is still valuable
            local value_score=$(calculate_backup_value_score "$backup_id")
            local cleanup_confidence=$(calculate_confirmed_cleanup_confidence "$backup_id" "$age_seconds" "$value_score")
            
            if (( $(echo "$cleanup_confidence >= $AUTO_CLEANUP_CONFIDENCE" | bc -l) )); then
                coordinate_backup_transition "$backup_id" "CLEANABLE" "TIME_BASED" "confirmed timeout: ${age_seconds}s, value score: $value_score"
            else
                flag_for_manual_review "$backup_id" "confirmed_timeout" "$cleanup_confidence"
            fi
        fi
        
        # Check for emergency timeout
        if [[ "$POLICY_EMERGENCY_CLEANUP" == "true" ]] && (( age_seconds >= EMERGENCY_CONFIRMED_TIMEOUT )); then
            local disk_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            
            if (( $(echo "$disk_usage >= $POLICY_EMERGENCY_CLEANUP_THRESHOLD" | bc -l) )); then
                log_warning "Emergency cleanup for backup $backup_id (disk usage: ${disk_usage}%)"
                coordinate_backup_transition "$backup_id" "CLEANABLE" "TIME_BASED" "emergency confirmed timeout: disk space pressure"
            fi
        fi
    done
}

# Process CLEANABLE state timeouts
process_cleanable_timeouts() {
    local current_time=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CLEANABLE" ]] && continue
        
        local cleanable_since=$(get_backup_timestamp "$backup_id" "cleanable")
        local age_seconds=$((current_time - cleanable_since))
        
        # Check for archive timeout
        if [[ "$POLICY_ARCHIVE_ENABLED" == "true" ]] && (( age_seconds >= CLEANABLE_TO_ARCHIVED_TIMEOUT )); then
            log_info "Backup $backup_id eligible for archiving after ${age_seconds}s"
            
            local archive_confidence=$(calculate_archive_confidence "$backup_id")
            
            if (( $(echo "$archive_confidence >= $AUTO_ARCHIVE_CONFIDENCE" | bc -l) )); then
                coordinate_backup_transition "$backup_id" "ARCHIVED" "TIME_BASED" "cleanable timeout: ${age_seconds}s, archiving"
            else
                flag_for_manual_review "$backup_id" "archive_decision" "$archive_confidence"
            fi
        else
            # Direct deletion if archiving is disabled
            local delete_confidence=$(calculate_delete_confidence "$backup_id")
            
            if (( $(echo "$delete_confidence >= $AUTO_DELETE_CONFIDENCE" | bc -l) )); then
                coordinate_backup_transition "$backup_id" "DELETED" "TIME_BASED" "cleanable timeout: ${age_seconds}s, direct deletion"
            else
                flag_for_manual_review "$backup_id" "delete_decision" "$delete_confidence"
            fi
        fi
    done
}

# Process ARCHIVED state timeouts
process_archived_timeouts() {
    local current_time=$1
    
    find "$ARCHIVE_ROOT" -name "*.tar.gz" | while read -r archive_file; do
        local backup_id=$(basename "$archive_file" .tar.gz)
        local archived_at=$(stat -c %Y "$archive_file" 2>/dev/null || stat -f %m "$archive_file" 2>/dev/null)
        local age_seconds=$((current_time - archived_at))
        
        # Check for deletion timeout
        if (( age_seconds >= ARCHIVED_TO_DELETED_TIMEOUT )); then
            log_info "Archived backup $backup_id eligible for deletion after ${age_seconds}s"
            
            local delete_confidence=$(calculate_archived_delete_confidence "$backup_id" "$age_seconds")
            
            if (( $(echo "$delete_confidence >= $AUTO_DELETE_CONFIDENCE" | bc -l) )); then
                delete_archived_backup "$backup_id" "$archive_file" "time-based deletion: ${age_seconds}s"
            else
                flag_archived_for_manual_review "$backup_id" "$delete_confidence"
            fi
        fi
    done
}

# Helper functions for time-based processing

# Get backup timestamp for specific event
get_backup_timestamp() {
    local backup_id=$1
    local event_type=$2
    
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    case "$event_type" in
        "created")
            if [[ -f "$backup_dir/.created_at" ]]; then
                cat "$backup_dir/.created_at"
            else
                stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir" 2>/dev/null
            fi
            ;;
        "pending")
            if [[ -f "$backup_dir/.pending_since" ]]; then
                cat "$backup_dir/.pending_since"
            else
                get_backup_timestamp "$backup_id" "created"
            fi
            ;;
        "confirmed")
            if [[ -f "$backup_dir/.confirmed_at" ]]; then
                cat "$backup_dir/.confirmed_at"
            else
                get_backup_timestamp "$backup_id" "pending"
            fi
            ;;
        "cleanable")
            if [[ -f "$backup_dir/.cleanable_since" ]]; then
                cat "$backup_dir/.cleanable_since"
            else
                get_backup_timestamp "$backup_id" "confirmed"
            fi
            ;;
        *)
            log_error "Unknown event type: $event_type"
            echo "0"
            ;;
    esac
}

# Check if git activity has occurred since backup creation
has_git_activity_since() {
    local backup_id=$1
    local since_timestamp=$2
    
    # Check for commits since backup creation
    local recent_commits=$(git log --since="@$since_timestamp" --oneline | wc -l)
    
    if (( recent_commits > 0 )); then
        return 0
    else
        return 1
    fi
}

# Calculate cleanup confidence for CREATED backups
calculate_created_cleanup_confidence() {
    local backup_id=$1
    local age_seconds=$2
    
    local confidence=0.3  # Base confidence for created backups
    
    # Age factor (older = higher confidence)
    local age_hours=$((age_seconds / 3600))
    if (( age_hours >= 24 )); then
        confidence=$(echo "scale=2; $confidence + 0.4" | bc -l)
    elif (( age_hours >= 6 )); then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Git activity factor
    local backup_dir="$BACKUP_ROOT/$backup_id"
    if [[ -f "$backup_dir/.created_at" ]]; then
        local created_at=$(cat "$backup_dir/.created_at")
        if ! has_git_activity_since "$backup_id" "$created_at"; then
            confidence=$(echo "scale=2; $confidence + 0.3" | bc -l)
        fi
    fi
    
    # Size factor (smaller = higher confidence)
    local size_mb=$(du -sm "$backup_dir" 2>/dev/null | cut -f1)
    if (( size_mb < 10 )); then
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

# Calculate cleanup confidence for PENDING backups
calculate_pending_cleanup_confidence() {
    local backup_id=$1
    local age_seconds=$2
    
    local confidence=0.5  # Base confidence for pending backups
    
    # Age factor
    local age_days=$((age_seconds / 86400))
    if (( age_days >= 7 )); then
        confidence=$(echo "scale=2; $confidence + 0.3" | bc -l)
    elif (( age_days >= 3 )); then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Merge expectation factor
    if ! is_merge_still_expected "$backup_id"; then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    fi
    
    # Branch activity factor
    local backup_dir="$BACKUP_ROOT/$backup_id"
    if [[ -f "$backup_dir/.commit_info" ]]; then
        local branch=$(jq -r '.branch' "$backup_dir/.commit_info" 2>/dev/null)
        if ! is_branch_active "$branch"; then
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

# Calculate cleanup confidence for CONFIRMED backups
calculate_confirmed_cleanup_confidence() {
    local backup_id=$1
    local age_seconds=$2
    local value_score=$3
    
    local confidence=0.6  # Base confidence for confirmed backups
    
    # Age factor
    local age_days=$((age_seconds / 86400))
    if (( age_days >= 30 )); then
        confidence=$(echo "scale=2; $confidence + 0.3" | bc -l)
    elif (( age_days >= 14 )); then
        confidence=$(echo "scale=2; $confidence + 0.2" | bc -l)
    elif (( age_days >= 7 )); then
        confidence=$(echo "scale=2; $confidence + 0.1" | bc -l)
    fi
    
    # Value score factor (lower value = higher cleanup confidence)
    local value_factor=$(echo "scale=2; (1.0 - $value_score) * 0.2" | bc -l)
    confidence=$(echo "scale=2; $confidence + $value_factor" | bc -l)
    
    # Ensure confidence stays within bounds
    if (( $(echo "$confidence > 1.0" | bc -l) )); then
        confidence=1.0
    elif (( $(echo "$confidence < 0.0" | bc -l) )); then
        confidence=0.0
    fi
    
    echo "$confidence"
}

# Calculate backup value score
calculate_backup_value_score() {
    local backup_id=$1
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    local value=0.5  # Base value
    
    # Recent access factor
    local last_access=$(find "$backup_dir" -type f -atime -7 | wc -l)
    if (( last_access > 0 )); then
        value=$(echo "scale=2; $value + 0.2" | bc -l)
    fi
    
    # Size factor (larger backups might be more valuable)
    local size_mb=$(du -sm "$backup_dir" 2>/dev/null | cut -f1)
    if (( size_mb > 100 )); then
        value=$(echo "scale=2; $value + 0.1" | bc -l)
    fi
    
    # Merge quality factor
    if [[ -f "$backup_dir/.merge_info" ]]; then
        local merge_confidence=$(jq -r '.confidence' "$backup_dir/.merge_info" 2>/dev/null)
        if [[ "$merge_confidence" != "null" ]]; then
            local merge_factor=$(echo "scale=2; $merge_confidence * 0.2" | bc -l)
            value=$(echo "scale=2; $value + $merge_factor" | bc -l)
        fi
    fi
    
    # Ensure value stays within bounds
    if (( $(echo "$value > 1.0" | bc -l) )); then
        value=1.0
    elif (( $(echo "$value < 0.0" | bc -l) )); then
        value=0.0
    fi
    
    echo "$value"
}

# Check if merge is still expected for a backup
is_merge_still_expected() {
    local backup_id=$1
    local backup_dir="$BACKUP_ROOT/$backup_id"
    
    # Check if backup has commit info
    if [[ ! -f "$backup_dir/.commit_info" ]]; then
        return 1
    fi
    
    local branch=$(jq -r '.branch' "$backup_dir/.commit_info" 2>/dev/null)
    local commit_hash=$(jq -r '.commit_hash' "$backup_dir/.commit_info" 2>/dev/null)
    
    # Check if branch still exists and is active
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        return 1
    fi
    
    # Check if commit is still in branch history
    if ! git merge-base --is-ancestor "$commit_hash" "$branch" 2>/dev/null; then
        return 1
    fi
    
    # Check for recent activity on the branch
    local recent_commits=$(git log "$branch" --since="7 days ago" --oneline | wc -l)
    if (( recent_commits > 0 )); then
        return 0
    else
        return 1
    fi
}

# Check if a branch is still active
is_branch_active() {
    local branch=$1
    
    # Check if branch exists
    if ! git show-ref --verify --quiet "refs/heads/$branch"; then
        return 1
    fi
    
    # Check for recent commits
    local recent_commits=$(git log "$branch" --since="7 days ago" --oneline | wc -l)
    if (( recent_commits > 0 )); then
        return 0
    else
        return 1
    fi
}

# Flag backup for manual review
flag_for_manual_review() {
    local backup_id=$1
    local reason=$2
    local confidence=$3
    
    local review_file="$BACKUP_CONFIG_DIR/manual-review.log"
    local timestamp=$(date -Iseconds)
    
    echo "${timestamp}|${backup_id}|${reason}|${confidence}" >> "$review_file"
    
    log_info "Backup $backup_id flagged for manual review: $reason (confidence: $confidence)"
}

# Update time policy metrics
update_time_policy_metrics() {
    local current_time=$1
    local metrics_file="$BACKUP_CONFIG_DIR/metrics/time-policies.log"
    
    mkdir -p "$(dirname "$metrics_file")"
    
    # Count backups in each state
    local created_count=$(find "$BACKUP_ROOT" -name ".state" -exec grep -l "CREATED" {} \; | wc -l)
    local pending_count=$(find "$BACKUP_ROOT" -name ".state" -exec grep -l "PENDING" {} \; | wc -l)
    local confirmed_count=$(find "$BACKUP_ROOT" -name ".state" -exec grep -l "CONFIRMED" {} \; | wc -l)
    local cleanable_count=$(find "$BACKUP_ROOT" -name ".state" -exec grep -l "CLEANABLE" {} \; | wc -l)
    
    # Count archived backups
    local archived_count=$(find "$ARCHIVE_ROOT" -name "*.tar.gz" | wc -l)
    
    echo "$(date -Iseconds)|$created_count|$pending_count|$confirmed_count|$cleanable_count|$archived_count" >> "$metrics_file"
}

# Time trigger daemon status
get_time_trigger_status() {
    local daemon_name="backup-time-trigger"
    local pid_file="/var/run/${daemon_name}.pid"
    
    echo "=== Time-Based Backup Trigger Status ==="
    
    if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo "Status: Running (PID: $(cat "$pid_file"))"
        echo "Started: $(ps -o lstart= -p "$(cat "$pid_file")" 2>/dev/null)"
    else
        echo "Status: Stopped"
    fi
    
    echo ""
    echo "=== Policy Configuration ==="
    if [[ -f "$BACKUP_CONFIG_DIR/time-policies.conf" ]]; then
        grep -E "(TIMEOUT|INTERVAL|THRESHOLD)" "$BACKUP_CONFIG_DIR/time-policies.conf"
    else
        echo "No policy configuration found"
    fi
    
    echo ""
    echo "=== Recent Metrics ==="
    if [[ -f "$BACKUP_CONFIG_DIR/metrics/time-policies.log" ]]; then
        echo "Timestamp|Created|Pending|Confirmed|Cleanable|Archived"
        tail -5 "$BACKUP_CONFIG_DIR/metrics/time-policies.log"
    else
        echo "No metrics available"
    fi
}

# Main function for direct execution
main() {
    local action=${1:-"status"}
    
    case "$action" in
        "start")
            start_time_trigger_daemon "$2"
            ;;
        "stop")
            stop_time_trigger_daemon
            ;;
        "restart")
            stop_time_trigger_daemon
            sleep 2
            start_time_trigger_daemon
            ;;
        "status")
            get_time_trigger_status
            ;;
        "process")
            # Manual policy processing
            process_time_policies
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|process}"
            echo "  start [--foreground]  - Start the time trigger daemon"
            echo "  stop                  - Stop the time trigger daemon"
            echo "  restart              - Restart the time trigger daemon"
            echo "  status               - Show daemon and policy status"
            echo "  process              - Manually process time policies once"
            exit 1
            ;;
    esac
}

# Export functions for external usage
export -f start_time_trigger_daemon
export -f stop_time_trigger_daemon
export -f process_time_policies

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi