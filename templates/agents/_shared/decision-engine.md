---
description: Intelligent decision engine for determining optimal execution strategy (direct vs agent-based)
---

# Agent Decision Engine

Intelligent routing system that analyzes task complexity and determines whether to use direct execution or spawn specialized agents for optimal performance.

## Core Decision Logic

```yaml
decision_framework:
  inputs:
    - task_type: Classification of the requested operation
    - file_count: Number of files to process
    - operation_complexity: Simple/Medium/Complex
    - parallelism_benefit: Estimated speedup from parallelization
    - resource_availability: Current system resources
    
  outputs:
    - execution_mode: direct | enhanced | full_orchestration
    - agent_selection: List of agents to spawn
    - coordination_strategy: How agents will coordinate
    - expected_performance: Estimated completion time
```

## Complexity Assessment

### Task Complexity Calculator

```javascript
function assessComplexity(task) {
  const metrics = {
    fileCount: 0,
    operationTypes: new Set(),
    dependencies: [],
    estimatedTime: 0,
    parallelismPotential: 0
  };
  
  // File count analysis
  if (task.files) {
    metrics.fileCount = task.files.length;
  }
  
  // Operation type analysis
  if (task.operations) {
    task.operations.forEach(op => metrics.operationTypes.add(op.type));
  }
  
  // Dependency analysis
  metrics.dependencies = analyzeDependencies(task);
  
  // Time estimation
  metrics.estimatedTime = estimateExecutionTime(task);
  
  // Parallelism benefit
  metrics.parallelismPotential = calculateParallelismBenefit(task);
  
  return classifyComplexity(metrics);
}

function classifyComplexity(metrics) {
  if (metrics.fileCount < 3 && 
      metrics.operationTypes.size === 1 && 
      metrics.estimatedTime < 100) {
    return 'SIMPLE';
  }
  
  if (metrics.fileCount < 10 && 
      metrics.operationTypes.size <= 3 && 
      metrics.estimatedTime < 5000) {
    return 'MEDIUM';
  }
  
  return 'COMPLEX';
}
```

## Execution Mode Selection

### Decision Matrix

| Complexity | File Count | Parallelism Benefit | Execution Mode | Agents |
|------------|------------|---------------------|----------------|---------|
| SIMPLE | < 3 | Low | Direct | None |
| SIMPLE | 3-5 | Medium | Enhanced | 1-2 selective |
| MEDIUM | < 10 | Low | Direct | None |
| MEDIUM | < 10 | High | Enhanced | 2-3 specialized |
| COMPLEX | > 10 | Any | Full Orchestration | 3-5 coordinated |
| ANY | > 50 | High | Full Orchestration | 5 parallel |

### Agent Selection Logic

```yaml
agent_selection_rules:
  test_operations:
    primary: test-fixer
    support: [code-analyzer]
    threshold: "> 5 test files"
    
  code_analysis:
    primary: code-analyzer
    support: [code-quality-enforcer]
    threshold: "> 10 files OR complex analysis"
    
  git_operations:
    primary: git-operator
    support: []
    threshold: "conflicts OR multi-branch"
    
  file_processing:
    primary: file-processor
    support: []
    threshold: "> 20 files"
    
  quality_enforcement:
    primary: code-quality-enforcer
    support: [code-analyzer]
    threshold: "full codebase scan"
    
  complex_orchestration:
    primary: orchestrator
    support: [any required agents]
    threshold: "multiple operation types"
```

## Performance Prediction

### Execution Time Estimation

```javascript
function estimateExecutionTime(task, mode) {
  const baseTime = calculateBaseTime(task);
  
  switch(mode) {
    case 'direct':
      return baseTime;
      
    case 'enhanced':
      // 2-3x speedup for suitable tasks
      const parallelismFactor = Math.min(task.parallelismPotential, 0.4);
      return baseTime * (1 - parallelismFactor);
      
    case 'full_orchestration':
      // 3-10x speedup for complex tasks
      const orchestrationOverhead = 500; // ms
      const parallelSpeedup = Math.min(task.parallelismPotential, 0.8);
      return orchestrationOverhead + (baseTime * (1 - parallelSpeedup));
      
    default:
      return baseTime;
  }
}

function calculateBaseTime(task) {
  let time = 0;
  
  // File operations: ~50ms per file
  time += task.fileCount * 50;
  
  // Analysis operations: ~100ms per file
  if (task.requiresAnalysis) {
    time += task.fileCount * 100;
  }
  
  // Transformation operations: ~200ms per file
  if (task.requiresTransformation) {
    time += task.fileCount * 200;
  }
  
  // Network operations: ~500ms per request
  if (task.networkOperations) {
    time += task.networkOperations * 500;
  }
  
  return time;
}
```

## Resource Management

### Resource Availability Check

```yaml
resource_checks:
  cpu:
    threshold: 80%
    action: "Reduce agent count or defer"
    
  memory:
    threshold: 75%
    action: "Use sequential processing"
    
  disk_io:
    threshold: 90%
    action: "Batch operations"
    
  agent_slots:
    max: 5
    current: "Check active agents"
    action: "Queue or fallback to direct"
```

### Dynamic Adjustment

```javascript
class ResourceMonitor {
  constructor() {
    this.limits = {
      maxAgents: 5,
      maxMemory: 500 * 1024 * 1024, // 500MB
      maxCpu: 80 // percentage
    };
  }
  
  canSpawnAgent() {
    const current = this.getCurrentResources();
    
    return current.agentCount < this.limits.maxAgents &&
           current.memoryUsage < this.limits.maxMemory &&
           current.cpuUsage < this.limits.maxCpu;
  }
  
  adjustExecutionMode(preferredMode) {
    if (!this.canSpawnAgent()) {
      // Downgrade execution mode
      if (preferredMode === 'full_orchestration') {
        return 'enhanced';
      }
      if (preferredMode === 'enhanced') {
        return 'direct';
      }
    }
    return preferredMode;
  }
}
```

## Decision Engine API

### Usage Example

```javascript
// Decision engine usage in commands
async function executeCommand(command, args) {
  // Analyze task
  const task = {
    type: command.type,
    files: await getTargetFiles(args),
    operations: command.operations,
    complexity: await analyzeComplexity(args)
  };
  
  // Get execution decision
  const decision = decisionEngine.decide(task);
  
  console.log(`Execution mode: ${decision.mode}`);
  console.log(`Agents to spawn: ${decision.agents.join(', ')}`);
  console.log(`Expected speedup: ${decision.speedup}x`);
  
  // Execute based on decision
  switch(decision.mode) {
    case 'direct':
      return executeDirectly(command, args);
      
    case 'enhanced':
      return executeWithAgents(command, args, decision.agents);
      
    case 'full_orchestration':
      return orchestrateExecution(command, args, decision);
  }
}
```

### Decision Response Format

```json
{
  "mode": "enhanced",
  "agents": ["test-fixer", "code-analyzer"],
  "coordination": "parallel_independent",
  "reasoning": {
    "complexity": "MEDIUM",
    "fileCount": 8,
    "parallelismBenefit": "HIGH",
    "resourceAvailability": "GOOD"
  },
  "performance": {
    "estimatedTime": "3.2s",
    "expectedSpeedup": "2.8x",
    "confidence": 0.85
  },
  "fallback": {
    "mode": "direct",
    "trigger": "resource_exhaustion"
  }
}
```

## Integration with Commands

### Command Integration Pattern

```markdown
# In any command file:

## Execution Strategy

I'll analyze the task complexity to determine the optimal execution approach:

<use decision engine>
- Task type: {{COMMAND_TYPE}}
- File count: {{FILE_COUNT}}
- Complexity: {{COMPLEXITY_ASSESSMENT}}
</use>

Based on the analysis:
- Execution mode: {{DECISION_MODE}}
- Performance benefit: {{EXPECTED_SPEEDUP}}

{{IF mode == "full_orchestration"}}
I'll spawn multiple specialized agents for optimal performance:
[Spawn orchestrator and specialized agents]
{{ELSE IF mode == "enhanced"}}
I'll use selective agents for key operations:
[Spawn specific agents]
{{ELSE}}
I'll execute this directly for fastest results:
[Direct execution]
{{/IF}}
```

## Continuous Learning

### Performance Tracking

```yaml
performance_metrics:
  track:
    - actual_vs_estimated_time
    - agent_utilization
    - resource_consumption
    - error_rates
    
  adjust:
    - complexity_thresholds
    - agent_selection_rules
    - parallelism_estimates
    - resource_limits
    
  report:
    - weekly_performance_summary
    - optimization_opportunities
    - threshold_adjustments
```

## Decision Quality Gates

**Before making decision:**
- [ ] Task analyzed completely
- [ ] Resources checked
- [ ] Complexity assessed
- [ ] Performance estimated

**After decision:**
- [ ] Mode selected appropriately
- [ ] Agents identified correctly
- [ ] Fallback defined
- [ ] Performance tracked

The decision engine ensures optimal execution strategy selection, maximizing performance while maintaining system stability and resource efficiency.