---
description: Context management and state persistence for milestone operations
---

# Milestone Context Management

Shared utilities for managing milestone context, state persistence, and session continuity across execution phases.

## Context Structure

```yaml
milestone_context:
  session:
    id: "session-20240713-001"
    started_at: "2024-07-13T14:30:00Z"
    resumed_from: "session-20240712-003"
    working_directory: "/path/to/project"
    git_branch: "feature/milestone-003"
    
  active_milestone:
    id: "milestone-003"
    title: "API Integration Phase"
    status: "in_progress"
    progress_percentage: 45
    
  execution_state:
    current_task: "task-003-004"
    active_agents: ["api-agent", "test-agent"]
    blockers: []
    dependencies_met: ["milestone-001", "milestone-002"]
    
  environment:
    git_status: "clean"
    uncommitted_changes: false
    current_branch: "feature/milestone-003"
    remote_sync_status: "up_to_date"
```

## Context Persistence Functions

```bash
# Save milestone context
save_milestone_context() {
    local session_id=$1
    local context_file=".milestones/sessions/$session_id.yaml"
    
    mkdir -p ".milestones/sessions"
    
    cat > "$context_file" << EOF
session:
  id: "$session_id"
  started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  working_directory: "$(pwd)"
  git_branch: "$(git branch --show-current)"
  
active_milestone:
  id: "$(cat .milestones/active/current.txt 2>/dev/null)"
  status: "$(yq e '.status' .milestones/active/milestone-*.yaml | head -1)"
  
environment:
  git_status: "$(git status --porcelain | wc -l | tr -d ' ')"
  current_branch: "$(git branch --show-current)"
  last_commit: "$(git rev-parse HEAD)"
EOF
    
    echo "Context saved to: $context_file"
}

# Load milestone context
load_milestone_context() {
    local session_id=$1
    local context_file=".milestones/sessions/$session_id.yaml"
    
    if [ ! -f "$context_file" ]; then
        echo "ERROR: Context file not found: $context_file"
        return 1
    fi
    
    # Restore working directory
    local work_dir=$(yq e '.session.working_directory' "$context_file")
    if [ "$work_dir" != "$(pwd)" ]; then
        echo "WARNING: Context was saved in different directory: $work_dir"
        read -p "Change to that directory? [y/N]: " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            cd "$work_dir"
        fi
    fi
    
    # Restore git branch
    local saved_branch=$(yq e '.session.git_branch' "$context_file")
    local current_branch=$(git branch --show-current)
    
    if [ "$saved_branch" != "$current_branch" ]; then
        echo "WARNING: Different git branch. Saved: $saved_branch, Current: $current_branch"
        read -p "Switch to saved branch? [y/N]: " response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git checkout "$saved_branch"
        fi
    fi
    
    echo "Context loaded from: $context_file"
}

# Generate session ID
generate_session_id() {
    echo "session-$(date +%Y%m%d-%H%M%S)"
}

# Find latest session
find_latest_session() {
    local latest_session=$(ls -t .milestones/sessions/*.yaml 2>/dev/null | head -1)
    if [ -n "$latest_session" ]; then
        basename "$latest_session" .yaml
    fi
}
```

## State Validation

```bash
# Validate milestone state
validate_milestone_state() {
    local milestone_id=$1
    local errors=0
    
    echo "=== Milestone State Validation ==="
    
    # Check milestone file exists
    if [ ! -f ".milestones/active/$milestone_id.yaml" ]; then
        echo "ERROR: Milestone file not found: $milestone_id.yaml"
        ((errors++))
    fi
    
    # Check dependencies
    local dependencies=$(yq e '.dependencies.requires[]' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
    for dep in $dependencies; do
        if [ ! -f ".milestones/completed/$dep.yaml" ]; then
            echo "ERROR: Dependency not completed: $dep"
            ((errors++))
        fi
    done
    
    # Check git state
    if [ -n "$(git status --porcelain)" ]; then
        echo "WARNING: Uncommitted changes detected"
        git status --short
    fi
    
    # Check working directory matches context
    local expected_dir=$(yq e '.context.working_directory' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
    if [ -n "$expected_dir" ] && [ "$expected_dir" != "$(pwd)" ]; then
        echo "WARNING: Working directory mismatch"
        echo "  Expected: $expected_dir"
        echo "  Current:  $(pwd)"
    fi
    
    if [ $errors -eq 0 ]; then
        echo "✅ Milestone state is valid"
    else
        echo "❌ Found $errors state validation errors"
    fi
    
    return $errors
}
```

## Agent Coordination Context

```bash
# Register active agent
register_agent() {
    local agent_id=$1
    local agent_type=$2
    local milestone_id=$3
    
    local agent_file=".milestones/sessions/agents/$agent_id.yaml"
    mkdir -p ".milestones/sessions/agents"
    
    cat > "$agent_file" << EOF
agent:
  id: "$agent_id"
  type: "$agent_type"
  milestone: "$milestone_id"
  started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  status: "active"
  
context:
  working_directory: "$(pwd)"
  git_branch: "$(git branch --show-current)"
  assigned_tasks: []
EOF
    
    echo "Agent registered: $agent_id"
}

# Update agent status
update_agent_status() {
    local agent_id=$1
    local status=$2
    local agent_file=".milestones/sessions/agents/$agent_id.yaml"
    
    if [ -f "$agent_file" ]; then
        yq e ".agent.status = \"$status\"" -i "$agent_file"
        yq e ".agent.updated_at = \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"" -i "$agent_file"
        echo "Agent $agent_id status updated to: $status"
    fi
}

# List active agents
list_active_agents() {
    local milestone_id=$1
    
    echo "=== Active Agents for $milestone_id ==="
    for agent_file in .milestones/sessions/agents/*.yaml; do
        if [ -f "$agent_file" ]; then
            local agent_milestone=$(yq e '.agent.milestone' "$agent_file")
            local agent_status=$(yq e '.agent.status' "$agent_file")
            
            if [ "$agent_milestone" == "$milestone_id" ] && [ "$agent_status" == "active" ]; then
                local agent_id=$(yq e '.agent.id' "$agent_file")
                local agent_type=$(yq e '.agent.type' "$agent_file")
                echo "  $agent_id ($agent_type)"
            fi
        fi
    done
}
```

This context management system provides the foundation for milestone execution state persistence and agent coordination.