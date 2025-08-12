---
description: Reusable Task tool agent templates for consistent parallelism
---

# Task Tool Agent Templates

Standardized templates for implementing true parallelism across all commands.

## Test Command Agents

### Test Discovery Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Discover tests</parameter>
<parameter name="prompt">You are the Test Discovery Agent.

Your responsibilities:
1. Scan the project for all test files
2. Identify test frameworks and patterns
3. Map test coverage gaps
4. Categorize tests by type and priority
5. Generate discovery report

Provide comprehensive test inventory.</parameter>
</invoke>
</function_calls>
```

### Test Execution Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Execute tests</parameter>
<parameter name="prompt">You are the Test Execution Agent.

Your responsibilities:
1. Run tests in parallel batches
2. Capture test results and metrics
3. Identify failing tests and errors
4. Generate execution reports
5. Monitor test performance

Execute tests efficiently with full reporting.</parameter>
</invoke>
</function_calls>
```

### Test Fix Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Fix failing tests</parameter>
<parameter name="prompt">You are the Test Fix Agent.

Your responsibilities:
1. Analyze failing test results
2. Identify root causes of failures
3. Implement fixes for test issues
4. Validate fixes with re-runs
5. Update test documentation

Fix all failing tests to achieve 100% pass rate.</parameter>
</invoke>
</function_calls>
```

### Coverage Analysis Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Analyze coverage</parameter>
<parameter name="prompt">You are the Coverage Analysis Agent.

Your responsibilities:
1. Calculate test coverage metrics
2. Identify uncovered code paths
3. Prioritize coverage gaps
4. Generate coverage reports
5. Recommend test additions

Provide comprehensive coverage analysis.</parameter>
</invoke>
</function_calls>
```

## Code Review Agents

### Code Analysis Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Analyze code</parameter>
<parameter name="prompt">You are the Code Analysis Agent.

Your responsibilities:
1. Scan code for quality issues
2. Identify patterns and anti-patterns
3. Check style and conventions
4. Detect potential bugs
5. Generate analysis report

Provide comprehensive code analysis.</parameter>
</invoke>
</function_calls>
```

### Review Suggestion Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Generate suggestions</parameter>
<parameter name="prompt">You are the Review Suggestion Agent.

Your responsibilities:
1. Generate improvement suggestions
2. Prioritize issues by impact
3. Provide fix recommendations
4. Create actionable feedback
5. Track suggestion acceptance

Provide helpful review suggestions.</parameter>
</invoke>
</function_calls>
```

## Generic Parallel Processing Agents

### Parallel Processor Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">{{TASK_DESCRIPTION}}</parameter>
<parameter name="prompt">You are the {{AGENT_NAME}}.

Your responsibilities:
1. {{RESPONSIBILITY_1}}
2. {{RESPONSIBILITY_2}}
3. {{RESPONSIBILITY_3}}
4. {{RESPONSIBILITY_4}}
5. {{RESPONSIBILITY_5}}

{{COMPLETION_INSTRUCTION}}</parameter>
</invoke>
</function_calls>
```

## Implementation Pattern

When implementing Task tool agents in any command:

1. **Replace conceptual descriptions** with actual Task tool invocations
2. **Use appropriate subagent_type**:
   - `test-fixer` for test-related tasks
   - `general-purpose` for most other tasks
   - `statusline-setup` for configuration tasks
3. **Include clear responsibilities** in the prompt
4. **Specify output locations** for agent results
5. **Coordinate through shared files** when needed

## Migration Guide

### From Bash Functions to Task Tool:

**OLD (Bash Function):**
```bash
spawn_test_agent() {
    echo "Starting test agent..."
    # Bash implementation
}
spawn_test_agent &
```

**NEW (Task Tool):**
```markdown
[Use Test Execution Agent Template above]
```

### From Conceptual to Implementation:

**OLD (Conceptual):**
```
"I'll spawn multiple agents to handle testing:
- Test Runner Agent: Execute tests in parallel
- Coverage Agent: Analyze test coverage"
```

**NEW (Implementation):**
```markdown
I'll spawn 2 specialized agents using Task tool:

[Use Test Execution Agent Template]
[Use Coverage Analysis Agent Template]
```

## Performance Benefits

| Approach | Parallelism | Speed | Isolation | Error Recovery |
|----------|------------|-------|-----------|----------------|
| Sequential | 0% | 1x | None | Stops on error |
| Bash Functions | Fake | 1.2x | Minimal | Limited |
| Task Tool | Real | 3-5x | Full | Per-agent |

## File Processing Agents

### Batch File Processor Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Process files in parallel</parameter>
<parameter name="prompt">You are the Batch File Processor Agent.

Your responsibilities:
1. Process files in parallel batches for optimal performance
2. Apply consistent transformations across file sets
3. Validate file integrity before and after processing
4. Handle file encoding and format conversions
5. Report processing results with error handling
6. Coordinate with other agents through shared state files

Process files efficiently while maintaining data integrity.
Save results to /tmp/batch-processing-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### File Analysis Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Analyze file patterns and structures</parameter>
<parameter name="prompt">You are the File Analysis Agent.

Your responsibilities:
1. Analyze file structures, patterns, and dependencies
2. Identify file relationships and import/export mappings
3. Detect code smells and architectural issues in file organization
4. Generate file metrics and complexity reports
5. Recommend file reorganization strategies
6. Map file usage patterns and hotspots

Provide comprehensive file analysis for optimization decisions.
Save analysis to /tmp/file-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

### File Transformation Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Transform files with format conversions</parameter>
<parameter name="prompt">You are the File Transformation Agent.

Your responsibilities:
1. Convert files between different formats and encodings
2. Apply systematic refactoring transformations
3. Migrate code patterns and update syntax
4. Preserve file metadata and permissions
5. Validate transformations with integrity checks
6. Handle large file sets efficiently

Execute file transformations safely with full validation.
Save transformation log to /tmp/file-transformations-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Safety Validation Agents

### Safety Backup Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Create safety backups before operations</parameter>
<parameter name="prompt">You are the Safety Backup Agent.

Your responsibilities:
1. Create comprehensive backups before risky operations
2. Verify backup integrity and completeness
3. Store backups in secure, accessible locations
4. Generate backup manifests with file checksums
5. Implement incremental backup strategies
6. Coordinate with rollback procedures

Ensure complete data protection before any destructive operations.
Save backup manifest to /tmp/safety-backup-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Rollback Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute rollback procedures safely</parameter>
<parameter name="prompt">You are the Rollback Agent.

Your responsibilities:
1. Execute rollback procedures when operations fail
2. Restore files from safety backups with verification
3. Validate rollback completeness and integrity
4. Handle partial rollbacks and selective restoration
5. Report rollback status and any issues encountered
6. Coordinate with other agents during recovery

Execute rollbacks safely to restore system state.
Save rollback status to /tmp/rollback-status-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Health Check Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Validate system health and integrity</parameter>
<parameter name="prompt">You are the Health Check Agent.

Your responsibilities:
1. Validate system state and file integrity
2. Run comprehensive health checks on critical components
3. Verify that operations completed successfully
4. Check for corruption or inconsistent states
5. Monitor system resources and performance
6. Report health status with actionable recommendations

Ensure system integrity throughout operations.
Save health report to /tmp/health-check-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Language-Specific Formatting Agents

### JavaScript/TypeScript Formatter Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Format JavaScript/TypeScript code</parameter>
<parameter name="prompt">You are the JavaScript/TypeScript Formatter Agent.

Your responsibilities:
1. Apply Prettier formatting with project-specific configuration
2. Run ESLint with auto-fix for style and quality issues
3. Organize and optimize imports automatically
4. Handle TypeScript-specific formatting rules
5. Process large codebases efficiently in parallel
6. Validate formatting integrity and syntax correctness

Format JS/TS code to consistent, high-quality standards.
Save formatting results to /tmp/js-format-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Python Formatter Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Format Python code</parameter>
<parameter name="prompt">You are the Python Formatter Agent.

Your responsibilities:
1. Apply Black formatting for consistent Python style
2. Run isort for import organization and optimization
3. Use flake8 or pylint for code quality checks
4. Handle Python-specific formatting edge cases
5. Process multiple Python files in parallel batches
6. Validate syntax and formatting integrity

Format Python code to PEP 8 and project standards.
Save formatting results to /tmp/python-format-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Go Formatter Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Format Go code</parameter>
<parameter name="prompt">You are the Go Formatter Agent.

Your responsibilities:
1. Apply gofmt for standard Go formatting
2. Use goimports for import management and organization
3. Run golint or staticcheck for code quality
4. Handle Go modules and package structure
5. Process Go packages in parallel for efficiency
6. Validate Go syntax and build compatibility

Format Go code to official Go standards.
Save formatting results to /tmp/go-format-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Analysis and Reporting Agents

### Metrics Collection Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Collect comprehensive metrics</parameter>
<parameter name="prompt">You are the Metrics Collection Agent.

Your responsibilities:
1. Collect performance metrics from all operations
2. Measure code quality metrics (complexity, maintainability)
3. Track operation timing and resource usage
4. Generate statistical analysis of improvements
5. Compare before/after metrics for validation
6. Aggregate metrics from multiple parallel agents

Provide comprehensive metrics for operation assessment.
Save metrics to /tmp/metrics-collection-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Report Generation Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Generate comprehensive reports</parameter>
<parameter name="prompt">You are the Report Generation Agent.

Your responsibilities:
1. Aggregate results from all parallel agents
2. Generate executive summaries and detailed reports
3. Create visual representations of data and metrics
4. Provide actionable recommendations and next steps
5. Format reports for different audiences (technical/business)
6. Include error analysis and lessons learned

Generate comprehensive reports from parallel operations.
Save final report to /tmp/final-report-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Coordination Agents

### Master Coordinator Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Coordinate parallel agent execution</parameter>
<parameter name="prompt">You are the Master Coordinator Agent.

Your responsibilities:
1. Orchestrate execution of multiple parallel agents
2. Monitor agent progress and handle coordination
3. Aggregate results from all agents systematically
4. Handle error propagation and recovery procedures
5. Ensure all agents complete successfully before final steps
6. Generate unified status reports and final coordination

Coordinate parallel agents for optimal execution flow.
Save coordination status to /tmp/coordination-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

### Error Handling Agent Template:
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Handle errors across parallel agents</parameter>
<parameter name="prompt">You are the Error Handling Agent.

Your responsibilities:
1. Monitor error conditions across all parallel agents
2. Implement error recovery and retry strategies
3. Coordinate rollback procedures when necessary
4. Analyze error patterns and root causes
5. Provide detailed error reports with solutions
6. Ensure graceful degradation of operations

Handle errors gracefully to maintain operation integrity.
Save error analysis to /tmp/error-handling-{{TIMESTAMP}}.json</parameter>
</invoke>
</function_calls>
```

## Standardized Coordination Patterns

### Shared State File Management

**State File Naming Convention:**
```
/tmp/agent-{operation}-{timestamp}.json
/tmp/{agent-type}-results-{timestamp}.json
/tmp/coordination-status-{timestamp}.json
/tmp/final-report-{timestamp}.json
```

**State File Structure:**
```json
{
  "agent_id": "unique-agent-identifier",
  "operation": "operation-name",
  "timestamp": "2024-01-01T12:00:00Z",
  "status": "completed|in_progress|failed",
  "results": {
    "files_processed": 42,
    "success_count": 40,
    "error_count": 2,
    "metrics": {},
    "recommendations": []
  },
  "errors": [],
  "next_steps": []
}
```

### Agent Result Aggregation Pattern

```markdown
<!-- Coordination Template -->
1. **Launch Phase**: Spawn all required agents with Task tool
2. **Monitoring Phase**: Each agent writes to /tmp/agent-{name}-{timestamp}.json
3. **Aggregation Phase**: Coordinator reads all state files
4. **Validation Phase**: Verify all agents completed successfully
5. **Reporting Phase**: Generate unified results and recommendations
```

### Progress Tracking Pattern

```markdown
<!-- Progress Tracking Template -->
**Agent Progress Coordination:**

1. **Initialization**: Each agent creates /tmp/progress-{agent}-{timestamp}.json
2. **Updates**: Agents update progress files regularly
3. **Monitoring**: Coordinator tracks progress across all agents
4. **Completion**: Final status aggregated in /tmp/final-status-{timestamp}.json
```

## Performance Guidelines

### When to Use Task Tool vs Bash Functions

**✅ Use Task Tool When:**
- 3+ independent operations can run in parallel
- Operations take >30 seconds each
- Different skill sets needed (test-fixer vs general-purpose)
- Error isolation required between operations
- Results need aggregation from multiple sources

**❌ Avoid Task Tool When:**
- Single sequential operation
- Operations are interdependent
- Total time <1 minute
- Simple coordination sufficient

### Optimal Agent Batching Strategies

**File Processing:**
- Batch size: 50-100 files per agent
- Max agents: 4-6 (based on CPU cores)
- Coordination: Round-robin file assignment

**Code Analysis:**
- Batch by modules/directories
- Max agents: 3-5 per operation type
- Coordination: Hierarchical result aggregation

**Testing:**
- Batch by test suites/frameworks
- Max agents: 5-7 specialized agents
- Coordination: Sequential dependency handling

### Performance Optimization Tips

1. **Spawn Agents Early**: Launch all agents at operation start
2. **Use Shared State**: Coordinate through /tmp files, not direct communication
3. **Batch Operations**: Group similar work for efficiency
4. **Monitor Resources**: Balance parallelism with system capacity
5. **Handle Failures**: Implement robust error handling and recovery

## Migration Examples

### From Bash Functions to Task Tool

**❌ OLD (Bash Functions with &):**
```bash
process_files() {
    echo "Processing files..."
    # Sequential or fake parallel processing
}
process_files &
```

**✅ NEW (Task Tool):**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Process files in parallel</parameter>
<parameter name="prompt">[Use Batch File Processor Template above]</parameter>
</invoke>
</function_calls>
```

### From Sequential to Parallel

**❌ OLD (Sequential):**
```
Step 1: Analyze code
Step 2: Run tests  
Step 3: Generate report
```

**✅ NEW (Parallel):**
```markdown
I'll spawn 3 agents in parallel:

[Code Analysis Agent Template]
[Test Execution Agent Template]  
[Report Generation Agent Template]
```

## Critical Reminders

1. **ALWAYS use Task tool** for agent spawning (never bash functions with &)
2. **REPLACE template variables** ({{TIMESTAMP}}, {{AGENT_NAME}}) before use
3. **USE shared state files** (/tmp/*) for coordination between agents
4. **MONITOR agent completion** before proceeding to next phase
5. **AGGREGATE results** systematically for comprehensive reporting
6. **HANDLE errors gracefully** with proper rollback procedures
7. **VALIDATE completion** of all parallel operations
8. **CLEAN UP** temporary coordination files after operations