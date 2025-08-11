---
allowed-tools: all
description: **EXECUTE all unit tests** with comprehensive coverage analysis and parallel agent coordination
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: UNIT TEST EXECUTION AND VALIDATION! ⚡⚡⚡

**THIS IS NOT A SIMPLE TEST RUN - THIS IS A COMPREHENSIVE UNIT TEST EXECUTION SYSTEM!**

When you run `/test/unit`, you are REQUIRED to:

1. **EXECUTE** all unit tests with framework-specific optimizations and parallel processing
2. **ANALYZE** test coverage gaps and generate actionable improvement recommendations
3. **VALIDATE** unit test quality and identify potential improvements
4. **REPORT** comprehensive test results with detailed failure analysis
5. **USE MULTIPLE AGENTS** for parallel unit test execution using Task tool

I'll spawn 5 specialized agents using Task tool for comprehensive unit testing:

**Test Discovery Agent:**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Discover and categorize unit tests</parameter>
<parameter name="prompt">You are the Test Discovery Agent.

Your responsibilities:
1. Scan the project for all unit test files across frameworks (Jest, pytest, Go test, RSpec, PHPUnit)
2. Identify test frameworks and configuration patterns
3. Categorize tests by speed and complexity (fast/slow tests)
4. Map test coverage gaps and missing test files
5. Generate comprehensive test inventory with framework optimizations
6. Validate test structure and organization
7. Report on test file distribution and patterns

Provide detailed test discovery report including:
- Total test count by framework
- Test categorization (fast/slow)
- Framework-specific configurations
- Missing test coverage areas
- Structural recommendations

Save results to /tmp/test-discovery-results.json for coordination.</parameter>
</invoke>
</function_calls>
```

**Test Execution Agent:**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Execute unit tests in parallel</parameter>
<parameter name="prompt">You are the Test Execution Agent.

Your responsibilities:
1. Execute unit tests in parallel batches using framework-specific optimizations
2. Run Jest with --maxWorkers, pytest with -n auto, Go with -parallel
3. Capture comprehensive test results and execution metrics
4. Monitor test execution progress and performance
5. Generate detailed test execution logs
6. Validate 100% success rate requirement (MANDATORY)
7. Block execution if any tests fail

CRITICAL: 100% TEST SUCCESS RATE REQUIRED
- Any failing tests MUST block execution
- Provide detailed failure analysis
- No coverage analysis until 100% success achieved

Execute tests with:
- Framework-specific parallel execution
- Comprehensive result capture
- Performance monitoring
- Mandatory success validation

Save results to /tmp/test-execution-results.json for coordination.</parameter>
</invoke>
</function_calls>
```

**Test Analysis Agent:**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Analyze test failures and quality</parameter>
<parameter name="prompt">You are the Test Analysis Agent.

Your responsibilities:
1. Analyze failing test results and identify root causes
2. Parse framework-specific error messages and stack traces
3. Identify patterns in test failures (flaky tests, environment issues)
4. Validate test quality against best practices
5. Check for proper assertions, mocking, and test structure
6. Generate actionable recommendations for test improvements
7. Prioritize fixes by impact and complexity

Analysis includes:
- Root cause analysis of failures
- Test quality validation
- Best practices compliance
- Flaky test identification
- Performance bottlenecks
- Structural improvements

Only execute after Test Execution Agent confirms results.
Save analysis to /tmp/test-analysis-results.json for coordination.</parameter>
</invoke>
</function_calls>
```

**Coverage Agent:**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Measure comprehensive test coverage</parameter>
<parameter name="prompt">You are the Coverage Agent.

Your responsibilities:
1. Generate comprehensive test coverage reports using framework tools
2. Calculate line, branch, and function coverage metrics
3. Identify uncovered code paths and critical gaps
4. Parse coverage data (Jest coverage-final.json, pytest .coverage, Go coverage.out)
5. Prioritize coverage gaps by business impact
6. Generate actionable recommendations for test additions
7. Create coverage improvement roadmap

Coverage analysis includes:
- Line coverage percentage and gaps
- Branch coverage analysis
- Function/method coverage
- Critical path coverage validation
- Coverage trend analysis
- Gap prioritization by importance

Generate reports in HTML and JSON formats.
Save results to /tmp/coverage-results.json for coordination.</parameter>
</invoke>
</function_calls>
```

**Fix Coordinator Agent:**
```markdown
<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Coordinate test fixes and reporting</parameter>
<parameter name="prompt">You are the Fix Coordinator Agent.

Your responsibilities:
1. Coordinate outputs from all test agents
2. Compile comprehensive test execution report
3. Prioritize identified issues by severity and impact
4. Generate actionable fix recommendations
5. Create unified test quality dashboard
6. Monitor fix implementation progress
7. Validate that all requirements are met

Coordination tasks:
- Aggregate results from /tmp/test-*-results.json files
- Create unified status report
- Prioritize fixes by impact
- Generate implementation timeline
- Validate completion criteria
- Provide executive summary

COMPLETION VALIDATION:
- ✅ 100% unit test success rate achieved
- ✅ All unit tests discovered and executed
- ✅ Test coverage analyzed with gap identification
- ✅ Test quality validated against best practices
- ✅ Actionable recommendations provided
- ✅ Performance metrics collected

Generate final report to /tmp/unit-test-final-report.json</parameter>
</invoke>
</function_calls>
```

**FORBIDDEN BEHAVIORS:**
- ❌ "Run basic npm test command" → NO! Use framework-specific optimizations!
- ❌ "Skip coverage analysis" → NO! Comprehensive coverage reporting required!
- ❌ **"Accept any test failures"** → NO! 100% SUCCESS RATE MANDATORY!
- ❌ **"Continue with failing tests"** → NO! ALL FAILURES MUST BE FIXED!
- ❌ "Ignore test failures" → NO! Detailed failure analysis and fixing required!
- ❌ "Single-threaded execution" → NO! Use parallel agent coordination!
- ❌ "Generic test output" → NO! Framework-specific parsing and reporting!

**MANDATORY WORKFLOW:**
```
1. Framework detection → Identify test framework and configuration
2. IMMEDIATELY spawn 5 agents using Task tool for parallel execution
3. Test discovery → Find all unit test files and categorize them
4. Parallel execution → Run tests across multiple agents
5. **100% SUCCESS VALIDATION** → BLOCK EXECUTION if any test fails
6. Coverage analysis → Generate comprehensive coverage reports only after 100% success
7. VERIFY results → Ensure all tests pass and coverage meets thresholds
```

**YOU ARE NOT DONE UNTIL:**
- ✅ **100% UNIT TEST SUCCESS RATE ACHIEVED** - NO FAILURES ALLOWED
- ✅ All unit tests discovered and executed successfully
- ✅ Test coverage analyzed with gap identification
- ✅ **ZERO FAILED TESTS** - Any failure must be fixed before proceeding
- ✅ Performance metrics collected and reported
- ✅ Actionable recommendations provided for improvements
- ✅ Test quality validated and documented

---

🛑 **MANDATORY UNIT TEST EXECUTION PROTOCOL** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current test framework configuration
3. Verify unit test structure and organization

Execute comprehensive unit test execution with ZERO tolerance for incomplete coverage analysis.

**FORBIDDEN SHORTCUT PATTERNS:**
- "Basic test run is sufficient" → NO, comprehensive execution required
- "Skip slow tests for speed" → NO, all tests must be executed
- "Coverage reports are optional" → NO, mandatory coverage analysis
- "Manual failure analysis is fine" → NO, automated analysis required
- "Single agent execution is faster" → NO, parallel execution mandatory

You are executing unit tests for: $ARGUMENTS

**Command-line PHP Control Flags:**
Parse and respect these flags in $ARGUMENTS:
- `--no-php`: Skip all PHP-specific behaviors and structure validation
- `--skip-php-structure-check`: Skip PHP structure validation only

Let me ultrathink about comprehensive unit test execution with parallel agent coordination.

🚨 **REMEMBER: Unit tests are the foundation of code quality and reliability!** 🚨

**Agent Coordination Protocol:**

The 5 agents work in coordinated phases:

**Phase 1: Discovery (Test Discovery Agent)**
- Framework detection and configuration
- Test file discovery and categorization
- Structure validation
- Results: /tmp/test-discovery-results.json

**Phase 2: Execution (Test Execution Agent)**
- Parallel test execution with framework optimizations
- Real-time progress monitoring
- Performance metrics collection
- Mandatory 100% success validation
- Results: /tmp/test-execution-results.json

**Phase 3: Analysis (Test Analysis Agent + Coverage Agent)**
- Failure analysis and root cause identification
- Test quality validation
- Coverage gap analysis and prioritization
- Results: /tmp/test-analysis-results.json, /tmp/coverage-results.json

**Phase 4: Coordination (Fix Coordinator Agent)**
- Result aggregation and prioritization
- Comprehensive reporting
- Action plan generation
- Results: /tmp/unit-test-final-report.json

**Framework-Specific Optimizations:**

**Jest:**
```bash
npx jest --coverage --maxWorkers=4 --verbose --testPathPattern="test|spec"
```

**pytest:**
```bash
python -m pytest -v --cov=. --cov-report=html --cov-report=term -n auto
```

**Go test:**
```bash
go test -v -race -coverprofile=coverage.out -parallel 4 ./...
```

**RSpec:**
```bash
bundle exec rspec --format documentation --format html --out rspec_results.html
```

**PHPUnit:**
```bash
./vendor/bin/phpunit --coverage-html coverage --coverage-text --process-isolation
```

**Performance Monitoring:**

Each agent tracks:
- Execution time per test suite
- Memory usage during execution
- Parallel execution efficiency
- Framework-specific optimizations applied
- Coverage generation time

**Quality Validation Criteria:**

- Test structure follows framework best practices
- Proper use of assertions and expectations
- Appropriate mocking and stubbing
- Test isolation and independence
- Descriptive test names and organization
- Adequate test coverage (>80% recommended)

**Failure Analysis Framework:**

1. **Syntax Errors**: Code compilation/parsing failures
2. **Logic Errors**: Incorrect test expectations or implementations
3. **Environment Issues**: Missing dependencies, configuration problems
4. **Flaky Tests**: Inconsistent results due to timing or state issues
5. **Performance Issues**: Tests exceeding reasonable execution time

**Coverage Gap Prioritization:**

1. **Critical Paths**: Core business logic and error handling
2. **Security Functions**: Authentication, authorization, input validation
3. **Data Processing**: Database operations, API integrations
4. **Edge Cases**: Boundary conditions, error scenarios
5. **Utility Functions**: Helper methods and common operations

**Final Verification Checklist:**
- [ ] All 5 agents spawned successfully using Task tool
- [ ] Framework detection completed correctly
- [ ] All unit tests discovered and categorized
- [ ] 100% test success rate achieved (MANDATORY)
- [ ] Comprehensive coverage analysis completed
- [ ] Test quality validated against best practices
- [ ] Performance metrics collected and analyzed
- [ ] Actionable recommendations generated
- [ ] Final coordination report produced
- [ ] All temporary coordination files cleaned up

**Anti-Patterns to Avoid:**
- ❌ Using bash functions with & instead of Task tool
- ❌ Running tests without coverage analysis
- ❌ Accepting any test failures without fixing
- ❌ Single-threaded execution without parallelization
- ❌ Generic reporting without framework-specific insights
- ❌ Skipping test quality validation
- ❌ Missing coordination between agents

**REMEMBER:**
This is UNIT TEST EXECUTION mode with true parallel agent coordination using Task tool. The goal is comprehensive testing with coverage analysis, quality validation, and performance optimization through specialized agent collaboration.

Executing comprehensive unit test execution protocol with parallel Task tool agent coordination...