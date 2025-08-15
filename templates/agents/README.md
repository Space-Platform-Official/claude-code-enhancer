# Claude Code Agents - Template Reference

## Overview

This directory contains agent templates that can be spawned by Claude Code for specialized development tasks. For comprehensive documentation of all agents, see [/docs/agents.md](/docs/agents.md).

## Quick Reference

This directory contains 14 specialized agents across 4 categories:

### Testing Agents (4)
- `test-orchestrator` - Adaptive test orchestration
- `unit-test-master` - Unit test specialist
- `integration-test-master` - Integration test specialist  
- `test-fixer` - Test failure resolution

### Milestone Agents (3)
- `milestone-coordinator` - Workflow orchestration
- `milestone-planner` - Strategic planning
- `milestone-executor` - Milestone execution

### Code Quality Agents (3)
- `code-analyzer` - Code analysis and patterns
- `code-quality-enforcer` - Standards enforcement
- `file-processor` - Bulk file operations

### Infrastructure Agents (4)
- `orchestrator` - High-level workflow coordination
- `git-operator` - Git operations automation
- `dependency-manager` - Dependency management
- `api-integration-tester` - API testing

## Detailed Test Agent Documentation

### 🎯 test-orchestrator
**Hybrid Adaptive Test Orchestrator**
- Intelligently switches between unit and integration testing modes
- Automatically categorizes tests and selects optimal execution strategy
- Coordinates multi-agent test execution for maximum efficiency
- Achieves 100% test success rate through comprehensive orchestration

**Use when:**
- You need comprehensive test execution across multiple test types
- You want intelligent test categorization and optimization
- You have a mixed test suite with unit, integration, and e2e tests

### 🚀 unit-test-master
**Unit Test Specialist**
- Focuses on fast, isolated component testing
- Expert mock management and test isolation
- Maximum parallelization for speed
- Deep framework-specific optimizations

**Use when:**
- You need to run or fix unit tests specifically
- You want to optimize unit test performance
- You need expert mock management and isolation

### 🌐 integration-test-master
**Integration Test Specialist**
- Handles complex service orchestration
- Manages test environments and dependencies
- Validates cross-service communication
- Ensures data consistency across systems

**Use when:**
- You need to test service interactions
- You want to validate API contracts
- You need comprehensive end-to-end testing

## Architecture

### Coordination Pattern

The test agents use a sophisticated coordination pattern:

1. **Test Orchestrator** acts as the main coordinator
2. **Specialist Agents** (unit/integration) handle specific test types
3. **Shared Intelligence** provides common capabilities
4. **Coordination Mechanisms** enable agent communication

### 5-Agent Spawning Pattern

Each agent can spawn up to 5 sub-agents for parallel execution:

```markdown
Agent 1: Analysis & Discovery
Agent 2: Environment Setup
Agent 3: Test Execution
Agent 4: Failure Analysis
Agent 5: Validation & Reporting
```

### Shared Components

Located in `_shared/`:
- `test-intelligence.md` - Framework detection, failure analysis, coverage
- `test-coordination.md` - Agent communication, state sync, reporting

## Usage Examples

### Basic Test Orchestration
```bash
# User: "Run all my tests and fix any failures"
# Claude will use test-orchestrator to:
# 1. Discover and categorize all tests
# 2. Execute with optimal strategy
# 3. Fix any failures
# 4. Achieve 100% pass rate
```

### Unit Test Focus
```bash
# User: "Fix my failing unit tests"
# Claude will use unit-test-master to:
# 1. Identify unit test failures
# 2. Analyze mock and isolation issues
# 3. Fix with maximum speed
# 4. Optimize performance
```

### Integration Testing
```bash
# User: "Test my API integrations"
# Claude will use integration-test-master to:
# 1. Setup test environment
# 2. Orchestrate services
# 3. Validate contracts
# 4. Ensure data consistency
```

## Framework Support

All agents support major testing frameworks:

**JavaScript/TypeScript:**
- Jest
- Vitest
- Mocha
- Jasmine

**Python:**
- pytest
- unittest

**Go:**
- Built-in testing

**Ruby:**
- RSpec
- Minitest

**Java:**
- JUnit

**PHP:**
- PHPUnit

**Rust:**
- Built-in testing

## Performance Features

### Intelligent Parallelization
- Unit tests: Maximum parallelization
- Integration tests: Controlled parallelization
- E2E tests: Sequential or limited parallel

### Resource Management
- Automatic resource allocation
- CPU and memory optimization
- Adaptive scaling based on system capacity

### Failure Recovery
- Automatic agent recovery on failure
- Work reassignment to healthy agents
- Session persistence for interruption recovery

## Quality Guarantees

All test agents enforce:
- ✅ 100% test success rate
- ✅ Comprehensive coverage analysis
- ✅ Flaky test elimination
- ✅ Performance optimization
- ✅ Detailed reporting

## Integration with Claude Code

These agents integrate seamlessly with:
- Task tool for true parallelism
- Existing test commands in `/test/`
- Coverage and performance monitoring
- CI/CD workflows

## Best Practices

1. **Start with test-orchestrator** for comprehensive testing
2. **Use specialist agents** for focused optimization
3. **Monitor coordination files** in `/tmp/test-sessions/`
4. **Review aggregated reports** for insights
5. **Let agents handle parallelization** automatically

## Troubleshooting

### Common Issues

**Tests not discovered:**
- Check framework detection in test-intelligence
- Verify test file naming conventions

**Parallelization issues:**
- Review resource allocation
- Check test isolation

**Agent coordination failures:**
- Verify `/tmp/` permissions
- Check session file integrity

## Future Enhancements

Planned improvements:
- Mutation testing capabilities
- Visual regression testing
- Performance baseline tracking
- Contract testing specialization
- Chaos testing integration