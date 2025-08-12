---
allowed-tools: all
description: Orchestrate comprehensive quality workflows across format, cleanup, dedupe, and verify commands
---

# 🚨🚨🚨 CRITICAL REQUIREMENT: ORCHESTRATE COMPLETE QUALITY WORKFLOW! 🚨🚨🚨

**THIS IS NOT A REPORTING TASK - THIS IS A COMPREHENSIVE FIXING ORCHESTRATION!**

When you run `/check`, you are REQUIRED to:

1. **ANALYZE PROJECT** and select appropriate quality workflow
2. **ORCHESTRATE QUALITY COMMANDS** in proper dependency order
3. **SPAWN MULTIPLE TASK TOOL AGENTS** to execute quality commands in true parallel:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute format quality command</parameter>
<parameter name="prompt">You are the Format Quality Agent.

Your responsibilities:
1. Execute `/quality/format` command for comprehensive code formatting
2. Apply consistent formatting across all languages in the project
3. Handle formatting errors and retry with appropriate fixes
4. Generate detailed formatting metrics and improvements
5. Save results to /tmp/format-quality-{{timestamp}}.json
6. Coordinate with other quality agents through shared state files

Execute comprehensive code formatting and report all improvements.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute cleanup quality command</parameter>
<parameter name="prompt">You are the Cleanup Quality Agent.

Your responsibilities:
1. Execute `/quality/cleanup` command for dead code removal
2. Remove unused imports, variables, and functions across all files
3. Optimize code structure and eliminate redundancies
4. Handle cleanup errors and ensure code integrity
5. Save results to /tmp/cleanup-quality-{{timestamp}}.json
6. Coordinate with other quality agents through shared state files

Execute comprehensive code cleanup and report all optimizations.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute dedupe quality command</parameter>
<parameter name="prompt">You are the Dedupe Quality Agent.

Your responsibilities:
1. Execute `/quality/dedupe` command for duplicate detection and removal
2. Identify and consolidate duplicate code patterns and functions
3. Merge similar code blocks and extract common utilities
4. Validate deduplication doesn't break functionality
5. Save results to /tmp/dedupe-quality-{{timestamp}}.json
6. Coordinate with other quality agents through shared state files

Execute comprehensive code deduplication and report all consolidations.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Execute verify quality command</parameter>
<parameter name="prompt">You are the Verify Quality Agent.

Your responsibilities:
1. Execute `/quality/verify` command for final validation
2. Run comprehensive syntax, style, and standards verification
3. Perform security analysis and dependency auditing
4. Validate all previous quality operations completed successfully
5. Save results to /tmp/verify-quality-{{timestamp}}.json
6. Generate final quality report aggregating all agent results

Execute comprehensive code verification and generate final quality status.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Coordinate quality pipeline execution</parameter>
<parameter name="prompt">You are the Quality Coordinator Agent.

Your responsibilities:
1. Monitor all quality agents' progress through /tmp state files
2. Aggregate results from format, cleanup, dedupe, and verify agents
3. Handle error propagation and coordinate retry operations
4. Ensure proper execution order and dependencies
5. Generate unified quality report from all operations
6. Save final coordination status to /tmp/quality-coordination-{{timestamp}}.json

Coordinate the complete quality pipeline and ensure all operations succeed.</parameter>
</invoke>
</function_calls>

4. **DO NOT STOP** until:
   - ✅ ALL quality commands complete successfully
   - ✅ ALL format/cleanup/dedupe/verify operations pass
   - ✅ Complete workflow shows GREEN status
   - ✅ EVERYTHING is VALIDATED and OPTIMIZED

**FORBIDDEN BEHAVIORS:**
- ❌ "Here are the quality issues" → NO! ORCHESTRATE FIXES!
- ❌ "Format command reports problems" → NO! COORDINATE RESOLUTION!
- ❌ "Cleanup found issues" → NO! MANAGE COMPLETE PIPELINE!
- ❌ Stopping after individual command results → NO! COMPLETE FULL WORKFLOW!

**MANDATORY ORCHESTRATION WORKFLOW:**
```
1. Analyze project → Select quality workflow
2. IMMEDIATELY spawn 5 Task tool agents in parallel:
   - Format Quality Agent
   - Cleanup Quality Agent  
   - Dedupe Quality Agent
   - Verify Quality Agent
   - Quality Coordinator Agent
3. Execute format → cleanup → dedupe → verify sequence through agent coordination
4. Aggregate results through /tmp state file coordination
5. REPEAT any failed stages until EVERYTHING passes
```

**YOU ARE NOT DONE UNTIL:**
- All quality commands execute successfully
- Format operations complete with zero issues
- Cleanup removes all dead code and optimizes imports
- Dedupe eliminates all code duplication
- Verify validates complete codebase quality
- Complete orchestrated workflow shows green/passing status

---

🛑 **MANDATORY PRE-FLIGHT CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you're not declaring "done" prematurely

Execute comprehensive quality checks with ZERO tolerance for excuses.

**FORBIDDEN EXCUSE PATTERNS:**
- "This is just stylistic" → NO, it's a requirement
- "Most remaining issues are minor" → NO, ALL issues must be fixed
- "This can be addressed later" → NO, fix it now
- "It's good enough" → NO, it must be perfect
- "The linter is being pedantic" → NO, the linter is right

Let me ultrathink about validating this codebase against our exceptional standards.

🚨 **REMEMBER: Hooks will verify EVERYTHING and block on violations!** 🚨

**Universal Quality Verification Protocol:**

**Step 0: Hook Status Check**
- Run `~/.claude/hooks/smart-lint.sh` directly to see current state
- If ANY issues exist, they MUST be fixed before proceeding
- Check `~/.claude/hooks/violation-status.sh` if it exists

**Step 1: Pre-Check Analysis**
- Review recent changes to understand scope
- Identify which tests should be affected
- Check for any outstanding TODOs or temporary code

**Step 2: Language-Agnostic Linting**
Run appropriate linters for ALL languages in the project:
- `make lint` if Makefile exists
- `~/.claude/hooks/smart-lint.sh` for automatic detection
- Manual linter runs if needed

**Universal Requirements:**
- ZERO warnings across ALL linters
- ZERO disabled linter rules without documented justification
- ZERO "nolint" or suppression comments without explanation
- ZERO formatting issues (all code must be auto-formatted)

**For Go projects specifically:**
- ZERO warnings from golangci-lint (all checks enabled)
- No disabled linter rules without explicit justification
- No use of interface{} or any{} types
- No nolint comments unless absolutely necessary with explanation
- Proper error wrapping with context
- No naked returns in functions over 5 lines
- Consistent naming following Go conventions

**Step 3: Test Verification**
Run `make test` and ensure:
- ALL tests pass without flakiness
- Test coverage is meaningful (not just high numbers)
- Table-driven tests for complex logic
- No skipped tests without justification
- Benchmarks exist for performance-critical paths
- Tests actually test behavior, not implementation details

**Go Quality Checklist:**
- [ ] No interface{} or any{} - concrete types everywhere
- [ ] Simple error handling - no custom error hierarchies
- [ ] Early returns to reduce nesting
- [ ] Meaningful variable names (userID not id)
- [ ] Proper context propagation
- [ ] No goroutine leaks
- [ ] Deferred cleanup where appropriate
- [ ] No race conditions (run with -race flag)
- [ ] No time.Sleep() for synchronization - channels used instead
- [ ] Select with timeouts instead of polling loops

**Code Hygiene Verification:**
- [ ] All exported symbols have godoc comments
- [ ] No commented-out code blocks
- [ ] No debugging print statements
- [ ] No placeholder implementations
- [ ] Consistent formatting (gofmt/goimports)
- [ ] Dependencies are actually used
- [ ] No circular dependencies

**Security Audit:**
- [ ] Input validation on all external data
- [ ] SQL queries use prepared statements
- [ ] Crypto operations use crypto/rand
- [ ] No hardcoded secrets or credentials
- [ ] Proper permission checks
- [ ] Rate limiting where appropriate

**Performance Verification:**
- [ ] No obvious N+1 queries
- [ ] Appropriate use of pointers vs values
- [ ] Buffered channels where beneficial
- [ ] Connection pooling configured
- [ ] No unnecessary allocations in hot paths
- [ ] No busy-wait loops consuming CPU
- [ ] Channels used for efficient goroutine coordination

**Failure Response Protocol:**
When issues are found:
1. **IMMEDIATELY SPAWN TASK TOOL AGENTS** to fix issues in parallel:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Fix linting issues batch 1</parameter>
<parameter name="prompt">You are the Lint Fix Agent 1.

Your responsibilities:
1. Fix linting issues in files A, B, C
2. Apply automatic fixes where possible
3. Handle complex linting violations manually
4. Validate fixes don't break functionality
5. Save results to /tmp/lint-fixes-batch1-{{timestamp}}.json

Fix all assigned linting issues and report completion status.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">general-purpose</parameter>
<parameter name="description">Fix linting issues batch 2</parameter>
<parameter name="prompt">You are the Lint Fix Agent 2.

Your responsibilities:
1. Fix linting issues in files D, E, F
2. Apply automatic fixes where possible
3. Handle complex linting violations manually
4. Validate fixes don't break functionality
5. Save results to /tmp/lint-fixes-batch2-{{timestamp}}.json

Fix all assigned linting issues and report completion status.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Fix failing tests</parameter>
<parameter name="prompt">You are the Test Fix Agent.

Your responsibilities:
1. Fix the 3 failing tests identified
2. Analyze test failure root causes
3. Update test implementation or fix underlying code
4. Ensure all tests pass after fixes
5. Save results to /tmp/test-fixes-{{timestamp}}.json

Fix all failing tests and ensure 100% test pass rate.</parameter>
</invoke>
</function_calls>
2. **FIX EVERYTHING** - Address EVERY issue, no matter how "minor"
3. **VERIFY** - Re-run all checks after fixes
4. **REPEAT** - If new issues found, spawn more agents and fix those too
5. **NO STOPPING** - Keep working until ALL checks show ✅ GREEN
6. **NO EXCUSES** - Common invalid excuses:
   - "It's just formatting" → Auto-format it NOW
   - "It's a false positive" → Prove it or fix it NOW
   - "It works fine" → Working isn't enough, fix it NOW
   - "Other code does this" → Fix that too NOW
7. **ESCALATE** - Only ask for help if truly blocked after attempting fixes

**Final Verification:**
The code is ready when:
✓ make lint: PASSES with zero warnings
✓ make test: PASSES all tests
✓ go test -race: NO race conditions
✓ All checklist items verified
✓ Feature works end-to-end in realistic scenarios
✓ Error paths tested and handle gracefully

**Final Commitment:**
I will now execute EVERY check listed above and FIX ALL ISSUES using Task tool agents. I will:
- ✅ Run all checks to identify issues
- ✅ SPAWN MULTIPLE TASK TOOL AGENTS to fix issues in true parallel
- ✅ Coordinate through /tmp state files for optimal performance
- ✅ Keep working until EVERYTHING passes
- ✅ Not stop until all checks show passing status

I will NOT:
- ❌ Just report issues without fixing them
- ❌ Skip any checks
- ❌ Rationalize away issues
- ❌ Declare "good enough"
- ❌ Stop at "mostly passing"
- ❌ Stop working while ANY issues remain

**REMEMBER: This is a FIXING task, not a reporting task!**

The code is ready ONLY when every single check shows ✅ GREEN.

**Executing comprehensive validation and FIXING ALL ISSUES NOW with Task tool parallel agents...**

## Task Tool Agent Coordination Pattern

**State File Management:**
- `/tmp/format-quality-{timestamp}.json` - Format agent results
- `/tmp/cleanup-quality-{timestamp}.json` - Cleanup agent results  
- `/tmp/dedupe-quality-{timestamp}.json` - Dedupe agent results
- `/tmp/verify-quality-{timestamp}.json` - Verify agent results
- `/tmp/quality-coordination-{timestamp}.json` - Coordinator status
- `/tmp/final-quality-report-{timestamp}.json` - Aggregated results

**Performance Benefits:**
- **3-5x faster execution** through true parallelism
- **Isolated error handling** per quality operation
- **Real-time progress monitoring** via state files
- **Scalable agent coordination** for complex projects
- **Automatic retry mechanisms** for failed operations

**Agent Execution Flow:**
1. **Launch Phase**: All 5 agents spawn simultaneously
2. **Coordination Phase**: Agents coordinate through shared state files
3. **Execution Phase**: Quality operations run in parallel with dependencies
4. **Aggregation Phase**: Coordinator collects and validates all results
5. **Reporting Phase**: Unified quality report with comprehensive metrics