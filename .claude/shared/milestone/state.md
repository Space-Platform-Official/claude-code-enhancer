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

## Reactive Status Updates

```bash
# Automatically update milestone status when events occur
update_milestone_status_reactive() {
    local milestone_id=$1
    local trigger_event=$2
    local event_data=$3
    
    # Calculate new status based on current milestone state
    local milestone_file=".milestones/active/$milestone_id.yaml"
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found: $milestone_file"
        return 1
    fi
    
    # Calculate progress percentage from completed tasks
    local total_tasks=$(yq e '.tasks | length' "$milestone_file" 2>/dev/null || echo "0")
    local completed_tasks=$(yq e '.tasks[] | select(.status == "completed") | .id' "$milestone_file" 2>/dev/null | wc -l)
    
    local progress_percentage=0
    if [ "$total_tasks" -gt 0 ]; then
        progress_percentage=$((completed_tasks * 100 / total_tasks))
    fi
    
    # Determine milestone status based on progress
    local milestone_status="planned"
    if [ "$progress_percentage" -eq 100 ]; then
        milestone_status="completed"
    elif [ "$progress_percentage" -gt 0 ]; then
        milestone_status="in_progress"
    fi
    
    # Update milestone file atomically
    acquire_state_lock "$milestone_id"
    
    yq e '.status = "'$milestone_status'"' -i "$milestone_file"
    yq e '.progress.percentage = '$progress_percentage -i "$milestone_file"
    yq e '.progress.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
    
    release_state_lock "$milestone_id"
    
    # Log the status update event
    log_milestone_event "$milestone_id" "status_updated" "{\"old_status\": \"$previous_status\", \"new_status\": \"$milestone_status\", \"progress_percentage\": $progress_percentage, \"trigger_event\": \"$trigger_event\"}"
    
    echo "✅ Milestone status updated: $milestone_id → $milestone_status ($progress_percentage%)"
}

# Watch for milestone events and trigger reactive updates
watch_milestone_events_reactive() {
    local milestone_id=$1
    local event_log=".milestones/state/events/milestone-$milestone_id.jsonl"
    
    # Simple file watching using tail
    if [ -f "$event_log" ]; then
        tail -f "$event_log" | while read -r event_line; do
            if [ -n "$event_line" ]; then
                local event_type=$(echo "$event_line" | python3 -c "import json, sys; print(json.load(sys.stdin).get('event_type', ''))")
                
                # Trigger status updates for relevant events
                case "$event_type" in
                    "task_completed"|"task_started"|"milestone_modified")
                        update_milestone_status_reactive "$milestone_id" "$event_type" "$event_line"
                        ;;
                esac
            fi
        done
    fi
}

# Enhanced milestone event logging with automatic status triggers
log_milestone_event_reactive() {
    local milestone_id=$1
    local event_type=$2
    local event_data=$3
    local session_id=${4:-"$(get_current_session_id)"}
    
    # Log the event using existing function
    log_milestone_event "$milestone_id" "$event_type" "$event_data" "$session_id"
    
    # Trigger automatic status update for relevant events
    case "$event_type" in
        "task_completed"|"task_started"|"milestone_modified"|"dependency_resolved")
            update_milestone_status_reactive "$milestone_id" "$event_type" "$event_data"
            ;;
    esac
}

# Simple milestone update with automatic status calculation
update_milestone_progress() {
    local milestone_id=$1
    local task_id=$2
    local new_status=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Update task status
    acquire_state_lock "$milestone_id"
    yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "'$new_status'"' -i "$milestone_file"
    release_state_lock "$milestone_id"
    
    # Log event and trigger reactive status update
    log_milestone_event_reactive "$milestone_id" "task_status_changed" "{\"task_id\": \"$task_id\", \"new_status\": \"$new_status\"}"
    
    echo "Task updated: $task_id → $new_status"
}

# Complete a milestone task and trigger status update
complete_milestone_task() {
    local milestone_id=$1
    local task_id=$2
    
    update_milestone_progress "$milestone_id" "$task_id" "completed"
    
    # Check if milestone is now complete
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local total_tasks=$(yq e '.tasks | length' "$milestone_file")
    local completed_tasks=$(yq e '.tasks[] | select(.status == "completed") | .id' "$milestone_file" | wc -l)
    
    if [ "$completed_tasks" -eq "$total_tasks" ]; then
        log_milestone_event_reactive "$milestone_id" "milestone_completed" "{\"total_tasks\": $total_tasks}"
        echo "🎉 Milestone completed: $milestone_id"
    fi
}
```

## Kiro Workflow Phase Management

```bash
# Update kiro phase status with approval gate support
update_kiro_phase_status() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    local new_status=$4
    local approval_data=${5:-"{}"}
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    if [ ! -f "$milestone_file" ]; then
        echo "ERROR: Milestone file not found: $milestone_file"
        return 1
    fi
    
    acquire_state_lock "$milestone_id"
    
    # Update phase status
    yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.status) = "'$new_status'"' -i "$milestone_file"
    
    # Set timestamp based on status
    case "$new_status" in
        "in_progress")
            yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.started_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
            ;;
        "completed")
            yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.completed_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
            ;;
        "approved")
            yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.approved_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
            ;;
        "blocked"|"waiting_approval")
            yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.blocked_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
            ;;
    esac
    
    release_state_lock "$milestone_id"
    
    # Log phase status change event
    log_milestone_event_reactive "$milestone_id" "kiro_phase_updated" "{\"task_id\": \"$task_id\", \"phase\": \"$phase_name\", \"status\": \"$new_status\", \"approval_data\": $approval_data}"
    
    echo "✅ Kiro phase updated: $task_id.$phase_name → $new_status"
}

# Transition between kiro phases with approval gate checking
transition_kiro_phase() {
    local milestone_id=$1
    local task_id=$2
    local from_phase=$3
    local to_phase=$4
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Check if task has kiro workflow enabled
    local kiro_enabled=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.enabled' "$milestone_file" 2>/dev/null)
    if [ "$kiro_enabled" != "true" ]; then
        echo "Kiro workflow not enabled for task: $task_id"
        return 1
    fi
    
    # Check if approval is required for this transition
    local approval_required=$(check_kiro_approval_required "$milestone_id" "$task_id" "$from_phase" "$to_phase")
    
    if [ "$approval_required" = "true" ]; then
        echo "⏳ Approval required for transition: $from_phase → $to_phase"
        request_kiro_phase_approval "$milestone_id" "$task_id" "$from_phase" "$to_phase"
        return 0
    fi
    
    # Update current phase
    acquire_state_lock "$milestone_id"
    yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.current_phase) = "'$to_phase'"' -i "$milestone_file"
    release_state_lock "$milestone_id"
    
    # Start new phase
    update_kiro_phase_status "$milestone_id" "$task_id" "$to_phase" "in_progress"
    
    log_milestone_event_reactive "$milestone_id" "kiro_phase_transition" "{\"task_id\": \"$task_id\", \"from_phase\": \"$from_phase\", \"to_phase\": \"$to_phase\", \"transition_type\": \"automatic\"}"
    
    echo "✅ Phase transition: $from_phase → $to_phase"
}

# Check if approval is required for phase transition
check_kiro_approval_required() {
    local milestone_id=$1
    local task_id=$2
    local from_phase=$3
    local to_phase=$4
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Check task-specific approval requirements
    local task_approval=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$from_phase'.approval_required' "$milestone_file" 2>/dev/null)
    
    # Check milestone-level approval configuration
    local milestone_approval=$(yq e '.kiro_configuration.approval_gates.'$from_phase'_to_'$to_phase'.required' "$milestone_file" 2>/dev/null)
    
    # Default approval requirements for standard transitions
    case "$from_phase" in
        "design")
            echo "${task_approval:-${milestone_approval:-true}}"
            ;;
        "spec")
            echo "${task_approval:-${milestone_approval:-true}}"
            ;;
        "task")
            echo "${task_approval:-${milestone_approval:-false}}"
            ;;
        *)
            echo "${task_approval:-${milestone_approval:-false}}"
            ;;
    esac
}

# Request approval for kiro phase transition
request_kiro_phase_approval() {
    local milestone_id=$1
    local task_id=$2
    local from_phase=$3
    local to_phase=$4
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local approval_id="approval-$milestone_id-$task_id-$from_phase-$to_phase"
    local approval_file=".milestones/approvals/$approval_id.yaml"
    
    mkdir -p ".milestones/approvals"
    
    # Extract approval requirements from milestone configuration
    local approvers=$(yq e '.kiro_configuration.approval_gates.'$from_phase'_to_'$to_phase'.approvers[]' "$milestone_file" 2>/dev/null)
    local criteria=$(yq e '.kiro_configuration.approval_gates.'$from_phase'_to_'$to_phase'.criteria[]' "$milestone_file" 2>/dev/null)
    
    # Get phase deliverables for review
    local deliverables=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$from_phase'.deliverables[]' "$milestone_file" 2>/dev/null)
    
    # Create approval request
    cat > "$approval_file" << EOF
approval_request:
  id: "$approval_id"
  milestone_id: "$milestone_id"
  task_id: "$task_id"
  transition: "$from_phase → $to_phase"
  requested_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  status: "pending"
  
approvers:
$(echo "$approvers" | sed 's/^/  - role: /' | sed 's/$/ 
    status: pending
    contacted: false/')

approval_criteria:
$(echo "$criteria" | sed 's/^/  - /')

phase_deliverables:
$(echo "$deliverables" | sed 's/^/  - /')

phase_summary:
  phase: "$from_phase"
  started_at: "$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$from_phase'.started_at' "$milestone_file")"
  completed_at: "$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$from_phase'.completed_at' "$milestone_file")"
  deliverables_path: ".milestones/deliverables/$task_id/$from_phase/"
EOF
    
    # Update task status to waiting for approval
    update_kiro_phase_status "$milestone_id" "$task_id" "$from_phase" "waiting_approval"
    
    log_milestone_event_reactive "$milestone_id" "kiro_approval_requested" "{\"task_id\": \"$task_id\", \"transition\": \"$from_phase → $to_phase\", \"approval_file\": \"$approval_file\"}"
    
    echo "📋 Approval requested: $from_phase → $to_phase"
    echo "Approval file: $approval_file"
    echo "Deliverables for review: .milestones/deliverables/$task_id/$from_phase/"
}

# Process approval response for kiro phase transition
process_kiro_phase_approval() {
    local approval_file=$1
    local approver_role=$2
    local decision=$3  # "approved" or "rejected"
    local comments=${4:-""}
    
    if [ ! -f "$approval_file" ]; then
        echo "ERROR: Approval file not found: $approval_file"
        return 1
    fi
    
    local milestone_id=$(yq e '.approval_request.milestone_id' "$approval_file")
    local task_id=$(yq e '.approval_request.task_id' "$approval_file")
    local transition=$(yq e '.approval_request.transition' "$approval_file")
    
    # Update approver status
    acquire_state_lock "$milestone_id"
    yq e '(.approvers[] | select(.role == "'$approver_role'") | .status) = "'$decision'"' -i "$approval_file"
    yq e '(.approvers[] | select(.role == "'$approver_role'") | .decided_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$approval_file"
    yq e '(.approvers[] | select(.role == "'$approver_role'") | .contacted) = true' -i "$approval_file"
    
    if [ -n "$comments" ]; then
        yq e '(.approvers[] | select(.role == "'$approver_role'") | .comments) = "'$comments'"' -i "$approval_file"
    fi
    release_state_lock "$milestone_id"
    
    # Check if all approvers have decided
    local pending_approvers=$(yq e '.approvers[] | select(.status == "pending") | .role' "$approval_file" | wc -l)
    
    if [ "$pending_approvers" -eq 0 ]; then
        # All approvers have decided
        local rejected_count=$(yq e '.approvers[] | select(.status == "rejected") | .role' "$approval_file" | wc -l)
        
        if [ "$rejected_count" -gt 0 ]; then
            # Approval rejected
            yq e '.approval_request.status = "rejected"' -i "$approval_file"
            yq e '.approval_request.decided_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$approval_file"
            
            local from_phase=$(echo "$transition" | cut -d' ' -f1)
            update_kiro_phase_status "$milestone_id" "$task_id" "$from_phase" "blocked" "{\"reason\": \"approval_rejected\"}"
            
            log_milestone_event_reactive "$milestone_id" "kiro_approval_rejected" "{\"task_id\": \"$task_id\", \"transition\": \"$transition\", \"rejected_by\": \"$approver_role\"}"
            echo "❌ Approval rejected: $transition"
        else
            # Approval granted
            yq e '.approval_request.status = "approved"' -i "$approval_file"
            yq e '.approval_request.decided_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$approval_file"
            
            local from_phase=$(echo "$transition" | cut -d' ' -f1)
            local to_phase=$(echo "$transition" | cut -d' ' -f3)
            
            update_kiro_phase_status "$milestone_id" "$task_id" "$from_phase" "approved"
            transition_kiro_phase "$milestone_id" "$task_id" "$from_phase" "$to_phase"
            
            log_milestone_event_reactive "$milestone_id" "kiro_approval_granted" "{\"task_id\": \"$task_id\", \"transition\": \"$transition\"}"
            echo "✅ Approval granted: $transition"
        fi
    else
        echo "⏳ Waiting for $pending_approvers more approver(s)"
    fi
}

# Calculate task progress based on kiro phase completion
calculate_kiro_task_progress() {
    local milestone_id=$1
    local task_id=$2
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Check if task has kiro workflow enabled
    local kiro_enabled=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.enabled' "$milestone_file" 2>/dev/null)
    if [ "$kiro_enabled" != "true" ]; then
        # Fall back to standard task progress calculation
        local task_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .status' "$milestone_file")
        case "$task_status" in
            "completed") echo "100" ;;
            "in_progress") echo "50" ;;
            *) echo "0" ;;
        esac
        return
    fi
    
    # Get phase weights from milestone configuration
    local design_weight=$(yq e '.kiro_configuration.phase_weights.design' "$milestone_file" 2>/dev/null || echo "15")
    local spec_weight=$(yq e '.kiro_configuration.phase_weights.spec' "$milestone_file" 2>/dev/null || echo "25")
    local task_weight=$(yq e '.kiro_configuration.phase_weights.task' "$milestone_file" 2>/dev/null || echo "20")
    local execute_weight=$(yq e '.kiro_configuration.phase_weights.execute' "$milestone_file" 2>/dev/null || echo "40")
    
    local total_progress=0
    
    # Calculate progress for each phase
    for phase in design spec task execute; do
        local phase_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase'.status' "$milestone_file")
        local phase_progress=0
        
        case "$phase_status" in
            "completed"|"approved")
                phase_progress=100
                ;;
            "in_progress")
                phase_progress=60
                ;;
            "waiting_approval")
                phase_progress=90
                ;;
            "blocked")
                phase_progress=30
                ;;
            *)
                phase_progress=0
                ;;
        esac
        
        # Apply weight to phase progress
        case "$phase" in
            "design")
                total_progress=$((total_progress + (phase_progress * design_weight / 100)))
                ;;
            "spec")
                total_progress=$((total_progress + (phase_progress * spec_weight / 100)))
                ;;
            "task")
                total_progress=$((total_progress + (phase_progress * task_weight / 100)))
                ;;
            "execute")
                total_progress=$((total_progress + (phase_progress * execute_weight / 100)))
                ;;
        esac
    done
    
    echo "$total_progress"
}

# Enhanced milestone progress calculation with kiro phase support
calculate_milestone_progress_with_kiro() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    local task_ids=$(yq e '.tasks[].id' "$milestone_file")
    local total_tasks=$(echo "$task_ids" | wc -l)
    local total_progress=0
    
    for task_id in $task_ids; do
        local task_progress=$(calculate_kiro_task_progress "$milestone_id" "$task_id")
        total_progress=$((total_progress + task_progress))
    done
    
    local milestone_progress=$((total_progress / total_tasks))
    echo "$milestone_progress"
}

# Get next kiro phase in progression
get_next_kiro_phase() {
    local current_phase=$1
    
    case "$current_phase" in
        "design") echo "spec" ;;
        "spec") echo "task" ;;
        "task") echo "execute" ;;
        "execute") echo "" ;;  # No next phase
        *) echo "" ;;
    esac
}

# Check if kiro phase is complete and ready for transition
check_kiro_phase_ready_for_transition() {
    local milestone_id=$1
    local task_id=$2
    local phase_name=$3
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local phase_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase_name'.status' "$milestone_file")
    
    case "$phase_status" in
        "approved"|"completed")
            local next_phase=$(get_next_kiro_phase "$phase_name")
            if [ -n "$next_phase" ]; then
                echo "ready"
            else
                echo "task_complete"
            fi
            ;;
        *)
            echo "not_ready"
            ;;
    esac
}

# Auto-transition kiro phases when ready
auto_transition_kiro_phases() {
    local milestone_id=$1
    local task_id=$2
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local current_phase=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.current_phase' "$milestone_file")
    
    local transition_ready=$(check_kiro_phase_ready_for_transition "$milestone_id" "$task_id" "$current_phase")
    
    case "$transition_ready" in
        "ready")
            local next_phase=$(get_next_kiro_phase "$current_phase")
            echo "🔄 Auto-transitioning: $current_phase → $next_phase"
            transition_kiro_phase "$milestone_id" "$task_id" "$current_phase" "$next_phase"
            ;;
        "task_complete")
            echo "✅ All kiro phases completed for task: $task_id"
            complete_milestone_task "$milestone_id" "$task_id"
            ;;
        *)
            echo "⏳ Phase $current_phase not ready for transition"
            ;;
    esac
}

# Monitor kiro phase progressions and handle auto-transitions
monitor_kiro_phase_progressions() {
    local milestone_id=$1
    
    local milestone_file=".milestones/active/$milestone_id.yaml"
    local kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' "$milestone_file" 2>/dev/null)
    
    for task_id in $kiro_tasks; do
        auto_transition_kiro_phases "$milestone_id" "$task_id"
    done
}
```

This state management system provides robust, atomic operations for milestone state persistence with comprehensive event logging, recovery capabilities, automatic reactive status updates, and full kiro workflow phase management with approval gates.