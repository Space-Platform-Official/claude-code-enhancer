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

## Critical Reminders

1. **ALWAYS use Task tool** for agent spawning
2. **NEVER use bash functions** with `&`
3. **Replace template variables** before use
4. **Test parallelism** is real parallelism
5. **Monitor agent outputs** for coordination