---
description: Test suite for .claude protection override mechanisms
phase: phase-003
dependencies: ["claude-protection-overrides.md", "claude-protection-integration.md"]
status: testing
---

# .Claude Protection Test Suite

**Comprehensive test scenarios for validating override mechanisms**

This test suite ensures the .claude protection system works correctly across all scenarios and edge cases.

## Test Environment Setup

```bash
# Setup test environment for .claude protection
setup_claude_protection_test_env() {
    local test_dir="./test-claude-protection"
    
    echo "🧪 Setting up .claude protection test environment..."
    
    # Clean up any existing test environment
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
    fi
    
    # Create test directory structure
    mkdir -p "$test_dir"/{src,docs,.claude/commands,.claude-snapshots,.claude-audit}
    
    # Create test files
    cat > "$test_dir/src/test.js" <<EOF
// Test JavaScript file
console.log("Hello World");
function test() {
    return true;
}
EOF
    
    cat > "$test_dir/.claude/CLAUDE.md" <<EOF
# Test Claude Configuration
This is a test Claude configuration file.
EOF
    
    cat > "$test_dir/.claude/commands/test-command.md" <<EOF
---
description: Test command for .claude protection
---
# Test Command
This is a test command file.
EOF
    
    # Create some temporary files for cleanup testing
    touch "$test_dir/.claude/commands/test.bak"
    touch "$test_dir/.claude/commands/temp~"
    touch "$test_dir/src/backup.tmp"
    
    echo "✅ Test environment created: $test_dir"
    echo "$test_dir"
}

# Cleanup test environment
cleanup_claude_protection_test_env() {
    local test_dir=${1:-"./test-claude-protection"}
    
    if [ -d "$test_dir" ]; then
        rm -rf "$test_dir"
        echo "🧹 Test environment cleaned up"
    fi
}
```

## Override Flag Tests

```bash
# Test override flag parsing
test_override_flag_parsing() {
    echo ""
    echo "🧪 Testing Override Flag Parsing"
    echo "================================"
    
    local test_passed=0
    local test_failed=0
    
    # Test 1: No flags
    echo "Test 1: No override flags"
    local result=$(parse_claude_override_flags "arg1" "arg2")
    if [[ "$CLAUDE_INCLUDE_ENABLED" == "false" ]] && [[ "$result" == "arg1 arg2" ]]; then
        echo "✅ PASS: No flags parsed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: No flags test failed"
        test_failed=$((test_failed + 1))
    fi
    
    # Reset environment
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    # Test 2: --include-claude flag
    echo "Test 2: --include-claude flag"
    result=$(parse_claude_override_flags "--include-claude" "arg1")
    if [[ "$CLAUDE_INCLUDE_ENABLED" == "true" ]] && [[ "$result" == "arg1" ]]; then
        echo "✅ PASS: --include-claude parsed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: --include-claude test failed"
        test_failed=$((test_failed + 1))
    fi
    
    # Reset environment
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    # Test 3: --claude-only flag
    echo "Test 3: --claude-only flag"
    result=$(parse_claude_override_flags "--claude-only" "arg1")
    if [[ "$CLAUDE_ONLY_MODE" == "true" ]] && [[ "$CLAUDE_INCLUDE_ENABLED" == "true" ]]; then
        echo "✅ PASS: --claude-only parsed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: --claude-only test failed"
        test_failed=$((test_failed + 1))
    fi
    
    # Reset environment
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    # Test 4: --claude-dry-run flag
    echo "Test 4: --claude-dry-run flag"
    result=$(parse_claude_override_flags "--claude-dry-run" "arg1")
    if [[ "$CLAUDE_DRY_RUN_MODE" == "true" ]]; then
        echo "✅ PASS: --claude-dry-run parsed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: --claude-dry-run test failed"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 5: Invalid flag combination
    echo "Test 5: Invalid flag combination"
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    if ! parse_claude_override_flags "--claude-only" "--force-claude" "arg1" >/dev/null 2>&1; then
        echo "✅ PASS: Invalid combination rejected"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Invalid combination not caught"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Flag Parsing Test Results: $test_passed passed, $test_failed failed"
    
    # Reset environment
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    return $test_failed
}

# Test path filtering logic
test_path_filtering() {
    echo ""
    echo "🧪 Testing Path Filtering Logic"
    echo "==============================="
    
    local test_passed=0
    local test_failed=0
    local test_dir=$(setup_claude_protection_test_env)
    
    # Test 1: Default behavior (exclude .claude)
    echo "Test 1: Default behavior - exclude .claude paths"
    export CLAUDE_INCLUDE_ENABLED="false"
    export CLAUDE_ONLY_MODE="false"
    
    if should_process_path_with_overrides "$test_dir/src/test.js"; then
        echo "✅ PASS: Regular files included by default"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Regular files excluded incorrectly"
        test_failed=$((test_failed + 1))
    fi
    
    if ! should_process_path_with_overrides "$test_dir/.claude/CLAUDE.md"; then
        echo "✅ PASS: .claude files excluded by default"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: .claude files not excluded by default"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Include .claude mode
    echo "Test 2: Include .claude mode"
    export CLAUDE_INCLUDE_ENABLED="true"
    export CLAUDE_ONLY_MODE="false"
    
    if should_process_path_with_overrides "$test_dir/src/test.js"; then
        echo "✅ PASS: Regular files included with --include-claude"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Regular files excluded with --include-claude"
        test_failed=$((test_failed + 1))
    fi
    
    if should_process_path_with_overrides "$test_dir/.claude/CLAUDE.md"; then
        echo "✅ PASS: .claude files included with --include-claude"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: .claude files not included with --include-claude"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Claude-only mode
    echo "Test 3: Claude-only mode"
    export CLAUDE_INCLUDE_ENABLED="true"
    export CLAUDE_ONLY_MODE="true"
    
    if ! should_process_path_with_overrides "$test_dir/src/test.js"; then
        echo "✅ PASS: Regular files excluded in claude-only mode"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Regular files not excluded in claude-only mode"
        test_failed=$((test_failed + 1))
    fi
    
    if should_process_path_with_overrides "$test_dir/.claude/CLAUDE.md"; then
        echo "✅ PASS: .claude files included in claude-only mode"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: .claude files not included in claude-only mode"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Path Filtering Test Results: $test_passed passed, $test_failed failed"
    
    cleanup_claude_protection_test_env "$test_dir"
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    return $test_failed
}
```

## Dry Run Tests

```bash
# Test dry run functionality
test_dry_run_functionality() {
    echo ""
    echo "🧪 Testing Dry Run Functionality"
    echo "================================"
    
    local test_passed=0
    local test_failed=0
    local test_dir=$(setup_claude_protection_test_env)
    
    # Setup dry run mode
    export CLAUDE_DRY_RUN_MODE="true"
    export CLAUDE_INCLUDE_ENABLED="true"
    
    # Test 1: Dry run format operation
    echo "Test 1: Dry run format operation"
    local dry_run_output=$(execute_claude_dry_run "format" "$test_dir/.claude/CLAUDE.md" 2>&1)
    
    if [[ "$dry_run_output" == *"DRY RUN MODE ACTIVE"* ]] && [[ "$dry_run_output" == *"No actual changes were made"* ]]; then
        echo "✅ PASS: Dry run format operation completed"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Dry run format operation failed"
        echo "Output: $dry_run_output"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Verify no files were modified
    echo "Test 2: Verify no files were modified in dry run"
    local original_content="# Test Claude Configuration"
    local current_content=$(head -1 "$test_dir/.claude/CLAUDE.md")
    
    if [[ "$current_content" == "$original_content" ]]; then
        echo "✅ PASS: Files not modified in dry run"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Files were modified in dry run"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Dry run cleanup operation
    echo "Test 3: Dry run cleanup operation"
    dry_run_output=$(execute_claude_dry_run "cleanup" "$test_dir/.claude" 2>&1)
    
    if [[ "$dry_run_output" == *"temporary files"* ]] && [ -f "$test_dir/.claude/commands/test.bak" ]; then
        echo "✅ PASS: Dry run cleanup identified temp files but didn't remove them"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Dry run cleanup operation failed"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Dry Run Test Results: $test_passed passed, $test_failed failed"
    
    cleanup_claude_protection_test_env "$test_dir"
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE
    
    return $test_failed
}
```

## Audit Logging Tests

```bash
# Test audit logging functionality
test_audit_logging() {
    echo ""
    echo "🧪 Testing Audit Logging Functionality"
    echo "======================================"
    
    local test_passed=0
    local test_failed=0
    local test_dir=$(setup_claude_protection_test_env)
    
    # Setup audit logging
    setup_claude_audit_logging "$test_dir"
    
    # Test 1: Basic audit logging
    echo "Test 1: Basic audit logging"
    log_audit_event "test_operation" "$test_dir/.claude/test" "SUCCESS" "test details"
    
    local audit_file="$test_dir/.claude-audit/access.log"
    if [ -f "$audit_file" ] && grep -q "test_operation" "$audit_file"; then
        echo "✅ PASS: Audit event logged successfully"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Audit event not logged"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Access logging
    echo "Test 2: Access logging"
    export CLAUDE_INCLUDE_ENABLED="false"
    log_claude_access "format" "$test_dir/.claude/CLAUDE.md" false
    
    if grep -q "DENIED" "$audit_file"; then
        echo "✅ PASS: Access denial logged"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Access denial not logged"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Allowed access logging
    echo "Test 3: Allowed access logging"
    export CLAUDE_INCLUDE_ENABLED="true"
    log_claude_access "format" "$test_dir/.claude/CLAUDE.md" true
    
    if grep -q "ALLOWED" "$audit_file"; then
        echo "✅ PASS: Access approval logged"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Access approval not logged"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 4: Audit report generation
    echo "Test 4: Audit report generation"
    local report_output=$(generate_claude_audit_report "$test_dir" "summary" "all" 2>&1)
    
    if [[ "$report_output" == *"AUDIT REPORT"* ]] && [[ "$report_output" == *"SUMMARY STATISTICS"* ]]; then
        echo "✅ PASS: Audit report generated successfully"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Audit report generation failed"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Audit Logging Test Results: $test_passed passed, $test_failed failed"
    
    cleanup_claude_protection_test_env "$test_dir"
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE CLAUDE_AUDIT_ENABLED
    
    return $test_failed
}
```

## Integration Tests

```bash
# Test integration with quality commands
test_command_integration() {
    echo ""
    echo "🧪 Testing Command Integration"
    echo "============================="
    
    local test_passed=0
    local test_failed=0
    local test_dir=$(setup_claude_protection_test_env)
    
    # Mock quality commands for testing
    format_codebase_original() {
        echo "Mock format operation on: $*"
        return 0
    }
    
    cleanup_codebase_original() {
        echo "Mock cleanup operation on: $*"
        # Simulate cleanup by removing .bak files
        find "$1" -name "*.bak" -delete 2>/dev/null || true
        return 0
    }
    
    verify_codebase_original() {
        echo "Mock verify operation on: $*"
        return 0
    }
    
    # Test 1: Default behavior blocks .claude access
    echo "Test 1: Default behavior blocks .claude access"
    export CLAUDE_INCLUDE_ENABLED="false"
    
    local integration_result=$(integrate_claude_overrides "format" "$test_dir/.claude/CLAUDE.md" 2>&1)
    if [[ $? -ne 0 ]]; then
        echo "✅ PASS: Default behavior blocks .claude access"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Default behavior didn't block .claude access"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Include flag allows .claude access
    echo "Test 2: Include flag allows .claude access"
    export CLAUDE_INCLUDE_ENABLED="true"
    setup_claude_audit_logging "$test_dir"
    
    integration_result=$(integrate_claude_overrides "format" "$test_dir/.claude/CLAUDE.md")
    if [[ $? -eq 0 ]] && [[ "$integration_result" == *".claude/CLAUDE.md"* ]]; then
        echo "✅ PASS: Include flag allows .claude access"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Include flag didn't allow .claude access"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Claude-only mode filters correctly
    echo "Test 3: Claude-only mode filters correctly"
    export CLAUDE_ONLY_MODE="true"
    
    integration_result=$(integrate_claude_overrides "format" "$test_dir/src/test.js" "$test_dir/.claude/CLAUDE.md")
    if [[ "$integration_result" == *".claude/CLAUDE.md"* ]] && [[ "$integration_result" != *"src/test.js"* ]]; then
        echo "✅ PASS: Claude-only mode filters correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Claude-only mode filtering failed"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 4: Integrated command execution
    echo "Test 4: Integrated command execution"
    export CLAUDE_ONLY_MODE="false"
    export CLAUDE_DRY_RUN_MODE="false"
    
    if format_codebase_with_protection "$test_dir" 2>&1 | grep -q "Mock format operation"; then
        echo "✅ PASS: Integrated command execution works"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Integrated command execution failed"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Integration Test Results: $test_passed passed, $test_failed failed"
    
    cleanup_claude_protection_test_env "$test_dir"
    unset CLAUDE_INCLUDE_ENABLED CLAUDE_ONLY_MODE CLAUDE_FORCE_MODE CLAUDE_DRY_RUN_MODE CLAUDE_CONFIRM_MODE CLAUDE_AUDIT_ENABLED
    
    return $test_failed
}
```

## Risk Assessment Tests

```bash
# Test risk assessment functionality
test_risk_assessment() {
    echo ""
    echo "🧪 Testing Risk Assessment"
    echo "========================="
    
    local test_passed=0
    local test_failed=0
    local test_dir=$(setup_claude_protection_test_env)
    
    # Test 1: Low risk operation
    echo "Test 1: Low risk operation (format)"
    local risk_level=$(assess_claude_operation_risk "format" "$test_dir/.claude/commands/test-command.md")
    
    if [[ "$risk_level" == "LOW" ]] || [[ "$risk_level" == "MEDIUM" ]]; then
        echo "✅ PASS: Format operation assessed as low/medium risk"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Format operation risk assessment incorrect: $risk_level"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: High risk operation
    echo "Test 2: High risk operation (delete on CLAUDE.md)"
    risk_level=$(assess_claude_operation_risk "delete" "$test_dir/.claude/CLAUDE.md")
    
    if [[ "$risk_level" == "HIGH" ]] || [[ "$risk_level" == "CRITICAL" ]]; then
        echo "✅ PASS: Delete CLAUDE.md assessed as high/critical risk"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Delete CLAUDE.md risk assessment incorrect: $risk_level"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Medium risk operation
    echo "Test 3: Medium risk operation (cleanup)"
    risk_level=$(assess_claude_operation_risk "cleanup" "$test_dir/.claude/commands/test-command.md")
    
    if [[ "$risk_level" == "MEDIUM" ]] || [[ "$risk_level" == "HIGH" ]]; then
        echo "✅ PASS: Cleanup operation assessed as medium/high risk"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Cleanup operation risk assessment incorrect: $risk_level"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Risk Assessment Test Results: $test_passed passed, $test_failed failed"
    
    cleanup_claude_protection_test_env "$test_dir"
    
    return $test_failed
}
```

## Error Handling Tests

```bash
# Test error handling and guidance
test_error_handling() {
    echo ""
    echo "🧪 Testing Error Handling and Guidance"
    echo "======================================"
    
    local test_passed=0
    local test_failed=0
    
    # Test 1: Access denied error
    echo "Test 1: Access denied error display"
    local error_output=$(display_claude_error "access_denied" 2>&1)
    
    if [[ "$error_output" == *"CLAUDE OPERATION ERROR"* ]] && [[ "$error_output" == *"--include-claude"* ]]; then
        echo "✅ PASS: Access denied error displayed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Access denied error not displayed correctly"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 2: Invalid flags error
    echo "Test 2: Invalid flags error display"
    error_output=$(display_claude_error "invalid_flags" "--claude-only + --force-claude" 2>&1)
    
    if [[ "$error_output" == *"Invalid flag combination"* ]] && [[ "$error_output" == *"INVALID COMBINATIONS"* ]]; then
        echo "✅ PASS: Invalid flags error displayed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Invalid flags error not displayed correctly"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 3: Quick help display
    echo "Test 3: Quick help display"
    local help_output=$(show_claude_quick_help 2>&1)
    
    if [[ "$help_output" == *"CLAUDE DIRECTORY PROTECTION HELP"* ]] && [[ "$help_output" == *"EXAMPLES"* ]]; then
        echo "✅ PASS: Quick help displayed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Quick help not displayed correctly"
        test_failed=$((test_failed + 1))
    fi
    
    # Test 4: Operation guidance
    echo "Test 4: Operation-specific guidance"
    local guidance_output=$(display_claude_guidance "format" 2>&1)
    
    if [[ "$guidance_output" == *"FORMATTING .claude DIRECTORIES"* ]] && [[ "$guidance_output" == *"RECOMMENDED WORKFLOW"* ]]; then
        echo "✅ PASS: Format guidance displayed correctly"
        test_passed=$((test_passed + 1))
    else
        echo "❌ FAIL: Format guidance not displayed correctly"
        test_failed=$((test_failed + 1))
    fi
    
    echo ""
    echo "Error Handling Test Results: $test_passed passed, $test_failed failed"
    
    return $test_failed
}
```

## Comprehensive Test Runner

```bash
# Run all .claude protection tests
run_claude_protection_tests() {
    echo ""
    echo "🚀 RUNNING CLAUDE PROTECTION TEST SUITE"
    echo "======================================="
    echo "Testing Phase 3: User Override Mechanisms"
    echo ""
    
    local total_tests=0
    local total_failures=0
    local start_time=$(date +%s)
    
    # Source required files
    echo "📋 Loading .claude protection modules..."
    local base_dir="${CLAUDE_COMMANDS_DIR:-/Users/nashgao/Desktop/claude/claude-code/instruction/.claude/commands}"
    
    if [ -f "$base_dir/quality/_shared/claude-protection-overrides.md" ]; then
        source "$base_dir/quality/_shared/claude-protection-overrides.md"
        echo "✅ Override mechanisms loaded"
    else
        echo "❌ Override mechanisms not found"
        return 1
    fi
    
    if [ -f "$base_dir/quality/_shared/claude-protection-integration.md" ]; then
        source "$base_dir/quality/_shared/claude-protection-integration.md"
        echo "✅ Integration layer loaded"
    else
        echo "❌ Integration layer not found"
        return 1
    fi
    
    echo ""
    
    # Run test suites
    echo "🧪 Running test suites..."
    echo ""
    
    # Test 1: Override Flag Tests
    test_override_flag_parsing
    local result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 2: Path Filtering Tests
    test_path_filtering
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 3: Dry Run Tests
    test_dry_run_functionality
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 4: Audit Logging Tests
    test_audit_logging
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 5: Integration Tests
    test_command_integration
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 6: Risk Assessment Tests
    test_risk_assessment
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Test 7: Error Handling Tests
    test_error_handling
    result=$?
    total_tests=$((total_tests + 1))
    if [ $result -ne 0 ]; then
        total_failures=$((total_failures + 1))
    fi
    
    # Calculate results
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local passed_tests=$((total_tests - total_failures))
    
    echo ""
    echo "📊 CLAUDE PROTECTION TEST RESULTS"
    echo "================================="
    echo "Total Test Suites: $total_tests"
    echo "Passed: $passed_tests"
    echo "Failed: $total_failures"
    echo "Duration: ${duration}s"
    echo ""
    
    if [ $total_failures -eq 0 ]; then
        echo "🎉 ALL TESTS PASSED!"
        echo "✅ .claude protection override mechanisms are working correctly"
        echo ""
        echo "🚀 Phase 3 implementation is COMPLETE and VALIDATED"
        return 0
    else
        echo "❌ SOME TESTS FAILED"
        echo "🔧 Review failed tests and fix issues before deployment"
        echo ""
        echo "📋 Failed test suites need attention before Phase 3 completion"
        return 1
    fi
}

# Quick validation test
validate_claude_protection_quick() {
    echo "🔍 Quick .claude protection validation..."
    
    # Check if functions are available
    local required_functions=(
        "parse_claude_override_flags"
        "confirm_claude_operation"
        "execute_claude_dry_run"
        "log_audit_event"
        "display_claude_error"
    )
    
    local missing_functions=()
    for func in "${required_functions[@]}"; do
        if ! declare -f "$func" >/dev/null 2>&1; then
            missing_functions+=("$func")
        fi
    done
    
    if [ ${#missing_functions[@]} -eq 0 ]; then
        echo "✅ All required functions available"
        echo "✅ .claude protection system ready"
        return 0
    else
        echo "❌ Missing functions:"
        for func in "${missing_functions[@]}"; do
            echo "  - $func"
        done
        return 1
    fi
}

# Export test functions
export -f run_claude_protection_tests
export -f validate_claude_protection_quick
export -f setup_claude_protection_test_env
export -f cleanup_claude_protection_test_env
```

This comprehensive test suite validates all aspects of the Phase 3 user override mechanisms:

1. **Override Flag Tests** - Ensures flags are parsed correctly
2. **Path Filtering Tests** - Validates path inclusion/exclusion logic
3. **Dry Run Tests** - Verifies safe preview functionality
4. **Audit Logging Tests** - Confirms all operations are logged
5. **Integration Tests** - Tests integration with quality commands
6. **Risk Assessment Tests** - Validates risk level calculations
7. **Error Handling Tests** - Ensures helpful error messages

The test suite provides comprehensive validation that the override mechanisms work correctly and safely.