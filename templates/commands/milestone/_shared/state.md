---
description: State management utilities for milestone execution with atomic operations and event logging
---

# Milestone State Management

Comprehensive state management utilities providing file-based persistence, atomic operations, event logging, and session management for milestone execution.

## Core State Management

```bash
# Initialize milestone state directory
init_milestone_state() {
    local milestone_id=$1
    local state_dir=".milestones/state"
    
    mkdir -p "$state_dir"/{active,completed,sessions,backups,events}
    
    # Create state lock directory for atomic operations
    mkdir -p "$state_dir/.locks"
    
    # Initialize event log
    local event_log="$state_dir/events/milestone-$milestone_id.jsonl"
    if [ ! -f "$event_log" ]; then
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"state_initialized\",\"milestone_id\":\"$milestone_id\"}" >> "$event_log"
    fi
    
    echo "State management initialized for milestone: $milestone_id"
}

# Acquire state lock for atomic operations
acquire_state_lock() {
    local milestone_id=$1
    local timeout=${2:-30}
    local lock_file=".milestones/state/.locks/$milestone_id.lock"
    local lock_acquired=false
    local waited=0
    
    while [ $waited -lt $timeout ]; do
        if mkdir "$lock_file" 2>/dev/null; then
            echo $$ > "$lock_file/pid"
            echo "$(date -u +%Y-%m-%dT%H:%M:%SZ)" > "$lock_file/acquired"
            lock_acquired=true
            break
        fi
        
        # Check if lock is stale (older than 10 minutes)
        if [ -f "$lock_file/acquired" ]; then
            local lock_time=$(cat "$lock_file/acquired")
            local lock_epoch=$(date -d "$lock_time" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$lock_time" +%s 2>/dev/null)
            local current_epoch=$(date +%s)
            
            if [ $((current_epoch - lock_epoch)) -gt 600 ]; then
                echo "Removing stale lock (older than 10 minutes)"
                release_state_lock "$milestone_id" "force"
                continue
            fi
        fi
        
        sleep 1
        ((waited++))
    done
    
    if [ "$lock_acquired" = false ]; then
        echo "ERROR: Could not acquire state lock for milestone: $milestone_id"
        return 1
    fi
    
    echo "State lock acquired for milestone: $milestone_id"
}

# Release state lock
release_state_lock() {
    local milestone_id=$1
    local force=${2:-"false"}
    local lock_file=".milestones/state/.locks/$milestone_id.lock"
    
    if [ "$force" = "force" ] || [ -f "$lock_file/pid" ] && [ "$(cat "$lock_file/pid")" = "$$" ]; then
        rm -rf "$lock_file"
        echo "State lock released for milestone: $milestone_id"
    else
        echo "WARNING: Cannot release lock not owned by this process"
        return 1
    fi
}

# Save milestone state atomically
save_milestone_state() {
    local milestone_id=$1
    local state_data=$2
    local state_file=".milestones/state/active/$milestone_id.json"
    local temp_file="$state_file.tmp.$$"
    
    # Acquire lock
    if ! acquire_state_lock "$milestone_id"; then
        return 1
    fi
    
    # Create backup of current state
    if [ -f "$state_file" ]; then
        cp "$state_file" ".milestones/state/backups/$milestone_id-$(date +%Y%m%d-%H%M%S).json"
    fi
    
    # Write to temporary file first
    cat > "$temp_file" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "milestone_id": "$milestone_id",
  "version": "1.0",
  "state": $state_data
}
EOF
    
    # Validate JSON format
    if ! python3 -m json.tool "$temp_file" >/dev/null 2>&1; then
        echo "ERROR: Invalid JSON state data"
        rm -f "$temp_file"
        release_state_lock "$milestone_id"
        return 1
    fi
    
    # Atomic move
    mv "$temp_file" "$state_file"
    
    # Log state change event
    log_milestone_event "$milestone_id" "state_saved" "{\"state_file\": \"$state_file\"}"
    
    # Release lock
    release_state_lock "$milestone_id"
    
    echo "Milestone state saved: $state_file"
}

# Load milestone state
load_milestone_state() {
    local milestone_id=$1
    local state_file=".milestones/state/active/$milestone_id.json"
    
    if [ ! -f "$state_file" ]; then
        echo "ERROR: State file not found: $state_file"
        return 1
    fi
    
    # Validate file integrity
    if ! python3 -m json.tool "$state_file" >/dev/null 2>&1; then
        echo "ERROR: Corrupted state file, attempting recovery..."
        recover_milestone_state "$milestone_id"
        return $?
    fi
    
    # Extract state data
    python3 -c "import json; data=json.load(open('$state_file')); print(json.dumps(data['state'], indent=2))"
    
    # Log state access event
    log_milestone_event "$milestone_id" "state_loaded" "{\"state_file\": \"$state_file\"}"
}
```

## Event Logging

```bash
# Log milestone event in JSONL format
log_milestone_event() {
    local milestone_id=$1
    local event_type=$2
    local event_data=$3
    local session_id=${4:-"$(get_current_session_id)"}
    
    local event_log=".milestones/state/events/milestone-$milestone_id.jsonl"
    
    # Create event entry
    local event_entry="{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"milestone_id\":\"$milestone_id\",\"session_id\":\"$session_id\",\"event_type\":\"$event_type\",\"data\":$event_data,\"pid\":$$,\"user\":\"$(whoami)\"}"
    
    # Append to event log
    echo "$event_entry" >> "$event_log"
}

# Query milestone events
query_milestone_events() {
    local milestone_id=$1
    local event_type=${2:-""}
    local since=${3:-""}
    local limit=${4:-"50"}
    
    local event_log=".milestones/state/events/milestone-$milestone_id.jsonl"
    
    if [ ! -f "$event_log" ]; then
        echo "No events found for milestone: $milestone_id"
        return 0
    fi
    
    local filter_cmd="cat"
    
    # Apply event type filter
    if [ -n "$event_type" ]; then
        filter_cmd="$filter_cmd | grep '\"event_type\":\"$event_type\"'"
    fi
    
    # Apply time filter
    if [ -n "$since" ]; then
        local since_epoch=$(date -d "$since" +%s 2>/dev/null || date -j -f "%Y-%m-%d" "$since" +%s 2>/dev/null)
        filter_cmd="$filter_cmd | python3 -c \"
import sys, json
for line in sys.stdin:
    event = json.loads(line.strip())
    import datetime
    event_time = datetime.datetime.fromisoformat(event['timestamp'].replace('Z', '+00:00'))
    if event_time.timestamp() >= $since_epoch:
        print(json.dumps(event, indent=2))
\""
    fi
    
    # Apply limit
    filter_cmd="$filter_cmd | head -$limit"
    
    eval "$filter_cmd" "$event_log"
}

# Generate event timeline report
generate_event_timeline() {
    local milestone_id=$1
    local output_format=${2:-"text"}
    
    local event_log=".milestones/state/events/milestone-$milestone_id.jsonl"
    
    if [ ! -f "$event_log" ]; then
        echo "No events found for milestone: $milestone_id"
        return 0
    fi
    
    case "$output_format" in
        "text")
            echo "=== Milestone Event Timeline: $milestone_id ==="
            python3 -c "
import json, sys
events = []
with open('$event_log') as f:
    for line in f:
        events.append(json.loads(line.strip()))

for event in sorted(events, key=lambda x: x['timestamp']):
    print(f\"{event['timestamp']} [{event['event_type']}] {event.get('data', {})}\")
"
            ;;
        "json")
            python3 -c "
import json, sys
events = []
with open('$event_log') as f:
    for line in f:
        events.append(json.loads(line.strip()))

print(json.dumps(sorted(events, key=lambda x: x['timestamp']), indent=2))
"
            ;;
        *)
            echo "ERROR: Unsupported output format: $output_format"
            return 1
            ;;
    esac
}
```

## State Recovery and Backup

```bash
# Recover milestone state from backup
recover_milestone_state() {
    local milestone_id=$1
    local backup_dir=".milestones/state/backups"
    local state_file=".milestones/state/active/$milestone_id.json"
    
    echo "Attempting to recover milestone state for: $milestone_id"
    
    # Find latest backup
    local latest_backup=$(ls -t "$backup_dir/$milestone_id"-*.json 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        echo "ERROR: No backup found for milestone: $milestone_id"
        return 1
    fi
    
    echo "Using backup: $latest_backup"
    
    # Validate backup integrity
    if ! python3 -m json.tool "$latest_backup" >/dev/null 2>&1; then
        echo "ERROR: Backup file is also corrupted"
        return 1
    fi
    
    # Acquire lock
    if ! acquire_state_lock "$milestone_id"; then
        return 1
    fi
    
    # Move corrupted file aside
    if [ -f "$state_file" ]; then
        mv "$state_file" "$state_file.corrupted.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Restore from backup
    cp "$latest_backup" "$state_file"
    
    # Log recovery event
    log_milestone_event "$milestone_id" "state_recovered" "{\"backup_file\": \"$latest_backup\"}"
    
    # Release lock
    release_state_lock "$milestone_id"
    
    echo "State recovered successfully from: $latest_backup"
}

# Create state checkpoint
create_state_checkpoint() {
    local milestone_id=$1
    local checkpoint_name=${2:-"manual-$(date +%Y%m%d-%H%M%S)"}
    local state_file=".milestones/state/active/$milestone_id.json"
    local checkpoint_file=".milestones/state/backups/$milestone_id-checkpoint-$checkpoint_name.json"
    
    if [ ! -f "$state_file" ]; then
        echo "ERROR: No active state file found for milestone: $milestone_id"
        return 1
    fi
    
    cp "$state_file" "$checkpoint_file"
    log_milestone_event "$milestone_id" "checkpoint_created" "{\"checkpoint_name\": \"$checkpoint_name\", \"checkpoint_file\": \"$checkpoint_file\"}"
    
    echo "Checkpoint created: $checkpoint_name"
}

# Restore from specific checkpoint
restore_from_checkpoint() {
    local milestone_id=$1
    local checkpoint_name=$2
    local checkpoint_file=".milestones/state/backups/$milestone_id-checkpoint-$checkpoint_name.json"
    local state_file=".milestones/state/active/$milestone_id.json"
    
    if [ ! -f "$checkpoint_file" ]; then
        echo "ERROR: Checkpoint not found: $checkpoint_name"
        return 1
    fi
    
    # Acquire lock
    if ! acquire_state_lock "$milestone_id"; then
        return 1
    fi
    
    # Create backup of current state before restore
    create_state_checkpoint "$milestone_id" "pre-restore-$(date +%Y%m%d-%H%M%S)"
    
    # Restore checkpoint
    cp "$checkpoint_file" "$state_file"
    
    # Log restore event
    log_milestone_event "$milestone_id" "state_restored" "{\"checkpoint_name\": \"$checkpoint_name\"}"
    
    # Release lock
    release_state_lock "$milestone_id"
    
    echo "State restored from checkpoint: $checkpoint_name"
}
```

## Session Management

```bash
# Create new session
create_milestone_session() {
    local milestone_id=$1
    local session_id="session-$(date +%Y%m%d-%H%M%S)-$$"
    local session_file=".milestones/state/sessions/$session_id.json"
    
    mkdir -p ".milestones/state/sessions"
    
    cat > "$session_file" << EOF
{
  "session_id": "$session_id",
  "milestone_id": "$milestone_id",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "pid": $$,
  "user": "$(whoami)",
  "working_directory": "$(pwd)",
  "git_branch": "$(git branch --show-current 2>/dev/null || echo 'none')",
  "status": "active"
}
EOF
    
    # Set as current session
    echo "$session_id" > ".milestones/state/.current_session"
    
    log_milestone_event "$milestone_id" "session_created" "{\"session_id\": \"$session_id\"}" "$session_id"
    
    echo "$session_id"
}

# Get current session ID
get_current_session_id() {
    if [ -f ".milestones/state/.current_session" ]; then
        cat ".milestones/state/.current_session"
    else
        echo "no-session"
    fi
}

# End milestone session
end_milestone_session() {
    local session_id=${1:-"$(get_current_session_id)"}
    local session_file=".milestones/state/sessions/$session_id.json"
    
    if [ -f "$session_file" ]; then
        # Update session status
        python3 -c "
import json
with open('$session_file', 'r') as f:
    session = json.load(f)
session['status'] = 'completed'
session['ended_at'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
with open('$session_file', 'w') as f:
    json.dump(session, f, indent=2)
"
        
        # Clear current session
        rm -f ".milestones/state/.current_session"
        
        local milestone_id=$(python3 -c "import json; print(json.load(open('$session_file'))['milestone_id'])")
        log_milestone_event "$milestone_id" "session_ended" "{\"session_id\": \"$session_id\"}" "$session_id"
        
        echo "Session ended: $session_id"
    fi
}

# Clean up old sessions and backups
cleanup_milestone_state() {
    local milestone_id=$1
    local retention_days=${2:-7}
    
    echo "Cleaning up milestone state older than $retention_days days..."
    
    # Clean old backups
    find ".milestones/state/backups" -name "$milestone_id-*.json" -mtime +$retention_days -delete 2>/dev/null
    
    # Clean old sessions
    find ".milestones/state/sessions" -name "*.json" -mtime +$retention_days -exec python3 -c "
import json, sys, os
try:
    with open(sys.argv[1]) as f:
        session = json.load(f)
    if session.get('milestone_id') == '$milestone_id' and session.get('status') == 'completed':
        os.remove(sys.argv[1])
        print(f'Removed old session: {session[\"session_id\"]}')
except:
    pass
" {} \;
    
    # Compress old event logs
    local event_log=".milestones/state/events/milestone-$milestone_id.jsonl"
    if [ -f "$event_log" ]; then
        local temp_log="$event_log.tmp"
        local cutoff_date=$(date -d "$retention_days days ago" +%Y-%m-%d 2>/dev/null || date -j -v-${retention_days}d +%Y-%m-%d)
        
        python3 -c "
import json, sys
with open('$event_log') as f:
    for line in f:
        event = json.loads(line.strip())
        if event['timestamp'].split('T')[0] >= '$cutoff_date':
            print(json.dumps(event))
" > "$temp_log"
        
        mv "$temp_log" "$event_log"
    fi
    
    log_milestone_event "$milestone_id" "state_cleaned" "{\"retention_days\": $retention_days}"
    
    echo "State cleanup completed"
}
```

This state management system provides robust, atomic operations for milestone state persistence with comprehensive event logging and recovery capabilities.