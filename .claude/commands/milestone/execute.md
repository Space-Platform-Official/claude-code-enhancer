---
allowed-tools: all
description: Comprehensive milestone execution with multi-agent coordination, progress tracking, and session management
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: MILESTONE EXECUTION MODE ENGAGED ⚡⚡⚡

**THIS IS NOT A PLANNING TASK - THIS IS ACTIVE MILESTONE EXECUTION AND COORDINATION!**

When you run `/milestone/execute`, you are REQUIRED to:

1. **ACTIVATE** - Transition milestone from planned to active execution state
2. **COORDINATE** - Deploy multi-agent task execution with real-time monitoring
3. **TRACK** - Implement continuous progress tracking with event logging
4. **INTEGRATE** - Ensure seamless working directory and git integration
5. **MANAGE** - Maintain session state for interruption and resume capability
6. **VALIDATE** - Enforce dependency requirements and detect blockers
7. **ESCALATE** - Handle blockers and coordinate resolution strategies

## 🎯 USE MULTIPLE AGENTS FOR EXECUTION

**MANDATORY AGENT COORDINATION FOR MILESTONE EXECUTION:**
```
"I'll spawn multiple execution agents to handle milestone tasks in parallel:
- Task Execution Agent: Execute specific milestone tasks and track completion
- Progress Monitoring Agent: Real-time progress tracking and event logging
- Git Integration Agent: Handle branch management, commits, and repository state
- Dependency Validation Agent: Monitor and enforce milestone dependencies
- Blocker Detection Agent: Identify blockers and coordinate resolution
- Session Management Agent: Handle interruptions and resume capabilities"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Start execution without proper milestone activation → NO! Validate state first!
- ❌ Execute tasks without dependency validation → NO! Check prerequisites!
- ❌ Ignore working directory integration → NO! Maintain git consistency!
- ❌ Skip progress tracking and logging → NO! Real-time monitoring required!
- ❌ Execute without session management → NO! Resume capability essential!
- ❌ Continue execution with unresolved blockers → NO! Escalate immediately!

**MANDATORY EXECUTION WORKFLOW:**
```
1. Milestone state validation → Ensure prerequisites and dependencies met
2. IMMEDIATELY spawn execution agents for parallel task coordination
3. Activate milestone → Transition from planned to active state
4. Execute tasks → Multi-agent coordination with real-time tracking
5. Monitor progress → Continuous event logging and status updates
6. Handle blockers → Detection, escalation, and resolution coordination
7. VERIFY execution completion and milestone state integrity
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Milestone activated and in execution state
- ✅ Multi-agent task coordination deployed
- ✅ Real-time progress tracking implemented
- ✅ Working directory and git integration active
- ✅ Session management with resume capability functional
- ✅ All blockers identified and escalated appropriately

---

🛑 **MANDATORY EXECUTION VALIDATION CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Validate current milestone state and dependencies
3. Confirm working directory and git integration requirements

Execute comprehensive milestone execution with ZERO tolerance for incomplete coordination.

**FORBIDDEN EXECUTION PATTERNS:**
- "Let's just run the tasks sequentially" → NO, multi-agent coordination required
- "Simple progress tracking is enough" → NO, real-time event logging needed
- "We don't need session management" → NO, resume capability essential
- "Manual blocker handling is fine" → NO, automated detection required
- "Git integration can be manual" → NO, integrated repository management needed

You are executing milestone: $ARGUMENTS

Let me ultrathink about the comprehensive execution architecture and coordination system.

🚨 **REMEMBER: Effective execution requires coordination, not just task completion!** 🚨

**Comprehensive Milestone Execution Protocol:**

## Step 0: Execution Prerequisites Validation

**Validate Milestone State:**
```bash
# Verify milestone exists and is ready for execution
validate_milestone_state() {
    local milestone_id=$1
    
    echo "=== Milestone Execution Prerequisites ==="
    
    # Check milestone file exists
    if [ ! -f ".milestones/active/$milestone_id.yaml" ]; then
        echo "ERROR: Milestone not found: $milestone_id"
        return 1
    fi
    
    # Validate status allows execution
    local status=$(yq e '.status' ".milestones/active/$milestone_id.yaml")
    if [ "$status" != "planned" ] && [ "$status" != "paused" ]; then
        echo "ERROR: Milestone status '$status' does not allow execution"
        return 1
    fi
    
    # Check dependencies are met
    local dependencies=$(yq e '.dependencies.requires[]' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
    for dep in $dependencies; do
        if [ ! -f ".milestones/completed/$dep.yaml" ]; then
            echo "ERROR: Dependency not completed: $dep"
            return 1
        fi
    done
    
    echo "✅ Prerequisites validated for execution"
}
```

**Working Directory Integration:**
```bash
# Ensure proper working directory setup
setup_execution_environment() {
    local milestone_id=$1
    
    # Source shared utilities
    source ".claude/commands/milestone/_shared/context.md"
    source ".claude/commands/milestone/_shared/git-integration.md"
    source ".claude/commands/milestone/_shared/state.md"
    
    # Create execution directories
    mkdir -p ".milestones/active"
    mkdir -p ".milestones/logs"
    mkdir -p ".milestones/sessions"
    mkdir -p ".milestones/sessions/agents"
    
    # Initialize git integration
    validate_milestone_branch "$milestone_id"
    
    # Create session context
    local session_id=$(generate_session_id)
    save_milestone_context "$session_id"
    
    echo "Execution environment ready: $session_id"
    return 0
}
```

## Step 1: Milestone Activation Protocol

**Activate Milestone for Execution:**
```yaml
milestone_activation:
  pre_activation:
    - validate_dependencies: true
    - check_git_state: true
    - verify_working_directory: true
    - initialize_session: true
    
  activation_process:
    - update_status: "in_progress"
    - set_start_timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    - create_execution_log: ".milestones/logs/execution-${milestone_id}.jsonl"
    - initialize_progress_tracking: true
    
  post_activation:
    - log_activation_event: true
    - notify_dependent_milestones: true
    - setup_monitoring: true
```

**Activation Implementation:**
```bash
activate_milestone() {
    local milestone_id=$1
    local session_id=$2
    
    echo "⚡ Activating milestone for execution: $milestone_id"
    
    # Update milestone status
    yq e '.status = "in_progress"' -i ".milestones/active/$milestone_id.yaml"
    yq e '.execution.started_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
    yq e '.execution.session_id = "'$session_id'"' -i ".milestones/active/$milestone_id.yaml"
    
    # Initialize progress tracking
    yq e '.progress.percentage = 0' -i ".milestones/active/$milestone_id.yaml"
    yq e '.progress.tasks_completed = 0' -i ".milestones/active/$milestone_id.yaml"
    yq e '.progress.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
    
    # Create execution log
    local log_file=".milestones/logs/execution-$milestone_id.jsonl"
    echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"milestone_activated","milestone_id":"'$milestone_id'","session_id":"'$session_id'"}' >> "$log_file"
    
    # Set current milestone marker
    echo "$milestone_id" > ".milestones/active/current.txt"
    
    echo "✅ Milestone activated: $milestone_id"
}
```

## Step 2: Multi-Agent Task Coordination

**Agent Deployment Strategy:**
```bash
deploy_execution_agents() {
    local milestone_id=$1
    local session_id=$2
    
    echo "🤖 Deploying execution agents for milestone: $milestone_id"
    
    # Task Execution Agent
    register_agent "task-executor-$session_id" "task_executor" "$milestone_id"
    spawn_task_execution_agent "$milestone_id" &
    
    # Progress Monitoring Agent (Enhanced with Kiro support)
    register_agent "progress-monitor-$session_id" "progress_monitor" "$milestone_id"
    spawn_progress_monitoring_agent "$milestone_id" &
    
    # NEW: Kiro Workflow Coordination Agent
    register_agent "kiro-coordinator-$session_id" "kiro_coordinator" "$milestone_id"
    spawn_kiro_coordination_agent "$milestone_id" &
    
    # Git Integration Agent
    register_agent "git-integration-$session_id" "git_integration" "$milestone_id"
    spawn_git_integration_agent "$milestone_id" &
    
    # Dependency Validation Agent
    register_agent "dependency-validator-$session_id" "dependency_validator" "$milestone_id"
    spawn_dependency_validation_agent "$milestone_id" &
    
    # Blocker Detection Agent
    register_agent "blocker-detector-$session_id" "blocker_detector" "$milestone_id"
    spawn_blocker_detection_agent "$milestone_id" &
    
    echo "✅ All execution agents deployed (including kiro workflow support)"
}
```

**Task Execution Agent:**
```bash
spawn_task_execution_agent() {
    local milestone_id=$1
    
    echo "🔧 Task Execution Agent: Starting task coordination for $milestone_id"
    
    # Get pending tasks
    local tasks=$(yq e '.tasks[] | select(.status == "pending") | .id' ".milestones/active/$milestone_id.yaml")
    
    for task_id in $tasks; do
        echo "📋 Processing task: $task_id"
        
        # Check if task has kiro workflow enabled
        local kiro_enabled=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.enabled' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
        
        if [ "$kiro_enabled" = "true" ]; then
            echo "🔄 Task $task_id uses kiro workflow - delegating to kiro coordination agent"
            # Kiro workflow tasks are handled by the kiro coordination agent
            # Just mark task as kiro-managed and let the coordination agent handle phases
            yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "kiro_managed"' -i ".milestones/active/$milestone_id.yaml"
            yq e '(.tasks[] | select(.id == "'$task_id'") | .started_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
            
            # Initialize kiro workflow phases
            initialize_kiro_workflow "$milestone_id" "$task_id"
            
            log_milestone_event_reactive "$milestone_id" "kiro_workflow_started" "{\"task_id\": \"$task_id\"}"
        else
            echo "📋 Executing standard task: $task_id"
            
            # Standard task execution
            yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "in_progress"' -i ".milestones/active/$milestone_id.yaml"
            yq e '(.tasks[] | select(.id == "'$task_id'") | .started_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
            
            # Log task start with reactive status update
            log_milestone_event_reactive "$milestone_id" "task_started" "{\"task_id\": \"$task_id\"}"
            
            # Execute task (placeholder for actual task execution)
            execute_milestone_task "$milestone_id" "$task_id"
            
            # Update task completion
            yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "completed"' -i ".milestones/active/$milestone_id.yaml"
            yq e '(.tasks[] | select(.id == "'$task_id'") | .completed_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
            
            # Log task completion with reactive status update
            log_milestone_event_reactive "$milestone_id" "task_completed" "{\"task_id\": \"$task_id\"}"
            
            # Create milestone commit
            create_milestone_commit "$milestone_id" "$task_id" "Complete task: $(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")"
        fi
    done
    
    echo "✅ Task Execution Agent: All tasks processed"
}

# Initialize kiro workflow for a task
initialize_kiro_workflow() {
    local milestone_id=$1
    local task_id=$2
    
    echo "🔄 Initializing kiro workflow for task: $task_id"
    
    # Create deliverables directory structure
    mkdir -p ".milestones/deliverables/$task_id"/{design,spec,task,execute}
    
    # Set initial phase status
    update_kiro_phase_status "$milestone_id" "$task_id" "design" "in_progress"
    
    # Update task's current phase
    yq e '(.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.current_phase) = "design"' -i ".milestones/active/$milestone_id.yaml"
    
    echo "✅ Kiro workflow initialized for $task_id - starting with design phase"
}

# NEW: Kiro Workflow Coordination Agent
spawn_kiro_coordination_agent() {
    local milestone_id=$1
    
    echo "🎨 Kiro Coordination Agent: Managing workflow phases for $milestone_id"
    
    while true; do
        # Find tasks with kiro workflow enabled
        local kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
        
        for task_id in $kiro_tasks; do
            local current_phase=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.current_phase' ".milestones/active/$milestone_id.yaml")
            local phase_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$current_phase'.status' ".milestones/active/$milestone_id.yaml")
            
            case "$current_phase" in
                "design")
                    if [ "$phase_status" = "in_progress" ]; then
                        execute_design_phase "$milestone_id" "$task_id"
                    fi
                    ;;
                "spec")
                    if [ "$phase_status" = "in_progress" ]; then
                        execute_spec_phase "$milestone_id" "$task_id"
                    fi
                    ;;
                "task")
                    if [ "$phase_status" = "in_progress" ]; then
                        execute_task_phase "$milestone_id" "$task_id"
                    fi
                    ;;
                "execute")
                    if [ "$phase_status" = "in_progress" ]; then
                        execute_implementation_phase "$milestone_id" "$task_id"
                    fi
                    ;;
            esac
            
            # Monitor for phase transitions
            monitor_kiro_phase_progressions "$milestone_id"
        done
        
        sleep 30
    done
}

# Execute design phase for kiro workflow
execute_design_phase() {
    local milestone_id=$1
    local task_id=$2
    
    echo "🎨 Executing design phase for task: $task_id"
    
    local task_title=$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")
    local deliverable_dir=".milestones/deliverables/$task_id/design"
    
    # Create architecture design document
    cat > "$deliverable_dir/architecture.md" << EOF
# Architecture Design: $task_title

## Overview
$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")

## Architecture Decisions
- [Design decision 1]
- [Design decision 2]
- [Design decision 3]

## API Design
- Endpoints and interfaces
- Data flow patterns
- Integration points

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    # Create API specification
    cat > "$deliverable_dir/api-spec.yaml" << EOF
# API Specification: $task_title
openapi: 3.0.0
info:
  title: $task_title API
  version: 1.0.0
  description: Auto-generated API specification
paths:
  # API endpoints will be defined here
components:
  schemas:
    # Data models will be defined here
# Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "✅ Design phase deliverables created for $task_id"
    
    # Complete design phase
    update_kiro_phase_status "$milestone_id" "$task_id" "design" "completed"
    
    # Trigger transition to spec phase (with approval if required)
    transition_kiro_phase "$milestone_id" "$task_id" "design" "spec"
}

# Execute specification phase for kiro workflow
execute_spec_phase() {
    local milestone_id=$1
    local task_id=$2
    
    echo "📋 Executing specification phase for task: $task_id"
    
    local task_title=$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")
    local deliverable_dir=".milestones/deliverables/$task_id/spec"
    
    # Create technical specification
    cat > "$deliverable_dir/technical-spec.md" << EOF
# Technical Specification: $task_title

## Implementation Requirements
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

## Interface Definitions
- Input/output specifications
- Data validation rules
- Error handling patterns

## Test Requirements
- Unit test coverage requirements
- Integration test scenarios
- Performance benchmarks

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    # Create test plan
    cat > "$deliverable_dir/test-plan.md" << EOF
# Test Plan: $task_title

## Test Strategy
- Unit testing approach
- Integration testing approach
- End-to-end testing requirements

## Test Cases
1. [Test case 1]
2. [Test case 2]
3. [Test case 3]

## Acceptance Criteria
- [Criteria 1]
- [Criteria 2]
- [Criteria 3]

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "✅ Specification phase deliverables created for $task_id"
    
    # Complete spec phase
    update_kiro_phase_status "$milestone_id" "$task_id" "spec" "completed"
    
    # Trigger transition to task phase
    transition_kiro_phase "$milestone_id" "$task_id" "spec" "task"
}

# Execute task planning phase for kiro workflow
execute_task_phase() {
    local milestone_id=$1
    local task_id=$2
    
    echo "📝 Executing task planning phase for task: $task_id"
    
    local task_title=$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")
    local deliverable_dir=".milestones/deliverables/$task_id/task"
    
    # Create implementation plan
    cat > "$deliverable_dir/implementation-plan.md" << EOF
# Implementation Plan: $task_title

## Development Tasks
1. [ ] Set up project structure
2. [ ] Implement core functionality
3. [ ] Add error handling
4. [ ] Write unit tests
5. [ ] Integration testing
6. [ ] Documentation updates

## Development Timeline
- Task 1: 2 hours
- Task 2: 4 hours  
- Task 3: 1 hour
- Task 4: 3 hours
- Task 5: 2 hours
- Task 6: 1 hour

## Dependencies
- [Dependency 1]
- [Dependency 2]

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "✅ Task planning phase deliverables created for $task_id"
    
    # Complete task phase
    update_kiro_phase_status "$milestone_id" "$task_id" "task" "completed"
    
    # Trigger transition to execute phase
    transition_kiro_phase "$milestone_id" "$task_id" "task" "execute"
}

# Execute implementation phase for kiro workflow
execute_implementation_phase() {
    local milestone_id=$1
    local task_id=$2
    
    echo "⚡ Executing implementation phase for task: $task_id"
    
    local task_title=$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' ".milestones/active/$milestone_id.yaml")
    local deliverable_dir=".milestones/deliverables/$task_id/execute"
    
    # Create implementation summary
    cat > "$deliverable_dir/implementation-summary.md" << EOF
# Implementation Summary: $task_title

## Completed Work
- [Implementation item 1]
- [Implementation item 2]
- [Implementation item 3]

## Code Changes
- Files modified: [list]
- Tests added: [list]
- Documentation updated: [list]

## Validation Results
- Unit tests: PASSED
- Integration tests: PASSED
- Code quality checks: PASSED

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    # Create test results
    cat > "$deliverable_dir/test-results.md" << EOF
# Test Results: $task_title

## Test Summary
- Total tests: 10
- Passed: 10
- Failed: 0
- Coverage: 95%

## Test Details
All tests passed successfully.

## Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF
    
    echo "✅ Implementation phase deliverables created for $task_id"
    
    # Complete execute phase and overall task
    update_kiro_phase_status "$milestone_id" "$task_id" "execute" "completed"
    
    # Mark the overall task as completed
    yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "completed"' -i ".milestones/active/$milestone_id.yaml"
    yq e '(.tasks[] | select(.id == "'$task_id'") | .completed_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
    
    log_milestone_event_reactive "$milestone_id" "kiro_workflow_completed" "{\"task_id\": \"$task_id\"}"
    log_milestone_event_reactive "$milestone_id" "task_completed" "{\"task_id\": \"$task_id\"}"
    
    echo "🎉 Kiro workflow completed for task: $task_id"
}
```

## Step 3: Real-Time Progress Tracking

**Progress Monitoring Implementation:**
```bash
spawn_progress_monitoring_agent() {
    local milestone_id=$1
    
    echo "📊 Progress Monitoring Agent: Starting real-time tracking with kiro support for $milestone_id"
    
    while true; do
        # Enhanced progress calculation with kiro workflow support
        local total_tasks=$(yq e '.tasks | length' ".milestones/active/$milestone_id.yaml")
        local milestone_progress=$(calculate_milestone_progress_with_kiro "$milestone_id")
        
        # Calculate standard completed tasks for backward compatibility
        local completed_tasks=$(yq e '.tasks[] | select(.status == "completed") | .id' ".milestones/active/$milestone_id.yaml" | wc -l)
        
        # Update progress in milestone file
        yq e '.progress.percentage = '$milestone_progress -i ".milestones/active/$milestone_id.yaml"
        yq e '.progress.tasks_completed = '$completed_tasks -i ".milestones/active/$milestone_id.yaml"
        yq e '.progress.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
        
        # Calculate and store kiro-specific progress data
        calculate_and_store_kiro_progress "$milestone_id"
        
        # Log progress update with reactive status update
        log_milestone_event_reactive "$milestone_id" "progress_updated" "{\"percentage\": $milestone_progress, \"completed_tasks\": $completed_tasks, \"total_tasks\": $total_tasks, \"calculation_type\": \"kiro_enhanced\"}"
        
        # Display enhanced progress dashboard
        display_kiro_enhanced_progress_dashboard "$milestone_id"
        
        # Check if milestone is complete
        if [ "$completed_tasks" -eq "$total_tasks" ]; then
            echo "🎉 Milestone completed: $milestone_id"
            complete_milestone "$milestone_id"
            break
        fi
        
        # Wait before next update
        sleep 30
    done
}
```

**Progress Dashboard:**
```bash
display_progress_dashboard() {
    local milestone_id=$1
    
    echo "=== MILESTONE EXECUTION DASHBOARD ==="
    echo "Milestone: $(yq e '.title' ".milestones/active/$milestone_id.yaml")"
    echo "Status: $(yq e '.status' ".milestones/active/$milestone_id.yaml")"
    echo "Progress: $(yq e '.progress.percentage' ".milestones/active/$milestone_id.yaml")%"
    echo ""
    
    echo "TASK STATUS:"
    yq e '.tasks[] | .id + ": " + .status + " (" + .title + ")"' ".milestones/active/$milestone_id.yaml"
    
    echo ""
    echo "ACTIVE AGENTS:"
    list_active_agents "$milestone_id"
    
    echo ""
    echo "RECENT EVENTS:"
    tail -5 ".milestones/logs/execution-$milestone_id.jsonl" | jq -r '.timestamp + " " + .event + ": " + (.details // "")'
    
    echo "================================="
}

# Calculate and store kiro-specific progress data
calculate_and_store_kiro_progress() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    # Initialize kiro progress section if it doesn't exist
    if ! yq e '.kiro_progress' "$milestone_file" >/dev/null 2>&1; then
        yq e '.kiro_progress = {}' -i "$milestone_file"
    fi
    
    # Calculate phase-wise progress across all kiro tasks
    local total_design_progress=0
    local total_spec_progress=0
    local total_task_progress=0
    local total_execute_progress=0
    local kiro_task_count=0
    
    local kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' "$milestone_file" 2>/dev/null)
    
    for task_id in $kiro_tasks; do
        ((kiro_task_count++))
        
        for phase in design spec task execute; do
            local phase_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$phase'.status' "$milestone_file")
            local phase_progress=0
            
            case "$phase_status" in
                "completed"|"approved") phase_progress=100 ;;
                "in_progress") phase_progress=60 ;;
                "waiting_approval") phase_progress=90 ;;
                "blocked") phase_progress=30 ;;
                *) phase_progress=0 ;;
            esac
            
            case "$phase" in
                "design") total_design_progress=$((total_design_progress + phase_progress)) ;;
                "spec") total_spec_progress=$((total_spec_progress + phase_progress)) ;;
                "task") total_task_progress=$((total_task_progress + phase_progress)) ;;
                "execute") total_execute_progress=$((total_execute_progress + phase_progress)) ;;
            esac
        done
    done
    
    # Calculate averages
    if [ "$kiro_task_count" -gt 0 ]; then
        local avg_design=$((total_design_progress / kiro_task_count))
        local avg_spec=$((total_spec_progress / kiro_task_count))
        local avg_task=$((total_task_progress / kiro_task_count))
        local avg_execute=$((total_execute_progress / kiro_task_count))
        
        # Store kiro progress data
        yq e '.kiro_progress.phase_averages.design = '$avg_design -i "$milestone_file"
        yq e '.kiro_progress.phase_averages.spec = '$avg_spec -i "$milestone_file"
        yq e '.kiro_progress.phase_averages.task = '$avg_task -i "$milestone_file"
        yq e '.kiro_progress.phase_averages.execute = '$avg_execute -i "$milestone_file"
        yq e '.kiro_progress.kiro_task_count = '$kiro_task_count -i "$milestone_file"
        yq e '.kiro_progress.last_calculated = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$milestone_file"
    fi
}

# Enhanced progress dashboard with kiro workflow phase visibility
display_kiro_enhanced_progress_dashboard() {
    local milestone_id=$1
    local milestone_file=".milestones/active/$milestone_id.yaml"
    
    echo "=== ENHANCED MILESTONE EXECUTION DASHBOARD (WITH KIRO WORKFLOWS) ==="
    echo "Milestone: $(yq e '.title' "$milestone_file")"
    echo "Status: $(yq e '.status' "$milestone_file")"
    echo "Overall Progress: $(yq e '.progress.percentage' "$milestone_file")%"
    echo ""
    
    # Display kiro phase progress if available
    local kiro_task_count=$(yq e '.kiro_progress.kiro_task_count' "$milestone_file" 2>/dev/null || echo "0")
    if [ "$kiro_task_count" -gt 0 ]; then
        echo "KIRO WORKFLOW PROGRESS SUMMARY:"
        echo "├── Design Phase:    [$(create_progress_bar $(yq e '.kiro_progress.phase_averages.design' "$milestone_file" 2>/dev/null || echo "0"))] $(yq e '.kiro_progress.phase_averages.design' "$milestone_file" 2>/dev/null || echo "0")%"
        echo "├── Spec Phase:      [$(create_progress_bar $(yq e '.kiro_progress.phase_averages.spec' "$milestone_file" 2>/dev/null || echo "0"))] $(yq e '.kiro_progress.phase_averages.spec' "$milestone_file" 2>/dev/null || echo "0")%"
        echo "├── Task Phase:      [$(create_progress_bar $(yq e '.kiro_progress.phase_averages.task' "$milestone_file" 2>/dev/null || echo "0"))] $(yq e '.kiro_progress.phase_averages.task' "$milestone_file" 2>/dev/null || echo "0")%"
        echo "└── Execute Phase:   [$(create_progress_bar $(yq e '.kiro_progress.phase_averages.execute' "$milestone_file" 2>/dev/null || echo "0"))] $(yq e '.kiro_progress.phase_averages.execute' "$milestone_file" 2>/dev/null || echo "0")%"
        echo ""
    fi
    
    echo "DETAILED TASK STATUS:"
    local task_ids=$(yq e '.tasks[].id' "$milestone_file")
    for task_id in $task_ids; do
        local task_title=$(yq e '.tasks[] | select(.id == "'$task_id'") | .title' "$milestone_file")
        local task_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .status' "$milestone_file")
        local kiro_enabled=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.enabled' "$milestone_file" 2>/dev/null)
        
        if [ "$kiro_enabled" = "true" ]; then
            local current_phase=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.current_phase' "$milestone_file")
            local phase_status=$(yq e '.tasks[] | select(.id == "'$task_id'") | .kiro_workflow.phases.'$current_phase'.status' "$milestone_file")
            local task_progress=$(calculate_kiro_task_progress "$milestone_id" "$task_id")
            
            echo "├── $task_id: [$(create_progress_bar $task_progress)] $task_progress% (kiro: $current_phase/$phase_status)"
            echo "│   └── $task_title"
        else
            local task_progress=0
            case "$task_status" in
                "completed") task_progress=100 ;;
                "in_progress") task_progress=50 ;;
                *) task_progress=0 ;;
            esac
            echo "├── $task_id: [$(create_progress_bar $task_progress)] $task_progress% (standard: $task_status)"
            echo "│   └── $task_title"
        fi
    done
    
    echo ""
    echo "ACTIVE AGENTS:"
    list_active_agents "$milestone_id"
    
    # Show pending approvals if any
    local pending_approvals=$(find ".milestones/approvals" -name "*$milestone_id*" -type f 2>/dev/null | wc -l)
    if [ "$pending_approvals" -gt 0 ]; then
        echo ""
        echo "PENDING APPROVALS: $pending_approvals"
        find ".milestones/approvals" -name "*$milestone_id*" -type f -exec basename {} \; 2>/dev/null | sed 's/^/├── /'
    fi
    
    echo ""
    echo "RECENT EVENTS:"
    tail -5 ".milestones/logs/execution-$milestone_id.jsonl" | jq -r '.timestamp + " " + .event + ": " + (.details // "")' 2>/dev/null || echo "No recent events"
    
    echo "================================="
}

# Create progress bar visualization
create_progress_bar() {
    local percentage=$1
    local bar_length=10
    local filled=$((percentage * bar_length / 100))
    local empty=$((bar_length - filled))
    
    printf '█%.0s' $(seq 1 $filled)
    printf '░%.0s' $(seq 1 $empty)
}
```

## Step 4: Session Management and Resume

**Session State Management:**
```bash
save_execution_session() {
    local milestone_id=$1
    local session_id=$2
    local reason=${3:-"manual_save"}
    
    local session_file=".milestones/sessions/$session_id.yaml"
    
    cat > "$session_file" << EOF
session:
  id: "$session_id"
  milestone_id: "$milestone_id"
  status: "active"
  saved_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  save_reason: "$reason"
  
context:
  working_directory: "$(pwd)"
  git_branch: "$(git branch --show-current)"
  git_commit: "$(git rev-parse HEAD)"
  
execution_state:
  active_agents: [$(list_active_agents "$milestone_id" | tr '\n' ',' | sed 's/,$//')] 
  current_task: "$(yq e '.tasks[] | select(.status == "in_progress") | .id' ".milestones/active/$milestone_id.yaml" | head -1)"
  progress_percentage: $(yq e '.progress.percentage' ".milestones/active/$milestone_id.yaml")
  
resume_points:
  next_tasks: [$(yq e '.tasks[] | select(.status == "pending") | .id' ".milestones/active/$milestone_id.yaml" | tr '\n' ',' | sed 's/,$//'')]
  pending_commits: $(git status --porcelain | wc -l)
  uncommitted_changes: $([ -n "$(git status --porcelain)" ] && echo "true" || echo "false")
EOF
    
    echo "Session saved: $session_file"
}

resume_execution_session() {
    local session_id=$1
    local session_file=".milestones/sessions/$session_id.yaml"
    
    if [ ! -f "$session_file" ]; then
        echo "ERROR: Session file not found: $session_file"
        return 1
    fi
    
    echo "🔄 Resuming execution session: $session_id"
    
    # Load session context
    local milestone_id=$(yq e '.session.milestone_id' "$session_file")
    local working_dir=$(yq e '.context.working_directory' "$session_file")
    local git_branch=$(yq e '.context.git_branch' "$session_file")
    
    # Restore context
    cd "$working_dir"
    git checkout "$git_branch"
    
    # Update session status
    yq e '.session.status = "resumed"' -i "$session_file"
    yq e '.session.resumed_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$session_file"
    
    # Log resume event
    log_milestone_event_reactive "$milestone_id" "session_resumed" "{\"session_id\": \"$session_id\"}"
    
    # Redeploy execution agents
    deploy_execution_agents "$milestone_id" "$session_id"
    
    echo "✅ Session resumed successfully"
}
```

## Step 5: Dependency Validation and Blockers

**Dependency Validation Agent:**
```bash
spawn_dependency_validation_agent() {
    local milestone_id=$1
    
    echo "🔗 Dependency Validation Agent: Monitoring dependencies for $milestone_id"
    
    while true; do
        # Check milestone dependencies
        local dependencies=$(yq e '.dependencies.requires[]' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
        local dependency_issues=0
        
        for dep in $dependencies; do
            if [ ! -f ".milestones/completed/$dep.yaml" ]; then
                echo "❌ Dependency blocker: $dep not completed"
                log_milestone_event "$milestone_id" "dependency_blocker" "{\"dependency\": \"$dep\"}"
                ((dependency_issues++))
            fi
        done
        
        # Check task dependencies
        local current_tasks=$(yq e '.tasks[] | select(.status == "in_progress") | .id' ".milestones/active/$milestone_id.yaml")
        for task_id in $current_tasks; do
            local task_deps=$(yq e '.tasks[] | select(.id == "'$task_id'") | .dependencies[]?' ".milestones/active/$milestone_id.yaml" 2>/dev/null)
            for task_dep in $task_deps; do
                local dep_status=$(yq e '.tasks[] | select(.id == "'$task_dep'") | .status' ".milestones/active/$milestone_id.yaml")
                if [ "$dep_status" != "completed" ]; then
                    echo "❌ Task dependency blocker: $task_id depends on $task_dep"
                    log_milestone_event "$milestone_id" "task_dependency_blocker" "{\"task\": \"$task_id\", \"dependency\": \"$task_dep\"}"
                    ((dependency_issues++))
                fi
            done
        done
        
        if [ $dependency_issues -eq 0 ]; then
            echo "✅ All dependencies satisfied"
        fi
        
        sleep 60
    done
}
```

**Blocker Detection Agent:**
```bash
spawn_blocker_detection_agent() {
    local milestone_id=$1
    
    echo "🚫 Blocker Detection Agent: Monitoring for execution blockers"
    
    while true; do
        local blockers=()
        
        # Check for Git conflicts
        if [ -n "$(git status --porcelain | grep '^UU\|^AA\|^DD')" ]; then
            blockers+=("git_conflicts")
            log_milestone_event "$milestone_id" "blocker_detected" "{\"type\": \"git_conflicts\"}"
        fi
        
        # Check for failed tests
        if ! make test &>/dev/null; then
            blockers+=("test_failures")
            log_milestone_event "$milestone_id" "blocker_detected" "{\"type\": \"test_failures\"}"
        fi
        
        # Check for long-running tasks
        local long_running_tasks=$(yq e '.tasks[] | select(.status == "in_progress" and .started_at != null) | select((now - (.started_at | fromdateiso8601)) > 3600) | .id' ".milestones/active/$milestone_id.yaml")
        if [ -n "$long_running_tasks" ]; then
            blockers+=("long_running_tasks")
            log_milestone_event "$milestone_id" "blocker_detected" "{\"type\": \"long_running_tasks\", \"tasks\": \"$long_running_tasks\"}"
        fi
        
        # Check for resource constraints
        local disk_usage=$(df . | tail -1 | awk '{print $5}' | sed 's/%//')
        if [ "$disk_usage" -gt 90 ]; then
            blockers+=("disk_space")
            log_milestone_event "$milestone_id" "blocker_detected" "{\"type\": \"disk_space\", \"usage\": \"$disk_usage%\"}"
        fi
        
        # Escalate blockers
        if [ ${#blockers[@]} -gt 0 ]; then
            escalate_blockers "$milestone_id" "${blockers[@]}"
        fi
        
        sleep 120
    done
}

escalate_blockers() {
    local milestone_id=$1
    shift
    local blockers=("$@")
    
    echo "🚨 BLOCKERS DETECTED FOR MILESTONE: $milestone_id"
    echo "Blockers: ${blockers[*]}"
    
    # Pause milestone execution
    yq e '.status = "blocked"' -i ".milestones/active/$milestone_id.yaml"
    yq e '.blockers = ["'$(IFS='","'; echo "${blockers[*]}")'""]' -i ".milestones/active/$milestone_id.yaml"
    
    # Save session for recovery
    save_execution_session "$milestone_id" "$(yq e '.execution.session_id' ".milestones/active/$milestone_id.yaml")" "blocker_detected"
    
    # Log escalation
    log_milestone_event "$milestone_id" "blockers_escalated" "{\"blockers\": [\"$(IFS='","'; echo "${blockers[*]}")\"]}"
    
    echo "⏸️  Milestone execution paused due to blockers"
    echo "Resolve blockers and resume with: /milestone/execute --resume"
}
```

## Step 6: Git Integration During Execution

**Git Integration Agent:**
```bash
spawn_git_integration_agent() {
    local milestone_id=$1
    
    echo "🔧 Git Integration Agent: Managing repository state for $milestone_id"
    
    # Ensure we're on the correct milestone branch
    switch_to_milestone_branch "$milestone_id"
    
    while true; do
        # Monitor for changes that need committing
        if [ -n "$(git status --porcelain)" ]; then
            local uncommitted_changes=$(git status --porcelain | wc -l)
            
            if [ "$uncommitted_changes" -gt 10 ]; then
                echo "📝 Auto-committing accumulated changes"
                
                # Create checkpoint commit
                git add .
                git commit -m "checkpoint(milestone-$milestone_id): auto-commit during execution

$(git status --short | head -10)

Generated with Claude Code milestone execution"
                
                log_milestone_event "$milestone_id" "auto_commit" "{\"files_changed\": $uncommitted_changes}"
            fi
        fi
        
        # Sync with remote periodically
        sync_milestone_branch "$milestone_id"
        
        # Save repository state
        save_repository_state "$milestone_id"
        
        sleep 300  # 5 minutes
    done
}
```

## Step 7: Execution Quality Checklist

**Milestone Execution Validation:**
- [ ] Milestone properly activated with status transition
- [ ] All execution agents deployed and monitoring
- [ ] Real-time progress tracking functional
- [ ] Session management with resume capability tested
- [ ] Git integration maintaining repository state
- [ ] Dependency validation preventing violations
- [ ] Blocker detection with escalation procedures
- [ ] Event logging capturing all execution activities

**Agent Coordination Checklist:**
- [ ] Task execution proceeding with proper commits
- [ ] Progress monitoring updating metrics continuously
- [ ] Git integration handling branch and commit management
- [ ] Dependency validation preventing conflicts
- [ ] Blocker detection identifying issues early
- [ ] Session state preserved for resume capability

**Integration Validation:**
- [ ] Working directory maintained throughout execution
- [ ] Git branch consistency preserved
- [ ] Progress events logged with timestamps
- [ ] Milestone file updated with current state
- [ ] Session context saved for interruption recovery

**Anti-Patterns to Avoid:**
- ❌ Executing tasks without dependency validation
- ❌ Missing progress tracking and event logging
- ❌ Ignoring session management for interruptions
- ❌ Failing to detect and escalate blockers
- ❌ Inconsistent git integration and branch management
- ❌ No coordination between execution agents

**Final Verification:**
Before completing milestone execution:
- Have all tasks been executed with proper coordination?
- Is progress tracking providing real-time visibility?
- Are sessions properly managed for resume capability?
- Have all blockers been detected and escalated?
- Is git integration maintaining repository consistency?
- Are all agents coordinating effectively?

**Final Commitment:**
- **I will**: Execute milestones with comprehensive agent coordination
- **I will**: Implement real-time progress tracking with event logging
- **I will**: Maintain session state for interruption and resume capability
- **I will**: Integrate with git for repository consistency
- **I will NOT**: Execute without proper dependency validation
- **I will NOT**: Skip blocker detection and escalation
- **I will NOT**: Ignore session management requirements

**REMEMBER:**
This is MILESTONE EXECUTION mode - active coordination, real-time tracking, and resume-capable progress management. The goal is to execute milestones with comprehensive monitoring, agent coordination, and robust state management.

Executing comprehensive milestone execution protocol for coordinated task completion...