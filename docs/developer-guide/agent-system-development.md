# Agent System Development Guide

Comprehensive guide for developing and coordinating multi-agent systems in the Claude Code Enhancer platform.

## Agent System Architecture

### Multi-Agent Coordination Philosophy

The Claude Code Enhancer employs a sophisticated multi-agent architecture based on **specialized agents working in parallel** rather than monolithic processing:

```
Multi-Agent Coordination Architecture
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Agent Coordination Engine                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐ │
│  │ Task Execution   │ │ Progress Monitor │ │ Git Integration │ │
│  │     Agent        │ │     Agent        │ │     Agent       │ │
│  └────────┬────────┘ └────────┬────────┘ └────────┬────────┘ │
│            │                   │                   │           │
│  ┌────────┴───────────────────┴───────────────────┴────────┐ │
│  │                Communication & Synchronization                    │ │
│  └────────┬────────────────────────────────────────────────────────────┘ │
│            │                                                           │
│  ┌────────┴────────────────────────────────────────────────────────────┐ │
│  │ Dependency Validator Agent      │ Blocker Detection Agent        │ │
│  └─────────────────────────────────┘ └────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Core Agent Types

#### 1. Task Execution Agent

**Purpose**: Execute primary development tasks and operations

**Capabilities**:
- Code modification and file operations
- Command execution and process management
- Build and deployment operations
- Test execution and validation

**State Management**:
- Task queue with priority scheduling
- Execution context and environment
- Progress tracking and metrics
- Error handling and recovery

#### 2. Progress Monitoring Agent

**Purpose**: Real-time progress tracking and reporting

**Capabilities**:
- Progress calculation and ETA estimation
- Bottleneck detection and analysis
- Performance metrics collection
- User notification and reporting

**State Management**:
- Progress metrics and timing data
- Performance statistics and trends
- Alert thresholds and notifications
- Reporting configuration and output

#### 3. Git Integration Agent

**Purpose**: Git operations and repository state management

**Capabilities**:
- Branch management and switching
- Commit creation and message generation
- Conflict detection and resolution
- Remote synchronization and push/pull

**State Management**:
- Repository status and branch tracking
- Change detection and staging
- Conflict resolution strategies
- Remote repository coordination

#### 4. Dependency Validation Agent

**Purpose**: Dependency tracking and validation

**Capabilities**:
- External dependency verification
- Version compatibility checking
- Security vulnerability scanning
- Performance impact analysis

**State Management**:
- Dependency graph and relationships
- Version tracking and compatibility
- Security scan results and alerts
- Performance impact metrics

#### 5. Blocker Detection Agent

**Purpose**: Identify and resolve operational blockers

**Capabilities**:
- Resource constraint detection
- Permission and access verification
- Network connectivity monitoring
- System health assessment

**State Management**:
- System resource monitoring
- Permission and access tracking
- Network status and connectivity
- Health check results and alerts

## Agent Development Framework

### Agent Interface Specification

All agents must implement the standard agent interface:

```bash
# Agent Interface Definition
# File: _shared/agent-interface.md

# Required functions for all agents
agent_interface_functions=(
    "initialize_agent"
    "execute_agent_task"
    "report_agent_status"
    "handle_agent_message"
    "cleanup_agent"
    "get_agent_capabilities"
    "validate_agent_config"
)

# Agent initialization
initialize_agent() {
    local agent_id="$1"
    local agent_config="$2"
    
    # Validate configuration
    if ! validate_agent_config "$agent_config"; then
        echo "Error: Invalid agent configuration" >&2
        return 1
    fi
    
    # Set up agent environment
    setup_agent_environment "$agent_id" "$agent_config"
    
    # Initialize agent state
    initialize_agent_state "$agent_id"
    
    # Register with coordination engine
    register_agent "$agent_id" "$(get_agent_capabilities)"
    
    echo "Agent initialized: $agent_id"
}

# Agent task execution
execute_agent_task() {
    local agent_id="$1"
    local task_spec="$2"
    
    # Parse task specification
    local task_type=$(parse_task_type "$task_spec")
    local task_params=$(parse_task_params "$task_spec")
    
    # Execute task based on type
    case "$task_type" in
        "execute")
            execute_task "$task_params"
            ;;
        "monitor")
            monitor_task "$task_params"
            ;;
        "validate")
            validate_task "$task_params"
            ;;
        *)
            echo "Error: Unknown task type: $task_type" >&2
            return 1
            ;;
    esac
    
    # Report task completion
    report_task_completion "$agent_id" "$task_spec"
}

# Agent status reporting
report_agent_status() {
    local agent_id="$1"
    
    # Collect agent metrics
    local status=$(collect_agent_status "$agent_id")
    local progress=$(calculate_agent_progress "$agent_id")
    local health=$(check_agent_health "$agent_id")
    
    # Format status report
    cat << EOF
{
    "agent_id": "$agent_id",
    "status": "$status",
    "progress": $progress,
    "health": "$health",
    "timestamp": "$(date -Iseconds)"
}
EOF
}

# Agent message handling
handle_agent_message() {
    local agent_id="$1"
    local message_type="$2"
    local message_data="$3"
    
    case "$message_type" in
        "coordinate")
            handle_coordination_message "$agent_id" "$message_data"
            ;;
        "status_request")
            handle_status_request "$agent_id" "$message_data"
            ;;
        "task_assignment")
            handle_task_assignment "$agent_id" "$message_data"
            ;;
        "shutdown")
            handle_shutdown_message "$agent_id" "$message_data"
            ;;
        *)
            echo "Error: Unknown message type: $message_type" >&2
            return 1
            ;;
    esac
}

# Agent cleanup
cleanup_agent() {
    local agent_id="$1"
    
    # Save agent state
    save_agent_state "$agent_id"
    
    # Clean up resources
    cleanup_agent_resources "$agent_id"
    
    # Unregister from coordination engine
    unregister_agent "$agent_id"
    
    echo "Agent cleaned up: $agent_id"
}

# Agent capabilities
get_agent_capabilities() {
    # Override in specific agent implementations
    cat << EOF
{
    "agent_type": "base",
    "capabilities": ["basic_operations"],
    "resource_requirements": {
        "cpu": "low",
        "memory": "low",
        "disk": "minimal"
    }
}
EOF
}

# Configuration validation
validate_agent_config() {
    local config="$1"
    
    # Basic configuration validation
    if [[ -z "$config" ]]; then
        echo "Error: Empty configuration" >&2
        return 1
    fi
    
    # Validate JSON format if applicable
    if [[ "$config" =~ ^\{.*\}$ ]]; then
        if ! echo "$config" | python -m json.tool >/dev/null 2>&1; then
            echo "Error: Invalid JSON configuration" >&2
            return 1
        fi
    fi
    
    return 0
}
```

### Agent Implementation Templates

#### Task Execution Agent Implementation

```bash
# Task Execution Agent
# File: agents/task-execution-agent.md

source _shared/agent-interface.md

# Agent-specific capabilities
get_agent_capabilities() {
    cat << EOF
{
    "agent_type": "task_executor",
    "capabilities": [
        "file_operations",
        "command_execution",
        "build_operations",
        "test_execution"
    ],
    "resource_requirements": {
        "cpu": "medium",
        "memory": "medium",
        "disk": "moderate"
    },
    "parallel_tasks": 4
}
EOF
}

# Task execution implementation
execute_task() {
    local task_params="$1"
    
    # Parse task parameters
    local operation=$(echo "$task_params" | jq -r '.operation')
    local target=$(echo "$task_params" | jq -r '.target')
    local options=$(echo "$task_params" | jq -r '.options')
    
    case "$operation" in
        "file_modify")
            execute_file_modification "$target" "$options"
            ;;
        "command_run")
            execute_command_operation "$target" "$options"
            ;;
        "build_project")
            execute_build_operation "$target" "$options"
            ;;
        "run_tests")
            execute_test_operation "$target" "$options"
            ;;
        *)
            echo "Error: Unknown operation: $operation" >&2
            return 1
            ;;
    esac
}

# File modification operations
execute_file_modification() {
    local target="$1"
    local options="$2"
    
    # Parse modification options
    local action=$(echo "$options" | jq -r '.action')
    local content=$(echo "$options" | jq -r '.content')
    
    case "$action" in
        "create")
            create_file "$target" "$content"
            ;;
        "modify")
            modify_file "$target" "$content"
            ;;
        "delete")
            delete_file "$target"
            ;;
        *)
            echo "Error: Unknown file action: $action" >&2
            return 1
            ;;
    esac
    
    # Report progress
    report_task_progress "file_modify" "$target" "completed"
}

# Command execution operations
execute_command_operation() {
    local command="$1"
    local options="$2"
    
    # Parse command options
    local timeout=$(echo "$options" | jq -r '.timeout // 300')
    local working_dir=$(echo "$options" | jq -r '.working_dir // "."')
    local environment=$(echo "$options" | jq -r '.environment // {}')
    
    # Set up execution environment
    local original_dir=$(pwd)
    cd "$working_dir"
    
    # Set environment variables
    while IFS= read -r env_var; do
        if [[ -n "$env_var" ]]; then
            export "$env_var"
        fi
    done < <(echo "$environment" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
    
    # Execute command with timeout
    if timeout "$timeout" bash -c "$command"; then
        report_task_progress "command_run" "$command" "completed"
    else
        report_task_progress "command_run" "$command" "failed"
        cd "$original_dir"
        return 1
    fi
    
    cd "$original_dir"
}

# Build operations
execute_build_operation() {
    local target="$1"
    local options="$2"
    
    # Detect build system
    local build_system=$(detect_build_system "$target")
    
    case "$build_system" in
        "npm")
            execute_npm_build "$target" "$options"
            ;;
        "python")
            execute_python_build "$target" "$options"
            ;;
        "go")
            execute_go_build "$target" "$options"
            ;;
        "rust")
            execute_rust_build "$target" "$options"
            ;;
        *)
            echo "Error: Unknown build system: $build_system" >&2
            return 1
            ;;
    esac
}

# Test execution
execute_test_operation() {
    local target="$1"
    local options="$2"
    
    # Parse test options
    local test_type=$(echo "$options" | jq -r '.type // "unit"')
    local test_pattern=$(echo "$options" | jq -r '.pattern // "**/*.test.*"')
    local coverage=$(echo "$options" | jq -r '.coverage // false')
    
    case "$test_type" in
        "unit")
            execute_unit_tests "$target" "$test_pattern" "$coverage"
            ;;
        "integration")
            execute_integration_tests "$target" "$test_pattern" "$coverage"
            ;;
        "e2e")
            execute_e2e_tests "$target" "$test_pattern" "$coverage"
            ;;
        *)
            echo "Error: Unknown test type: $test_type" >&2
            return 1
            ;;
    esac
}
```

#### Progress Monitoring Agent Implementation

```bash
# Progress Monitoring Agent
# File: agents/progress-monitoring-agent.md

source _shared/agent-interface.md

# Agent-specific capabilities
get_agent_capabilities() {
    cat << EOF
{
    "agent_type": "progress_monitor",
    "capabilities": [
        "progress_tracking",
        "eta_calculation",
        "bottleneck_detection",
        "performance_monitoring"
    ],
    "resource_requirements": {
        "cpu": "low",
        "memory": "low",
        "disk": "minimal"
    },
    "update_interval": 1
}
EOF
}

# Progress monitoring implementation
monitor_task() {
    local task_params="$1"
    
    # Parse monitoring parameters
    local operation_id=$(echo "$task_params" | jq -r '.operation_id')
    local update_interval=$(echo "$task_params" | jq -r '.update_interval // 1')
    local total_steps=$(echo "$task_params" | jq -r '.total_steps')
    
    # Initialize progress tracking
    initialize_progress_tracking "$operation_id" "$total_steps"
    
    # Start monitoring loop
    while is_operation_active "$operation_id"; do
        # Collect progress data
        local current_progress=$(get_current_progress "$operation_id")
        local performance_metrics=$(collect_performance_metrics "$operation_id")
        
        # Calculate ETA
        local eta=$(calculate_eta "$operation_id" "$current_progress" "$total_steps")
        
        # Detect bottlenecks
        local bottlenecks=$(detect_bottlenecks "$operation_id" "$performance_metrics")
        
        # Update progress display
        update_progress_display "$operation_id" "$current_progress" "$total_steps" "$eta" "$bottlenecks"
        
        # Report progress to coordination engine
        report_progress_update "$operation_id" "$current_progress" "$eta"
        
        sleep "$update_interval"
    done
    
    # Final progress report
    finalize_progress_tracking "$operation_id"
}

# Progress calculation
calculate_eta() {
    local operation_id="$1"
    local current_progress="$2"
    local total_steps="$3"
    
    # Get timing data
    local start_time=$(get_operation_start_time "$operation_id")
    local current_time=$(date +%s)
    local elapsed_time=$((current_time - start_time))
    
    # Calculate progress rate
    if [[ $current_progress -gt 0 ]]; then
        local progress_rate=$(echo "scale=2; $current_progress / $elapsed_time" | bc)
        local remaining_steps=$((total_steps - current_progress))
        local eta_seconds=$(echo "scale=0; $remaining_steps / $progress_rate" | bc)
        
        format_duration "$eta_seconds"
    else
        echo "calculating..."
    fi
}

# Bottleneck detection
detect_bottlenecks() {
    local operation_id="$1"
    local performance_metrics="$2"
    
    local bottlenecks=()
    
    # CPU bottleneck detection
    local cpu_usage=$(echo "$performance_metrics" | jq -r '.cpu_usage')
    if (( $(echo "$cpu_usage > 90" | bc -l) )); then
        bottlenecks+=("high_cpu_usage")
    fi
    
    # Memory bottleneck detection
    local memory_usage=$(echo "$performance_metrics" | jq -r '.memory_usage')
    if (( $(echo "$memory_usage > 85" | bc -l) )); then
        bottlenecks+=("high_memory_usage")
    fi
    
    # I/O bottleneck detection
    local io_wait=$(echo "$performance_metrics" | jq -r '.io_wait')
    if (( $(echo "$io_wait > 50" | bc -l) )); then
        bottlenecks+=("high_io_wait")
    fi
    
    # Network bottleneck detection
    local network_latency=$(echo "$performance_metrics" | jq -r '.network_latency')
    if (( $(echo "$network_latency > 1000" | bc -l) )); then
        bottlenecks+=("high_network_latency")
    fi
    
    # Return detected bottlenecks
    printf '%s\n' "${bottlenecks[@]}"
}

# Performance metrics collection
collect_performance_metrics() {
    local operation_id="$1"
    
    # System metrics
    local cpu_usage=$(get_cpu_usage)
    local memory_usage=$(get_memory_usage)
    local disk_usage=$(get_disk_usage)
    local io_wait=$(get_io_wait)
    
    # Network metrics
    local network_latency=$(get_network_latency)
    local network_throughput=$(get_network_throughput)
    
    # Process-specific metrics
    local process_count=$(get_process_count "$operation_id")
    local thread_count=$(get_thread_count "$operation_id")
    
    # Format metrics as JSON
    cat << EOF
{
    "cpu_usage": $cpu_usage,
    "memory_usage": $memory_usage,
    "disk_usage": $disk_usage,
    "io_wait": $io_wait,
    "network_latency": $network_latency,
    "network_throughput": $network_throughput,
    "process_count": $process_count,
    "thread_count": $thread_count,
    "timestamp": "$(date -Iseconds)"
}
EOF
}
```

## Agent Coordination Patterns

### Event-Driven Coordination

Agents communicate through a sophisticated event system:

```bash
# Event-driven coordination system
# File: _shared/agent-coordination.md

# Event types
declare -A EVENT_TYPES=(
    ["TASK_STARTED"]="task_lifecycle"
    ["TASK_COMPLETED"]="task_lifecycle"
    ["TASK_FAILED"]="task_lifecycle"
    ["PROGRESS_UPDATE"]="progress"
    ["BOTTLENECK_DETECTED"]="performance"
    ["ERROR_OCCURRED"]="error_handling"
    ["COORDINATION_REQUEST"]="coordination"
    ["STATUS_REQUEST"]="status"
    ["SHUTDOWN_REQUEST"]="lifecycle"
)

# Event publishing
publish_event() {
    local event_type="$1"
    local event_data="$2"
    local event_source="$3"
    
    # Validate event type
    if [[ -z "${EVENT_TYPES[$event_type]}" ]]; then
        echo "Error: Unknown event type: $event_type" >&2
        return 1
    fi
    
    # Create event structure
    local event_id="$(generate_event_id)"
    local timestamp="$(date -Iseconds)"
    
    local event_json=$(cat << EOF
{
    "event_id": "$event_id",
    "event_type": "$event_type",
    "event_category": "${EVENT_TYPES[$event_type]}",
    "event_data": $event_data,
    "event_source": "$event_source",
    "timestamp": "$timestamp"
}
EOF
    )
    
    # Publish to event queue
    publish_to_event_queue "$event_json"
    
    # Notify subscribers
    notify_event_subscribers "$event_type" "$event_json"
}

# Event subscription
subscribe_to_events() {
    local agent_id="$1"
    local event_types="$2"  # JSON array of event types
    
    # Register subscription
    register_event_subscription "$agent_id" "$event_types"
    
    # Start event listener
    start_event_listener "$agent_id" &
    local listener_pid=$!
    
    # Store listener PID for cleanup
    store_listener_pid "$agent_id" "$listener_pid"
}

# Event listener
start_event_listener() {
    local agent_id="$1"
    
    while is_agent_active "$agent_id"; do
        # Check for new events
        local events=$(get_pending_events "$agent_id")
        
        if [[ -n "$events" ]]; then
            # Process each event
            while IFS= read -r event; do
                process_agent_event "$agent_id" "$event"
            done <<< "$events"
        fi
        
        sleep 0.1  # Short polling interval
    done
}

# Event processing
process_agent_event() {
    local agent_id="$1"
    local event_json="$2"
    
    # Parse event
    local event_type=$(echo "$event_json" | jq -r '.event_type')
    local event_data=$(echo "$event_json" | jq -r '.event_data')
    local event_source=$(echo "$event_json" | jq -r '.event_source')
    
    # Handle event based on type
    case "$event_type" in
        "TASK_STARTED")
            handle_task_started_event "$agent_id" "$event_data"
            ;;
        "TASK_COMPLETED")
            handle_task_completed_event "$agent_id" "$event_data"
            ;;
        "TASK_FAILED")
            handle_task_failed_event "$agent_id" "$event_data"
            ;;
        "PROGRESS_UPDATE")
            handle_progress_update_event "$agent_id" "$event_data"
            ;;
        "BOTTLENECK_DETECTED")
            handle_bottleneck_detected_event "$agent_id" "$event_data"
            ;;
        "ERROR_OCCURRED")
            handle_error_occurred_event "$agent_id" "$event_data"
            ;;
        "COORDINATION_REQUEST")
            handle_coordination_request_event "$agent_id" "$event_data"
            ;;
        "STATUS_REQUEST")
            handle_status_request_event "$agent_id" "$event_data"
            ;;
        "SHUTDOWN_REQUEST")
            handle_shutdown_request_event "$agent_id" "$event_data"
            ;;
        *)
            echo "Warning: Unhandled event type: $event_type" >&2
            ;;
    esac
}
```

### State Synchronization

Agents maintain synchronized state through a shared state management system:

```bash
# State synchronization system
# File: _shared/agent-state-sync.md

# Shared state management
shared_state_dir=".claude/state/agents"
state_lock_dir=".claude/state/locks"

# Initialize shared state
initialize_shared_state() {
    local operation_id="$1"
    
    mkdir -p "$shared_state_dir/$operation_id"
    mkdir -p "$state_lock_dir"
    
    # Create operation state file
    cat > "$shared_state_dir/$operation_id/operation.json" << EOF
{
    "operation_id": "$operation_id",
    "status": "initializing",
    "start_time": "$(date -Iseconds)",
    "agents": {},
    "progress": {
        "current_step": 0,
        "total_steps": 0,
        "percentage": 0
    },
    "metrics": {
        "tasks_completed": 0,
        "tasks_failed": 0,
        "performance": {}
    }
}
EOF
}

# Update agent state
update_agent_state() {
    local operation_id="$1"
    local agent_id="$2"
    local state_data="$3"
    
    # Acquire state lock
    local lock_file="$state_lock_dir/$operation_id.lock"
    exec 200>"$lock_file"
    flock 200
    
    # Update state file
    local state_file="$shared_state_dir/$operation_id/operation.json"
    
    # Create temporary file for atomic update
    local temp_file="$state_file.tmp"
    
    # Update agent state in operation data
    jq --arg agent_id "$agent_id" --argjson state_data "$state_data" \
       '.agents[$agent_id] = $state_data | .updated = now | .updated_by = $agent_id' \
       "$state_file" > "$temp_file"
    
    # Atomic move
    mv "$temp_file" "$state_file"
    
    # Release lock
    flock -u 200
    exec 200>&-
}

# Get shared state
get_shared_state() {
    local operation_id="$1"
    local filter="${2:-.}"  # jq filter, default to entire state
    
    local state_file="$shared_state_dir/$operation_id/operation.json"
    
    if [[ -f "$state_file" ]]; then
        jq "$filter" "$state_file"
    else
        echo "null"
    fi
}

# Synchronize agent states
synchronize_agent_states() {
    local operation_id="$1"
    local source_agent="$2"
    local target_agents="$3"  # JSON array of agent IDs
    
    # Get source agent state
    local source_state=$(get_shared_state "$operation_id" ".agents.\"$source_agent\"")
    
    if [[ "$source_state" == "null" ]]; then
        echo "Error: Source agent state not found: $source_agent" >&2
        return 1
    fi
    
    # Extract relevant state data for synchronization
    local sync_data=$(echo "$source_state" | jq '{
        progress: .progress,
        status: .status,
        last_updated: .last_updated,
        context: .context
    }')
    
    # Synchronize with target agents
    while IFS= read -r target_agent; do
        if [[ -n "$target_agent" && "$target_agent" != "$source_agent" ]]; then
            # Send synchronization message
            send_agent_message "$target_agent" "STATE_SYNC" "$sync_data"
        fi
    done < <(echo "$target_agents" | jq -r '.[]')
}

# Handle state synchronization
handle_state_sync() {
    local agent_id="$1"
    local sync_data="$2"
    
    # Parse synchronization data
    local remote_progress=$(echo "$sync_data" | jq -r '.progress')
    local remote_status=$(echo "$sync_data" | jq -r '.status')
    local remote_context=$(echo "$sync_data" | jq -r '.context')
    
    # Update local agent state with synchronized data
    update_local_agent_state "$agent_id" "{
        \"synchronized_progress\": $remote_progress,
        \"synchronized_status\": \"$remote_status\",
        \"synchronized_context\": $remote_context,
        \"last_sync\": \"$(date -Iseconds)\"
    }"
    
    # Trigger state-dependent actions
    trigger_state_dependent_actions "$agent_id" "$sync_data"
}
```

### Advanced Coordination Patterns

#### Leader Election Pattern

```bash
# Leader election for agent coordination
# File: _shared/leader-election.md

# Elect leader agent for coordination
elect_leader_agent() {
    local operation_id="$1"
    local candidate_agents="$2"  # JSON array of agent IDs
    
    local election_file="$shared_state_dir/$operation_id/leader_election.json"
    
    # Initialize election if not exists
    if [[ ! -f "$election_file" ]]; then
        cat > "$election_file" << EOF
{
    "election_id": "$(generate_election_id)",
    "status": "in_progress",
    "candidates": $candidate_agents,
    "votes": {},
    "leader": null,
    "start_time": "$(date -Iseconds)"
}
EOF
    fi
    
    # Conduct election based on priority and capability
    local leader_agent=$(conduct_leader_election "$operation_id" "$candidate_agents")
    
    # Update election results
    jq --arg leader "$leader_agent" \
       '.leader = $leader | .status = "completed" | .end_time = now' \
       "$election_file" > "$election_file.tmp"
    mv "$election_file.tmp" "$election_file"
    
    # Notify all agents of election results
    notify_election_results "$operation_id" "$leader_agent" "$candidate_agents"
    
    echo "$leader_agent"
}

# Conduct election based on agent capabilities
conduct_leader_election() {
    local operation_id="$1"
    local candidates="$2"
    
    local best_candidate=""
    local best_score=0
    
    # Evaluate each candidate
    while IFS= read -r candidate; do
        if [[ -n "$candidate" ]]; then
            local score=$(calculate_leadership_score "$candidate" "$operation_id")
            
            if (( $(echo "$score > $best_score" | bc -l) )); then
                best_candidate="$candidate"
                best_score="$score"
            fi
        fi
    done < <(echo "$candidates" | jq -r '.[]')
    
    echo "$best_candidate"
}

# Calculate leadership score based on agent characteristics
calculate_leadership_score() {
    local agent_id="$1"
    local operation_id="$2"
    
    # Get agent capabilities
    local capabilities=$(get_agent_capabilities "$agent_id")
    local agent_type=$(echo "$capabilities" | jq -r '.agent_type')
    local resource_usage=$(echo "$capabilities" | jq -r '.resource_requirements')
    
    # Get agent performance metrics
    local performance=$(get_agent_performance_metrics "$agent_id")
    local reliability=$(echo "$performance" | jq -r '.reliability // 0.5')
    local response_time=$(echo "$performance" | jq -r '.avg_response_time // 1000')
    
    # Calculate score based on multiple factors
    local type_score=0
    case "$agent_type" in
        "task_executor") type_score=10 ;;
        "progress_monitor") type_score=8 ;;
        "git_integration") type_score=6 ;;
        "dependency_validator") type_score=7 ;;
        "blocker_detection") type_score=5 ;;
        *) type_score=3 ;;
    esac
    
    # Resource efficiency score (lower resource usage = higher score)
    local cpu_req=$(echo "$resource_usage" | jq -r '.cpu')
    local resource_score=0
    case "$cpu_req" in
        "low") resource_score=10 ;;
        "medium") resource_score=7 ;;
        "high") resource_score=4 ;;
        *) resource_score=5 ;;
    esac
    
    # Performance score
    local perf_score=$(echo "scale=0; ($reliability * 10) + (1000 / $response_time)" | bc)
    
    # Calculate total score
    local total_score=$(echo "scale=2; $type_score + $resource_score + $perf_score" | bc)
    
    echo "$total_score"
}
```

#### Consensus Building Pattern

```bash
# Consensus building for critical decisions
# File: _shared/consensus-building.md

# Build consensus among agents for critical decisions
build_agent_consensus() {
    local operation_id="$1"
    local decision_topic="$2"
    local participating_agents="$3"  # JSON array
    local consensus_threshold="${4:-0.7}"  # 70% agreement by default
    
    local consensus_id="$(generate_consensus_id)"
    local consensus_file="$shared_state_dir/$operation_id/consensus_$consensus_id.json"
    
    # Initialize consensus process
    cat > "$consensus_file" << EOF
{
    "consensus_id": "$consensus_id",
    "operation_id": "$operation_id",
    "topic": "$decision_topic",
    "participants": $participating_agents,
    "threshold": $consensus_threshold,
    "votes": {},
    "status": "voting",
    "start_time": "$(date -Iseconds)",
    "timeout": $(( $(date +%s) + 300 ))  // 5 minute timeout
}
EOF
    
    # Request votes from all participating agents
    while IFS= read -r agent_id; do
        if [[ -n "$agent_id" ]]; then
            request_consensus_vote "$agent_id" "$consensus_id" "$decision_topic"
        fi
    done < <(echo "$participating_agents" | jq -r '.[]')
    
    # Wait for consensus or timeout
    wait_for_consensus "$consensus_id" "$consensus_file"
    
    # Return consensus result
    get_consensus_result "$consensus_file"
}

# Request vote from agent
request_consensus_vote() {
    local agent_id="$1"
    local consensus_id="$2"
    local decision_topic="$3"
    
    # Send vote request message
    send_agent_message "$agent_id" "CONSENSUS_VOTE_REQUEST" "{
        \"consensus_id\": \"$consensus_id\",
        \"topic\": \"$decision_topic\",
        \"timeout\": 300
    }"
}

# Handle consensus vote request
handle_consensus_vote_request() {
    local agent_id="$1"
    local request_data="$2"
    
    local consensus_id=$(echo "$request_data" | jq -r '.consensus_id')
    local topic=$(echo "$request_data" | jq -r '.topic')
    
    # Evaluate decision based on agent-specific criteria
    local vote=$(evaluate_consensus_decision "$agent_id" "$topic")
    local confidence=$(calculate_vote_confidence "$agent_id" "$topic")
    
    # Submit vote
    submit_consensus_vote "$consensus_id" "$agent_id" "$vote" "$confidence"
}

# Submit consensus vote
submit_consensus_vote() {
    local consensus_id="$1"
    local agent_id="$2"
    local vote="$3"  # "approve", "reject", "abstain"
    local confidence="$4"  # 0.0 to 1.0
    
    local consensus_file="$shared_state_dir/*/consensus_$consensus_id.json"
    
    # Acquire lock
    local lock_file="$state_lock_dir/consensus_$consensus_id.lock"
    exec 200>"$lock_file"
    flock 200
    
    # Update consensus file with vote
    jq --arg agent_id "$agent_id" \
       --arg vote "$vote" \
       --arg confidence "$confidence" \
       '.votes[$agent_id] = {"vote": $vote, "confidence": ($confidence | tonumber), "timestamp": now}' \
       "$consensus_file" > "$consensus_file.tmp"
    mv "$consensus_file.tmp" "$consensus_file"
    
    # Release lock
    flock -u 200
    exec 200>&-
    
    # Check if consensus reached
    check_consensus_reached "$consensus_id" "$consensus_file"
}

# Wait for consensus or timeout
wait_for_consensus() {
    local consensus_id="$1"
    local consensus_file="$2"
    
    while true; do
        local status=$(jq -r '.status' "$consensus_file")
        
        if [[ "$status" != "voting" ]]; then
            break
        fi
        
        # Check timeout
        local timeout=$(jq -r '.timeout' "$consensus_file")
        local current_time=$(date +%s)
        
        if (( current_time > timeout )); then
            # Mark as timed out
            jq '.status = "timeout" | .end_time = now' \
               "$consensus_file" > "$consensus_file.tmp"
            mv "$consensus_file.tmp" "$consensus_file"
            break
        fi
        
        sleep 1
    done
}

# Check if consensus has been reached
check_consensus_reached() {
    local consensus_id="$1"
    local consensus_file="$2"
    
    local threshold=$(jq -r '.threshold' "$consensus_file")
    local participants=$(jq -r '.participants | length' "$consensus_file")
    local votes=$(jq -r '.votes | length' "$consensus_file")
    
    # Check if all votes received
    if (( votes >= participants )); then
        # Calculate consensus
        local approve_votes=$(jq -r '[.votes[] | select(.vote == "approve")] | length' "$consensus_file")
        local total_confidence=$(jq -r '[.votes[] | select(.vote == "approve") | .confidence] | add // 0' "$consensus_file")
        local avg_confidence=$(echo "scale=3; $total_confidence / $approve_votes" | bc)
        
        local approval_rate=$(echo "scale=3; $approve_votes / $participants" | bc)
        local weighted_consensus=$(echo "scale=3; $approval_rate * $avg_confidence" | bc)
        
        if (( $(echo "$weighted_consensus >= $threshold" | bc -l) )); then
            # Consensus reached
            jq --arg result "approved" \
               --arg rate "$approval_rate" \
               --arg confidence "$avg_confidence" \
               --arg weighted "$weighted_consensus" \
               '.status = "completed" | .result = $result | .approval_rate = ($rate | tonumber) | .avg_confidence = ($confidence | tonumber) | .weighted_consensus = ($weighted | tonumber) | .end_time = now' \
               "$consensus_file" > "$consensus_file.tmp"
            mv "$consensus_file.tmp" "$consensus_file"
        else
            # Consensus not reached
            jq --arg result "rejected" \
               --arg rate "$approval_rate" \
               --arg confidence "$avg_confidence" \
               --arg weighted "$weighted_consensus" \
               '.status = "completed" | .result = $result | .approval_rate = ($rate | tonumber) | .avg_confidence = ($confidence | tonumber) | .weighted_consensus = ($weighted | tonumber) | .end_time = now' \
               "$consensus_file" > "$consensus_file.tmp"
            mv "$consensus_file.tmp" "$consensus_file"
        fi
        
        # Notify all participants of result
        notify_consensus_result "$consensus_id" "$consensus_file"
    fi
}
```

## Agent Testing and Quality Assurance

### Agent Testing Framework

```bash
# Agent testing framework
# File: test/agent-testing-framework.md

# Test agent implementation
test_agent() {
    local agent_type="$1"
    local test_config="$2"
    
    echo "Testing agent: $agent_type"
    
    # Unit tests
    test_agent_initialization "$agent_type" "$test_config"
    test_agent_task_execution "$agent_type" "$test_config"
    test_agent_communication "$agent_type" "$test_config"
    test_agent_error_handling "$agent_type" "$test_config"
    test_agent_cleanup "$agent_type" "$test_config"
    
    # Integration tests
    test_agent_coordination "$agent_type" "$test_config"
    test_agent_state_sync "$agent_type" "$test_config"
    
    # Performance tests
    test_agent_performance "$agent_type" "$test_config"
    
    echo "All tests passed for agent: $agent_type"
}

# Test agent initialization
test_agent_initialization() {
    local agent_type="$1"
    local test_config="$2"
    
    echo "Testing agent initialization..."
    
    # Test valid initialization
    local agent_id="test-$agent_type-$(date +%s)"
    
    if initialize_agent "$agent_id" "$test_config"; then
        echo "✓ Agent initialization successful"
    else
        echo "✗ Agent initialization failed"
        return 1
    fi
    
    # Verify agent registration
    if is_agent_registered "$agent_id"; then
        echo "✓ Agent registration successful"
    else
        echo "✗ Agent registration failed"
        return 1
    fi
    
    # Test invalid configuration
    if initialize_agent "invalid-agent" "invalid-config"; then
        echo "✗ Invalid configuration should be rejected"
        return 1
    else
        echo "✓ Invalid configuration correctly rejected"
    fi
    
    # Cleanup
    cleanup_agent "$agent_id"
}

# Test agent task execution
test_agent_task_execution() {
    local agent_type="$1"
    local test_config="$2"
    
    echo "Testing agent task execution..."
    
    # Initialize test agent
    local agent_id="test-exec-$agent_type-$(date +%s)"
    initialize_agent "$agent_id" "$test_config"
    
    # Create test task
    local test_task='{
        "operation": "test_operation",
        "parameters": {
            "test_param": "test_value"
        }
    }'
    
    # Execute task
    if execute_agent_task "$agent_id" "$test_task"; then
        echo "✓ Task execution successful"
    else
        echo "✗ Task execution failed"
        cleanup_agent "$agent_id"
        return 1
    fi
    
    # Verify task results
    if verify_task_results "$agent_id" "$test_task"; then
        echo "✓ Task results verified"
    else
        echo "✗ Task results verification failed"
        cleanup_agent "$agent_id"
        return 1
    fi
    
    # Cleanup
    cleanup_agent "$agent_id"
}

# Test multi-agent coordination
test_multi_agent_coordination() {
    local operation_id="test-coordination-$(date +%s)"
    
    echo "Testing multi-agent coordination..."
    
    # Spawn multiple agents
    local agent_configs=(
        '{"agent_type": "task_executor", "max_tasks": 3}'
        '{"agent_type": "progress_monitor", "update_interval": 1}'
        '{"agent_type": "git_integration", "auto_commit": false}'
    )
    
    local agent_ids=()
    for config in "${agent_configs[@]}"; do
        local agent_id="test-coord-$(date +%s)-$RANDOM"
        initialize_agent "$agent_id" "$config"
        agent_ids+=("$agent_id")
    done
    
    # Test coordination workflow
    if coordinate_agent_workflow "$operation_id" "${agent_ids[@]}"; then
        echo "✓ Multi-agent coordination successful"
    else
        echo "✗ Multi-agent coordination failed"
        # Cleanup agents
        for agent_id in "${agent_ids[@]}"; do
            cleanup_agent "$agent_id"
        done
        return 1
    fi
    
    # Verify coordination results
    if verify_coordination_results "$operation_id" "${agent_ids[@]}"; then
        echo "✓ Coordination results verified"
    else
        echo "✗ Coordination results verification failed"
    fi
    
    # Cleanup agents
    for agent_id in "${agent_ids[@]}"; do
        cleanup_agent "$agent_id"
    done
}
```

## Best Practices for Agent Development

### Design Principles

1. **Single Responsibility**: Each agent should have one clear, focused responsibility
2. **Loose Coupling**: Agents should be independently deployable and maintainable
3. **High Cohesion**: Related functionality should be grouped within the same agent
4. **Fault Tolerance**: Agents should handle failures gracefully and recover when possible
5. **Resource Efficiency**: Optimize resource usage while maintaining performance
6. **Observable**: Provide comprehensive monitoring and debugging capabilities

### Implementation Guidelines

1. **Standard Interface**: Implement the required agent interface functions
2. **Configuration Validation**: Thoroughly validate agent configuration on initialization
3. **Error Handling**: Implement comprehensive error handling with recovery mechanisms
4. **Resource Management**: Properly manage memory, CPU, and I/O resources
5. **State Management**: Maintain clean, consistent state throughout the agent lifecycle
6. **Communication**: Use standard message formats and communication patterns
7. **Testing**: Include comprehensive unit and integration tests

### Performance Optimization

1. **Asynchronous Operations**: Use non-blocking operations where possible
2. **Resource Pooling**: Pool expensive resources like database connections
3. **Caching**: Cache frequently accessed data to reduce latency
4. **Batch Processing**: Process multiple items together when efficient
5. **Memory Management**: Monitor and optimize memory usage patterns
6. **CPU Optimization**: Profile and optimize CPU-intensive operations

### Monitoring and Debugging

1. **Comprehensive Logging**: Log all significant events and state changes
2. **Metrics Collection**: Collect and expose performance metrics
3. **Health Checks**: Implement health check endpoints for monitoring
4. **Debug Mode**: Provide detailed debug output when enabled
5. **Tracing**: Support distributed tracing for complex workflows
6. **Alerting**: Generate alerts for error conditions and performance issues

---

**Next**: [Quality Standards](./quality-standards.md) - Code quality and review processes

**See Also**:
- [Architecture Overview](./architecture-overview.md) - System design principles
- [Command Development](./command-development.md) - Building commands with agents
- [Performance Optimization](./performance-optimization.md) - Optimization techniques