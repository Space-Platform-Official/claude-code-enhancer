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

**ENHANCED MILESTONE AGENT INTEGRATION:**

### Execution Complexity Assessment
```javascript
// Analyze execution complexity
const complexity = assessMilestoneComplexity({
  currentPhase: milestone.currentPhase,
  remainingTasks: milestone.pendingTasks.length,
  parallelismScore: calculateParallelismPotential(milestone),
  resourceAvailability: checkAgentAvailability()
});

if (complexity >= 'medium' && parallelismScore > 0.6) {
  // Deploy milestone-coordinator for orchestration
  // Use milestone-executor for parallel phase execution
  console.log('Using agent-based execution for 3-5x performance boost');
} else {
  // Use sequential execution for simple milestones
  console.log('Using direct execution for this simple milestone');
}
```

**MANDATORY ENHANCED AGENT COORDINATION:**
```
"I'll spawn specialized milestone agents for optimal parallel execution:
- Milestone Coordinator Agent: Orchestrate KIRO phases with weighted progress
- Milestone Executor Agents: Execute Design/Spec/Task/Execute phases in parallel
- Git Operator Agent: Professional git operations and conflict resolution
- Quality Enforcer Agent: Validate deliverables and standards
- File Processor Agent: Handle bulk file operations efficiently"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ Start execution without proper milestone activation → NO! Validate state first!
- ❌ Execute tasks without dependency validation → NO! Check prerequisites!
- ❌ Ignore working directory integration → NO! Maintain git consistency!
- ❌ Skip progress tracking and logging → NO! Real-time monitoring required!
- ❌ Execute without session management → NO! Resume capability essential!
- ❌ Continue execution with unresolved blockers → NO! Escalate immediately!

**MANDATORY ENHANCED EXECUTION WORKFLOW:**
```
1. Assess complexity → Determine optimal execution strategy
2. Deploy coordinator → Spawn milestone-coordinator for orchestration
3. Deploy executors → Spawn milestone-executor agents per phase
4. Leverage specialized agents → git-operator, quality-enforcer, file-processor
5. Execute KIRO phases → Parallel execution with 15/25/20/40% weighting
6. Coordinate state → Synchronize via /tmp/milestone-state-*.json
7. Aggregate progress → Unified tracking across all agents
8. VERIFY completion → All phases complete with deliverables validated
```

### Native Agent Invocation:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Coordinate milestone execution</parameter>
<parameter name="prompt">You are the Milestone Coordinator Agent.

Using milestone-coordinator capabilities:
1. Orchestrate KIRO phase execution (Design 15%, Spec 25%, Task 20%, Execute 40%)
2. Deploy milestone-executor agents for each phase
3. Coordinate with git-operator for version control
4. Track weighted progress across all phases
5. Handle phase transitions and dependencies

Milestone: {{MILESTONE_ID}}
Current State: {{MILESTONE_STATE}}

Begin orchestrated execution.</parameter>
</invoke>
</function_calls>
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

**Agent Deployment Using Task Tool:**

**CRITICAL**: Use the Task tool to spawn real agents, NOT bash functions!

```markdown
When deploying agents, you MUST:

1. Source the agent-spawning framework:
   - Load templates from templates/commands/milestone/_shared/agent-spawning.md
   - Use exact Task tool patterns, not bash functions

2. Deploy exactly 5 agents in parallel:
   - Task Executor Agent
   - Progress Monitor Agent  
   - Git Integration Agent
   - Dependency Validator Agent
   - Blocker Detector Agent

3. Replace template variables:
   - {{MILESTONE_ID}} with actual milestone ID
   - {{SESSION_ID}} with generated session ID
   - {{PWD}} with current working directory
```

### Task Executor Agent Spawning:

```markdown
When spawning the Task Executor Agent, use this exact Task tool invocation:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute milestone tasks</parameter>
<parameter name="prompt">You are the Task Executor Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Read the milestone file at .milestones/active/{{MILESTONE_ID}}.yaml
2. Identify all pending tasks with kiro workflow enabled
3. For each task:
   - Update status to "in_progress" in the YAML file
   - Execute through kiro phases: Design→Spec→Task→Execute
   - Validate phase deliverables before transitions
   - Handle approval gates when required
   - Update status to "completed" when all phases done
   - Create atomic commits with meaningful messages
4. Log all activities to .milestones/logs/{{SESSION_ID}}/execution.jsonl
5. Update overall milestone progress percentage

Session: {{SESSION_ID}}
Working Directory: {{PWD}}

Begin by reading the milestone file and listing all pending tasks.</parameter>
</invoke>
</function_calls>
```

### Progress Monitor Agent Spawning:

```markdown
When spawning the Progress Monitor Agent, use this exact Task tool invocation:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Monitor milestone progress</parameter>
<parameter name="prompt">You are the Progress Monitor Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor .milestones/active/{{MILESTONE_ID}}.yaml every 30 seconds
2. Calculate kiro-weighted progress using phase completion (15/25/20/40%)
3. Generate progress reports to .milestones/logs/{{SESSION_ID}}/progress.jsonl
4. Detect stalled tasks (no status update for >5 minutes)
5. Create visual progress indicators and dashboards
6. Alert when milestone reaches 100% completion

Session: {{SESSION_ID}}

Begin monitoring and report initial milestone status.</parameter>
</invoke>
</function_calls>
```

### Git Integration Agent Spawning:

```markdown
When spawning the Git Integration Agent, use this exact Task tool invocation:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Manage git operations</parameter>
<parameter name="prompt">You are the Git Integration Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Create and switch to branch: milestone/{{MILESTONE_ID}}
2. Monitor for uncommitted changes every minute
3. Create atomic commits when tasks are marked complete
4. Push changes to remote periodically (every 3 completed tasks)
5. Handle merge conflicts if they arise
6. Log all git operations to .milestones/logs/{{SESSION_ID}}/git.jsonl

Session: {{SESSION_ID}}

Start by checking current git status and creating the milestone branch.</parameter>
</invoke>
</function_calls>
```

### Dependency Validator Agent Spawning:

```markdown
When spawning the Dependency Validator Agent, use this exact Task tool invocation:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Validate dependencies</parameter>
<parameter name="prompt">You are the Dependency Validator Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Read dependencies from .milestones/active/{{MILESTONE_ID}}.yaml
2. Verify all prerequisite milestones exist in .milestones/completed/
3. Check for circular dependencies
4. Monitor for resource conflicts with other active milestones
5. Alert if dependencies are not satisfied
6. Log validation results to .milestones/logs/{{SESSION_ID}}/dependencies.jsonl

Session: {{SESSION_ID}}

Begin by validating all dependencies for this milestone.</parameter>
</invoke>
</function_calls>
```

### Blocker Detector Agent Spawning:

```markdown
When spawning the Blocker Detector Agent, use this exact Task tool invocation:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Detect execution blockers</parameter>
<parameter name="prompt">You are the Blocker Detector Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor all log files in .milestones/logs/{{SESSION_ID}}/
2. Detect error patterns and failures
3. Identify stalled execution (no progress for >10 minutes)
4. Recognize resource bottlenecks
5. Propose resolution strategies for blockers
6. Alert immediately on critical blockers
7. Log all blockers to .milestones/logs/{{SESSION_ID}}/blockers.jsonl

Session: {{SESSION_ID}}

Start continuous monitoring for execution issues.</parameter>
</invoke>
</function_calls>
```
## Step 3: Agent Coordination and Infrastructure

**Setup Shared Infrastructure:**
```bash
# Create infrastructure for agent communication
setup_agent_infrastructure() {
    local milestone_id=$1
    local session_id=$2
    
    # Create session directories
    mkdir -p ".milestones/sessions/$session_id/agents"
    mkdir -p ".milestones/logs/$session_id"
    
    # Initialize shared state file
    cat > ".milestones/sessions/$session_id/agents/state.json" <<EOF
{
    "session_id": "$session_id",
    "milestone_id": "$milestone_id",
    "agents": {
        "task_executor": "spawning",
        "progress_monitor": "spawning",
        "git_integration": "spawning",
        "dependency_validator": "spawning",
        "blocker_detector": "spawning"
    },
    "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "coordination_mode": "parallel"
}
EOF
    
    echo "✅ Agent infrastructure ready: $session_id"
}
```

## Step 4: Implementation Pattern

**Complete Execution Flow:**

```markdown
When user runs `/milestone/execute [milestone-id]`, follow this EXACT pattern:

1. **Validate Prerequisites:**
   - Check milestone exists and is ready
   - Validate kiro compliance
   - Verify dependencies are met

2. **Setup Infrastructure:**
   - Generate session ID: exec-[milestone-id]-[timestamp]
   - Call setup_agent_infrastructure() 
   - Create logging directories

3. **Spawn All 5 Agents Using Task Tool:**
   
   I'll now spawn 5 specialized agents for true parallel execution:
   
   [Use Task tool with Task Executor Agent template above]
   [Use Task tool with Progress Monitor Agent template above]
   [Use Task tool with Git Integration Agent template above]
   [Use Task tool with Dependency Validator Agent template above]
   [Use Task tool with Blocker Detector Agent template above]

4. **Monitor Coordination:**
   - All agents are now running in parallel
   - Each handles their specific responsibilities
   - Progress updates will be logged to session directory

5. **Report Completion:**
   - Agents will coordinate to complete all tasks
   - Milestone marked complete when all tasks done
```

## Step 5: Key Differences from Old Implementation

**Old Approach (Bash Functions):**
- Used bash functions with `&` for background execution
- No real parallelism - just background processes
- Limited error isolation
- Difficult to debug and monitor
- Inconsistent agent counts

**New Approach (Task Tool):**
- Real parallel execution with separate Claude instances
- True isolation between agents
- Better error handling per agent
- 3-5x performance improvement
- Exactly 5 agents every time

## Step 6: Session Management

**Session Management Pattern:**

Sessions are automatically managed by the agents. Each agent maintains its own state and can recover from interruptions.

```bash
# Session infrastructure setup (called before spawning agents)
save_execution_session() {
    local milestone_id=$1
    local session_id=$2
    
    # Create session file for agent coordination
    cat > ".milestones/sessions/$session_id.yaml" <<EOF
session:
  id: "$session_id"
  milestone_id: "$milestone_id"
  status: "active"
  started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  agents_spawned: 5
  agent_types:
    - task_executor
    - progress_monitor
    - git_integration
    - dependency_validator
    - blocker_detector
EOF
}
```

## Step 7: Important Implementation Notes

**Critical Requirements:**
1. **ALWAYS use Task tool** - Never fall back to bash functions
2. **Exactly 5 agents** - Consistent behavior every time
3. **Replace variables** - Substitute {{MILESTONE_ID}}, {{SESSION_ID}}, {{PWD}}
4. **Monitor all agents** - Check outputs and coordination
5. **Handle failures gracefully** - Each agent can fail independently

**Performance Benefits:**
| Metric | Old (Bash) | New (Task Tool) | Improvement |
|--------|------------|-----------------|-------------|
| Execution Time | Sequential | Parallel | 3-5x faster |
| Agent Count | Inconsistent | Always 5 | 100% reliable |
| Error Recovery | Limited | Per-agent | Much better |
| Real Parallelism | 0% | 100% | True parallel |

## Execution Quality Checklist

**Before Execution:**
- [ ] Milestone file exists and is valid
- [ ] Dependencies are satisfied
- [ ] Kiro workflow is enabled for all tasks
- [ ] Session infrastructure is created

**During Execution:**
- [ ] All 5 agents spawned using Task tool
- [ ] Progress tracking is active
- [ ] Git operations are handled
- [ ] Dependencies are validated
- [ ] Blockers are detected

**After Execution:**
- [ ] All tasks marked as completed
- [ ] Final commits are created
- [ ] Milestone status updated
- [ ] Session logs are saved

## Anti-Patterns to Avoid

❌ **NEVER** use bash functions with `&` for agents
❌ **NEVER** claim to spawn different numbers of agents
❌ **NEVER** skip Task tool for agent spawning
❌ **NEVER** mix bash and Task tool approaches
❌ **NEVER** forget to replace template variables

## Final Implementation Commitment

When executing milestones, Claude Code will:
- ✅ **ALWAYS** spawn exactly 5 agents using Task tool
- ✅ **ALWAYS** use proper Task tool invocations
- ✅ **ALWAYS** maintain consistent behavior
- ✅ **ALWAYS** provide real parallelism
- ✅ **ALWAYS** handle errors per-agent

**REMEMBER:** This updated implementation ensures consistent, reliable milestone execution with exactly 5 parallel agents every time, fixing the discrepancy between announced and actual agent counts.