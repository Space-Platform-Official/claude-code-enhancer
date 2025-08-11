---
description: Real multi-agent spawning patterns using Task tool for milestone execution
---

# Milestone Agent Spawning Framework

Real multi-agent orchestration using Claude Code's Task tool for parallel milestone execution.

## 🚨 MANDATORY: Use Task Tool, Not Bash Functions!

**CRITICAL REQUIREMENT:**
When executing milestones, you MUST use the Task tool to spawn real agents, NOT bash background processes.

### ❌ WRONG (Old Way - No Real Parallelism):
```bash
spawn_task_execution_agent "$milestone_id" &  # Just a bash function
spawn_progress_monitoring_agent "$milestone_id" &  # Another bash function
```

### ✅ CORRECT (New Way - Real Task Tool Agents):
Use the Task tool with these exact patterns to spawn real parallel agents.

## Core Agent Templates

### 1. Task Executor Agent
```markdown
When spawning the Task Executor Agent, use:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute milestone tasks</parameter>
<parameter name="prompt">You are the Task Executor Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Read the milestone file at .milestones/active/{{MILESTONE_ID}}.yaml
2. Identify all pending tasks (status: "pending")
3. For each task:
   - Update status to "in_progress" in the YAML file
   - Execute the required code changes
   - Run relevant tests
   - Update status to "completed"
   - Create atomic commits with meaningful messages
4. Log all activities to .milestones/logs/{{SESSION_ID}}/execution.jsonl
5. Update overall milestone progress percentage

Session: {{SESSION_ID}}
Working Directory: {{PWD}}

Begin by reading the milestone file and listing all pending tasks.</parameter>
</invoke>
</function_calls>
```

### 2. Progress Monitor Agent
```markdown
When spawning the Progress Monitor Agent, use:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Monitor milestone progress</parameter>
<parameter name="prompt">You are the Progress Monitor Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor .milestones/active/{{MILESTONE_ID}}.yaml every 30 seconds
2. Calculate completion percentage: (completed_tasks / total_tasks) * 100
3. Generate progress reports to .milestones/logs/{{SESSION_ID}}/progress.jsonl
4. Detect stalled tasks (no status update for >5 minutes)
5. Create visual progress indicators
6. Alert when milestone reaches 100% completion

Session: {{SESSION_ID}}

Begin monitoring and report initial milestone status.</parameter>
</invoke>
</function_calls>
```

### 3. Git Integration Agent
```markdown
When spawning the Git Integration Agent, use:

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

### 4. Dependency Validator Agent
```markdown
When spawning the Dependency Validator Agent, use:

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

### 5. Blocker Detector Agent
```markdown
When spawning the Blocker Detector Agent, use:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Detect execution blockers</parameter>
<parameter name="prompt">You are the Blocker Detector Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor all log files in .milestones/logs/{{SESSION_ID}/
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

## Implementation Pattern for milestone/execute.md

When the user runs `/milestone/execute [milestone-id]`, follow this EXACT pattern:

```markdown
## Executing Milestone with Real Agents

I'll now spawn 5 specialized agents using the Task tool for true parallel execution:

1. **Spawning Task Executor Agent...**
   [Use Task tool with exact template above]

2. **Spawning Progress Monitor Agent...**
   [Use Task tool with exact template above]

3. **Spawning Git Integration Agent...**
   [Use Task tool with exact template above]

4. **Spawning Dependency Validator Agent...**
   [Use Task tool with exact template above]

5. **Spawning Blocker Detector Agent...**
   [Use Task tool with exact template above]

All agents are now running in parallel, each handling their specific responsibilities.
```

## Agent Coordination

### Shared State Management
```bash
# Setup shared infrastructure for agent communication
setup_agent_infrastructure() {
    local session_id=$1
    
    # Create session directories
    mkdir -p ".milestones/sessions/$session_id/agents"
    mkdir -p ".milestones/logs/$session_id"
    
    # Initialize shared state file
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
}
```

### Performance Benefits

| Metric | Bash Functions | Task Tool Agents | Improvement |
|--------|---------------|------------------|-------------|
| Execution Time | Sequential | Parallel | 3-5x faster |
| Agent Isolation | None | Full | 100% better |
| Error Recovery | Limited | Per-agent | Much better |
| Resource Usage | Single thread | Multi-thread | Optimized |
| Real Parallelism | 0% | 100% | True parallel |

## CRITICAL REMINDERS

1. **ALWAYS use Task tool**: Never fall back to bash functions with `&`
2. **Replace {{VARIABLES}}**: Substitute actual values for MILESTONE_ID, SESSION_ID, PWD
3. **Monitor all agents**: Check their outputs and coordination
4. **Handle failures**: Each agent can fail independently - handle gracefully
5. **Session tracking**: Use unique session IDs for each execution

## Example Complete Flow

```bash
# When user runs: /milestone/execute milestone-001

1. Validate milestone exists
2. Create session: exec-milestone-001-20250810-abc123
3. Setup infrastructure with setup_agent_infrastructure()
4. Spawn 5 agents using Task tool (NOT bash functions!)
5. Monitor agent coordination
6. Report completion when all agents finish
```

## Why This Matters

- **Real Parallelism**: Task tool creates actual separate Claude Code instances
- **Better Performance**: 3-5x faster than sequential execution
- **Isolation**: Agent failures don't affect others
- **Specialization**: Each agent optimized for its specific task
- **Visibility**: Real-time progress from multiple perspectives

**Remember: The `.claude/` directory in target projects will receive this via `claude-merge`. Never create milestone commands directly in `.claude/` - always use `templates/`!**