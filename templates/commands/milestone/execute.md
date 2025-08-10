---
allowed-tools: all
description: Comprehensive milestone execution with multi-agent coordination, progress tracking, and session management
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: KIRO-NATIVE MILESTONE EXECUTION MODE ⚡⚡⚡

**THIS IS KIRO WORKFLOW EXECUTION - ALL TASKS FOLLOW THE 4-PHASE METHODOLOGY!**

When you run `/milestone/execute`, you are REQUIRED to:

1. **ACTIVATE** - Transition milestone to active state with kiro validation
2. **VALIDATE** - Ensure all tasks have mandatory kiro workflow structure
3. **EXECUTE PHASES** - Progress through Design→Spec→Task→Execute for each task
4. **VALIDATE DELIVERABLES** - Check phase deliverables before transitions
5. **MANAGE APPROVALS** - Handle approval gates at critical phase transitions
6. **TRACK KIRO PROGRESS** - Monitor phase-weighted progress (15/25/20/40%)
7. **VISUALIZE** - Display kiro workflow status and phase progression

## 🎯 USE MULTIPLE AGENTS FOR EXECUTION

**MANDATORY KIRO-AWARE AGENT COORDINATION:**
```
"I'll spawn kiro-native execution agents for phase-based task execution:
- Kiro Phase Agent: Execute tasks through 4-phase workflow progression
- Deliverable Validation Agent: Validate phase deliverables before transitions
- Approval Workflow Agent: Manage approval gates and waiting states
- Kiro Progress Agent: Track phase-weighted progress and visualization
- Git Integration Agent: Commit phase deliverables and track changes
- Session Management Agent: Handle phase resumption and state persistence"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Start execution without proper milestone activation → NO! Validate state first!
- ❌ Execute tasks without dependency validation → NO! Check prerequisites!
- ❌ Ignore working directory integration → NO! Maintain git consistency!
- ❌ Skip progress tracking and logging → NO! Real-time monitoring required!
- ❌ Execute without session management → NO! Resume capability essential!
- ❌ Continue execution with unresolved blockers → NO! Escalate immediately!

**MANDATORY KIRO EXECUTION WORKFLOW:**
```
1. Kiro compliance validation → Ensure all tasks have kiro workflow enabled
2. IMMEDIATELY spawn kiro-aware agents for phase-based execution
3. Activate milestone → Transition to active with kiro enforcement
4. Execute kiro phases → Design→Spec→Task→Execute with validation
5. Validate deliverables → Check phase outputs before transitions
6. Handle approvals → Manage approval gates and waiting states
7. Track kiro progress → Phase-weighted monitoring and visualization
8. VERIFY all phases complete and deliverables validated
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

**Kiro-Native Milestone Execution Protocol:**

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
    if [ "$status" != "planned" ] && [ "$status" != "paused" ] && [ "$status" != "in_progress" ]; then
        echo "ERROR: Milestone status '$status' does not allow execution"
        return 1
    fi
    
    # Validate kiro compliance
    echo "🔒 Validating kiro workflow compliance..."
    source "templates/commands/milestone/_shared/kiro-native.md"
    enforce_kiro_compliance "$milestone_id" "strict"
    
    if [ $? -ne 0 ]; then
        echo "❌ ERROR: Milestone not kiro-compliant. Migrating tasks..."
        # Auto-migrate non-kiro tasks
        local non_kiro_tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled != true) | .id' ".milestones/active/$milestone_id.yaml")
        for task_id in $non_kiro_tasks; do
            migrate_task_to_kiro "$milestone_id" "$task_id"
        done
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
    
    # Source shared utilities including kiro-native
    source "templates/commands/milestone/_shared/context.md"
    source "templates/commands/milestone/_shared/git-integration.md"
    source "templates/commands/milestone/_shared/state.md"
    source "templates/commands/milestone/_shared/kiro-native.md"
    source "templates/commands/milestone/_shared/kiro-visualizer.md"
    
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
    
    # Kiro Phase Execution Agent
    register_agent "kiro-executor-$session_id" "kiro_executor" "$milestone_id"
    spawn_task_execution_agent "$milestone_id" &
    
    # Kiro Progress Monitoring Agent
    register_agent "kiro-progress-$session_id" "kiro_progress" "$milestone_id"
    spawn_progress_monitoring_agent "$milestone_id" &
    
    # Deliverable Validation Agent
    register_agent "deliverable-validator-$session_id" "deliverable_validator" "$milestone_id"
    spawn_deliverable_validation_agent "$milestone_id" &
    
    # Approval Workflow Agent
    register_agent "approval-manager-$session_id" "approval_manager" "$milestone_id"
    spawn_approval_workflow_agent "$milestone_id" &
    
    # Git Integration Agent
    register_agent "git-integration-$session_id" "git_integration" "$milestone_id"
    spawn_git_integration_agent "$milestone_id" &
    
    echo "✅ All execution agents deployed"
}
```

**Kiro Phase Execution Agent:**
```bash
spawn_task_execution_agent() {
    local milestone_id=$1
    
    echo "🔧 Kiro Execution Agent: Starting phase-based task execution for $milestone_id"
    
    # Get all kiro-enabled tasks
    local tasks=$(yq e '.tasks[] | select(.kiro_workflow.enabled == true) | .id' ".milestones/active/$milestone_id.yaml")
    
    for task_id in $tasks; do
        echo "📋 Executing kiro workflow for task: $task_id"
        
        # Execute through kiro phases
        execute_kiro_workflow "$milestone_id" "$task_id"
    done
    
    echo "✅ Kiro Execution Agent: All task phases processed"
}

# Execute task through kiro workflow phases
execute_kiro_workflow() {
    local milestone_id=$1
    local task_id=$2
    
    # Get current phase
    local current_phase=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.current_phase" ".milestones/active/$milestone_id.yaml")
    
    # Execute phases in sequence
    local phases=("design" "spec" "task" "execute")
    local phase_index=0
    
    # Find starting phase index
    for i in "${!phases[@]}"; do
        if [ "${phases[$i]}" = "$current_phase" ]; then
            phase_index=$i
            break
        fi
    done
    
    # Execute from current phase onwards
    for ((i=phase_index; i<${#phases[@]}; i++)); do
        local phase="${phases[$i]}"
        
        echo "🎯 Starting $phase phase for task $task_id"
        
        # Start phase
        start_kiro_phase "$milestone_id" "$task_id" "$phase"
        
        # Execute phase work (simplified - in real implementation would execute actual work)
        echo "   🔨 Executing $phase phase activities..."
        sleep 2  # Simulate work
        
        # Complete phase with deliverable validation
        if complete_kiro_phase "$milestone_id" "$task_id" "$phase"; then
            echo "   ✅ Phase $phase completed"
            
            # Check if approval needed
            local approval_required=$(yq e ".tasks[] | select(.id == \"$task_id\") | .kiro_workflow.phases.$phase.approval_required" ".milestones/active/$milestone_id.yaml")
            
            if [ "$approval_required" = "true" ]; then
                echo "   🔐 Waiting for approval..."
                # In real implementation, would wait for actual approval
                # For now, auto-approve after brief wait
                sleep 1
                approve_kiro_phase "$milestone_id" "$task_id" "$phase" "auto-approver" "Auto-approved for execution"
            fi
        else
            echo "   ❌ Phase $phase validation failed - check deliverables"
            return 1
        fi
    done
    
    # Mark task as completed
    yq e '(.tasks[] | select(.id == "'$task_id'") | .status) = "completed"' -i ".milestones/active/$milestone_id.yaml"
    yq e '(.tasks[] | select(.id == "'$task_id'") | .completed_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
    
    # Log completion
    log_milestone_event_reactive "$milestone_id" "kiro_task_completed" "{\"task_id\": \"$task_id\", \"phases_completed\": 4}"
    
    echo "🎆 Task $task_id completed all kiro phases!"
}
```

## Step 3: Real-Time Progress Tracking

**Progress Monitoring Implementation:**
```bash
spawn_progress_monitoring_agent() {
    local milestone_id=$1
    
    echo "📊 Kiro Progress Agent: Starting phase-weighted tracking for $milestone_id"
    
    while true; do
        # Calculate kiro-weighted progress
        local progress_percentage=$(calculate_kiro_milestone_progress "$milestone_id")
        local completed_tasks=$(yq e '.tasks[] | select(.status == "completed") | .id' ".milestones/active/$milestone_id.yaml" | wc -l)
        local total_tasks=$(yq e '.tasks | length' ".milestones/active/$milestone_id.yaml")
        
        # Update progress in milestone file
        yq e '.progress.percentage = '$progress_percentage -i ".milestones/active/$milestone_id.yaml"
        yq e '.progress.tasks_completed = '$completed_tasks -i ".milestones/active/$milestone_id.yaml"
        yq e '.progress.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".milestones/active/$milestone_id.yaml"
        
        # Log progress update with reactive status update
        log_milestone_event_reactive "$milestone_id" "progress_updated" "{\"percentage\": $progress_percentage, \"completed_tasks\": $completed_tasks, \"total_tasks\": $total_tasks}"
        
        # Display kiro progress visualization
        visualize_kiro_dashboard "$milestone_id" "all"
        
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