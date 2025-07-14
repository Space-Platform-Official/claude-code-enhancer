---
allowed-tools: all
description: Identify untested code paths and spawn agents to achieve comprehensive test coverage
---

# 🚨 CRITICAL TEST COVERAGE IMPROVEMENT 🚨

**THIS IS NOT AN ANALYSIS TASK - THIS IS A TESTING IMPLEMENTATION TASK!**

When you run `/test-coverage`, you are REQUIRED to:

1. **ANALYZE** current test coverage and identify gaps
2. **IMPLEMENT COMPREHENSIVE TESTS** for all untested critical paths
3. **USE MULTIPLE AGENTS** to create tests in parallel:
   - Spawn one agent per module/component
   - Spawn agents for different test types (unit, integration, e2e)
   - Say: "I'll spawn multiple agents to create comprehensive test coverage in parallel"
4. **DO NOT STOP** until:
   - ✅ All critical business logic is tested
   - ✅ Coverage targets are achieved
   - ✅ Edge cases and error paths are covered
   - ✅ Tests are meaningful and robust

**FORBIDDEN BEHAVIORS:**
- ❌ "Coverage is at 85%, that's good enough" → NO! Focus on critical paths!
- ❌ "These functions are simple, no tests needed" → NO! Test all business logic!
- ❌ "I'll just add a few basic tests" → NO! Create comprehensive coverage!
- ❌ Stopping after partial implementation → NO! KEEP WORKING!

**MANDATORY WORKFLOW:**
```
1. Analyze current coverage → Identify gaps
2. IMMEDIATELY spawn agents to create tests for ALL gaps
3. Re-run coverage analysis → Find remaining gaps
4. Fix those too
5. REPEAT until critical paths are fully tested
```

**YOU ARE NOT DONE UNTIL:**
- All critical business logic has meaningful tests
- Specified coverage targets are achieved
- Edge cases and error conditions are tested
- All tests pass and are non-flaky

---

🛑 **MANDATORY PRE-COVERAGE CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current TODO.md status
3. Verify you understand the coverage goals

Execute comprehensive test coverage improvement for: $ARGUMENTS

**FORBIDDEN EXCUSE PATTERNS:**
- "This function is too simple to test" → NO, test it anyway
- "Coverage numbers look good" → NO, focus on quality not quantity
- "These are just getters/setters" → NO, test the behavior
- "Integration tests cover this" → NO, also need unit tests
- "The code is obviously correct" → NO, tests document behavior

Let me ultrathink about achieving comprehensive test coverage for critical business logic.

🚨 **REMEMBER: Quality over quantity - focus on meaningful tests!** 🚨

**Test Coverage Improvement Protocol:**

**Step 0: Coverage Baseline Analysis**
- Run existing test coverage tools to establish baseline
- Identify which files/functions have zero or minimal coverage
- Prioritize critical business logic and public APIs
- Check for existing test patterns and frameworks in use

**Step 1: Critical Path Identification**
- Analyze codebase to identify core business logic
- Map data flow through critical user journeys
- Identify error handling and edge case scenarios
- Prioritize by business impact and complexity

**Step 2: Coverage Gap Analysis**
Run coverage analysis tools:
- `go test -coverprofile=coverage.out` for Go projects
- `npm test -- --coverage` for JavaScript/TypeScript
- Language-appropriate coverage tools
- Generate detailed coverage reports

**Critical Areas to Test:**
- All public APIs and exported functions
- Business logic and domain models
- Data validation and transformation
- Error handling and recovery paths
- Configuration and initialization code
- Integration points with external services

**For Go projects specifically:**
- Test all exported functions and methods
- Cover error return paths thoroughly
- Test concurrent code with race detection
- Validate context cancellation handling
- Test timeout and retry logic
- Cover configuration parsing and validation

**Step 3: Agent Spawning Strategy**
When coverage gaps are identified, spawn agents strategically:
```
"I found coverage gaps in 12 modules. I'll spawn agents to create comprehensive tests:
- Agent 1: Core business logic tests (auth, user management)
- Agent 2: Data layer tests (database operations, validation)
- Agent 3: API endpoint tests (HTTP handlers, middleware)
- Agent 4: Error handling and edge case tests
- Agent 5: Integration and end-to-end test scenarios
Let me tackle all of these in parallel..."
```

**Test Quality Requirements:**
- [ ] Tests cover happy path scenarios completely
- [ ] Error conditions and edge cases are tested
- [ ] Input validation is thoroughly covered
- [ ] State transitions are verified
- [ ] Concurrent behavior is tested where applicable
- [ ] Performance characteristics are validated for critical paths
- [ ] Integration points with external dependencies are mocked/tested

**Go Testing Best Practices:**
- [ ] Table-driven tests for multiple input scenarios
- [ ] Subtests for logical grouping
- [ ] Proper test fixtures and setup/teardown
- [ ] Mock external dependencies appropriately
- [ ] Test with -race flag for concurrent code
- [ ] Benchmark tests for performance-critical code
- [ ] Example tests for public APIs

**Test Implementation Guidelines:**
- Write tests that document expected behavior
- Test behavior, not implementation details
- Use meaningful test names that describe scenarios
- Include both positive and negative test cases
- Test boundary conditions and edge cases
- Verify error messages and types are correct

**Coverage Target Strategy:**
Focus on achieving high coverage for:
1. **Critical Business Logic** (aim for 95%+ coverage)
2. **Public APIs** (aim for 100% coverage)
3. **Error Handling** (test all error paths)
4. **Data Validation** (test all validation rules)
5. **Configuration** (test all config scenarios)

**Failure Response Protocol:**
When coverage gaps are found:
1. **IMMEDIATELY SPAWN AGENTS** to create tests in parallel
2. **IMPLEMENT COMPREHENSIVE TESTS** - Cover ALL identified gaps
3. **VERIFY** - Re-run coverage analysis after implementation
4. **REPEAT** - If gaps remain, spawn more agents and fill those too
5. **NO STOPPING** - Keep working until targets are achieved
6. **NO SHORTCUTS** - Don't skip edge cases or error paths

**Agent Task Distribution Patterns:**

**Pattern A: Module-Based Coverage**
```
Agent 1: Authentication module tests (login, logout, token validation)
Agent 2: User management tests (CRUD operations, permissions)
Agent 3: Data processing tests (transformations, calculations)
Agent 4: API layer tests (routing, middleware, serialization)
```

**Pattern B: Test Type Distribution**
```
Agent 1: Unit tests for core business logic
Agent 2: Integration tests for database operations
Agent 3: API integration tests for HTTP endpoints
Agent 4: End-to-end tests for complete user flows
```

**Pattern C: Domain-Based Coverage**
```
Agent 1: User domain (registration, authentication, profiles)
Agent 2: Order domain (creation, processing, fulfillment)
Agent 3: Payment domain (processing, validation, refunds)
Agent 4: Notification domain (sending, templates, delivery)
```

**Test Verification Checklist:**
- [ ] All critical business logic paths are tested
- [ ] Error handling scenarios are covered
- [ ] Edge cases and boundary conditions tested
- [ ] Configuration and environment variations tested
- [ ] Concurrent behavior tested where applicable
- [ ] Integration points are properly mocked
- [ ] Tests are deterministic and non-flaky
- [ ] Test data is realistic and representative

**Final Coverage Verification:**
The test suite is complete when:
✓ Coverage reports show critical paths are tested
✓ All new tests pass consistently
✓ Error scenarios are properly validated
✓ Integration tests verify component interactions
✓ Performance-critical paths have benchmarks
✓ Documentation reflects tested behavior

**Final Commitment:**
I will now execute comprehensive test coverage improvement and CREATE ALL MISSING TESTS. I will:
- ✅ Analyze current coverage and identify ALL gaps
- ✅ SPAWN MULTIPLE AGENTS to create tests in parallel
- ✅ Keep working until coverage targets are achieved
- ✅ Not stop until critical business logic is fully tested

I will NOT:
- ❌ Just report coverage gaps without fixing them
- ❌ Skip complex or difficult-to-test code
- ❌ Accept "good enough" coverage numbers
- ❌ Stop at basic happy-path tests
- ❌ Ignore error handling and edge cases
- ❌ Stop working while ANY critical gaps remain

**REMEMBER: This is a TEST IMPLEMENTATION task, not a coverage reporting task!**

The coverage is complete ONLY when all critical business logic has meaningful, comprehensive test coverage.

**Executing comprehensive test coverage improvement and IMPLEMENTING ALL MISSING TESTS NOW...**