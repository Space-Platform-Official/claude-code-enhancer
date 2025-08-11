---
allowed-tools: all
description: **EXECUTE and fix all failing tests** with comprehensive root cause analysis and verification
intensity: ⚡⚡⚡⚡
pattern: 🔧🔧🔧🔧
---

# 🔧🔧🔧🔧 CRITICAL TEST EXECUTION AND FIXING: COMPREHENSIVE TEST RESOLUTION! 🔧🔧🔧🔧

**THIS IS NOT A SIMPLE TEST FIX - THIS IS A COMPREHENSIVE TEST EXECUTION AND RESOLUTION SYSTEM!**

**🚨 ACTUAL TEST EXECUTION REQUIRED - TESTS MUST BE RUN AND VERIFIED! 🚨**

When you run `/test fix`, you are REQUIRED to:

1. **EXECUTE** failing tests to reproduce and validate failures  
2. **ANALYZE** test failures and perform comprehensive root cause analysis
3. **IMPLEMENT** fixes that address root causes, not just symptoms
4. **VERIFY** all tests pass through actual execution
5. **USE MULTIPLE AGENTS** for parallel test debugging:
   - Spawn one agent per failing test or failure category
   - Spawn agents for different debugging approaches (stack trace, environment, dependencies)
   - Say: "I'll spawn multiple agents to debug and fix all failing tests in parallel"
6. **VERIFY** fixes work correctly and don't introduce regressions
7. **PREVENT** similar failures through improved test design and practices

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR TEST DEBUGGING:**

I'll spawn 5 specialized agents using Task tool for comprehensive test fixing:

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Analyze test failures and categorize issues</parameter>
<parameter name="prompt">You are the Failure Analysis Agent for comprehensive test debugging.

Your responsibilities:
1. Collect all failing test information and error details
2. Categorize failures by type (assertion, timeout, mock, async, environment, flaky)
3. Analyze error patterns and stack traces
4. Prioritize failures by severity and impact
5. Group related failures together
6. Generate comprehensive failure analysis report
7. Coordinate with other test fix agents

Analyze all failing tests systematically and provide detailed categorization for targeted fixes.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Implement fixes for identified root causes</parameter>
<parameter name="prompt">You are the Fix Implementation Agent for comprehensive test debugging.

Your responsibilities:
1. Receive failure analysis from Failure Analysis Agent
2. Perform deep root cause analysis for each failure category
3. Implement systematic fixes addressing root causes (not symptoms)
4. Handle assertion errors, timeout issues, mock problems, and async errors
5. Apply fixes incrementally with proper rollback capability
6. Document all changes made during fix implementation
7. Coordinate with validation agents for fix verification

Implement comprehensive fixes that address root causes and improve test reliability.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Verify fixes work correctly</parameter>
<parameter name="prompt">You are the Validation Agent for comprehensive test debugging.

Your responsibilities:
1. Receive fix implementations from Fix Implementation Agent
2. Execute fixed tests multiple times to verify stability
3. Check that all previously failing tests now pass consistently
4. Measure performance improvements and execution times
5. Validate fix effectiveness without introducing new issues
6. Generate validation reports with test execution results
7. Coordinate with regression prevention agent

Verify all fixes work correctly and provide stable, reliable test results.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Ensure fixes don't introduce regressions</parameter>
<parameter name="prompt">You are the Regression Prevention Agent for comprehensive test debugging.

Your responsibilities:
1. Identify all tests related to the fixed functionality
2. Execute comprehensive regression test suites
3. Monitor for new test failures introduced by fixes
4. Check integration points and dependency impacts
5. Verify that existing passing tests remain stable
6. Generate regression analysis reports
7. Coordinate rollback if regressions are detected

Ensure all fixes maintain system stability and don't introduce new failures.</parameter>
</invoke>
</function_calls>

<function_calls>
<invoke name="Task">
<parameter name="subagent_type">test-fixer</parameter>
<parameter name="description">Improve test design and prevent future failures</parameter>
<parameter name="prompt">You are the Prevention Enhancement Agent for comprehensive test debugging.

Your responsibilities:
1. Analyze patterns in fixed failures to identify prevention opportunities
2. Implement test reliability improvements (determinism, isolation, timing)
3. Create linting rules and templates to prevent similar issues
4. Add monitoring and alerting for test quality metrics
5. Update documentation with lessons learned and best practices
6. Establish failure prevention measures and quality gates
7. Generate final comprehensive test debugging report

Implement prevention measures to avoid similar test failures in the future.</parameter>
</invoke>
</function_calls>

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ "Just comment out the failing test" → NO! Fix the root cause!
- ❌ Apply quick fixes without understanding → NO! Analyze thoroughly!
- ❌ Ignore test environment issues → NO! Environment affects reliability!
- ❌ Skip regression testing → NO! Verify fixes don't break other tests!
- ❌ "It's just a flaky test" → NO! Make tests deterministic!
- ❌ Fix symptoms instead of root causes → NO! Address underlying issues!

**MANDATORY WORKFLOW:**
```
1. TEST EXECUTION → Run tests to identify and reproduce failures
2. Failure analysis → Categorize and prioritize failing tests  
3. IMMEDIATELY spawn agents for parallel debugging
4. Root cause identification → Deep analysis of underlying issues
5. Fix implementation → Address root causes comprehensively
6. TEST VERIFICATION → Re-run tests to confirm fixes work
7. Regression testing → Verify fixes don't introduce new issues
8. FINAL VERIFICATION → Ensure 100% test pass rate
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL tests have been EXECUTED and failures identified
- ✅ ALL failing tests are fixed and passing through ACTUAL EXECUTION
- ✅ Root causes are identified and addressed
- ✅ Fixes are verified through TEST EXECUTION to not introduce regressions
- ✅ Test reliability is improved and verified through execution
- ✅ Prevention measures are implemented
- ✅ Test debugging knowledge is documented

---

🛑 **MANDATORY TEST DEBUGGING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current failing tests and their error patterns
3. Verify you understand the test debugging requirements

Execute comprehensive test debugging and fixing for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "This test is too complex to debug" → NO, break it down systematically!
- "Random fixes might work" → NO, use systematic debugging!
- "Environment issues are someone else's problem" → NO, fix the environment!
- "Flaky tests are normal" → NO, make them deterministic!
- "Quick fixes are faster" → NO, fix root causes properly!

Let me ultrathink about the comprehensive test debugging architecture and fixing strategy.

🚨 **REMEMBER: Properly debugged and fixed tests improve code quality and team velocity!** 🚨

**Comprehensive Test Debugging and Fixing Protocol:**

**Step 0: Test Failure Analysis and Categorization**
- Collect all failing test information and error details
- Categorize failures by type and severity
- Prioritize fixes based on impact and complexity
- Set up debugging environment and tools
- Prepare systematic debugging approach

**Step 1: Comprehensive Failure Analysis**

**Failure Analysis Framework:**
```typescript
interface TestFailure {
  test_name: string;
  test_file: string;
  error_message: string;
  stack_trace: string;
  failure_type: FailureType;
  error_category: ErrorCategory;
  severity: 'critical' | 'high' | 'medium' | 'low';
  environment_info: EnvironmentInfo;
  execution_context: ExecutionContext;
  related_failures: string[];
  debugging_priority: number;
}

enum FailureType {
  ASSERTION_ERROR = 'assertion_error',
  TIMEOUT = 'timeout',
  SETUP_ERROR = 'setup_error',
  TEARDOWN_ERROR = 'teardown_error',
  MOCK_ERROR = 'mock_error',
  ASYNC_ERROR = 'async_error',
  ENVIRONMENT_ERROR = 'environment_error',
  DEPENDENCY_ERROR = 'dependency_error',
  CONFIGURATION_ERROR = 'configuration_error',
  FLAKY_TEST = 'flaky_test'
}

enum ErrorCategory {
  LOGIC_ERROR = 'logic_error',
  TIMING_ISSUE = 'timing_issue',
  RESOURCE_ISSUE = 'resource_issue',
  EXTERNAL_DEPENDENCY = 'external_dependency',
  TEST_DESIGN = 'test_design',
  INFRASTRUCTURE = 'infrastructure'
}

class TestFailureAnalyzer {
  async analyzeFailures(testResults: TestResult[]): Promise<TestFailureAnalysis> {
    console.log('🔍 Analyzing test failures...');
    
    const failures = testResults.filter(result => !result.passed);
    const analysis = {
      total_failures: failures.length,
      failure_categories: new Map<ErrorCategory, TestFailure[]>(),
      failure_types: new Map<FailureType, TestFailure[]>(),
      priority_failures: [],
      related_failure_groups: [],
      debugging_recommendations: []
    };
    
    // Categorize failures
    for (const failure of failures) {
      const failureInfo = await this.analyzeIndividualFailure(failure);
      
      // Group by category
      if (!analysis.failure_categories.has(failureInfo.error_category)) {
        analysis.failure_categories.set(failureInfo.error_category, []);
      }
      analysis.failure_categories.get(failureInfo.error_category).push(failureInfo);
      
      // Group by type
      if (!analysis.failure_types.has(failureInfo.failure_type)) {
        analysis.failure_types.set(failureInfo.failure_type, []);
      }
      analysis.failure_types.get(failureInfo.failure_type).push(failureInfo);
    }
    
    // Identify priority failures
    analysis.priority_failures = failures
      .sort((a, b) => b.debugging_priority - a.debugging_priority)
      .slice(0, 10);
    
    // Group related failures
    analysis.related_failure_groups = this.groupRelatedFailures(failures);
    
    // Generate debugging recommendations
    analysis.debugging_recommendations = this.generateDebuggingRecommendations(analysis);
    
    return analysis;
  }
  
  private async analyzeIndividualFailure(failure: TestResult): Promise<TestFailure> {
    console.log(`🔍 Analyzing failure: ${failure.test_name}`);
    
    const failureInfo = {
      test_name: failure.test_name,
      test_file: failure.test_file,
      error_message: failure.error_message,
      stack_trace: failure.stack_trace,
      failure_type: this.determineFailureType(failure),
      error_category: this.determineErrorCategory(failure),
      severity: this.determineSeverity(failure),
      environment_info: await this.collectEnvironmentInfo(),
      execution_context: await this.collectExecutionContext(failure),
      related_failures: this.findRelatedFailures(failure),
      debugging_priority: this.calculateDebuggingPriority(failure)
    };
    
    return failureInfo;
  }
  
  private determineFailureType(failure: TestResult): FailureType {
    const errorMessage = failure.error_message.toLowerCase();
    const stackTrace = failure.stack_trace.toLowerCase();
    
    if (errorMessage.includes('timeout') || errorMessage.includes('exceeded')) {
      return FailureType.TIMEOUT;
    }
    
    if (errorMessage.includes('mock') || errorMessage.includes('stub')) {
      return FailureType.MOCK_ERROR;
    }
    
    if (errorMessage.includes('async') || errorMessage.includes('promise') || 
        errorMessage.includes('await')) {
      return FailureType.ASYNC_ERROR;
    }
    
    if (errorMessage.includes('setup') || errorMessage.includes('beforeeach')) {
      return FailureType.SETUP_ERROR;
    }
    
    if (errorMessage.includes('teardown') || errorMessage.includes('aftereach')) {
      return FailureType.TEARDOWN_ERROR;
    }
    
    if (errorMessage.includes('connection') || errorMessage.includes('network') ||
        errorMessage.includes('database')) {
      return FailureType.DEPENDENCY_ERROR;
    }
    
    if (errorMessage.includes('config') || errorMessage.includes('environment')) {
      return FailureType.CONFIGURATION_ERROR;
    }
    
    if (this.isFlaky(failure)) {
      return FailureType.FLAKY_TEST;
    }
    
    return FailureType.ASSERTION_ERROR;
  }
  
  private determineErrorCategory(failure: TestResult): ErrorCategory {
    const failureType = this.determineFailureType(failure);
    
    switch (failureType) {
      case FailureType.ASSERTION_ERROR:
        return ErrorCategory.LOGIC_ERROR;
      case FailureType.TIMEOUT:
      case FailureType.ASYNC_ERROR:
        return ErrorCategory.TIMING_ISSUE;
      case FailureType.DEPENDENCY_ERROR:
        return ErrorCategory.EXTERNAL_DEPENDENCY;
      case FailureType.ENVIRONMENT_ERROR:
      case FailureType.CONFIGURATION_ERROR:
        return ErrorCategory.INFRASTRUCTURE;
      case FailureType.FLAKY_TEST:
        return ErrorCategory.TEST_DESIGN;
      default:
        return ErrorCategory.LOGIC_ERROR;
    }
  }
  
  private isFlaky(failure: TestResult): boolean {
    // Check test history for inconsistent results
    const testHistory = this.getTestHistory(failure.test_name);
    const recentResults = testHistory.slice(-10);
    
    if (recentResults.length < 5) return false;
    
    const passCount = recentResults.filter(r => r.passed).length;
    const failCount = recentResults.length - passCount;
    
    // Consider flaky if it has both passes and failures in recent history
    return passCount > 0 && failCount > 0;
  }
  
  private calculateDebuggingPriority(failure: TestResult): number {
    let priority = 0;
    
    // Higher priority for critical functionality
    if (this.isCriticalTest(failure.test_name)) {
      priority += 10;
    }
    
    // Higher priority for blocking other tests
    if (this.isBlockingTest(failure.test_name)) {
      priority += 8;
    }
    
    // Higher priority for frequently failing tests
    const failureRate = this.getFailureRate(failure.test_name);
    priority += Math.floor(failureRate * 5);
    
    // Higher priority for tests with many dependencies
    const dependencyCount = this.countTestDependencies(failure.test_name);
    priority += Math.min(dependencyCount, 5);
    
    return priority;
  }
}
```

**Step 2: Parallel Agent Deployment for Test Debugging**

**Agent Spawning Strategy:**

After identifying failing tests, I deploy specialized agents through Task tool for targeted fixes:

**Example Agent Deployment:**
"I've identified 23 failing tests across 6 different categories. I'll spawn specialized agents using Task tool invocations above:

1. **Failure Analysis Agent**: Categorizes all 23 failures into assertion errors (8), timeout issues (5), mock errors (4), async errors (3), environment issues (2), and flaky tests (1)
2. **Fix Implementation Agent**: Implements targeted fixes for each failure category using systematic root cause analysis
3. **Validation Agent**: Verifies each fix through multiple test runs to ensure stability and effectiveness
4. **Regression Prevention Agent**: Runs comprehensive regression suites to prevent new failures
5. **Prevention Enhancement Agent**: Analyzes patterns and implements prevention measures

Each agent operates in parallel while coordinating through shared analysis reports and fix validation."

**Step 3: Systematic Test Debugging Implementation**

**Root Cause Analysis Engine:**
```typescript
class RootCauseAnalyzer {
  async analyzeRootCause(failure: TestFailure): Promise<RootCauseAnalysis> {
    console.log(`🔍 Analyzing root cause for: ${failure.test_name}`);
    
    const analysis = {
      primary_cause: null,
      contributing_factors: [],
      evidence: [],
      reproduction_steps: [],
      fix_recommendations: [],
      prevention_measures: []
    };
    
    // Analyze based on failure type
    switch (failure.failure_type) {
      case FailureType.ASSERTION_ERROR:
        analysis.primary_cause = await this.analyzeAssertionError(failure);
        break;
      case FailureType.TIMEOUT:
        analysis.primary_cause = await this.analyzeTimeoutError(failure);
        break;
      case FailureType.MOCK_ERROR:
        analysis.primary_cause = await this.analyzeMockError(failure);
        break;
      case FailureType.ASYNC_ERROR:
        analysis.primary_cause = await this.analyzeAsyncError(failure);
        break;
      case FailureType.FLAKY_TEST:
        analysis.primary_cause = await this.analyzeFlakiness(failure);
        break;
      default:
        analysis.primary_cause = await this.analyzeGenericError(failure);
    }
    
    // Collect evidence
    analysis.evidence = await this.collectEvidence(failure);
    
    // Generate reproduction steps
    analysis.reproduction_steps = await this.generateReproductionSteps(failure);
    
    // Generate fix recommendations
    analysis.fix_recommendations = await this.generateFixRecommendations(analysis);
    
    // Generate prevention measures
    analysis.prevention_measures = await this.generatePreventionMeasures(analysis);
    
    return analysis;
  }
  
  private async analyzeAssertionError(failure: TestFailure): Promise<CauseAnalysis> {
    console.log('🔍 Analyzing assertion error...');
    
    const stackTrace = this.parseStackTrace(failure.stack_trace);
    const testCode = await this.getTestCode(failure.test_file);
    const productionCode = await this.getProductionCode(failure.test_file);
    
    // Analyze assertion details
    const assertion = this.extractAssertion(failure.error_message);
    const expectedValue = this.extractExpectedValue(assertion);
    const actualValue = this.extractActualValue(assertion);
    
    // Analyze why values don't match
    const valueAnalysis = await this.analyzeValueMismatch(expectedValue, actualValue);
    
    // Trace back to root cause
    const rootCause = await this.traceAssertionRootCause(
      assertion,
      valueAnalysis,
      testCode,
      productionCode
    );
    
    return {
      type: 'assertion_error',
      description: `Assertion failed: expected ${expectedValue}, got ${actualValue}`,
      root_cause: rootCause,
      confidence: this.calculateConfidence(rootCause),
      supporting_evidence: valueAnalysis.evidence
    };
  }
  
  private async analyzeTimeoutError(failure: TestFailure): Promise<CauseAnalysis> {
    console.log('🔍 Analyzing timeout error...');
    
    const timeoutValue = this.extractTimeoutValue(failure.error_message);
    const testCode = await this.getTestCode(failure.test_file);
    
    // Analyze what operations might be causing the timeout
    const slowOperations = await this.identifySlowOperations(testCode);
    
    // Check for infinite loops or blocking operations
    const blockingOperations = await this.identifyBlockingOperations(testCode);
    
    // Analyze async operations
    const asyncOperations = await this.analyzeAsyncOperations(testCode);
    
    // Determine most likely cause
    const rootCause = await this.determineTimeoutRootCause(
      slowOperations,
      blockingOperations,
      asyncOperations,
      timeoutValue
    );
    
    return {
      type: 'timeout_error',
      description: `Test timed out after ${timeoutValue}ms`,
      root_cause: rootCause,
      confidence: this.calculateConfidence(rootCause),
      supporting_evidence: {
        slow_operations: slowOperations,
        blocking_operations: blockingOperations,
        async_operations: asyncOperations
      }
    };
  }
  
  private async analyzeMockError(failure: TestFailure): Promise<CauseAnalysis> {
    console.log('🔍 Analyzing mock error...');
    
    const testCode = await this.getTestCode(failure.test_file);
    const mocks = await this.extractMocks(testCode);
    
    // Analyze mock setup
    const mockSetup = await this.analyzeMockSetup(mocks);
    
    // Check for mock expectations
    const mockExpectations = await this.analyzeMockExpectations(mocks);
    
    // Verify mock cleanup
    const mockCleanup = await this.analyzeMockCleanup(mocks);
    
    // Identify mock issues
    const mockIssues = await this.identifyMockIssues(
      mockSetup,
      mockExpectations,
      mockCleanup,
      failure.error_message
    );
    
    return {
      type: 'mock_error',
      description: `Mock error: ${failure.error_message}`,
      root_cause: mockIssues.primary_issue,
      confidence: this.calculateConfidence(mockIssues.primary_issue),
      supporting_evidence: mockIssues.evidence
    };
  }
  
  private async analyzeAsyncError(failure: TestFailure): Promise<CauseAnalysis> {
    console.log('🔍 Analyzing async error...');
    
    const testCode = await this.getTestCode(failure.test_file);
    const asyncOperations = await this.extractAsyncOperations(testCode);
    
    // Analyze promise handling
    const promiseHandling = await this.analyzePromiseHandling(asyncOperations);
    
    // Check for missing await
    const missingAwait = await this.checkForMissingAwait(asyncOperations);
    
    // Analyze error propagation
    const errorPropagation = await this.analyzeErrorPropagation(asyncOperations);
    
    // Check for race conditions
    const raceConditions = await this.checkForRaceConditions(asyncOperations);
    
    const rootCause = await this.determineAsyncRootCause(
      promiseHandling,
      missingAwait,
      errorPropagation,
      raceConditions
    );
    
    return {
      type: 'async_error',
      description: `Async error: ${failure.error_message}`,
      root_cause: rootCause,
      confidence: this.calculateConfidence(rootCause),
      supporting_evidence: {
        promise_handling: promiseHandling,
        missing_await: missingAwait,
        error_propagation: errorPropagation,
        race_conditions: raceConditions
      }
    };
  }
  
  private async analyzeFlakiness(failure: TestFailure): Promise<CauseAnalysis> {
    console.log('🔍 Analyzing test flakiness...');
    
    const testHistory = this.getTestHistory(failure.test_name);
    const testCode = await this.getTestCode(failure.test_file);
    
    // Analyze timing dependencies
    const timingDependencies = await this.analyzeTimingDependencies(testCode);
    
    // Check for external dependencies
    const externalDependencies = await this.analyzeExternalDependencies(testCode);
    
    // Analyze state dependencies
    const stateDependencies = await this.analyzeStateDependencies(testCode);
    
    // Check for race conditions
    const raceConditions = await this.analyzeRaceConditions(testCode);
    
    // Analyze environmental factors
    const environmentalFactors = await this.analyzeEnvironmentalFactors(testHistory);
    
    const rootCause = await this.determineFlakinessCause(
      timingDependencies,
      externalDependencies,
      stateDependencies,
      raceConditions,
      environmentalFactors
    );
    
    return {
      type: 'flaky_test',
      description: `Flaky test with ${this.getFailureRate(failure.test_name)}% failure rate`,
      root_cause: rootCause,
      confidence: this.calculateConfidence(rootCause),
      supporting_evidence: {
        timing_dependencies: timingDependencies,
        external_dependencies: externalDependencies,
        state_dependencies: stateDependencies,
        race_conditions: raceConditions,
        environmental_factors: environmentalFactors
      }
    };
  }
}
```

**Step 4: Automated Test Fix Implementation**

**Test Fix Implementation Engine:**
```typescript
class TestFixImplementer {
  async implementFix(rootCause: RootCauseAnalysis): Promise<FixImplementationResult> {
    console.log(`🔧 Implementing fix for: ${rootCause.primary_cause.type}`);
    
    const implementationResult = {
      fix_applied: false,
      changes_made: [],
      verification_results: null,
      rollback_plan: null,
      success: false
    };
    
    try {
      // Create backup of current state
      const backup = await this.createBackup(rootCause);
      implementationResult.rollback_plan = backup;
      
      // Apply fix based on root cause type
      const fixResult = await this.applyFix(rootCause);
      implementationResult.changes_made = fixResult.changes;
      implementationResult.fix_applied = true;
      
      // Verify fix works
      const verificationResult = await this.verifyFix(rootCause);
      implementationResult.verification_results = verificationResult;
      
      if (verificationResult.success) {
        // Run regression tests
        const regressionResult = await this.runRegressionTests(rootCause);
        
        if (regressionResult.success) {
          implementationResult.success = true;
          console.log(`✅ Fix successfully implemented for ${rootCause.primary_cause.type}`);
        } else {
          // Rollback if regression tests fail
          await this.rollbackFix(backup);
          implementationResult.success = false;
          console.log(`❌ Fix caused regressions, rolled back`);
        }
      } else {
        // Rollback if verification fails
        await this.rollbackFix(backup);
        implementationResult.success = false;
        console.log(`❌ Fix verification failed, rolled back`);
      }
      
    } catch (error) {
      // Rollback on any error
      if (implementationResult.rollback_plan) {
        await this.rollbackFix(implementationResult.rollback_plan);
      }
      
      implementationResult.success = false;
      implementationResult.error = error.message;
      console.log(`❌ Fix implementation failed: ${error.message}`);
    }
    
    return implementationResult;
  }
  
  private async applyFix(rootCause: RootCauseAnalysis): Promise<FixResult> {
    const changes = [];
    
    switch (rootCause.primary_cause.type) {
      case 'assertion_error':
        changes.push(...await this.fixAssertionError(rootCause));
        break;
      case 'timeout_error':
        changes.push(...await this.fixTimeoutError(rootCause));
        break;
      case 'mock_error':
        changes.push(...await this.fixMockError(rootCause));
        break;
      case 'async_error':
        changes.push(...await this.fixAsyncError(rootCause));
        break;
      case 'flaky_test':
        changes.push(...await this.fixFlakiness(rootCause));
        break;
      default:
        changes.push(...await this.fixGenericError(rootCause));
    }
    
    return { changes };
  }
  
  private async fixAssertionError(rootCause: RootCauseAnalysis): Promise<CodeChange[]> {
    const changes = [];
    
    // Fix based on specific assertion error type
    if (rootCause.primary_cause.description.includes('expected')) {
      const expectedValue = this.extractExpectedValue(rootCause.primary_cause.description);
      const actualValue = this.extractActualValue(rootCause.primary_cause.description);
      
      // Determine if expectation or implementation is wrong
      const correctValue = await this.determineCorrectValue(expectedValue, actualValue, rootCause);
      
      if (correctValue === expectedValue) {
        // Fix the implementation
        changes.push(await this.fixImplementation(rootCause, correctValue));
      } else {
        // Fix the test expectation
        changes.push(await this.fixTestExpectation(rootCause, correctValue));
      }
    }
    
    return changes;
  }
  
  private async fixTimeoutError(rootCause: RootCauseAnalysis): Promise<CodeChange[]> {
    const changes = [];
    
    const evidence = rootCause.supporting_evidence;
    
    // Fix slow operations
    if (evidence.slow_operations && evidence.slow_operations.length > 0) {
      for (const operation of evidence.slow_operations) {
        changes.push(await this.optimizeSlowOperation(operation));
      }
    }
    
    // Fix blocking operations
    if (evidence.blocking_operations && evidence.blocking_operations.length > 0) {
      for (const operation of evidence.blocking_operations) {
        changes.push(await this.fixBlockingOperation(operation));
      }
    }
    
    // Fix async operations
    if (evidence.async_operations && evidence.async_operations.length > 0) {
      for (const operation of evidence.async_operations) {
        changes.push(await this.fixAsyncOperation(operation));
      }
    }
    
    // Increase timeout if necessary
    if (this.shouldIncreaseTimeout(rootCause)) {
      changes.push(await this.increaseTimeout(rootCause));
    }
    
    return changes;
  }
  
  private async fixMockError(rootCause: RootCauseAnalysis): Promise<CodeChange[]> {
    const changes = [];
    
    const evidence = rootCause.supporting_evidence;
    
    // Fix mock setup issues
    if (evidence.mock_setup_issues) {
      for (const issue of evidence.mock_setup_issues) {
        changes.push(await this.fixMockSetup(issue));
      }
    }
    
    // Fix mock expectations
    if (evidence.mock_expectation_issues) {
      for (const issue of evidence.mock_expectation_issues) {
        changes.push(await this.fixMockExpectation(issue));
      }
    }
    
    // Fix mock cleanup
    if (evidence.mock_cleanup_issues) {
      for (const issue of evidence.mock_cleanup_issues) {
        changes.push(await this.fixMockCleanup(issue));
      }
    }
    
    return changes;
  }
  
  private async fixAsyncError(rootCause: RootCauseAnalysis): Promise<CodeChange[]> {
    const changes = [];
    
    const evidence = rootCause.supporting_evidence;
    
    // Fix missing await
    if (evidence.missing_await) {
      for (const missingAwait of evidence.missing_await) {
        changes.push(await this.addMissingAwait(missingAwait));
      }
    }
    
    // Fix promise handling
    if (evidence.promise_handling_issues) {
      for (const issue of evidence.promise_handling_issues) {
        changes.push(await this.fixPromiseHandling(issue));
      }
    }
    
    // Fix error propagation
    if (evidence.error_propagation_issues) {
      for (const issue of evidence.error_propagation_issues) {
        changes.push(await this.fixErrorPropagation(issue));
      }
    }
    
    // Fix race conditions
    if (evidence.race_conditions) {
      for (const raceCondition of evidence.race_conditions) {
        changes.push(await this.fixRaceCondition(raceCondition));
      }
    }
    
    return changes;
  }
  
  private async fixFlakiness(rootCause: RootCauseAnalysis): Promise<CodeChange[]> {
    const changes = [];
    
    const evidence = rootCause.supporting_evidence;
    
    // Fix timing dependencies
    if (evidence.timing_dependencies) {
      for (const dependency of evidence.timing_dependencies) {
        changes.push(await this.fixTimingDependency(dependency));
      }
    }
    
    // Fix external dependencies
    if (evidence.external_dependencies) {
      for (const dependency of evidence.external_dependencies) {
        changes.push(await this.fixExternalDependency(dependency));
      }
    }
    
    // Fix state dependencies
    if (evidence.state_dependencies) {
      for (const dependency of evidence.state_dependencies) {
        changes.push(await this.fixStateDependency(dependency));
      }
    }
    
    // Fix race conditions
    if (evidence.race_conditions) {
      for (const raceCondition of evidence.race_conditions) {
        changes.push(await this.fixRaceCondition(raceCondition));
      }
    }
    
    // Make test more deterministic
    changes.push(await this.makeDeterministic(rootCause));
    
    return changes;
  }
  
  private async verifyFix(rootCause: RootCauseAnalysis): Promise<VerificationResult> {
    console.log('🔍 Verifying fix...');
    
    // Run the specific test multiple times
    const testResults = await this.runTestMultipleTimes(rootCause.test_name, 5);
    
    // Check if all runs pass
    const allPassed = testResults.every(result => result.passed);
    
    // Check execution time improvements
    const executionTimes = testResults.map(result => result.execution_time);
    const averageTime = executionTimes.reduce((a, b) => a + b, 0) / executionTimes.length;
    
    // Check for stability (consistent results)
    const isStable = this.checkStability(testResults);
    
    return {
      success: allPassed && isStable,
      test_passes: allPassed,
      stability_improved: isStable,
      average_execution_time: averageTime,
      test_results: testResults
    };
  }
  
  private async runRegressionTests(rootCause: RootCauseAnalysis): Promise<RegressionTestResult> {
    console.log('🔍 Running regression tests...');
    
    // Find related tests
    const relatedTests = await this.findRelatedTests(rootCause.test_name);
    
    // Run related tests
    const regressionResults = await this.runTests(relatedTests);
    
    // Check for new failures
    const newFailures = regressionResults.filter(result => !result.passed);
    
    return {
      success: newFailures.length === 0,
      tests_run: relatedTests.length,
      new_failures: newFailures,
      all_results: regressionResults
    };
  }
}
```

**Step 5: Test Reliability Improvement**

**Test Reliability Enhancement:**
```typescript
class TestReliabilityEnhancer {
  async enhanceTestReliability(fixedTests: string[]): Promise<ReliabilityEnhancement> {
    console.log('🛡️ Enhancing test reliability...');
    
    const enhancements = {
      deterministic_improvements: [],
      isolation_improvements: [],
      timing_improvements: [],
      error_handling_improvements: [],
      monitoring_improvements: []
    };
    
    for (const testName of fixedTests) {
      const testCode = await this.getTestCode(testName);
      
      // Make test more deterministic
      const deterministicImprovements = await this.improveDeterminism(testCode);
      enhancements.deterministic_improvements.push(...deterministicImprovements);
      
      // Improve test isolation
      const isolationImprovements = await this.improveIsolation(testCode);
      enhancements.isolation_improvements.push(...isolationImprovements);
      
      // Improve timing reliability
      const timingImprovements = await this.improveTiming(testCode);
      enhancements.timing_improvements.push(...timingImprovements);
      
      // Improve error handling
      const errorHandlingImprovements = await this.improveErrorHandling(testCode);
      enhancements.error_handling_improvements.push(...errorHandlingImprovements);
      
      // Add monitoring
      const monitoringImprovements = await this.addMonitoring(testCode);
      enhancements.monitoring_improvements.push(...monitoringImprovements);
    }
    
    return enhancements;
  }
  
  private async improveDeterminism(testCode: string): Promise<DeterministicImprovement[]> {
    const improvements = [];
    
    // Remove random elements
    const randomUsages = this.findRandomUsages(testCode);
    for (const usage of randomUsages) {
      improvements.push({
        type: 'remove_randomness',
        description: 'Replace random values with deterministic test data',
        change: await this.replaceRandomWithDeterministic(usage)
      });
    }
    
    // Add data seeding
    const seedingNeeded = this.needsDataSeeding(testCode);
    if (seedingNeeded) {
      improvements.push({
        type: 'add_data_seeding',
        description: 'Add deterministic data seeding',
        change: await this.addDataSeeding(testCode)
      });
    }
    
    // Fix date/time dependencies
    const timeUsages = this.findTimeUsages(testCode);
    for (const usage of timeUsages) {
      improvements.push({
        type: 'fix_time_dependency',
        description: 'Use deterministic time values',
        change: await this.fixTimeDependency(usage)
      });
    }
    
    return improvements;
  }
  
  private async improveIsolation(testCode: string): Promise<IsolationImprovement[]> {
    const improvements = [];
    
    // Add proper setup/teardown
    const setupTeardownNeeded = this.needsSetupTeardown(testCode);
    if (setupTeardownNeeded) {
      improvements.push({
        type: 'add_setup_teardown',
        description: 'Add proper test setup and teardown',
        change: await this.addSetupTeardown(testCode)
      });
    }
    
    // Fix shared state issues
    const sharedStateIssues = this.findSharedStateIssues(testCode);
    for (const issue of sharedStateIssues) {
      improvements.push({
        type: 'fix_shared_state',
        description: 'Eliminate shared state dependencies',
        change: await this.fixSharedState(issue)
      });
    }
    
    // Add test data isolation
    const dataIsolationNeeded = this.needsDataIsolation(testCode);
    if (dataIsolationNeeded) {
      improvements.push({
        type: 'add_data_isolation',
        description: 'Isolate test data between tests',
        change: await this.addDataIsolation(testCode)
      });
    }
    
    return improvements;
  }
  
  private async improveTiming(testCode: string): Promise<TimingImprovement[]> {
    const improvements = [];
    
    // Add proper waits
    const waitingNeeded = this.needsProperWaits(testCode);
    if (waitingNeeded) {
      improvements.push({
        type: 'add_proper_waits',
        description: 'Add deterministic waits instead of sleep',
        change: await this.addProperWaits(testCode)
      });
    }
    
    // Fix race conditions
    const raceConditions = this.findRaceConditions(testCode);
    for (const condition of raceConditions) {
      improvements.push({
        type: 'fix_race_condition',
        description: 'Fix race condition in test',
        change: await this.fixRaceCondition(condition)
      });
    }
    
    // Add timeouts
    const timeoutNeeded = this.needsTimeouts(testCode);
    if (timeoutNeeded) {
      improvements.push({
        type: 'add_timeouts',
        description: 'Add appropriate timeouts',
        change: await this.addTimeouts(testCode)
      });
    }
    
    return improvements;
  }
}
```

**Step 6: Prevention Measures and Best Practices**

**Test Failure Prevention System:**
```typescript
class TestFailurePreventionSystem {
  async implementPreventionMeasures(fixedFailures: TestFailure[]): Promise<PreventionMeasures> {
    console.log('🛡️ Implementing failure prevention measures...');
    
    const measures = {
      linting_rules: [],
      test_templates: [],
      documentation_updates: [],
      ci_cd_improvements: [],
      monitoring_additions: []
    };
    
    // Analyze patterns in fixed failures
    const patterns = this.analyzeFailurePatterns(fixedFailures);
    
    // Create linting rules to prevent similar issues
    measures.linting_rules = await this.createLintingRules(patterns);
    
    // Create test templates for common scenarios
    measures.test_templates = await this.createTestTemplates(patterns);
    
    // Update documentation with lessons learned
    measures.documentation_updates = await this.updateDocumentation(patterns);
    
    // Improve CI/CD pipeline
    measures.ci_cd_improvements = await this.improveCICD(patterns);
    
    // Add monitoring for potential issues
    measures.monitoring_additions = await this.addMonitoring(patterns);
    
    return measures;
  }
  
  private async createLintingRules(patterns: FailurePattern[]): Promise<LintingRule[]> {
    const rules = [];
    
    for (const pattern of patterns) {
      switch (pattern.type) {
        case 'missing_await':
          rules.push({
            name: 'require-await-async-test',
            description: 'Require await for async operations in tests',
            rule: 'Always use await for async operations in tests'
          });
          break;
          
        case 'improper_mocking':
          rules.push({
            name: 'proper-mock-cleanup',
            description: 'Ensure mocks are properly cleaned up',
            rule: 'Always reset mocks in teardown'
          });
          break;
          
        case 'flaky_timing':
          rules.push({
            name: 'no-sleep-in-tests',
            description: 'Avoid sleep/setTimeout in tests',
            rule: 'Use deterministic waiting instead of sleep'
          });
          break;
      }
    }
    
    return rules;
  }
  
  private async createTestTemplates(patterns: FailurePattern[]): Promise<TestTemplate[]> {
    const templates = [];
    
    // Create templates for common test scenarios
    templates.push({
      name: 'async-test-template',
      description: 'Template for async test with proper error handling',
      template: `
describe('{{MODULE_NAME}}', () => {
  beforeEach(async () => {
    // Setup test data
    await setupTestData();
  });
  
  afterEach(async () => {
    // Cleanup test data
    await cleanupTestData();
  });
  
  it('should {{TEST_DESCRIPTION}}', async () => {
    // Arrange
    const testData = await createTestData();
    
    // Act
    const result = await {{FUNCTION_NAME}}(testData);
    
    // Assert
    expect(result).toBeDefined();
    expect(result).toEqual(expectedResult);
  });
});`
    });
    
    templates.push({
      name: 'mock-test-template',
      description: 'Template for tests with proper mocking',
      template: `
describe('{{MODULE_NAME}}', () => {
  let mockDependency: jest.Mocked<DependencyType>;
  
  beforeEach(() => {
    mockDependency = {
      method: jest.fn()
    };
  });
  
  afterEach(() => {
    jest.clearAllMocks();
  });
  
  it('should {{TEST_DESCRIPTION}}', async () => {
    // Arrange
    mockDependency.method.mockResolvedValue(expectedValue);
    
    // Act
    const result = await {{FUNCTION_NAME}}(mockDependency);
    
    // Assert
    expect(result).toEqual(expectedResult);
    expect(mockDependency.method).toHaveBeenCalledWith(expectedInput);
  });
});`
    });
    
    return templates;
  }
}
```

**Test Debugging Quality Checklist:**
- [ ] All failing tests are analyzed and categorized
- [ ] Root causes are identified through systematic debugging
- [ ] Fixes address root causes, not just symptoms
- [ ] Fixes are verified to work correctly
- [ ] Regression tests confirm no new issues introduced
- [ ] Test reliability is improved through enhancements
- [ ] Prevention measures are implemented
- [ ] Knowledge is documented for future reference

**Agent Coordination for Test Debugging:**

For comprehensive test debugging, I coordinate multiple specialized agents through Task tool:

**Agent Coordination Flow:**
1. **Failure Analysis Agent** → Provides categorized failure analysis to all other agents
2. **Fix Implementation Agent** → Receives analysis, implements fixes, reports to validation
3. **Validation Agent** → Receives fixes, validates effectiveness, reports to regression prevention
4. **Regression Prevention Agent** → Receives validation results, runs regression tests, reports to prevention
5. **Prevention Enhancement Agent** → Receives all reports, implements prevention measures, generates final report

**Parallel Processing Architecture:**
- All agents operate simultaneously using Task tool parallelism
- Shared analysis files enable coordination without blocking
- Each agent focuses on their specialized domain
- Real-time progress reporting ensures comprehensive coverage
- Automatic rollback capabilities if any agent detects issues

This Task tool-based approach provides true parallelism and systematic test debugging coverage.

**Anti-Patterns to Avoid:**
- ❌ Commenting out failing tests (avoiding the problem)
- ❌ Quick fixes without understanding root causes (symptom fixing)
- ❌ Ignoring test environment issues (unreliable infrastructure)
- ❌ Skipping regression testing (introducing new problems)
- ❌ Accepting flaky tests as normal (poor test quality)
- ❌ Not implementing prevention measures (repeated failures)

**Final Verification:**
Before completing test debugging:
- Are all failing tests fixed and passing?
- Are root causes identified and addressed?
- Are fixes verified to work correctly?
- Are regression tests passing?
- Are prevention measures implemented?
- Is debugging knowledge documented?

**Final Commitment:**
- **I will**: Perform comprehensive root cause analysis for all failing tests
- **I will**: Use multiple agents for parallel debugging and fixing
- **I will**: Address root causes, not just symptoms
- **I will**: Verify fixes work and don't introduce regressions
- **I will NOT**: Comment out failing tests or apply quick fixes
- **I will NOT**: Ignore test environment or infrastructure issues
- **I will NOT**: Skip prevention measures or documentation

**REMEMBER:**
This is TEST DEBUGGING AND FIXING mode - comprehensive root cause analysis, systematic fixing, and prevention implementation. The goal is to create reliable, maintainable tests that provide accurate feedback about code quality.

Executing comprehensive test debugging and fixing protocol for reliable test suite...