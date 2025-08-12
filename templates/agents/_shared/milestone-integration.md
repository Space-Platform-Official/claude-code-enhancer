---
description: Integration layer for milestone commands to leverage agent-based execution
---

# Milestone Agent Integration

Seamless integration between milestone commands and specialized milestone agents for enhanced performance.

## Integration Architecture

```yaml
integration_layers:
  command_layer:
    - Original milestone commands remain as entry points
    - Commands analyze complexity and delegate to agents
    - Backward compatibility maintained
    
  decision_layer:
    - Complexity assessment for milestone operations
    - Agent vs direct execution decision
    - Resource availability checking
    - Mode selection (planning vs execution)
    
  agent_layer:
    - milestone-coordinator for dual-mode orchestration
    - milestone-planner for planning analysis
    - milestone-executor for phase execution
    - Specialized agents for specific operations
    
  coordination_layer:
    - State synchronization between agents
    - Planning-to-execution state transition
    - Progress aggregation and reporting
    - Git operations coordination
```

## Command Enhancement Pattern

### Enhancing Milestone Commands via Decision Agent

```markdown
Deploy complexity assessment agent for execution decisions:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Assess milestone complexity</parameter>
<parameter name="prompt">You are the Complexity Assessment Agent for milestone operations.

Your responsibilities:
1. Analyze milestone requirements:
   - Read command arguments from /tmp/milestone-command-args.json
   - Estimate phase count (design, spec, task, execute)
   - Estimate task count based on scope
   - Estimate file changes required
   - Count Git operations needed
2. Calculate complexity score:
   - High: tasks > 20 OR files > 50
   - Medium: tasks > 10 OR files > 20
   - Low: tasks <= 10 AND files <= 20
3. Check agent availability:
   - Verify Task tool is available
   - Check system resources
   - Validate agent templates exist
4. Make execution decision:
   - High + agents available → Use full agent orchestration
   - Medium + agents available → Use hybrid execution
   - Low OR no agents → Use direct execution
5. Save decision to /tmp/milestone-execution-decision.json:
   {
     "complexity": "high|medium|low",
     "agents_available": true|false,
     "execution_mode": "agents|hybrid|direct",
     "reasoning": "..."
   }

Command: {{COMMAND}}
Arguments: {{ARGS}}

Assess complexity and determine optimal execution strategy.</parameter>
</invoke>
</function_calls>
```

## Agent Invocation Templates

### For milestone/plan.md

```markdown
## Execution Strategy

Analyzing milestone planning requirements...
- Scope complexity: {{SCOPE_COMPLEXITY}}
- Estimated components: {{COMPONENT_COUNT}}
- Risk factors: {{RISK_COUNT}}
- Planning complexity: {{COMPLEXITY}}

{{IF COMPLEXITY >= "medium"}}
### Using Enhanced Agent-Based Planning

I'll deploy the milestone coordinator in planning mode for comprehensive analysis:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Orchestrate comprehensive milestone planning</parameter>
<parameter name="prompt">You are the Milestone Coordinator Agent operating in PLANNING MODE.

Using milestone-coordinator planning capabilities:
1. Deploy planning sub-agents for parallel analysis:
   - Scope Analysis Agent
   - Estimation Agent
   - Risk Assessment Agent
   - KIRO Strategy Agent
2. Coordinate planning results from all agents
3. Generate comprehensive planning artifacts
4. Prepare state for execution transition
5. Create unified milestone plan with KIRO phases

Milestone: {{MILESTONE_TITLE}}
Context: {{PROJECT_CONTEXT}}
Mode: planning

Save artifacts to: /tmp/milestone-planning-{{MILESTONE_ID}}/

Begin comprehensive parallel planning analysis.</parameter>
</invoke>
</function_calls>

### Planning Sub-Agents Deployment

The coordinator will automatically deploy specialized planning agents:
- **Scope Analyzer**: Deep project analysis with KIRO lens
- **Estimation Expert**: Timeline and resource calculations
- **Risk Assessor**: Comprehensive risk identification
- **KIRO Strategist**: Strategic framework application

{{ELSE}}
### Using Direct Planning
Proceeding with streamlined milestone planning...
{{/IF}}
```

### For milestone/execute.md

```markdown
## Execution Strategy

Analyzing milestone execution requirements...
- Current phase: {{CURRENT_PHASE}}
- Remaining tasks: {{TASK_COUNT}}
- Parallelization potential: {{PARALLEL_SCORE}}

{{IF PARALLEL_SCORE > 0.6}}
### Deploying Parallel Execution Agents

I'll spawn multiple agents for parallel phase execution:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Coordinate milestone execution</parameter>
<parameter name="prompt">You are the Milestone Coordinator Agent.

Execute milestone: {{MILESTONE_ID}}
Current state: {{MILESTONE_STATE}}

Deploy phase execution agents for:
- Design (15% weight)
- Spec (25% weight)
- Task (20% weight)
- Execute (40% weight)

Coordinate parallel execution and track progress.
Aggregate results in: /tmp/milestone-execute-{{MILESTONE_ID}}/</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">git-operator</parameter>
<parameter name="description">Manage milestone Git operations</parameter>
<parameter name="prompt">You are the Git Operations Agent.

Manage Git operations for milestone: {{MILESTONE_ID}}

Tasks:
1. Create/update feature branch
2. Create phase commits
3. Handle merge operations
4. Manage conflicts

Coordinate with milestone execution agents.</parameter>
</invoke>
</function_calls>
{{ELSE}}
### Using Sequential Execution
Proceeding with phase-by-phase execution...
{{/IF}}
```

## Planning-Execution State Management

### Planning State Structure

```yaml
planning_state_structure:
  planning:
    status: "in_progress|complete"
    started_at: "ISO timestamp"
    completed_at: "ISO timestamp"
    artifacts:
      scope: "/tmp/milestone-planning-scope-*.json"
      estimates: "/tmp/milestone-planning-estimates-*.json"
      risks: "/tmp/milestone-planning-risks-*.json"
      kiro: "/tmp/milestone-planning-kiro-*.json"
      unified: "/tmp/milestone-plan-*.json"
    metrics:
      analysis_time: "seconds"
      confidence_score: "0-100"
      complexity_score: "0-100"
      
  execution:
    status: "pending|ready|in_progress|complete"
    plan_reference: "path to plan file"
    phases:
      design: "status and progress"
      spec: "status and progress"
      task: "status and progress"
      execute: "status and progress"
    progress:
      overall: "0-100"
      by_phase: "weighted percentages"
      
  transition:
    planning_complete: "boolean"
    execution_ready: "boolean"
    transitioned_at: "ISO timestamp"
```

### Planning-to-Execution Transition via Bridge Agent

```markdown
Deploy transition bridge agent:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Bridge planning to execution</parameter>
<parameter name="prompt">You are the Planning-Execution Bridge Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Load planning artifacts:
   - Read /tmp/milestone-plan-{{MILESTONE_ID}}.json
   - Verify all required planning files exist
   - Check planning completeness markers
2. Validate planning completeness:
   - Scope analysis complete
   - Estimates provided
   - Risks assessed
   - KIRO strategy defined
   - Dependencies mapped
3. Transform planning to execution config:
   - Extract phases from plan
   - Extract tasks from plan
   - Map dependencies
   - Copy KIRO strategy
   - Transfer estimates and risks
4. Initialize execution state:
   - Create /tmp/milestone-execution-state-{{MILESTONE_ID}}.json
   - Set all phases to 'pending'
   - Initialize progress to 0%
   - Set execution status to 'ready'
5. Notify coordinator of transition:
   - Write to /tmp/milestone-coordinator-notification.json:
   {
     "milestone_id": "{{MILESTONE_ID}}",
     "event": "mode_transition",
     "from": "planning",
     "to": "execution",
     "timestamp": "ISO timestamp",
     "config": "execution configuration"
   }
6. Create execution ready marker:
   - /tmp/milestone-execution-ready-{{MILESTONE_ID}}.marker

Milestone: {{MILESTONE_ID}}
Transition Mode: planning_to_execution

Bridge planning artifacts to execution configuration.</parameter>
</invoke>
</function_calls>
```

## State Synchronization

### Milestone State Bridge via Sync Agent

```markdown
Deploy state synchronization agent:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Synchronize milestone state</parameter>
<parameter name="prompt">You are the State Synchronization Agent for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor state files:
   - Command state: /tmp/milestone-{{MILESTONE_ID}}.json
   - Agent state: /tmp/milestone-state-{{MILESTONE_ID}}.json
2. Sync from command to agent format:
   - Read command state file
   - Transform to agent format:
     * metadata.id ← id
     * metadata.title ← title
     * metadata.created_at ← created
     * metadata.status ← status
     * phases ← map phase data
     * progress.overall ← progress
     * progress.by_phase ← phaseProgress
     * git.branch ← branch
     * git.commits ← commits
   - Write to agent state file
3. Sync from agent to command format:
   - Read agent state file
   - Transform to command format:
     * id ← metadata.id
     * title ← metadata.title
     * created ← metadata.created_at
     * status ← metadata.status
     * phases ← unmap phase data
     * progress ← progress.overall
     * phaseProgress ← progress.by_phase
     * branch ← git.branch
     * commits ← git.commits
   - Write to command state file
4. Handle sync conflicts:
   - Use timestamp to determine newer data
   - Merge non-conflicting changes
   - Log conflicts to /tmp/milestone-sync-conflicts.log
5. Sync every 10 seconds:
   - Check for changes in either file
   - Perform bidirectional sync
   - Update sync timestamp

Milestone: {{MILESTONE_ID}}
Sync Interval: 10 seconds
Conflict Resolution: timestamp-based

Maintain consistent state between command and agent layers.</parameter>
</invoke>
</function_calls>
```

## Progress Aggregation

### Unified Progress Tracking via Aggregator Agent

```markdown
Deploy progress aggregation agent:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Aggregate milestone progress</parameter>
<parameter name="prompt">You are the Progress Aggregator for milestone {{MILESTONE_ID}}.

Your responsibilities:
1. Monitor progress sources:
   - Command: /tmp/milestone-{{MILESTONE_ID}}.json
   - Coordinator: /tmp/milestone-coordinator-{{MILESTONE_ID}}.json
   - Executor: /tmp/milestone-executor-{{MILESTONE_ID}}.json
2. Collect progress data:
   - Read progress from each source
   - Handle missing or unavailable sources
   - Extract phase-specific progress
3. Calculate weighted overall progress:
   - Design phase: 15% weight
   - Spec phase: 25% weight
   - Task phase: 20% weight
   - Execute phase: 40% weight
   - Formula: Σ(phase_progress * phase_weight)
4. Aggregate task-level progress:
   - Count completed vs total tasks
   - Track in-progress tasks
   - Identify blocked tasks
5. Broadcast unified progress:
   - Write to /tmp/milestone-progress-unified-{{MILESTONE_ID}}.json:
   {
     "overall": "0-100",
     "phases": {
       "design": "percentage",
       "spec": "percentage",
       "task": "percentage",
       "execute": "percentage"
     },
     "tasks": {
       "total": "count",
       "completed": "count",
       "in_progress": "count",
       "blocked": "count"
     },
     "sources": {
       "command": "progress data",
       "coordinator": "progress data",
       "executor": "progress data"
     },
     "timestamp": "ISO timestamp"
   }
6. Update all source files with unified progress
7. Aggregate every 15 seconds

Milestone: {{MILESTONE_ID}}
Aggregation Interval: 15 seconds

Provide unified progress view across all milestone layers.</parameter>
</invoke>
</function_calls>
```

## Git Integration Coordination

### Coordinated Git Operations

```yaml
git_coordination:
  branch_management:
    coordinator_role:
      - Create milestone feature branch
      - Manage branch protection rules
      - Coordinate merge operations
      
    executor_role:
      - Create phase commits
      - Stage phase deliverables
      - Update branch with changes
      
  commit_strategy:
    phase_commits:
      design: "feat(design): complete design phase for {{MILESTONE}}"
      spec: "feat(spec): complete specification phase for {{MILESTONE}}"
      task: "feat(task): complete task planning for {{MILESTONE}}"
      execute: "feat(execute): implement {{MILESTONE}} functionality"
      
  conflict_resolution:
    coordinator:
      - Detect conflicts across agents
      - Delegate to git-operator agent
      - Verify resolution success
      
    git_operator:
      - Analyze conflict patterns
      - Apply resolution strategies
      - Validate merged results
```

## Performance Metrics

### Agent Performance Tracking via Metrics Agent

```markdown
Deploy performance metrics agent:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Track performance metrics</parameter>
<parameter name="prompt">You are the Performance Metrics Agent for milestone operations.

Your responsibilities:
1. Collect direct execution metrics:
   - Read from /tmp/milestone-metrics-direct-*.json
   - Track execution time
   - Count sequential tasks
   - Measure resource usage
   - Calculate quality score
2. Collect agent execution metrics:
   - Read from /tmp/milestone-metrics-agent-*.json
   - Track parallel execution time
   - Count parallel tasks
   - Measure agent resource usage
   - Calculate agent quality score
3. Compare performance:
   - Speedup = agent_time / direct_time
   - Parallelism = parallel_tasks / sequential_tasks
   - Efficiency = agent_resources / direct_resources
   - Quality = agent_quality / direct_quality
4. Generate recommendations:
   - Speedup > 2x AND quality >= 1: Always use agents
   - Speedup > 1.5x: Use agents for complex tasks
   - Otherwise: Use direct for simple tasks
5. Save metrics report:
   - /tmp/milestone-performance-report-{{TIMESTAMP}}.json:
   {
     "metrics": {
       "direct": "metrics data",
       "agent": "metrics data"
     },
     "comparison": {
       "speedup": "multiplier",
       "parallelism": "ratio",
       "resource_efficiency": "ratio",
       "quality": "ratio"
     },
     "recommendation": "always_use_agents|use_agents_for_complex|use_direct_for_simple",
     "timestamp": "ISO timestamp"
   }
6. Update metrics every execution

Operation: {{OPERATION}}
Milestone: {{MILESTONE_ID}}

Track and compare performance between execution modes.</parameter>
</invoke>
</function_calls>
```

## Migration Path

### Gradual Agent Adoption

```yaml
migration_phases:
  phase_1_observation:
    - Monitor existing milestone command usage
    - Identify performance bottlenecks
    - Collect complexity metrics
    
  phase_2_enhancement:
    - Add agent decision logic to commands
    - Enable opt-in agent execution
    - Track performance comparisons
    
  phase_3_optimization:
    - Default to agents for complex milestones
    - Maintain direct execution for simple cases
    - Optimize agent coordination
    
  phase_4_maturity:
    - Full agent integration
    - Automatic optimization
    - Predictive agent deployment
```

## Integration Testing

### Validation Checklist

**Command Integration:**
- [ ] Commands detect agent availability
- [ ] Complexity assessment accurate
- [ ] Agent invocation successful
- [ ] Fallback to direct execution works

**State Management:**
- [ ] State synchronized between layers
- [ ] Progress tracked accurately
- [ ] No state conflicts
- [ ] Recovery from failures

**Performance:**
- [ ] Agent execution faster for complex tasks
- [ ] Resource usage within limits
- [ ] No degradation for simple tasks
- [ ] Parallel execution effective

**Compatibility:**
- [ ] Existing workflows unaffected
- [ ] All commands functioning
- [ ] Git operations coordinated
- [ ] Results consistent

## Usage Examples

### Simple Milestone (Direct Execution)
```bash
# Small milestone with few tasks
/milestone/plan "Add login feature"
# Complexity: Low
# Execution: Direct (no agents needed)
```

### Complex Milestone (Agent Execution)
```bash
# Large milestone with many phases and tasks
/milestone/plan "Refactor authentication system"
# Complexity: High
# Execution: Agent-based (3-5x speedup)
# Agents deployed: milestone-coordinator, milestone-executor, git-operator
```

### Hybrid Execution
```bash
# Medium complexity with selective agent use
/milestone/execute --phase design
# Design phase: Direct execution
/milestone/execute --phase execute
# Execute phase: Agent-based (parallel task execution)
```

The integration layer ensures seamless cooperation between milestone commands and agents, delivering performance improvements while maintaining the familiar command interface.