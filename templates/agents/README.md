# Claude Code Native Agents

A high-performance, parallel execution system for Claude Code operations using specialized agents and intelligent orchestration.

## Overview

The Claude Code Agent System transforms sequential command execution into efficient parallel operations through specialized agents, intelligent routing, and robust coordination mechanisms.

### Key Benefits

- **3-10x Performance Improvement** for complex operations
- **Intelligent Execution** with automatic mode selection
- **Resource Management** preventing system overload
- **Fault Tolerance** with isolated agent failures
- **Scalable Architecture** supporting various workload types

## Available Agents

### Core Agents

| Agent | Purpose | Optimal For | Resource Usage |
|-------|---------|-------------|----------------|
| **orchestrator** | Master coordination | Complex multi-agent workflows | Low |
| **test-fixer** | Test operations | Failing tests, coverage analysis | Medium |
| **code-analyzer** | Code analysis | Refactoring, optimization, review | Low |
| **git-operator** | Version control | Commits, merges, conflicts | Low |
| **file-processor** | Batch operations | Large-scale transformations | High |
| **code-quality-enforcer** | Quality standards | Linting, formatting, compliance | Medium |

## Architecture

```
┌─────────────────────────────────────────┐
│         Command Interface Layer         │
└─────────────────┬───────────────────────┘
                  │
         ┌────────▼────────┐
         │ Decision Engine │
         └────────┬────────┘
                  │
    ┌─────────────┼─────────────┐
    │             │             │
┌───▼──┐    ┌────▼────┐    ┌───▼────┐
│Direct│    │Enhanced │    │  Full  │
│ Exec │    │  Agents │    │Orchestr│
└──────┘    └─────────┘    └────────┘
                  │             │
          ┌───────┴───────┬─────┴────┐
          │               │          │
    ┌─────▼────┐   ┌─────▼────┐  ┌──▼──┐
    │ Test Fix │   │Code Anal │  │ ... │
    └──────────┘   └──────────┘  └─────┘
```

## Usage

### Agent Invocation

Agents are invoked through the Task tool with specific parameters:

```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Fix failing tests</parameter>
<parameter name="prompt">You are the Test Fixing Agent...</parameter>
</invoke>
</function_calls>
```

### Execution Modes

The Decision Engine automatically selects the optimal execution mode:

1. **Direct Execution** - Simple, single-file operations
2. **Enhanced Execution** - Medium complexity with selective agents
3. **Full Orchestration** - Complex operations requiring multiple agents

### Coordination

Agents coordinate through shared state files in `/tmp/claude-agents/`:

```
/tmp/claude-agents/{session-id}/
├── registry/       # Active agent tracking
├── state/         # Shared state files
├── messages/      # Inter-agent messages
├── results/       # Agent outputs
├── locks/         # Coordination locks
└── metrics/       # Performance data
```

## Integration with Commands

### Converting Commands to Use Agents

Commands can leverage agents through the decision engine:

```yaml
# In command file
execution_strategy:
  analyze_complexity: true
  use_decision_engine: true
  fallback: direct_execution
  
  agent_mapping:
    test_operations: test-fixer
    code_analysis: code-analyzer
    git_operations: git-operator
    file_processing: file-processor
    quality_checks: code-quality-enforcer
```

### Example: Test Command with Agents

```markdown
# Complexity Assessment
Files to test: 25
Estimated time: 30s sequential, 8s parallel
Decision: Use enhanced execution with test-fixer agents

# Agent Deployment
Spawning 3 test-fixer agents for parallel execution:
- Agent 1: Unit tests
- Agent 2: Integration tests
- Agent 3: Coverage analysis

# Coordination
Results aggregated from all agents
Final report generated
```

## Performance Optimization

### Parallel Execution Patterns

#### Map-Reduce Pattern
```
Files → [Agent1, Agent2, Agent3] → Results → Aggregator → Report
```

#### Pipeline Pattern
```
Discovery → Analysis → Transformation → Validation → Complete
```

#### Scatter-Gather Pattern
```
Task → [All Agents] → First Valid Result → Complete
```

### Resource Management

The system enforces strict resource limits:

- **Global Limits**
  - Max 5 concurrent agents
  - Max 2GB total memory
  - Max 80% CPU usage

- **Per-Agent Limits**
  - Memory: 200-600MB depending on type
  - CPU: 10-30% depending on type
  - Timeout: 60-600s depending on operation

## Monitoring

### Agent Status

Monitor active agents and their resource usage:

```bash
# View active agents
ls /tmp/claude-agents/*/registry/agents.json

# Check resource usage
cat /tmp/claude-agents/*/metrics/*.json
```

### Performance Metrics

The system tracks:
- Execution time improvements
- Resource utilization
- Agent success rates
- Coordination overhead

## Best Practices

### When to Use Agents

**Use Agents For:**
- Operations on 5+ files
- Complex analysis requiring specialization
- Tasks with parallelization potential
- Multi-step workflows

**Use Direct Execution For:**
- Simple, single-file edits
- Quick lookups or searches
- Operations < 100ms
- Sequential dependencies

### Agent Selection

The Decision Engine considers:
1. Task complexity and file count
2. Available system resources
3. Parallelization benefit
4. Agent specialization match

### Error Handling

Agents provide isolated failure handling:
- Agent failures don't affect others
- Automatic retry with backoff
- Fallback to direct execution
- Comprehensive error reporting

## Advanced Features

### Custom Agent Creation

Create specialized agents for specific workflows:

```yaml
name: custom-agent
description: Specialized agent for custom operations
model: sonnet
capabilities:
  - custom_analysis
  - specialized_processing
resource_requirements:
  memory: 400MB
  cpu: 20%
  timeout: 180s
```

### Agent Composition

Combine agents for complex workflows:

```javascript
workflow: {
  stages: [
    { agent: 'code-analyzer', task: 'identify_issues' },
    { agent: 'file-processor', task: 'apply_fixes' },
    { agent: 'code-quality-enforcer', task: 'validate_quality' },
    { agent: 'git-operator', task: 'commit_changes' }
  ]
}
```

## Troubleshooting

### Common Issues

**Agent Spawn Failures**
- Check resource availability
- Verify session initialization
- Review agent limits

**Coordination Failures**
- Check `/tmp/claude-agents/` permissions
- Verify lock file cleanup
- Review message queue status

**Performance Issues**
- Monitor resource usage
- Check for agent timeouts
- Review parallelization settings

### Debug Mode

Enable detailed logging:

```bash
export CLAUDE_AGENT_DEBUG=1
export CLAUDE_AGENT_LOG_LEVEL=verbose
```

## Migration Guide

### From Sequential Commands

1. Identify parallelization opportunities
2. Map operations to agent capabilities
3. Integrate decision engine
4. Test with various workloads
5. Monitor performance improvements

### Gradual Adoption

Start with:
1. Test commands (highest benefit)
2. Quality enforcement
3. File processing operations
4. Complex orchestrations

## API Reference

### Task Tool Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `subagent_type` | string | Agent type to spawn |
| `description` | string | Brief task description |
| `prompt` | string | Detailed agent instructions |

### Decision Engine API

```javascript
const decision = decisionEngine.decide({
  type: 'test_operation',
  files: ['test1.js', 'test2.js'],
  complexity: 'medium'
});

// Returns:
{
  mode: 'enhanced',
  agents: ['test-fixer'],
  expectedSpeedup: '3x'
}
```

### Coordination API

```javascript
// Initialize session
const session = coordination.initSession('test-operation');

// Register agent
coordination.registerAgent(session, {
  id: 'test-fixer-001',
  type: 'test-fixer',
  capabilities: ['test_execution']
});

// Share state
coordination.setState(session, 'progress', { percent: 50 });

// Send message
coordination.sendMessage(session, {
  from: 'agent-001',
  to: 'agent-002',
  type: 'task_complete'
});
```

## Future Enhancements

- **Dynamic Agent Scaling** - Auto-scale based on workload
- **Cross-Project Coordination** - Share agents across projects
- **Machine Learning Optimization** - Learn optimal agent selection
- **Custom Agent Marketplace** - Share specialized agents
- **Visual Monitoring Dashboard** - Real-time agent visualization

## Contributing

To contribute new agents or improvements:

1. Follow the agent template structure
2. Implement required agent interface
3. Add resource requirements
4. Include coordination patterns
5. Document capabilities and usage

## Support

For issues or questions:
- Check troubleshooting guide
- Review agent logs in `/tmp/claude-agents/`
- Consult decision engine reasoning
- Report issues with full context

---

The Claude Code Agent System represents a significant evolution in command execution, delivering dramatic performance improvements while maintaining reliability and ease of use.