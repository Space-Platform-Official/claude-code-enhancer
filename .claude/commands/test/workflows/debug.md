---
allowed-tools: all
description: Test debugging workflow with comprehensive failure analysis and systematic troubleshooting
intensity: ⚡⚡⚡⚡
pattern: 🔍🔍🔍🔍
---

# 🔍🔍🔍🔍 CRITICAL TEST DEBUGGING WORKFLOW: COMPREHENSIVE FAILURE ANALYSIS! 🔍🔍🔍🔍

**THIS IS NOT A SIMPLE TEST DEBUG - THIS IS A COMPREHENSIVE TEST DEBUGGING WORKFLOW SYSTEM!**

When you run `/test workflows/debug`, you are REQUIRED to:

1. **ANALYZE** test failures with systematic debugging methodologies
2. **DIAGNOSE** root causes using comprehensive investigation techniques
3. **RESOLVE** issues through targeted fixes and improvements
4. **USE MULTIPLE AGENTS** for parallel debugging execution:
   - Spawn one agent per debugging phase or investigation type
   - Spawn agents for different failure categories and root cause analysis
   - Say: "I'll spawn multiple agents to debug test failures across all investigation areas in parallel"
5. **PREVENT** similar failures through improved test design and practices
6. **DOCUMENT** debugging insights for future reference

## 🎯 USE MULTIPLE AGENTS

**MANDATORY AGENT SPAWNING FOR TEST DEBUGGING:**
```
"I'll spawn multiple agents to handle test debugging comprehensively:
- Failure Classification Agent: Categorize and prioritize test failures
- Stack Trace Agent: Analyze error stack traces and execution paths
- Environment Agent: Investigate test environment and configuration issues
- Dependency Agent: Debug external dependencies and integration issues
- Timing Agent: Investigate timing-related and race condition issues
- Data Agent: Analyze test data and fixture problems
- Assertion Agent: Debug assertion failures and expectation mismatches
- Integration Agent: Investigate cross-component and integration issues"
```

## 🚨 FORBIDDEN BEHAVIORS

**NEVER:**
- ❌ "Just restart the test and hope it passes" → NO! Investigate root cause!
- ❌ Ignore intermittent failures → NO! Flaky tests indicate real issues!
- ❌ Skip environmental investigation → NO! Environment affects test reliability!
- ❌ "It works on my machine" → NO! Ensure consistent test environments!
- ❌ Apply random fixes without understanding → NO! Systematic investigation required!
- ❌ Debug only the symptom → NO! Find and fix the root cause!

**MANDATORY WORKFLOW:**
```
1. Failure collection → Gather all test failure information
2. IMMEDIATELY spawn agents for parallel debugging investigation
3. Systematic analysis → Categorize failures and investigate root causes
4. Root cause identification → Deep dive into underlying issues
5. Fix implementation → Apply targeted solutions
6. VERIFY fixes resolve issues and prevent recurrence
```

**YOU ARE NOT DONE UNTIL:**
- ✅ ALL test failures are thoroughly investigated
- ✅ Root causes are identified and documented
- ✅ Fixes are implemented and verified
- ✅ Test reliability is improved
- ✅ Prevention measures are implemented
- ✅ Debugging insights are documented for future reference

---

🛑 **MANDATORY TEST DEBUGGING CHECK** 🛑
1. Re-read ~/.claude/CLAUDE.md RIGHT NOW
2. Check current test failures and error patterns
3. Verify you understand the debugging workflow requirements

Execute comprehensive test debugging workflow for: $ARGUMENTS

**FORBIDDEN SHORTCUT PATTERNS:**
- "This failure is too complex to debug" → NO, break it down systematically!
- "Random changes might fix it" → NO, use systematic investigation!
- "Environment issues are not my concern" → NO, reliable environments are essential!
- "Intermittent failures are normal" → NO, make tests deterministic!
- "Quick fixes are faster than investigation" → NO, fix root causes properly!

Let me ultrathink about the comprehensive test debugging workflow architecture and investigation strategy.

🚨 **REMEMBER: Systematic debugging improves test reliability and prevents future failures!** 🚨

**Comprehensive Test Debugging Workflow Protocol:**

**Step 0: Test Debugging Environment Setup**
- Set up debugging tools and monitoring infrastructure
- Configure detailed logging and error reporting
- Prepare test failure collection and analysis system
- Set up debugging environment with proper isolation
- Configure systematic investigation workflows

**Step 1: Failure Collection and Classification**

**Failure Collection System:**
```bash
# Collect and classify test failures
collect_test_failures() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local failure_log="/tmp/test-failures-$$.log"
    
    echo "=== COLLECTING TEST FAILURES ==="
    echo "Project Directory: $project_dir"
    echo "Framework: $framework"
    echo ""
    
    # Source shared utilities
    source "$(dirname "$0")/../../../shared/utils.md"
    source "$(dirname "$0")/../../../shared/runners.md"
    
    # Detect framework if auto
    if [ "$framework" = "auto" ]; then
        framework=$(detect_test_framework "$project_dir")
    fi
    
    # Run tests and collect failures
    echo "Running tests to collect failure information..."
    execute_test_command "$framework" "$project_dir" "--verbose" > "$failure_log" 2>&1
    
    # Parse and classify failures
    classify_test_failures "$failure_log" "$framework"
    
    echo "Test failures collected and classified"
    echo "Failure log: $failure_log"
}

# Classify failures by type and severity
classify_test_failures() {
    local failure_log=$1
    local framework=$2
    
    echo "=== CLASSIFYING TEST FAILURES ==="
    echo ""
    
    # Initialize failure categories
    local assertion_failures=0
    local timeout_failures=0
    local setup_failures=0
    local teardown_failures=0
    local dependency_failures=0
    local environment_failures=0
    local race_condition_failures=0
    
    # Analyze failure patterns
    case "$framework" in
        "jest")
            assertion_failures=$(grep -c "expect.*toBe\|expect.*toEqual\|AssertionError" "$failure_log" || echo 0)
            timeout_failures=$(grep -c "Timeout\|timeout" "$failure_log" || echo 0)
            setup_failures=$(grep -c "beforeEach\|beforeAll" "$failure_log" || echo 0)
            teardown_failures=$(grep -c "afterEach\|afterAll" "$failure_log" || echo 0)
            ;;
        "pytest")
            assertion_failures=$(grep -c "AssertionError\|assert" "$failure_log" || echo 0)
            timeout_failures=$(grep -c "TimeoutError\|timeout" "$failure_log" || echo 0)
            setup_failures=$(grep -c "setup_method\|setup_class" "$failure_log" || echo 0)
            teardown_failures=$(grep -c "teardown_method\|teardown_class" "$failure_log" || echo 0)
            ;;
        "go-test")
            assertion_failures=$(grep -c "got.*want\|expected" "$failure_log" || echo 0)
            timeout_failures=$(grep -c "timeout\|deadline" "$failure_log" || echo 0)
            setup_failures=$(grep -c "TestMain\|setup" "$failure_log" || echo 0)
            ;;
        "rspec")
            assertion_failures=$(grep -c "expected.*got\|to eq\|to be" "$failure_log" || echo 0)
            timeout_failures=$(grep -c "timeout\|Timeout" "$failure_log" || echo 0)
            setup_failures=$(grep -c "before.*each\|before.*all" "$failure_log" || echo 0)
            teardown_failures=$(grep -c "after.*each\|after.*all" "$failure_log" || echo 0)
            ;;
    esac
    
    # Check for environment and dependency issues
    dependency_failures=$(grep -c "ModuleNotFoundError\|ImportError\|Cannot find module\|package not found" "$failure_log" || echo 0)
    environment_failures=$(grep -c "ENOENT\|Permission denied\|Environment variable" "$failure_log" || echo 0)
    
    # Report classification results
    echo "Failure Classification Results:"
    echo "- Assertion Failures: $assertion_failures"
    echo "- Timeout Failures: $timeout_failures"
    echo "- Setup Failures: $setup_failures"
    echo "- Teardown Failures: $teardown_failures"
    echo "- Dependency Failures: $dependency_failures"
    echo "- Environment Failures: $environment_failures"
    echo ""
    
    # Store classification data
    store_failure_classification "$assertion_failures" "$timeout_failures" "$setup_failures" "$teardown_failures" "$dependency_failures" "$environment_failures"
}

# Store failure classification data
store_failure_classification() {
    local assertion_failures=$1
    local timeout_failures=$2
    local setup_failures=$3
    local teardown_failures=$4
    local dependency_failures=$5
    local environment_failures=$6
    
    local classification_file="/tmp/failure-classification-$$.json"
    
    cat > "$classification_file" <<EOF
{
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "failure_types": {
        "assertion_failures": $assertion_failures,
        "timeout_failures": $timeout_failures,
        "setup_failures": $setup_failures,
        "teardown_failures": $teardown_failures,
        "dependency_failures": $dependency_failures,
        "environment_failures": $environment_failures
    },
    "total_failures": $((assertion_failures + timeout_failures + setup_failures + teardown_failures + dependency_failures + environment_failures)),
    "investigation_priority": []
}
EOF
    
    # Set investigation priorities
    set_investigation_priorities "$classification_file"
    
    export FAILURE_CLASSIFICATION_FILE="$classification_file"
    echo "Failure classification stored: $classification_file"
}

# Set investigation priorities based on failure types
set_investigation_priorities() {
    local classification_file=$1
    
    if command -v jq >/dev/null 2>&1; then
        local temp_file=$(mktemp)
        
        # Priority 1: Environment and dependency failures (blocking)
        local env_deps=$(jq '.failure_types.environment_failures + .failure_types.dependency_failures' "$classification_file")
        if [ "$env_deps" -gt 0 ]; then
            jq '.investigation_priority += ["environment_dependencies"]' "$classification_file" > "$temp_file"
            mv "$temp_file" "$classification_file"
        fi
        
        # Priority 2: Setup and teardown failures (infrastructure)
        local setup_teardown=$(jq '.failure_types.setup_failures + .failure_types.teardown_failures' "$classification_file")
        if [ "$setup_teardown" -gt 0 ]; then
            jq '.investigation_priority += ["setup_teardown"]' "$classification_file" > "$temp_file"
            mv "$temp_file" "$classification_file"
        fi
        
        # Priority 3: Timeout failures (performance/concurrency)
        local timeouts=$(jq '.failure_types.timeout_failures' "$classification_file")
        if [ "$timeouts" -gt 0 ]; then
            jq '.investigation_priority += ["timeouts"]' "$classification_file" > "$temp_file"
            mv "$temp_file" "$classification_file"
        fi
        
        # Priority 4: Assertion failures (logic)
        local assertions=$(jq '.failure_types.assertion_failures' "$classification_file")
        if [ "$assertions" -gt 0 ]; then
            jq '.investigation_priority += ["assertions"]' "$classification_file" > "$temp_file"
            mv "$temp_file" "$classification_file"
        fi
    fi
}
```

**Step 2: Systematic Failure Investigation**

**Investigation Framework:**
```bash
# Execute systematic failure investigation
investigate_test_failures() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local classification_file=${FAILURE_CLASSIFICATION_FILE:-}
    
    echo "=== SYSTEMATIC FAILURE INVESTIGATION ==="
    echo ""
    
    if [ -z "$classification_file" ] || [ ! -f "$classification_file" ]; then
        echo "ERROR: Failure classification not found. Run failure collection first."
        return 1
    fi
    
    # Get investigation priorities
    local priorities=($(jq -r '.investigation_priority[]' "$classification_file" 2>/dev/null))
    
    if [ ${#priorities[@]} -eq 0 ]; then
        echo "No failures to investigate"
        return 0
    fi
    
    # Investigate each priority area
    for priority in "${priorities[@]}"; do
        echo "Investigating: $priority"
        case "$priority" in
            "environment_dependencies")
                investigate_environment_dependencies "$project_dir" "$framework"
                ;;
            "setup_teardown")
                investigate_setup_teardown "$project_dir" "$framework"
                ;;
            "timeouts")
                investigate_timeout_failures "$project_dir" "$framework"
                ;;
            "assertions")
                investigate_assertion_failures "$project_dir" "$framework"
                ;;
        esac
        echo ""
    done
    
    # Generate investigation summary
    generate_investigation_summary "$classification_file"
}

# Investigate environment and dependency failures
investigate_environment_dependencies() {
    local project_dir=$1
    local framework=$2
    
    echo "=== INVESTIGATING ENVIRONMENT AND DEPENDENCY FAILURES ==="
    echo ""
    
    # Check environment setup
    echo "Checking environment setup..."
    check_test_environment "$project_dir" "$framework"
    
    # Check dependencies
    echo "Checking dependencies..."
    check_test_dependencies "$project_dir" "$framework"
    
    # Check file permissions
    echo "Checking file permissions..."
    check_file_permissions "$project_dir"
    
    # Check environment variables
    echo "Checking environment variables..."
    check_environment_variables "$framework"
}

# Check test environment setup
check_test_environment() {
    local project_dir=$1
    local framework=$2
    
    echo "Environment Check Results:"
    
    # Check working directory
    if [ ! -d "$project_dir" ]; then
        echo "❌ Project directory not found: $project_dir"
    else
        echo "✅ Project directory exists: $project_dir"
    fi
    
    # Check framework installation
    if validate_framework_installation "$framework" "$project_dir"; then
        echo "✅ Framework installation valid: $framework"
    else
        echo "❌ Framework installation issues: $framework"
    fi
    
    # Check test configuration
    check_test_configuration "$project_dir" "$framework"
}

# Check test dependencies
check_test_dependencies() {
    local project_dir=$1
    local framework=$2
    
    echo "Dependency Check Results:"
    
    case "$framework" in
        "jest"|"mocha")
            # Check Node.js dependencies
            if [ -f "$project_dir/package.json" ]; then
                echo "✅ package.json found"
                if [ -d "$project_dir/node_modules" ]; then
                    echo "✅ node_modules directory exists"
                else
                    echo "❌ node_modules directory missing - run npm install"
                fi
            else
                echo "❌ package.json not found"
            fi
            ;;
        "pytest")
            # Check Python dependencies
            if [ -f "$project_dir/requirements.txt" ]; then
                echo "✅ requirements.txt found"
                python -m pip check 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "✅ Python dependencies satisfied"
                else
                    echo "❌ Python dependency issues found"
                fi
            fi
            ;;
        "go-test")
            # Check Go dependencies
            if [ -f "$project_dir/go.mod" ]; then
                echo "✅ go.mod found"
                cd "$project_dir" && go mod verify 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "✅ Go modules verified"
                else
                    echo "❌ Go module verification failed"
                fi
            fi
            ;;
    esac
}

# Check file permissions
check_file_permissions() {
    local project_dir=$1
    
    echo "File Permission Check Results:"
    
    # Check read permissions on project directory
    if [ -r "$project_dir" ]; then
        echo "✅ Project directory is readable"
    else
        echo "❌ Project directory is not readable"
    fi
    
    # Check write permissions for test output
    local temp_test_file="$project_dir/.test-permission-$$"
    if touch "$temp_test_file" 2>/dev/null; then
        echo "✅ Project directory is writable"
        rm "$temp_test_file"
    else
        echo "❌ Project directory is not writable"
    fi
}

# Check environment variables
check_environment_variables() {
    local framework=$1
    
    echo "Environment Variable Check Results:"
    
    case "$framework" in
        "jest")
            if [ -n "$NODE_ENV" ]; then
                echo "✅ NODE_ENV is set: $NODE_ENV"
            else
                echo "⚠️  NODE_ENV not set (may default to 'test')"
            fi
            ;;
        "pytest")
            if [ -n "$PYTHONPATH" ]; then
                echo "✅ PYTHONPATH is set: $PYTHONPATH"
            else
                echo "⚠️  PYTHONPATH not set (may cause import issues)"
            fi
            ;;
        "go-test")
            if [ -n "$GOPATH" ]; then
                echo "✅ GOPATH is set: $GOPATH"
            else
                echo "ℹ️  GOPATH not set (using Go modules)"
            fi
            ;;
    esac
}

# Investigate setup and teardown failures
investigate_setup_teardown() {
    local project_dir=$1
    local framework=$2
    
    echo "=== INVESTIGATING SETUP AND TEARDOWN FAILURES ==="
    echo ""
    
    # Analyze setup/teardown patterns
    analyze_setup_teardown_patterns "$project_dir" "$framework"
    
    # Check for resource leaks
    check_resource_leaks "$project_dir" "$framework"
    
    # Check for state pollution
    check_state_pollution "$project_dir" "$framework"
}

# Analyze setup and teardown patterns
analyze_setup_teardown_patterns() {
    local project_dir=$1
    local framework=$2
    
    echo "Analyzing setup/teardown patterns..."
    
    # Find test files with setup/teardown
    local test_files=$(find_test_files "$project_dir" "$framework")
    
    while IFS= read -r test_file; do
        if [ -f "$test_file" ]; then
            case "$framework" in
                "jest")
                    if grep -q "beforeEach\|beforeAll\|afterEach\|afterAll" "$test_file"; then
                        echo "Setup/teardown found in: $test_file"
                        analyze_jest_setup_teardown "$test_file"
                    fi
                    ;;
                "pytest")
                    if grep -q "setup_method\|setup_class\|teardown_method\|teardown_class" "$test_file"; then
                        echo "Setup/teardown found in: $test_file"
                        analyze_pytest_setup_teardown "$test_file"
                    fi
                    ;;
                "rspec")
                    if grep -q "before.*each\|before.*all\|after.*each\|after.*all" "$test_file"; then
                        echo "Setup/teardown found in: $test_file"
                        analyze_rspec_setup_teardown "$test_file"
                    fi
                    ;;
            esac
        fi
    done <<< "$test_files"
}

# Check for resource leaks
check_resource_leaks() {
    local project_dir=$1
    local framework=$2
    
    echo "Checking for resource leaks..."
    
    # Check for file handle leaks
    echo "- Checking file handle usage"
    
    # Check for memory leaks
    echo "- Checking memory usage patterns"
    
    # Check for network connection leaks
    echo "- Checking network connection cleanup"
    
    # Check for timer leaks
    echo "- Checking timer/interval cleanup"
}

# Check for state pollution between tests
check_state_pollution() {
    local project_dir=$1
    local framework=$2
    
    echo "Checking for state pollution..."
    
    # Check for global variable pollution
    echo "- Checking global variable usage"
    
    # Check for shared object mutation
    echo "- Checking shared object state"
    
    # Check for singleton pollution
    echo "- Checking singleton state management"
}

# Investigate timeout failures
investigate_timeout_failures() {
    local project_dir=$1
    local framework=$2
    
    echo "=== INVESTIGATING TIMEOUT FAILURES ==="
    echo ""
    
    # Analyze timeout patterns
    analyze_timeout_patterns "$project_dir" "$framework"
    
    # Check for race conditions
    check_race_conditions "$project_dir" "$framework"
    
    # Check for performance issues
    check_performance_issues "$project_dir" "$framework"
}

# Analyze timeout patterns
analyze_timeout_patterns() {
    local project_dir=$1
    local framework=$2
    
    echo "Analyzing timeout patterns..."
    
    # Check test timeout configuration
    check_timeout_configuration "$project_dir" "$framework"
    
    # Identify slow tests
    identify_slow_tests "$project_dir" "$framework"
    
    # Check for infinite loops
    check_infinite_loops "$project_dir" "$framework"
}

# Check race conditions
check_race_conditions() {
    local project_dir=$1
    local framework=$2
    
    echo "Checking for race conditions..."
    
    # Check for concurrent access to shared resources
    echo "- Checking concurrent resource access"
    
    # Check for timing-dependent assertions
    echo "- Checking timing-dependent test logic"
    
    # Check for async/await issues
    echo "- Checking asynchronous operation handling"
}

# Investigate assertion failures
investigate_assertion_failures() {
    local project_dir=$1
    local framework=$2
    
    echo "=== INVESTIGATING ASSERTION FAILURES ==="
    echo ""
    
    # Analyze assertion patterns
    analyze_assertion_patterns "$project_dir" "$framework"
    
    # Check for data issues
    check_test_data_issues "$project_dir" "$framework"
    
    # Check for logic errors
    check_logic_errors "$project_dir" "$framework"
}

# Analyze assertion patterns
analyze_assertion_patterns() {
    local project_dir=$1
    local framework=$2
    
    echo "Analyzing assertion patterns..."
    
    # Find common assertion failures
    find_common_assertion_failures "$project_dir" "$framework"
    
    # Check assertion specificity
    check_assertion_specificity "$project_dir" "$framework"
    
    # Check for flaky assertions
    check_flaky_assertions "$project_dir" "$framework"
}

# Generate investigation summary
generate_investigation_summary() {
    local classification_file=$1
    
    echo "=== INVESTIGATION SUMMARY ==="
    echo ""
    
    if command -v jq >/dev/null 2>&1; then
        local total_failures=$(jq '.total_failures' "$classification_file")
        local priorities=($(jq -r '.investigation_priority[]' "$classification_file"))
        
        echo "Total Failures Investigated: $total_failures"
        echo "Investigation Areas:"
        for priority in "${priorities[@]}"; do
            echo "- $priority"
        done
        echo ""
    fi
    
    echo "Investigation Complete"
    echo "Next Steps:"
    echo "1. Apply fixes based on investigation findings"
    echo "2. Run tests to verify fixes"
    echo "3. Implement prevention measures"
    echo "4. Document lessons learned"
}
```

**Step 3: Fix Implementation and Verification**

**Fix Implementation System:**
```bash
# Implement fixes based on investigation findings
implement_debugging_fixes() {
    local project_dir=${1:-.}
    local framework=${2:-"auto"}
    local classification_file=${FAILURE_CLASSIFICATION_FILE:-}
    
    echo "=== IMPLEMENTING DEBUGGING FIXES ==="
    echo ""
    
    if [ -z "$classification_file" ] || [ ! -f "$classification_file" ]; then
        echo "ERROR: Investigation data not found. Run investigation first."
        return 1
    fi
    
    # Get investigation priorities
    local priorities=($(jq -r '.investigation_priority[]' "$classification_file" 2>/dev/null))
    
    # Implement fixes for each priority area
    for priority in "${priorities[@]}"; do
        echo "Implementing fixes for: $priority"
        case "$priority" in
            "environment_dependencies")
                fix_environment_dependencies "$project_dir" "$framework"
                ;;
            "setup_teardown")
                fix_setup_teardown_issues "$project_dir" "$framework"
                ;;
            "timeouts")
                fix_timeout_issues "$project_dir" "$framework"
                ;;
            "assertions")
                fix_assertion_issues "$project_dir" "$framework"
                ;;
        esac
        echo ""
    done
    
    # Verify fixes
    verify_debugging_fixes "$project_dir" "$framework"
}

# Fix environment and dependency issues
fix_environment_dependencies() {
    local project_dir=$1
    local framework=$2
    
    echo "Fixing environment and dependency issues..."
    
    # Fix dependency installation
    fix_dependency_installation "$project_dir" "$framework"
    
    # Fix environment configuration
    fix_environment_configuration "$project_dir" "$framework"
    
    # Fix file permissions
    fix_file_permissions "$project_dir"
}

# Fix setup and teardown issues
fix_setup_teardown_issues() {
    local project_dir=$1
    local framework=$2
    
    echo "Fixing setup and teardown issues..."
    
    # Fix resource cleanup
    fix_resource_cleanup "$project_dir" "$framework"
    
    # Fix state isolation
    fix_state_isolation "$project_dir" "$framework"
    
    # Fix setup/teardown order
    fix_setup_teardown_order "$project_dir" "$framework"
}

# Fix timeout issues
fix_timeout_issues() {
    local project_dir=$1
    local framework=$2
    
    echo "Fixing timeout issues..."
    
    # Increase timeout limits
    increase_timeout_limits "$project_dir" "$framework"
    
    # Fix race conditions
    fix_race_conditions "$project_dir" "$framework"
    
    # Optimize slow tests
    optimize_slow_tests "$project_dir" "$framework"
}

# Fix assertion issues
fix_assertion_issues() {
    local project_dir=$1
    local framework=$2
    
    echo "Fixing assertion issues..."
    
    # Fix assertion specificity
    fix_assertion_specificity "$project_dir" "$framework"
    
    # Fix test data issues
    fix_test_data_issues "$project_dir" "$framework"
    
    # Fix logic errors
    fix_logic_errors "$project_dir" "$framework"
}

# Verify debugging fixes
verify_debugging_fixes() {
    local project_dir=$1
    local framework=$2
    
    echo "=== VERIFYING DEBUGGING FIXES ==="
    echo ""
    
    # Run tests to verify fixes
    echo "Running tests to verify fixes..."
    local test_output="/tmp/fix-verification-$$.log"
    execute_test_command "$framework" "$project_dir" "--verbose" > "$test_output" 2>&1
    
    # Check if fixes resolved issues
    local remaining_failures=$(grep -c "FAIL\|FAILED\|ERROR" "$test_output" || echo 0)
    
    if [ "$remaining_failures" -eq 0 ]; then
        echo "✅ All tests passing - fixes successful!"
    else
        echo "❌ $remaining_failures tests still failing - additional investigation needed"
        echo "Remaining failures logged in: $test_output"
    fi
    
    # Generate fix verification report
    generate_fix_verification_report "$test_output" "$framework"
}

# Generate fix verification report
generate_fix_verification_report() {
    local test_output=$1
    local framework=$2
    
    echo "=== FIX VERIFICATION REPORT ==="
    echo ""
    
    # Parse test results
    local total_tests=$(grep -c "PASS\|PASSED\|OK" "$test_output" || echo 0)
    local failed_tests=$(grep -c "FAIL\|FAILED\|ERROR" "$test_output" || echo 0)
    local success_rate=0
    
    if [ $((total_tests + failed_tests)) -gt 0 ]; then
        success_rate=$(echo "scale=2; $total_tests * 100 / ($total_tests + $failed_tests)" | bc 2>/dev/null || echo 0)
    fi
    
    echo "Test Results After Fixes:"
    echo "- Total Tests: $((total_tests + failed_tests))"
    echo "- Passed: $total_tests"
    echo "- Failed: $failed_tests"
    echo "- Success Rate: $success_rate%"
    echo ""
    
    if [ "$failed_tests" -gt 0 ]; then
        echo "Remaining Issues:"
        parse_test_results "$framework" "$test_output" | tail -10
    else
        echo "🎉 All tests passing! Debugging fixes successful."
    fi
}
```

**Test Debugging Quality Checklist:**
- [ ] All test failures collected and classified
- [ ] Systematic investigation performed for each failure type
- [ ] Root causes identified and documented
- [ ] Fixes implemented and verified
- [ ] Test reliability improved
- [ ] Prevention measures implemented
- [ ] Debugging insights documented

**Anti-Patterns to Avoid:**
- ❌ Random trial-and-error fixes without investigation
- ❌ Ignoring environmental factors in debugging
- ❌ Fixing symptoms instead of root causes
- ❌ Skipping verification after implementing fixes
- ❌ Not documenting debugging insights for future reference
- ❌ Accepting flaky tests as "normal"

**Final Verification:**
Before completing debugging workflow:
- Have I systematically investigated all failure types?
- Are root causes identified and documented?
- Have fixes been implemented and verified?
- Is test reliability improved?
- Are prevention measures in place?

**Final Commitment:**
- **I will**: Systematically investigate all test failures
- **I will**: Identify and fix root causes, not just symptoms
- **I will**: Verify fixes resolve issues completely
- **I will**: Implement prevention measures
- **I will**: Document debugging insights for future reference
- **I will NOT**: Apply random fixes without investigation
- **I will NOT**: Ignore environmental factors
- **I will NOT**: Accept flaky tests as normal

**REMEMBER:**
This is TEST DEBUGGING WORKFLOW mode - systematic investigation and resolution of test failures. The goal is to improve test reliability and prevent future issues through comprehensive debugging and prevention measures.

Executing comprehensive test debugging workflow with systematic investigation...