---
description: Real multi-agent spawning patterns using Task tool for milestone execution
---

# Milestone Agent Spawning Framework

Real multi-agent orchestration using Claude Code's Task tool for parallel milestone execution.

## Core Agent Spawning Patterns

### Task Executor Agent Template
```bash
# Deploy task executor agent using Task tool
spawn_task_executor() {
    local milestone_id=$1
    local session_id=$2
    
    # Agent will be spawned with Task tool using this prompt
    echo "Task Executor Agent for milestone $milestone_id
    
    Responsibilities:
    - Read milestone from .milestones/active/${milestone_id}.yaml
    - Execute pending tasks sequentially
    - Update task status after completion
    - Log progress to .milestones/logs/${session_id}/execution.jsonl
    - Create commits for completed work
    
    Session: $session_id"
}
```

### Progress Monitor Agent Template
```bash
# Deploy progress monitoring agent using Task tool
spawn_progress_monitor() {
    local milestone_id=$1
    local session_id=$2
    
    echo "Progress Monitor Agent for milestone $milestone_id
    
    Responsibilities:
    - Monitor execution progress
    - Calculate completion percentage
    - Update milestone progress
    - Detect stalled tasks
    - Report to .milestones/logs/${session_id}/progress.jsonl
    
    Session: $session_id"
}
```

### Git Integration Agent Template
```bash
# Deploy git integration agent using Task tool
spawn_git_integration() {
    local milestone_id=$1
    local session_id=$2
    local branch=$3
    
    echo "Git Integration Agent for milestone $milestone_id
    
    Responsibilities:
    - Manage branch: $branch
    - Create atomic commits
    - Handle merge conflicts
    - Push completed changes
    - Log to .milestones/logs/${session_id}/git.jsonl
    
    Session: $session_id"
}
```

### Dependency Validator Agent Template
```bash
# Deploy dependency validator using Task tool
spawn_dependency_validator() {
    local milestone_id=$1
    local session_id=$2
    
    echo "Dependency Validator Agent for milestone $milestone_id
    
    Responsibilities:
    - Check prerequisite milestones
    - Validate dependencies
    - Detect circular dependencies
    - Monitor resource conflicts
    - Report to .milestones/logs/${session_id}/dependencies.jsonl
    
    Session: $session_id"
}
```

### Blocker Detection Agent Template
```bash
# Deploy blocker detector using Task tool
spawn_blocker_detector() {
    local milestone_id=$1
    local session_id=$2
    
    echo "Blocker Detection Agent for milestone $milestone_id
    
    Responsibilities:
    - Monitor for errors
    - Detect stalled execution
    - Identify bottlenecks
    - Propose resolutions
    - Alert to .milestones/logs/${session_id}/blockers.jsonl
    
    Session: $session_id"
}
```

## Multi-Agent Orchestration Function

### Main Orchestration Entry Point
```bash
# Execute milestone with real multi-agent coordination
execute_milestone_with_agents() {
    local milestone_id=$1
    local session_id=$(generate_session_id)
    local branch="milestone/$milestone_id"
    
    echo "=== Starting Multi-Agent Milestone Execution ==="
    echo "Milestone: $milestone_id"
    echo "Session: $session_id"
    
    # Setup communication infrastructure
    setup_agent_infrastructure "$session_id"
    
    # Deploy agents in parallel using Task tool
    echo "Deploying specialized agents..."
    
    # Task Executor Agent
    local task_prompt=$(spawn_task_executor "$milestone_id" "$session_id")
    echo "DEPLOY_AGENT:task-executor:$task_prompt"
    
    # Progress Monitor Agent
    local progress_prompt=$(spawn_progress_monitor "$milestone_id" "$session_id")
    echo "DEPLOY_AGENT:progress-monitor:$progress_prompt"
    
    # Git Integration Agent
    local git_prompt=$(spawn_git_integration "$milestone_id" "$session_id" "$branch")
    echo "DEPLOY_AGENT:git-integration:$git_prompt"
    
    # Dependency Validator Agent
    local dep_prompt=$(spawn_dependency_validator "$milestone_id" "$session_id")
    echo "DEPLOY_AGENT:dependency-validator:$dep_prompt"
    
    # Blocker Detection Agent
    local blocker_prompt=$(spawn_blocker_detector "$milestone_id" "$session_id")
    echo "DEPLOY_AGENT:blocker-detector:$blocker_prompt"
    
    echo "All agents deployed for parallel execution"
    
    # Monitor agent coordination
    monitor_agent_coordination "$session_id"
}
```

### Agent Infrastructure Setup
```bash
# Setup shared infrastructure for agents
setup_agent_infrastructure() {
    local session_id=$1
    
    # Create session directories
    mkdir -p ".milestones/sessions/$session_id/agents"
    mkdir -p ".milestones/logs/$session_id"
    
    # Initialize shared state
    cat > ".milestones/sessions/$session_id/agents/state.json" <<EOF
{
    "session_id": "$session_id",
    "agents": {
        "task_executor": "initializing",
        "progress_monitor": "initializing",
        "git_integration": "initializing",
        "dependency_validator": "initializing",
        "blocker_detector": "initializing"
    },
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "coordination_mode": "parallel"
}
EOF
    
    # Create communication channels
    touch ".milestones/sessions/$session_id/agents/messages.jsonl"
    touch ".milestones/sessions/$session_id/agents/requests.jsonl"
    touch ".milestones/sessions/$session_id/agents/responses.jsonl"
}
```

### Agent Coordination Monitor
```bash
# Monitor and coordinate agent activities
monitor_agent_coordination() {
    local session_id=$1
    local max_duration=${2:-7200}  # 2 hours default
    
    local start_time=$(date +%s)
    local monitoring=true
    
    echo "Monitoring agent coordination for session: $session_id"
    
    while [ "$monitoring" = true ]; do
        # Check agent status
        local agents_status=$(jq -r '.agents | to_entries[] | "\(.key): \(.value)"' \
            ".milestones/sessions/$session_id/agents/state.json" 2>/dev/null)
        
        # Check for completion
        local completed_count=$(echo "$agents_status" | grep -c "completed" || true)
        local total_agents=5
        
        if [ "$completed_count" -eq "$total_agents" ]; then
            echo "All agents completed successfully"
            monitoring=false
        fi
        
        # Check for failures
        local failed_count=$(echo "$agents_status" | grep -c "failed" || true)
        if [ "$failed_count" -gt 0 ]; then
            echo "WARNING: $failed_count agents failed"
            handle_agent_failures "$session_id"
        fi
        
        # Check timeout
        local elapsed=$(($(date +%s) - start_time))
        if [ $elapsed -gt $max_duration ]; then
            echo "Session timeout reached"
            monitoring=false
        fi
        
        # Brief pause before next check
        sleep 5
    done
    
    # Final coordination report
    generate_coordination_report "$session_id"
}
```

### Agent Failure Handling
```bash
# Handle agent failures and recovery
handle_agent_failures() {
    local session_id=$1
    
    # Read failure details
    local failed_agents=$(jq -r '.agents | to_entries[] | select(.value == "failed") | .key' \
        ".milestones/sessions/$session_id/agents/state.json")
    
    for agent in $failed_agents; do
        echo "Attempting recovery for agent: $agent"
        
        # Log failure event
        echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"event\":\"agent_recovery\",\"agent\":\"$agent\"}" \
            >> ".milestones/sessions/$session_id/agents/messages.jsonl"
        
        # Attempt restart with recovery prompt
        case "$agent" in
            task_executor)
                echo "RESTART_AGENT:task-executor:Resume task execution from last checkpoint"
                ;;
            progress_monitor)
                echo "RESTART_AGENT:progress-monitor:Resume progress monitoring"
                ;;
            git_integration)
                echo "RESTART_AGENT:git-integration:Check git status and resume"
                ;;
            dependency_validator)
                echo "RESTART_AGENT:dependency-validator:Re-validate dependencies"
                ;;
            blocker_detector)
                echo "RESTART_AGENT:blocker-detector:Resume blocker detection"
                ;;
        esac
    done
}
```

### Coordination Report Generation
```bash
# Generate final coordination report
generate_coordination_report() {
    local session_id=$1
    
    echo "=== Agent Coordination Report ==="
    echo "Session: $session_id"
    
    # Read final state
    local state_file=".milestones/sessions/$session_id/agents/state.json"
    
    if [ -f "$state_file" ]; then
        echo "Agent Status:"
        jq -r '.agents | to_entries[] | "  - \(.key): \(.value)"' "$state_file"
        
        echo "Execution Metrics:"
        # Count events per agent
        for log_file in .milestones/logs/$session_id/*.jsonl; do
            if [ -f "$log_file" ]; then
                local agent=$(basename "$log_file" .jsonl)
                local event_count=$(wc -l < "$log_file")
                echo "  - $agent: $event_count events"
            fi
        done
        
        echo "Coordination Summary:"
        local message_count=$(wc -l < ".milestones/sessions/$session_id/agents/messages.jsonl" 2>/dev/null || echo 0)
        echo "  - Inter-agent messages: $message_count"
    fi
}
```

## Integration with Claude Code

### Task Tool Usage Instructions
```markdown
When executing a milestone, Claude Code should:

1. Parse the DEPLOY_AGENT directives
2. Use the Task tool to spawn each agent
3. Monitor agent outputs
4. Coordinate agent activities
5. Handle completion and cleanup

Example Task tool invocation pattern:
- Read agent prompt from DEPLOY_AGENT directive
- Invoke Task tool with subagent_type="general-purpose"
- Set description to agent type and session
- Provide full prompt with responsibilities

The agents will work in parallel, each handling their specific domain.
```

### Session Recovery
```bash
# Resume interrupted milestone execution
resume_milestone_execution() {
    local session_id=$1
    
    echo "Resuming milestone execution session: $session_id"
    
    # Read session state
    local state_file=".milestones/sessions/$session_id/agents/state.json"
    
    if [ ! -f "$state_file" ]; then
        echo "ERROR: Session not found: $session_id"
        return 1
    fi
    
    # Check which agents need resuming
    local incomplete_agents=$(jq -r '.agents | to_entries[] | select(.value != "completed") | .key' "$state_file")
    
    for agent in $incomplete_agents; do
        echo "Resuming agent: $agent"
        echo "RESUME_AGENT:$agent:Continue from last checkpoint in session $session_id"
    done
    
    # Resume coordination monitoring
    monitor_agent_coordination "$session_id"
}
```

## Performance Benefits

### Expected Improvements
- **3-5x faster execution** through parallel processing
- **Specialized optimization** per agent domain
- **Reduced context switching** with focused agents
- **Better error isolation** and recovery
- **Real-time progress visibility**

### Measurement Framework
```bash
# Measure multi-agent performance
measure_agent_performance() {
    local session_id=$1
    
    # Calculate execution metrics
    local start_time=$(jq -r '.started_at' ".milestones/sessions/$session_id/agents/state.json")
    local end_time=$(jq -r '.completed_at' ".milestones/sessions/$session_id/agents/state.json")
    
    # Compare with sequential baseline
    echo "Performance Analysis:"
    echo "  Multi-agent execution time: $(calculate_duration "$start_time" "$end_time")"
    echo "  Parallel efficiency: $(calculate_parallel_efficiency "$session_id")"
    echo "  Agent utilization: $(calculate_agent_utilization "$session_id")"
}
```