---
description: Disk space monitoring and emergency cleanup system
---

# Disk Space Backup Triggers

Real-time disk space monitoring system that triggers emergency cleanup when space thresholds are exceeded, with priority-based cleanup ordering.

## Disk Space Monitor

```bash
# Source the coordinator and shared utilities
source "$(dirname "${BASH_SOURCE[0]}")/../coordinator.md"

# Disk space monitoring daemon
start_disk_monitor_daemon() {
    local daemon_name="backup-disk-monitor"
    local pid_file="/var/run/${daemon_name}.pid"
    local log_file="/var/log/${daemon_name}.log"
    local config_file="$BACKUP_CONFIG_DIR/disk-policies.conf"
    
    # Check if daemon is already running
    if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        log_error "Disk monitor daemon is already running (PID: $(cat "$pid_file"))"
        return 1
    fi
    
    log_info "Starting disk space backup monitor daemon"
    
    # Load configuration
    load_disk_policies "$config_file"
    
    # Daemonize the process
    {
        while true; do
            # Monitor disk space
            monitor_disk_space
            
            # Check for emergency conditions
            check_emergency_conditions
            
            # Sleep based on check interval
            sleep "${DISK_CHECK_INTERVAL:-60}"  # Default 1 minute
            
        done
    } &
    
    local daemon_pid=$!
    echo "$daemon_pid" > "$pid_file"
    
    log_success "Disk monitor daemon started (PID: $daemon_pid)"
    
    # Setup signal handlers for graceful shutdown
    trap "stop_disk_monitor_daemon" TERM INT
    
    # Wait for daemon process if running in foreground
    if [[ "${1:-}" == "--foreground" ]]; then
        wait "$daemon_pid"
    fi
}

# Stop disk monitor daemon
stop_disk_monitor_daemon() {
    local daemon_name="backup-disk-monitor"
    local pid_file="/var/run/${daemon_name}.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        
        if kill -0 "$pid" 2>/dev/null; then
            log_info "Stopping disk monitor daemon (PID: $pid)"
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
            log_success "Disk monitor daemon stopped"
        else
            log_warning "Daemon PID file exists but process not running"
            rm -f "$pid_file"
        fi
    else
        log_info "Disk monitor daemon is not running"
    fi
}

# Load disk space policies
load_disk_policies() {
    local config_file=$1
    
    # Default policies if config file doesn't exist
    if [[ ! -f "$config_file" ]]; then
        create_default_disk_policies "$config_file"
    fi
    
    # Source the configuration
    source "$config_file"
    
    log_debug "Loaded disk policies from: $config_file"
}

# Create default disk policies
create_default_disk_policies() {
    local config_file=$1
    
    mkdir -p "$(dirname "$config_file")"
    
    cat > "$config_file" << 'EOF'
# Disk space monitoring and cleanup policies

# Disk usage thresholds (percentage)
DISK_WARNING_THRESHOLD=75
DISK_CRITICAL_THRESHOLD=85
DISK_EMERGENCY_THRESHOLD=95

# Cleanup strategies
CLEANUP_STRATEGY="oldest_first"  # oldest_first, largest_first, confidence_based
EMERGENCY_CLEANUP_STRATEGY="aggressive"  # conservative, aggressive, nuclear

# Size thresholds for priority cleanup
LARGE_BACKUP_THRESHOLD=100  # MB
HUGE_BACKUP_THRESHOLD=500   # MB

# Safety limits
MAX_CLEANUP_PER_CYCLE=10    # Maximum backups to clean per cycle
MIN_FREE_SPACE_TARGET=20    # Target free space percentage after cleanup
EMERGENCY_CLEANUP_LIMIT=50  # Maximum backups to clean in emergency

# Check intervals
DISK_CHECK_INTERVAL=60      # 1 minute
CLEANUP_CYCLE_INTERVAL=300  # 5 minutes
EMERGENCY_CHECK_INTERVAL=10 # 10 seconds during emergency

# Cleanup confidence overrides for disk pressure
DISK_PRESSURE_CONFIDENCE_BOOST=0.2
EMERGENCY_CONFIDENCE_OVERRIDE=0.5

# Archive compression during cleanup
COMPRESS_BEFORE_DELETE=true
COMPRESSION_RATIO_ESTIMATE=0.3  # 30% of original size

# Monitoring and alerting
ENABLE_DISK_ALERTS=true
ALERT_EMAIL=""
ALERT_WEBHOOK_URL=""
SLACK_WEBHOOK_URL=""
EOF
    
    log_info "Created default disk policies: $config_file"
}

# Monitor disk space and trigger actions
monitor_disk_space() {
    local backup_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    local archive_usage=$(get_disk_usage_percentage "$ARCHIVE_ROOT")
    local total_usage=$(get_disk_usage_percentage "/")
    
    # Log current usage
    log_debug "Disk usage - Backup: ${backup_usage}%, Archive: ${archive_usage}%, Total: ${total_usage}%"
    
    # Update metrics
    update_disk_metrics "$backup_usage" "$archive_usage" "$total_usage"
    
    # Check thresholds and take action
    if (( $(echo "$backup_usage >= $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
        log_warning "EMERGENCY: Backup disk usage at ${backup_usage}%"
        trigger_emergency_cleanup "$backup_usage"
    elif (( $(echo "$backup_usage >= $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
        log_warning "CRITICAL: Backup disk usage at ${backup_usage}%"
        trigger_critical_cleanup "$backup_usage"
    elif (( $(echo "$backup_usage >= $DISK_WARNING_THRESHOLD" | bc -l) )); then
        log_info "WARNING: Backup disk usage at ${backup_usage}%"
        trigger_warning_cleanup "$backup_usage"
    fi
    
    # Check archive disk separately
    if (( $(echo "$archive_usage >= $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
        log_warning "Archive disk usage critical: ${archive_usage}%"
        trigger_archive_cleanup "$archive_usage"
    fi
}

# Check for emergency disk conditions
check_emergency_conditions() {
    local backup_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    
    # Emergency monitoring mode
    if (( $(echo "$backup_usage >= $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
        log_warning "Entering emergency monitoring mode"
        
        # More frequent checks during emergency
        local emergency_cycles=30  # 5 minutes of 10-second checks
        for (( i=0; i<emergency_cycles; i++ )); do
            sleep "$EMERGENCY_CHECK_INTERVAL"
            
            local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            
            if (( $(echo "$current_usage < $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
                log_success "Emergency condition resolved: ${current_usage}%"
                break
            fi
            
            # Continue emergency cleanup
            if (( i % 3 == 0 )); then  # Every 30 seconds
                trigger_emergency_cleanup "$current_usage"
            fi
        done
    fi
}

# Trigger warning-level cleanup
trigger_warning_cleanup() {
    local usage_percent=$1
    
    log_info "Triggering warning-level cleanup (usage: ${usage_percent}%)"
    
    # Find cleanable backups for gentle cleanup
    local cleanup_candidates=$(find_cleanup_candidates "gentle" 5)
    
    if [[ -n "$cleanup_candidates" ]]; then
        execute_cleanup_batch "$cleanup_candidates" "DISK_SPACE" "warning level cleanup: ${usage_percent}%"
    else
        log_info "No suitable candidates for warning-level cleanup"
    fi
    
    # Send warning alert
    send_disk_alert "warning" "$usage_percent"
}

# Trigger critical-level cleanup
trigger_critical_cleanup() {
    local usage_percent=$1
    
    log_warning "Triggering critical-level cleanup (usage: ${usage_percent}%)"
    
    # Find cleanable backups for moderate cleanup
    local cleanup_candidates=$(find_cleanup_candidates "moderate" "$MAX_CLEANUP_PER_CYCLE")
    
    if [[ -n "$cleanup_candidates" ]]; then
        execute_cleanup_batch "$cleanup_candidates" "DISK_SPACE" "critical level cleanup: ${usage_percent}%"
    fi
    
    # If still critical, try to transition confirmed backups to cleanable
    local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    if (( $(echo "$current_usage >= $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
        promote_confirmed_to_cleanable "$usage_percent"
    fi
    
    # Send critical alert
    send_disk_alert "critical" "$usage_percent"
}

# Trigger emergency-level cleanup
trigger_emergency_cleanup() {
    local usage_percent=$1
    
    log_error "Triggering EMERGENCY cleanup (usage: ${usage_percent}%)"
    
    # Emergency cleanup with relaxed constraints
    local cleanup_candidates
    
    case "$EMERGENCY_CLEANUP_STRATEGY" in
        "aggressive")
            cleanup_candidates=$(find_cleanup_candidates "aggressive" "$EMERGENCY_CLEANUP_LIMIT")
            ;;
        "nuclear")
            cleanup_candidates=$(find_cleanup_candidates "nuclear" -1)  # No limit
            ;;
        *)
            cleanup_candidates=$(find_cleanup_candidates "conservative" "$MAX_CLEANUP_PER_CYCLE")
            ;;
    esac
    
    if [[ -n "$cleanup_candidates" ]]; then
        execute_emergency_cleanup_batch "$cleanup_candidates" "emergency cleanup: ${usage_percent}%"
    fi
    
    # If still in emergency, force transitions
    local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    if (( $(echo "$current_usage >= $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
        force_emergency_transitions "$usage_percent"
    fi
    
    # Send emergency alert
    send_disk_alert "emergency" "$usage_percent"
}

# Find cleanup candidates based on strategy
find_cleanup_candidates() {
    local cleanup_level=$1
    local max_candidates=$2
    
    local candidates=()
    
    case "$CLEANUP_STRATEGY" in
        "oldest_first")
            candidates=($(find_oldest_cleanable_backups "$max_candidates"))
            ;;
        "largest_first")
            candidates=($(find_largest_cleanable_backups "$max_candidates"))
            ;;
        "confidence_based")
            candidates=($(find_highest_confidence_backups "$cleanup_level" "$max_candidates"))
            ;;
        *)
            candidates=($(find_oldest_cleanable_backups "$max_candidates"))
            ;;
    esac
    
    # Apply cleanup level filters
    case "$cleanup_level" in
        "gentle")
            # Only high-confidence cleanable backups
            filter_candidates_by_confidence "${candidates[@]}" 0.85
            ;;
        "moderate")
            # Medium to high confidence cleanable and some confirmed
            filter_candidates_by_confidence "${candidates[@]}" 0.70
            ;;
        "aggressive")
            # Include pending backups and lower confidence
            filter_candidates_by_confidence "${candidates[@]}" 0.50
            ;;
        "nuclear")
            # Include almost everything except very recent
            filter_candidates_by_age "${candidates[@]}" 3600  # 1 hour minimum
            ;;
        *)
            filter_candidates_by_confidence "${candidates[@]}" 0.75
            ;;
    esac
}

# Find oldest cleanable backups
find_oldest_cleanable_backups() {
    local max_count=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        
        local state=$(cat "$backup_dir/.state")
        [[ "$state" == "CLEANABLE" ]] || continue
        
        # Get modification time for sorting
        local mtime=$(stat -c %Y "$backup_dir" 2>/dev/null || stat -f %m "$backup_dir" 2>/dev/null)
        echo "$mtime $backup_id"
        
    done | sort -n | head -n "$max_count" | cut -d' ' -f2
}

# Find largest cleanable backups
find_largest_cleanable_backups() {
    local max_count=$1
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        
        local state=$(cat "$backup_dir/.state")
        [[ "$state" == "CLEANABLE" ]] || continue
        
        # Get directory size for sorting
        local size_kb=$(du -sk "$backup_dir" 2>/dev/null | cut -f1)
        echo "$size_kb $backup_id"
        
    done | sort -nr | head -n "$max_count" | cut -d' ' -f2
}

# Find highest confidence backups for cleanup
find_highest_confidence_backups() {
    local cleanup_level=$1
    local max_count=$2
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        
        local state=$(cat "$backup_dir/.state")
        
        # Include different states based on cleanup level
        case "$cleanup_level" in
            "gentle")
                [[ "$state" == "CLEANABLE" ]] || continue
                ;;
            "moderate")
                [[ "$state" =~ ^(CLEANABLE|CONFIRMED)$ ]] || continue
                ;;
            "aggressive")
                [[ "$state" =~ ^(CLEANABLE|CONFIRMED|PENDING)$ ]] || continue
                ;;
            "nuclear")
                [[ "$state" =~ ^(CLEANABLE|CONFIRMED|PENDING|CREATED)$ ]] || continue
                ;;
        esac
        
        # Calculate cleanup confidence with disk pressure boost
        local base_confidence=$(calculate_cleanup_confidence "$backup_id")
        local boosted_confidence=$(echo "scale=2; $base_confidence + $DISK_PRESSURE_CONFIDENCE_BOOST" | bc -l)
        
        # Ensure confidence doesn't exceed 1.0
        if (( $(echo "$boosted_confidence > 1.0" | bc -l) )); then
            boosted_confidence=1.0
        fi
        
        echo "$boosted_confidence $backup_id"
        
    done | sort -nr | head -n "$max_count" | cut -d' ' -f2
}

# Filter candidates by confidence threshold
filter_candidates_by_confidence() {
    local threshold=$1
    shift
    local candidates=("$@")
    
    for backup_id in "${candidates[@]}"; do
        local confidence=$(calculate_cleanup_confidence "$backup_id")
        local boosted_confidence=$(echo "scale=2; $confidence + $DISK_PRESSURE_CONFIDENCE_BOOST" | bc -l)
        
        if (( $(echo "$boosted_confidence >= $threshold" | bc -l) )); then
            echo "$backup_id"
        fi
    done
}

# Filter candidates by minimum age
filter_candidates_by_age() {
    local min_age_seconds=$1
    shift
    local candidates=("$@")
    
    local current_time=$(date +%s)
    
    for backup_id in "${candidates[@]}"; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        local created_at=$(get_backup_timestamp "$backup_id" "created")
        local age_seconds=$((current_time - created_at))
        
        if (( age_seconds >= min_age_seconds )); then
            echo "$backup_id"
        fi
    done
}

# Execute cleanup batch
execute_cleanup_batch() {
    local candidates="$1"
    local trigger_type="$2"
    local reason="$3"
    
    local cleaned_count=0
    local total_size_freed=0
    
    for backup_id in $candidates; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        
        # Skip if backup no longer exists
        [[ ! -d "$backup_dir" ]] && continue
        
        # Calculate size before cleanup
        local backup_size=$(du -sk "$backup_dir" 2>/dev/null | cut -f1)
        
        log_info "Cleaning up backup: $backup_id (${backup_size}KB)"
        
        # Attempt cleanup transition
        if coordinate_backup_transition "$backup_id" "DELETED" "$trigger_type" "$reason"; then
            ((cleaned_count++))
            total_size_freed=$((total_size_freed + backup_size))
            
            log_success "Backup $backup_id cleaned up successfully"
        else
            log_error "Failed to clean up backup: $backup_id"
        fi
        
        # Check if we've freed enough space
        local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
        if (( $(echo "$current_usage < $DISK_WARNING_THRESHOLD" | bc -l) )); then
            log_success "Disk usage reduced to acceptable level: ${current_usage}%"
            break
        fi
    done
    
    log_info "Cleanup batch completed: $cleaned_count backups cleaned, ${total_size_freed}KB freed"
}

# Execute emergency cleanup batch with relaxed constraints
execute_emergency_cleanup_batch() {
    local candidates="$1"
    local reason="$2"
    
    local cleaned_count=0
    local total_size_freed=0
    
    for backup_id in $candidates; do
        local backup_dir="$BACKUP_ROOT/$backup_id"
        
        # Skip if backup no longer exists
        [[ ! -d "$backup_dir" ]] && continue
        
        # Calculate size before cleanup
        local backup_size=$(du -sk "$backup_dir" 2>/dev/null | cut -f1)
        
        log_warning "EMERGENCY: Cleaning up backup: $backup_id (${backup_size}KB)"
        
        # Force transition with emergency confidence override
        local current_state=$(cat "$backup_dir/.state" 2>/dev/null || echo "UNKNOWN")
        
        # Try archive first if enabled and backup is valuable
        if [[ "$COMPRESS_BEFORE_DELETE" == "true" ]] && [[ "$current_state" =~ ^(CONFIRMED|CLEANABLE)$ ]]; then
            if coordinate_backup_transition "$backup_id" "ARCHIVED" "DISK_SPACE" "emergency archive: $reason"; then
                local compressed_size=$((backup_size * COMPRESSION_RATIO_ESTIMATE / 1))
                local size_saved=$((backup_size - compressed_size))
                total_size_freed=$((total_size_freed + size_saved))
                ((cleaned_count++))
                
                log_success "Backup $backup_id archived (saved ${size_saved}KB)"
            else
                # Archive failed, try direct deletion
                if coordinate_backup_transition "$backup_id" "DELETED" "DISK_SPACE" "emergency delete: $reason" "true"; then
                    total_size_freed=$((total_size_freed + backup_size))
                    ((cleaned_count++))
                    
                    log_warning "Backup $backup_id force deleted"
                fi
            fi
        else
            # Direct deletion
            if coordinate_backup_transition "$backup_id" "DELETED" "DISK_SPACE" "emergency delete: $reason" "true"; then
                total_size_freed=$((total_size_freed + backup_size))
                ((cleaned_count++))
                
                log_warning "Backup $backup_id emergency deleted"
            fi
        fi
        
        # Check if we've reached target free space
        local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
        if (( $(echo "$current_usage <= $MIN_FREE_SPACE_TARGET" | bc -l) )); then
            log_success "Target free space reached: ${current_usage}%"
            break
        fi
    done
    
    log_warning "Emergency cleanup completed: $cleaned_count backups processed, ${total_size_freed}KB freed"
}

# Promote confirmed backups to cleanable during critical conditions
promote_confirmed_to_cleanable() {
    local usage_percent=$1
    
    log_info "Promoting confirmed backups to cleanable due to critical disk usage: ${usage_percent}%"
    
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        [[ "$(cat "$backup_dir/.state")" != "CONFIRMED" ]] && continue
        
        # Check backup age (only promote older backups)
        local backup_age=$(get_backup_age_days "$backup_id")
        if (( backup_age >= 1 )); then
            log_info "Promoting backup $backup_id to CLEANABLE (age: ${backup_age} days)"
            
            coordinate_backup_transition "$backup_id" "CLEANABLE" "DISK_SPACE" "promoted due to critical disk usage: ${usage_percent}%"
        fi
    done
}

# Force emergency transitions
force_emergency_transitions() {
    local usage_percent=$1
    
    log_error "Forcing emergency transitions due to critical disk usage: ${usage_percent}%"
    
    # Force pending backups to cleanable if they're old enough
    find "$BACKUP_ROOT" -maxdepth 1 -type d -name "*" | while read -r backup_dir; do
        local backup_id=$(basename "$backup_dir")
        
        # Skip if not a valid backup directory
        [[ "$backup_id" == "*" ]] && continue
        [[ ! -f "$backup_dir/.state" ]] && continue
        
        local state=$(cat "$backup_dir/.state")
        local backup_age=$(get_backup_age_days "$backup_id")
        
        case "$state" in
            "CREATED")
                if (( backup_age >= 1 )); then  # 1 day old
                    coordinate_backup_transition "$backup_id" "DELETED" "DISK_SPACE" "emergency force delete CREATED: ${usage_percent}%" "true"
                fi
                ;;
            "PENDING")
                if (( backup_age >= 2 )); then  # 2 days old
                    coordinate_backup_transition "$backup_id" "CLEANABLE" "DISK_SPACE" "emergency force PENDING→CLEANABLE: ${usage_percent}%" "true"
                fi
                ;;
        esac
    done
}

# Trigger archive cleanup when archive disk is full
trigger_archive_cleanup() {
    local usage_percent=$1
    
    log_warning "Triggering archive cleanup (usage: ${usage_percent}%)"
    
    # Find oldest archives for deletion
    find "$ARCHIVE_ROOT" -name "*.tar.gz" -printf "%T@ %p\n" | sort -n | head -10 | while read -r timestamp archive_path; do
        local backup_id=$(basename "$archive_path" .tar.gz)
        
        log_info "Deleting old archive: $backup_id"
        
        if delete_archived_backup "$backup_id" "$archive_path" "archive disk cleanup: ${usage_percent}%"; then
            log_success "Archive deleted: $backup_id"
        else
            log_error "Failed to delete archive: $backup_id"
        fi
        
        # Check if we've freed enough space
        local current_usage=$(get_disk_usage_percentage "$ARCHIVE_ROOT")
        if (( $(echo "$current_usage < $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
            log_success "Archive disk usage reduced: ${current_usage}%"
            break
        fi
    done
}

# Get disk usage percentage for a path
get_disk_usage_percentage() {
    local path=$1
    
    # Ensure path exists
    [[ ! -d "$path" ]] && echo "0" && return
    
    # Get disk usage using df
    local usage_percent=$(df "$path" | awk 'NR==2 {gsub(/%/, "", $5); print $5}')
    
    echo "${usage_percent:-0}"
}

# Update disk metrics
update_disk_metrics() {
    local backup_usage=$1
    local archive_usage=$2
    local total_usage=$3
    
    local metrics_file="$BACKUP_CONFIG_DIR/metrics/disk-usage.log"
    mkdir -p "$(dirname "$metrics_file")"
    
    local timestamp=$(date -Iseconds)
    echo "${timestamp}|${backup_usage}|${archive_usage}|${total_usage}" >> "$metrics_file"
    
    # Keep only last 24 hours of metrics
    local cutoff_time=$(date -d '24 hours ago' -Iseconds 2>/dev/null || date -j -v-24H +%Y-%m-%dT%H:%M:%S 2>/dev/null)
    if [[ -n "$cutoff_time" ]]; then
        local temp_file=$(mktemp)
        awk -F'|' -v cutoff="$cutoff_time" '$1 >= cutoff' "$metrics_file" > "$temp_file"
        mv "$temp_file" "$metrics_file"
    fi
}

# Send disk usage alerts
send_disk_alert() {
    local alert_level=$1
    local usage_percent=$2
    
    if [[ "$ENABLE_DISK_ALERTS" != "true" ]]; then
        return 0
    fi
    
    local alert_message="BACKUP DISK ALERT: $alert_level level - ${usage_percent}% usage"
    local alert_details="Backup Directory: $BACKUP_ROOT\nTimestamp: $(date)\nUsage: ${usage_percent}%"
    
    # Email alert
    if [[ -n "$ALERT_EMAIL" ]] && command -v mail >/dev/null 2>&1; then
        echo -e "$alert_details" | mail -s "$alert_message" "$ALERT_EMAIL"
    fi
    
    # Webhook alert
    if [[ -n "$ALERT_WEBHOOK_URL" ]] && command -v curl >/dev/null 2>&1; then
        curl -X POST -H "Content-Type: application/json" \
             -d "{\"message\":\"$alert_message\",\"details\":\"$alert_details\",\"level\":\"$alert_level\"}" \
             "$ALERT_WEBHOOK_URL" >/dev/null 2>&1 &
    fi
    
    # Slack alert
    if [[ -n "$SLACK_WEBHOOK_URL" ]] && command -v curl >/dev/null 2>&1; then
        local slack_color="good"
        case "$alert_level" in
            "critical") slack_color="warning" ;;
            "emergency") slack_color="danger" ;;
        esac
        
        curl -X POST -H "Content-Type: application/json" \
             -d "{\"attachments\":[{\"color\":\"$slack_color\",\"title\":\"$alert_message\",\"text\":\"$alert_details\"}]}" \
             "$SLACK_WEBHOOK_URL" >/dev/null 2>&1 &
    fi
    
    log_info "Disk alert sent: $alert_level level"
}

# Get disk monitor status
get_disk_monitor_status() {
    local daemon_name="backup-disk-monitor"
    local pid_file="/var/run/${daemon_name}.pid"
    
    echo "=== Disk Space Backup Monitor Status ==="
    
    if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo "Status: Running (PID: $(cat "$pid_file"))"
        echo "Started: $(ps -o lstart= -p "$(cat "$pid_file")" 2>/dev/null)"
    else
        echo "Status: Stopped"
    fi
    
    echo ""
    echo "=== Current Disk Usage ==="
    local backup_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    local archive_usage=$(get_disk_usage_percentage "$ARCHIVE_ROOT")
    
    echo "Backup Directory: ${backup_usage}%"
    echo "Archive Directory: ${archive_usage}%"
    
    # Show usage relative to thresholds
    echo ""
    echo "=== Threshold Status ==="
    echo "Warning Threshold: $DISK_WARNING_THRESHOLD%"
    echo "Critical Threshold: $DISK_CRITICAL_THRESHOLD%"
    echo "Emergency Threshold: $DISK_EMERGENCY_THRESHOLD%"
    
    if (( $(echo "$backup_usage >= $DISK_EMERGENCY_THRESHOLD" | bc -l) )); then
        echo "Status: EMERGENCY ⚠️"
    elif (( $(echo "$backup_usage >= $DISK_CRITICAL_THRESHOLD" | bc -l) )); then
        echo "Status: CRITICAL ⚠️"
    elif (( $(echo "$backup_usage >= $DISK_WARNING_THRESHOLD" | bc -l) )); then
        echo "Status: WARNING ⚠️"
    else
        echo "Status: OK ✅"
    fi
    
    echo ""
    echo "=== Recent Metrics ==="
    if [[ -f "$BACKUP_CONFIG_DIR/metrics/disk-usage.log" ]]; then
        echo "Timestamp|Backup%|Archive%|Total%"
        tail -5 "$BACKUP_CONFIG_DIR/metrics/disk-usage.log"
    else
        echo "No metrics available"
    fi
}

# Manual disk cleanup trigger
manual_disk_cleanup() {
    local cleanup_level=${1:-"moderate"}
    local max_backups=${2:-10}
    
    log_info "Manual disk cleanup triggered: $cleanup_level level, max $max_backups backups"
    
    local current_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
    log_info "Current backup disk usage: ${current_usage}%"
    
    local candidates=$(find_cleanup_candidates "$cleanup_level" "$max_backups")
    
    if [[ -n "$candidates" ]]; then
        echo "Cleanup candidates:"
        for backup_id in $candidates; do
            local backup_dir="$BACKUP_ROOT/$backup_id"
            local size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
            local state=$(cat "$backup_dir/.state" 2>/dev/null)
            local confidence=$(calculate_cleanup_confidence "$backup_id")
            
            echo "  $backup_id: $size, $state, confidence: $confidence"
        done
        
        echo ""
        read -p "Proceed with cleanup? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            execute_cleanup_batch "$candidates" "USER" "manual disk cleanup: $cleanup_level"
            
            local new_usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            log_success "Cleanup completed. New usage: ${new_usage}%"
        else
            log_info "Cleanup cancelled by user"
        fi
    else
        log_info "No suitable cleanup candidates found"
    fi
}

# Main function for direct execution
main() {
    local action=${1:-"status"}
    
    case "$action" in
        "start")
            start_disk_monitor_daemon "$2"
            ;;
        "stop")
            stop_disk_monitor_daemon
            ;;
        "restart")
            stop_disk_monitor_daemon
            sleep 2
            start_disk_monitor_daemon
            ;;
        "status")
            get_disk_monitor_status
            ;;
        "monitor")
            # Manual monitoring cycle
            monitor_disk_space
            ;;
        "cleanup")
            manual_disk_cleanup "$2" "$3"
            ;;
        "emergency")
            # Manual emergency cleanup
            local usage=$(get_disk_usage_percentage "$BACKUP_ROOT")
            trigger_emergency_cleanup "$usage"
            ;;
        *)
            echo "Usage: $0 {start|stop|restart|status|monitor|cleanup|emergency}"
            echo "  start [--foreground]     - Start the disk monitor daemon"
            echo "  stop                     - Stop the disk monitor daemon"
            echo "  restart                  - Restart the disk monitor daemon"
            echo "  status                   - Show disk usage and monitor status"
            echo "  monitor                  - Run monitoring cycle once"
            echo "  cleanup [level] [count]  - Manual cleanup (gentle|moderate|aggressive)"
            echo "  emergency                - Manual emergency cleanup"
            exit 1
            ;;
    esac
}

# Export functions for external usage
export -f start_disk_monitor_daemon
export -f stop_disk_monitor_daemon
export -f monitor_disk_space
export -f trigger_emergency_cleanup

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi