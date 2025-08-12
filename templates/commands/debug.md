---
allowed-tools: all
description: Systematic debugging workflow with root cause analysis and verification
---

# 🐛🐛🐛 CRITICAL DEBUGGING REQUIREMENT: FIND AND FIX THE ROOT CAUSE! 🐛🐛🐛

**THIS IS NOT A SYMPTOM INVESTIGATION - THIS IS A ROOT CAUSE ELIMINATION TASK!**

When you run `/debug`, you are REQUIRED to:

1. **REPRODUCE** the issue consistently and reliably
2. **ISOLATE** the root cause using systematic debugging techniques
3. **FIX THE ACTUAL PROBLEM** - not just the symptoms!
4. **USE TASK TOOL AGENTS** for true parallel debugging investigation
5. **DO NOT STOP** until:
   - ✅ Root cause is definitively identified
   - ✅ Fix addresses the underlying problem
   - ✅ Issue cannot be reproduced after fix
   - ✅ No regression in other functionality

**FORBIDDEN BEHAVIORS:**
- ❌ "The error message suggests..." → NO! PROVE THE ROOT CAUSE!
- ❌ "This might be caused by..." → NO! VERIFY WITH EVIDENCE!
- ❌ "Applying this workaround..." → NO! FIX THE REAL PROBLEM!
- ❌ Stopping after masking symptoms → NO! KEEP DIGGING!

**MANDATORY WORKFLOW:**
```
1. Reproduce issue → Confirm the problem
2. IMMEDIATELY spawn Task tool agents for systematic parallel analysis
3. Aggregate findings → Coordinate agent results through /tmp state files
4. Fix root cause → Eliminate the underlying issue
5. VERIFY fix → Ensure problem is solved permanently
```

**YOU ARE NOT DONE UNTIL:**
- The root cause is definitively identified
- The underlying issue is completely resolved
- The fix is verified to work consistently
- No regression testing shows any new issues

---

🛑 **MANDATORY DEBUGGING PROTOCOL** 🛑

Execute systematic debugging analysis for issue: $ARGUMENTS

🚨 **REMEMBER: Bugs in production can cause system failures and data corruption!** 🚨

**Universal Debugging Investigation Protocol:**

**Step 0: Issue Reproduction**
- Create minimal reproducible test case
- Document exact steps to trigger the issue
- Identify environmental factors (OS, version, config)
- Establish baseline behavior vs. buggy behavior

**Step 1: Evidence Collection**
Gather comprehensive diagnostic data:
- Stack traces and error logs
- System metrics at time of failure
- Network requests and responses
- Database query logs
- Memory usage and garbage collection data
- CPU profiling during issue occurrence

**Step 2: Binary Search Debugging Strategy**
Systematically narrow down the problem space:

**Phase A: Component Isolation**
- Identify which major component contains the bug
- Test each component in isolation
- Use dependency injection to mock external systems
- Isolate frontend vs. backend vs. database issues

**Phase B: Code Path Tracing**
- Add strategic logging/debugging statements
- Use debugger step-through for complex logic
- Trace data flow through the entire pipeline
- Identify exact point where behavior diverges

**Phase C: State Analysis**
- Examine variable states at each checkpoint
- Validate assumptions about data structures
- Check for unexpected null/undefined values
- Verify object mutations and side effects

**Step 3: Hypothesis-Driven Investigation**
Generate and test specific hypotheses:

**Common Bug Categories to Investigate:**
1. **Race Conditions**
   - Check for concurrent access to shared resources
   - Verify proper synchronization mechanisms
   - Test under high concurrency loads
   - Look for timing-dependent behavior

2. **Memory Issues**
   - Memory leaks and excessive allocation
   - Buffer overflows and underflows
   - Dangling pointers and use-after-free
   - Garbage collection pressure

3. **Logic Errors**
   - Off-by-one errors in loops and arrays
   - Incorrect conditional logic
   - Edge case handling failures
   - Wrong algorithm implementation

4. **State Management Issues**
   - Inconsistent state updates
   - Stale cache data
   - Session management problems
   - Database transaction issues

5. **Integration Problems**
   - API version mismatches
   - Protocol handling errors
   - Serialization/deserialization issues
   - Third-party service failures

6. **Configuration Errors**
   - Environment-specific settings
   - Missing or incorrect configuration values
   - Security policy conflicts
   - Resource limit constraints

**Step 4: Task Tool Debugging Agent Deployment**
Launch specialized debugging agents using Task tool for true parallelism:

```markdown
I'll spawn 5 specialized debugging agents using Task tool:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Log Analysis Agent</parameter>
<parameter name="prompt">You are the Log Analysis Agent for debugging investigation.

Your responsibilities:
1. Analyze all available log files (application, system, error logs)
2. Identify error patterns, warnings, and anomalies
3. Correlate log entries with issue timeline
4. Extract stack traces and error context
5. Generate log analysis report with findings

Provide comprehensive log analysis to identify root cause indicators.
Save findings to /tmp/log-analysis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Code Inspection Agent</parameter>
<parameter name="prompt">You are the Code Inspection Agent for debugging investigation.

Your responsibilities:
1. Inspect code paths related to the reported issue
2. Analyze function calls, data flow, and state changes
3. Identify potential logic errors, race conditions, edge cases
4. Review recent code changes that might have introduced the bug
5. Generate code inspection report with suspect areas

Provide detailed code analysis focusing on potential root causes.
Save findings to /tmp/code-inspection-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Environment Validation Agent</parameter>
<parameter name="prompt">You are the Environment Validation Agent for debugging investigation.

Your responsibilities:
1. Check system configuration, environment variables, dependencies
2. Validate service availability, network connectivity, permissions
3. Verify resource availability (memory, disk, CPU, network)
4. Compare working vs. failing environment differences
5. Generate environment validation report

Provide comprehensive environment analysis to identify configuration issues.
Save findings to /tmp/env-validation-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Issue Reproduction Agent</parameter>
<parameter name="prompt">You are the Issue Reproduction Agent for debugging investigation.

Your responsibilities:
1. Create minimal reproducible test cases for the issue
2. Systematically reproduce the issue under controlled conditions
3. Test edge cases and boundary conditions that trigger the problem
4. Document exact steps, timing, and conditions for reproduction
5. Generate reproduction report with consistent trigger methods

Provide reliable reproduction methods to enable systematic debugging.
Save findings to /tmp/issue-reproduction-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Solution Synthesis Agent</parameter>
<parameter name="prompt">You are the Solution Synthesis Agent for debugging investigation.

Your responsibilities:
1. Aggregate findings from all debugging agents
2. Correlate evidence to identify the most likely root cause
3. Propose specific fixes addressing the identified root cause
4. Validate fix effectiveness through testing scenarios
5. Generate comprehensive solution report with implementation plan

Synthesize all debugging evidence into actionable root cause solution.
Save solution to /tmp/solution-synthesis-{{TIMESTAMP}}.json for coordination.</parameter>
</invoke>
</function_calls>
```

**Language-Specific Debugging Techniques:**

**For ALL languages:**
- Use language-specific debuggers effectively
- Implement comprehensive logging with context
- Use profiling tools to identify bottlenecks
- Add assertion statements to verify assumptions

**For Go specifically:**
- Use `go test -race` to detect race conditions
- Leverage `go tool pprof` for CPU and memory profiling
- Use `go tool trace` for goroutine analysis
- Add `runtime.Stack()` for detailed stack traces
- Use `context.WithTimeout` to detect hanging operations

**For JavaScript/Node.js:**
- Use Chrome DevTools for frontend debugging
- Leverage Node.js inspector for backend debugging
- Use `console.time`/`console.timeEnd` for performance analysis
- Implement proper error boundaries in React applications
- Use `process.memoryUsage()` for memory monitoring

**For Python:**
- Use `pdb` debugger for interactive debugging
- Leverage `cProfile` for performance profiling
- Use `traceback` module for detailed error information
- Implement proper exception handling with context
- Use `memory_profiler` for memory usage analysis

**Step 5: Root Cause Verification**
Prove the root cause through controlled testing:
- Reproduce the issue in isolation
- Apply the suspected fix
- Verify the issue no longer occurs
- Test edge cases and boundary conditions
- Confirm no new issues are introduced

**Step 6: Fix Implementation Strategy**
Implement the proper solution:

**Fix Categories:**
1. **Immediate Fix**: Resolve the root cause directly
2. **Preventive Fix**: Add safeguards to prevent similar issues
3. **Detective Fix**: Add monitoring to catch issues earlier
4. **Defensive Fix**: Improve error handling and recovery

**Fix Quality Requirements:**
- [ ] Addresses the root cause, not symptoms
- [ ] Doesn't introduce new bugs or regressions
- [ ] Includes comprehensive test coverage
- [ ] Has proper error handling and logging
- [ ] Follows established code patterns
- [ ] Is documented with explanation of the problem and solution

**Step 7: Regression Prevention**
Implement measures to prevent the issue from recurring:
- Add unit tests that specifically cover the bug scenario
- Implement integration tests for the affected workflow
- Add monitoring and alerting for similar failures
- Document the root cause and fix in knowledge base
- Review related code for similar potential issues

**Debugging Anti-patterns (FORBIDDEN):**
- ❌ "Let me try this random fix" → NO, understand the problem first
- ❌ "This works on my machine" → NO, reproduce in target environment
- ❌ "It's probably a caching issue" → NO, verify with evidence
- ❌ "Just restart the service" → NO, find the underlying cause
- ❌ "Add more logging and see what happens" → NO, be strategic
- ❌ "Someone else's code is buggy" → NO, prove it with testing

**Debugging Tool Arsenal:**
- Debuggers (gdb, pdb, Chrome DevTools, VS Code debugger)
- Profilers (pprof, perf, Chrome DevTools Performance)
- Network analysis (Wireshark, browser dev tools, tcpdump)
- Database profilers (EXPLAIN PLAN, slow query logs)
- APM tools (New Relic, DataDog, custom metrics)
- Log aggregation (ELK stack, Splunk, structured logging)

**Final Debugging Verification:**
The issue is resolved when:
✓ Root cause is definitively identified with evidence
✓ Fix directly addresses the underlying problem
✓ Issue cannot be reproduced after applying fix
✓ Comprehensive test coverage prevents regression
✓ Related potential issues have been reviewed and addressed
✓ Monitoring is in place to detect similar future issues

**Step 8: Agent Coordination and Results Aggregation**
Coordinate debugging agents and synthesize findings:

```markdown
**Debugging Agent Coordination Protocol:**

1. **Launch Phase**: Spawn all 5 debugging agents using Task tool
2. **Monitoring Phase**: Each agent writes findings to /tmp/debug-{agent}-{timestamp}.json
3. **Aggregation Phase**: Solution Synthesis Agent reads all state files
4. **Analysis Phase**: Correlate findings to identify definitive root cause
5. **Implementation Phase**: Apply targeted fix addressing root cause
6. **Verification Phase**: Validate fix with comprehensive testing
```

**State File Coordination:**
- Log Analysis: `/tmp/log-analysis-{timestamp}.json`
- Code Inspection: `/tmp/code-inspection-{timestamp}.json`
- Environment Validation: `/tmp/env-validation-{timestamp}.json`
- Issue Reproduction: `/tmp/issue-reproduction-{timestamp}.json`
- Solution Synthesis: `/tmp/solution-synthesis-{timestamp}.json`
- Final Coordination: `/tmp/debugging-final-report-{timestamp}.json`

**Final Debugging Commitment:**
I will now execute EVERY debugging step listed above and FIND THE ROOT CAUSE. I will:
- ✅ Systematically reproduce and isolate the issue
- ✅ SPAWN TASK TOOL DEBUGGING AGENTS for true parallel investigation
- ✅ Coordinate agent findings through /tmp state files
- ✅ Use binary search and hypothesis-driven debugging
- ✅ Keep working until the root cause is definitively identified
- ✅ Fix the underlying problem, not just symptoms
- ✅ Verify the fix resolves the issue completely

I will NOT:
- ❌ Just mask symptoms without understanding the cause
- ❌ Apply random fixes hoping they work
- ❌ Stop investigation at the first plausible explanation
- ❌ Declare "good enough" without verification
- ❌ Skip regression testing
- ❌ Stop working while the root cause remains unknown

**REMEMBER: This is a ROOT CAUSE ELIMINATION task, not symptom management!**

The issue is resolved ONLY when the root cause is eliminated and verified.

**Executing systematic debugging investigation with Task tool agents and ROOT CAUSE ELIMINATION NOW...**