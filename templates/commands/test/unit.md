---
allowed-tools: all
description: Unit test execution with comprehensive coverage analysis and parallel agent coordination
---

# ⚡⚡⚡ CRITICAL REQUIREMENT: UNIT TEST EXECUTION AND VALIDATION! ⚡⚡⚡

**THIS IS NOT A SIMPLE TEST RUN - THIS IS A COMPREHENSIVE UNIT TEST EXECUTION SYSTEM!**

When you run `/test/unit`, you are REQUIRED to:

1. **EXECUTE** all unit tests with framework-specific optimizations and parallel processing
2. **ANALYZE** test coverage gaps and generate actionable improvement recommendations
3. **VALIDATE** unit test quality and identify potential improvements
4. **REPORT** comprehensive test results with detailed failure analysis
5. **USE MULTIPLE AGENTS** for parallel unit test execution:
   - Spawn one agent for core module unit tests
   - Spawn another for utility and helper function tests
   - Spawn more agents for different test categories (fast/slow tests)
   - Say: "I'll spawn multiple agents to execute unit tests in parallel for optimal performance"

**FORBIDDEN BEHAVIORS:**
- ❌ "Run basic npm test command" → NO! Use framework-specific optimizations!
- ❌ "Skip coverage analysis" → NO! Comprehensive coverage reporting required!
- ❌ "Ignore test failures" → NO! Detailed failure analysis and fixing required!
- ❌ "Single-threaded execution" → NO! Use parallel agent coordination!
- ❌ "Generic test output" → NO! Framework-specific parsing and reporting!

**MANDATORY WORKFLOW:**
```
1. Framework detection → Identify test framework and configuration
2. IMMEDIATELY spawn agents for parallel test execution
3. Test discovery → Find all unit test files and categorize them
4. Parallel execution → Run tests across multiple agents
5. Coverage analysis → Generate comprehensive coverage reports
6. VERIFY results → Ensure all tests pass and coverage meets thresholds
```

**YOU ARE NOT DONE UNTIL:**
- ✅ All unit tests discovered and executed successfully
- ✅ Test coverage analyzed with gap identification
- ✅ Failed tests analyzed with root cause identification
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

**Comprehensive Unit Test Execution Protocol:**

**Step 0: Framework Detection and Configuration**
- **PHP control validation**: Check PHP structure generation preferences and command flags
- **Structure validation**: Check if proper test structure exists (respecting PHP opt-out settings)
- Detect test framework (Jest, pytest, Go test, RSpec, PHPUnit, etc.)
- Validate framework installation and configuration
- Identify test file patterns and naming conventions
- Check for existing test configuration files
- Verify test environment setup
- **Silent annotation validation**: Validate method-level annotations without CLI output (if PHP enabled)

**Test Structure Validation:**
```bash
# Check if comprehensive test structure exists
validate_test_structure() {
    local project_dir=${1:-.}
    local command_args=${2:-""}
    
    echo "=== Test Structure Validation ==="
    echo ""
    
    # Check PHP control mechanisms first
    local php_status=$(get_php_status_message "$project_dir" "$command_args")
    echo "$php_status"
    echo ""
    
    # Parse command flags for structure check override
    local flags=$(parse_php_test_flags "$command_args")
    local skip_structure_flag=$(echo "$flags" | sed 's/.*skip_structure_check:\([^ ]*\).*/\1/')
    local php_disabled_flag=$(echo "$flags" | sed 's/.*php_disabled:\([^ ]*\).*/\1/')
    
    # Skip PHP structure validation if disabled or overridden
    if [ "$skip_structure_flag" = "true" ] || [ "$php_disabled_flag" = "true" ] || is_php_structure_disabled "$project_dir"; then
        echo "✅ Test structure validation skipped (PHP features disabled)"
        return 0
    fi
    
    # Only enforce PHP structure if PHP project is detected
    if detect_php_framework "$project_dir" >/dev/null 2>&1; then
        local required_dirs=("tests" "tests/Unit" "tests/Integration" "tests/Support")
        
        # Check for basic test structure
        for dir in "${required_dirs[@]}"; do
            if [ ! -d "$project_dir/$dir" ]; then
                echo "⚠️  Missing test directory: $dir"
                echo ""
                echo "🏗️  It looks like you need a comprehensive test structure!"
                echo "   Run: /test structure"
                echo "   This will generate a complete PHP test structure with:"
                echo "   - Framework-specific optimizations (Laravel, Symfony, Pure PHP)"
                echo "   - Tool configurations (PHPStan, PHPCS, Infection)"
                echo "   - Support files and bootstrap configuration"
                echo "   - Integration with annotation validation system"
                echo ""
                echo "💡 To disable PHP structure validation, use:"
                echo "   --skip-php-structure-check flag OR"
                echo "   export CLAUDE_PHP_TESTS=false OR"
                echo "   touch .claude/no-php-tests"
                echo ""
                return 1
            fi
        done
    else
        # Non-PHP project - check for basic test directory
        if [ ! -d "$project_dir/test" ] && [ ! -d "$project_dir/tests" ] && [ ! -d "$project_dir/__tests__" ] && [ ! -d "$project_dir/spec" ]; then
            echo "⚠️  No test directory found"
            echo "   Consider creating: test/ or tests/ directory"
            echo ""
        fi
    fi
    
    # Check for framework-specific test structure
    if detect_php_framework "$project_dir" >/dev/null 2>&1; then
        local framework=$(detect_php_framework "$project_dir" | grep "framework:" | cut -d: -f2)
        
        case "$framework" in
            "laravel")
                if [ ! -d "$project_dir/tests/Feature" ] || [ ! -d "$project_dir/tests/Unit/Http" ]; then
                    echo "⚠️  Incomplete Laravel test structure detected"
                    echo "   Consider running: /test structure"
                    echo "   This will optimize your test structure for Laravel"
                fi
                ;;
            "symfony")
                if [ ! -d "$project_dir/tests/Unit/Controller" ] || [ ! -d "$project_dir/tests/Functional" ]; then
                    echo "⚠️  Incomplete Symfony test structure detected"
                    echo "   Consider running: /test structure"
                    echo "   This will optimize your test structure for Symfony"
                fi
                ;;
        esac
    fi
    
    echo "✅ Test structure validation completed"
    return 0
}
```

**Step 1: Test Discovery and Categorization**

**Test File Discovery:**
```bash
# Discover all unit test files
find_unit_tests() {
    local project_dir=${1:-.}
    local command_args=${2:-""}
    local framework=$(detect_test_framework "$project_dir")
    
    # Validate test structure before proceeding (respecting PHP opt-out)
    if ! validate_test_structure "$project_dir" "$command_args"; then
        echo ""
        echo "❌ Test structure validation failed - cannot proceed with unit tests"
        echo "   Please run '/test structure' first to create the required test infrastructure"
        echo "   OR use --skip-php-structure-check to bypass PHP structure validation"
        return 1
    fi
    
    case "$framework" in
        "jest"|"mocha")
            find "$project_dir" -name "*.test.js" -o -name "*.spec.js" -o -name "*.test.ts" -o -name "*.spec.ts"
            ;;
        "pytest")
            find "$project_dir" -name "test_*.py" -o -name "*_test.py"
            ;;
        "go-test")
            find "$project_dir" -name "*_test.go"
            ;;
        "rspec")
            find "$project_dir" -name "*_spec.rb"
            ;;
        "phpunit")
            find "$project_dir/tests" -name "*Test.php"
            ;;
        *)
            echo "ERROR: Unsupported test framework: $framework"
            return 1
            ;;
    esac
}

# Silent annotation validation for unit testing
validate_annotations_silently() {
    local project_dir=${1:-.}
    local command_args=${2:-""}
    
    # Check if PHP features are disabled
    local flags=$(parse_php_test_flags "$command_args")
    local php_disabled_flag=$(echo "$flags" | sed 's/.*php_disabled:\([^ ]*\).*/\1/')
    
    if [ "$php_disabled_flag" = "true" ] || is_php_structure_disabled "$project_dir"; then
        # PHP features disabled, skip annotation validation
        return 0
    fi
    
    # Check for PHP annotation system
    if detect_php_annotations "$project_dir" >/dev/null 2>&1; then
        # Run annotation validation silently and capture results
        local annotation_result=$(execute_annotation_command "validate" "$project_dir" "json" 2>/dev/null)
        local annotation_status=$?
        
        # Store results for later reporting
        echo "$annotation_result" > /tmp/unit-test-annotations.json 2>/dev/null
        
        # Return status without output
        return $annotation_status
    fi
    
    # No annotation system found, skip silently
    return 0
}

# Categorize tests by speed and complexity
categorize_unit_tests() {
    local test_files=("$@")
    local fast_tests=()
    local slow_tests=()
    
    for test_file in "${test_files[@]}"; do
        # Use file size as proxy for test complexity
        local size=$(stat -f%z "$test_file" 2>/dev/null || stat -c%s "$test_file" 2>/dev/null)
        if [ "$size" -gt 5000 ]; then
            slow_tests+=("$test_file")
        else
            fast_tests+=("$test_file")
        fi
    done
    
    echo "Fast tests: ${#fast_tests[@]}"
    echo "Slow tests: ${#slow_tests[@]}"
}
```

**Step 2: Multi-Agent Test Execution Strategy**

**Agent Spawning Strategy for Unit Tests:**
```
"I'll spawn multiple agents to execute unit tests comprehensively:
- Fast Test Agent: Execute quick unit tests for immediate feedback
- Slow Test Agent: Execute complex unit tests with detailed analysis
- Coverage Agent: Analyze test coverage and identify gaps
- Quality Agent: Validate test quality and suggest improvements
- Annotation Agent: Silently validate method-level annotations in background
- Reporting Agent: Generate comprehensive test reports and metrics"
```

**Step 3: Parallel Unit Test Execution**

**Framework-Specific Execution:**
```bash
# Execute unit tests with framework optimizations
execute_unit_tests() {
    local framework=$1
    local project_dir=${2:-.}
    local parallel_agents=${3:-4}
    local command_args=${4:-""}
    
    # Silently validate annotations before running tests (respecting PHP opt-out)
    validate_annotations_silently "$project_dir" "$command_args" &
    local annotation_pid=$!
    
    case "$framework" in
        "jest")
            # Jest with parallel execution
            npx jest --coverage --maxWorkers=$parallel_agents --verbose --testPathPattern="test|spec"
            ;;
        "pytest")
            # pytest with parallel execution
            python -m pytest -v --cov=. --cov-report=html --cov-report=term -n $parallel_agents
            ;;
        "go-test")
            # Go test with race detection
            go test -v -race -coverprofile=coverage.out ./...
            ;;
        "rspec")
            # RSpec with parallel execution
            bundle exec rspec --format documentation --format html --out rspec_results.html
            ;;
        "phpunit")
            # PHPUnit with coverage (if not disabled)
            local flags=$(parse_php_test_flags "$command_args")
            local php_disabled=$(echo "$flags" | sed 's/.*php_disabled:\([^ ]*\).*/\1/')
            
            if [ "$php_disabled" = "true" ]; then
                echo "PHPUnit execution skipped (--no-php flag specified)"
                return 0
            else
                ./vendor/bin/phpunit --coverage-html coverage --coverage-text 2>/dev/null || phpunit --coverage-html coverage --coverage-text
            fi
            ;;
        *)
            echo "ERROR: Framework execution not implemented: $framework"
            return 1
            ;;
    esac
    
    # Wait for annotation validation to complete
    wait $annotation_pid >/dev/null 2>&1
}

# Monitor test execution progress
monitor_test_progress() {
    local total_tests=$1
    local completed_tests=0
    
    while [ $completed_tests -lt $total_tests ]; do
        echo "Progress: $completed_tests/$total_tests tests completed"
        sleep 2
        # Update completed_tests based on actual execution
        completed_tests=$((completed_tests + 1))
    done
}
```

**Step 4: Coverage Analysis and Gap Identification**

**Coverage Analysis Tools:**
```bash
# Generate comprehensive coverage report
generate_coverage_report() {
    local framework=$1
    local project_dir=${2:-.}
    
    case "$framework" in
        "jest")
            # Jest coverage analysis
            npx jest --coverage --coverageReporters=html --coverageReporters=text --coverageReporters=json
            ;;
        "pytest")
            # pytest coverage analysis
            python -m pytest --cov=. --cov-report=html --cov-report=term-missing
            ;;
        "go-test")
            # Go coverage analysis
            go test -coverprofile=coverage.out ./... && go tool cover -html=coverage.out -o coverage.html
            ;;
        "rspec")
            # RSpec with SimpleCov
            bundle exec rspec --require simplecov
            ;;
    esac
}

# Identify coverage gaps
identify_coverage_gaps() {
    local framework=$1
    local coverage_file=${2:-"coverage"}
    
    echo "=== Coverage Gap Analysis ==="
    echo ""
    
    case "$framework" in
        "jest")
            # Parse Jest coverage JSON
            if [ -f "coverage/coverage-final.json" ]; then
                node -e "
                const coverage = require('./coverage/coverage-final.json');
                Object.keys(coverage).forEach(file => {
                    const fileCoverage = coverage[file];
                    const uncoveredLines = Object.keys(fileCoverage.statementMap).filter(line => 
                        fileCoverage.s[line] === 0
                    );
                    if (uncoveredLines.length > 0) {
                        console.log(\`\${file}: Lines \${uncoveredLines.join(', ')} not covered\`);
                    }
                });
                "
            fi
            ;;
        "pytest")
            # Parse pytest coverage
            if [ -f ".coverage" ]; then
                python -c "
import coverage
cov = coverage.Coverage()
cov.load()
for filename in cov.get_data().measured_files():
    missing_lines = cov.analysis2(filename)[3]
    if missing_lines:
        print(f'{filename}: Lines {missing_lines} not covered')
"
            fi
            ;;
        "go-test")
            # Parse Go coverage
            if [ -f "coverage.out" ]; then
                go tool cover -func=coverage.out | grep -v "100.0%"
            fi
            ;;
    esac
}
```

**Step 5: Test Quality Validation**

**Test Quality Metrics:**
```bash
# Validate test quality
validate_test_quality() {
    local test_files=("$@")
    local quality_issues=0
    
    echo "=== Test Quality Validation ==="
    echo ""
    
    for test_file in "${test_files[@]}"; do
        # Check for test best practices
        if ! grep -q "describe\|it\|test\|def test_" "$test_file"; then
            echo "WARNING: $test_file may not contain proper test structure"
            quality_issues=$((quality_issues + 1))
        fi
        
        # Check for assertions
        if ! grep -q "expect\|assert\|should\|assertEquals" "$test_file"; then
            echo "WARNING: $test_file may not contain assertions"
            quality_issues=$((quality_issues + 1))
        fi
        
        # Check for mocks/stubs
        if grep -q "mock\|stub\|spy" "$test_file"; then
            echo "INFO: $test_file uses mocking (good for isolation)"
        fi
    done
    
    if [ $quality_issues -eq 0 ]; then
        echo "✅ All tests follow quality best practices"
    else
        echo "⚠️  Found $quality_issues quality issues"
    fi
}

# Generate test quality report
generate_quality_report() {
    local framework=$1
    local project_dir=${2:-.}
    
    local total_tests=$(find_unit_tests "$project_dir" | wc -l)
    local test_files=$(find_unit_tests "$project_dir")
    
    echo "=== Unit Test Quality Report ==="
    echo "Total Unit Tests: $total_tests"
    echo "Framework: $framework"
    echo "Project Directory: $project_dir"
    echo ""
    
    # Validate test quality
    validate_test_quality $test_files
    
    # Coverage analysis
    identify_coverage_gaps "$framework"
    
    # Include annotation validation results if available
    include_annotation_results_summary
    
    # Performance metrics
    echo ""
    echo "=== Performance Metrics ==="
    echo "Test execution time: $(get_test_execution_time)"
    echo "Average test duration: $(calculate_average_test_duration)"
}

# Include annotation validation summary in test report
include_annotation_results_summary() {
    if [ -f "/tmp/unit-test-annotations.json" ]; then
        echo ""
        echo "=== Annotation Validation Summary ==="
        
        # Parse annotation results silently and show summary
        local annotation_summary=$(php -r "
        \$results = json_decode(file_get_contents('/tmp/unit-test-annotations.json'), true);
        if (isset(\$results['method_linkage_analysis']['summary'])) {
            \$summary = \$results['method_linkage_analysis']['summary'];
            \$total_methods = (\$summary['totalSourceMethods'] ?? 0);
            \$with_annotations = (\$summary['methodsWithVerified'] ?? 0);
            \$coverage = \$total_methods > 0 ? round((\$with_annotations / \$total_methods) * 100, 1) : 0;
            echo \"Annotation Coverage: \$coverage% (\$with_annotations/\$total_methods methods)\";
            if ((\$summary['invalidMethodLinks'] ?? 0) > 0) {
                echo \" - \" . (\$summary['invalidMethodLinks'] ?? 0) . \" invalid links\";
            }
        }
        " 2>/dev/null)
        
        if [ -n "$annotation_summary" ]; then
            echo "$annotation_summary"
        else
            echo "Annotation validation completed"
        fi
        
        # Clean up temporary file
        rm -f "/tmp/unit-test-annotations.json" 2>/dev/null
    fi
}
```

**Step 6: Failure Analysis and Reporting**

**Failure Analysis Tools:**
```bash
# Analyze test failures
analyze_test_failures() {
    local framework=$1
    local test_output_file=${2:-"test-output.log"}
    
    echo "=== Test Failure Analysis ==="
    echo ""
    
    case "$framework" in
        "jest")
            # Parse Jest failures
            grep -A 10 -B 2 "FAIL" "$test_output_file" | while read -r line; do
                if [[ "$line" =~ FAIL ]]; then
                    echo "❌ Failed Test: $line"
                elif [[ "$line" =~ Error ]]; then
                    echo "   Error: $line"
                fi
            done
            ;;
        "pytest")
            # Parse pytest failures
            grep -A 5 -B 2 "FAILED" "$test_output_file" | while read -r line; do
                if [[ "$line" =~ FAILED ]]; then
                    echo "❌ Failed Test: $line"
                elif [[ "$line" =~ AssertionError ]]; then
                    echo "   Assertion Error: $line"
                fi
            done
            ;;
        "go-test")
            # Parse Go test failures
            grep -A 3 -B 1 "FAIL" "$test_output_file" | while read -r line; do
                if [[ "$line" =~ FAIL ]]; then
                    echo "❌ Failed Test: $line"
                elif [[ "$line" =~ "Error:" ]]; then
                    echo "   Error: $line"
                fi
            done
            ;;
    esac
}

# Generate failure summary
generate_failure_summary() {
    local framework=$1
    local test_output_file=${2:-"test-output.log"}
    
    local failed_tests=$(grep -c "FAIL\|FAILED" "$test_output_file" 2>/dev/null || echo "0")
    local total_tests=$(grep -c "PASS\|PASSED\|OK" "$test_output_file" 2>/dev/null || echo "0")
    total_tests=$((total_tests + failed_tests))
    
    echo "=== Test Execution Summary ==="
    echo "Total Tests: $total_tests"
    echo "Passed: $((total_tests - failed_tests))"
    echo "Failed: $failed_tests"
    echo "Success Rate: $(echo "scale=2; ($total_tests - $failed_tests) * 100 / $total_tests" | bc 2>/dev/null || echo "0")%"
    echo ""
    
    if [ "$failed_tests" -gt 0 ]; then
        echo "=== Failed Tests Analysis ==="
        analyze_test_failures "$framework" "$test_output_file"
    fi
}
```

**Step 7: Performance Optimization**

**Performance Monitoring:**
```bash
# Monitor test performance
monitor_test_performance() {
    local framework=$1
    local start_time=$(date +%s)
    
    # Execute tests with timing
    execute_unit_tests "$framework" "." 4
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo "=== Performance Metrics ==="
    echo "Total execution time: ${duration}s"
    echo "Framework: $framework"
    echo "Parallel agents: 4"
    
    # Framework-specific performance tips
    case "$framework" in
        "jest")
            echo "💡 Jest Performance Tips:"
            echo "- Use --maxWorkers to optimize parallel execution"
            echo "- Consider --onlyChanged for faster feedback"
            echo "- Use --bail to stop on first failure"
            ;;
        "pytest")
            echo "💡 pytest Performance Tips:"
            echo "- Use -n auto for optimal parallel execution"
            echo "- Consider --lf to run last failed tests first"
            echo "- Use --durations=10 to identify slow tests"
            ;;
        "go-test")
            echo "💡 Go Test Performance Tips:"
            echo "- Use -parallel flag for parallel execution"
            echo "- Consider -short flag for faster subset"
            echo "- Use build cache for faster compilation"
            ;;
    esac
}
```

**Unit Test Quality Checklist:**
- [ ] All unit tests discovered and categorized
- [ ] Framework-specific optimizations applied
- [ ] Parallel execution configured and working
- [ ] Coverage analysis completed with gap identification
- [ ] Test quality validated against best practices
- [ ] **Silent annotation validation completed** (if PHP system available)
- [ ] Failed tests analyzed with root cause identification
- [ ] Performance metrics collected and reported
- [ ] **Annotation coverage summary included** in quality report
- [ ] Actionable recommendations provided

**Anti-Patterns to Avoid:**
- ❌ Running tests without coverage analysis (incomplete validation)
- ❌ Ignoring test failures or flaky tests (quality compromise)
- ❌ Single-threaded execution without parallelization (performance issue)
- ❌ Generic test execution without framework optimization (suboptimal)
- ❌ Skipping test quality validation (technical debt)
- ❌ No failure analysis or actionable reporting (missed improvements)

**Final Verification:**
Before completing unit test execution:
- Have I executed all unit tests with proper framework configuration?
- Are coverage reports generated with gap analysis?
- Have I analyzed and reported on test failures?
- **Has annotation validation been completed silently** (if PHP system available)?
- **Is annotation coverage summary included** in the quality report?
- Are performance metrics collected and optimization tips provided?
- Do I have actionable recommendations for improvement?

**Final Commitment:**
- **I will**: Execute all unit tests with comprehensive coverage analysis
- **I will**: Use parallel agents for optimal performance
- **I will**: **Silently validate annotations** without cluttering CLI output
- **I will**: **Include annotation coverage** in quality reports when available
- **I will**: Provide detailed failure analysis and actionable recommendations
- **I will**: Validate test quality and suggest improvements
- **I will**: Generate comprehensive reports with performance metrics
- **I will NOT**: Skip coverage analysis or quality validation
- **I will NOT**: **Output annotation validation details** during test execution
- **I will NOT**: Ignore test failures or performance issues
- **I will NOT**: Use single-threaded execution without parallelization
- **I will NOT**: Provide generic reports without actionable insights

**REMEMBER:**
This is UNIT TEST EXECUTION mode - comprehensive testing with coverage analysis, quality validation, silent annotation validation, and performance optimization. The goal is to ensure code quality and reliability through thorough unit testing with integrated annotation coverage reporting.

Executing comprehensive unit test execution protocol with parallel agent coordination...