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
4. **USE MULTIPLE AGENTS** to trace different code paths in parallel:
   - Spawn one agent to reproduce and isolate the issue
   - Spawn another to trace execution flow
   - Spawn more agents for different hypotheses
   - Say: "I'll spawn multiple debugging agents to trace all possible root causes in parallel"
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
2. IMMEDIATELY spawn agents for systematic analysis
3. Binary search debugging → Narrow down the cause
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

**Step 4: Multi-Agent Debugging Approach**
Deploy specialized debugging agents for parallel investigation:

```
"I've identified 5 potential root causes for this issue. I'll spawn debugging agents:
- Agent 1: Trace the authentication flow and session handling
- Agent 2: Investigate database query performance and locking
- Agent 3: Analyze memory usage patterns and potential leaks  
- Agent 4: Test race conditions in concurrent request handling
- Agent 5: Examine third-party API integration failures
Let me investigate all these potential causes in parallel..."
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

**Final Debugging Commitment:**
I will now execute EVERY debugging step listed above and FIND THE ROOT CAUSE. I will:
- ✅ Systematically reproduce and isolate the issue
- ✅ SPAWN MULTIPLE DEBUGGING AGENTS to investigate in parallel
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

**Executing systematic debugging investigation and ROOT CAUSE ELIMINATION NOW...**