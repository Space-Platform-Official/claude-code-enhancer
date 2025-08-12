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

### Enhancing Milestone Commands

```javascript
// In milestone command files (plan.md, execute.md, etc.)

function enhanceMilestoneCommand(command, args) {
  // Assess complexity
  const complexity = assessMilestoneComplexity(args);
  
  // Check for agent availability
  const agentsAvailable = checkAgentAvailability();
  
  // Make execution decision
  if (complexity === 'high' && agentsAvailable) {
    return executeWithAgents(command, args);
  } else if (complexity === 'medium' && agentsAvailable) {
    return hybridExecution(command, args);
  } else {
    return directExecution(command, args);
  }
}

function assessMilestoneComplexity(args) {
  const factors = {
    phaseCount: getPhaseCount(args),
    taskCount: estimateTaskCount(args),
    fileCount: estimateFileCount(args),
    gitOperations: estimateGitOperations(args)
  };
  
  if (factors.taskCount > 20 || factors.fileCount > 50) {
    return 'high';
  } else if (factors.taskCount > 10 || factors.fileCount > 20) {
    return 'medium';
  } else {
    return 'low';
  }
}
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

```javascript
class PlanningState {
  constructor(milestoneId) {
    this.structure = {
      planning: {
        status: 'in_progress|complete',
        startedAt: Date,
        completedAt: Date,
        artifacts: {
          scope: '/tmp/milestone-planning-scope-*.json',
          estimates: '/tmp/milestone-planning-estimates-*.json',
          risks: '/tmp/milestone-planning-risks-*.json',
          kiro: '/tmp/milestone-planning-kiro-*.json',
          unified: '/tmp/milestone-plan-*.json'
        },
        metrics: {
          analysisTime: Number,
          confidenceScore: Number,
          complexityScore: Number
        }
      },
      execution: {
        status: 'pending|ready|in_progress|complete',
        planReference: String,
        phases: {},
        progress: {}
      },
      transition: {
        planningComplete: Boolean,
        executionReady: Boolean,
        transitionedAt: Date
      }
    };
  }
}
```

### Planning-to-Execution Transition

```javascript
class PlanningExecutionBridge {
  async transitionToExecution(milestoneId) {
    // Load planning artifacts
    const planningArtifacts = await this.loadPlanningArtifacts(milestoneId);
    
    // Validate planning completeness
    if (!this.validatePlanning(planningArtifacts)) {
      throw new Error('Planning incomplete - cannot transition to execution');
    }
    
    // Transform planning output to execution input
    const executionConfig = {
      milestoneId: milestoneId,
      mode: 'execution',
      phases: this.extractPhases(planningArtifacts),
      tasks: this.extractTasks(planningArtifacts),
      dependencies: planningArtifacts.dependencies,
      kiroStrategy: planningArtifacts.kiroStrategy,
      estimates: planningArtifacts.estimates,
      risks: planningArtifacts.risks
    };
    
    // Initialize execution state
    await this.initializeExecutionState(executionConfig);
    
    // Notify coordinator of mode switch
    await this.notifyCoordinator({
      milestoneId: milestoneId,
      event: 'mode_transition',
      from: 'planning',
      to: 'execution',
      config: executionConfig
    });
    
    return executionConfig;
  }
}
```

## State Synchronization

### Milestone State Bridge

```javascript
class MilestoneStateBridge {
  constructor(milestoneId) {
    this.milestoneId = milestoneId;
    this.commandState = `/tmp/milestone-${milestoneId}.json`;
    this.agentState = `/tmp/milestone-state-${milestoneId}.json`;
  }
  
  async syncFromCommand() {
    // Read command-maintained state
    const commandData = await this.readCommandState();
    
    // Transform to agent format
    const agentData = this.transformToAgentFormat(commandData);
    
    // Write to agent state
    await this.writeAgentState(agentData);
  }
  
  async syncFromAgent() {
    // Read agent-maintained state
    const agentData = await this.readAgentState();
    
    // Transform to command format
    const commandData = this.transformToCommandFormat(agentData);
    
    // Update command state
    await this.updateCommandState(commandData);
  }
  
  transformToAgentFormat(commandData) {
    return {
      metadata: {
        id: commandData.id,
        title: commandData.title,
        created_at: commandData.created,
        status: commandData.status
      },
      phases: this.mapPhases(commandData.phases),
      progress: {
        overall: commandData.progress || 0,
        by_phase: commandData.phaseProgress || {}
      },
      git: {
        branch: commandData.branch,
        commits: commandData.commits || []
      }
    };
  }
  
  transformToCommandFormat(agentData) {
    return {
      id: agentData.metadata.id,
      title: agentData.metadata.title,
      created: agentData.metadata.created_at,
      status: agentData.metadata.status,
      phases: this.unmapPhases(agentData.phases),
      progress: agentData.progress.overall,
      phaseProgress: agentData.progress.by_phase,
      branch: agentData.git.branch,
      commits: agentData.git.commits
    };
  }
}
```

## Progress Aggregation

### Unified Progress Tracking

```javascript
class UnifiedProgressTracker {
  constructor(milestoneId) {
    this.milestoneId = milestoneId;
    this.sources = {
      command: `/tmp/milestone-${milestoneId}.json`,
      coordinator: `/tmp/milestone-coordinator-${milestoneId}.json`,
      executor: `/tmp/milestone-executor-${milestoneId}.json`
    };
  }
  
  async aggregateProgress() {
    const progress = {
      overall: 0,
      phases: {},
      tasks: {},
      agents: {}
    };
    
    // Collect from all sources
    for (const [source, file] of Object.entries(this.sources)) {
      try {
        const data = await fs.readJson(file);
        progress[source] = data.progress || data;
      } catch {
        // Source not available
      }
    }
    
    // Calculate weighted progress
    progress.overall = this.calculateWeightedProgress(progress);
    
    // Update all sources
    await this.broadcastProgress(progress);
    
    return progress;
  }
  
  calculateWeightedProgress(progress) {
    const weights = {
      design: 0.15,
      spec: 0.25,
      task: 0.20,
      execute: 0.40
    };
    
    let total = 0;
    for (const [phase, weight] of Object.entries(weights)) {
      const phaseProgress = this.getPhaseProgress(progress, phase);
      total += phaseProgress * weight;
    }
    
    return Math.round(total * 100);
  }
}
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

### Agent Performance Tracking

```javascript
class MilestonePerformanceTracker {
  async comparePerformance() {
    const metrics = {
      direct: await this.getDirectMetrics(),
      agent: await this.getAgentMetrics()
    };
    
    const comparison = {
      speedup: metrics.agent.time / metrics.direct.time,
      parallelism: metrics.agent.parallelTasks / metrics.direct.sequentialTasks,
      resource_efficiency: metrics.agent.resourceUsage / metrics.direct.resourceUsage,
      quality: metrics.agent.qualityScore / metrics.direct.qualityScore
    };
    
    return {
      metrics: metrics,
      comparison: comparison,
      recommendation: this.getRecommendation(comparison)
    };
  }
  
  getRecommendation(comparison) {
    if (comparison.speedup > 2 && comparison.quality >= 1) {
      return 'always_use_agents';
    } else if (comparison.speedup > 1.5) {
      return 'use_agents_for_complex';
    } else {
      return 'use_direct_for_simple';
    }
  }
}
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