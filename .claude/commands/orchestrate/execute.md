---
allowed-tools: all
description: Comprehensive orchestration execution with multi-agent coordination, workflow management, and session monitoring
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: ORCHESTRATION EXECUTION MODE ENGAGED ⚡⚡⚡

**THIS IS NOT A PLANNING TASK - THIS IS ACTIVE ORCHESTRATION EXECUTION AND COORDINATION!**

When you run `/orchestrate/execute`, you are REQUIRED to:

1. **ACTIVATE** - Transition orchestration from planned to active execution state
2. **COORDINATE** - Deploy multi-agent workflow execution with real-time monitoring
3. **TRACK** - Implement continuous coordination tracking with event logging
4. **INTEGRATE** - Ensure seamless working directory and git integration
5. **MANAGE** - Maintain session state for interruption and resume capability
6. **VALIDATE** - Enforce workflow dependencies and detect coordination blockers
7. **ESCALATE** - Handle blockers and coordinate resolution strategies

## 🎯 USE MULTIPLE AGENTS FOR ORCHESTRATION

**MANDATORY AGENT COORDINATION FOR ORCHESTRATION EXECUTION:**
```
"I'll spawn multiple orchestration agents to handle workflow coordination in parallel:
- Workflow Execution Agent: Execute specific orchestration phases and track completion
- Coordination Monitoring Agent: Real-time coordination tracking and event logging
- Git Integration Agent: Handle branch management, commits, and repository state
- Dependency Validation Agent: Monitor and enforce workflow dependencies
- Blocker Detection Agent: Identify coordination blockers and orchestrate resolution
- Session Management Agent: Handle interruptions and resume capabilities"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Start execution without proper orchestration activation → NO! Validate state first!
- ❌ Execute workflows without dependency validation → NO! Check prerequisites!
- ❌ Ignore working directory integration → NO! Maintain git consistency!
- ❌ Skip coordination tracking and logging → NO! Real-time monitoring required!
- ❌ Execute without session management → NO! Resume capability essential!
- ❌ Continue execution with unresolved blockers → NO! Escalate immediately!

**MANDATORY EXECUTION WORKFLOW:**
```
1. Orchestration state validation → Ensure prerequisites and dependencies met
2. IMMEDIATELY spawn execution agents for parallel workflow coordination
3. Activate orchestration → Transition from planned to active state
4. Execute workflows → Multi-agent coordination with real-time tracking
5. Monitor coordination → Continuous event logging and status updates
6. Handle blockers → Detection, escalation, and resolution coordination
7. VERIFY execution completion and orchestration state integrity
```

**YOU ARE NOT DONE UNTIL:**
- ✅ Orchestration activated and in execution state
- ✅ Multi-agent workflow coordination deployed
- ✅ Real-time coordination tracking implemented
- ✅ Working directory and git integration active
- ✅ Session management with resume capability functional
- ✅ All blockers identified and escalated appropriately

---

🛑 **MANDATORY EXECUTION VALIDATION CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Validate current orchestration state and dependencies
3. Confirm working directory and git integration requirements

Execute comprehensive orchestration execution with ZERO tolerance for incomplete coordination.

**FORBIDDEN EXECUTION PATTERNS:**
- "Let's just run the workflows sequentially" → NO, multi-agent coordination required
- "Simple coordination tracking is enough" → NO, real-time event logging needed
- "We don't need session management" → NO, resume capability essential
- "Manual blocker handling is fine" → NO, automated detection required
- "Git integration can be manual" → NO, integrated repository management needed

You are executing orchestration: $ARGUMENTS

Let me ultrathink about the comprehensive execution architecture and coordination system.

🚨 **REMEMBER: Effective orchestration requires coordination, not just workflow completion!** 🚨

**Comprehensive Orchestration Execution Protocol:**

## Step 0: Execution Prerequisites Validation

**Validate Orchestration State:**
```bash
# Verify orchestration exists and is ready for execution
validate_orchestration_state() {
    local orchestration_id=$1
    
    echo "=== Orchestration Execution Prerequisites ==="
    
    # Check orchestration file exists
    if [ ! -f ".orchestration/sessions/$orchestration_id.yaml" ]; then
        echo "ERROR: Orchestration not found: $orchestration_id"
        return 1
    fi
    
    # Validate status allows execution
    local status=$(yq e '.status' ".orchestration/sessions/$orchestration_id.yaml")
    if [ "$status" != "planned" ] && [ "$status" != "paused" ]; then
        echo "ERROR: Orchestration status '$status' does not allow execution"
        return 1
    fi
    
    # Check dependencies are met
    local dependencies=$(yq e '.dependencies.requires[]' ".orchestration/sessions/$orchestration_id.yaml" 2>/dev/null)
    for dep in $dependencies; do
        if [ ! -f ".orchestration/completed/$dep.yaml" ]; then
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
setup_orchestration_environment() {
    local orchestration_id=$1
    
    # Source shared utilities
    source ".claude/commands/orchestrate/../../shared/context.md"
    source ".claude/commands/orchestrate/../../shared/git-integration.md"
    
    # Create execution directories
    mkdir -p ".orchestration/sessions"
    mkdir -p ".orchestration/logs"
    mkdir -p ".orchestration/coordination"
    mkdir -p ".orchestration/coordination/agents"
    
    # Initialize git integration
    validate_orchestration_branch "$orchestration_id"
    
    # Create session context
    local session_id=$(generate_orchestration_session_id)
    save_orchestration_context "$session_id"
    
    echo "Orchestration environment ready: $session_id"
    return 0
}
```

## Step 1: Orchestration Activation Protocol

**Activate Orchestration for Execution:**
```yaml
orchestration_activation:
  pre_activation:
    - validate_dependencies: true
    - check_git_state: true
    - verify_working_directory: true
    - initialize_session: true
    
  activation_process:
    - update_status: "coordinating"
    - set_start_timestamp: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    - create_execution_log: ".orchestration/logs/coordination-${orchestration_id}.jsonl"
    - initialize_coordination_tracking: true
    
  post_activation:
    - log_activation_event: true
    - notify_dependent_orchestrations: true
    - setup_monitoring: true
```

**Activation Implementation:**
```bash
activate_orchestration() {
    local orchestration_id=$1
    local session_id=$2
    
    echo "⚡ Activating orchestration for execution: $orchestration_id"
    
    # Update orchestration status
    yq e '.status = "coordinating"' -i ".orchestration/sessions/$orchestration_id.yaml"
    yq e '.execution.started_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".orchestration/sessions/$orchestration_id.yaml"
    yq e '.execution.session_id = "'$session_id'"' -i ".orchestration/sessions/$orchestration_id.yaml"
    
    # Initialize coordination tracking
    yq e '.coordination.percentage = 0' -i ".orchestration/sessions/$orchestration_id.yaml"
    yq e '.coordination.phases_completed = 0' -i ".orchestration/sessions/$orchestration_id.yaml"
    yq e '.coordination.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".orchestration/sessions/$orchestration_id.yaml"
    
    # Create execution log
    local log_file=".orchestration/logs/coordination-$orchestration_id.jsonl"
    echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","event":"orchestration_activated","orchestration_id":"'$orchestration_id'","session_id":"'$session_id'"}' >> "$log_file"
    
    # Set current orchestration marker
    echo "$orchestration_id" > ".orchestration/sessions/current.txt"
    
    echo "✅ Orchestration activated: $orchestration_id"
}
```

## Step 2: Multi-Agent Workflow Coordination

**Agent Deployment Strategy:**
```bash
deploy_orchestration_agents() {
    local orchestration_id=$1
    local session_id=$2
    
    echo "🤖 Deploying orchestration agents for workflow: $orchestration_id"
    
    # Workflow Execution Agent
    register_agent "workflow-executor-$session_id" "workflow_executor" "$orchestration_id"
    spawn_workflow_execution_agent "$orchestration_id" &
    
    # Coordination Monitoring Agent
    register_agent "coordination-monitor-$session_id" "coordination_monitor" "$orchestration_id"
    spawn_coordination_monitoring_agent "$orchestration_id" &
    
    # Git Integration Agent
    register_agent "git-integration-$session_id" "git_integration" "$orchestration_id"
    spawn_git_integration_agent "$orchestration_id" &
    
    # Dependency Validation Agent
    register_agent "dependency-validator-$session_id" "dependency_validator" "$orchestration_id"
    spawn_dependency_validation_agent "$orchestration_id" &
    
    # Blocker Detection Agent
    register_agent "blocker-detector-$session_id" "blocker_detector" "$orchestration_id"
    spawn_blocker_detection_agent "$orchestration_id" &
    
    echo "✅ All orchestration agents deployed"
}
```

**Workflow Execution Agent:**
```bash
spawn_workflow_execution_agent() {
    local orchestration_id=$1
    
    echo "🔧 Workflow Execution Agent: Starting coordination for $orchestration_id"
    
    # Get pending workflow phases
    local phases=$(yq e '.workflow.phases[] | select(.status == "pending") | .id' ".orchestration/sessions/$orchestration_id.yaml")
    
    for phase_id in $phases; do
        echo "📋 Executing workflow phase: $phase_id"
        
        # Update phase status
        yq e '(.workflow.phases[] | select(.id == "'$phase_id'") | .status) = "coordinating"' -i ".orchestration/sessions/$orchestration_id.yaml"
        yq e '(.workflow.phases[] | select(.id == "'$phase_id'") | .started_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".orchestration/sessions/$orchestration_id.yaml"
        
        # Log phase start
        log_orchestration_event "$orchestration_id" "phase_started" "{\"phase_id\": \"$phase_id\"}"
        
        # Execute workflow phase (placeholder for actual coordination execution)
        execute_orchestration_phase "$orchestration_id" "$phase_id"
        
        # Update phase completion
        yq e '(.workflow.phases[] | select(.id == "'$phase_id'") | .status) = "completed"' -i ".orchestration/sessions/$orchestration_id.yaml"
        yq e '(.workflow.phases[] | select(.id == "'$phase_id'") | .completed_at) = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".orchestration/sessions/$orchestration_id.yaml"
        
        # Log phase completion
        log_orchestration_event "$orchestration_id" "phase_completed" "{\"phase_id\": \"$phase_id\"}"
        
        # Create orchestration commit
        create_orchestration_commit "$orchestration_id" "$phase_id" "Complete phase: $(yq e '.workflow.phases[] | select(.id == "'$phase_id'") | .title' ".orchestration/sessions/$orchestration_id.yaml")"
    done
    
    echo "✅ Workflow Execution Agent: All phases processed"
}
```

## Step 3: Real-Time Coordination Tracking

**Coordination Monitoring Implementation:**
```bash
spawn_coordination_monitoring_agent() {
    local orchestration_id=$1
    
    echo "📊 Coordination Monitoring Agent: Starting real-time tracking for $orchestration_id"
    
    while true; do
        # Calculate current coordination progress
        local total_phases=$(yq e '.workflow.phases | length' ".orchestration/sessions/$orchestration_id.yaml")
        local completed_phases=$(yq e '.workflow.phases[] | select(.status == "completed") | .id' ".orchestration/sessions/$orchestration_id.yaml" | wc -l)
        local coordination_percentage=$((completed_phases * 100 / total_phases))
        
        # Update coordination in orchestration file
        yq e '.coordination.percentage = '$coordination_percentage -i ".orchestration/sessions/$orchestration_id.yaml"
        yq e '.coordination.phases_completed = '$completed_phases -i ".orchestration/sessions/$orchestration_id.yaml"
        yq e '.coordination.last_update = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i ".orchestration/sessions/$orchestration_id.yaml"
        
        # Log coordination update
        log_orchestration_event "$orchestration_id" "coordination_updated" "{\"percentage\": $coordination_percentage, \"completed_phases\": $completed_phases, \"total_phases\": $total_phases}"
        
        # Display coordination dashboard
        display_coordination_dashboard "$orchestration_id"
        
        # Check if orchestration is complete
        if [ "$completed_phases" -eq "$total_phases" ]; then
            echo "🎉 Orchestration completed: $orchestration_id"
            complete_orchestration "$orchestration_id"
            break
        fi
        
        # Wait before next update
        sleep 30
    done
}
```

**Coordination Dashboard:**
```bash
display_coordination_dashboard() {
    local orchestration_id=$1
    
    echo "=== ORCHESTRATION EXECUTION DASHBOARD ==="
    echo "Orchestration: $(yq e '.title' ".orchestration/sessions/$orchestration_id.yaml")"
    echo "Status: $(yq e '.status' ".orchestration/sessions/$orchestration_id.yaml")"
    echo "Coordination: $(yq e '.coordination.percentage' ".orchestration/sessions/$orchestration_id.yaml")%"
    echo ""
    
    echo "WORKFLOW PHASE STATUS:"
    yq e '.workflow.phases[] | .id + ": " + .status + " (" + .title + ")"' ".orchestration/sessions/$orchestration_id.yaml"
    
    echo ""
    echo "ACTIVE AGENTS:"
    list_active_orchestration_agents "$orchestration_id"
    
    echo ""
    echo "RECENT COORDINATION EVENTS:"
    tail -5 ".orchestration/logs/coordination-$orchestration_id.jsonl" | jq -r '.timestamp + " " + .event + ": " + (.details // "")'
    
    echo "================================="
}
```

## Step 4: Session Management and Resume

**Session State Management:**
```bash
save_orchestration_session() {
    local orchestration_id=$1
    local session_id=$2
    local reason=${3:-"manual_save"}
    
    local session_file=".orchestration/coordination/$session_id.yaml"
    
    cat > "$session_file" << EOF
session:
  id: "$session_id"
  orchestration_id: "$orchestration_id"
  status: "active"
  saved_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  save_reason: "$reason"
  
context:
  working_directory: "$(pwd)"
  git_branch: "$(git branch --show-current)"
  git_commit: "$(git rev-parse HEAD)"
  
execution_state:
  active_agents: [$(list_active_orchestration_agents "$orchestration_id" | tr '\n' ',' | sed 's/,$//')] 
  current_phase: "$(yq e '.workflow.phases[] | select(.status == "coordinating") | .id' ".orchestration/sessions/$orchestration_id.yaml" | head -1)"
  coordination_percentage: $(yq e '.coordination.percentage' ".orchestration/sessions/$orchestration_id.yaml")
  
resume_points:
  next_phases: [$(yq e '.workflow.phases[] | select(.status == "pending") | .id' ".orchestration/sessions/$orchestration_id.yaml" | tr '\n' ',' | sed 's/,$//'')]
  pending_commits: $(git status --porcelain | wc -l)
  uncommitted_changes: $([ -n "$(git status --porcelain)" ] && echo "true" || echo "false")
EOF
    
    echo "Orchestration session saved: $session_file"
}

resume_orchestration_session() {
    local session_id=$1
    local session_file=".orchestration/coordination/$session_id.yaml"
    
    if [ ! -f "$session_file" ]; then
        echo "ERROR: Session file not found: $session_file"
        return 1
    fi
    
    echo "🔄 Resuming orchestration session: $session_id"
    
    # Load session context
    local orchestration_id=$(yq e '.session.orchestration_id' "$session_file")
    local working_dir=$(yq e '.context.working_directory' "$session_file")
    local git_branch=$(yq e '.context.git_branch' "$session_file")
    
    # Restore context
    cd "$working_dir"
    git checkout "$git_branch"
    
    # Update session status
    yq e '.session.status = "resumed"' -i "$session_file"
    yq e '.session.resumed_at = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' -i "$session_file"
    
    # Log resume event
    log_orchestration_event "$orchestration_id" "session_resumed" "{\"session_id\": \"$session_id\"}"
    
    # Redeploy orchestration agents
    deploy_orchestration_agents "$orchestration_id" "$session_id"
    
    echo "✅ Orchestration session resumed successfully"
}
```

## Step 5: Dependency Validation and Blockers

**Dependency Validation Agent:**
```bash
spawn_dependency_validation_agent() {
    local orchestration_id=$1
    
    echo "🔗 Dependency Validation Agent: Monitoring dependencies for $orchestration_id"
    
    while true; do
        # Check orchestration dependencies
        local dependencies=$(yq e '.dependencies.requires[]' ".orchestration/sessions/$orchestration_id.yaml" 2>/dev/null)
        local dependency_issues=0
        
        for dep in $dependencies; do
            if [ ! -f ".orchestration/completed/$dep.yaml" ]; then
                echo "❌ Dependency blocker: $dep not completed"
                log_orchestration_event "$orchestration_id" "dependency_blocker" "{\"dependency\": \"$dep\"}"
                ((dependency_issues++))
            fi
        done
        
        # Check workflow phase dependencies
        local current_phases=$(yq e '.workflow.phases[] | select(.status == "coordinating") | .id' ".orchestration/sessions/$orchestration_id.yaml")
        for phase_id in $current_phases; do
            local phase_deps=$(yq e '.workflow.phases[] | select(.id == "'$phase_id'") | .dependencies[]?' ".orchestration/sessions/$orchestration_id.yaml" 2>/dev/null)
            for phase_dep in $phase_deps; do
                local dep_status=$(yq e '.workflow.phases[] | select(.id == "'$phase_dep'") | .status' ".orchestration/sessions/$orchestration_id.yaml")
                if [ "$dep_status" != "completed" ]; then
                    echo "❌ Workflow dependency blocker: $phase_id depends on $phase_dep"
                    log_orchestration_event "$orchestration_id" "workflow_dependency_blocker" "{\"phase\": \"$phase_id\", \"dependency\": \"$phase_dep\"}"
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
    local orchestration_id=$1
    
    echo "🚫 Blocker Detection Agent: Monitoring for coordination blockers"
    
    while true; do
        local blockers=()
        
        # Check for Git conflicts
        if [ -n "$(git status --porcelain | grep '^UU\|^AA\|^DD')" ]; then
            blockers+=("git_conflicts")
            log_orchestration_event "$orchestration_id" "blocker_detected" "{\"type\": \"git_conflicts\"}"
        fi
        
        # Check for failed tests
        if ! make test &>/dev/null; then
            blockers+=("test_failures")
            log_orchestration_event "$orchestration_id" "blocker_detected" "{\"type\": \"test_failures\"}"
        fi
        
        # Check for long-running phases
        local long_running_phases=$(yq e '.workflow.phases[] | select(.status == "coordinating" and .started_at != null) | select((now - (.started_at | fromdateiso8601)) > 3600) | .id' ".orchestration/sessions/$orchestration_id.yaml")
        if [ -n "$long_running_phases" ]; then
            blockers+=("long_running_phases")
            log_orchestration_event "$orchestration_id" "blocker_detected" "{\"type\": \"long_running_phases\", \"phases\": \"$long_running_phases\"}"
        fi
        
        # Check for coordination deadlocks
        local coordinating_phases=$(yq e '.workflow.phases[] | select(.status == "coordinating") | .id' ".orchestration/sessions/$orchestration_id.yaml" | wc -l)
        local total_phases=$(yq e '.workflow.phases | length' ".orchestration/sessions/$orchestration_id.yaml")
        if [ "$coordinating_phases" -gt 0 ] && [ "$coordinating_phases" -eq "$total_phases" ]; then
            blockers+=("coordination_deadlock")
            log_orchestration_event "$orchestration_id" "blocker_detected" "{\"type\": \"coordination_deadlock\"}"
        fi
        
        # Escalate blockers
        if [ ${#blockers[@]} -gt 0 ]; then
            escalate_coordination_blockers "$orchestration_id" "${blockers[@]}"
        fi
        
        sleep 120
    done
}

escalate_coordination_blockers() {
    local orchestration_id=$1
    shift
    local blockers=("$@")
    
    echo "🚨 COORDINATION BLOCKERS DETECTED FOR ORCHESTRATION: $orchestration_id"
    echo "Blockers: ${blockers[*]}"
    
    # Pause orchestration execution
    yq e '.status = "blocked"' -i ".orchestration/sessions/$orchestration_id.yaml"
    yq e '.blockers = ["'$(IFS='","'; echo "${blockers[*]}")'""]' -i ".orchestration/sessions/$orchestration_id.yaml"
    
    # Save session for recovery
    save_orchestration_session "$orchestration_id" "$(yq e '.execution.session_id' ".orchestration/sessions/$orchestration_id.yaml")" "blocker_detected"
    
    # Log escalation
    log_orchestration_event "$orchestration_id" "blockers_escalated" "{\"blockers\": [\"$(IFS='","'; echo "${blockers[*]}")\"]}"
    
    echo "⏸️  Orchestration execution paused due to blockers"
    echo "Resolve blockers and resume with: /orchestrate/execute --resume"
}
```

## Step 6: Git Integration During Execution

**Git Integration Agent:**
```bash
spawn_git_integration_agent() {
    local orchestration_id=$1
    
    echo "🔧 Git Integration Agent: Managing repository state for $orchestration_id"
    
    # Ensure we're on the correct orchestration branch
    switch_to_orchestration_branch "$orchestration_id"
    
    while true; do
        # Monitor for changes that need committing
        if [ -n "$(git status --porcelain)" ]; then
            local uncommitted_changes=$(git status --porcelain | wc -l)
            
            if [ "$uncommitted_changes" -gt 10 ]; then
                echo "📝 Auto-committing accumulated changes"
                
                # Create checkpoint commit
                git add .
                git commit -m "checkpoint(orchestration-$orchestration_id): auto-commit during coordination

$(git status --short | head -10)

Generated with Claude Code orchestration execution"
                
                log_orchestration_event "$orchestration_id" "auto_commit" "{\"files_changed\": $uncommitted_changes}"
            fi
        fi
        
        # Sync with remote periodically
        sync_orchestration_branch "$orchestration_id"
        
        # Save repository state
        save_orchestration_repository_state "$orchestration_id"
        
        sleep 300  # 5 minutes
    done
}
```

## Step 7: Execution Quality Checklist

**Orchestration Execution Validation:**
- [ ] Orchestration properly activated with status transition
- [ ] All execution agents deployed and monitoring
- [ ] Real-time coordination tracking functional
- [ ] Session management with resume capability tested
- [ ] Git integration maintaining repository state
- [ ] Dependency validation preventing violations
- [ ] Blocker detection with escalation procedures
- [ ] Event logging capturing all coordination activities

**Agent Coordination Checklist:**
- [ ] Workflow execution proceeding with proper commits
- [ ] Coordination monitoring updating metrics continuously
- [ ] Git integration handling branch and commit management
- [ ] Dependency validation preventing conflicts
- [ ] Blocker detection identifying issues early
- [ ] Session state preserved for resume capability

**Integration Validation:**
- [ ] Working directory maintained throughout execution
- [ ] Git branch consistency preserved
- [ ] Coordination events logged with timestamps
- [ ] Orchestration file updated with current state
- [ ] Session context saved for interruption recovery

**Anti-Patterns to Avoid:**
- ❌ Executing workflows without dependency validation
- ❌ Missing coordination tracking and event logging
- ❌ Ignoring session management for interruptions
- ❌ Failing to detect and escalate coordination blockers
- ❌ Inconsistent git integration and branch management
- ❌ No coordination between execution agents

**Final Verification:**
Before completing orchestration execution:
- Have all workflow phases been executed with proper coordination?
- Is coordination tracking providing real-time visibility?
- Are sessions properly managed for resume capability?
- Have all blockers been detected and escalated?
- Is git integration maintaining repository consistency?
- Are all agents coordinating effectively?

**Final Commitment:**
- **I will**: Execute orchestrations with comprehensive agent coordination
- **I will**: Implement real-time coordination tracking with event logging
- **I will**: Maintain session state for interruption and resume capability
- **I will**: Integrate with git for repository consistency
- **I will NOT**: Execute without proper dependency validation
- **I will NOT**: Skip blocker detection and escalation
- **I will NOT**: Ignore session management requirements

**REMEMBER:**
This is ORCHESTRATION EXECUTION mode - active coordination, real-time tracking, and resume-capable progress management. The goal is to execute orchestrations with comprehensive monitoring, agent coordination, and robust state management.

Executing comprehensive orchestration execution protocol for coordinated workflow completion...